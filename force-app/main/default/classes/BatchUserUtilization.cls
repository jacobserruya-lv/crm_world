/*
BW - 28/05/2019
Create records in the object Utilisation with the statistics of utilization during the n previous days (backward)
before the endDate at the global level (country = '') or per country.

Counters, requests, other parameters are defined in the metadata User_utilization_setting__mdt.
Countries, management levels, zones are defined in the metadata User_country__mdt.
This list should be the same than the picklist in the field user.Country__c.

All stats by country or at the global level are recorded in the object Utilisation / Utilization_report_line__c.
If a record exists at the same end date for the same number of days backward, for the same country (or no country),
the record is updated.
The batch should run with size one (one country per one country)

To calculate the utilization for all countries (one record per country + the global counters):
DateTime endDateTime = DateTime.newInstance(2020, 04, 20, 21, 0, 0);
BatchUserUtilization cl = new BatchUserUtilization(endDateTime, 28, '', '');
Id batchInstanceId = Database.executeBatch(cl, 8);

To calculate the utilization at the global level only :
BatchUserUtilization cl = new BatchUserUtilization(endDateTime, 28, 'WW', '');
Id batchInstanceId = Database.executeBatch(cl, 1);

To calculate the utilization for one specific country :
BatchUserUtilization cl = new BatchUserUtilization(endDateTime, 28, 'FRA', '');
Id batchInstanceId = Database.executeBatch(cl, 1);
*/

