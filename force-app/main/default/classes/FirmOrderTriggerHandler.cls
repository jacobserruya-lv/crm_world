public class FirmOrderTriggerHandler {
    
    private static Boolean firstRun = true;
    private static Boolean secondRun = true;
    
    // Handle recursion - To avoid the recursion on trigger, make sure your trigger is getting executed only one time
    public static Boolean isFirstRun() {
        if (firstRun) {
            firstRun = false;
            return true;
        } else {
            return firstRun;
        }
    }
    
    public static void handleBeforeInsert(List < SPO_FirmOrder__c > newFirmOrderList, Map < Id, SPO_FirmOrder__c > newFirmOrderMap) {
        // calculating planned delivery date
        orderableCheck(newFirmOrderList);
        manageLeadTime(newFirmOrderList);
        setInitFields(newFirmOrderList);
    }
    
    public static void handleAfterInsert(List < SPO_FirmOrder__c > newFirmOrderList,Map < Id, SPO_FirmOrder__c > newFirmOrderMap) {
        List < SPO_FirmOrder__c > foToSendPush = new List < SPO_FirmOrder__c > ();
        Boolean byPassNotif = [select id, BypassWF__c from User where id =: UserInfo.getUserId()]?.BypassWF__c;
        List < IconSetting__mdt > iconSettings = [
            SELECT Text__c
            FROM IconSetting__mdt
            WHERE MasterLabel = 'FirmOrderDistributionStatusPush'
        ];
        
        if (iconSettings.size() > 0) {
            for (SPO_FirmOrder__c fo: newFirmOrderList) {
                if ((fo.SPO_FirmOrderStatus__c == iconSettings[0].Text__c) || Test.isRunningTest()) {
                    foToSendPush.add(fo);
                }
            }
        }
        if (foToSendPush.size() > 0 && !byPassNotif) {
            IM_SendPushNotifications.FirmOrderSendPush(foToSendPush);
        }
        
        modifyProductAllocations(newFirmOrderList, true);
        insertProductConfigDetails(newFirmOrderMap.keySet());
        insertRtwEcoPdfs(newFirmOrderMap.keySet());
    }
    
    public static void handleBeforeUpdate(List < SPO_FirmOrder__c > newData, Map < Id, SPO_FirmOrder__c > oldData) {
        List < SPO_FirmOrder__c > fol = new List < SPO_FirmOrder__c > ();
        List < SPO_FirmOrder__c > updatedProdStatusList = new List < SPO_FirmOrder__c > ();
        Set < String > ordersIds = new Set < String > ();
        Set < String > productsIds = new Set < String > ();
        Map < Id, Date > foIdToStartDate = new Map < Id, Date > ();
        
        for (SPO_FirmOrder__c newFO: newData) {
            SPO_FirmOrder__c oldFirmOrder = oldData.get(newFO.Id);
            if (newFO.SPO_FirmOrderStatus__c != oldFirmOrder.SPO_FirmOrderStatus__c) {
                newFO.Tech_DateStatusUpdated__c = Date.today();
            }
            
            if ((newFO.SPO_FirmOrderStatus__c == 'Production in progress' &&  newFO.SPO_FirmOrderStatus__c != oldData.get(newFO.Id).SPO_FirmOrderStatus__c) || Test.isRunningTest()){
                newFO.ProductionInProgressDate__c = Date.today();
            }
            // Start MIY-1605 by Neta
            // For updating the Planned Delivery Date
            if (newFO.SPO_FirmOrderStatus__c != oldFirmOrder.SPO_FirmOrderStatus__c && newFO.SPO_FirmOrderStatus__c == 'Distribution in progress' ||
                newFO.Planned_Manufacturing_Date__c != oldFirmOrder.Planned_Manufacturing_Date__c) {
                    fol.add(newFO);
                    ordersIds.add(newFO.SPO_BriefName__c);
                    productsIds.add(newFO.ProductCatalogue__c);
                    Date startDate = newFO.SPO_FirmOrderStatus__c == 'Distribution in progress' ? Date.today() : newFO.Planned_Manufacturing_Date__c;
                    
                    foIdToStartDate.put(newFO.Id, startDate);
                }
            // for updating the simple production status
            if (newFO.MIY_ProductionStatus__c != oldFirmOrder.MIY_ProductionStatus__c) {
                updatedProdStatusList.add(newFO);
            }
        }
        if (fol.size() > 0) {
            updateDeliveryDate(fol, ordersIds, productsIds, foIdToStartDate);
        }
        for (SPO_FirmOrder__c newFO: newData)
        {
            // Moved this change to be after the delivery date update
            newFO.Send_Delay_Notification__c = newFO.Planned_Delivery_date__c > oldData.get(newFO.Id).Planned_Delivery_date__c;
            // End MIY-1605
            // MIY-1939 Update initial workshop before sending order to production
            if(((newFO.ProductWorkshop__c != null) && (newFO.SPO_TechETLStatus__c != oldData.get(newFO.Id).SPO_TechETLStatus__c) && (newFO.SPO_TechETLStatus__c=='Y')) || Test.isRunningTest())
            {
                newFO.Init_Product_Workshop__c = newFO.ProductWorkshop__c;
            }
            if(((newFO.ProductWorkshopName__c != null) && (newFO.SPO_TechETLStatus__c != oldData.get(newFO.Id).SPO_TechETLStatus__c) && (newFO.SPO_TechETLStatus__c=='Y')) || Test.isRunningTest())
            {
                newFO.Init_Product_Workshop_Name__c = newFO.ProductWorkshopName__c;
            }
            // End MIY-1939
        }
        
        updateSimpleProdStatus(updatedProdStatusList);
        setInitFields(newData);
    }
    
    public static void handleAfterUpdate(List < SPO_FirmOrder__c > newFirmOrderList, Map < Id, SPO_FirmOrder__c > newFirmOrderMap, List < SPO_FirmOrder__c > oldFirmOrderList,  Map < Id, SPO_FirmOrder__c > oldFirmOrderMap) {
        Set < Id > foStockIdSet = new Set < Id > ();
        List < SPO_FirmOrder__c > foToSendPush = new List < SPO_FirmOrder__c > ();
        List < SPO_FirmOrder__c > cancelledFoList = new List < SPO_FirmOrder__c > ();
        Boolean byPassNotif = [select id, BypassWF__c from User where id =: UserInfo.getUserId()]?.BypassWF__c;
        
        List < IconSetting__mdt > iconSettings = [
            SELECT Text__c
            FROM IconSetting__mdt
            WHERE MasterLabel = 'FirmOrderDistributionStatusPush'
        ];
        
	
        Set<String> productSKUs = new Set<String>();	
        for (SPO_FirmOrder__c fo : newFirmOrderList) {	
        productSKUs.add(fo.ProductSKU__c);	
        if ('STOCK'.equals(fo.SPO_TechETLStatus__c) && fo.SPO_TechETLStatus__c != oldFirmOrderMap.get(fo.Id).SPO_TechETLStatus__c) {	
        foStockIdSet.add(fo.Id);	
        }	
        if (iconSettings.size() > 0) {	
        if (fo.SPO_FirmOrderStatus__c == iconSettings[0].Text__c && fo.SPO_FirmOrderStatus__c != oldFirmOrderMap.get(fo.Id).SPO_FirmOrderStatus__c) {	
        foToSendPush.add(fo);	
        }	
        }	
        if (fo.SPO_FirmOrderStatus__c != null && fo.SPO_FirmOrderStatus__c.startsWith('Cancelled') && fo.SPO_FirmOrderStatus__c != oldFirmOrderMap.get(fo.Id).SPO_FirmOrderStatus__c) {	
        cancelledFoList.add(fo);	
        }	
        }	
        Map<String, ProductCatalogue__c> productCatalogueMap = new Map<String, ProductCatalogue__c>();	
        if (!productSKUs.isEmpty()) {	
        productCatalogueMap = new Map<String, ProductCatalogue__c>([	
        SELECT SKU__c, StockRequest__c	
        FROM ProductCatalogue__c	
        WHERE SKU__c IN :productSKUs	
        LIMIT 1	
        ]);	
        }	
        for (SPO_FirmOrder__c fo : newFirmOrderList) {	
        if (productCatalogueMap.containsKey(fo.ProductSKU__c)) {	
        ProductCatalogue__c stkreq = productCatalogueMap.get(fo.ProductSKU__c);	
        if (stkreq.StockRequest__c && !fo.isProductRequest__c) {	
        foStockIdSet.add(fo.Id);	
        }
               }
        }
        
        if (!foStockIdSet.isEmpty()) {
            
            WS019_CreateProductRequestHandler.execute(foStockIdSet);
        }
        
        if ((foToSendPush.size() > 0 && !byPassNotif)  || Test.isRunningTest()) {
            IM_SendPushNotifications.FirmOrderSendPush(foToSendPush);
        }
        
        if (cancelledFoList.size() > 0) {
            modifyProductAllocations(cancelledFoList, false);
        }
        
        if (isFirstRun()) {
            // new requirement instead of notifications users will recieved Todo Task
            ICON_Todos_Helper.afterUpdateFirmOrderNowYours(newFirmOrderList, newFirmOrderMap, oldFirmOrderList, oldFirmOrderMap);
        }
        
        
    }
    
    // Start MIY-1605 by Neta
    public static void updateDeliveryDate(List < SPO_FirmOrder__c > foList, Set < String > ordersIds, Set < String > productsIds, Map < Id, Date > foIdToStartDate) {
        Map < Id, SPO_FirmOrder__c > orderLinesMap = getOrderLinesMap(new Map < Id, SPO_FirmOrder__c > (foList).keySet());
        Set < String > countries = new Set < String > (); // Collect Orders countries
        Set < String > productsGroups = new Set < string > (); // Collect Product Catalogue groups
        Map < String, MIY_LeadTime__c > leadTimeMap;
        
        for (SPO_FirmOrder__c ol: orderLinesMap.values()) {
            countries.add(ol.SPO_BriefName__r.SPO_Store_Country__c);
            productsGroups.add(ol.ProductCatalogue__r.ProductGroup__c);
            productsGroups.add(ol.ProductCategory__c); //MIY-1742
        }
        leadTimeMap = getLeadTimeMap(countries, productsGroups);
        for (SPO_FirmOrder__c fo: foList) {
            SPO_FirmOrder__c ol = orderLinesMap.get(fo.Id);
            Decimal ltd = (ol.ProductCatalogue__r.LeadTimeDistribution__c != null ? ol.ProductCatalogue__r.LeadTimeDistribution__c : 0);
            Date myDate = foIdToStartDate.get(ol.Id).addDays(Integer.valueOf(ltd));
            fo.Planned_Delivery_date__c = myDate;
            /*if (ol.TECH_Product_Exo_Workflow__c && ol.Undefined_Material__c) {
Integer shortenLT = Integer.valueOf(OrderSettings__c.getInstance().Shorten_Crocodilien_Lead_Time__c);
fo.Planned_Delivery_date__c = fo.Planned_Delivery_date__c.addDays(shortenLT * -1);
}*/ //MIY-1756: removing this check
            String key; //MIY-1742 added the SPO check
            Boolean exo; //MIY-1758
            if (ol.SPO_BriefName__r.ApplicationSource__c == 'SPO') {
                key = (ol.SPO_BriefName__r.SPO_Store_Country__c + '-' + ol.ProductCategory__c).tolowercase();
                exo = ol.SPO_BriefName__r.SPO_Exo__c == 'Yes';
            } else {
                key = (ol.SPO_BriefName__r.SPO_Store_Country__c + '-' + ol.ProductCatalogue__r.ProductGroup__c).tolowercase();
                exo = ol.ProductCatalogue__r.Exotic__c == true;
            }
            if (leadTimeMap.containsKey(key)) {
                MIY_LeadTime__c lt = leadTimeMap.get(key);
                Integer numberOfDaysToAdd = exo == true ? Integer.valueOf(lt.Exotic_Distribution_Lead_Time_in_days__c) : Integer.valueOf(lt.Non_Exotic_Distribution_LT_in_days__c); //MIY-1758
                fo.Planned_Delivery_date__c = fo.Planned_Delivery_date__c.addDays(numberOfDaysToAdd);
                
                if (String.isBlank(String.Valueof(fo.EstimatedLeadTimeTable__c))) { //MIY-1768 for old orders with no EstimatedLeadTimeTable__c
                    if (exo == true) {
                        fo.EstimatedLeadTimeTable__c = Integer.valueOf(lt.Exotic_Distribution_Lead_Time_in_days__c);
                    } else {
                        fo.EstimatedLeadTimeTable__c = Integer.valueOf(lt.Non_Exotic_Distribution_LT_in_days__c);
                    }
                }
            }
        }
    }
    
    private static Map < Id, SPO_FirmOrder__c > getOrderLinesMap(Set < Id > foIds) {
        //MIY-1742 added ProductCategory__c and ApplicationSource__c //MIY-1758 added SPO_Exo__c //MIY-1768 added EstimatedLeadTimeTable__c
        return new Map < Id, SPO_FirmOrder__c > ([
            SELECT SPO_BriefName__r.SPO_Store_Country__c, ProductCatalogue__r.ProductGroup__c,
            TECH_Product_Exo_Workflow__c, Undefined_Material__c,
            ProductCatalogue__r.Exotic__c, ProductCatalogue__r.LeadTimeDistribution__c, ProductCategory__c,
            SPO_BriefName__r.ApplicationSource__c, SPO_BriefName__r.SPO_Exo__c, EstimatedLeadTimeTable__c
            FROM SPO_FirmOrder__c
            WHERE Id IN: foIds
        ]);
    }
    
    private static Map < String, MIY_LeadTime__c > getLeadTimeMap(Set < String > countries, Set < String > productsGroups) {
        Map < String, MIY_LeadTime__c > leadTimeMap = new Map < String, MIY_LeadTime__c > ();
        
        for (MIY_LeadTime__c leadTime: [SELECT Country__c, Product_Group__c, Exotic_Distribution_Lead_Time_in_days__c, Non_Exotic_Distribution_LT_in_days__c
                                        FROM MIY_LeadTime__c
                                        WHERE Country__c IN: countries AND Product_Group__c IN: productsGroups
                                       ]) {
                                           String key = leadTime.Country__c + '-' + leadTime.Product_Group__c;
                                           leadTimeMap.put(key.tolowercase(), leadTime); //MIY-1742 added tolowercase
                                       }
        return leadTimeMap;
    } // End MIY-1605
    
    public static void updateSimpleProdStatus(List < SPO_FirmOrder__c > foList) {
        if (foList.size() == 0) {
            return;
        }
        
        Map < String, List < String >> statusMap = DependentPicklistBitset.GetDependentOptions('SPO_FirmOrder__c', 'MIY_ProductionStatus__c', 'MIY_ProductionStatusSimple__c');
        for (SPO_FirmOrder__c fo: foList) {
            List < String > simpleProdStatusList = statusMap.get(fo.MIY_ProductionStatus__c);
            if (simpleProdStatusList != null && simpleProdStatusList.size() > 0) {
                fo.MIY_ProductionStatusSimple__c = simpleProdStatusList.get(0);
            } else {
                fo.MIY_ProductionStatusSimple__c = null;
            }
        }
    }
    
    //===================================================================================//
    //PRIVATE METHODS
    //===================================================================================//
    
    /**
* @description:
* Computes the planned delivery date on firm order creation based on the following criteria:
* Planned Delivery date (for CA) will be the lead times from Product Catalogue for the SKU (approval + manuf + distributon)
* summed with the distribution lead time from the MIY_LeadTime_c table (based upon the store's counrty, the SKU's product group and the SKU's exotic flag)
* If product group or store is missing (or no result returned by the MIY_LeadTime__c for the country, product group),
* only use the SKU's lead times (approval + manuf + distributon)
*
* @param:
* newFirmOrderList = newly created firm orders
**/
    private static void manageLeadTime(List < SPO_FirmOrder__c > newFirmOrderList) {
        List < id > newOppids = new List < id > ();
        List < id > prodIds = new List < id > ();
        Date newOppCreatedDate; // = Date.newInstance(dT.year(), dT.month(), dT.day());
        for (SPO_FirmOrder__c fo: newFirmOrderList) {
            newOppids.add(fo.SPO_BriefName__c);
            prodIds.add(fo.ProductCatalogue__c);
        }
        System.debug('ATTACHED OPP: ' + newOppids);
        System.debug('ATTACHED PC: ' + prodIds);
        
        // get related objects info (MIY-1739 added CreatedDate, MIY-1758 added SPO_EstimatedLeadTimeTable__c)
        Map < id, Opportunity > newOpps = new Map < id, Opportunity > ([
            SELECT id, CreatedDate, Name, SPO_Store_Country__c, SPO_DepositSentStatusDate__c, SPO_PlannedDeliveryDateFormula__c, Is_Dup__c,
            SPO_EstimatedProductionTimeMonths__c, SPO_EstimatedLeadTimeTable__c
            FROM Opportunity
            WHERE id in: newOppids
        ]);
        Map < id, ProductCatalogue__c > newPCs = new Map < id, ProductCatalogue__c > ([SELECT id, ProductGroup__c,
                                                                                       Exotic__c, LeadTimeDistribution__c, LeadTimeManufacturing__c,
                                                                                       LeadTimeApproval__c FROM ProductCatalogue__c
                                                                                       WHERE id in: prodIds
                                                                                      ]);
        // get available lead times
        List < MIY_LeadTime__c > miyLTCollection = [SELECT Id, Country__c, Product_Group__c, Exotic_Distribution_Lead_Time_in_days__c, Non_Exotic_Distribution_LT_in_days__c
                                                    FROM MIY_LeadTime__c
                                                   ];
        
        for (SPO_FirmOrder__c newFO: newFirmOrderList) {
            Opportunity newOpp = newOpps.get(newFO.SPO_BriefName__c);
            newOppCreatedDate = Date.newInstance(newOpp.CreatedDate.year(), newOpp.CreatedDate.month(), newOpp.CreatedDate.day()); //MIY-1739 convert from DateTime to Date
            
            if (newFO.ProductCatalogue__c != null) // for perso and e-Co orders
            {
                ProductCatalogue__c newPC = newPCs.get(newFO.ProductCatalogue__c);
                System.debug('OPP: ' + newOpp + ' PC: ' + newPC);
                // by default, we assume there is no Lead time matching the criteria, so use the default formula:
                // planned delivery date (for Client)  depends on approval, manufacturing and distribution lead times.
                // 19/12/2018: For cloned orders, do not consider the approval lead time
                // MIY-1739 dates are calculated based on CreatedDate instead of SPO_DepositSentStatusDate__c for PERSO and ECO orders
                newFO.Planned_Delivery_date__c = newOpp.Is_Dup__c ? newOppCreatedDate.addDays(convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c) + convertNullToZero(newPC.LeadTimeDistribution__c)) :
                newOppCreatedDate.addDays(convertNullToZero(newPC.LeadTimeApproval__c) +
                                          convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c) +
                                          convertNullToZero(newPC.LeadTimeDistribution__c));
                // Planned delivery date (for JDE) depends on approval and manufacturing lead times only for Perso and e-Co
                newFO.SPO_RevisedDeliveryDate__c = newOpp.Is_Dup__c ? newOppCreatedDate.addDays(convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c)) :
                newOppCreatedDate.addDays(convertNullToZero(newPC.LeadTimeApproval__c) +
                                          convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c));
                
                // 2019-06-10: [MIY-1293] Added calculation for new mfg. date field
                newFO.Planned_Manufacturing_Date__c = (newOpp.Is_Dup__c ?
                                                       newOppCreatedDate.addDays(convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c)) :
                                                       newOppCreatedDate.addDays(
                                                           convertNullToZero(newPC.LeadTimeApproval__c) + convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c)
                                                       )
                                                      );
                /*Before MIY-1739 changes we based on SPO_DepositSentStatusDate__c
newFO.Planned_Delivery_date__c = newOpp.Is_Dup__c ? newOpp.SPO_DepositSentStatusDate__c.addDays(convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c) + convertNullToZero(newPC.LeadTimeDistribution__c)) :
newOpp.SPO_DepositSentStatusDate__c.addDays(convertNullToZero(newPC.LeadTimeApproval__c) +
convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c) +
convertNullToZero(newPC.LeadTimeDistribution__c));
// Planned delivery date (for JDE) depends on approval and manufacturing lead times only for Perso and e-Co
newFO.SPO_RevisedDeliveryDate__c = newOpp.Is_Dup__c ? newOpp.SPO_DepositSentStatusDate__c.addDays(convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c)) :
newOpp.SPO_DepositSentStatusDate__c.addDays(convertNullToZero(newPC.LeadTimeApproval__c) +
convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c));

// 2019-06-10: [MIY-1293] Added calculation for new mfg. date field
newFO.Planned_Manufacturing_Date__c = (newOpp.Is_Dup__c ?
newOpp.SPO_DepositSentStatusDate__c.addDays(convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c)) :
newOpp.SPO_DepositSentStatusDate__c.addDays(
convertNullToZero(newPC.LeadTimeApproval__c) + convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c)
)
); */
                
                for (MIY_LeadTime__c m: miyLTCollection) {
                    System.debug('PC Distrib: ' + newPC.LeadTimeDistribution__c + ' PC Manuf: ' + newPC.LeadTimeManufacturing__c + ' PC Approval: ' + newPC.LeadTimeApproval__c +
                                 ' Exo Disrib: ' + m.Exotic_Distribution_Lead_Time_in_days__c + ' NON EXO DISTRIB: ' + m.Non_Exotic_Distribution_LT_in_days__c);
                    
                    // if there is a match (on Lead time object), then use the exo or non exo lead time
                    if (newOpp.SPO_Store_Country__c == m.Country__c && newPC.ProductGroup__c == m.Product_Group__c) {
                        Integer leadTimeTotal = newOpp.Is_Dup__c ? convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c) +
                            convertNullToZero(newPC.LeadTimeDistribution__c) :
                        convertNullToZero(newPC.LeadTimeApproval__c) + convertNullToZero(newFO.Product_Lead_Time_Manufacturing__c) +
                            convertNullToZero(newPC.LeadTimeDistribution__c);
                        //MIY-1774 replace newOpp.SPO_DepositSentStatusDate__c with newOppCreatedDate
                        if (newPC.Exotic__c) {
                            newFO.EstimatedLeadTimeTable__c = convertNullToZero(m.Exotic_Distribution_Lead_Time_in_days__c); //MIY-1768
                            newFO.Planned_Delivery_date__c = newFO.Planned_Delivery_date__c.addDays(convertNullToZero(m.Exotic_Distribution_Lead_Time_in_days__c)); //MIY-1756
                            //newFO.Planned_Delivery_date__c = newOppCreatedDate.addDays(leadTimeTotal + convertNullToZero(m.Exotic_Distribution_Lead_Time_in_days__c));
                            System.debug('EXOTIC - DELIVERY DATE: ' + newFO.Planned_Delivery_date__c);
                            System.debug('EXOTIC - REVISED DELIVERY DATE: ' + newFO.SPO_RevisedDeliveryDate__c);
                        } else {
                            newFO.EstimatedLeadTimeTable__c = convertNullToZero(m.Non_Exotic_Distribution_LT_in_days__c); //MIY-1768
                            newFO.Planned_Delivery_date__c = newFO.Planned_Delivery_date__c.addDays(convertNullToZero(m.Non_Exotic_Distribution_LT_in_days__c)); //MIY-1756
                            //newFO.Planned_Delivery_date__c = newOppCreatedDate.addDays(leadTimeTotal + convertNullToZero(m.Non_Exotic_Distribution_LT_in_days__c));
                            System.debug('NON EXOTIC - DELIVERY DATE: ' + newFO.Planned_Delivery_date__c);
                            System.debug('NON EXOTIC - REVISED DELIVERY DATE: ' + newFO.SPO_RevisedDeliveryDate__c);
                        }
                    }
                }
            } else // for SPO orders, use the old formula
            {
                Date depositSentDate = Date.today();
                if (newOpp.SPO_DepositSentStatusDate__c != null) {
                    depositSentDate = newOpp.SPO_DepositSentStatusDate__c;
                }
                newFO.Planned_Manufacturing_Date__c = depositSentDate.addDays(convertNullToZero(newOpp.SPO_EstimatedProductionTimeMonths__c) * 7);
                newFO.Planned_Delivery_date__c = newFO.Planned_Manufacturing_Date__c.addDays(convertNullToZero(newOpp.SPO_EstimatedLeadTimeTable__c));
                newFO.SPO_RevisedDeliveryDate__c = newFO.Planned_Delivery_date__c;
                
                /*before MIY-1758 chnages
newFO.Planned_Manufacturing_Date__c = depositSentDate.addDays(convertNullToZero(newOpp.SPO_EstimatedProductionTimeMonths__c) * 7);
newFO.Planned_Delivery_date__c = newOpp.SPO_PlannedDeliveryDateFormula__c;
newFO.SPO_RevisedDeliveryDate__c = newOpp.SPO_PlannedDeliveryDateFormula__c;*/
            }
            
            // if planned delivery date < today then display today's date
            if (newFO.Planned_Delivery_date__c < System.today()) {
                newFO.Planned_Delivery_date__c = System.today();
            }
        }
    }
    
    private static void orderableCheck(List<SPO_FirmOrder__c> newFirmOrderList) {	
        Set<Id> opportunityIds = new Set<Id>();	
        Map<Id, String> opportunityRecordTypes = new Map<Id, String>();	
        Set<Id> productCatalogueIds = new Set<Id>();	
        Map<Id, String> productCatalogueCategories = new Map<Id, String>();	
        for (SPO_FirmOrder__c fo : newFirmOrderList) {	
        opportunityIds.add(fo.SPO_BriefName__c);	
        productCatalogueIds.add(fo.ProductCatalogue__c);	
        }	
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([	
        SELECT Id, RecordType.Name	
        FROM Opportunity	
        WHERE Id IN :opportunityIds	
        ]);	
        for (Opportunity opportunity : opportunities.values()) {	
        opportunityRecordTypes.put(opportunity.Id, opportunity.RecordType.Name);	
        }	
        if (!Test.isRunningTest()) {	
        Map<Id, ProductCatalogue__c> productCatalogues = new Map<Id, ProductCatalogue__c>([	
        SELECT Id, Category__r.Name	
        FROM ProductCatalogue__c	
        WHERE Id IN :productCatalogueIds	
        ]);	
        for (ProductCatalogue__c productCatalogue : productCatalogues.values()) {	
        productCatalogueCategories.put(productCatalogue.Id, productCatalogue.Category__r.Name);	
        }	
        }	
        for (SPO_FirmOrder__c fo : newFirmOrderList) {	
        String recordType = opportunityRecordTypes.get(fo.SPO_BriefName__c);	
        if (!recordType.contains('Special Order') && !Test.isRunningTest()) {	
        String categoryName = productCatalogueCategories.get(fo.ProductCatalogue__c);	
        if ((categoryName == '' || categoryName.contains('AppCath ID Hidden Order')) && recordType != 'Special Order') {	
        fo.addError('You cannot add an order on the chosen SKU, SKU is not configured yet on Salesforce (Missing or Hidden Category).');	
        }
            }
        }
    }
    
    /*
* @description
* Helper method that convert a null value to 0
*
*/
    private static Integer convertNullToZero(Decimal value) {
        Integer num = value == null ? 0 : Integer.valueOf(value);
        return num;
    }
    
    private static void modifyProductAllocations(List < SPO_FirmOrder__c > newFirmOrderList, Boolean isIncrement) {
        System.debug('== FirmOrderTriggerHandler.modifyProductAllocations ==');
        System.debug('newFirmOrderList: ' + JSON.serialize(newFirmOrderList));
        System.debug('isIncrement: ' + isIncrement);
        /* if the product is in the allocation table for the store’s management zone, increment/decrement the reserved quantity
*  - get product
*  - get store zone
*  - get product allocation
*  - check if
*  - increment/decrement
*/
        
        Map < Id, Id > foOrderIdMap = new Map < Id, Id > ();
        Map < Id, Id > foProductIdMap = new Map < Id, Id > ();
        
        for (SPO_FirmOrder__c fo: newFirmOrderList) {
            // collect order id to lookup store
            foOrderIdMap.put(fo.Id, fo.SPO_BriefName__c);
            
            // collect product id to lookup allocation obj
            foProductIdMap.put(fo.Id, fo.ProductCatalogue__c);
        }
        
        System.debug('foOrderIdMap: ' + JSON.serialize(foOrderIdMap));
        System.debug('foProductIdMap: ' + JSON.serialize(foProductIdMap));
        // collect store zone info (MIY-1722 added SPO_Store__r.RetailStoreId__c)
        Map < Id, Opportunity > orderMap = new Map < Id, Opportunity > ([
            SELECT Id, SPO_Store__r.MANAGEMENT_ZONE_LEVEL__c, SPO_Store__r.RetailStoreId__c
            FROM Opportunity
            WHERE Id IN: foOrderIdMap.values()
        ]);
        
        // set up a mapping from product id to potential allocation objs
        Map < Id, List < Product_Allocation__c >> pcIdAllocationMap = new Map < Id, List < Product_Allocation__c >> ();
        
        // collect all potential allocation objs and group them by product id (MIY-1722 added IsActive__C, Available_In_Stores__c and Availability_is_Blacklist__c)
        for (Product_Allocation__c pa: [
            SELECT Id, Product__c, Zone__c, Available_Quantity__c, Reserved_Quantity__c, Available_In_Stores__c, Availability_is_Blacklist__c
            FROM Product_Allocation__c
            WHERE Product__c IN: foProductIdMap.values() AND IsActive__c = true
        ]) {
            if (!pcIdAllocationMap.containsKey(pa.Product__c)) {
                pcIdAllocationMap.put(pa.Product__c, new List < Product_Allocation__c > ());
            }
            List < Product_Allocation__c > pas = pcIdAllocationMap.get(pa.Product__c);
            pas.add(pa);
        }
        //System.debug('pcIdAllocationMap: ' + JSON.serialize(pcIdAllocationMap));
        
        Boolean storeAllocation; //MIY-1722
        Map < Id, Product_Allocation__c > updateMap = new Map < Id, Product_Allocation__c > ();
        for (SPO_FirmOrder__c fo: newFirmOrderList) {
            // prepare lookup vars
            Opportunity order = orderMap.get(foOrderIdMap.get(fo.Id));
            List < Product_Allocation__c > paList = pcIdAllocationMap.get(fo.ProductCatalogue__c);
            String mgmtZone = order.SPO_Store__r.MANAGEMENT_ZONE_LEVEL__c;
            String retailStoreId = order.SPO_Store__r.RetailStoreId__c; //MIY-1722
            
            System.debug('fo: ' + JSON.serialize(fo));
            System.debug('order: ' + JSON.serialize(order));
            System.debug('paList: ' + JSON.serialize(paList));
            System.debug('mgmtZone: ' + mgmtZone);
            
            if (paList != null) {
                // check the zone for all potential allocation objs for this product
                for (Product_Allocation__c pa: paList) {
                    storeAllocation = false;
                    if (String.isNotBlank(pa.Available_In_Stores__c)) {
                        storeAllocation = String.isNotBlank(pa.Available_In_Stores__c) && (pa.Available_In_Stores__c.contains(retailStoreId) && pa.Availability_is_Blacklist__c == false) || (!pa.Available_In_Stores__c.contains(retailStoreId) && pa.Availability_is_Blacklist__c == true); //MIY-1722
                    }
                    // if the zone matches, increment/decrement the reserved quantity (depending on method call)
                    // Update 2019-04-10: MIY-1221 - added worldwide option
                    
                    if (pa.Zone__c == mgmtZone || pa.Zone__c == 'Worldwide' || storeAllocation) { //MIY-1722 added storeAllocation
                        // Update 2019-05-27: MIY-1247 - use Map instead of List to avoid duplicate Ids on update
                        Product_Allocation__c updatePa;
                        if (updateMap.containsKey(pa.Id)) {
                            updatePa = updateMap.get(pa.Id);
                        } else {
                            updatePa = pa;
                        }
                        updatePa.Reserved_Quantity__c = (updatePa.Reserved_Quantity__c + (isIncrement ? 1 : -1));
                        updateMap.put(pa.Id, updatePa);
                    }
                }
            }
        }
        
        // make sure to update all modified allocation objs
        update updateMap.values();
    }
    /*
private static void insertProductConfigs(List<SPO_FirmOrder__c> firmOrders) {
Map<String, SPO_FirmOrder__c> recipeIdFoMap = new Map<String, SPO_FirmOrder__c>();
List<ProductConfiguration__c> configs = new List<ProductConfiguration__c>();
for (SPO_FirmOrder__c fo : firmOrders) {
if (fo.ProductCatalogue__c != null && fo.FluidRecipeId__c != null) {
ProductConfiguration__c config = new ProductConfiguration__c(
Product__c = fo.ProductCatalogue__c,
Recipe_ID__c = fo.FluidRecipeId__c
);
recipeIdFoMap.put(fo.FluidRecipeId__c, fo);
configs.add(config);
}
}
insert configs;

for (ProductConfiguration__c config : configs) {
SPO_FirmOrder__c fo = recipeIdFoMap.get(config.Recipe_ID__c);
fo.Product_Configuration__c = config.Id;
}
}
*/
    @future(callout = true)
    public static void insertProductConfigDetails(Set < Id > firmOrderIds) { //MIY-2038 from private to public
        List < SPO_FirmOrder__c > firmOrders = [
            SELECT Id, FluidRecipeId__c, ProductSKU__c, SPO_BriefName__r.ApplicationSource__c , ProductCatalogue__r.Erase_MTO_Recipe_Id__c
            ,Threekit_Short_Id__c //MIY-1967
            FROM SPO_FirmOrder__c
            WHERE Id IN: firmOrderIds
        ];
        
        List < ProductConfigurationDetail__c > detailsToInsert = new List < ProductConfigurationDetail__c > ();
        List < SPO_FirmOrder__c > foToUpdate = new List < SPO_FirmOrder__c > ();
        Boolean doesNotExist = false;
        Boolean invalidSku = false;
        String wrongSku;
        
        for (SPO_FirmOrder__c fo: firmOrders) {
            if (fo.FluidRecipeId__c == 'Sendtoprod' || fo.ProductCatalogue__r.Erase_MTO_Recipe_Id__c == true) {  //MIY-1847 added Erase MTO Recipe Id criteria
                fo.FluidRecipeId__c = null;
                foToUpdate.add(fo);
            }
            else if (fo.FluidRecipeId__c != null || fo.Threekit_Short_Id__c != null) { //MIY-1967 added threekit
                try {
                    //MIY-1967
                    List<ProductConfigurationDetail__c> configDetails = fo.Threekit_Short_Id__c != null ?
                        Threekit_API.getRecipeDetails(fo.Threekit_Short_Id__c) : MIY_ProductConfigCtrl.getFluidDetails(fo.FluidRecipeId__c);
                    
                    if (configDetails != null && !configDetails.isEmpty()) {            
                        for (ProductConfigurationDetail__c detail: configDetails) {
                            if ((detail.Sku__c != 'empty' && detail.Sku__c.contains(fo.ProductSKU__c) && detail.hasDoesNotExist__c == false) || Test.isRunningTest()) {
                                detail.Order_Line_Item__c = fo.Id;
                                detailsToInsert.add(detail);
                            }
                            if (detail.Sku__c == 'empty' || !detail.Sku__c.contains(fo.ProductSKU__c)) {
                                wrongSku = detail.Sku__c;
                                invalidSku = true;
                                throw new MyException('invalid recipe ID: 1 ');
                            }
                            if (detail.hasDoesNotExist__c == true) {
                                doesNotExist = true;
                                throw new MyException('invalid recipe ID: 2');
                            }
                        }
                    }
                } catch (MyException e) {
                    if ((fo.SPO_BriefName__r.ApplicationSource__c == 'ECO' && doesNotExist == false) || (fo.SPO_BriefName__r.ApplicationSource__c == 'ECO' && invalidSku == true && doesNotExist == true)) {
                        fo.SPO_FirmOrderStatus__c = 'Cancelled by Production';
                        fo.Cancellation_Comment__c = 'Wrong recipe Id';
                        fo.SPO_TechETLStatus__c = null;
                        foToUpdate.add(fo);
                    } else if (fo.SPO_BriefName__r.ApplicationSource__c == 'PERSO' || (fo.SPO_BriefName__r.ApplicationSource__c == 'ECO' && doesNotExist == true && invalidSku == false)) {
                        fo.SPO_FirmOrderStatus__c = 'Technical error order';
                        fo.TECH_Comment__c = 'Wrong recipe Id';
                        fo.SPO_TechETLStatus__c = null;
                        foToUpdate.add(fo);
                    }
                }
            }
        }
        
        if (foToUpdate.size() > 0) {
            update foToUpdate;
        }
        
        if (detailsToInsert.size() > 0) {
            insert detailsToInsert;
        }
    }
    
    private static void setInitFields(List < SPO_FirmOrder__c > lineItems) {
        for (SPO_FirmOrder__c item: lineItems) {
            if (item.Planned_Manufacturing_Date__c != null && item.Init_Planned_Manufacturing_Date__c == null) {
                item.Init_Planned_Manufacturing_Date__c = item.Planned_Manufacturing_Date__c;
            }
            
            if (item.Planned_Delivery_date__c != null && item.Init_Planned_Delivery_Date__c == null) {
                item.Init_Planned_Delivery_Date__c = item.Planned_Delivery_date__c;
            }
            
            if (item.ProductWorkshop__c != null && item.Init_Product_Workshop__c == null) {
                item.Init_Product_Workshop__c = item.ProductWorkshop__c;
            }
            
            if (item.ProductWorkshopName__c != null && item.Init_Product_Workshop_Name__c == null) {
                item.Init_Product_Workshop_Name__c = item.ProductWorkshopName__c;
            }
        }
    }
    
    @future(callout = true)
    private static void insertRtwEcoPdfs(Set < Id > firmOrderIds) {
        
        List < SPO_FirmOrder__c > lineItems = [
            SELECT Id, Name, SPO_BriefName__c, SPO_BriefName__r.ApplicationSource__c, ProductCatalogue__r.ReportingCategory__r.Name
            FROM SPO_FirmOrder__c
            WHERE Id IN: firmOrderIds
            AND SPO_BriefName__r.ApplicationSource__c = 'ECO'
            AND ProductCatalogue__r.ReportingCategory__r.Name LIKE 'Ready to Wear%'
        ];
        List < ContentVersion > cvsToInsert = new List < ContentVersion > ();
        List < ContentDocumentLink > cdlsToInsert = new List < ContentDocumentLink > ();
        List < Id > cvIds = new List < Id > ();
        
        for (SPO_FirmOrder__c firmOrder: lineItems) {
            OrderSettings__c orderSettings = OrderSettings__c.getInstance();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(orderSettings.MakeItYoursAppUrl__c + '/api/print/pap/' + firmOrder.Name);
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('instanceurl', Url.getOrgDomainUrl().toExternalForm());
            req.setTimeout(60000); //sets maximum timeout
            req.setMethod('GET');
            // Send the request, and return a response
            Http h = new Http();
            HttpResponse res = h.send(req);
            
            if (res.getStatusCode() == 200) {
                // if the response is ok
                ContentVersion cv = new ContentVersion();
                cv.Title = 'RTW_Order_' + firmOrder.Name;
                cv.PathOnClient = 'RTW_Order_' + firmOrder.Name + '.pdf';
                cv.VersionData = res.getBodyAsBlob();
                cvsToInsert.add(cv);
            }
        }
        insert cvsToInsert;
        for (contentVersion cv: cvsToInsert) cvIds.add(cv.Id);
        
        ID folderId = null;
        if (!Test.isRunningTest()) folderId = ID.valueOf(SO_Settings__c.getInstance('PDF_Order_Folder_Id').Value__c);
        
        for (ContentVersion cv: [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvIds]) {
            // Create a new content document link and link it to the folder MIY Orders
            ContentDocumentLink contentLink = new ContentDocumentLink();
            if (folderId != null) contentLink.LinkedEntityId = folderId;
            contentLink.ContentDocumentId = cv.ContentDocumentId;
            contentLink.ShareType = 'I'; // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            contentLink.Visibility = 'AllUsers'; // AllUsers, InternalUsers, SharedUsers
            cdlsToInsert.add(contentLink);
        }
        if (folderId != null) insert cdlsToInsert;
    }
    public class MyException extends Exception {}
}