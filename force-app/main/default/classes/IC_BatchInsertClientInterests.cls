global class IC_BatchInsertClientInterests implements Database.Batchable<String> {
	
	String query;

	
	global IC_BatchInsertClientInterests() {
		query = 'select Id,Body,Description From Document WHERE Name Like \'interests%\' And (NOT Description  Like \'%Processed\') Order by CreatedDate desc';
		system.debug('###query = '+ query);
	}
	
	global Iterable<String> start(Database.BatchableContext BC) {
		List<Document> docs = [select Id,Body,Description From Document WHERE Name Like 'interest%' And (NOT Description  Like '%Processed') And (NOT Description  Like '%Processing') Order by CreatedDate asc LIMIT 1];
		system.debug('###docs = '+ docs);
        if(docs.size()>0){
            String allDocsString='';
            List<Document> docsToUpdate = new List<Document>();
            for(Document doc :docs){
                doc.Description = 'Processing';
                docsToUpdate.add(doc);
                allDocsString += doc.body.toString() +'\n';
            }
            update docsToUpdate;
			Utility_RowIterator r = New Utility_RowIterator(allDocsString,'\n');
			return r;
		}
		return null;
	}

   	global void execute(Database.BatchableContext BC, List<String> scope) {
   		List<String> fieldHeaders = IC_Config__c.getInstance('InterestsFiledHeaders').Value__c.split(';');
   		if(scope.size()>0){
   			ParseFile(scope,'Interests__c',fieldHeaders);
   		}
   		
   		
	}
	
	global void finish(Database.BatchableContext BC) {
        List<Document> docs = [select Id From Document WHERE Name Like 'interest%' And (NOT Description  Like '%Processed') And (NOT Description  Like '%Processing') Order by CreatedDate asc LIMIT 1];
        if(docs.size()>0){
            IC_BatchInsertClientInterests toRun = new IC_BatchInsertClientInterests();
            Database.executebatch(toRun,200); 
        } else{
            List<Document> docsToupload = new List<Document>();
            List<Document> docsProcessing = [select Id,Description From Document WHERE Name Like 'interest%' And Description Like 'Processing'  Order by LastModifiedDate ];
            if(docsProcessing.size()>0){
                for(Document doc :docsProcessing){
                    doc.Description = 'Processed';
                    docsToupload.add(doc);
                }
                Database.update(docsToupload,false);
                IC_BatchInactiveInterests b = new IC_BatchInactiveInterests();
                database.executebatch(b,200);
            }
        }
	}

	public static void ParseFile(List<String> lines,String objName,List<String> fieldHeaders){ 

        Set<Interests__c> interestsSetToUpload = new Set<Interests__c>();
        List<Interests__c> interestsToUpload = new List<Interests__c>();
        Map<String,List<Interests__c>> interestsMap = new Map<String,List<Interests__c>>();

        try{
                for(String line : lines){
                    String[] inputvalues = new String[]{};
                    inputvalues = line.split(',');
                    if(fieldHeaders[0]!= inputvalues[0] && !isEmpty(inputvalues[0])){
                        Interests__c sObj = (Interests__c)UtilityParseFile.CsvParserToSObject(fieldHeaders,inputvalues,objName);
                        String dreamId = inputvalues[0].trim().replaceAll('\n','');
                        if(interestsMap.get(dreamId)==null){
                            interestsMap.put(dreamId,new List<Interests__c>());
                        }
                        interestsMap.get(dreamId).add(sObj);
                    }
                }
                if(interestsMap.keySet().size()>0){
                    Set<String> dreamIds = interestsMap.keySet();
                    List<Account> accounts = [select Id,DREAMID__c From Account Where DREAMID__c IN : dreamIds];
                    for(Account acc : accounts){
                        Integer i = 1;
                        for(Interests__c interest : interestsMap.get(acc.DREAMID__c)){
                            if(!isEmpty(interest.Categories__c)){
                                interest.TECH_ExtId__c = acc.DREAMID__c+interest.Categories__c;
                                interest.Client__c = acc.Id;
                                interest.Categories__c = interest.Categories__c.replaceAll('_',' ');
                                interest.isActive__c = TRUE;
                                interestsSetToUpload.add(interest);
                                i++;
                            }
                        }
                    }
                }
                if(interestsSetToUpload.size()>0){
                    interestsToUpload.addAll(interestsSetToUpload);
                    Schema.SObjectField f = Interests__c.Fields.TECH_ExtId__c;
                	Database.UpsertResult[] srList = Database.upsert(interestsToUpload,f,false);
                    // Iterate through each returned result
                    String csvErrorContent = 'Field,Error Message,Error Code\n';
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Interest ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                csvErrorContent += err.getFields()+','+err.getMessage()+','+err.getStatusCode()+'\n';
                            }
                        }
                    }
                    if(csvErrorContent.split('\n').size()>1){
                        sendEmailError(csvErrorContent);
                    }
                }
            }   
        catch(Exception e){
            system.debug('An error has occured reading the CSV file '+e.getMessage()+ ' '+e.getLineNumber());
        }       
    }

    public static Boolean isEmpty(String s){
        return (s == null || s == '' || s == '\n');
    }


    public static void sendEmailError(String csvBody){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();            
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('Interests_Errors_Update.csv');
            efa.setBody(Blob.valueOf(csvBody));
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            email.setSubject('Interests Upsert Errors');
            email.setToAddresses(new String[] {IC_Config__c.getInstance('InterestMail').Value__c});
            email.setHtmlBody(' ');
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
        }
	
	
}