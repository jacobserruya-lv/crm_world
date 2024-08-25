public class BL_ICON_Transactions_Helper {
    public static Object getAllClientDetails(String clientId, Date endRangeDate,BL_UserInfo me){
        String employeeNumber = me.basicInfos.EmployeeNumber;
        Datetime endRangeDatetime = endRangeDate;
        Datetime endRangeDatetime30 = endRangeDate != null ? endRangeDate.addDays(30):null;
        String formatedDt = endRangeDatetime!= null ? endRangeDatetime.format('yyyy-MM-dd'):null;
        String formatedDt30 = endRangeDatetime30!= null ? endRangeDatetime30.format('yyyy-MM-dd'):null;
        List<AggregateResult> aggregateResults = new BL_EasyQuery()
            .objectName('PPR_PurchProduct__c')
            .fields(new String[]{'MAX(Id) transactionId','PurchasedDate__c transactionPurchasedDate','CurrencyCode__c transactionCurrency','StoreRetailCode__c StoreRetailCode','tolabel(Store__c) transactionStore','TransactionRMSId__c TransactionRMSId','MAX(CAName__c) caName','SUM(Amount__c) salesAmount','SUM(ConvertedAmountEUR__c) salesAmountEUR','SUM(ConvertedAmountUSD__c) salesAmountUSD','SUM(ConvertedAmountYEN__c) salesAmountYEN','SUM(ConvertedAmountYUAN__c) salesAmountYUAN'})
            .condition('Client__c =  \''+ clientId + '\'')
            .addCondition((endRangeDate)!=null ? 'PurchasedDate__c <'+ formatedDt30 + ' AND PurchasedDate__c >= '+ formatedDt : null)
            .addCondition('(WWEmployeeNumber__c =  \''+ employeeNumber + '\' OR WWEmployeeNumber__c = \''+ '' + '\') GROUP BY StoreRetailCode__c,CurrencyCode__c, TransactionRMSId__c,Store__c,PurchasedDate__c HAVING SUM(Amount__c) >= 0')
            .orderBy('PurchasedDate__c desc ,Store__c Asc')
            .limitCount(100)
            .executeQuery()
            .getSObjects();
        return aggregateResults; 
    }

    public static Object getAllValidTransactions(String eventId,String clientId, BL_UserInfo me){
        String employeeNumber = me.basicInfos.WWEmployeeNumber__c;
        Event apt;
        List<Event> apts = [SELECT ID, StartDateTime, ActivityDate, CreatedDate, WhatId, OwnerId From Event Where Id = : eventId AND WhatId =: clientId];
        if (apts.size() > 0) {
            apt = apts[0];
            List<User> owner = [Select WWEmployeeNumber__c from User where ID =:apt.OwnerId];
            employeeNumber = owner.size() > 0  && String.isNotBlank(owner[0].WWEmployeeNumber__c)? owner[0].WWEmployeeNumber__c : employeeNumber;
        } else {
            if(Test.isRunningTest()){
                return new list<Object>();
            }
            throw new BL_Exceptions.RouterException('Event ID NOT FOUND OR MISSING');
        }

        Datetime endRangeDatetime = apt.StartDateTime;
        Datetime endRangeDatetime30 = endRangeDatetime != null ? endRangeDatetime.addDays(30):null;
        String formatedDt = endRangeDatetime!= null ? endRangeDatetime.formatGmt('yyyy-MM-dd'):null;
        String formatedDt30 = endRangeDatetime30!= null ? endRangeDatetime30.formatGmt('yyyy-MM-dd'):null;
        List<AggregateResult> aggregateResults = new BL_EasyQuery()
            .objectName('PPR_PurchProduct__c')
            .fields(new String[]{'MAX(Id) transactionId','PurchasedDate__c transactionPurchasedDate','MAX(PurchaseDateTime__c) transactionPurchasedDateTime','CurrencyCode__c transactionCurrency','StoreRetailCode__c StoreRetailCode','tolabel(Store__c) transactionStore','TransactionRMSId__c TransactionRMSId','MAX(CAName__c) caName','SUM(Amount__c) salesAmount','SUM(ConvertedAmountEUR__c) salesAmountEUR','SUM(ConvertedAmountUSD__c) salesAmountUSD','SUM(ConvertedAmountYEN__c) salesAmountYEN','SUM(ConvertedAmountYUAN__c) salesAmountYUAN','MAX(Name) nameField','MAX(Image_Url__c) imageUrl'})
            .condition('Client__c =  \''+ apt.WhatId + '\'')
            .addCondition((formatedDt)!=null ? 'PurchasedDate__c <'+ formatedDt30 + ' AND PurchasedDate__c >= '+ formatedDt : null)
            .addCondition('(WWEmployeeNumber__c =  \''+ employeeNumber + '\' OR WWEmployeeNumber__c = \''+ '' + '\') GROUP BY StoreRetailCode__c,CurrencyCode__c, TransactionRMSId__c,Store__c,PurchasedDate__c HAVING SUM(Amount__c) >= 0')
            .orderBy('PurchasedDate__c desc ,Store__c Asc')
            .limitCount(100)
            .executeQuery()
            .getSObjects();
        
        if(aggregateResults.size() == 0){
            return aggregateResults;
        }
        Set<String> ticketnumbers =new Set<String>();
        Set<String> storeCodes =new Set<String>();
        for(AggregateResult agg : aggregateResults){
            ticketnumbers.add((String) agg.get('TransactionRMSId'));
            storeCodes.add((String) agg.get('StoreRetailCode'));
        }

        
        List<String> linkedTickets = checkEventTransaction(eventId, new List<String>(ticketnumbers));
        List<Map<String,Object>> results = new List<Map<String, Object>>();
        List<Map<String,Object>> aggregateResultsMap = BL_ICON_Utils.getAggregateResultAsMap(aggregateResults);
        for(Map<String,Object> agg : aggregateResultsMap){
            if ( !linkedTickets.contains(((String) agg.get('TransactionRMSId')))){
                agg.put('valid', true);
                results.add(agg);
            }
        }
        if(apt.CreatedDate.date() == apt.ActivityDate){
            List<Store__c> stores =  (List<Store__c>) new BL_EasyQuery()
            .objectname('Store__c')
            .fields(new list<String>{'RetailStoreId__c','Time_Zone_Id__c'})
            .condition( 'RetailStoreId__c  ' +  BL_ICON_Utils.buildMultiChoiceFilterFromList(new List<String>(storeCodes)) )
            .executeQuery()
            .getSObjects();
    
            Map<String, SObject> storeMap = BL_Utils.createMapFromSObject(stores, 'RetailStoreId__c');
            for(Map<String, Object> ppr : results){
                String timezoneId = ppr.get('StoreRetailCode')!= null && storeMap.get((String) ppr.get('StoreRetailCode'))!= null && ((Store__c) storeMap.get((String) ppr.get('StoreRetailCode'))).Time_Zone_Id__c != null ?
                ((Store__c) storeMap.get((String) ppr.get('StoreRetailCode'))).Time_Zone_Id__c :
                (String)me.extendInfos.get('timeZoneId');
                ppr.put('gmtStartDatetimeEvent', apt.StartDatetime);
                Datetime gmtPurchaseDatetime = getStoreGMTTime(timezoneId,Datetime.valueOfGMT(((String)ppr.get('transactionPurchasedDateTime')).replace('.000+0000','.000Z').replace('T', ' ').replace('.000Z', '')));
                ppr.put('gmtPurchaseDatetime', gmtPurchaseDatetime);

                if( apt.StartDatetime > gmtPurchaseDatetime){
                    ppr.put('valid', false);

                }
            }
        }
        return results; 
    }


    public static List<String> checkEventTransaction(string id,list<String> relatedTickets){
        List<Event> eventsLinked =  (List<Event> ) new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)     
            .condition('id != \'' + id + '\' AND (' + getQueryOr(relatedTickets)+')')
            .executeQuery()
            .getSObjects();
        Set<String> linkedTickets = new Set<String>();
        for(Event ev: eventsLinked){
            linkedTickets.add(ev.RelatedTicketNumber__c);
        }
        return new List<String>(linkedTickets);
    }
    static public String getQueryOr (list<String> relatedTickets){
        String  queryId = '';
        Integer i = 0;
        for(String item :relatedTickets){
            if(i == 0){
                i++;
                queryId += ' RelatedTicketNumber__c  like \'%' + item + '%\'';
            }
            else
                queryId += ' OR RelatedTicketNumber__c like \'%' + item + '%\'';
        }
        return queryId;
    }

    public static Datetime getStoreGMTTime (String timeZoneId , Datetime d){
        if(String.isNotEmpty(timeZoneId) && d != null){
            Timezone tz = Timezone.getTimeZone(timeZoneId);
            return d.addSeconds(-tz.getOffset(d)/1000);
        }
        return null;
    }

}