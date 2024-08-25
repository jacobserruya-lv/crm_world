/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-29-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global without sharing class BL_ICON_PushNotification_Config {
    
     Static List<Push_Notification_Recipient__c> recipientToInsert = new List<Push_Notification_Recipient__c>();

    /*
        * This function create child 'Push_Notification_Item_Recipient' for all users in a Push_Notification_Item
        * 
    */
    static public void PushAtferInsertHandler(List<Push_Notification_Item__c> pushObject) {

        try {
            List<String> exceptionUseCase = new List<String>{'Other' ,'Voice', 'Wardrobing'};      
            List<Push_Notification_Item__c> pushObjects = new List<Push_Notification_Item__c>();

            for(Push_Notification_Item__c pushItem : pushObject){
                if(String.isblank(pushItem.Parent_Push__c) && pushItem.Is_Silent_Push__c == false && !exceptionUseCase.contains(pushItem.type__c)){
                    
                    pushObjects.add(pushItem);
                }
            }   
             
            createNotifications(pushObjects);

        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }
    }

    


    /*
        * This function create child 'Push_Notification_Item_Recipient' for all users in a Push_Notification_Item
        * 
    */


    public static void createNotifications(List<Push_Notification_Item__c> PushNotificationItemList) {
        
       Set<String> iosClientBehavior = new Set<String>{'FirmOrder','Order','Wardrobing'};
       List<String> exceptionUseCase = new List<String>{'Other'};      

       Map<String, Set<String>> objectIdByType =  new Map<String, Set<String>>() ;
       List<PushNotification> pushNotifications = new List<PushNotification> () ; 
       List<Map<String, Object>> objectList = new  List<Map<String, Object>>();
       Map<String, Map<String, Object>> mapObjectById = new Map<String, Map<String, Object>> (); 

       try {
           
            for(Push_Notification_Item__c  pni : PushNotificationItemList ){
                
                Set<String> usersList =(String.isNotBlank(pni.UserRecipient__c) ? new Set<String>{pni.UserRecipient__c} :   (String.isNotBlank(pni.UsersIds__c) ? new Set<String>(pni.UsersIds__c.split(';')) : new Set<String>())) ;                
                PushNotification pushNotif = new PushNotification(pni,usersList ,iosClientBehavior);
                pushNotifications.add(pushNotif);

                if(!objectIdByType.containskey(pni.Type__c)){
                    objectIdByType.put(pni.Type__c, new Set<String>{});
                }
                objectIdByType.get(pni.Type__c).add(pni.ObjectId__c) ;
            }
            
            // BL_USE_CASE   
            for(String keyUseCase : objectIdByType.keyset()) {
                
                if(!exceptionUseCase.contains(keyUseCase) ){

                    List<Map<String, Object>> FieldAliasMap = new BL_EasyQuery()
                                                .useCase(keyUseCase +'_PushNotification')  
                                                .condition( 'id IN'+ BL_Utils.convertToString(objectIdByType.get(keyUseCase)))
                                                .executeQuery()
                                                .getMappedObjects();
                    objectList.addall(FieldAliasMap);	
                }
            }
            

            for(Map<String, Object> objct : objectList){
                
                if( objct.containskey('objectId')){
                    mapObjectById.put(String.valueOf(objct.get('objectId')),objct); 
                }
            } 
           
            for(PushNotification pushNotif : pushNotifications){
            
                if( mapObjectById.containskey(pushNotif.objectId) && String.isNotBlank(String.valueOf(mapObjectById.get(pushNotif.objectId)))  ){
                
                    pushNotif.userData.put( 'objectField' , mapObjectById.get(pushNotif.objectId));
                     // cretaion du pushrecipient
               		createListRecipent(pushNotif.userIds,pushNotif.pushItemId, JSON.serialize(mapObjectById.get(pushNotif.objectId)) );
                }else{
                    pushNotif.userData.put( 'objectID',pushNotif.objectId);
                }
             
            }
           
           System.debug(JSON.serialize(recipientToInsert)) ;
           System.debug('TEST' +recipientToInsert.isEmpty());
           if(!recipientToInsert.isEmpty()){
                 Database.Insert(recipientToInsert, TRUE); 
           }
          
            
            System.debug(JSON.serialize(pushNotifications)) ;
                
            AsyncSendNotification PushNotificationJob = new AsyncSendNotification(pushNotifications);
            System.enqueueJob(PushNotificationJob);
            
            
        } catch (Exception ex) {
            
            system.debug(ex.getMessage());
            
            //CREATE LOG
            /*  new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'Notification To New Icon', 
                'category' => 'APEX CODE',
                'exception_case' => ex
            });*/
       }    
   }
    public static void createListRecipent(Set<String> UserIds, String pushItemId , String jsonObjectField){
        
        System.debug(jsonObjectField) ;

        for(String UserId:UserIds ){
            
			recipientToInsert.add(createPushItemRecipient(UserId , pushItemId ,jsonObjectField));            
        }
        
    }
    
    /*
        * This function create child 'Push_Notification_Item_Recipient' for all users in a Push_Notification_Item
        * 
    */   
    static public Push_Notification_Recipient__c createPushItemRecipient(string userId , string itemId ,String jsonObjectField ){
        
        
        Push_Notification_Recipient__c itemRecipient = new Push_Notification_Recipient__c();
        itemRecipient.userId__c = userId;
        itemRecipient.Push_Notification_Item__c  = itemId;
        itemRecipient.ObjectField_Json__c  = jsonObjectField;
        itemRecipient.isRead__c = false;
        itemRecipient.ExKey__c = itemId+''+userId;
        return itemRecipient;
    }

    public class PushNotification   {
        public String pushItemId;		
		public Id objectId;	
		public Set<String> userIds;
		public Map<String,Object> userData = new Map<String,Object>();
		
		public PushNotification(Push_Notification_Item__c pni ,Set<String> userIds , Set<String> iosClientBehavior){

            Map<String, Object> aps = new Map<String, Object>();
            Map<String, Object> alert = new Map<String, Object>();

            this.userIds = userIds ;
            this.objectId = pni.ObjectId__c;
            this.pushItemId = pni.Id ;
            
            //String pniType = iosClientBehavior.contains(pni.Type__c) ? 'Client' : pni.Type__c;
           // this.userData.put('ObjectId',objectId);
            this.userData.put('Type',pni.Type__c);
            this.userData.put('Id',pni.Id);
            
            //aps.put('mutable-content',1);
            aps.put('content-available',1);

            if(pni.Is_Silent_Push__c == false){

                alert.put('body',pni.Body__c);
                if(String.isNotBlank(pni.Title__c)) {

                    if( String.isNotBlank(pni.Body__c) ){

                        alert.put('title',pni.Title__c) ;

                    } else{

                        alert.put('body',pni.Title__c);
                    }
                }
            }
            aps.put('alert',alert);
            this.userData.put('aps',aps);
		}
        
	}
     
}