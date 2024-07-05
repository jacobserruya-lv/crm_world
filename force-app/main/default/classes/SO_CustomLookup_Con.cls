public class SO_CustomLookup_Con {

    public String labelFieldVar{ get; set; }
    public String valueFieldVar{ get; set; }
    public String sObjVal{get;set;}
    public Integer randomJsIden{get;set;}
    public Object cacheField{get;private set;} 
    
    private Object targetFieldVar;
    
    private static final String DELIMITER = ':';
    
    public SO_CustomLookup_Con(){
        randomJsIden = getRandomNumber(1000000);
        sObjVal='Account';
        labelFieldVar='Name';
        valueFieldVar='Id';
    }
    
    /*Dummy setter Method*/
    public void setCacheField(Object cacheField){}
    
    public void setTargetFieldVar(Object targetFieldVar){
        
        if(targetFieldVar != this.targetFieldVar){
            cacheField = getCacheFieldValue(targetFieldVar);
            this.targetFieldVar = targetFieldVar;
           
        }
        
    }
    
    public Object getTargetFieldVar(){
        return targetFieldVar;
    }
    
    private Object getCacheFieldValue(Object targetFieldVar){
        Object retVal = targetFieldVar;
        if(targetFieldVar!=null){
            for(sObject sObj : Database.query('SELECT SKUCode__c,'+valueFieldVar+','+labelFieldVar+' FROM '+sObjVal+' WHERE '+valueFieldVar+' =:targetFieldVar')){
                retVal = sObj.get(labelFieldVar) + ' ' + DELIMITER + ' ' + sObj.get('SKUCode__c');
                break;
            }
        }
        
        return retVal;
    }

    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }
    



    public static String nameOrSkuQueryString(String param)
    {
        String queryStr = '';
        //String delimiter = '-';
        List<String> paramList = new List<String>();
        //new List<String>();

        if(String.isBlank(param)){
            return queryStr;
        }

        paramList = param.split(DELIMITER);
        //System.debug('paramList size: ' + paramList.size());
        for(Integer i=0; i<paramList.Size();i++)
        {
            paramList[i] = paramList[i].trim();
        }

        if(param.indexOf(DELIMITER) == -1 || (param.indexOf(DELIMITER) > -1 && paramList.size() == 1) )
        {
            queryStr += ' Name LIKE \'%' + paramList[0] + '%\' OR SKUCode__c LIKE \'%' + paramList[0] + '%\'';
        }
        else if(param.indexOf(DELIMITER) > -1)
        {
            String skuQuery = '';
            String skuCode = '';
            String nameQuery = '';

            if(paramList.size() > 1)
            {
                //skuQuery += ' AND ( SKUCode__c LIKE \'%' + paramList[1] + '%\' ';
                //skuQuery += paramList[1];
                //skuCode += paramList[0];
                //nameQuery += paramList[1];
                //nameQuery += ' AND ( Name LIKE \'%' + paramList[1] + '%\' ';
                //List<String> nameQueryList = new List<String>();
                //for(Integer i = 1; i < paramList.size(); ++i)
                //{
                //    if(String.isNotBlank(paramList[i]))
                //    {
                //        //skuQuery += ' OR SKUCode__c LIKE \'%' + paramList[i] + '%\' ';
                //        skuQuery += DELIMITER + paramList[i];
                //        nameQueryList.add(' Name LIKE \'%' + paramList[i] + '%\' ');
                //    }

                //}
                //skuQuery += ' ) ';
                //if(!nameQueryList.isEmpty())
                //{
                //    nameQuery += ' AND ( ' + String.join(nameQueryList, ' OR ') + ') ';
                //}
                
                queryStr += ' (Name LIKE \'%' + paramList[0] + '%\' AND SKUCode__c LIKE \'%' + paramList[1] + '%\') OR (SKUCode__c LIKE \'%' + paramList[0] + '%\' AND Name Like \'%' + paramList[1] + '%\')';
            }
        }
        
        //System.debug('queryStr: ' + queryStr);
        return queryStr;
    }

    /*
    *This method queries data according to the passed parameters
    ***/
    @RemoteAction
    public static List<AutoCompleteData> getData(String sObjVal,String labelFieldVar,String valueFieldVar, String productCategory ,String param){
       
        List<AutoCompleteData> AutoCompleteDatas = new List<AutoCompleteData>();
        param = String.escapeSingleQuotes(param);

        //Boolean runAsSOQL = false;
        String  queryStr ='';

        //if(runAsSOQL)
        //{
        //    queryStr =  'SELECT '+valueFieldVar+','+labelFieldVar+',SKUCode__c' ;
        //    queryStr += ' FROM '+sObjVal ;
        //    queryStr += ' WHERE' ;
        //    queryStr += ' SKUCode__c != null';

        //    if(String.isNotBlank(productCategory))
        //    {

        //        queryStr += ' AND ProductCategory__c =: productCategory ';
        //    }
            

        //    if(String.isNotBlank(param))
        //    {
        //        queryStr += ' AND  (';
        //        queryStr += nameOrSkuQueryString(param);
        //        queryStr += ' )';
        //    }
        //    //queryStr += ' AND  (';

        //    ////if(paramList.size() == 1)
        //    ////{
        //    ////    queryStr += ' Name LIKE \'%' + paramList[0] + '%\' OR SKUCode__c LIKE \'%' + paramList[0] + '%\'';
        //    ////}
        //    ////if(paramList.size() >= 2)
        //    ////{
        //    ////    queryStr += ' Name LIKE \'%' + paramList[0] + '%\' ';
        //    ////    if(String.isNotBlank(paramList[1]))
        //    ////    {
        //    ////        queryStr += ' AND SKUCode__c LIKE \'%' + paramList[1] + '%\'';
        //    ////    }
        //    ////}

        //    //queryStr += ' )'; 
        //    queryStr += ' limit 20';
        //}
        //else
        //{
            //FIND {Watch 2* AND S4*} IN ALL FIELDS RETURNING ProductReferential__c (Id, Name, SKUCode__c)
            List<String> paramList = param.split(DELIMITER);
            for(Integer i = 0; i < paramList.size(); ++i)
            {
                paramList[i] = paramList[i].trim();
            }
            String findQuery = '';
            if( param.indexOf(DELIMITER) == -1 || (param.indexOf(DELIMITER) > -1 && paramList.size() == 1) )
            {
                findQuery = '\'' + paramList[0] + '*\'';
            }
            else if(param.indexOf(DELIMITER) > -1 && paramList.size() > 1)
            {
                findQuery = '\'' + paramList[0] + '* AND ' + paramList[1] + '*\'';
            }
            queryStr = 'FIND ' + findQuery + ' IN ALL FIELDS RETURNING ProductReferential__c (Id, Name, SKUCode__c WHERE ';
            queryStr += ' SKUCode__c != null';
            if(String.isNotBlank(productCategory))
            {
                queryStr += ' AND ProductCategory__c =: productCategory ';
            }
            queryStr += ' LIMIT 20)';
            //System.debug('getData - queryStr: ' + queryStr);
        //}

        try
        {
            List<sObject> sObjValList = new List<sObject>();
            //if(runAsSOQL)
            //{
            //    sObjValList = Database.query(queryStr);
            //}
            //else
            //{
                //List<List<SObject>>searchList=search.query(searchquery);
                List<List<SObject>> searchList = Search.query(queryStr);
                if(!searchList.isEmpty())
                {
                    sObjValList = searchList[0];
                }
            //}
            //Database.query(queryStr);
            for( Sobject sObj : sObjValList){
                AutoCompleteDatas.add(new AutoCompleteData(sObj.get(valueFieldVar),sObj.get(labelFieldVar) + ' ' + DELIMITER + ' ' + sObj.get('SKUCode__c') ));
            }
        }   
        catch(Exception e)
        {
            System.debug('SO_CustomLookup_Con - getData - ERROR: ' + e);
            AutoCompleteDatas = new List<AutoCompleteData>();
        }     

        return AutoCompleteDatas;
        
    }
    
    public class AutoCompleteData{
        public String id;
        public String text;
        
        public AutoCompleteData(Object id, Object text){
            this.id = String.valueOf(id);
            this.text = String.valueOf(text);
        }
    }

    
}