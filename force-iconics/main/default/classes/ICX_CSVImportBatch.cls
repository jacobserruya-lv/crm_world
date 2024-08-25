public class ICX_CSVImportBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    String strStatefulError = '';
    List<Case> clListParam = new List<Case>();
    Set<String> dreamIdLocal = new Set<String>();

    public ICX_CSVImportBatch(List<Case> clList, Set<String> dreamId) {        
        clListParam = clList;
        dreamIdLocal = dreamId;
    }

    public List<Case> start(Database.BatchableContext BC) {
        return clListParam;
    } 

    public void execute(Database.BatchableContext BC, List<Case> clListParam) {
        Database.SaveResult[] saveResultList = Database.insert(clListParam, false);
        System.debug('saveResultList' + saveResultList);
        
        //temp vars used to serialize data for the xls file
        string tempAddStar = String.join( saveResultList, '*');
        List<String> tempSplitStar = tempAddStar.split('\\*');
        
        for (String var : tempSplitStar) {
            if(var != null)
            strStatefulError += var;
            strStatefulError += '*';
        }
        }

    public void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
      
        //Set email of sender
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'concierge@contact.louisvuitton.com'];

        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Dpca import: ' + a.Status);
        // mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
        mail.setPlainTextBody('records processed ' + a.TotalJobItems);
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

        System.debug('ICX_CSVImportBatch--strStatefulError: ' + strStatefulError);
        List<String> resLst = strStatefulError.split('\\*');
        list<String> dreamIdLocalList = new list<String>();
        
        for (String var : dreamIdLocal) {
            dreamIdLocalList.add(var);
        }

        for (integer i = 0; i < resLst.size(); i++) {            
            String addErrorStr = resLst[i];
            resLst[i] = dreamIdLocalList[i] + ', ' + addErrorStr;
        }

        System.debug('ICX_CSVImportBatch--resLst' + resLst);
        String result = String.join( resLst, '\n');
        attachment.setBody(Blob.valueOf(result));
        // attachment.setFileName( 'getTable.csv');
        attachment.setFileName( 'getTable.xls');
        
        mail.setFileAttachments(new Messaging.EmailFileattachment[]{attachment});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}