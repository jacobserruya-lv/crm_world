public with sharing class OpportunityTriggerHandler {
    private static Boolean firstRun = true;
    
    // Handle recursion - To avoid the recursion on trigger, make sure your trigger is getting executed only one time 
    public static Boolean isFirstRun() {
        if (firstRun) {
            firstRun = false;
            return true;
        } else {
            return firstRun;
        }
    }
    
    public static void handleBeforeUpdate(List<Opportunity> newOrderList, Map<Id, Opportunity> newOrderMap, List<Opportunity> oldOrderList, Map<Id, Opportunity> oldOrderMap) {
        updateManufacuringDelayTime(newOrderList);
        updateOppAccFlag(newOrderList);
    }
    
    
    public static void handleAfterUpdate(List<Opportunity> newOrderList, Map<Id, Opportunity> newOrderMap, List<Opportunity> oldOrderList, Map<Id, Opportunity> oldOrderMap) {
        List<Opportunity> oppToSendPush = new List<Opportunity>();
        
        List<IconSetting__mdt> iconSettings = [Select Text__c
                                               FROM IconSetting__mdt 
                                               WHERE MasterLabel ='OrderStageNameForPush'];
        
        if(iconSettings.size()>0) {
            for(Opportunity opp : newOrderList){
                if (opp.StageName == iconSettings[0].Text__c && opp.StageName != oldOrderMap.get(opp.Id).StageName){
                    oppToSendPush.add(opp);
                }
            }
            if (oppToSendPush.size()>0){
                IM_SendPushNotifications.OpportunitySendPush(oppToSendPush);
            }
        }
       

    }
    
    public static void handleAfterInsert(List<Opportunity> newOrderList, Map<Id, Opportunity> newOrderMap){
        List<Opportunity> oppToSendPush = new List<Opportunity>();
        
        List<IconSetting__mdt> iconSettings = [Select Text__c
                                               FROM IconSetting__mdt 
                                               WHERE MasterLabel ='OrderStageNameForPush'];
        
        if(iconSettings.size()>0) {
            
            for(Opportunity opp : newOrderList){
                if (opp.StageName == iconSettings[0].Text__c){
                    oppToSendPush.add(opp);
                }
            }
            if (oppToSendPush.size()>0){
                IM_SendPushNotifications.OpportunitySendPush(oppToSendPush);
            }
        }
        for(Opportunity opp : newOrderList){
            if (opp.ApplicationSource__c =='ECO'  && !Test.isRunningTest()){
                SPO_OppStandardControllerExtension.insertPdf(opp.Id) ;
            }
        }
        
    }
    
    public static void handleBeforeInsert(List<Opportunity> newOrderList, Map<Id, Opportunity> newOrderMap){
        updateDistributionLeadTime(newOrderList);
        updateOppAccFlag(newOrderList);
    }
    
    private static void updateDistributionLeadTime(List<Opportunity> opps){
        
        Set<String> countries = new Set<String>();
        Set<String> BaseSkus = new Set<String>();
        Set<String> ProductCategories = new Set<String>();
        
        for(Opportunity opp: opps) {
            if(opp.ApplicationSource__c == 'SPO') {
                if (opp.SPO_Store_Country__c != null) {
                    countries.add(opp.SPO_Store_Country__c);
                }
                if (opp.SPO_BaseSku__c != null) {
                    BaseSkus.add(opp.SPO_BaseSku__c);
                }
            }
        }
        
        /* List<ProductCatalogue__c> newPCs = new List<ProductCatalogue__c>([SELECT id, ProductGroup__c,
Exotic__c , ProductReferential__r.SKUCode__c FROM ProductCatalogue__c
WHERE ProductReferential__r.SKUCode__c in:BaseSkus]);

for(ProductCatalogue__c product: newPCs) {
ProductGroups.add(product.ProductGroup__c);
}*/
        
        List<ProductReferential__c> newPRs = new List<ProductReferential__c>([
            SELECT Id, SKUCode__c, ProductCategory__c 
            FROM ProductReferential__c
            WHERE SKUCode__c IN :BaseSkus
        ]);
        
        for(ProductReferential__c productR: newPRs) {
            ProductCategories.add(productR.ProductCategory__c);
        }
        
        List<MIY_LeadTime__c>  miyLTCollection = [
            SELECT Id, Country__c, Product_Group__c, Exotic_Distribution_Lead_Time_in_days__c, Non_Exotic_Distribution_LT_in_days__c
            FROM MIY_LeadTime__c 
            WHERE Country__c IN :countries 
            AND Product_Group__c IN :ProductCategories
        ];
        
        
        for(Opportunity opp: opps) {
            if(opp.ApplicationSource__c == 'SPO') {
                for (MIY_LeadTime__c leadTime: miyLTCollection) {
                    for (ProductReferential__c productR :newPRs) {
                        if (productR.SKUCode__c == opp.SPO_BaseSku__c) {
                            if (opp.SPO_Store_Country__c == leadTime.Country__c &&
                                productR.ProductCategory__c == leadTime.Product_Group__c) {
                                    if (opp.SPO_Exo__c == 'yes') {
                                        opp.SPO_EstimatedDistributionTime__c =
                                            (leadTime.Exotic_Distribution_Lead_Time_in_days__c / 7).round(
                                                System.RoundingMode.UP);
                                    } else {
                                        opp.SPO_EstimatedDistributionTime__c =
                                            (leadTime.Non_Exotic_Distribution_LT_in_days__c / 7).round(
                                                System.RoundingMode.UP);
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    private static void updateManufacuringDelayTime(List<Opportunity> opps) {
        if( !Test.isRunningTest()){
        Set<String> BaseSkus = new Set<String>();
        Set<String> CreationType = new Set<String>();
        Set<String> OrderType = new Set<String>();
        Set<String> ProductCategories = new Set<String>();
        Set<String> Workshops = new Set<String>();
        
        for(Opportunity opp: opps) {
            if(opp.ApplicationSource__c == 'SPO') {
                if (opp.SPO_BaseSku__c != null) {
                    BaseSkus.add(opp.SPO_BaseSku__c);
                }
                if (opp.SPO_OrderType__c != null) {
                    OrderType.add(opp.SPO_OrderType__c);
                }
                if (opp.SPO_CreationType__c != null) {
                    CreationType.add(opp.SPO_CreationType__c);
                }
                if (opp.Workshop__c != null) {
                    Workshops.add(opp.Workshop__c);
                }
            }
        } 
        List<ProductReferential__c> newPRs ;
        
        newPRs = new List<ProductReferential__c>([
            SELECT Id, SKUCode__c, ProductCategory__c 
            FROM ProductReferential__c
            WHERE SKUCode__c IN :BaseSkus
        ]);
        

        
        for(ProductReferential__c productR: newPRs) {
            ProductCategories.add(productR.ProductCategory__c);
        }
        
        List<MIY_Workshop__c>  miyWorkshop = [
            SELECT Id, Production_Time_In_Days__c, Creation_Type__c, Exotic__c, Product_Category__c, Workshop__c, Order_Type__c
            FROM MIY_Workshop__c 
            WHERE Creation_Type__c IN :CreationType  
            AND Order_Type__c IN :OrderType 
            AND Product_Category__c IN :ProductCategories 
            AND Workshop__c IN :Workshops 
            AND Source__c = 'SPO'
        ];
        
        for(Opportunity opp: opps) {
            if(opp.ApplicationSource__c == 'SPO') {
                for (MIY_Workshop__c workshop: miyWorkshop) {
                    for (ProductReferential__c productR :newPRs) {
                        
                        if (productR.SKUCode__c == opp.SPO_BaseSku__c
                            && productR.ProductCategory__c == workshop.Product_Category__c
                            && opp.SPO_Exo__c == workshop.Exotic__c
                            && opp.SPO_OrderType__c == workshop.Order_Type__c
                            && opp.SPO_CreationType__c == workshop.Creation_Type__c
                            && opp.workshop__c == workshop.Workshop__c) {
                                
                                Decimal days = workshop.Production_Time_In_Days__c;
                                if (days == null) {days = 0;}
                                if(opp.SPO_EstimatedProductionTimeMonths__c == 0 || opp.SPO_EstimatedProductionTimeMonths__c == null ) {
                                    opp.SPO_EstimatedProductionTimeMonths__c = days.divide(7, 0, System.RoundingMode.UP);
                                }
                            }
                    }
                }
            }
        
        }
    }
    }
    //update the TECH_ChinaVisibility on Opportunity according to the related Account - Data China Isolation
    public static void updateOppAccFlag(List<Opportunity> newOppList){
        Map<Id, String> mapAcc = getRelatedAccount(newOppList); 
        for(Opportunity opp : newOppList){
            if(String.isNotBlank(mapAcc.get(opp.accountId)) ){
                opp.TECH_ChinaVisibility__c = mapAcc.get(opp.accountId);
            } 
        }
        
    }
    private static Map<id, String> getRelatedAccount(List<Opportunity> newOppList){
        Map<Id, String> mapAcc = new Map<Id, String>();
        Set<Id> accId = new Set<Id>();
        // get Account Id
        if(newOppList.size()>0){
            for(Opportunity opp : newOppList){
                if(String.isNotBlank(opp.AccountId)) {
                    accId.add(opp.AccountId);
                }  
            }
        } 
        if(accId.size()>0){
            for(Account acc : [SELECT Id, TECH_ChinaVisibility__c  FROM Account WHERE Id IN : accId]){
                mapAcc.put(acc.id , acc.TECH_ChinaVisibility__c);
            }
        }
        return mapAcc;
    }
}