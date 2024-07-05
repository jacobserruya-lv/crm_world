/*
CreatedDate:  2017
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Get ClientLists
*/

@RestResource(urlMapping='/ClientList/*')
global with sharing class IM_ClientListWS {
    

    global static String accountSOQLFields(){
        return 'Select Id, Salutation, FirstName, LastName, Firstname2__pc, LastName2__pc, LastTrans__pc, Owner.FirstName, Owner.LastName, Owner.IsTechnicalUser__c,'+
        ' OwnerId, Gender__pc, PersonHomePhone, PersonMobilePhone, Phone, PersonEmail, Can_Be_Contacted_By_Email__pc, LastModifierStoreCountry__pc,'+
        ' Can_Be_Contacted_By_Mail__pc, Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, Last36MSpendEUR__pc, Last36MSpendYUAN__pc, Last36MSpendUSD__pc,'+
        ' HistoricalNbrProducts__pc, HistoricalSpendYUAN__pc, HistoricalSpendUSD__pc, HistoricalSpendEUR__pc, HistoricalSpendYEN__pc, Last36MSpendYEN__pc,'+
        ' PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryCity__pc, PrimaryZipCode__pc, PrimaryStateProvince__pc, PrimaryCountry__pc,'+
        ' Segmentation__pc, DREAMID__c, toLabel(AttachedStore__pc), CAName__c, PassportNumber__pc, Nationality__pc, PreferredLanguage__pc,'+
        ' LastContactDate__pc,LastAppointmentDate__pc, IsProspect__pc, CreatedDate, BirthdateDay__pc, BirthdateMonth__pc, BirthdateYear__pc,'+
        ' FirstTrans__pc, AnniversaryDay__pc, AnniversaryMonth__pc, AnniversaryYear__pc, LastVoiceDate__pc, LastVoiceType__pc, Description, LocalHomePhone__pc,'+
        ' LocalMobilePhone__pc, LocalWorkPhone__pc, MobilePhoneCountryCode__pc, TECH_PhoneCountryCode__pc, WorkPhoneCountryCode__pc,HomePhoneCountrycode__pc,'+
        ' PreferredContactChannel__pc, Title__pc, FlowerFlag__pc, ComplaintClosingDate__pc, Ind_10K__c, indic_10K_rank__c,TECH_UpcomingAnniversaryDate__pc,'+ 
        ' TECH_UpcomingWeddingDate__pc, TECH_UpcomingBirthdayDate__pc,' +
        ' (select Owner.FirstName,Owner.LastName,ActivityDate from tasks Where ActivityDate != null order by ActivityDate desc limit 1) ,'+
        ' (select Owner.FirstName,Owner.LastName,ActivityDate,StartDateTime, EndDateTime from events Where  ActivityDate != null And StartDateTime != null order by ActivityDate desc limit 1)';
    }

    @HttpGet
    global static void get() {

        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String clientListId = req.params.get('clientListId');
        Boolean isStoreList = req.params.get('isStoreList') != null ? Boolean.valueOf(req.params.get('isStoreList')) : false;

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        
        string response;

        try{
            if(service == ''){
                response = JSON.serialize(getServiceClientLists(isStoreList));
            }
            if(service == 'MyCR'){
                response = JSON.serialize(getMyCRClients(false));
            }
            if(service == 'MyStoreCR'){
                response = JSON.serialize(getMyCRClients(isStoreList));
            }
            
            res.responseBody = Blob.valueOf(response);
            UtilsLogs.addLog('ICON','IM_ClientListWS', JSON.serialize(req.params), '', response, '');
            
        }
        catch(Exception ex){
            string error = ex.getMessage() + '\n\n' + ex.getLineNumber();
            res.responseBody = Blob.valueOf(error);
            res.statusCode = 400;
            UtilsLogs.addLog('ICON', 'IM_ClientListWS', JSON.serialize(req.params), '','', error);  
        }
    }

    global static Map<String,List<Account>> getServiceClientLists(Boolean isStoreList){
        Map<String,List<Account>> CLMap = new Map<String,List<Account>>();
        CLMap.put('MyCR',getMyCRClients(false));
        CLMap.put('MyStoreCR',getMyCRClients(isStoreList));

        return CLMap;
    } 

    global static List<Account> getMyCRClients(Boolean isStoreList){
        String currentUserId = UserInfo.getUserId();
        String userStore = isStoreList ? getStoreUser() : null;
        String ownerCondition = isStoreList && userStore != null  ? ' Parent.Store__c = : userStore ' : 'MemberId = :currentUserId ' ; 
        String CTMSQuery = 'Select ParentId, Parent.AccountId From CaseTeamMember Where '+ownerCondition+' AND Parent.Status != \'Closed\'';
        List<CaseTeamMember> ctms = Database.query(CTMSQuery);

        List<String> caseIds = new List<String>();
        List<String> clientIds = new List<String>();
        for(CaseTeamMember ctm : ctms){
            caseIds.add(ctm.ParentId);
            clientIds.add(ctm.Parent.AccountId);
        }

        String query = accountSOQLFields() + ' , (SELECT Id, AccountId, Status, Subject, Description, CreatedDate, ClosedDate,InStoreOwner__c ,'+
        ' CaseNumber, RecordTypeId,OwnerId,Owner.FirstName,Owner.LastName from Cases where  ID IN :caseIds ) FROM '+
        ' Account Where ID IN :clientIds';

         return Database.query(query);
    }

       


    global static Boolean isEmpty(String s){
        return (s == null || s == '');
    }

    global static User getCurrentUser(){
        User u = [Select Id,DefaultStore__c From User Where Id=: UserInfo.getUserId()];
        return u;
    }

    global static String getStoreUser(){
        List<Store__c> store = [Select Id, Name, RetailStoreId__c From Store__c Where RetailStoreId__c = :getCurrentUser().DefaultStore__c];
        if(store.size() >0){
            return store[0].Id;
        }
        return null;
    }

    //Convert String 'aaa; jjjj; nnn;' to SF SOQL LIST ('aaa','jjjj','nnn')
    global static String getStringListConverted(String optionString){
        List<String> optionsList = optionString.split(';');
        String returnString= '(';

        for(String option : optionsList){
            returnString += '\''+option+'\',';
        }

        returnString = returnString.removeEnd(',');
        returnString += ')';

        return returnString;
    }


}