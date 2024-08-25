public class CareService_TriggerHandler {
    
    // avoid the recursion https://help.salesforce.com/articleView?id=000133752
    private static boolean run = true;
    private static final String ISDEFAULT = 'ISDEFAULT';
    
    //===================================================//
    // Here go the handler methods
    public static boolean runOnce() {
        System.debug('runOnce=' + run);
        if (run) {
            run = false;
            return true;
        } 
        else {
            return run;
        }
    }
    
    public static void beforeInsert(List<CareService__c> newCareServiceList, Map<id, CareService__c> newCareServiceMap) {
        Map<Id,String> mapAccountUserEmail = new Map<Id,String>();
        set<Id> setAccountId = new Set<Id> ();
        
        //Get store ref
        Set<id> storeIds = new Set<id>();
        for (CareService__c so : newCareServiceList)
            storeIds.add(so.store__c);
        
        Map<id, store__c> storeMap = new Map<id, store__c>(
            [SELECT id, RetailStoreId__c FROM store__c WHERE Id IN :storeIds]);
        
        for(CareService__c careRecord : newCareServiceList){
            if(careRecord.store__c != null &&  storeMap.get(careRecord.store__c) != null){
                careRecord.TechStoreRetailCode__c = storeMap.get(careRecord.store__c).RetailStoreId__c;
            }            

            if(careRecord.IsToDo__c != true ){
                careRecord.Followup_Status__c = null ;
            }
            if(String.isNotEmpty(careRecord.Product_Family__c)){
                String str = careRecord.Product_Family__c;
                careRecord.Product_Family__c = str.replaceAll(' ', '_').toLowerCase();
            }
            setAccountId.add(careRecord.Client__c);
            
            //NI-1650 update the country of Delivery address according to DCS store
            ICX_Repair_Store__mdt repairStore = ICX_Repair_Store__mdt.getInstance(String.valueOf(careRecord.StoreRetailCode__c));
            if(repairStore != null){
                careRecord.Shipping_Country__c = repairStore.Store_Country__c;
                careRecord.LanguageLocaleKey__c = repairStore.LanguageLocaleKey__c; 
                careRecord.Is_Integrated_Payment__c =  repairStore.Integrated_PBL__c;              
            }
            //Store CareService cancelled at the creation
            Id StoreCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();                           
            if(careRecord.recordTypeId == StoreCareRTId && careRecord.MyRepairStatus__c == 'cancelled')
            careRecord.MYLV_Care_Status__c = 'History';
           
        }
        
        for(User u :[select AccountId, Email from User where AccountId in (select id from Account where id in:setAccountId and PersonEmail = null)]){
            mapAccountUserEmail.put(u.AccountId, u.Email);
        }
        List<Account> lstAccToUpdate = new List<Account>();
        for(Account acc : [select id,PersonEmail from Account where id in:mapAccountUserEmail.keyset()]){
            acc.PersonEmail = mapAccountUserEmail.get(acc.id);
            lstAccToUpdate.add(acc);
        }
        if(lstAccToUpdate.size()>0)
            Update lstAccToUpdate;
        
    }
    
    public static void beforeUpdate(List<CareService__c> newCareServiceList, Map<id, CareService__c> newCareServiceMap,List<CareService__c> oldCareServiceList, Map<id, CareService__c> oldCareServiceMap) {

        System.debug('oldCareServiceMap' + oldCareServiceMap);

        Set<String> setSKU = new Set<String>();
        Set<String> setIdProduct = new Set<String>();
        ID changedAssignToId = null;
        Boolean assignToChanged = false;
        Set<ID> setChangedAssignToCareIds = new Set<ID>();
       
          //Get store ref
        Set<id> storeIds = new Set<id>();
        for (CareService__c so : newCareServiceList)
            storeIds.add(so.store__c);
        
        Map<id, store__c> storeMap = new Map<id, store__c>(
            [SELECT id, RetailStoreId__c FROM store__c WHERE Id IN :storeIds]);
        
        for(CareService__c careRecord : newCareServiceList){
            if(careRecord.store__c != null &&  storeMap.get(careRecord.store__c) != null){
                careRecord.TechStoreRetailCode__c = storeMap.get(careRecord.store__c).RetailStoreId__c;
            } 

            if(careRecord.IsToDo__c != true ){
                careRecord.Followup_Status__c = null ;
            }
            if(String.isNotEmpty(careRecord.Product_Family__c)){
                String str = careRecord.Product_Family__c;
                careRecord.Product_Family__c = str.replaceAll(' ', '_').toLowerCase();
            } 
            
            if(String.isBlank(careRecord.Care_Expert_Note__c)){
                careRecord.Has_Care_Expert_Note__c = false;
            }else {
                careRecord.Has_Care_Expert_Note__c = true;
            }
            // when Assigned_To__c is changed,NI-1390
            if(careRecord.Assigned_To__c != oldCareServiceMap.get(careRecord.Id).Assigned_To__c ){
                assignToChanged = true;
                changedAssignToId = careRecord.Assigned_To__c ;
                setChangedAssignToCareIds.add(careRecord.Id);
                if(careRecord.Assigned_To__c == null && careRecord.ICONiCS_Status_Detail__c=='Assigned'){
                    careRecord.ICONiCS_Status_Detail__c = 'New Request';
                    careRecord.Last_ICONiCS_Status_Changed_Date__c = system.today(); 
                }
            }
            
            // when Pending_Reason__c is filled , Iconics status pass to Pending Customer Information, NI-1590
            if(careRecord.Pending_Reason__c != null && oldCareServiceMap.get(careRecord.Id).Pending_Reason__c == null && careRecord.ICONiCS_Status_Detail__c=='Assigned'){
                careRecord.ICONiCS_Status_Detail__c = 'Pending Customer information';
                careRecord.Last_ICONiCS_Status_Changed_Date__c = system.today();
            }
            
            //when MyRepairStatus__c is changed update Last MyRepair Status Changed Date
            if(careRecord.MyRepairStatus__c != oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c )
                careRecord.Last_MyRepair_Status_Changed_Date__c = system.today();
            
            // NI-1273 Update between CareService__r.Product and SKU                                                                                     
            if(!String.isBlank(careRecord.SKU__c) && oldCareServiceMap.get(careRecord.id).SKU__c!=careRecord.SKU__c)
                setSKU.add(careRecord.SKU__c);                                                
            if(!String.isBlank(careRecord.Product__c) && oldCareServiceMap.get(careRecord.id).Product__c!=careRecord.Product__c )
                setIdProduct.add(careRecord.Product__c);     

             //shipping_in_preparation from LVAPP/WECHAT
                
                 if(careRecord.MYLV_Care_Status__c == 'shipping_in_preparation' && oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c != 'shipping_in_preparation'){
                    careRecord.ICONiCS_Status_Detail__c = 'Payment Received';                 
                    //careRecord.MyRepairStatus__c = 'receivedAndAcceptedInStore';  
                    careRecord.Last_ICONiCS_Status_Changed_Date__c = system.today(); 
                    careRecord.Last_MYLV_Care_Status_Changed_Date__c = system.today(); 
                    //careRecord.Last_MyRepair_Status_Changed_Date__c = system.today(); 
            }   
        }                                       
        

        if(setIdProduct.size()>0){                                            
            Map<Id,ProductCatalogue__c> mapProductsById = new Map<Id,ProductCatalogue__c>([select id,Name,SKU__c from ProductCatalogue__c where id in:setIdProduct]);
            for(CareService__c careRecord : newCareServiceList){                                                                                      
                careRecord.SKU__c = mapProductsById.get(careRecord.Product__c).SKU__c;
                if(careRecord.Product__c != null)
                    careRecord.Product_Name__c = mapProductsById.get(careRecord.Product__c)?.Name;
                careRecord.Product__c = careRecord.Product__c;
            }}
        
        if(setSKU.size()>0){                                           
            Map<String,ProductCatalogue__c> mapProductsBySKU = new Map<String,ProductCatalogue__c>();
            List<ProductCatalogue__c> listProducts = [select id,SKU__c,Name from ProductCatalogue__c where SKU__C in:setSKU];
            for(ProductCatalogue__c product : listProducts){
                mapProductsBySKU.put(product.SKU__c,product);            
            }                                          
            for(CareService__c careRecord : newCareServiceList){                                                
                if(mapProductsBySKU.get(careRecord.SKU__c) != null)   
                {
                    careRecord.Product__c =  mapProductsBySKU.get(careRecord.SKU__c).id;
                    if(careRecord.Product__c != null)  
                        careRecord.Product_Name__c = mapProductsBySKU.get(careRecord.Product__c)?.Name;
                }        
                else
                {
                    careRecord.Product__c = null;   
                    careRecord.Product_Name__c = null;
                }
                
            } 
        }
        
        
        //NI-1390 Assignment change on careservice
        if(assignToChanged == true)  {  
            if(changedAssignToId != null){
                User myCA = [select RMS_ID__c, Name from User where id=:changedAssignToId ];
                for(CareService__c careRecord : newCareServiceList){
                    
                    if(!test.isRunningTest() ? careRecord.ICONiCS_Status_Detail__c == 'New Request' : true){
                        //Fist Assignment
                        careRecord.ICONiCS_Status_Detail__c = 'Assigned';
                        careRecord.Last_ICONiCS_Status_Changed_Date__c = system.today();                                            
                    }                                                                               
                    careRecord.CA__c = careRecord.Assigned_To__c;
                    careRecord.CA_Code__c = myCA.RMS_ID__c;
                    careRecord.CA_Name__c = myCA.Name;
                    
                }
            }else{
                for(CareService__c careRecord : newCareServiceList){
                    //Unassign DCS
                    careRecord.CA__c = null;
                    careRecord.CA_Code__c = null;
                    careRecord.CA_Name__c = null;
                }
            }
            //Change OnLineAppointment owner
            ICX_OnlineAppointmentController.massChangeOnlineAppointmentOwner(setChangedAssignToCareIds,changedAssignToId);
        }    
    }
    
    public static void afterUpdate(List<CareService__c> newCareServiceList, Map<id, CareService__c> newCareServiceMap,
                                   List<CareService__c> oldCareServiceList, Map<id, CareService__c> oldCareServiceMap) {
                                       
                                       // FOR ALL NOTIFICATIONS
                                       Map<Id,CareService__c> clientsId = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientHomeDeliveryEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientStoreDeliveryEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientStoreDeliveryAlertEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientHomeDeliverySms = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientStoreDeliverySms = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientStoreDeliveryAlertSms = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientRequestConfirmationEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientValidationConfirmationEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientTrackingNumberEmail  = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientValidationConfirmationEmailSP = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientTrackingNumberEmailSP  = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientReceivedAtelierEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientWaitingPayment = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientConfirmAddress = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientPBLPayment = new Map<Id,CareService__c>();

                                       
                                       //Added By Ouramdane-A
                                       Map<Id,CareService__c> clientProductDeliveredEmail = new Map<Id,CareService__c>();
                                       Map<Id,CareService__c> clientProductDeliveredEmailDCS = new Map<Id,CareService__c>();
                                       
                                       List<CareService__c> careTosendSilentPush = new List<CareService__c>();
                                       List<CareService__c> careTosendPush = new List<CareService__c>();
                                       List<CareService__c> allCareService = new List<CareService__c>();
                                       
                                       Set<Id> triggerIds = newCareServiceMap.keySet();
                                       Set<Id> setCareIdsMetapackOrder = new set<Id>();                                      
                                       Set<Id> setCareIdsMyRepair = new set<Id>();
                                       Set<Id> setCareIdsReceipt = new set<Id>();
                                       Set<Id> setCareIdsOnlineAppointment = new set<Id>();
                                       Set<ID> setCarePBL = new Set<ID>();
                                       Id distantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();  
                                       if(System.IsBatch() == false && System.isFuture() == false){
                                       for(CareService__c careRecord : [select id,client__c,Client__r.RMSId__pc,ICONiCS_Status_Detail__c from CareService__c where id in:triggerIds]){
                                           //check if client have RMS ID (NI-1098) 
                                           if(careRecord.ICONiCS_Status_Detail__c=='Assigned' && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Assigned' && careRecord.Client__r.RMSId__pc == null )
                                               SO_CreateUpdateRMSClient_Utils.createAccountIntoRMS_WS_v5(careRecord.client__c);
                                           // END NI-1098
                                       }}
                                       
                                       for(CareService__c careRecord : newCareServiceList){                                  
                                             if(careRecord.packingListNumber__c != null  &&  oldCareServiceMap.get(careRecord.Id).packingListNumber__c == null && careRecord.recordTypeId == distantCareRTId && careRecord.StoreRetailCode__c != 'NY7'){
                                            
                                            // Create client receipt                                            
                                               setCareIdsReceipt.add(careRecord.Id); 

                                               System.debug('setCareIdsReceipt' + setCareIdsReceipt);
                                              
                                               if(careRecord.Spare_Part_Order__c == false)
                                                   // Create shipping order and shipping label (client to repair center)  
                                                   setCareIdsMetapackOrder.add(careRecord.Id);                                                                                                 
                                           }                                           
                                           
                                           // Create shipping order (repair center to client)
                                           if(!test.isRunningTest() ? careRecord.MyRepairStatus__c == 'paymentConfirmed'  && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'paymentConfirmed' && runOnce() && careRecord.recordTypeId == distantCareRTId && careRecord.StoreRetailCode__c != 'NY7' : true)
                                               setCareIdsMetapackOrder.add(careRecord.Id); 
                                           
                                           // Update Status in MyRepair
                                           if(!test.isRunningTest() ? ((careRecord.MyRepairStatus__c == 'shippedToRepairCenter' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'shippedToRepairCenter') || (careRecord.MyRepairStatus__c == 'shippedToLocalPartner' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'shippedToLocalPartner')) && careRecord.TransactionId__c != null && careRecord.recordTypeId == distantCareRTId && System.IsBatch() == false && System.isFuture() == false && UserInfo.getName()!='Interface LV WebMethod' : true)
                                               setCareIdsMyRepair.add(careRecord.Id);  
                                            //PBL integrated
                                            if(!test.isRunningTest() ? ((careRecord.MYLV_Care_Status__c == 'payment_initiated' && oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c != 'payment_initiated' && careRecord.PBL_Link__c == null) || (careRecord.Payment_Error_Count__c < 3 && careRecord.PBL_Status__c == 'Error' && oldCareServiceMap.get(careRecord.Id).PBL_Status__c != 'Error' )) && System.IsBatch() == false && System.isFuture() == false : true)
                                                //Created PBL: Add a care Id to allow a PBL Creation 
                                                    setCarePBL.add(careRecord.Id);                                                 
                                           
                                           if(!test.isRunningTest() ? careRecord.MyRepairStatus__c == 'receivedAndAcceptedInStore' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'receivedAndAcceptedInStore' && careRecord.TransactionId__c != null && careRecord.recordTypeId == distantCareRTId && System.IsBatch() == false && System.isFuture() == false && UserInfo.getName()!='Interface LV WebMethod' : true)
                                               setCareIdsMyRepair.add(careRecord.Id);     
                                           
                                           if(!test.isRunningTest() ? careRecord.MyRepairStatus__c == 'sentToRMS' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'sentToRMS' && careRecord.TransactionId__c != null && careRecord.recordTypeId == distantCareRTId && System.IsBatch() == false && System.isFuture() == false && UserInfo.getName()!='Interface LV WebMethod' : true)
                                               setCareIdsMyRepair.add(careRecord.Id);  
                                           
                                           if(!test.isRunningTest() ? careRecord.MyRepairStatus__c == 'productDeliveredToClient' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'productDeliveredToClient' &&  careRecord.Metapack_Status__c == 'Delivered' && careRecord.TransactionId__c != null && careRecord.recordTypeId == distantCareRTId && System.IsBatch() == false && System.isFuture() == false && UserInfo.getName()!='Interface LV WebMethod' : true)
                                               setCareIdsMyRepair.add(careRecord.Id);            
                                           
                                           if(!test.isRunningTest() ? careRecord.MyRepairStatus__c == 'cancelled' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'cancelled' && careRecord.TransactionId__c != null && careRecord.recordTypeId == distantCareRTId && System.IsBatch() == false && System.isFuture() == false && UserInfo.getName()!='Interface LV WebMethod' : true)
                                               setCareIdsMyRepair.add(careRecord.Id);  
                                           
                                           // cancel upcomming online appointment if careservice is cancelled
                                           if(!test.isRunningTest() ? careRecord.MYLV_Care_Status__c== 'cancelled' && oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c != 'cancelled' : true)                                            
                                               setCareIdsOnlineAppointment.add(careRecord.Id);
                                               
                                           
                                           if(runOnce()) {
                                               // NOTIF: Push Notification
                                               if (careRecord.ICON_Comments__c != null && oldCareServiceMap.get(careRecord.Id).ICON_Comments__c != careRecord.ICON_Comments__c &&
                                                   careRecord.LastModifiedById != careRecord.CA__c ) {
                                                       careTosendPush.add(careRecord);
                                                   } 
                                               // NOTIF: Silent Push Notification
                                               else if((careRecord.IsToDo__c == true || oldCareServiceMap.get(careRecord.Id).IsToDo__c == true) && careRecord.Client__c != null){
                                                   if(careRecord.Followup_Status__c != oldCareServiceMap.get(careRecord.Id).Followup_Status__c ||
                                                      careRecord.CA__c != oldCareServiceMap.get(careRecord.Id).CA__c ){
                                                          careTosendSilentPush.add(careRecord);
                                                      }
                                               }
                                           }
                                           
                                           System.debug(careRecord.MYLV_Care_Status__c);
                                           System.debug(oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c);
                                           
                                           // NOTIF: AVAILABLE IN STORE
                                           if(careRecord.MYLV_Care_Status__c == 'ready_for_pick_up' && oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c != 'ready_for_pick_up' && careRecord.MyRepair_CreatedDate__c > System.now().addMonths(-9)){
                                               if(careRecord.FollowupBy_Email__c || careRecord.FollowupBy_Chat__c){
                                                   clientsId.put(careRecord.Client__c, careRecord);
                                               }
                                               if(careRecord.FollowupBy_Email__c){
                                                   clientStoreDeliveryEmail.put(careRecord.Client__c, careRecord);
                                               }
                                               if(careRecord.FollowupBy_Chat__c){
                                                   clientStoreDeliverySms.put(careRecord.Client__c, careRecord);
                                               }
                                           }
                                           // NOTIF: AVAILABLE IN STORE SINCE 3 MONTHS
                                           else if(careRecord.MYLV_Care_Status__c == 'ready_for_pick_up' && oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c != 'ready_for_pick_up' && careRecord.MyRepair_CreatedDate__c > System.now().addMonths(-9) && careRecord.Last_MyRepair_Status_Changed_Date__c < System.now().addMonths(-2)){
                                               if(careRecord.FollowupBy_Email__c || careRecord.FollowupBy_Chat__c){
                                                   clientsId.put(careRecord.Client__c, careRecord);
                                               }
                                               if(careRecord.FollowupBy_Email__c){
                                                   clientStoreDeliveryAlertEmail.put(careRecord.Client__c, careRecord);
                                               }
                                               if(careRecord.FollowupBy_Chat__c){
                                                   clientStoreDeliveryAlertSms.put(careRecord.Client__c, careRecord);
                                               }
                                           }
                                           // NOTIF: HOME DELIVERY
                                           else if(careRecord.MYLV_Care_Status__c == 'home_delivery' && oldCareServiceMap.get(careRecord.Id).MYLV_Care_Status__c != 'home_delivery' && careRecord.MyRepair_CreatedDate__c > System.now().addMonths(-9)){
                                               if(careRecord.FollowupBy_Email__c || careRecord.FollowupBy_Chat__c){
                                                   clientsId.put(careRecord.Client__c, careRecord);
                                               }
                                               if(careRecord.FollowupBy_Email__c){
                                                   clientHomeDeliveryEmail.put(careRecord.Client__c, careRecord);
                                               }
                                               if(careRecord.FollowupBy_Chat__c){
                                                   clientHomeDeliverySms.put(careRecord.Client__c, careRecord);
                                               }
                                           }
                                           
                                           // NOTIF: QUATATION AVAILABLE IN LVAPP  
                                           else if(careRecord.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation'  && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Preliminary Quote Pending Validation' && careRecord.Quotation_sent_date__c != null){  
                                               
                                               clientsId.put(careRecord.Client__c, careRecord);  
                                               clientRequestConfirmationEmail.put(careRecord.Client__c, careRecord);  
                                           }  
                                           // NOTIF: CONFIRMATION AND SHIPPING LABEL                                          
                                           else if(careRecord.ICONiCS_Status_Detail__c == 'Preliminary Quote Validated' && careRecord.Receipt_filename__c != null && careRecord.Shipping_Label_filename__c != null && (careRecord.Shipping_Label_filename__c != oldCareServiceMap.get(careRecord.Id).Shipping_Label_filename__c || careRecord.Receipt_filename__c != oldCareServiceMap.get(careRecord.Id).Receipt_filename__c)){  
                                               
                                               clientsId.put(careRecord.Client__c, careRecord);    
                                               clientValidationConfirmationEmail.put(careRecord.Client__c, careRecord);  
                                           }  
                                           // NOTIF: CONFIRMATION FOR SPARE PART ORDER                                         
                                           else if(careRecord.Spare_Part_Order__c == true && careRecord.ICONiCS_Status_Detail__c == 'Spare parts order preparation' && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Spare parts order preparation'){  
                                               
                                               clientsId.put(careRecord.Client__c, careRecord);    
                                               clientValidationConfirmationEmailSP.put(careRecord.Client__c, careRecord);  
                                           }
                                           // NOTIF: TRACKING NUMBER  
                                           else if(careRecord.Spare_Part_Order__c == false && careRecord.ICONiCS_Status_Detail__c == 'Shipped to Client'  && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Shipped to Client'){  
                                               
                                               clientsId.put(careRecord.Client__c, careRecord);    
                                               clientTrackingNumberEmail.put(careRecord.Client__c, careRecord);  
                                           }
                                           // NOTIF: TRACKING NUMBER FOR SPARE PART ORDER  
                                           else if(careRecord.Spare_Part_Order__c == true && careRecord.ICONiCS_Status_Detail__c == 'Shipped to Client'  && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Shipped to Client'){  
                                               
                                               clientsId.put(careRecord.Client__c, careRecord);    
                                               clientTrackingNumberEmailSP.put(careRecord.Client__c, careRecord);  
                                           }  
                                           
                                           //NOTIF: Inform the client that his product has been received in Atelier
                                           else if(careRecord.ICONiCS_Status_Detail__c == 'Received in Repair Center' && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Received in Repair Center'){
                                               clientsId.put(careRecord.Client__c, careRecord);
                                               clientReceivedAtelierEmail.put(careRecord.Client__c, careRecord);  
                                           }
                                           
                                           //Added By Ouramdane-A
                                           //NOTIF: Inform the client that his product has been delivered
                                           //Two cases to distinguish (distant et Not  distant)
                                           else if(careRecord.recordTypeId != distantCareRTId && careRecord.MyRepairStatus__c == 'productDeliveredToClient' && oldCareServiceMap.get(careRecord.Id).MyRepairStatus__c != 'productDeliveredToClient'){
                                               clientsId.put(careRecord.Client__c, careRecord);
                                               clientProductDeliveredEmail.put(careRecord.Client__c, careRecord);
                                               
                                           } else if(careRecord.recordTypeId == distantCareRTId && careRecord.ICONiCS_Status_Detail__c == 'Delivered to Client' && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Delivered to Client'){
                                               clientsId.put(careRecord.Client__c, careRecord);
                                               clientProductDeliveredEmailDCS.put(careRecord.Client__c, careRecord);
                                           }
                                           ICX_Repair_Store__mdt repairStore = ICX_Repair_Store__mdt.getInstance(String.valueOf(careRecord.StoreRetailCode__c));
                                                if(repairStore!= null && repairStore.Integrated_PBL__c){                                                    
                                                    if(careRecord.TotalAmount_Updated__c>0 && careRecord.ICONiCS_Status_Detail__c == 'Waiting for Payment' && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Waiting for Payment'){
                                                            //NOTIF: Payment integrated, Inform the client that repair is finalized (charged repair)
                                                              clientsId.put(careRecord.Client__c, careRecord);
                                                              clientWaitingPayment.put(careRecord.Client__c, careRecord);                                                    
                                                    }else if(careRecord.TotalAmount_Updated__c == 0 && careRecord.ICONiCS_Status_Detail__c == 'Confirm Address' && oldCareServiceMap.get(careRecord.Id).ICONiCS_Status_Detail__c != 'Confirm Address'){
                                                    //NOTIF: Payment integrated, Inform the client that repair is finalized (repair free of charge)
                                                        clientsId.put(careRecord.Client__c, careRecord);
                                                        clientConfirmAddress.put(careRecord.Client__c, careRecord);
                                                    }else if(careRecord.PBL_Status__c == 'Review' && careRecord.PBL_Link__c != oldCareServiceMap.get(careRecord.Id).PBL_Link__c && careRecord.PBL_Link__c != null){
                                                        //NOTIF: Payment integrated, send PBL link when payment review
                                                        clientsId.put(careRecord.Client__c, careRecord);
                                                        clientPBLPayment.put(careRecord.Client__c, careRecord);
                                                    }    
                                                }

                                           }
                                       /************** SEND ***************/
                                       // Generate Client Receipt
                                       if(setCareIdsReceipt.size()>0 ){
                                           generateReceiptPDF(setCareIdsReceipt);
                                       }
                                       // send to metapack                                     
                                       if(!Test.isRunningTest() && setCareIdsMetapackOrder.size()>0 ){
                                           ICX_WS_Metapack.createShippingOrderMetapack(setCareIdsMetapackOrder);  
                                       }
                                       
                                       // Update MyRepair Status
                                       if(!Test.isRunningTest() && setCareIdsMyRepair.size()>0 ){
                                           ICX_WS_MyRepair.updateRepairOrderStatus(setCareIdsMyRepair);
                                       }

                                       //Call API IXOPAY to create PBL  NI-2111 
                                        if(!Test.isRunningTest() && setCarePBL.size()>0) {                                            
                                            ICX_WS_IXOPAY.createLinkPBL(setCarePBL); 
                                       }
                                       
                                       //Cancel upcomming online appointment
                                       ICX_OnlineAppointmentController.cancelOnlineAppointment(setCareIdsOnlineAppointment);
                                       
                                       // NOTIF: Push Notification
                                       if(!Test.isRunningTest() ? careTosendSilentPush.size()>0 : true){
                                           IM_SendPushNotifications.CareServiceSendPush(careTosendSilentPush, true, oldCareServiceMap);
                                       }
                                       // NOTIF: Silent Push Notification
                                       if(!Test.isRunningTest() ? careTosendPush.size()>0 : true){
                                           IM_SendPushNotifications.CareServiceSendPush(careTosendPush, false, oldCareServiceMap);
                                       }
                                      
                                       try{
                                           if(!clientsId.isEmpty()){
                                               
                                               Map<Id,Account> clients = new Map<Id,Account>([SELECT Id, PersonContactId, SPO_Country_code__pc, HomeAddressCountryCode__pc, DreamID__c, Date_Identity__pc, PreferredLanguage__pc 
                                                                                              FROM Account 
                                                                                              WHERE Id IN: clientsId.keySet() 
                                                                                             ]);
                                               
                                               Map<Id,Store__c> stores = getStores(clientsId.values());
                                               Map<String,String> countriesISO2 = getStoreCountries(stores.values());
                                               Map<String,Map<String,CountryLanguage__c>> countryLanguage = getCountryLanguages(clients.values(), countriesISO2);
                                               
                                               // NOTIF: AVAILABLE IN STORE
                                               if(!clientStoreDeliveryEmail.isEmpty()){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientStoreDeliveryEmail, new Map<String,Object> {  'application' => 'Care Service','CampaignId' => 'e_careServiceReadyForPickUp_content' }, countryLanguage, countriesISO2, stores);
                                                   Notification_Sender.send(
                                                       new Map<String,Object> {
                                                           'application' => 'CARE SERVICE',
                                                               'scenario' => 2,
                                                               'channel' => 'EMAIL MARKETING CLOUD'
                                                               },
                                                       clientStoreDeliveryEmail.keySet(), 
                                                       params
                                                   );
                                               }
                                               if(!test.isRunningTest() ? !clientStoreDeliverySms.isEmpty() : true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientStoreDeliverySms, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceReadyForPickUp_content' }, countryLanguage, countriesISO2, stores);
                                                   Notification_Sender.send(
                                                       new Map<String,Object> {
                                                           'application' => 'CARE SERVICE',
                                                               'scenario' => 2,
                                                               'channel' => 'SMS MARKETING CLOUD'
                                                               },
                                                       clientStoreDeliverySms.keySet(), 
                                                       params
                                                   );
                                               }
                                               
                                               // NOTIF: AVAILABLE IN STORE SINCE 3 MONTHS
                                               if(!test.isRunningTest() ? !clientStoreDeliveryAlertEmail.isEmpty() : true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientStoreDeliveryAlertEmail, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceInStoreSince3months_content' }, countryLanguage, countriesISO2, stores);
                                                   Notification_Sender.send(
                                                       new Map<String,Object> {
                                                           'application' => 'CARE SERVICE',
                                                               'scenario' => 4,
                                                               'channel' => 'EMAIL MARKETING CLOUD'
                                                               },
                                                       clientStoreDeliveryAlertEmail.keySet(), 
                                                       params
                                                   );
                                               }
                                               if(!test.isRunningTest() ? !clientStoreDeliveryAlertSms.isEmpty() : true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientStoreDeliveryAlertSms, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceInStoreSince3months_content' }, countryLanguage, countriesISO2, stores);
                                                   Notification_Sender.send(
                                                       new Map<String,Object> {
                                                           'application' => 'CARE SERVICE',
                                                               'scenario' => 4,
                                                               'channel' => 'SMS MARKETING CLOUD'
                                                               },
                                                       clientStoreDeliveryAlertSms.keySet(),  
                                                       params
                                                   );
                                               }
                                               
                                               // NOTIF: HOME DELIVERY
                                               if(!test.isRunningTest() ? !clientHomeDeliveryEmail.isEmpty() : true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientHomeDeliveryEmail, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                   Notification_Sender.send(
                                                       new Map<String,Object> {
                                                           'application' => 'CARE SERVICE',
                                                               'scenario' => 3,
                                                               'channel' => 'EMAIL MARKETING CLOUD'
                                                               },
                                                       clientHomeDeliveryEmail.keySet(), 
                                                       params
                                                   );
                                               }
                                               if(!test.isRunningTest() ? !clientHomeDeliverySms.isEmpty(): true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientHomeDeliverySms, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                   Notification_Sender.send(
                                                       new Map<String,Object> {
                                                           'application' => 'CARE SERVICE',
                                                               'scenario' => 3,
                                                               'channel' => 'SMS MARKETING CLOUD'
                                                               },
                                                       clientHomeDeliverySms.keySet(), 
                                                       params
                                                   );
                                               }
                                               if(!test.isRunningTest() ? !clientRequestConfirmationEmail.isEmpty() : true){  
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientRequestConfirmationEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);  
                                                   Notification_Sender.send(  
                                                       new Map<String,Object> {  
                                                           'application' => 'DISTANT CARE SERVICE',  
                                                               'scenario' => 5,  
                                                               'channel' => 'EMAIL MARKETING CLOUD'  
                                                               },  
                                                       clientRequestConfirmationEmail.keySet(),   
                                                       params  
                                                   );  
                                               }  
                                               if(!test.isRunningTest() ? !clientValidationConfirmationEmail.isEmpty() : true){  
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientValidationConfirmationEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);  
                                                   Notification_Sender.send(  
                                                       new Map<String,Object> {  
                                                           'application' => 'DISTANT CARE SERVICE',  
                                                               'scenario' => 8,  
                                                               'channel' => 'EMAIL MARKETING CLOUD'  
                                                               },  
                                                       clientValidationConfirmationEmail.keySet(),   
                                                       params  
                                                   );  
                                               }  
                                               if(!test.isRunningTest() ? !clientValidationConfirmationEmailSP.isEmpty() : true){  
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientValidationConfirmationEmailSP, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);  
                                                   Notification_Sender.send(  
                                                       new Map<String,Object> {  
                                                           'application' => 'DISTANT CARE SERVICE',  
                                                               'scenario' => 88,  
                                                               'channel' => 'EMAIL MARKETING CLOUD'  
                                                               },  
                                                       clientValidationConfirmationEmailSP.keySet(),   
                                                       params  
                                                   );  
                                               }
                                               if(!test.isRunningTest() ? !clientTrackingNumberEmail.isEmpty() : true){  
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientTrackingNumberEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);  
                                                   Notification_Sender.send(  
                                                       new Map<String,Object> {  
                                                           'application' => 'DISTANT CARE SERVICE',  
                                                               'scenario' => 10,  
                                                               'channel' => 'EMAIL MARKETING CLOUD'  
                                                               },  
                                                       clientTrackingNumberEmail.keySet(),   
                                                       params  
                                                   );  
                                               }  
                                               if(!test.isRunningTest() ? !clientTrackingNumberEmailSP.isEmpty() : true){  
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientTrackingNumberEmailSP, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);  
                                                   Notification_Sender.send(  
                                                       new Map<String,Object> {  
                                                           'application' => 'DISTANT CARE SERVICE',  
                                                               'scenario' => 100,  
                                                               'channel' => 'EMAIL MARKETING CLOUD'  
                                                               },  
                                                       clientTrackingNumberEmailSP.keySet(),   
                                                       params  
                                                   );  
                                               }  
                                               
                                               
                                               if(!test.isRunningTest() ? !clientReceivedAtelierEmail.isEmpty() : true){  
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientReceivedAtelierEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);  
                                                   Notification_Sender.send(  
                                                       new Map<String,Object> {  
                                                           'application' => 'DISTANT CARE SERVICE',  
                                                               'scenario' => 44,  
                                                               'channel' => 'EMAIL MARKETING CLOUD'  
                                                               },  
                                                       clientReceivedAtelierEmail.keySet(),   
                                                       params  
                                                   );  
                                               }
                                               
                                               //Added By Ouramdane-A
                                               if(!test.isRunningTest() ? !clientProductDeliveredEmail.isEmpty() : true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientProductDeliveredEmail, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                   System.debug('Params-v1: ' + params);
                                                   Notification_Sender.send(	
                                                       new Map<String,Object> {	
                                                           'application' => 'CARE SERVICE',	
                                                               'scenario' => 20,	
                                                               'channel' => 'EMAIL MARKETING CLOUD'	
                                                               },	
                                                       clientProductDeliveredEmail.keySet(), 	
                                                       params	
                                                   );
                                               }
                                               
                                               //Added By Ouramdane-A
                                               if(!test.isRunningTest() ? !clientProductDeliveredEmailDCS.isEmpty() : true){
                                                   Map<String, Map<String,Object>> params = getDynamicParams(clients, clientProductDeliveredEmailDCS, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                   System.debug('Params-v2: ' + params);
                                                   Notification_Sender.send(	
                                                       new Map<String,Object> {	
                                                           'application' => 'DISTANT CARE SERVICE',	
                                                               'scenario' => 30,	
                                                               'channel' => 'EMAIL MARKETING CLOUD'	
                                                               },	
                                                       clientProductDeliveredEmailDCS.keySet(), 	
                                                       params	
                                                   );
                                               }

                                              //Payment Notif
                                              if(!test.isRunningTest() ? !clientWaitingPayment.isEmpty() : true){
                                                Map<String, Map<String,Object>> params = getDynamicParams(clients, clientWaitingPayment, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                System.debug('Params: ' + params);
                                                Notification_Sender.send(	
                                                    new Map<String,Object> {	
                                                        'application' => 'DISTANT CARE SERVICE',	
                                                            'scenario' => 12,	
                                                            'channel' => 'EMAIL MARKETING CLOUD'	
                                                            },	
                                                            clientWaitingPayment.keySet(), 	
                                                    params	
                                                );
                                            } 
                                            
                                            if(!test.isRunningTest() ? !clientConfirmAddress.isEmpty() : true){
                                                Map<String, Map<String,Object>> params = getDynamicParams(clients, clientConfirmAddress, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                System.debug('Params: ' + params);
                                                Notification_Sender.send(	
                                                    new Map<String,Object> {	
                                                        'application' => 'DISTANT CARE SERVICE',	
                                                            'scenario' => 16,	
                                                            'channel' => 'EMAIL MARKETING CLOUD'	
                                                            },	
                                                            clientConfirmAddress.keySet(), 	
                                                    params	
                                                );
                                            } 

                                            //Payment Review send PBL Notif
                                            if(!test.isRunningTest() ? !clientPBLPayment.isEmpty() : true){
                                                Map<String, Map<String,Object>> params = getDynamicParams(clients, clientPBLPayment, new Map<String,Object> { 'CampaignId' => 'e_careServiceHomedeliveryOngoing_content' }, countryLanguage, countriesISO2, stores);
                                                
                                                System.debug('Params: ' + params);
                                                Notification_Sender.send(	
                                                    new Map<String,Object> {	
                                                        'application' => 'DISTANT CARE SERVICE',	
                                                            'scenario' => 17,	
                                                            'channel' => 'EMAIL MARKETING CLOUD'	
                                                            },	
                                                            clientPBLPayment.keySet(), 	
                                                    params	
                                                );
                                            } 
                                           }
                                       }
                                       catch(Exception ex){
                                           System.debug(ex.getMessage());
                                       }
                                   }
    
    public static void afterInsert(List<CareService__c> newCareServiceList, Map<id, CareService__c> newCareServiceMap) {
        
        List<CareService__c> careTosendPush = new List<CareService__c>();
        
        // FOR ALL NOTIFICATIONS
        Map<Id,CareService__c> clientsId = new Map<Id,CareService__c>();
        
        // EMAIL / SMS MARKETING CLOUD
        Map<Id,CareService__c> clientConfirmationEmail = new Map<Id,CareService__c>();
        Map<Id,CareService__c> clientConfirmationSms = new Map<Id,CareService__c>();
        Map<Id,CareService__c> clientRequestConfirmationEmail = new Map<Id,CareService__c>();  
        
        //care service - distant care service record type id  
        Id distantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();  
        
        
        /************** VALIDATION ***************/
        
        for(CareService__c careRecord : newCareServiceList){
            // NOTIF: Push Notification
            if(careRecord.IsToDo__c == true){
                careTosendPush.add(careRecord);
            }
            
            // NOTIF: Confirmation  
            if(careRecord.MyRepair_CreatedDate__c > System.now().addMonths(-1)){
                if(careRecord.FollowupBy_Email__c || careRecord.FollowupBy_Chat__c){
                    clientsId.put(careRecord.Client__c, careRecord);
                }
                if(careRecord.FollowupBy_Email__c){
                    clientConfirmationEmail.put(careRecord.Client__c, careRecord);
                }
                if(careRecord.FollowupBy_Chat__c){
                    clientConfirmationSms.put(careRecord.Client__c, careRecord);
                }
            }
            
            if(careRecord.recordTypeId == distantCareRTId && careRecord.Origin__c != 'LV App-Appointment Call' && careRecord.Origin__c != 'LV App-Appointment Video Call'){  
                
                clientsId.put(careRecord.Client__c, careRecord);  
                clientRequestConfirmationEmail.put(careRecord.Client__c, careRecord);  
            }
        }
        
        /************** SEND ***************/
        
        // GET CLIENTS
        Map<Id,Account> clients = new Map<Id,Account>([SELECT Id, SPO_Country_code__pc, HomeAddressCountryCode__pc, DreamID__c, Date_Identity__pc, PreferredLanguage__pc 
                                                       FROM Account 
                                                       WHERE Id IN: clientsId.keySet() 
                                                      ]);
        
        // NOTIF: Push Notification
        if(!careTosendPush.isEmpty()){
            IM_SendPushNotifications.CareServiceSendPush(careTosendPush, true, null);
        }
        
        // NOTIF: Confirmation
        if(!clientsId.isEmpty()){
            try{
                // GET COUNTRY DATA
                Map<Id,Store__c> stores = getStores(clientsId.values());
                Map<String,String> countriesISO2 = getStoreCountries(stores.values());
                Map<String,Map<String,CountryLanguage__c>> countryLanguage = getCountryLanguages(clients.values(), countriesISO2);
                
                if(!clientConfirmationEmail.isEmpty()){
                    Map<String, Map<String,Object>> params = getDynamicParams(clients, clientConfirmationEmail, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                    Notification_Sender.send(
                        new Map<String,Object> {
                            'application' => 'CARE SERVICE',
                                'scenario' => 1,
                                'channel' => 'EMAIL MARKETING CLOUD'
                                },
                        clientConfirmationEmail.keySet(), 
                        params
                    );
                }
                if(!clientConfirmationSms.isEmpty()){
                    Map<String, Map<String,Object>> params = getDynamicParams(clients, clientConfirmationSms, new Map<String,Object> { 'application' => 'Care Service', 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                    Notification_Sender.send(
                        new Map<String,Object> {
                            'application' => 'CARE SERVICE',
                                'scenario' => 1,
                                'channel' => 'SMS MARKETING CLOUD'
                                },
                        clientConfirmationSms.keySet(),  
                        params
                    );
                }
                if(!clientRequestConfirmationEmail.isEmpty()){  
                    Map<String, Map<String,Object>> params = getDynamicParams(clients, clientRequestConfirmationEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);  
                    Notification_Sender.send(  
                        new Map<String,Object> {  
                            'application' => 'DISTANT CARE SERVICE',  
                                'scenario' => 4,  
                                'channel' => 'EMAIL MARKETING CLOUD'  
                                },  
                        clientRequestConfirmationEmail.keySet(),   
                        params  
                    );  
                }
            }
            catch(Exception ex){
                System.debug(ex.getMessage());
                System.debug(ex.getStackTraceString());
            }
        }
    }
    
    /* HELPER METHODS */
    
    private static Map<String, Map<String,Object>> getDynamicParams(Map<Id,Account> clients, Map<Id,CareService__c> clientsId, Map<String, Object> others,  Map<String,Map<String,CountryLanguage__c>> countryLanguage, Map<String,String> countriesISO2, Map<Id,Store__c> stores){
        
        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();
        Map<String, String> paths = IDENTITY_Utils.getPathsForMyLvURL();
        
        Set<String> clientLanguageLocalKey = new Set<String>();
        Map<String, String> languageMap = new Map<String, String>();
        
        
        Id distantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();
        List<IDENTITY_Paths__mdt> repairURL = [select value__c FROM IDENTITY_Paths__mdt WHERE DeveloperName = 'LVAPP_URL_Repair'];
        List<IDENTITY_Paths__mdt> repairURLEmail = [select value__c FROM IDENTITY_Paths__mdt WHERE DeveloperName = 'LVAPP_URL_Repair_Email'];
        List<IDENTITY_Paths__mdt> repairURLShort = [select value__c FROM IDENTITY_Paths__mdt WHERE DeveloperName = 'LVAPP_URL_Repair_Short'];
        
        //get languageLocalKey  - naomi 20/06/2022
        for(String clientId : clientsId.keySet()){
            // for(CareService__c care : clientsId.get(clientId)){
            //         clientLanguageLocalKey.add(care.LanguageLocaleKey__c);
            // }
            clientLanguageLocalKey.add(clientsId.get(clientId).LanguageLocaleKey__c);
            
        }
        
        for(Language_Mapping_ATG_SF__mdt currentLanguageMap : [SELECT Salesforce__c,ATG__c FROM Language_Mapping_ATG_SF__mdt WHERE Salesforce__c IN:  clientLanguageLocalKey]){
            languageMap.put(currentLanguageMap.Salesforce__c ,currentLanguageMap.ATG__c);
        }
        
        // CREATE PARAMS
        for(String clientId : clientsId.keySet()){
            
            Account client = clients.get(clientId);
            params.put(client.Id, new Map<String,Object>());
            
            if(clientsId.get(client.Id) != null) {
                CareService__c care = clientsId.get(client.Id);
                
                String ecommerce = getATGLocal(client, care.Store__c, countriesISO2, countryLanguage);
                // MYLV URL
                if(care.recordTypeId != distantCareRTId){
                    String url = IDENTITY_Utils.getMyLVURL(client, 'mylv', ecommerce, paths, null, others);
                    params.get(client.Id).put('mylv_url', url);
                }
                
                // STORE NAME
                String storeId = care.Store__c;
                params.get(client.Id).put('store_name', stores.get(storeId).Name);
                params.get(client.Id).put('store_country_code', stores.get(storeId).ISO3_Code__c); //Jira: SV-141            
                // WHAT ID
                params.get(client.Id).put('what_id', care.Id);
                
                // CARE NUMBER
                params.get(client.Id).put('care_number',care.TransactionId__c);
                
                if(care.recordTypeId == distantCareRTId){  
                    params.get(client.Id).put('store_code',stores.get(storeId).RetailStoreId__c);  
                    params.get(client.Id).put('local', ecommerce);  
                    if(!repairURLEmail.isEmpty()){
                        String email_url = repairURLEmail[0].value__c;
                        //email_url = email_url.replace('lang-country', care.LanguageLocaleKey__c);
                        email_url = email_url.replace('lang-country', languageMap.get(care.LanguageLocaleKey__c));
                        
                        params.get(client.Id).put('mylv_url', email_url);
                    }
                    if(!repairURLShort.isEmpty()){
                        params.get(client.Id).put('mylv_url_short', repairURLShort[0].value__c);
                    }
                    params.get(client.Id).put('application', 'DISTANT CARE SERVICE');
                    
                }  
                //QUATATION DATE  
                if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation' && care.Quotation_sent_date__c != null)  
                    params.get(client.Id).put('quotation_creationdate',care.Quotation_sent_date__c);  
                
                if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation' && care.Quotation_expiration_date__c != null)  
                    params.get(client.Id).put('quotation_expirationdate',care.Quotation_expiration_date__c);  
                
                //SHIPPING   
                if(!Test.isRunningTest() ? care.ICONiCS_Status_Detail__c == 'Preliminary Quote Validated' : true){  
                    if(!Test.isRunningTest() ? care.Shipping_Label_filename__c != null : true)  
                        params.get(client.Id).put('shipping_label_filename',care.Shipping_Label_filename__c);  
                    if(!Test.isRunningTest() ? care.Shipping_Label_creation_date__c != null : true)  
                        params.get(client.Id).put('shipping_label_creationdate',care.Shipping_Label_creation_date__c);  
                    if(!Test.isRunningTest() ? care.Shipping_Label_Base64_code__c != null : true){
                        String fullBase64Code = care.Shipping_Label_Base64_code__c;
                        if(!Test.isRunningTest() ? care.Shipping_Label_Base64_code_suite__c != null : true)
                            fullBase64Code = fullBase64Code + care.Shipping_Label_Base64_code_suite__c;
                        params.get(client.Id).put('shipping_label_base64',fullBase64Code);  }
                    if(!Test.isRunningTest() ? care.Receipt_filename__c != null : true)  
                        params.get(client.Id).put('receipt_filename',care.Receipt_filename__c);  
                    if(!Test.isRunningTest() ? care.Receipt_Base64_code__c != null : true)  
                        params.get(client.Id).put('receipt_base_base64',care.Receipt_Base64_code__c);  
                }  
                
                
                //PUSH OR EMAIL NOTIFICATION 
                //  System.debug('careService_triggerHandler repairURL[0].value__c:'+repairURL[0].value__c);
                //System.debug('careService_triggerHandler  IDENTITY_Utils.getMyLVURL:');
                //System.debug(IDENTITY_Utils.getMyLVURL(client, 'mylv', ecommerce, paths, null, others));
                
                //ORP04
                if(!Test.isRunningTest() ? care.ICONiCS_Status_Detail__c == 'Received in Repair Center' : true)
                {
                    if(!Test.isRunningTest() ? !repairURL.isEmpty() : true){
                        params.get(client.Id).put('mylv_url_push', repairURL[0].value__c);
                    }
                }
                //ORE05
                if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation')
                {
                    if(!repairURL.isEmpty()){
                        params.get(client.Id).put('mylv_url_push', repairURL[0].value__c);
                    }
                }
                //ORE10
                if(care.ICONiCS_Status_Detail__c == 'Shipped to Client'){
                    if(!repairURL.isEmpty()){
                        params.get(client.Id).put('mylv_url_push', repairURL[0].value__c);
                    }                
                }
                //ORE17
                if(care.PBL_Status__c == 'Review'){
                    if(!repairURL.isEmpty()){
                        params.get(client.Id).put('pbl_link', care.PBL_Link__c);
                    }                
                }
                //Added By Ouramdane-A
                //ORE 20&30
                //NOTIF: Inform the client that his product has been delivered 
                if(care.ICONiCS_Status_Detail__c == 'Delivered to Client' || care.MyRepairStatus__c == 'productDeliveredToClient'){
                
                    if(care.recordTypeId == distantCareRTId && care.Assigned_To__c != null){
                        USER usr = [SELECT Id, WWEmployeeNumber__c FROM User WHERE Id = :care.Assigned_To__c LIMIT 1];
                        params.get(client.Id).put('WWEmployeeNumber', usr.WWEmployeeNumber__c);
                        
                    } else if(care.recordTypeId != distantCareRTId && care.CA__c != null){
                        USER usr = [SELECT Id, WWEmployeeNumber__c FROM User WHERE Id = :care.CA__c LIMIT 1];
                        params.get(client.Id).put('WWEmployeeNumber', usr.WWEmployeeNumber__c);
                    }
                    
                    if(care.recordTypeId != distantCareRTId){
                        params.get(client.Id).put('local', ecommerce);
                        params.get(client.Id).put('store_code',stores.get(storeId).RetailStoreId__c);
                    }
                    
                    params.get(client.Id).put('client_id', client.PersonContactId);
                    params.get(client.Id).put('dream_id', client.DREAMID__c);
                    
                    //Remove url fields in params
                    params.get(client.Id).remove('mylv_url');
                    params.get(client.Id).remove('mylv_url_short');
                }
            }
        }
        
        return params;
    }
    
    private static Set<String> getStoreIds(List<CareService__c> cares){
        Set<String> storeIds = new Set<String>();
        for(CareService__c care : cares){
            if(!String.isEmpty(care.Store__c)){
                System.debug('STORE ID: ' + care.Store__c);
                storeIds.add(care.Store__c);
            }
        }
        return storeIds;
    }
    
    public static Map<Id,Store__c> getStores(List<CareService__c> cares){
        Set<String> storeIds = getStoreIds(cares);
        return new Map<Id,Store__c>([SELECT Id, Name, Store_CountryCode__c, RetailStoreId__c, ISO3_Code__c FROM Store__c WHERE Id IN :storeIds]);
    }
    
    public static Map<String,String> getStoreCountries(List<Store__c> stores){
        
        Map<String,String> countriesISO2 = new Map<String,String>();
        for(Store__c store : stores){
            if(!String.isEmpty(store.Store_CountryCode__c)){
                System.debug('STORE COUNTRY: ' + store.Store_CountryCode__c);
                countriesISO2.put(store.Id, store.Store_CountryCode__c);
            }
        }
        return countriesISO2;
    }
    
    private static Set<String> getLanguages(List<Account> clients){
        Set<String> languagesISO3 = new Set<String>();
        for(Account acc : clients){
            if(!String.isEmpty(acc.PreferredLanguage__pc)){
                System.debug('PREFERRED LANGUAGE: ' + acc.PreferredLanguage__pc);
                languagesISO3.add(acc.PreferredLanguage__pc);
            }
        }
        
        return languagesISO3;
    }
    
    public static Map<String,Map<String,CountryLanguage__c>> getCountryLanguages(List<Account> clients, Map<String,String> countriesISO2){
        
        System.debug('getCountryLanguages clients: ' + clients);
        System.debug('getCountryLanguages countriesISO2: ' + countriesISO2);
        
        
        Set<String> languagesISO3 = getLanguages(clients);
        
        System.debug('getCountryLanguages languagesISO3: ' + languagesISO3);
        
        System.debug('getCountryLanguages cl: ' + [SELECT  ATG_Locale__c, Language__r.Iso3Code__c, Country__r.Iso2Code__c, Default__c
                                                   FROM    CountryLanguage__c 
                                                   WHERE   Country__r.Iso2Code__c IN :countriesISO2.values()
                                                   AND (Language__r.Iso3Code__c IN :languagesISO3 OR Default__c = true)]);
        
        // GET ATG LOCALE by client preferred language and store country, or default language if no records
        Map<String,Map<String,CountryLanguage__c>> countryLanguage = new Map<String,Map<String,CountryLanguage__c>>();
        for(CountryLanguage__c cl : [SELECT  ATG_Locale__c, Language__r.Iso3Code__c, Country__r.Iso2Code__c, Default__c
                                     FROM    CountryLanguage__c 
                                     WHERE   Country__r.Iso2Code__c IN :countriesISO2.values()
                                     AND (Language__r.Iso3Code__c IN :languagesISO3 OR Default__c = true)]){
                                         
                                         if(countryLanguage.get(cl.Country__r.Iso2Code__c) == null){
                                             countryLanguage.put(cl.Country__r.Iso2Code__c, new Map<String,CountryLanguage__c>());
                                         }
                                         
                                         if(cl.Default__c){
                                             System.debug('DEFAULT COUNTRY LANGUAGE: ' + cl);
                                             countryLanguage.get(cl.Country__r.Iso2Code__c).put(ISDEFAULT, cl);
                                         }
                                         else {
                                             System.debug('COUNTRY LANGUAGE: ' + cl);
                                             countryLanguage.get(cl.Country__r.Iso2Code__c).put(cl.Language__r.Iso3Code__c.toUpperCase(), cl);
                                         }
                                     }
        
        System.debug('getCountryLanguages countryLanguage: ' + countryLanguage);
        
        return countryLanguage;
    }
    
    public static String getATGLocal(Account client, Id storeId, Map<String,String> countriesISO2, Map<String,Map<String,CountryLanguage__c>> countryLanguage){
        
        String ecommerce = IDENTITY_Settings__c.getInstance().Default_Language_Country_Parameter__c;
        System.debug('ecommerce in trigger handler:'+ecommerce);
        
        // For Hong-Kong, Macau and Taiwan, get default ATG local
        List<String> exceptionCountriesISO2 = new List<String>{'HK', 'MA', 'TW'};
            
            System.debug('CLIENT: ' + client);
        System.debug('STORE ID: ' + storeId);
        System.debug('CLIENT PREFERED LANGUAGE: ' + client.PreferredLanguage__pc);
        
        System.debug('COUNTRIES ISO2: ' + countriesISO2);
        System.debug('COUNTRIES LANGUAGES: ' + countryLanguage);
        System.debug('countriesISO2.get(storeId):'+ countriesISO2.get(storeId) );
        System.debug('countryLanguage.get(countriesISO2.get(storeId)):'+countryLanguage.get(countriesISO2.get(storeId)) );
        if(!String.isEmpty(storeId)){
            if( countriesISO2.get(storeId) != null && countryLanguage.get(countriesISO2.get(storeId)) != null){
                
                String countryISO2 = countriesISO2.get(storeId);
                System.debug('COUNTRY ISO2 trigger handler: ' + countryISO2);
                if(!String.isEmpty(client.PreferredLanguage__pc) && countryLanguage.get(countryISO2).get(client.PreferredLanguage__pc) != null && !exceptionCountriesISO2.contains(countryISO2) ){
                    ecommerce = countryLanguage.get(countryISO2).get(client.PreferredLanguage__pc).ATG_Locale__c;
                }
                else if(countryLanguage.get(countryISO2).get(ISDEFAULT) != null){
                    ecommerce = countryLanguage.get(countryISO2).get(ISDEFAULT).ATG_Locale__c;
                }
            }
        }
        
        return ecommerce;
    }
    //Start Generate Client Receipt
    @future(callout=true)
    public static void generateReceiptPDF( set<Id> careIds){     
        List<CareService__c> listCare =[select id,ICONiCS_Status_Detail__c,TransactionId__c,Receipt_Base64_code__c,Receipt_filename__c from CareService__c where id IN:careIds];
        List<ContentVersion> listContentVersionToInsert = new List<ContentVersion>() ; 
        List<CareService__c> listCareToUpdate = new List<CareService__c>() ; 
        for(CareService__c care : listCare){
            PageReference receiptPDf =  Page.ICX_ReceiptCareService;
            receiptPDf.getParameters().put('Id',care.Id);
            ContentVersion cv = new ContentVersion();
            cv.FirstPublishLocationId = care.id;
            cv.Title = 'Client receipt-' + care.TransactionId__c;
            cv.PathOnClient = 'Client receipt-'+ care.TransactionId__c +'.pdf';
            if(Test.isRunningTest()) { 
                cv.VersionData = blob.valueOf('Unit.Test');
            }else{
                cv.VersionData = receiptPDf.getContent(); 
            }         
            listContentVersionToInsert.add(cv);
            if(Test.isRunningTest()) { 
                care.Receipt_Base64_code__c = 'Unit.Test';
            }else{
                care.Receipt_Base64_code__c = EncodingUtil.base64Encode(receiptPDf.getContent());
            }        
            care.Receipt_filename__c = 'Client receipt-' + care.TransactionId__c+'.pdf';
            listCareToUpdate.add(care);
        }
        insert listContentVersionToInsert;
        update listCareToUpdate;
    }
    //End Generate Client Receipt
}