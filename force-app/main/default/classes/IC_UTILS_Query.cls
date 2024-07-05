/**
    About
    -----
    Description: Shared utilities for Query
    Created for: SOW: IC00 ICON project
    Create date: FEB 2013

    Details
    -------
    This class contains methods that cover 
        - Get offset dor query pagination, .. 
        - Build where clause,  
        - Record count for query
    
    Update History
    --------------
    

    Issues / TODOs
    --------------
    Before a release make sure that the statuses given as default custom settings are applicable to the values used in the test code
*/

public class IC_UTILS_Query {
    
    public static final String START_WITH = 'STARTWITH';
    public static final String END_WITH = 'ENDWITH';
    public static final String CONTAINS = 'CONTAINS';
    public static final String EQUAL= 'EQUAL';
    public static final String NOT_EQUAL= 'NOTEQUAL';
    
    
    
    /**
    * Offset string is used only in query for clientt.
    * Seperate string because offset is not used for filtering.
    **/
    public static String getOffsetString(Integer  rowsPerPage, Integer currentPageNumber)
    {
        return ' limit '+ rowsPerPage + ' offset ' +(currentPageNumber * rowsPerPage);
    }

    /**
    * Build where Clause for SOQL 
    * Create filters for one or several fields
    */
    public static String buildWhereCLause(String[] fieldsName, String value, String operator, boolean addOpeToGroup) 
    {
        return buildWhereCLause(fieldsName, value, operator, addOpeToGroup, CONTAINS);
    }   


    /**
    * Build where Clause for SOQL 
    * Create filters for one or several fields
    */
    public static String buildWhereCLause(String[] fieldsName, String value, String operator, boolean addOpeToGroup, String filterType) 
    {
        String whereString =  '';
        if (IC_UTILS.Empty(value)) return whereString;
        String endWith = (filterType == END_WITH?'':'%');
        String startWith = (filterType == START_WITH?'':'%');
        
        for (String fieldName : fieldsName){
            if(filterType == EQUAL)
                whereString += (!IC_UTILS.empty(value) ? fieldName + ' = \'' + value +'\'' + operator + ' ' : '');  
            else if(filterType == NOT_EQUAL)
            	whereString += (!IC_UTILS.empty(value) ? fieldName + ' != \'' + value +'\'' + operator + ' ' : '');
            else           
                whereString += (!IC_UTILS.empty(value) ? fieldName + ' like \'' + startWith + value +endWith +'\'' + operator + ' ' : '');  
        }
        // Add operator between group of fields 
        String lastOperator = (addOpeToGroup ? ' AND ' :'');
        whereString =  (whereString.length() > 0? ' (' + whereString.removeEnd(operator + ' ') + ') ' + lastOperator: '');

        System.debug ('*** whereString=' + whereString);
        return whereString;
    }

    public static String buildWhereCLause(String fieldName, String value, boolean addOpeToGroup) 
    {
        return buildWhereCLause(new String[]{fieldName}, value, 'OR', addOpeToGroup);
    }

    public static String buildWhereCLause(String fieldName, String value, boolean addOpeToGroup, String filterType) 
    {
        return buildWhereCLause(new String[]{fieldName}, value, 'OR', addOpeToGroup, filterType);
    }
    
    /**
    * Build where Clause for SOQL 
    * Create filters for one or several fields
    */ 
    public static String buildWhereCLause(String[] fieldsName, String value, String operator) 
    {
        return buildWhereCLause(fieldsName, value, operator, false); 
    }
    
    /**
    * Return record count of query
    **/
    public static Integer getRecordCount (String objectName , String whereClause)
    {
        Integer numberOfRows = 0;
        //try {
            String whereString = (!IC_UTILS.empty(whereClause) && !whereClause.containsIgnoreCase('Where ')? ' Where ' +  whereClause: whereClause);
            System.debug('### Query: '+'Select count(Id) From ' + objectName + ' ' +  whereString);
            AggregateResult aggResult = Database.Query('Select count(Id) From ' + objectName + ' ' +  whereString);
            numberOfRows = Integer.valueOf(aggResult.get('expr0'));
        //}catch (Exception e ) {
        //    numberOfRows = 0;
       // }
        return numberOfRows;
    }   
    
}