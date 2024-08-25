global without sharing class IM_SendPushNotifications {

    public static void ClientListSendPush(List<CLI_CliList__c> clsList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();
        List<CLI_CliList__c>cLsNotified=new List<CLI_CliList__c>();
        //For Test
        if(Test.isRunningTest()){
            setTestSettings();
        }
        try{
            //Retrieves relevant push recipients
            Set<String> ownerIds = IC_UTILS.getIdList(clsList,'OwnerId');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey, WWEmployeeNumber__c, MGMT_ZONE_SUB_LEVEL1__c, DefaultStore__c, Lastname, FirstName  From User Where Id IN : ownerIds]);
            Map<String, Object> notifWecom = new Map<String, Object>();

            for(CLI_CliList__c cl:clsList){
                String placeholder = '';
                String languageLocaleKey = userMap.get(cl.OwnerId).LanguageLocaleKey;
                
                //Retrieve Push Message according to the user language
                if(cl.Type__c == 'Exclusive'){
                    placeholder = getNotificationTemplate(languageLocaleKey, 'Exclusive__c');
                }
                else if(!cl.TECH_IsReassignedClients__c) {
                    placeholder = getNotificationTemplate(languageLocaleKey, 'Client_List__c');
                } else {
                    placeholder = getNotificationTemplate(languageLocaleKey, 'Clients_Reassigned__c');
                } 
        
                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
                //Fill message according to fillers variablesß
                List<String> fillers = new String[]{cl.name};
                pushObj.Body__c=String.format(placeholder, fillers);
                pushObj.Type__c = 'ClientList';
                pushObj.ObjectId__c = cl.Id;
                pushObj.UserRecipient__c = (Id)cl.OwnerId;

                pushList.add(pushObj);
                CLI_CliList__c cl2 = new CLI_CliList__c(Id=cl.Id,TECH_PushNotified__c= true);
                cLsNotified.add(cl2);
            }

            if(cLsNotified.size() > 0 ){
               
                database.insert(pushList,false);
                database.update(cLsNotified,false);
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }
    }
    
    /*=================================================================================================================*/
    public static void ClientListExpirationSendPush(List<CLI_CliList__c> clsList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();
        List<CLI_CliList__c>cLsNotified=new List<CLI_CliList__c>();
        try{
            Set<String> ownerIds = IC_UTILS.getIdList(clsList,'OwnerId');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey, WWEmployeeNumber__c, MGMT_ZONE_SUB_LEVEL1__c, DefaultStore__c, Lastname, FirstName  From User Where Id IN : ownerIds]);
            for(CLI_CliList__c cl:clsList){
                String languageLocaleKey = userMap.get(cl.OwnerId).LanguageLocaleKey;
                String placeholder = getNotificationTemplate(languageLocaleKey, 'Expiration_List__c');

                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
                List<String> fillers = new String[]{cl.name};
                pushObj.Body__c=String.format(placeholder, fillers);
                pushObj.Type__c = 'ClientList';
                pushObj.ObjectId__c = cl.Id;
                pushObj.UserRecipient__c = (Id)cl.OwnerId;
                pushList.add(pushObj);
                CLI_CliList__c cl2 = new CLI_CliList__c(Id=cl.Id,TECH_PushNotified__c= true);
                cLsNotified.add(cl2);
            }
            if(cLsNotified.size()>0 ){
                database.insert(pushList,false);
                database.update(cLsNotified,false);
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }
        
    }

    /*=================================================================================================================*/
    @future
     public static void ClientReassignSendPush(List<String> accIdsList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();
        List<Account> accList = [Select Id, Name, OwnerId From Account Where Id IN : accIdsList];
        //For Test
        if(Test.isRunningTest()){
           setTestSettings();
        }
        try{
            //Retrieves relevant push recipients
            Set<String> ownerIds = IC_UTILS.getIdList(accList,'OwnerId');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,(Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) From User Where Id IN : ownerIds]);
            
            for(Account acc:accList){
                String languageLocaleKey = userMap.get(acc.OwnerId).LanguageLocaleKey;
                String placeholder = getNotificationTemplate(languageLocaleKey, 'Client_Assignment__c');

                //Fill push Notification Object
                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();

                //Fill message according to fillers variables
                List<String> fillers = new String[]{acc.name};
 
                if(!test.isRunningTest()){pushObj.Body__c = String.format(placeholder, fillers);}
                pushObj.Type__c = 'Client';
                pushObj.ObjectId__c = acc.Id;
                pushObj.UserRecipient__c = (Id)acc.OwnerId;
                pushList.add(pushObj);
            }
            if(pushList.size() > 0) {
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }
     }
        
    /*=================================================================================================================*/
    public static void FirmOrderSendPush(List<SPO_FirmOrder__c> firmOrderList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();

        //For Test
        if(Test.isRunningTest()) {
            setTestSettings();
       }
        try {
            //Retrieves relevant push recipients


            Set<String> ownerIds = IC_UTILS.getIdList(firmOrderList,'CreatedById');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,(Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) From User Where Id IN : ownerIds]);
            
            for(SPO_FirmOrder__c fo:firmOrderList){
                //Retrieve Push Message according to the user language
                String languageLocaleKey = !test.isRunningTest() ? userMap.get(fo.CreatedById).LanguageLocaleKey : 'en_US';
               // String pnTextPush = fo.SPO_FirmOrderStatus__c == 'Cancelled by production' ? 'OrderCancelled__c' : (fo.Send_Delay_Notification__c == true ? 'OrderDelay__c' : 'MIY__c');
               String pnTextPush = 'MIY__c';
               String placeholder = getNotificationTemplate(languageLocaleKey, pnTextPush);

                //Fill push Notification Object
                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();

                //Fill message according to fillers variables
                Datetime dt = fo.Planned_Delivery_date__c;
                system.debug('fooooooooooooooooooooooooo ' + fo);
                String dateAsString = dt.format('dd/MM/yyyy');
                List<String> fillers = new String[]{fo.Name, fo.Client_Name__c + '\'', dateAsString};
                pushObj.Body__c=String.format(placeholder, fillers);
           
                //pushObj.Type__c = 'FirmOrder';
                //pushObj.ObjectId__c = fo.Id;
                pushObj.Type__c = 'Order';
                pushObj.ObjectId__c = fo.SPO_BriefName__c;
                pushObj.UserRecipient__c = (Id)fo.OrderOwnerId__c;
                pushList.add(pushObj);
            }
            if(pushList.size() > 0) {
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }

    }

    /*=================================================================================================================*/
    public static void OpportunitySendPush(List<Opportunity> opportunityList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();

        //For Test
        if(Test.isRunningTest()) {
           setTestSettings();
        }
        try {
            //Retrieves relevant push recipients
            Set<String> ownerIds = IC_UTILS.getIdList(opportunityList,'CreatedById');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,(Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) From User Where Id IN : ownerIds]);
            
            for(Opportunity opp:opportunityList){
                String languageLocaleKey = userMap.get(opp.CreatedById).LanguageLocaleKey;
                String placeholder = getNotificationTemplate(languageLocaleKey, 'Order__c');

                //Fill push Notification Object
                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();

                //Fill message according to fillers variables
                List<String> fillers = new String[]{opp.Name, opp.SPO_ClientCompleteName__c};
                pushObj.Body__c=String.format(placeholder, fillers);
                pushObj.Type__c = 'Order';
                pushObj.ObjectId__c = opp.Id;
                pushObj.UserRecipient__c = (Id)opp.OwnerId;
                pushList.add(pushObj);
            }
            if(pushList.size() > 0) {
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }  
    }

    /*=================================================================================================================*/
    public static void CaseSendPush(List<Case> caseList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();

        //For Test
        if(Test.isRunningTest()){
            setTestSettings();
        }
        try{
            //Retrieves relevant push recipients
            Set<String> ownerIds = IC_UTILS.getIdList(caseList,'CA_Name__c');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,(Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) From User Where Id IN : ownerIds]);       
            //get Managers
            List <Case> caseListExtra = [Select Id, Store__c, Store__r.RetailStoreId__c,CA_Name__c,CaseNumber,High_Priority__c From Case where ID IN: caseList];
            
            Set<String> storeCodes = new Set<String>();
            for(Case caseRecord : caseListExtra){
                    storeCodes.add(caseRecord.Store__r.RetailStoreId__c);
            }
            Map<String, Set<User>> managerMap = getStoresManagers(storeCodes);
            System.debug('ca');
            for(Case caseRecord:caseListExtra){
                if ( caseRecord.CA_Name__c != null ){
                    System.debug('ca');
                    String languageLocaleKey = userMap.get(caseRecord.CA_Name__c).LanguageLocaleKey;
                    String placeholder = getNotificationTemplate(languageLocaleKey, 'Request__c');

                    //Fill push Notification Object
                    Push_Notification_Item__c pushObj= new Push_Notification_Item__c();

                    //Fill message according to fillers variables
                    List<String> fillers = new String[]{caseRecord.CaseNumber};
                    pushObj.Body__c=String.format(placeholder, fillers);
                    pushObj.Type__c = 'Request';
                    pushObj.ObjectId__c = caseRecord.Id;
                    pushObj.UserRecipient__c = (Id)caseRecord.CA_Name__c;
                    pushList.add(pushObj);

                } else if ( caseRecord.High_Priority__c == true && 
                            managerMap!= null && managerMap.size() > 0 &&
                            managerMap.get(caseRecord.Store__r.RetailStoreId__c) != null && 
                            managerMap.get(caseRecord.Store__r.RetailStoreId__c).size() > 0 ){
                    
                    List<User> managers = new List<User>();
                    managers.addAll(managerMap.get(caseRecord.Store__r.RetailStoreId__c));
                    String languageLocaleKey = managers[0].LanguageLocaleKey;
                    String placeholder = getNotificationTemplate(languageLocaleKey, 'Request_Manager__c');
                    //Fill push Notification Object
                    Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
                    //Fill message according to fillers variables
                    List<String> fillers = new String[]{caseRecord.CaseNumber};
                    pushObj.Body__c=String.format(placeholder, fillers);
                    pushObj.Type__c = 'Request';
                    pushObj.ObjectId__c = caseRecord.Id;
                    pushObj.UsersIds__c =  '';
                    if(managerMap.size() > 0) {
                        for( User u :managers){
                            pushObj.UsersIds__c += (Id)u.Id +';';
                        }
                    }
                    pushList.add(pushObj);
                }
            }
            system.debug(pushList); 
            if(pushList.size() > 0) {
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }

    }

    /*=================================================================================================================*/
    public static void CareServiceSendPush(List<CareService__c> careList, Boolean isSilentPush, Map<id, CareService__c> oldCareServiceMap){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();

        //For Test
        if(Test.isRunningTest()){
            setTestSettings();
        }
        try{
            //Retrieves relevant push recipients
            Set<String> ownerIds = IC_UTILS.getIdList(careList,'CA__c');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,DefaultStore__c, (Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) 
            From User Where Id IN : ownerIds]);          
            //get Managers
            Set<String> storeIds = IC_UTILS.getIdList(careList,'StoreRetailCode__c');
            Map<String, Set<User>> managerMap = getStoresManagers(storeIds);          
            for(CareService__c careRecord:careList){

                //Fill push Notification Object
                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
                if(isSilentPush == false){
                    String placeholder = '';
                    String languageLocaleKey = userMap.get(careRecord.CA__c).LanguageLocaleKey;
                    if(careRecord.ICON_Comments__c != null && oldCareServiceMap.get(careRecord.Id).ICON_Comments__c != careRecord.ICON_Comments__c && careRecord.LastModifiedById != careRecord.CA__c) {
                        placeholder = getNotificationTemplate(languageLocaleKey, 'CareServiceComment__c');
                    } else {
                        placeholder = getNotificationTemplate(languageLocaleKey, 'CareService__c');
                    }
                    //Fill message according to fillers variables
                    List<String> fillers = new String[]{careRecord.TransactionId__c};
                    pushObj.Body__c = String.format(placeholder, fillers);
                } else{
                    pushObj.Is_Silent_Push__c = true;
                }
                pushObj.Type__c = 'CareService';
                pushObj.ObjectId__c = careRecord.Id;

                pushObj.UsersIds__c = careRecord.CA__c != null && careRecord.CA__c != careRecord.LastModifiedById ? (Id)careRecord.CA__c +';' : '';
                if (managerMap.size() > 0){
                    for( User u : managerMap.get(careRecord.StoreRetailCode__c)){
                        if ( (Id)u.Id != careRecord.LastModifiedById){
                            pushObj.UsersIds__c += (Id)u.Id +';';
                        }
                    }
                }
                
                if(oldCareServiceMap != null && oldCareServiceMap.get(careRecord.Id) != null){
                    String oldCA = oldCareServiceMap.get(careRecord.Id).CA__c;
                    if (oldCA != null && oldCA != careRecord.CA__c){
                        pushObj.UsersIds__c += (Id)oldCA +';';
                    }
                }
                if (pushObj.UsersIds__c != ''){
                    pushList.add(pushObj);
                }
            }
            system.debug(pushList); 
            if(pushList.size() > 0) {
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }
    }