global without sharing class BatchUserUtilization implements Database.Batchable<sObject> {

    public final String myQuery;
    public final DateTime myEndDate;
    public final Integer myBackward;
    public final String myCountry;
    public final String myStat;

    // Constructor
    global BatchUserUtilization (DateTime endDate, Integer backward, String country, String stat) {
        myEndDate = endDate;
        myBackward = backward;
        myStat = stat.trim();
        myCountry = (String.isBlank(country) ? '' : country).trim().toUpperCase();
        // Get countries
        if (myCountry == '')
            // For all countries : Query returns all the countries
            myQuery = 'select Id, Name, Case__c, StoreOrUser__c, Zone__r.Name, Iso3Code__c from Country__c where User_country__c = true order by name';
        else if (myCountry == 'WW') 
            // World wide : Query doesn't return any record. Ah Ah !
            myQuery = 'select Id, Name, Case__c, StoreOrUser__c, Zone__r.Name, Iso3Code__c from Country__c where Iso3Code__c = \'WW\' and User_country__c = true order by name';
        else
            // For one country : Query return one country
            myQuery = 'select Id, Name, Case__c, StoreOrUser__c, Zone__r.Name, Iso3Code__c from Country__c where Iso3Code__c = \'' + myCountry + '\' and User_country__c = true order by name';
    } 

    global List<sObject> start(Database.BatchableContext BC){
        List<Country__c> l = Database.query(myQuery);
        // it calculates the global counters if WW or for all countries independantly of the batch chunks!
        if (myCountry == 'WW' || myCountry == '') BatchUserUtilization.getStats(myEndDate, myBackward, null, myStat);
        return l;
    }

    global void execute(Database.BatchableContext info, List<sObject> scope){
        for (sObject so : scope) {
            Country__c userCountry = (Country__c)so;
            BatchUserUtilization.getStats(myEndDate, myBackward, userCountry, myStat);
        }        
    }

    public static void getStats(DateTime endDate, Integer backward, Country__c country, String stat) {
        Integer duration = (backward == null ? 28 : backward);
        endDate = endDate != null ? endDate : System.now();
        DateTime startDate = endDate.addDays(-duration);
        Date myDate = Date.valueOf(endDate);
        Map<String, User_utilization_setting__mdt> settings = new Map<String, User_utilization_setting__mdt>();
        User_utilization_setting__mdt setting;
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Utilization_report_line__c.Fields.getMap();
        String iso3 = (country ==  null ? '' : country.Iso3Code__c);

        // Date range
        String createdDateSearch = 'CreatedDate > :startDate and CreatedDate <= :endDate';
        String updatedDateSearch = 'LastModifiedDate > :startDate and LastModifiedDate <= :endDate';

        // Search for an existing record in Utilization_report_line__c at the same date, with the same duration, for the same country
        String s = myDate.year() + '-' + String.valueof(myDate.month()).leftPad(2,'0') + '-' + String.valueOf(myDate.day()).leftPad(2,'0');
        String q = getQueryWithAllFields('Utilization_report_line__c', 'Date__c = ' + s + ' AND Backward__c = ' + duration + ' AND Iso3_code__c = \'' + iso3 + '\' limit 1');
        List <Utilization_report_line__c> utilizations = Database.query(q);

        // Create the utilization record if doesn't exist
        Utilization_report_line__c utilization;
        Boolean found = false;
        if (utilizations.isEmpty()) {
            String myName = myDate.year() + '-' + String.valueOf(myDate.month()).leftPad(2,'0') + '-' + String.valueOf(myDate.day()).leftPad(2,'0') + ' - ' + duration + ' last days';
            utilization = new Utilization_report_line__c(Name=myName, Date__c = Date.valueOf(endDate), Backward__c = duration, Country__c = (Country != null ? country.Name : ''), Iso3_code__c = iso3);
            utilization.Zone__c = country != null && !String.isBlank(country.Zone__c) ? country.Zone__r.Name : '';
        }
        else {
            utilization = utilizations[0];
            found = true;
        }

        // Get all stats settings
        q = 'select Label, Query__c, Count_type__c, Specific__c, Per_day__c, Field_to_update__c, Country_link__c, Country_format__c from User_utilization_setting__mdt where Deactivated__c = false';
        q += (stat != '' ? ' and Label = \'' + stat + '\'' : '');
        for(User_utilization_setting__mdt mySetting : Database.query(q)) {
            settings.put(mySetting.Label, mySetting);
        }
        if (settings.isEmpty()) return;

        // Standard KPIs
        for (User_utilization_setting__mdt mySetting : settings.values()) {
            if (mySetting.Specific__c) continue;
            String createdOrUpdated = mySetting.Count_type__c.trim().toLowerCase();
            string dateSearch = createdOrUpdated == 'created' ? createdDateSearch : (createdOrUpdated == 'updated'  ? updatedDateSearch : '');
            q = getQuery(mySetting, country, dateSearch);
            if (q != '') {
                Integer n = Database.countQuery(q);
                Integer nbDec = fieldMap.get(mySetting.Field_to_update__c).getDescribe().getScale();
                Decimal d = 0;
                if (mySetting.Per_day__c && duration > 0) {
                    if (nbDec == 0) {
                        n = n / duration;
                        utilization.put(mySetting.Field_to_update__c, n);
                    }
                    else {
                        d = ((Decimal)n / (Decimal)Duration);
                        utilization.put(mySetting.Field_to_update__c, d);
                    }
                }
                else utilization.put(mySetting.Field_to_update__c, n);
            }
        }

        // Is our new utilization record the most recent ?
        if (!found) {
            List<Utilization_report_line__c> lu = [select Id, Date__c, Last__c from Utilization_report_line__c WHERE Last__c = true AND Backward__c = :duration AND Iso3_code__c = :iso3];
            Boolean last = true;
            for (Utilization_report_line__c u : lu) {
                if (u.Date__c < myDate) {
                    u.Last__c = false;
                    update u;
                }
                else last = false;
            }
            if (last) utilization.Last__c = true;
        }
        if (found) update utilization; else insert utilization;
    }

    // Build the query from the parameters in settings
    private static String getQuery(User_utilization_setting__mdt setting, Country__c country, String dateSearch) {
        String q = setting.Query__c;
        Boolean condExists = q.indexOfIgnoreCase('where') >= 0 ? true : false;
        if (dateSearch != '') {
            q += (condExists ? ' AND ' : ' WHERE ') + dateSearch;
            condExists = true;
        }

        if (country != null) {
            if (string.isBlank(setting.Country_link__c))
                q = '';
            else
                q += (condExists ? ' AND ' : ' WHERE ') + setting.Country_link__c + ' = \'' + country.get(setting.Country_format__c) + '\'';
        }
        return q ;
    }

    // Build a query with all updatable fields
    private static string getQueryWithAllFields(String objectName, String whereClause){         
        String selects = '';         
        if (String.isBlank(whereClause)) return null;
         
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()) { 
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isCreateable()) selectFields.add(fd.getName());
            }
        }
        else return '';
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}             
        }
        else return '';         

        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    }

    global void finish(Database.BatchableContext info){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :info.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string[] toAddresses = new string[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('The calculation of use stats is finished');
        mail.setPlainTextBody ('The batch about use stats ended with ' + a.NumberOfErrors + ' error(s).');
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}