/*
***************************************************************************************************
* @File Name          : TR_BatchMergeMylvAccount.cls
* @Description        : This Batch was created for the C360 project to merge Mylv Client From technical Table => TECH_Merge_Manager__c 
* @Author             : Imad.alsidchikh
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh 
* @Last Modified On   : 11-09-2023
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       11-09-2023         Imad.alsidchikh                   Initial Version
* 1.1       30-10-2023         Ayoub.lameghaizi                  Update to deal with duplicate values of TECH_Merge_Manager__c records

****************************************************************************************************
*/

global class TR_BatchMergeMylvAccount implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    
    private  List<Account> absorbedClients;
    private  List<Account> masterClients;
    private  List<User> finalUserToAnonymize = new List<User>();
    private  static List<Datetime> existingDatetime = new List<Datetime>();
    private  static List<Account> finalListAccountUpdate = new List<Account>();
    private  static Map<String,TECH_Merge_Manager__c>  mapFinalMasterTechMerge =  new Map<String,TECH_Merge_Manager__c>();
    private  static Map<String,TECH_Merge_Manager__c>  mapFinalDreamTechMerge =  new Map<String,TECH_Merge_Manager__c>();
    private  static List<TECH_Merge_Manager__c> listMergeMangerRecoToUpdate = new List<TECH_Merge_Manager__c>();
    private  static Map<String,String> MapTechMegeUserToAnonymize = new Map<String,String>();
    
    private  static Map<String,User>  mapFinalMasterUser = new Map<String,User>();
    private  static Map<String,Asset>  mapFinalMasterAsset = new Map<String,Asset>();
    private  static Set<Id> masterAccountsIds = new Set<Id>();
    private  static Set<Id> childAccountsIds = new Set<Id>();  
    private  static Set<Id> techMergeIds = new Set<Id>();
    private  static Map<String,Account> finalChildAccountsIds = new Map<String,Account>();
    private  static Map<String,Account> MapSfIdAccountMasters = new Map<String,Account>();
    private String query;
    private Integer clientMergeLimit;
    private final Account_deletion_setting__mdt setting;
    
    global TR_BatchMergeMylvAccount() {
        clientMergeLimit = Integer.valueOf(Transverse_Batchs_Setup__c.getAll().get('Batch Merge Mylv').Limit__c);
        query = 'SELECT  Id, Child_DreamId__c, Child_SalesforceId__c, Master_DreamId__c, Master_SalesforceId__c, TR_Logs__c, Done__c from TECH_Merge_Manager__c WHERE Done__c= false ';
        if(clientMergeLimit != null){
            query = query + ' Limit :clientMergeLimit';
            //query = query + ' Limit 3';
        }
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        TECH_Merge_Manager__c mergeMangerReco = new TECH_Merge_Manager__c();
        if(scope.Size()>0){
            System.debug('scope.Size(): '+scope.Size());            
            for(sObject reco:scope){
                mergeMangerReco = (TECH_Merge_Manager__c) reco;
            	//System.debug('mergeMangerReco: '+mergeMangerReco);  
                if(String.isNotBlank(mergeMangerReco.Child_SalesforceId__c) && String.isNotBlank(mergeMangerReco.Master_SalesforceId__c)){
                	//System.debug('masterAccountsIds before: '+masterAccountsIds);               
                    masterAccountsIds.add(mergeMangerReco.Master_SalesforceId__c);
                	//System.debug('masterAccountsIds after: '+masterAccountsIds);  
                    //System.debug('childAccountsIds before: '+childAccountsIds);
                    childAccountsIds.add(mergeMangerReco.Child_SalesforceId__c);
                    //System.debug('childAccountsIds after: '+childAccountsIds);
                    //System.debug('mapFinalMasterTechMerge BEFORE: '+mapFinalMasterTechMerge);
                    mapFinalMasterTechMerge.put(mergeMangerReco.Master_DreamId__c, mergeMangerReco);
                    //System.debug('mapFinalMasterTechMerge AFTER: '+mapFinalMasterTechMerge);
                    //System.debug('mapFinalDreamTechMerge BEFORE: '+mapFinalDreamTechMerge);
                    mapFinalDreamTechMerge.put(mergeMangerReco.Child_DreamId__c, mergeMangerReco);
                    //System.debug('mapFinalDreamTechMerge AFTER: '+mapFinalDreamTechMerge);
                }
            }
        }
        startMergeClients();
    } 
    
    global void finish(Database.BatchableContext BC){
        System.debug('final User To Anonymize size: '+finalUserToAnonymize.size());
        if(!finalUserToAnonymize.isEmpty()){
            TR_QueueableMergeMylvUser queueable = new TR_QueueableMergeMylvUser(finalUserToAnonymize);
            System.enqueueJob(queueable);
        }
    }
    global void execute(SchedulableContext sc) {
        Integer workerSize = Integer.valueOf(Transverse_Batchs_Setup__c.getAll().get('Batch Merge Mylv').Batch_Worker_Size__c);
        TR_BatchMergeMylvAccount b = new TR_BatchMergeMylvAccount();
        database.executebatch(b, workerSize);
    }
    private void startMergeClients() { 
        masterClients =  getMasterRecords(masterAccountsIds);
                		System.debug('masterClients size: '+masterClients.size());
                		//System.debug('masterClients: '+masterClients);
        absorbedClients =  getChildRecords(childAccountsIds);
                		System.debug('absorbedClients size: '+absorbedClients.size());
                		//System.debug('absorbedClients: '+absorbedClients);
        if(absorbedClients.size()>0){
            for(Account acct : absorbedClients){
                //System.debug('current absorbedClients acct: '+acct);
                if(mapFinalMasterTechMerge.get(acct.DreamIdMasterClient__c) != null){
                    if(MapSfIdAccountMasters.containsKey(acct.MasterClientSFID__c) && !acct.users.isEmpty() && mapFinalMasterAsset.get(acct.Id) == NULL) {//if Master exists && slave has A USER && slave has 0 ASSETS
                        if(mapFinalMasterUser != null && mapFinalMasterUser.get(acct.MasterClientSFID__c) != null){ //if Master has A USER
                            if(acct.PersonEmail != acct.users[0].UserName){//if slave user email != slave personEmail -> anonymise Slave User
                                String techMergeId = mapFinalMasterTechMerge.get(acct.DreamIdMasterClient__c).Id;
                                User usr = anonymizeUserRecord(acct.Users[0]);   
                                finalUserToAnonymize.add(usr);
                                finalListAccountUpdate.Add(disableDateIdentity(acct));
                                //System.debug('finalListAccountUpdate: '+finalListAccountUpdate);
                                //System.debug('finalListAccountUpdate size: '+finalListAccountUpdate.Size());
                                TECH_Merge_Manager__c mergeMangerRecoToUpdate = new TECH_Merge_Manager__c();
                                mergeMangerRecoToUpdate.Id=techMergeId;
                                mergeMangerRecoToUpdate.Done__c=true;
                                mergeMangerRecoToUpdate.TR_UserToAnonymize__c=usr.Id;
                                Datetime currentDatetime = Datetime.now();
                                String formattedDatetime = currentDatetime.format();
                                mergeMangerRecoToUpdate.TR_Logs__c='This line has been treated on '+formattedDatetime+' ! \nSlave User anonymised ('+usr.Id+')';
                                listMergeMangerRecoToUpdate.add(mergeMangerRecoToUpdate);
                                if(!techMergeIds.contains(techMergeId)){
                                    techMergeIds.add(techMergeId);
                                }
                            }else if(mapFinalMasterAsset.get(acct.MasterClientSFID__c) == NULL){ //ELSE if (slave user email == slave personEmail) && Master has A USER and 0 ASSET -> anonymise Master User & exchange slave-master
                                String techMergeId = mapFinalMasterTechMerge.get(acct.DreamIdMasterClient__c).Id;
                                User usr =  anonymizeUserRecord(MapSfIdAccountMasters.get(acct.MasterClientSFID__c).Users[0]);
                                TECH_Merge_Manager__c mergeMangerRecoToUpdate = new TECH_Merge_Manager__c();
                                MapTechMegeUserToAnonymize.put(techMergeId,usr.Id);
                                finalUserToAnonymize.add(usr);
                                finalListAccountUpdate.addall(shareDataAccountFirstcase(MapSfIdAccountMasters.get(acct.MasterClientSFID__c),acct));
                                //System.debug('finalListAccountUpdate: '+finalListAccountUpdate);
                                //System.debug('finalListAccountUpdate size: '+finalListAccountUpdate.Size());
                            }
                        }else{ //ELSE: Master has 0 USER & Slave has A USER -> exchange slave-master
                            finalListAccountUpdate.addall(shareDataAccountFirstcase(MapSfIdAccountMasters.get(acct.MasterClientSFID__c),acct));
                            //System.debug('finalListAccountUpdate: '+finalListAccountUpdate);
                            //System.debug('finalListAccountUpdate size: '+finalListAccountUpdate.Size());
                        }
                    }else{
                        TECH_Merge_Manager__c mergeMangerRecoToUpdate = new TECH_Merge_Manager__c();
                        if(mapFinalMasterTechMerge.get(Acct.DreamIdMasterClient__c)!=null){
                            String techMergeId =(String) mapFinalMasterTechMerge.get(acct.DreamIdMasterClient__c).Id;
                            mergeMangerRecoToUpdate.Id=techMergeId;
                            mergeMangerRecoToUpdate.Done__c=true;
                            Datetime currentDatetime = Datetime.now();
                            String formattedDatetime = currentDatetime.format();
                            mergeMangerRecoToUpdate.TR_Logs__c='This line has been ignored on '+formattedDatetime+' !';

                            if(!techMergeIds.contains(techMergeId)){
                                listMergeMangerRecoToUpdate.add(mergeMangerRecoToUpdate);
                                techMergeIds.add(techMergeId);  
                            }
                        }
                    }
            	}
            }
            if(!finalListAccountUpdate.isEmpty()) {
                //System.debug('finalListAccountUpdate: '+finalListAccountUpdate);
                System.debug('finalListAccountUpdate size: '+finalListAccountUpdate.Size());
                Database.SaveResult[] results = Database.update(finalListAccountUpdate, false);
                Account accToTransfet;
                for(Database.SaveResult re : results){
                //System.debug('result: '+re);
                    TECH_Merge_Manager__c mergeMangerRecoToUpdate = new TECH_Merge_Manager__c();
                    if(re.isSuccess() && finalChildAccountsIds.containsKey(re.getId()) ){
                        accToTransfet=(Account) finalChildAccountsIds.get(re.getId());
                        String techMergeId = String.valueOf(mapFinalMasterTechMerge.get(accToTransfet.DreamIdMasterClient__c).get('Id'));
                        mergeMangerRecoToUpdate.Id=techMergeId;
                        mergeMangerRecoToUpdate.Child_DreamId__c = accToTransfet.DREAMID__c;
                        mergeMangerRecoToUpdate.Child_SalesforceId__c= accToTransfet.Id;
                        mergeMangerRecoToUpdate.Master_DreamId__c= accToTransfet.DreamIdMasterClient__c;
                        mergeMangerRecoToUpdate.Master_SalesforceId__c= accToTransfet.MasterClientSFID__c;
                        mergeMangerRecoToUpdate.Done__c = true;
                        Datetime currentDatetime = Datetime.now();
                        String formattedDatetime = currentDatetime.format();
                        mergeMangerRecoToUpdate.TR_Logs__c='This line has been treated and accounts SF ID exchanged on '+formattedDatetime+' !';
                        if(MapTechMegeUserToAnonymize.get(techMergeId)!=null){
                            String userId=MapTechMegeUserToAnonymize.get(techMergeId);
                            mergeMangerRecoToUpdate.TR_UserToAnonymize__c=userId;
                            mergeMangerRecoToUpdate.TR_Logs__c+='\nMaster User anonymised ('+userId+')';               
                        }
                        if(!techMergeIds.contains(techMergeId)){
                            listMergeMangerRecoToUpdate.add(mergeMangerRecoToUpdate);
                            techMergeIds.add(techMergeId);
                        }
                    }
                }
            }
            if(!listMergeMangerRecoToUpdate.isEmpty()){
                Database.SaveResult[] results2 = Database.update(listMergeMangerRecoToUpdate, false);   
                //system.debug(results2);
            }
        }
    }
    private  List<Account> getMasterRecords(Set<Id> lstMClients) {
        List<Account> masList    = [   SELECT ID,PersonEmail ,DREAMID__c,DreamIdMasterClient__c,Date_Identity__pc, Anonymization_date__c,Anonymization_key__c,MasterClientSFID__c,
                                    (SELECT id , Username,accountid,Email,IsActive FROM Users),(SELECT id FROM assets)
                                    FROM Account 
                                    WHERE  Id IN :lstMClients
                                   ];
        for(Account acc : masList){
            MapSfIdAccountMasters.put(acc.Id,acc);
            if(acc.users!=null && acc.users.size()>0){
                mapFinalMasterUser.put(acc.id, acc.users[0]);
            }
            if(acc.assets!=null && acc.assets.size()>0){
                mapFinalMasterAsset.put(acc.id, acc.assets[0]);
            }
        } 
        return masList;     
    }
    private List<Account> getChildRecords(Set<Id> lstCClients) {
        List<Account> absoList    = [   SELECT ID,PersonEmail ,DREAMID__c,DreamIdMasterClient__c,Date_Identity__pc, Anonymization_date__c,Anonymization_key__c,MasterClientSFID__c,
                                     (SELECT id , Username,accountid,Email,IsActive FROM Users),(SELECT id FROM assets) 
                                     FROM Account 
                                     WHERE  Id IN :lstCClients
                                    ];   
        for(account abAcc : absoList){
            if(abAcc.assets!=null && abAcc.assets.size()>0){
                mapFinalMasterAsset.put(abAcc.id, abAcc.assets[0]);
            }
        }
        return absoList;
    }
    public static Account disableDateIdentity(Account newacc) {
        newacc.ToDelete__c='1';
        newacc.date_identity__pc=null;
        return newacc;
    }
    public static User anonymizeUserRecord(User newUsr) {
        String suffixe = (String)ICONSettings__c.getOrgDefaults().get('ClientAnonymizationSuffixe__c');
        Datetime currentDatetime = generateUniqueDatetime();
        String formattedDatetime = currentDatetime.format('yyyyMMddHHmmssSSS');
        String MergeKey = formattedDatetime+'_LV';
        newUsr.LastName = 'ANONYMIZE_Merge_'+ MergeKey;
        newUsr.FirstName = 'ANONYMIZE_Merge_'+ MergeKey;
        String nickname='ANONYMIZE_Merge_'+MergeKey;
        newUsr.CommunityNickname = nickname.left(40);
        newUsr.Email =  'ANONYMIZE_Merge_'+MergeKey+'@louisvuitton.com';
        newUsr.MobilePhone = null;
        newUsr.Phone = null;
        newUsr.Username = newUsr.Email + (String.isBlank(suffixe) ? '' : '.' + suffixe);
        newUsr.TECH_Email__c = newUsr.Email.left(80);
        newUsr.TECH_MobilePhone__c = newUsr.Email.left(40); 
        newUsr.IsActive = false;
        newUsr.IsPortalEnabled=false;
        newUsr.Tracking_Identity_User__c = null;
        return newUsr;
    }
    public list<ACCOUNT> shareDataAccountFirstcase(Account original , Account master){
        List<Account> ListAccountUpdate=new List<Account>();
        string tmp= master.dreamID__c;
        master.dreamID__c= master.DreamIdMasterClient__c;
        master.DreamIdMasterClient__c=null;
        master.MasterClientSFID__c=null;
        master.ToDelete__c='';
        original.dreamID__c=tmp;
        original.DreamIdMasterClient__c=master.dreamID__c;
        original.MasterClientSFID__c=master.Id;
        original.ToDelete__c='1';
        original.Date_Identity__pc=null;
        finalChildAccountsIds.put(original.Id,original);
        ListAccountUpdate.add(original);
        ListAccountUpdate.add(master);
        return ListAccountUpdate;
    }


    // Method to generate a unique datetime
    public static Datetime generateUniqueDatetime() {
        Datetime uniqueDatetime = Datetime.now();

        // Check if the generated datetime is already in use
        while (isDatetimeInUse(uniqueDatetime)) {
            // If duplicate, modify the datetime and check again
            uniqueDatetime = uniqueDatetime.addSeconds(1);
        }
        return uniqueDatetime;
    }

    // Method to check if the datetime is already in use
    private static Boolean isDatetimeInUse(Datetime checkDatetime) {
        // Perform logic to check if the datetime is already in use
        
        return existingDatetime.contains(checkDatetime);
    }
    
    
}