/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-28-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global without sharing class IM_PushNotification_Config {

    /*=================================================================================================================*/
    public static void SendPushNotifications(List<PushObject> pushList) {
        system.debug(System.Limits.getMobilePushApexCalls());
        for(PushObject push : pushList){
            if(System.Limits.getMobilePushApexCalls() < 10) {
                Messaging.PushNotification msgPN = new Messaging.PushNotification();
                Map<String, Object> payload = push.userData;
                // Adding the assembled payload to the notification
                system.debug(payload);
                msgPN.setPayload(payload);
                try{
                    msgPN.send('ICON_ios', push.users);
                } catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
        }
    }

    /*=================================================================================================================*/        
    global class PushObject {
        public String msg {get; set;}
        public Set<String> users {get;set;}
        public Map<String, Object> userData {get;set;}
    }
    //Generci method to generate push notification Payload to send according to the Type Sobject is from
    static public void createPushNotifications(Map<String, Map<String, Push_Notification_Item__c>> pushMap) {
        try {
            System.debug('createPushNotifications pushMap: ' + pushMap);
            List<PushObject> pushToSend = new List<PushObject>();

            //Get IM_NotificationsMaps__c to generate relevant parameters in the payload according to Object Type
            List<IM_NotificationsMaps__c> objectTypesList = IM_NotificationsMaps__c.getall().values();
 
            for(IM_NotificationsMaps__c objectType : objectTypesList) {

                if(pushMap.get(objectType.Name) !=  null) {

                    Set<String> listIds = pushMap.get(objectType.Name).keySet();
                    if(objectType.Fields__c != null) {

                        //Generic SOQL to retrieve parameters for payload
                        String query = 'SELECT '+objectType.Fields__c+' FROM '+objectType.ObjectName__c+' WHERE Id IN :listIds';
                        System.debug('query: ' + query);
                        List<SObject> objects = Database.query(query);
                        System.debug('objects: ' + objects);
                        for(SObject obj : objects) {
                            //Call generic Method to build Method to Build Payload Object according to Type
                            PushObject push = buildPushObject(pushMap.get(objectType.Name).get(obj.Id));

                            //Call generic Method to build Field - Aliases Map in order to retrieve params from SF readable in IOS App
                            Map<String, String> fieldAliasMap = buildFieldAliasMap(objectType.Fields__c, objectType.Aliases__c);

                            for(String field : fieldAliasMap.keySet()) {

                                //If Fields are reltaed Fields for example Contact.Account.Name
                                if(field.contains('.')) {
                                    
                                    List<String> arrayFields = field.split('\\.');
                                    Object objToPut = obj;

                                    //Loop over the related Fields to retrieve the relevant SOQL results
                                    for(Integer i = 0; i < arrayFields.size(); i++) {
                                        if((SObject)objToPut != null){
                                            if(i < (arrayFields.size()-1)) {
                                                objToPut = ((SObject)objToPut).getSObject(arrayFields[i]);
                                            } else { 
                                                objToPut = ((SObject)objToPut).get(arrayFields[i]);
                                            }
                                        }
                                    }
                                    push.userData.put(fieldAliasMap.get(field), objToPut);

                                } else {
                                    push.userData.put(fieldAliasMap.get(field), obj.get(field));
                                }
                            }
                            pushToSend.add(push);
                        }
                    } else {
                        //If no need to retrieve SOQL Fields for IOS params Payload
                        for(String objId : listIds) {
                            PushObject push = buildPushObject(pushMap.get(objectType.Name).get(objId));
                            push.userData.put('ObjectId',objId);
                            pushToSend.add(push);
                        }
                    }
                }
            }
            
            if(pushToSend.size() > 0) {
                SendPushNotifications(pushToSend);
            }
        } catch(Exception ex) {
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }
    }

    /*=================================================================================================================*/
    static public Map<String,String> buildFieldAliasMap(String fieldsString,String aliasesString) {
        Map<String, String> fieldAliasMap = new Map<String, String>();
        if(aliasesString != null) {
            List<String>fieldsArray = fieldsString.split(',');
            List<String>aliasesArray = aliasesString.split(',');
            for(Integer i = 0; i < math.min(fieldsArray.size(),aliasesArray.size()); i++) {
                fieldAliasMap.put(fieldsArray[i],aliasesArray[i]);
            }
            return fieldAliasMap;
        } 
        for(String field : fieldsString.split(',')){
            fieldAliasMap.put(field,field);
        }
        return fieldAliasMap;
    }

    /*=================================================================================================================*/
    static public PushObject buildPushObject(Push_Notification_Item__c pni) {
        //type That IOS behavior will as Client Push Behavior (could be put in Custom settings)
        Set<String> iosClientBehavior = new Set<String>{'FirmOrder','Order'};
        String pniType = iosClientBehavior.contains(pni.Type__c) ? 'Client' : pni.Type__c;

        PushObject push = new PushObject();
        Map<String,Object> userData  = new Map<String,Object>();

        userData.put('Type',pniType);
        userData.put('Id',pni.Id);

        //Set payload IOs params
        Map<String, Object> aps = new Map<String, Object>();
        
        aps.put('mutable-content',1);
        aps.put('content-available',1);

        Map<String, Object> alert = new Map<String, Object>();
        if( pni.Is_Silent_Push__c == false ){
            alert.put('body',pni.Body__c);
            if (pni.Title__c != null) {
                if(pni.Body__c != null) {
                    alert.put('title',pni.Title__c);
                } else{
                    alert.put('body',pni.Title__c);
                }
            }
        }
        aps.put('alert',alert);
        userData.put('aps',aps);

        //Set recipients
        if(pni.UserRecipient__c != null) { // If One Recipient
            push.users = new Set<String>{pni.UserRecipient__c};
        } 
        else if(pni.UsersIds__c != null && pni.UsersIds__c != '') { //If multiple Recipients
            push.users = new Set<String>(pni.UsersIds__c.split(';'));
        }

        push.userData = userData;

        return push;
    }

    /*=================================================================================================================*/
    static public Void afterInsertUpdatePnis(List<Push_Notification_Item__c> newPnis, Map<Id, Push_Notification_Item__c> oldPnisMap) {
        Map<String, Map<String, Push_Notification_Item__c>> pushMap = new Map<String, Map<String, Push_Notification_Item__c>>();
	    List<Push_Notification_Item__c> pnisToUpdate = new List<Push_Notification_Item__c>();

        for(Push_Notification_Item__c pni : newPnis) {
            if(pni.Type__c != 'Wardrobing' && (oldPnisMap == null || (pni.Need_To_Be_Send__c && pni.Need_To_Be_Send__c != oldPnisMap.get(pni.Id).Need_To_Be_Send__c)) ) {
                Push_Notification_Item__c pniToUpdate = new Push_Notification_Item__c(
                    Id = pni.Id,
                    Need_To_Be_Send__c = false, 
                    Last_Send_Date__c = datetime.now(),
                    Title__c = pni.Title__c,
                    Body__c = pni.Body__c,
                    ObjectId__c = (Id)pni.ObjectId__c,
                    Type__c = pni.Type__c != null ? pni.Type__c : 'Other',
                    UserRecipient__c = pni.UserRecipient__c
                );

                if(pni.UsersIds__c != null && pni.UsersIds__c != '') {
                    List<String> userIdsList = pni.UsersIds__c.split(';');
                    pniToUpdate.UsersIds__c = '';
                    for(String uId : userIdsList){
                        Id newId18 = uId;
                        pniToUpdate.UsersIds__c += newId18+';';
                    }
                }
                pnisToUpdate.add(pniToUpdate);

                if(pushMap.get(pniToUpdate.Type__c) == null) {
                    pushMap.put(pniToUpdate.Type__c, new Map<String,Push_Notification_Item__c>());
                }
                String objId = pniToUpdate.ObjectId__c != null ? pniToUpdate.ObjectId__c : pniToUpdate.id;
                pushMap.get(pniToUpdate.Type__c).put(objId,pniToUpdate);
            }
        }

        createPushNotifications(pushMap);

        if (pnisToUpdate.size() > 0) {
            update pnisToUpdate;
        }
    }

   


}