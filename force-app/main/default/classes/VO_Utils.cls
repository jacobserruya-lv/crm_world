/**
     * Utils class that give us an abstraction for all the custom settings.
     * @createdBy   Menashe Yamin ,  2/1/2016         
     */

public class VO_Utils { 

	public  final static Integer LAST_n_MONTHS;
	private final static Integer numMonthCSDefualtValue = 6;
	private final static String CS_NAME_NUM_OF_MONTHS = 'num months before';

	public  final static Integer BEFORE_n_DAYS;
	private final static Integer numDaysCSDefualtValue = 7;
	private final static String CS_NAME_NUM_OF_DAYS = 'num days before';

	
	private final static Integer numDefaultnDaysFromSearchCSDefualtValue = 10;
	public  final static Integer DEFAULT_n_DAYS_FROM_DATE_SEARCH;
	private final static String CS_NAME_DEFAULT_FROM_DATE_SEARCH = 'Default from date search';

	private final static String CS_NAME_MAX_RESUALTS_PER_SEARCH = 'Max records per search';
	public  final static Integer DEFAULT_n_RESUALTS_PER_SEARCH;
	private final static Integer numDefaultnMaxResualtsCSDefualtValue = 500;

	public  final static String STR_RESULT_IN_SEARCH_PAGE;
	private final static String CS_NAME_OF_REULTS_IN_SEARCH_PAGE = 'num of results in search page';

	public  final static Integer NUM_OF_Q ;
	private final static String CS_NAME_NUM_OF_Q = 'NUM OF Q';
	private final static Integer numDefaultnNumOfQ = 10;

	public final static String PERMISSIONSET_PRIORITIES ;
	public final static String CS_NAME_OF_PERMISSIONSET_PRIORITIES = 'permissionSet priorities';

	public final static String SURVERY_TYPE_ORDERING ;
	public final static String CS_NAME_OF_SURVERY_TYPE_ORDERING = 'main statistics survey type ordering';

	public final static String CS_NAME_OF_MS_USE_BATCH = 'MS USE BATCH?';
	public   static Boolean MS_USE_BATCH ;
	private final static Boolean msUseBatcCSDefualtValue = true;

	public final static String CS_NAME_OF_HOST_NAME_CASE_DETAIL = 'HOST case detail';


	private final static String CS_NAME_MAX_RESUALTS_PER_SEARCH_EXCEL = 'Max records per search Excel';
	public  final static Integer DEFAULT_n_RESUALTS_PER_SEARCH_EXCEL;
	private final static Integer numDefaultnMaxResualtsExcelCSDefualtValue = 2000;

	public final static String VOICE_SALES ='VOICE Store Local Sales';// VO_Utils.VOICE_SALES
	public final static String VOICE_AFTER_SALES= 'VOICE Store After Sales';// VO_Utils.VOICE_AFTER_SALES
	public final static String VOICE_WEB_SALES = 'VOICE Web Sales'; //VO_Utils.VOICE_WEB_SALES 
	public final static String VOICE_CSC_SALES = 'VOICE CSC Sales'; //VO_Utils.VOICE_CSC_SALES
	public final static String VOICE_CC_CSC_SALES = 'VOICE CSC Click And Collect'; //VO_Utils.VOICE_CC_CSC_SALES
	public final static String VOICE_CC_WEB_SALES = 'VOICE Web Click And Collect'; //VO_Utils.VOICE_CC_WEB_SALES
	public final static String VOICE_EO_SALES = 'VOICE Endless Offer'; //VO_Utils.VOICE_EO_SALES


	public final static String VOICE_SURVEY_TYPE_SALES_PROMOTER = 'Promoter'; 
	public final static String VOICE_SURVEY_TYPE_RECOVERY_ACT = 'Recovery Act';
	public final static String VOICE_SURVEY_TYPE_DELIGHTED_CLIENT = 'Delighted Client';

