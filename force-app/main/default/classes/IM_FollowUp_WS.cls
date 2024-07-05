/*
CreatedDate: 2017
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Get Follow up Data by User or team members
*/

@RestResource(urlMapping='/GetFollowUpObject')
global with sharing class IM_FollowUp_WS {
    /*=================================================================================================================*/ 
     
	@HttpPost
    global static void GetFollowUpObject(){
        RestRequest req = RestContext.request;
    	
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');

        Map<String,Object> body = new Map<String,Object>();
        if (req.requestBody != null) {
            body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        }
        res.statusCode= 200;
        try{
            Set<String>teamIdSet= new Set<String>();
            
            if(body.get('teamIds') == null || (String)body.get('teamIds') == ''){
            teamIdSet.add(UserInfo.getUserId());
            }
            else{
                String teamIds = (String)body.get('teamIds');
                teamIdSet = new Set<String>(teamIds.split(';'));
            }

            Boolean isTeamView = body.get('isTeamView') != null ? Boolean.valueOf(body.get('isTeamView')) : false;

            String days = (String)body.get('days');

            Set<String>contactedSet=new Set<String>();
            FollowUpObject followUpObject = new FollowUpObject();

            Datetime now = System.now();
            List<Event> appointments = Database.query('Select id, WhoId, Subject, StartDateTime,Owner.Name, OwnerId, EndDateTime,Owner.FirstName,Owner.LastName,'+
                            'AccountId, what.Name, Account.Name,'+
                            'Account.FirstName, Account.LastName,'+
                            'SaleAmount__c,Currency__c, RelatedTicketNumber__c, No_Transaction__c, Description,'+
                            'WhatId , What.FirstName ,What.LastName '+
                            'From Event '+
                            'WHERE RecordType.Name != \'Online Appointment\' AND ActivityDate != null  And StartDateTime != null AND ActivityDate = '+(days == 'week' ? 'THIS_WEEK' : 'THIS_MONTH')+' AND StartDateTime <= :now ' +
                                    'and OwnerId IN : teamIdSet '+
                                    'order by ActivityDate ASC');

            
            followUpObject.appointmentsToComeCount = Database.countQuery('Select COUNT()'+
                            'From Event '+
                            'WHERE RecordType.Name != \'Online Appointment\' and ActivityDate != null  And StartDateTime != null AND ActivityDate ='+(days == 'week' ? 'THIS_WEEK' : 'THIS_MONTH')+' AND StartDateTime > :now '+
                                    'and OwnerId IN : teamIdSet ');

            List<Task> tasks = Database.query('SELECT Owner.Name, AccountId, what.Name,Owner.FirstName,Owner.LastName,'+
                                           'Account.Name, Account.FirstName, Account.LastName,'+
                                           'ActivityDate,Description,Id,ReminderDateTime,Status,'+
                                           'Subject,WhatId, ActionType__c, IsWardrobing__c, Look__c, Look__r.Picture_URL__c '+
                                           'FROM Task '+
                                           'WHERE ActivityDate != null AND ActivityDate = '+(days == 'week' ? 'THIS_WEEK ' : 'THIS_MONTH ')+' AND ActivityDate <= TODAY '+
                                                 'and OwnerId IN : teamIdSet '+
                                                 'and RecordType.Name != \'DREAMContact\''+
                                                 'and (ActionType__c=\'Email\' OR ActionType__c=\'Phone\' OR ActionType__c=\'SMS\' OR ActionType__c=\'Mobile Chat\' OR ActionType__c=\'Postal Mail\'  OR ActionType__c=\'WhatsApp\' OR ActionType__c=\'Card\' OR ActionType__c=\'Social\' OR ActionType__c=\'Chat\' OR ActionType__c=\'Line, KakaoChat, WeChat\' OR ActionType__c=\'Other Messenger and Social Media apps\' OR ActionType__c=\'Other\') '+
                                                 'order by ActivityDate ASC');
            // Set Outreaches
            List<Outreach> outreaches = new List<Outreach>();
            followUpObject.appointmentsCount = appointments.size();
            for (Event appointment:appointments){
                Outreach outreach = new Outreach();

                // check if has purchase
                if(appointment.RelatedTicketNumber__c != null){
                    followUpObject.pprsRMSIDS.addAll(appointment.RelatedTicketNumber__c.split(';'));
                    outreach.withPurchase = true;
                    followUpObject.appointmentsWithPurchaseCount ++;
                }
                else{
                    outreach.withPurchase = false;
                }
                outreach.appointment = appointment;
                //contactedSet.add(appointment.WhatId);
                outreaches.add(outreach);
            }
            followUpObject.tasksCount = tasks.size();
            for (Task task:tasks){
                Outreach outreach = new Outreach();
                outreach.task = task;   
                contactedSet.add(task.WhatId); 
                if(task.IsWardrobing__c == true){
                    followUpObject.myWardrobingOutreachCount++;
                    outreach.isWardrobing = true;
                    
                }
                outreaches.add(outreach);
            }
            followUpObject.contactedIds = new List<String>(contactedSet);

            //Set Purchased Products List

            AggregateResult[] groupedPPRs = [
                SELECT SUM(Amount__c) sumAmount, CurrencyCode__c
                From PPR_PurchProduct__c Where TransactionRMSId__c IN :followUpObject.pprsRMSIDS GROUP BY CurrencyCode__c];
            for(AggregateResult ar : groupedPPRs){
                followUpObject.pprMapCurrency.put(String.valueOf(ar.get('CurrencyCode__c')), (Decimal) ar.get('sumAmount'));
            }
            
            if(isTeamView == false){
                
                List<PPR_PurchProduct__c> pprs = [SELECT id, SA__c, Name, Image_Url__c, Amount__c, Quantity__c,
                PurchasedDate__c, toLabel(Store__c), CurrencyCode__c, TECH_ConvertedAmount__c,
                ProductLine__c, CAName__c, SKU__c,TransactionRMSId__c,Client__r.FirstName, Client__r.LastName From PPR_PurchProduct__c Where TransactionRMSId__c IN :followUpObject.pprsRMSIDS  Order BY TransactionRMSId__c, PurchasedDate__c];

                followUpObject.appointmentsToCome = Database.query('Select id, WhoId, Subject, StartDateTime,Owner.Name, OwnerId, EndDateTime,Owner.FirstName,Owner.LastName,'+
                            'AccountId, what.Name, Account.Name,'+
                            'Account.FirstName, Account.LastName,'+
                            'SaleAmount__c,Currency__c, RelatedTicketNumber__c, No_Transaction__c, Description,'+
                            'WhatId , What.FirstName ,What.LastName '+
                            'From Event '+
                            'WHERE RecordType.Name != \'Online Appointment\' and ActivityDate != null  And StartDateTime != null AND ActivityDate ='+(days == 'week' ? 'THIS_WEEK' : 'THIS_MONTH')+' AND StartDateTime > :now '+
                                    'and OwnerId IN : teamIdSet '+
                                    'order by ActivityDate ASC');

                followUpObject.outreaches = outreaches;
                followUpObject.purchasedProducts = pprs;

                followUpObject.contactedClients = [Select Id, TECH_Last36MSpend__pc, Salutation, FirstName, LastName, Firstname2__pc, LastName2__pc, LastTrans__pc, Owner.FirstName, 
                                              Owner.LastName, OwnerId, Gender__pc, PersonHomePhone, PersonMobilePhone, Phone, PersonEmail, 
                                              Can_Be_Contacted_By_Email__pc, LastModifierStoreCountry__pc, Can_Be_Contacted_By_Mail__pc,
                                               Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, Last36MSpendEUR__pc, 
                                               Last36MSpendYUAN__pc, Last36MSpendUSD__pc, HistoricalSpendYUAN__pc, HistoricalSpendUSD__pc,
                                                HistoricalSpendEUR__pc, HistoricalSpendYEN__pc, Last36MSpendYEN__pc, PrimaryAddressLine1__pc, 
                                                PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryCity__pc, PrimaryZipCode__pc, PrimaryStateProvince__pc, 
                                                PrimaryCountry__pc, Segmentation__pc, DREAMID__c, toLabel(AttachedStore__pc), CAName__c, PassportNumber__pc,
                                                 Nationality__pc, PreferredLanguage__pc, LastContactDate__pc, IsProspect__pc, CreatedDate,
                                                  BirthdateDay__pc, BirthdateMonth__pc, BirthdateYear__pc, FirstTrans__pc, AnniversaryDay__pc,
                                                   AnniversaryMonth__pc, AnniversaryYear__pc, LastVoiceDate__pc, LastVoiceType__pc, Description,
                                                    LocalHomePhone__pc, LocalMobilePhone__pc, LocalWorkPhone__pc, MobilePhoneCountryCode__pc, 
                                                    TECH_PhoneCountryCode__pc, WorkPhoneCountryCode__pc,HomePhoneCountrycode__pc, PreferredContactChannel__pc, 
                                                    Title__pc, FlowerFlag__pc, ComplaintClosingDate__pc,Ind_10K__c,indic_10K_rank__c,
                                              (select Owner.FirstName,Owner.LastName,ActivityDate from tasks Where ActivityDate != null order by ActivityDate desc limit 1) , 
                                              (select Owner.FirstName,Owner.LastName,ActivityDate,StartDateTime, EndDateTime from events Where  ActivityDate != null And StartDateTime != null order by ActivityDate desc limit 1)  
                                       From Account 
                                       WHERE Id In : contactedSet];
            }
            
            List<User> userEmp = [Select WWEmployeeNumber__c from User where Id IN :teamIdSet];
            List<String> empNumbers = new List<String>();
            for(User u : userEmp){
                empNumbers.add(u.WWEmployeeNumber__c);
            }
            
            followUpObject.my10KContacted = [Select COUNT() From Account WHERE OwnerId In : teamIdSet AND ID In : contactedSet AND Ind_10K__c = '10K'  limit 200];
            followUpObject.myTotal10K = [Select COUNT() From Account WHERE OwnerId In : teamIdSet AND Ind_10K__c = '10K'  limit 200];

            followUpObject.myPotential10KContacted = [Select COUNT() From Account WHERE OwnerId In : teamIdSet AND  ID In : contactedSet AND Ind_10K__c = 'Potential 10K'  limit 200];
            followUpObject.myTotalPotential10K = [Select COUNT() From Account WHERE OwnerId In : teamIdSet AND Ind_10K__c = 'Potential 10K'  limit 200];

            followUpObject.myConfirmed10KContacted = [Select COUNT() From Account WHERE OwnerId In : teamIdSet AND ID In : contactedSet AND indic_10K_rank__c = '10k YTM'  limit 200];
            followUpObject.myTotalConfirmed10K = [Select COUNT() From Account WHERE OwnerId In : teamIdSet AND indic_10K_rank__c = '10k YTM'  limit 200];

            // Integer totalAppointmentYTD = [Select COUNT() From Event Where OwnerId IN : teamIdSet AND
            //  ActivityDate = THIS_YEAR AND StartDateTime < :System.now()];
            // Integer totalAppointmentWithPurchaseYTD = [Select COUNT() From Event Where OwnerId IN : teamIdSet AND
            //  ActivityDate = THIS_YEAR AND StartDateTime < :System.now() AND RelatedTicketNumber__c != null AND SaleAmount__c > 0 ];
            // followUpObject.appointmentPurchaseYTD = totalAppointmentWithPurchaseYTD +' / '+totalAppointmentYTD;
            
            String response  = JSON.serialize(followUpObject);
           // UtilsLogs.addLog('ICON', 'IM_FollowUp_WS', JSON.serialize(body), JSON.serialize(req), response, '');
            res.responseBody = Blob.valueOf(response);

            new Logs.DEBUG('IM_FollowUp_WS','API',response);


        }
        catch(Exception ex){
            string error = ex.getMessage() + '\n\n' + ex.getLineNumber();
            res.responseBody = Blob.valueOf(JSON.serialize(error));
            res.statusCode = 400;
           // UtilsLogs.addLog('ICON', 'IM_FollowUp_WS', JSON.serialize(body), JSON.serialize(req),'', error);  

            new Logs.ERROR('IM_FollowUp_WS','API',ex);
        }
        
    }

    /*=================================================================================================================*/     
    global class Outreach{
    	Task task {get; set;}
    	Event appointment {get; set;}
        Boolean withPurchase {get; set;}
    	Boolean isWardrobing {get; set;}
    }

    /*=================================================================================================================*/     
    global class FollowUpObject{

        List<Event> appointmentsToCome {get;set;}
    	List<Outreach> outreaches {get; set;}
    	List<Account> contactedClients {get; set;}
        List<String> contactedIds {get;set;}
        List<PPR_PurchProduct__c> purchasedProducts {get; set;}
        Integer myWardrobingOutreachCount {get;set;}
        Integer my10KContacted {get;set;}
        Integer myTotal10K {get;set;}
        Integer myPotential10KContacted{get;set;}
        Integer myTotalPotential10K {get;set;}
        Integer myConfirmed10KContacted {get;set;}
        Integer myTotalConfirmed10K {get;set;}
        String appointmentPurchaseYTD {get;set;}
        Integer appointmentsToComeCount {get;set;}
        Integer appointmentsCount {get;set;}
        Integer appointmentsWithPurchaseCount {get;set;}
        Integer tasksCount {get;set;}
        Set<String> pprsRMSIDS {get;set;}
        Map<String, Decimal> pprMapCurrency {get; set;}

        public  FollowUpObject(){
        this.appointmentsToCome = new  List<Event>();
    	this.outreaches = new List<Outreach>();
    	this.contactedClients = new List<Account>();
        this.contactedIds = new List<String>();
        this.purchasedProducts = new List<PPR_PurchProduct__c>();
        this.myWardrobingOutreachCount = 0;
        this.my10KContacted = 0;
        this.myTotal10K = 0;
        this.myPotential10KContacted= 0;
        this.myTotalPotential10K = 0;
        this.myConfirmed10KContacted = 0;
        this.myTotalConfirmed10K = 0;
        this.appointmentPurchaseYTD = '';
        this.appointmentsToComeCount = 0;
        this.appointmentsCount = 0;
        this.appointmentsWithPurchaseCount = 0;
        this.tasksCount = 0;
        this.pprsRMSIDS = new Set<String>();
        this.pprMapCurrency = new Map<String, Decimal>();
         
        }
    }
}