/**
  *  -----
  *  Description: Shared utilities
  *  Created for: Client search optimization project
  *  Create date: Oct 2015
  *
  *  Details
  *  -------
  *  
  *  Update History
  *  --------------
  *  Oct 2015 / LV / Created by Simon GOURREAU
  *  
  *  Issues / TODOs
  *  --------------
*/
public with sharing class LV_UTILS {
	
    //AEF:  
    public Enum OperatorEnum  { EQUALS, startsWith }
    public Enum QueryTypeEnum { SOSL, SOQL, Automatic }

    /** Wrapper class to search criterias */
    public class SearchCriteria {
        public String Label;
        public String Operator;
        public String Value;
        //public String Field;
    }

    /**** Generic shortcut methods ****/
    public static Boolean empty(Object o)
    {
        return o==null || String.valueOf(o)=='';
    }
    public static Boolean empty(Integer o)
    {
        return o==null || o==0;
    }
    public static Boolean empty(Decimal o)
    {
        return o==null || o==0;
    }
}