    public final static String CS_NAME_PDF_PPRODUCT_LIMIT = 'PDF PPRODUCT LIMIT';
	public final static Integer PDF_PPRODUCT_LIMIT;
	static
	{
		 LAST_n_MONTHS = initNumberCustomSetting (CS_NAME_NUM_OF_MONTHS, numMonthCSDefualtValue);
		 BEFORE_n_DAYS = initNumberCustomSetting (CS_NAME_NUM_OF_DAYS, numDaysCSDefualtValue);
		 DEFAULT_n_DAYS_FROM_DATE_SEARCH = initNumberCustomSetting (CS_NAME_DEFAULT_FROM_DATE_SEARCH, numDefaultnDaysFromSearchCSDefualtValue);
		 DEFAULT_n_RESUALTS_PER_SEARCH = initNumberCustomSetting(CS_NAME_MAX_RESUALTS_PER_SEARCH, numDefaultnMaxResualtsCSDefualtValue);
		 
		 DEFAULT_n_RESUALTS_PER_SEARCH_EXCEL = initNumberCustomSetting(CS_NAME_MAX_RESUALTS_PER_SEARCH_EXCEL,numDefaultnMaxResualtsExcelCSDefualtValue);
		 STR_RESULT_IN_SEARCH_PAGE = VO_Config__c.getValues(CS_NAME_OF_REULTS_IN_SEARCH_PAGE).Value__c;
		 PERMISSIONSET_PRIORITIES = VO_Config__c.getValues(CS_NAME_OF_PERMISSIONSET_PRIORITIES).Value__c;
		 NUM_OF_Q = initNumberCustomSetting(CS_NAME_NUM_OF_Q, numDefaultnNumOfQ);
		 SURVERY_TYPE_ORDERING = VO_Config__c.getValues(CS_NAME_OF_SURVERY_TYPE_ORDERING).Value__c;
		 PDF_PPRODUCT_LIMIT = initNumberCustomSetting(CS_NAME_PDF_PPRODUCT_LIMIT, 200);
		 if(VO_Config__c.getValues(CS_NAME_OF_MS_USE_BATCH).Value__c != null &&  !VO_Config__c.getValues(CS_NAME_OF_MS_USE_BATCH).Value__c.equals('true'))
		 {
		 	MS_USE_BATCH = false;
		 }
		 else
		 {
		 	MS_USE_BATCH = msUseBatcCSDefualtValue;
		 }
	}

	/**
	 * [check if the custom setting value is number]
	 * @scenario	[first check if the value is Null after that check if the value of the  ]
	 * @result	[return the number of months from the custom setting 'num months before' if there is one ,
	 * otherwise return 6]
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 10.09.15
	 */
	private static Integer initNumberCustomSetting(String csName, Integer defualtValue)
	{
		String value;
		try 
		{
			value =  VO_Config__c.getValues(CSname).Value__c;
			Integer.valueOf(value);
		}
		catch (Exception  e)
		{
			system.debug('HAVE PROBLEM WITH CUSTOM SETTING');
			return defualtValue ;
		}
		return Integer.valueOf(value);
	}

	
    /* KTC */
    /**
     * [Get PickList Values of field by meta data]
     * @param  objectName [Object name]
     * @param  fieldName  [Field name of picklist type]
     * @param  firstVal   [Optional first value for the picklist list]
     * @return            [List of values for the picklist]
     * @createdBy         Niv Goldenberg on 01/06/2015
     * @modifiedBy        Niv Goldenberg on 01/06/2015
     */
    public static List<selectOption> getPicklistValues(String objectName, String fieldName, String unselectedVal) 
    {
        // New list for holding all of the picklist options.
        List<selectOption> options = new List<selectOption>(); 
        
        // If there is a first value being provided.
        if (String.isNotBlank(unselectedVal)) 
        {
            options.add(new selectOption(null, unselectedVal)); 
        }
        
        // Grab the sobject that was passed.
        Schema.sObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);

        // Describe the sobject.
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); 
        // Get a map of fields for the passed sobject.
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); 
        // Grab the list of picklist values for the passed field on the sobject.
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        // For all values in the picklist list.
        for (Schema.PicklistEntry picklistEntryItem : picklistValues) 
        { 
            if(picklistEntryItem.getValue() != 'unknown' && picklistEntryItem.getValue() != 'Other' ) 
            {   
                // Add the value and label to our final list.     
                options.add(new selectOption(picklistEntryItem.getValue(), picklistEntryItem.getLabel())); 
            }
        }
        
        return options; 
    }
    




}