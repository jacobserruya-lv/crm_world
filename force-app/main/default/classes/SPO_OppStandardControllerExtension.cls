public class SPO_OppStandardControllerExtension {
	private final Opportunity order;
    Public Boolean actionIsDone { get; set; }


    public SPO_OppStandardControllerExtension(ApexPages.StandardController stdController) {
        this.order = (Opportunity)stdController.getRecord();
        actionIsDone = false;
    }
    
    public PageReference duplicateOrder(){
        Boolean isEcoOrder = false;
        String originalEcoNumber;
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNames = fieldMap.keySet();
        String soqlQuery =
                ' SELECT ' + String.join(new List<String>(fieldNames), ',') + ' FROM Opportunity Where Id =\'' +
                order.Id + '\' Limit 1';
        Opportunity opp = Database.query(soqlQuery);
        if (opp.ApplicationSource__c == 'ECO'){
            isEcoOrder = true;
            originalEcoNumber = opp.ECO_OrderNumber__c ;
            opp.ECO_OrderNumber__c  += '_original' ;
            update opp;
        }
        Opportunity newRecord = opp.clone(false);
        //newRecord.StageName = 'Production to be launched';
        newRecord.StageName = 'Creation in progress';
        newRecord.Is_Dup__c = true;
        newRecord.OrderNumber__c = null;
            if(opp.ApplicationSource__c == 'ECO'){
                newRecord.ECO_OrderNumber__c = originalEcoNumber;
            }else{
                newRecord.ECO_OrderNumber__c = null;
            } 
        if(newRecord.Name.indexOf('-') > -1) {
            newRecord.Name = newRecord.Name.substringAfter('-');
        }
		// set the deposit date to today's date. This way the delivery date on order line will recompute
		newRecord.SPO_DepositSentStatusDate__c = System.today();
        insert(newRecord);

        Map<String, Schema.SObjectField> fieldMapFirmOrder =
                SPO_FirmOrder__c.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNamesFirmOrder = fieldMapFirmOrder.keySet();
        String soqlQueryFirmOrder = ' SELECT ' + String.join(new List<String>(fieldNamesFirmOrder), ',') +
                ' FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = \'' + order.Id + '\'';
        List<SPO_FirmOrder__c> linesOrder = Database.query(soqlQueryFirmOrder);
        List<SPO_FirmOrder__c> lineOrderLists = new List<SPO_FirmOrder__c>();

        for (SPO_FirmOrder__c line: linesOrder) {
            SPO_FirmOrder__c newRecordline = line.clone(false);
            newRecordline.SPO_FirmOrderStatus__c = 'Creation in progress';
            if (newRecord.ApplicationSource__c == 'PERSO' || newRecord.ApplicationSource__c == 'ECO') {
                if (newRecordline.ApplicationTarget__c == 'FIESSO') {
                    newRecordline.SPO_TechETLStatus__c = 'S';
                }
                if (newRecordline.ApplicationTarget__c == 'JDE') {
                    newRecordline.SPO_TechETLStatus__c = 'A';
                }
                if (newRecordline.ApplicationTarget__c == 'SAP') {
                    newRecordline.SPO_TechETLStatus__c = 'PAP_SO';
                }
                if (newRecordline.ApplicationTarget__c == 'MYPR') {
                    newRecordline.SPO_TechETLStatus__c = 'STOCK';
                }
                if (!String.isBlank(newRecordline.Creation_Status__c)) {
                    newRecordline.Creation_Status__c = 'New Order';
                    newRecordline.SPO_TechETLStatus__c = null;
                } else {
                    newRecordline.Creation_Status__c = null;
                    newRecordline.SPO_TechETLStatus__c = 'V';
                }
            } else {
                newRecordline.Creation_Status__c = null;
                newRecordline.SPO_TechETLStatus__c = null;
            }

            newRecordline.SPO_FirmOrderStatus__c = 'Creation in progress';
            newRecordline.SPO_BriefName__c = newRecord.Id;
            newRecordline.FirmOrderNumber__c = null;
            newRecordline.DistributionStatus__c = null;
            newRecordline.MIY_ProductionStatus__c = null;
            newRecordline.MIY_ProductionStatusSimple__c = null;

            lineOrderLists.add(newRecordline);
        }

        insert(lineOrderLists);
        insertPdf(newRecord.Id);

        return new PageReference('/' + newRecord.Id);
    }

    @future(callout = true)
    public static void insertPdf(Id orderId) {
        OrderSettings__c orderSettings = OrderSettings__c.getInstance();
        Opportunity order = [SELECT Id, OrderNumber__c FROM Opportunity WHERE Id = :orderId];
        HttpRequest req = new HttpRequest();
        req.setEndpoint(orderSettings.MakeItYoursAppUrl__c + '/api/print/pdf/' + order.OrderNumber__c);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('instanceurl', Url.getOrgDomainUrl().toExternalForm());
        req.setTimeout(60000);//sets maximum timeout
        req.setMethod('GET');
        // Send the request, and return a response
        Http h = new Http();
        HttpResponse res = h.send(req);

        if (res.getStatusCode() == 200) { // if the response is ok
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Order to reprint';
            cv.PathOnClient = '/'+res.getHeader('Content-Disposition').substringAfter('filename=');
            cv.VersionData = res.getBodyAsBlob();
            insert cv;

            //Query Content Version to use its Id in Content Document Link
            List<ContentVersion> docs = [Select Id,ContentDocumentId, Title From ContentVersion where Id =:cv.Id];

            // Create a new content document link and link it to above Opportunity
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.LinkedEntityId = order.id;
            contentLink.ContentDocumentId = docs[0].ContentDocumentId;
            contentLink.ShareType = 'V';
            insert contentLink;
        }
    }

/*
    public Void reportActions(){

        String actionName = apexpages.currentpage().getparameters().get('actionName');

        if (actionName == 'recivedInStore') {
            system.debug('In reciving with '+order.Id);
            List<Opportunity> Opp = SPO_OpportunityActionButtonController.updateFirmOrderDB(order.Id);
            if(Opp.size() > 1) {
                actionIsDone = true;
            }
        }else if(actionName == 'cancelOrder') {
            SPO_FirmOrderControllerLC.cancelFirmOrderDB(order.Id,'', null, null);
        }else if(actionName == 'deliverToClient') {

        }
    }
*/
}