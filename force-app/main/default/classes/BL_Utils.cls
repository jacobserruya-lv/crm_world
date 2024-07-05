/**
 * 
 * @author Jeremy Martiano
 * @since March 2019
 * @description Class to contain basic utility methods 
 * @group General Utils
 */
public class  BL_Utils {
    
    public static String getEntityName(String id){
        Id objId = (Id) id;
        return objId.getSObjectType().getDescribe().getName();
    }
    //Method  to be removed
    static public void ThrowSampleException(){
        integer a = 1;
        integer b = 0;
        integer c = a/b;
    }

    public static set<String> getIdList(List<Sobject> items, String fieldName){
            Set<String> s = new Set<String>();

            for (Sobject ob : items)
                {
                    if(!s.contains((string)ob.get(fieldName)))
                        s.add((string)ob.get(fieldName));
                }
            return s;
        }

    public static String convertToString(List<String> stringList){
            if (stringList.size() > 0) {
                return '(\'' + String.join(stringList, '\',\'') + '\')';
            } else {
                return '()';
            }

        }


    public static String convertToString(Set<String> stringSet){
            if (stringSet.size() > 0) {
                List<String> stringList = new List<String>();
                stringList.addAll(stringSet);
                return '(\'' + String.join(stringList, '\',\'') + '\')';
            } else {
                return '()';
            }

        }

        public static String toString(Object obj){
            return '\'' + (String) obj + '\'';
        }

    //Convert a List to a Set
    public static Set<String> toSet(List<String> l)
    {
        Set<String> s = new Set<String>();
        s.addAll(l);
        return s;
    }
    public static List<String> toList(Set<String> l)
    {
        List<String> s = new List<String>();
        s.addAll(l);
        return s;
    }

    public static Object[] slice(Object[] ary, Integer first, Integer last) {
        Object[] res = ary.clone(), temp;
        Integer size = ary.size(),
            startIndex = Math.min(size, Math.max(-1, first<0? size+first: first)),
            endIndex = Math.min(size, Math.max(-1, last<0? size+last: last-1)),
            offset = Math.max(-1, endIndex-startIndex);
        temp = new Object[offset+1];
        for(Integer h = 0, i = startIndex, j = endIndex; i <= j; ) {
            temp[h++] = ary[i++];
        }
        res.clear();
        res.addAll(temp);
        return res;
    }
    
    public static List<Object> reverse(List<Object> input ) {
        List<Object> reversed = new List<Object>();

        for(Integer i = input.size() - 1; i >= 0; i--){
            reversed.add(input[i]);
        }

        return reversed;
    }


    //Sort sObjects (alt do this in dynamic soql if using soql based pagination)
    public static Map<String, Object> createMapFromSObject(List<Sobject> items, String keyField, String valueField)
    {
        Map<String, Object> retMap = new Map<String, Object>();
        for(sObject item : items){
            if(keyField !=null)
                retMap.put(String.valueOf(item.get(keyField)) , item.get(valueField));
        }
        return retMap;
    }
    //Sort sObjects (alt do this in dynamic soql if using soql based pagination)
    public static Map<String, SObject> createMapFromSObject(List<Sobject> items, String keyField)
    {
        Map<String, sObject> retMap = new Map<String, sObject>();
        for(sObject item : items){
            if(keyField !=null)
                retMap.put(String.valueOf(item.get(keyField)) , item);
        }
        return retMap;
    }

    //Sort sObjects (alt do this in dynamic soql if using soql based pagination)
    public static void orderList(List<Sobject> items, String sortField, String theOrder)
    {
        theOrder = theOrder.toLowerCase();  
       List<Sobject> resultList = new List<Sobject>();
   
        //Create a map that can be used for sorting 
       Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
       
       for(Sobject ob : items)
       {
            if(objectMap.get(ob.get(sortField)) == null)
            {
                objectMap.put(ob.get(sortField), new List<Sobject>()); 
            }
            objectMap.get(ob.get(sortField)).add(ob);
        }       
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
       
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
       
        //Apply the sorted values to the source list
        items.clear();
        if(theOrder == 'asc')
        {
            for(Sobject ob : resultList)
            {
                items.add(ob); 
            }
        }
        else if(theOrder == 'desc')
        {
            for(integer i = resultList.size()-1; i >= 0; i--)
            {
                items.add(resultList[i]);  
            }
        }
    }  
    
    /**** Math ****/
    public static Decimal round(decimal aNumber, integer places)
    {
        return aNumber.setScale(places,System.RoundingMode.HALF_UP);
    }

    /**** URL ****/
    public static String sfInstance {
        public get {
            if (sfInstance == null) {
                //
                // Possible Scenarios:
                //
                // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
                // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
                // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable
    
                // Split up the hostname using the period as a delimiter
                List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
                if (parts.size() == 3) sfInstance = parts[0];
                else if (parts.size() == 5) sfInstance = parts[1];
                else sfInstance = null;
            } return sfInstance;
        } private set;
    }
    
    // And you can then get the Salesforce base URL like this:
    public static String baseURL() 
    {
         return 'https://' + sfInstance + '.salesforce.com';
    }

    //GET REQUEST URI BASED ON BASE_ENDPOINT
    public static String requestURI(String basePath) {
        return RestContext.request.requestURI.substring(RestContext.request.requestURI.indexOf(basePath) + basePath.length()); 
    }

    // DEBUG LOGS - Create more Readable Debugs Logs
    public static void log(string title, object o) {
        system.debug(LoggingLevel.INFO,'\n### ' + title + ' ###\n' + o + '\n### END ###\n');
    }

    public static void logError(string message) {
        system.debug(LoggingLevel.ERROR,'\n### ' + message  + '\n### END ###\n');
    }

    public static string getCurrentOrgLimits(){

        string limits = '****CURRENT LIMITS****\n' +
                'CPU : ' + Limits.getCpuTime()+ ' Of ' + Limits.getLimitCpuTime() + '\n' +
                'FUTURES : ' + Limits.getFutureCalls()+ ' Of ' + Limits.getLimitFutureCalls() + '\n' +
                'AGGREGATE QUERIES : ' + Limits.getAggregateQueries() + ' Of ' + Limits.getLimitAggregateQueries()+ '\n' +
                'DML ROWS : ' + Limits.getDMLRows() + ' Of ' + Limits.getLimitDMLRows()+ '\n' +
                'DML STATEMENT : ' + Limits.getDMLStatements() + ' Of ' + Limits.getLimitDMLStatements() + '\n' +
                'QUERIES : ' + Limits.getQueries() + ' Of ' + Limits.getLimitQueries() + '\n' +
                'QUERY ROWS : ' + Limits.getQueryRows() + ' Of ' + Limits.getLimitQueryRows() + '\n' +
                'SOSL(SEARCH) : ' + Limits.getSoslQueries() + ' Of ' + Limits.getLimitSoslQueries() + '\n' +
                'HEAP SIZE : ' + Limits.getHeapSize() + ' Of ' + Limits.getLimitHeapSize() + '\n' +
                'MOBILE PUSH : ' + Limits.getMobilePushApexCalls() + ' Of ' + Limits.getLimitMobilePushApexCalls() + '\n';

    return limits;
    }

    public static String getOrgLimits(String limitName){
        //Only if Admin & Future method
        return '\n#####CURRENT ORG LIMITS#####\n'+
                'DailyApiRequests : ' + OrgLimits.getMap().get(limitName).getValue() +
                '\n#####\n';
    }
}