/*=================================================================================================================*/


    public static void AppointmentSendPush(List<Event> events , Map<String ,String> notificationTypebyEventId ){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();
        if(Test.isRunningTest()){
            setTestSettings();
        }

        try{  
            Set<String> ownerIds = IC_UTILS.getIdList(events,'OwnerId');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey From User Where Id IN : ownerIds]);
            Set<String> accountIds = IC_UTILS.getIdList(events,'WhatId');
            Map<Id,Account> clientMap = new Map<ID, Account>([SELECT Id, Name From Account Where Id IN : accountIds]);

            for(Event appointment : events){
                
                String language  = userMap.get(appointment.OwnerId)?.LanguageLocaleKey;
                String languageLocaleKey = language != null ? language : 'en_US';
                String pnTextField = notificationTypebyEventId.get(appointment.Id);
                String placeholder = getNotificationTemplate(languageLocaleKey, pnTextField);

                //Fill push Notification Object
                Push_Notification_Item__c pushObj = new Push_Notification_Item__c(
                    Type__c = 'Appointment',
                    ObjectId__c = appointment.Id,
                    UserRecipient__c = (Id) appointment.OwnerId
                );

                List<Object> fillers = new List<Object>{appointment.Id,appointment.Reason__c, appointment.ActivityDate, clientMap.get(appointment.WhatId)?.Name};                               
                if(!test.isRunningTest()){
                    pushObj.Body__c = String.format(placeholder, fillers);
                }

                pushList.add(pushObj);
            }
            if(!pushList.isEmpty()){
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }  
         
    }

    public static void AppointmentSendPush(List<Event> appointmentList){
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();

        //For Test
        if(Test.isRunningTest()){
           setTestSettings();
        }
        try{
            //Retrieves relevant push recipients
            Set<String> ownerIds = IC_UTILS.getIdList(appointmentList,'OwnerId');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,(Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) From User Where Id IN : ownerIds]);
            System.debug('ownerIds: ' + ownerIds);
            System.debug('userMap: ' + userMap);
            System.debug('appointmentList: ' + appointmentList);
            for(Event appt: appointmentList){
                String languageLocaleKey = !test.isRunningTest() ? userMap.get(appt.OwnerId).LanguageLocaleKey : 'en_US';
                String pnTextField = appt.Status__c == 'Cancelled' ? 'AppointmentCancelled__c' : 'AppointmentAssigned__c';
                String placeholder = getNotificationTemplate(languageLocaleKey, pnTextField);
                System.debug('placeholder: ' + placeholder);
                //Fill push Notification Object
                Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
                //Fill message according to fillers variables
                List<String> fillers = new String[]{};
                if(!test.isRunningTest()){pushObj.Body__c = String.format(placeholder, fillers);}
                
            
                pushObj.Type__c = 'Appointment';
                pushObj.ObjectId__c = appt.Id;
                pushObj.UserRecipient__c = (Id)appt.OwnerId;
                pushList.add(pushObj);
            }
            System.debug('pushList: ' + pushList);
            if(pushList.size() > 0) {
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }  
    }

    /*=================================================================================================================*/  
    public static Map<String, Set<User>> getStoresManagers(Set<String> storeIds){
        system.debug(storeIds);
        List<User> managerList = [SELECT Id, LanguageLocaleKey,DefaultStore__c, (Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) 
        From User Where DefaultStore__c IN : storeIds AND TECH_IsManager__c = true AND DefaultStore__c != null AND isActive = true];

        Map<String, Set<User>> managerMap = new Map<String, Set<User>>();
        for( User u : managerList){
            if(managerMap.get(u.DefaultStore__c) == null){
                managerMap.put(u.DefaultStore__c, new Set<User>());
            }
            managerMap.get(u.DefaultStore__c).add(u);
        }

        return managerMap;
    }

    public static String getNotificationTemplate(String languageLocaleKey, String templateField) {
        IM_Notifications__c notificationTemplate = IM_Notifications__c.getInstance(languageLocaleKey);
        if(!test.IsRunningTest() ? notificationTemplate == null : true)
            notificationTemplate = IM_Notifications__c.getInstance('en_US');

        String template = (String)notificationTemplate.get(templateField);

        if(!test.IsRunningTest() ? template == null : true) {
            notificationTemplate = IM_Notifications__c.getInstance('en_US');
            template = (String)notificationTemplate.get(templateField);
        }
        return template;
    }

    public static void ClientMemberShipSendPush(List<Club_MemberShip__c> clubMembers ){
       /* 
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();
        if(Test.isRunningTest()){
            setTestSettings();
        }
        try{  
            Set<String> accountIds = IC_UTILS.getIdList(clubMembers,'clientId__c');
            Map<Id,Account> clientMap = new Map<ID, Account>([SELECT Id, Name,OwnerId,FirstName,LastName From Account Where Id IN : accountIds]);
            Set<String> ownerIds = IC_UTILS.getIdList(clientMap.values(),'OwnerId');
            Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,MGMT_ZONE_SUB_LEVEL1__c,WWEmployeeNumber__c,DefaultStore__c,FirstName,LastName From User Where Id IN : ownerIds]);
            for(Club_MemberShip__c clubMember : clubMembers){
                Account acc = clientMap.get(clubMember.clientId__c);
                //Id ownerId = acc.ownerId;
                User owner = userMap.get(acc.ownerId);
                if(owner.MGMT_ZONE_SUB_LEVEL1__c == '1071' && owner.DefaultStore__c != null){
                    sendWecomeNotif(owner, acc);
                }
                String language  = owner?.LanguageLocaleKey;
                String languageLocaleKey = language != null ? language : 'en_US';
                String pnTextField = 'Club_Member_Eligible__c';
                String placeholder = getNotificationTemplate(languageLocaleKey, pnTextField);
                //Fill push Notification Object
                Push_Notification_Item__c pushObj = new Push_Notification_Item__c(
                    Type__c = 'ClubMemberShip',
                    ObjectId__c = clubMember.Id,
                    UserRecipient__c = owner.Id
                );
                List<Object> fillers = new List<Object>{acc.Name};                               
                if(!test.isRunningTest()){
                    pushObj.Body__c = String.format(placeholder, fillers);
                }

                pushList.add(pushObj);
            }
            if(!pushList.isEmpty()){
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }  
      */
    }

    public static void experienceVariationSendPush(List<Id> newExperiencesIds ){
        
        List<Push_Notification_Item__c> pushList = new List<Push_Notification_Item__c>();
        if(Test.isRunningTest()){
            setTestSettings();
        }
        try{  
             Set<String> retailStoreIds = new Set<String>();
             Map<String,List<Id>> userByStore = new Map<String,List<Id>>();
             Map<String, String> countryByStoreCode = new Map<String, String>();
            
             List<Brand_Experience_Variation__c> experiences = [  
                                                                SELECT Name, Id, Store__r.RetailStoreId__c  ,Store__r.ISO3_Code__c   
                                                                FROM Brand_Experience_Variation__c
                                                                WHERE id in: newExperiencesIds AND Brand_Experience__r.RecordType.DeveloperName = 'Experience'
                                                            ];
             
             for(Brand_Experience_Variation__c experience : experiences){
                 retailStoreIds.add(experience.Store__r.RetailStoreId__c);
                 countryByStoreCode.put(experience.Store__r.RetailStoreId__c, experience.Store__r.ISO3_Code__c);
             }
            
             Map<String, String> languagePerCountry = BL_Experience_Variation_Utils.getLanguagePerStore(countryByStoreCode.values());
             userByStore = BL_Experience_Variation_Utils.getUsersByStore(retailStoreIds, null);
             system.debug( userByStore);
             
             for(Brand_Experience_Variation__c experience : experiences){

                String storeCode = (String) experience.Store__r.RetailStoreId__c;
                String caLanguage = languagePerCountry.get(countryByStoreCode.get(storeCode)) ;
                String placeholder = IM_SendPushNotifications.getNotificationTemplate(caLanguage, 'ExperienceVariationCreated__c');
                List<String> fillers = new String[]{experience.Name};

                Push_Notification_Item__c push = new Push_Notification_Item__c(
                     Body__c = String.format(placeholder, fillers),
                     Type__c = 'Experience_Variation',
                     ObjectId__c = experience.Id,
                     UsersIds__c  = String.join(userByStore.get(experience.Store__r.RetailStoreId__c) , ';')
                 );
                 pushList.add(push);
             }
         
            if(!pushList.isEmpty()){
                insert pushList;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
        }  
      
    } 
    static private void sendWecomeNotif(User caUser, Account client){
        Wecom_Notification__mdt mdt = Wecom_Notification__mdt.getInstance('LV_Snickers_Club_Member_Add');
        Map<String, String> params = new Map<String, String>{
            'key'=> '早上好​',
            'value'=> caUser.Lastname + ' ' + caUser.FirstName
        };
        String redirectPath = mdt.Path__c.replace('{clientId}',client.Id);
        Map<String,String> notifDetails= new Map<String,String>{
            'mainMessageKey' => mdt.Main_Message_Key__c,
            'mainMessage' => client.FirstName + ' '+ client.LastName,
            'lvMid' => caUser.WWEmployeeNumber__c,
            'path' => redirectPath,
            'title' =>  mdt.Title__c,
            'description' => mdt.Description__c
        };
        BL_WecomUtils.sendNotif(notifDetails, params);
    }
    static public Void setTestSettings(){
        if(IM_Notifications__c.getInstance('en_US')==null){

            IM_Notifications__c imn =  new IM_Notifications__c(
                Name='en_US',
                Client_List__c='A new client List was assigned to you : {0}',
                Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',
                Survey__c='A new Survey was created by: {0}',
                Clients_Reassigned__c='A new client List was assigned to you : {0}',
                MIY__c='A new client List was assigned to you : {0}',
                Order__c= 'A new client List was assigned to you : {0}', 
                SurveyManager__c='A new client List was assigned to you : {0}',
                Request__c = 'A new client List was assigned to you : {0}',
                CareService__c = 'A new client List was assigned to you : {0}'
                //Club_Member_Eligible__c = 'A new client List was assigned to you : {0}',
                //ExperienceVariationCreated__c = 'The event {0} has been created'
            );
            insert imn;
        }
    }

}