global  class IM_BatchAppointmentTransactionSync implements Database.Batchable<sObject> {

       
    public String query;
    
    
    global IM_BatchAppointmentTransactionSync(){
        Integer LimitDate = 10;
        List<IconSetting__mdt> iconSettingsDatesToSync = [
            SELECT Text__c, Boolean__c
            FROM IconSetting__mdt 
            WHERE QualifiedApiName ='DatesToSyncApptTran'];

        String datesConditions = '';
        if(iconSettingsDatesToSync.size() > 0 && iconSettingsDatesToSync[0].Text__c != null ) {
            List<String> dates = iconSettingsDatesToSync[0].Text__c.split(';');
            String fromDate = dates[0];
            String toDate = dates[1];
            datesConditions = 'ActivityDate >= ' + fromDate + ' AND ActivityDate <= ' + toDate;
        }
        else {
            List<IconSetting__mdt> iconSettingsDefauldDays= [SELECT Text__c, Boolean__c
                                                             FROM IconSetting__mdt 
                                                             WHERE QualifiedApiName ='DefaultDaysToSyncApptTran'];
            if (iconSettingsDefauldDays.size() > 0 && iconSettingsDefauldDays[0].Text__c != null) {
                LimitDate = Integer.valueOf(iconSettingsDefauldDays[0].Text__c);
            }
            datesConditions = 'ActivityDate = LAST_N_DAYS:' + LimitDate  ;
        }
        query = ' SELECT Id, StartDateTime, SaleAmount__c, Sale__c, Attendance__c, Store_Location__c, RelatedTicketNumber__c,Purchased_Product__c,No_Transaction__c, ClientNoShow__c, OwnerId, WhatId, ActivityDate, TECH_Is_Transaction_Auto_Sync__c, CreatedDate '+
        ' FROM  Event Where RelatedTicketNumber__c = null AND No_Transaction__c = false AND Sale__c = false AND Attendance__c IN (\'Yes\', \'None\', null) AND (' + datesConditions + ')';
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IM_BatchAppointmentTransactionSync');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        try{
            if(scope.size() > 0){
                this.setTransactions((List<Event>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){
        Datetime sysTime = System.now();

       // this would increase the time to 1 hour after current time
        sysTime = sysTime.addHours(1);

        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		String strJobName = 'AppointmentTransactionSyncJOB-' + sysTime.getTime();
		// System.schedule(strJobName, chron_exp, new IM_SchedulerCareServiceStatusFlow());
    }

    private void setTransactions( List<Event> events){
        Set<String> ClientIds = getIdList(events,'WhatId');
        Set<String> ownerIds = getIdList(events,'OwnerId');
        Map<Id, User> ownersMap = new Map<Id, User>([Select ID,WWEmployeeNumber__c, TimeZoneSidKey from User Where Id IN: ownerIds]);
        List<AggregateResult> aggregateTransactions = [
            SELECT MAX(Id) transactionId,  Client__c clientId, TransactionRMSId__c rmsTicketId,CurrencyCode__c,
                PurchasedDate__c transactionPurchasedDate, SUM(Amount__c) salesAmount, SUM(ConvertedAmountEUR__c) salesAmountEUR,
                SUM(ConvertedAmountUSD__c) salesAmountUSD,SUM(ConvertedAmountYEN__c) salesAmountYEN,SUM(ConvertedAmountYUAN__c) salesAmountYUAN,
                WWEmployeeNumber__c wwwEmployee, MIN(PurchaseDateTime__c) purchaseDateTime
            FROM PPR_PurchProduct__c 
            WHERE Client__c  IN : ClientIds AND Amount__c >= 0
            GROUP BY Client__c, PurchasedDate__c, WWEmployeeNumber__c,TransactionRMSId__c, CurrencyCode__c 
            Order by PurchasedDate__c desc 
            limit 100
        ];

         system.debug('aggregateTransactions = ' + aggregateTransactions);
        Map<String, List<AggregateResult>> transactionMap = new Map<String, List<AggregateResult>>();

        for (AggregateResult aggregateTransaction : aggregateTransactions){
            String key = String.valueOf(aggregateTransaction.get('clientId')) +
            Date.valueOf(aggregateTransaction.get('transactionPurchasedDate')).format() +
            String.valueOf(aggregateTransaction.get('wwwEmployee'));
            System.debug('2key: ' + key);
            if( transactionMap.get(key) == null){
                transactionMap.put(key, new List<AggregateResult>());
            }
           transactionMap.get(key).add(aggregateTransaction);
        }
        System.debug('transactionMap: ' + transactionMap);
        Set<String> transactionIds = getIdList(aggregateTransactions,'transactionId');

        // ------
        List<string> linkedTransactions =  new List<string>();
        // ------


        List<Map<string, object>> purchasesListMap = new List<Map<string, object>>();
        Map<string, object> purchasesMap = new Map<string, object>();
        Map<string, object> purchasesMap2 = new Map<string, object>();
        List <PPR_PurchProduct__c> transactionsWithEvents = [
            Select Id ,PurchaseDateTime__c, SA__c,WWEmployeeNumber__c, PurchasedDate__c, Client__c, (Select Id from Events) 
            FROM PPR_PurchProduct__c 
            WHERE Id IN :transactionIds
        ];

        
         for(PPR_PurchProduct__c ppr : transactionsWithEvents){
             if ( ppr.Events.size() > 0){
                transactionMap.remove(ppr.Client__c + Date.valueOf(ppr.PurchasedDate__c).format() + ppr.WWEmployeeNumber__c);
             }
         }

        List<Event> eventsToUpdate = new List<Event>();
         for(Event event : Events){
             String key = event.WhatId + Date.valueOf(event.ActivityDate).format() + ownersMap.get(event.OwnerId).WWEmployeeNumber__c;

             List<AggregateResult> aggregateTransactionsList = transactionMap.get(key);

             Date shortCreatedDate = Date.newInstance(event.CreatedDate.year(), event.CreatedDate.month(), event.CreatedDate.day());
             Date shortStartDate = Date.newInstance(event.StartDateTime.year(), event.StartDateTime.month(), event.StartDateTime.day());
             Boolean apptCreatedBefore = shortCreatedDate < shortStartDate;

             if ( aggregateTransactionsList != null &&  aggregateTransactionsList.size() > 0){
             
                Boolean toUpdate = true;
                String CurrencyCode = String.valueOf(aggregateTransactionsList[0].get('CurrencyCode__c'));
                event.RelatedTicketNumber__c = null;
                event.SaleAmount__c = null;
                event.Transaction_Total_Converted_Amount_EUR__c = null;
                event.Transaction_Total_Converted_Amount_USD__c = null;
                event.Transaction_Total_Converted_Amount_YEN__c = null;
                event.Transaction_Total_Converted_Amount_YUAN__c = null;
                for( AggregateResult purchasesList : aggregateTransactionsList){

                    if( CurrencyCode == String.valueOf(purchasesList.get('CurrencyCode__c')) ){

                        Datetime now = event.StartDateTime;
                        Integer offset = Timezone.getTimeZone(ownersMap.get(event.OwnerId).TimeZoneSidKey).getOffset(now);
                        Datetime local = now.addSeconds(offset/1000);
                        if( (apptCreatedBefore || Datetime.valueOf(purchasesList.get('purchaseDateTime')) >= local ) && !linkedTransactions.contains((String)purchasesList.get('transactionId'))) {


                            event.RelatedTicketNumber__c =  event.RelatedTicketNumber__c != null ?     event.RelatedTicketNumber__c + ';' + String.valueOf(purchasesList.get('rmsTicketId')) :       String.valueOf(purchasesList.get('rmsTicketId'));

                            event.SaleAmount__c = event.SaleAmount__c != null?  event.SaleAmount__c + (Decimal) purchasesList.get('salesAmount') : (Decimal) purchasesList.get('salesAmount');
                            event.Transaction_Total_Converted_Amount_EUR__c = event.Transaction_Total_Converted_Amount_EUR__c != null?  event.Transaction_Total_Converted_Amount_EUR__c + (Decimal) purchasesList.get('salesAmountEUR') : (Decimal) purchasesList.get('salesAmountEUR');
                            event.Transaction_Total_Converted_Amount_USD__c = event.Transaction_Total_Converted_Amount_USD__c != null?  event.Transaction_Total_Converted_Amount_USD__c + (Decimal) purchasesList.get('salesAmountUSD') : (Decimal) purchasesList.get('salesAmountUSD');
                            event.Transaction_Total_Converted_Amount_YEN__c = event.Transaction_Total_Converted_Amount_YEN__c != null?  event.Transaction_Total_Converted_Amount_YEN__c + (Decimal) purchasesList.get('salesAmountYEN') : (Decimal) purchasesList.get('salesAmountYEN');
                            event.Transaction_Total_Converted_Amount_YUAN__c = event.Transaction_Total_Converted_Amount_YUAN__c != null?  event.Transaction_Total_Converted_Amount_YUAN__c + (Decimal) purchasesList.get('salesAmountYUAN') : (Decimal) purchasesList.get('salesAmountYUAN');
                            event.Sale__c = true;
                            event.Currency__c = String.valueOf(purchasesList.get('CurrencyCode__c'));
                            event.SendToOneClient__c = true;
                            event.TECH_Is_Transaction_Auto_Sync__c = true;
                            event.Attendance__c = 'Yes';
                            event.No_Transaction__c = false;
                            linkedTransactions.add((String)purchasesList.get('transactionId'));
                            system.debug(linkedTransactions);
                        }
                    } else{

                        toUpdate = false;
                    }


                }
                if (toUpdate == true ){
                    eventsToUpdate.add(event);
                }
             }
             
         }

         if ( eventsToUpdate.size() > 0 ){
             update eventsToUpdate;
         }
    }

    public static set<String> getIdList(List<Sobject> items, String fieldName)
    {
       Set<String> s = new Set<String>();
   
       for(Sobject ob : items)
       {
            s.add((string)ob.get(fieldName));
       }
       return s;         
    }
}