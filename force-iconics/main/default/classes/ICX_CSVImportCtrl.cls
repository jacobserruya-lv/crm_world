public with sharing class ICX_CSVImportCtrl {
    
        // Logic: Check country input
        // public static boolean containsAny(String toSearch, List<String> values){
        //     for (String i : values)
        //     {
        //             if (i == toSearch)
        //             {
        //                 return true;
        //             }
        //     }
        //     return false;
        // }

        public static list<String> resFileList = new list<String>();

        @AuraEnabled
        public static list<String> createDPCAPreupload(Id contentDocumentId){
            list<Case> caseInsertList = new list<Case>();
            Set<String> setDreamId = new Set<String> ();
            List<String> listCountry = new List<String> ();
            Set<String> setUserId = new Set<String> ();

            if(contentDocumentId != null) {
                Id dpcaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Digital Private CA').getRecordTypeId();   
                // Fetch File Data based on the basic of document id 
                ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
                //store rows
                list<String>  csvRecordsList = contentVersionObj.VersionData.toString().split('\r\n');
                System.debug('ICX_CSVImportCtrl--contentVersionObj.VersionData.toString()' + contentVersionObj.VersionData.toString());
                Integer j =0;

                list<String> checkInputedData = csvRecordsList[0].split(',');
                System.debug('ICX_CSVImportCtrl--csvRecordsList[0]' + csvRecordsList[0]);
                System.debug('ICX_CSVImportCtrl--checkInputedData' + checkInputedData);

                //First Line Format no yet implemented
                // if(checkInputedData[0] != 'Account.DREAMID__c'|| checkInputedData[1] != 'Country__c' || checkInputedData[2] != 'OwnerId')
                    // throw new DmlException('PLEASE RESPECT FIRST LINE FORMAT : Account.DREAMID__c,Country__c,OwnerId');

                for(Integer i = 1; i < csvRecordsList.size(); i++){
                    list<String> csvRowData = csvRecordsList[i].split(',');
                    System.debug('ICX_CSVImportCtrl--csvRowData' + csvRowData);
                    System.debug('ICX_CSVImportCtrl--csvRowData.size()' + csvRowData.size());
                    setDreamId.add(csvRowData[0]);
                    listCountry.add(csvRowData[1]);
                    //Check size here if size 3 ok if size 2 add current ownerid
                    if(csvRowData.size() == 2)
                    {
                        setUserId.add(UserInfo.getUserId());
                    }
                    else {  
                        setUserId.add(csvRowData[2]);
                    }
                    j++;
                }
                
                Map<String,Id> mapClientDreamId = new Map<String,Id> ();
                List<Account> lstAccount = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c in :setDreamId];
                List<String> listDreamIdFound = new list<String>();
                for (Account var : lstAccount) {
                    listDreamIdFound.add(var.DREAMID__c);
                }

                for (string varSet : setDreamId) {
                    Boolean isFound = false;
                    for (String varFound : listDreamIdFound) {
                        if(varSet == varFound)
                            isFound = true;
                    }
                    if(isFound == false)
                    {
                        resFileList.add(varSet + ' DREAM ID NOT FOUND ON SALESFORCE');
                        System.debug(varSet + ' DREAM ID NOT FOUND ON SALESFORCE');
                    }
                }

                //CHECK IF ACC HAS ALREADY A CASE
                List<id> accID = new List<id>();
                for (Account lstItem  : lstAccount) {
                    accID.add(lstItem.id);
                }
                List<Case> checkCaseForAcc = [select id, Account.DREAMID__c from case where accountId =: accID AND RecordType.name = 'Digital Private CA' AND Status != 'Not Interested'];

                System.debug('checkCaseForAcc' + checkCaseForAcc);

                Set<String> setDreamIdCase = new Set<String>();
                if(checkCaseForAcc.size() > 0)
                {
                    for (Case var : checkCaseForAcc) {
                        setDreamIdCase.add(var.Account.DREAMID__c);
                    }

                    for (String var : setDreamIdCase) {
                        resFileList.add(var + ' ACCOUNT ALREADY HAS AN ACTIVE DPCA REQUEST');
                    }
                }

                // Logic: Check country input
                // CHECK IF COUNTRY EXISTS ON PICKLIST
                // List<String> pickListValuesList= new List<String>();
                // Schema.DescribeFieldResult fieldResult = case.country__c.getDescribe();
                // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                // for( Schema.PicklistEntry pickListVal : ple){
                //     pickListValuesList.add(pickListVal.getValue());
                // }
                // for (String inputCountry : listCountry) {
                //     Boolean isErr = containsAny(inputCountry, pickListValuesList);    
                    // if(!isErr)
                    // throw new DmlException('SORRY, AT LEAST ONE COUNTRY DOEST NOT EXIST');
                // } 
                
                // Logic check OwnerId =>
                //ADD MORE FILTER where Profile.Name = 'Iconics'
                // Populate map from SOQL query
                // Map<ID, User> m = new Map<ID, User>([SELECT Id FROM User where Profile.Name = 'Iconics_SA' OR Profile.Name = 'Iconics_SA Manager' OR profile.Name = 'Iconics Corporate' OR Profile.Name = 'Iconics_SA' OR Profile.Name = 'ICONiCS_Corporate' OR Profile.Name = 'System Administrator']);
                // Boolean isErrUser = FALSE;
                // // After populating the map, iterate through the map entries
                // for (string idKey : setUserId) {
                //     System.debug('idKey USer' + idKey);
                //     User a = m.get(idKey);
                //     if(a == null)
                //     isErrUser = true;
                // }
                // if (isErrUser) 
                // throw new DmlException('SORRY, AT LEAST ONE USER ID NOT FOUND');

                System.debug('ICX_CSVImportCtrl--resFileList' + resFileList);
            }
            return resFileList;
            //Query for sync call
            // list<Case> lstDPCA = [select id,Status,Account.DREAMID__c,Account.Name,Country__c, Origin,RecordType.Name from Case where id in:caseInsertList];
            // return lstDPCA;    
        }

        @AuraEnabled
        public static list<Case> createDPCA(Id contentDocumentId){
            list<Case> caseInsertList = new list<Case>();
            Set<String> setDreamId = new Set<String> ();
            List<String> listCountry = new List<String> ();
            Set<String> setUserId = new Set<String> ();

            if(contentDocumentId != null) {
                Id dpcaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Digital Private CA').getRecordTypeId();   
                // Fetch File Data based on the basic of document id 
                ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
                //store rows
                list<String>  csvRecordsList = contentVersionObj.VersionData.toString().split('\r\n');
                System.debug('ICX_CSVImportCtrl--contentVersionObj.VersionData.toString()' + contentVersionObj.VersionData.toString());
                Integer j =0;

                list<String> checkInputedData = csvRecordsList[0].split(',');
                System.debug('ICX_CSVImportCtrl--checkInputedData' + checkInputedData);

                //First line format not implemented
                // if(checkInputedData[0] != 'Account.DREAMID__c'|| checkInputedData[1] != 'Country__c' || checkInputedData[2] != 'OwnerId')
                    // throw new DmlException('PLEASE RESPECT FIRST LINE FORMAT : Account.DREAMID__c,Country__c,OwnerId');

                for(Integer i = 1; i < csvRecordsList.size(); i++){
                    list<String> csvRowData = csvRecordsList[i].split(',');
                    setDreamId.add(csvRowData[0]);
                    listCountry.add(csvRowData[1]);

                    //Check size here if size 3 ok if size 2 add current ownerid
                    if(csvRowData.size() == 2)
                    {
                        setUserId.add(UserInfo.getUserId());
                    }
                    else {  
                        setUserId.add(csvRowData[2]);
                    }
                    j++;
                }
                
                Map<String,Id> mapClientDreamId = new Map<String,Id> ();
                List<Account> lstAccount = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c in :setDreamId];


                // Logic : DreamID already implemented for async
                // if(j != lstAccount.size() && !Test.isRunningTest())
                //     throw new DmlException('SORRY, AT LEAST ONE DREAM ID NOT FOUND ON SALESFORCE');
                // //CHECK IF ACC HAS ALREADY A CASE
                // List<id> accID = new List<id>();
                // for (Account lstItem  : lstAccount) {
                //     accID.add(lstItem.id);
                // }
                // List<Case> checkCaseForAcc = [select id from case where accountId =: accID];

                // if(checkCaseForAcc.size() > 0)
                // throw new DmlException('SORRY, AT LEAST ONE ACCOUNT ALREADY HAS A CASE');

                //MAP ID AND ACCID
                for(Account acc :lstAccount){
                    mapClientDreamId.put(acc.DREAMID__c, acc.Id);
                }

            //Sync WAY , Async logic is used now
            /*
            if(j<=0)
            {
            for(Integer i = 1; i < csvRecordsList.size(); i++){
                Case myCase = new Case();
                list<String> csvRowData = csvRecordsList[i].split(',');
                myCase.AccountId = mapClientDreamId.get(csvRowData[0]);
                myCase.Country__c = csvRowData[1];                   
                myCase.Origin = 'File Import'; 
                myCase.RecordTypeId = dpcaRecordTypeId;
                myCase.Status = 'New';


                //Check size here if size 3 ok if size 2 add current ownerid
                if(csvRowData.size() == 2)
                {
                    // setUserId.add(UserInfo.getUserId());
                    myCase.OwnerId = UserInfo.getUserId();
                }
                else {  
                    // setUserId.add(csvRowData[2]);
                    myCase.OwnerId = csvRowData[2];
                }

                // myCase.OwnerId = csvRowData[2];
                caseInsertList.add(myCase);
            }

            try{    
                if(!caseInsertList.isEmpty()) {
                    insert caseInsertList;
                }
            }
            catch (Exception ex) {
                throw new DmlException(ex.getMessage());
            }

            }
            */ 
            // ASYNC WAY

                if(!csvRecordsList.isEmpty() && csvRecordsList != null)
                {
                    List <Case> listTechToInsert = new List<Case>();
                    list<String> csvRowData = new list<String>();

                    for(Integer i = 1; i < csvRecordsList.size(); i++){
                        Case myCaseLocal = new Case();
                        csvRowData = csvRecordsList[i].split(',');
                        myCaseLocal.AccountId = mapClientDreamId.get(csvRowData[0]);
                        myCaseLocal.Country__c = csvRowData[1];
                        myCaseLocal.Origin = 'File Import'; 
                        myCaseLocal.RecordTypeId = dpcaRecordTypeId;
                        myCaseLocal.Status = 'New';

                        //Check size here if size 3 ok if size 2 add current ownerid
                        if(csvRowData.size() == 2)
                        {
                            myCaseLocal.OwnerId = UserInfo.getUserId();
                        }
                        else {  
                            myCaseLocal.OwnerId = csvRowData[2];
                        }
                        listTechToInsert.add(myCaseLocal);
                    }
                    ICX_CSVImportBatch apc1 = new ICX_CSVImportBatch(listTechToInsert, setDreamId);
                    Id jobId = Database.executeBatch(apc1, 70); 
                }
            }
            list<Case> lstDPCA = [select id,Status,Account.DREAMID__c,Account.Name,Country__c, Origin,RecordType.Name from Case where id in:caseInsertList];
            return lstDPCA;    
        }

    //    @AuraEnabled
    //     public static list<Video_Session_Member__c> createVideoSessionMember(Id contentDocumentId,Id videoSessionId){
    //         list<Video_Session_Member__c> videoSessionMemberInsertList = new list<Video_Session_Member__c>();
    //         Set<String> setDreamId = new Set<String> ();
    //         Set<Id> setAccountId = new Set<Id> ();
    //         if(contentDocumentId != null) {
    //             // Fetch File Data based on the basic of document id 
    //             ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
    //             // split the file data
    //             list<String> csvRecordsList = contentVersionObj.VersionData.toString().split('\r\n');
    //             for(Integer i = 1; i < csvRecordsList.size(); i++){
    //                 list<String> csvRowData = csvRecordsList[i].split(',');
    //                 setDreamId.add(csvRowData[0]);
                  
    //             }
              
    //             Map<String,Id> mapClientDreamId = new Map<String,Id> ();
                
    //             List<Account> lstAccount = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c in :setDreamId];
                
    //             for(Account acc :lstAccount){
    //                 mapClientDreamId.put(acc.DREAMID__c, acc.Id);                  
    //             }
    //             //existing VideoSessionMember List                   
    //             List<Video_Session_Member__c> lstVSM = [SELECT Id,Client__c FROM Video_Session_Member__c where Video_Session__c=:videoSessionId];
    //                 for(Video_Session_Member__c vsm : lstVSM){
    //                       setAccountId.add(vsm.Client__c);
    //                 }
    //             for(Integer i = 1; i < csvRecordsList.size(); i++){
                  
    //                 list<String> csvRowData = csvRecordsList[i].split(',');                     
    //                 System.debug('csvRowData====> '+csvRowData);

    //                 if(!setAccountId.contains(mapClientDreamId.get(csvRowData[0]))){
    //                 Video_Session_Member__c myVideoSessionMember = new Video_Session_Member__c();
    //                 myVideoSessionMember.Client__c = mapClientDreamId.get(csvRowData[0]);          
    //                 myVideoSessionMember.Video_Session__c =  videoSessionId;    
    //                 System.debug('myVideoSessionMember '+myVideoSessionMember);
    //                 videoSessionMemberInsertList.add(myVideoSessionMember);
    //             }
    //          }
    
    //             try{    
    //                 if(!videoSessionMemberInsertList.isEmpty()) {
    //                     insert videoSessionMemberInsertList;
    //                 }
    //            }catch (DmlException e) {
    //             System.debug('Error on Video Session Member import  ' + e.getMessage());
    //           } 
    //         }
    //         list<Video_Session_Member__c> lstVideoSessionMember = [select id,Name,Client__r.DREAMID__c,Client__r.Name from Video_Session_Member__c where id in:videoSessionMemberInsertList];
    //         return lstVideoSessionMember;    
    //     }
    }