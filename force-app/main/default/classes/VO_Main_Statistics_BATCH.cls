/**
     * Controller of the VO_Main_Statistics page 
     * @createdBy   Menashe Yamin ,  11/26/2015    
     */


global class VO_Main_Statistics_BATCH implements Database.Batchable<sObject> {
	

	global final String fieldNames;
	private final static Integer LastMonth = 1;
	global Map<Id,Store__c> storeIdToStoreMap {get;set;}
	private Map<String,String> surveyTypeToSurveyTypeFieldName {get;set;}
	private Map<String,String> typeToTypeFieldName {get;set;}
	Map<String,String> typeToTypeFieldNameCapital{get;set;}
	
	global VO_Main_Statistics_BATCH() 
	{

	 	surveyTypeToSurveyTypeFieldName = new map<String,String> { VO_Utils.VOICE_SALES => 'Sales_', 
																VO_Utils.VOICE_AFTER_SALES => 'AS_', 
										 						VO_Utils.VOICE_WEb_SALES => 'WS_', 
										 						VO_Utils.VOICE_CSC_SALES => 'CSC_'};
		typeToTypeFieldName = new map<String,String> {  VO_Utils.VOICE_SURVEY_TYPE_SALES_PROMOTER => 'pm', 
													VO_Utils.VOICE_SURVEY_TYPE_RECOVERY_ACT =>'ra',
													VO_Utils.VOICE_SURVEY_TYPE_DELIGHTED_CLIENT =>'dc'};
		//MY 24.11.2015 :  need this also because the names OF those fields (was added as CR ..) for this section was without the name convaction I set/:
		 typeToTypeFieldNameCapital = new map<String,String> { VO_Utils.VOICE_SURVEY_TYPE_SALES_PROMOTER  => 'PR', 
		 													   VO_Utils.VOICE_SURVEY_TYPE_RECOVERY_ACT=>'RA',
															   VO_Utils.VOICE_SURVEY_TYPE_DELIGHTED_CLIENT =>'DC'};
	}
	/**
	 * @scenario	[Soql on survays that created in the past N months ]
	 * @result	[ list of AggregateResult of that data ]
	 * @param [isLastNmonth - if it's for the last N month query or for the last month 
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 20.09.15
	 */

	global String querySurveyCreator(Boolean isLastNmonth)
	{
        String queryStr = 'SELECT COUNT(Id), Store__r.id ,SurveyType__c, Status__c, Type__c,  SUM(DetractorNPS__c) Detractor, SUM(PromoterNPS__c) Promoter ';
		queryStr += 'FROM VO_Survey__c ';
		if(isLastNmonth)
		{
			queryStr += 'WHERE AnswerDate__c > :lastNmonthsDate ';	
		}
		else
		{
			queryStr += 'WHERE AnswerDate__c > :lastMonthDate ';
		}

		queryStr += 'AND Store__r.id IN :scope ';
		queryStr += 'AND SurveyType__c != Null ';
		queryStr += 'GROUP BY Store__r.id ,SurveyType__c, Status__c, Type__c';
		return queryStr;
	}

	/**
	 * @return [return a query about all the MS fields in the survey object]
	 */
	global String queryStoreCreator()
	{

        String queryStr = 'SELECT Id,';
        queryStr += 'MS_Sales_Total__C, MS_Sales_New__C, 	   MS_Sales_Pending__C,  MS_Sales_Closed__C, MS_Sales_NoAction__C,';
        queryStr += 'MS_Sales_dcNew__C, MS_Sales_dcPending__C, MS_Sales_pmNew__C, 	 MS_Sales_pmPending__C, ';
        queryStr += 'MS_Sales_raNew__C, MS_Sales_raPending__C, MS_Sales_raPending7D__C, ';
        queryStr += 'MS_Sales_Detractor_NPS__c, 			   MS_Sales_Promotor_NPS__c, ';

        queryStr += 'MS_AS_Total__C,    MS_AS_New__C,    	MS_AS_Pending__C,    MS_AS_Closed__C,    MS_AS_NoAction__C, ';
        queryStr += 'MS_AS_dcNew__C, 	MS_AS_dcPending__C, MS_AS_pmNew__C,		 MS_AS_pmPending__C, ';
        queryStr += 'MS_AS_raNew__C, 	MS_AS_raPending__C, ';
        queryStr += 'MS_AS_Detractor_NPS__c, 				MS_AS_Promotor_NPS__c, ';
        
        queryStr += 'MS_WS_Total__C,    MS_WS_New__C,    	MS_WS_Pending__C,    MS_WS_Closed__C,    MS_WS_NoAction__C, ';
        queryStr += 'MS_WS_dcNew__C,	MS_WS_dcPending__C,	MS_WS_pmNew__C,';
        queryStr += 'MS_WS_pmPending__C,MS_WS_raNew__C, 	MS_WS_raPending__C,  MS_WS_raPending7D__C, ';
        queryStr += 'MS_WS_Detractor_NPS__c, 				MS_WS_Promotor_NPS__c , ';

        queryStr += 'MS_CSC_Total__C,   MS_CSC_New__C,   	MS_CSC_Pending__C,   MS_CSC_Closed__C,   MS_CSC_NoAction__C,';
		queryStr += 'MS_CSC_dcNew__C,	MS_CSC_dcPending__C,MS_CSC_pmNew__C,     MS_CSC_pmPending__C,MS_CSC_raNew__C,';
		queryStr += 'MS_CSC_raPending__C,					MS_CSC_raPending7D__C, ';
		queryStr += 'MS_CSC_Detractor_NPS__c, 				MS_CSC_Promotor_NPS__c, ';
		
		queryStr += 'MS_Sales_Total_LastMonth__C,           MS_CSC_Total_LastMonth__C,             MS_Sales_raNewAndPending_LastMonth__C,';
		queryStr += 'MS_CSC_dcNewAndPending_LastMonth__C,   MS_Sales_pmNewAndPending_LastMonth__C, MS_CSC_pmNewAndPending_LastMonth__C,';
		queryStr += 'MS_Sales_dcNewAndPending_LastMonth__C, MS_CSC_raNewAndPending_LastMonth__C,   MS_AS_Total_LastMonth__C, ';
		queryStr += 'MS_WS_Total_LastMonth__C,              MS_AS_dcNewAndPending_LastMonth__C,    MS_WS_dcNewAndPending_LastMonth__C,';
		queryStr += 'MS_AS_pmNewAndPending_LastMonth__C,    MS_WS_pmNewAndPending_LastMonth__C,    MS_AS_raNewAndPending_LastMonth__C,';
		queryStr += 'MS_WS_raNewAndPending_LastMonth__C, ';

		queryStr += 'MS_Sales_Promotor_NPS_LastMonth__c, MS_Sales_Detractor_NPS_LastMonth__c, ';
		queryStr += 'MS_CSC_Promotor_NPS_LastMonth__c, 	 MS_CSC_Detractor_NPS_LastMonth__c, ';
		queryStr += 'MS_AS_Promotor_NPS_LastMonth__c, 	 MS_AS_Detractor_NPS_LastMonth__c, ';
		queryStr += 'MS_WS_Promotor_NPS_LastMonth__c, 	 MS_WS_Detractor_NPS_LastMonth__c ';

		queryStr += ',MS_Sales_Total_DC__c, MS_Sales_Total_RA__c,MS_Sales_Total_PR__c,';
		queryStr += 'MS_WS_Total_DC__c,     MS_WS_Total_RA__c,   MS_WS_Total_PR__c,';
		queryStr += 'MS_AS_Total_DC__c,     MS_AS_Total_RA__c,   MS_AS_Total_PR__c,';
		queryStr += 'MS_CSC_Total_DC__c,    MS_CSC_Total_RA__c,  MS_CSC_Total_PR__c,';

		queryStr += 'MS_Sales_Total_DC_Last_Month__c, MS_Sales_Total_RA_Last_Month__c,MS_Sales_Total_PR_Last_Month__c,';
		queryStr += 'MS_AS_Total_DC_Last_Month__c,    MS_AS_Total_RA_Last_Month__c   ,MS_AS_Total_PR_Last_Month__c,';
		queryStr += 'MS_WS_Total_DC_Last_Month__c,    MS_WS_Total_RA_Last_Month__c,   MS_WS_Total_PR_Last_Month__c,';
		queryStr += 'MS_CSC_Total_DC_Last_Month__c,   MS_CSC_Total_RA_Last_Month__c , MS_CSC_Total_PR_Last_Month__c';



		
		queryStr += ' FROM Store__c';		
		return queryStr;
	}	
	/**
	 * [querySurveyLastDaysCreator description]
	 * @param  scope [the scope from the batch of stores]
	 * @return       [AggregateResult List off all the surveys that relate to this scope with the fields that eeded from the calc of the last days ]
	 */
	private static List<AggregateResult> querySurveyLastDaysCreator(List<Store__c> scope)
	{
		Date dDays = date.today().addDays(-VO_Utils.BEFORE_n_DAYS);
		Date dMonth = date.today().addMonths(-VO_Utils.LAST_n_MONTHS);

		String PENDING ='Pending';
		String RECOVERY_ACT = VO_Utils.VOICE_SURVEY_TYPE_RECOVERY_ACT;
		List<AggregateResult> results = [SELECT COUNT(Id), SurveyType__c, Store__r.id
										 FROM VO_Survey__c
										 WHERE AnswerDate__c < :dDays 
										 AND AnswerDate__c > :dMonth
										 AND Store__r.id IN:scope
										 AND Status__c =: PENDING
										 AND Type__c =: RECOVERY_ACT
										 GROUP BY Store__r.id,SurveyType__c];
		return results;
	}
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(queryStoreCreator());
	}

   	global void execute(Database.BatchableContext BC, List<Store__c> scope) 
   	{

		System.debug('execute START');
		System.debug('scope : ' + scope);
		List<id> storeIdsTets = new List<id>();
		for(Store__c stor :scope)
		{
			storeIdsTets.add(stor.id);
			stor = VO_Main_Statistics_CTRL.initStoreToZeroForAllMSfields(stor);
		}

		Date lastNmonthsDate = date.today().addMonths(-VO_Utils.LAST_n_MONTHS);
		Date lastMonthDate = date.today().addMonths(-LastMonth);


        List<AggregateResult> lastNMonthresults = database.query(querySurveyCreator(true));
        List<AggregateResult> lastMonthResults = database.query(querySurveyCreator(false));

        List<AggregateResult> lastResultsInThelastNDays = querySurveyLastDaysCreator(scope);

		storeIdToStoreMap = new Map<Id,Store__c>();

		for(AggregateResult ar : lastNMonthresults)
		{
			aggregatHandler(ar,storeIdToStoreMap,'LastNMonth');	
		}
		for(AggregateResult ar : lastMonthResults)
		{
			aggregatHandler(ar,storeIdToStoreMap,'LastMonth');	
		}
		for(AggregateResult ar : lastResultsInThelastNDays)
		{
			aggregatHandler(ar,storeIdToStoreMap,'LastDays');	
		}
		


		update storeIdToStoreMap.values();
		System.debug('execute FINISH');
	}

	/**
	 * [checkIfHaveAlredyInMapStore -chcek if already we do some calc about this store with another surveys  - so the id in the map
	 * otherwise, add the store id to the map]
	 * @return                   [store id to put the statistic in ]
	 */
	private Store__c checkIfHaveAlredyInMapStore(AggregateResult ar, Map<Id,Store__c> storeIdToStoreMap)
	{
		if(!storeIdToStoreMap.containsKey(ar.get('Id')+''))
		{
			storeIdToStoreMap.put(ar.get('Id')+'',New Store__c());
			Store__c currStore = storeIdToStoreMap.get(ar.get('Id')+'');
			currStore.id = ar.get('Id')+'';
		}
		return storeIdToStoreMap.get(ar.get('Id')+'');
	}

	/**
	 * [fillStoreMSDateLastNmonths fill the fields that relate to the Last Nmonths]
	 * @param currStore [description]
	 * @param ar        [description]
	 */
	private void fillStoreMSDateLastNmonths(Store__c currStore,AggregateResult ar)
	{
		String Prefix = 'MS_';
		String Suffix = '__c';



		String surveyType = ar.get('SurveyType__c')+'';
		String Status = ar.get('Status__c')+'';
		if(Status.equals('No action'))
		{
			Status = 'NoAction';
		}
		String Type = ar.get('Type__c')+'';


		String TOTAL = 'Total';
		String TotalFieldName  = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + TOTAL +Suffix;
		String StatusFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + Status +Suffix;
		String TypeFieldName   = '';
		String typeTotalFieldName = '';
			///
		String PROMOTOR = 'Promotor_NPS';
		String DETRACTOR = 'Detractor_NPS';
		String PromotorFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + PROMOTOR +Suffix;
		String DetractorFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + DETRACTOR +Suffix;


		if(ar.get('SurveyType__c') != null && surveyTypeToSurveyTypeFieldName.containsKey(surveyType))
		{
			
			//Total Fields!
			if(currStore.get(TotalFieldName) != null)
			{
				currStore.put(TotalFieldName,Integer.valueOf(currStore.get(TotalFieldName))+Integer.valueOf(ar.get('expr0'))); 
			}
			else
			{
				currStore.put(TotalFieldName,Integer.valueOf(ar.get('expr0'))); 

			}


			//Status Fields
			if(ar.get('Status__c') != null)
			{
				if(currStore.get(StatusFieldName) !=null)
				{
					currStore.put(StatusFieldName,Integer.valueOf(currStore.get(StatusFieldName))+Integer.valueOf(ar.get('expr0'))); 
				}
				else
				{
					currStore.put(StatusFieldName,Integer.valueOf(Integer.valueOf(ar.get('expr0')))); 
				}
			}

			//TypeFields
			if(ar.get('Type__c') != null && typeToTypeFieldName.containsKey(ar.get('Type__c')+''))
			{
				//MY 24.11.2015 :  new calc of types precentes in 24/11
				TypeFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + typeToTypeFieldName.get(Type) +Status +Suffix;

				typeTotalFieldName =  Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + TOTAL + '_' +  typeToTypeFieldNameCapital.get(Type) + Suffix;
				
				if(currStore.get(TypeTotalFieldName) != null)
				{
					currStore.put(typeTotalFieldName,Integer.valueOf(currStore.get(TypeTotalFieldName))+Integer.valueOf(ar.get('expr0')));
				}
				else
				{
					currStore.put(typeTotalFieldName,Integer.valueOf(ar.get('expr0')));
				}

				if((Status == 'Pending' || Status == 'New'))
				{
					if(currStore.get(TypeFieldName) != null)
					{
						currStore.put(TypeFieldName,Integer.valueOf(currStore.get(TypeFieldName))+Integer.valueOf(ar.get('expr0'))); 
					}
					else
					{	
						currStore.put(TypeFieldName,Integer.valueOf(Integer.valueOf(ar.get('expr0')))); 
					}
				}
			}
			
			//Promoter and Detractor Fields
			if(ar.get('Detractor') != null)
			{
				if(currStore.get(DetractorFieldName) !=null)
				{
					currStore.put(DetractorFieldName,Integer.valueOf(currStore.get(DetractorFieldName))+Integer.valueOf(ar.get('Detractor'))); 
				}
				else
				{
					currStore.put(DetractorFieldName,Integer.valueOf(Integer.valueOf(ar.get('Detractor')))); 
				}
			}
			if(ar.get('Promoter') != null)
			{
				if(currStore.get(PromotorFieldName) !=null)
				{
					currStore.put(PromotorFieldName,Integer.valueOf(currStore.get(PromotorFieldName))+Integer.valueOf(ar.get('Promoter'))); 
				}
				else
				{
					currStore.put(PromotorFieldName,Integer.valueOf(Integer.valueOf(ar.get('Promoter')))); 
				}
			}
		}	
	}

	/**
	 * [fillStoreMSDateLastNmonths fill the fields that relate to the Last months]
	 * @param currStore [description]
	 * @param ar        [description]
	 */
	private void fillStoreMSDateLastmonth(Store__c currStore,AggregateResult ar)
	{
		String Prefix = 'MS_';
		String Suffix = '__c';
		String TOTAL = 'Total_';
		String LAST_MONTH = 'LastMonth';
		String NEW_AND_PENDING = 'NewAndPending_';
		String surveyType = ar.get('SurveyType__c')+'';
		String Status = ar.get('Status__c')+'';



		if(Status.equals('No action'))
		{
			Status = 'NoAction';
		}

		String Type = ar.get('Type__c')+'';
		
		String TotalFieldName  = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) ;
			   TotalFieldName += TOTAL + LAST_MONTH + Suffix;

		String TypeFieldName   = '';



		String PROMOTOR = 'Promotor_NPS_';
		String DETRACTOR = 'Detractor_NPS_';
		String PromotorFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + PROMOTOR + LAST_MONTH +Suffix;
		String DetractorFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + DETRACTOR + LAST_MONTH +Suffix;

		String LAST_MONTH2 = '_Last_Month';

		String typeTotalLastMonthFieldName = '' ;



		if(ar.get('SurveyType__c') != null && surveyTypeToSurveyTypeFieldName.containsKey(surveyType))
		{
			
			//Total Fields!
			if(currStore.get(TotalFieldName) != null)
			{
				currStore.put(TotalFieldName,Integer.valueOf(currStore.get(TotalFieldName))+Integer.valueOf(ar.get('expr0'))); 
			}
			else
			{
				currStore.put(TotalFieldName,Integer.valueOf(ar.get('expr0'))); 
			}

			//TypeFields
			if(ar.get('Type__c') != null && typeToTypeFieldName.containsKey(ar.get('Type__c')+''))
			{
				//MY 24.11.2015 :  new calc of types precentes in 24/11
				TypeFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + typeToTypeFieldName.get(Type) + NEW_AND_PENDING + LAST_MONTH +Suffix;

				typeTotalLastMonthFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + TOTAL +  typeToTypeFieldNameCapital.get(Type) + LAST_MONTH2 +Suffix;
				
				if(currStore.get(typeTotalLastMonthFieldName) != null)
				{
					currStore.put(typeTotalLastMonthFieldName,Integer.valueOf(currStore.get(typeTotalLastMonthFieldName))+Integer.valueOf(ar.get('expr0'))); 
				}
				else
				{
					currStore.put(typeTotalLastMonthFieldName,Integer.valueOf(ar.get('expr0'))); 
				}


				if((Status == 'Pending' || Status == 'New'))
				{
					System.debug('ar.get(Type__c) : ' +  ar.get('Type__c') );
					System.debug('Status : ' +  Status );
					System.debug('TypeFieldName : ' + TypeFieldName );
					if(currStore.get(TypeFieldName) != null)
					{
						currStore.put(TypeFieldName,Integer.valueOf(currStore.get(TypeFieldName))+Integer.valueOf(ar.get('expr0'))); 

					}
					else
					{	
						currStore.put(TypeFieldName,Integer.valueOf(Integer.valueOf(ar.get('expr0')))); 

					}
				}
			}

			//Promoter and Detractor Fields
			if(ar.get('Detractor') != null)
			{
				if(currStore.get(DetractorFieldName) !=null)
				{
					currStore.put(DetractorFieldName,Integer.valueOf(currStore.get(DetractorFieldName))+Integer.valueOf(ar.get('Detractor'))); 
				}
				else
				{
					currStore.put(DetractorFieldName,Integer.valueOf(Integer.valueOf(ar.get('Detractor')))); 
				}
			}
			if(ar.get('Promoter') != null)
			{
				if(currStore.get(PromotorFieldName) !=null)
				{
					currStore.put(PromotorFieldName,Integer.valueOf(currStore.get(PromotorFieldName))+Integer.valueOf(ar.get('Promoter'))); 
				}
				else
				{
					currStore.put(PromotorFieldName,Integer.valueOf(Integer.valueOf(ar.get('Promoter')))); 
				}
			}
		}
	}

	/**
	 * [fillStoreMSDateLastNmonths fill the fields that relate to the Last days (7 days and more..)]
	 * @param currStore [description]
	 * @param ar        [description]
	 */
	private void fillStoreMSDateLastDays(Store__c currStore,AggregateResult ar)
	{
		String Prefix = 'MS_';
		String Suffix = 'raPending7D__c';
		
		String surveyType = ar.get('SurveyType__c')+'';
		String Pending7DFieldName = Prefix + surveyTypeToSurveyTypeFieldName.get(surveyType) + Suffix;

		if(ar.get('SurveyType__c') != null && surveyTypeToSurveyTypeFieldName.containsKey(surveyType))
		{
			if(currStore.get(Pending7DFieldName) != null)
			{
				currStore.put(Pending7DFieldName,Integer.valueOf(currStore.get(Pending7DFieldName))+Integer.valueOf(ar.get('expr0'))); 
			}
			else
			{
				currStore.put(Pending7DFieldName,Integer.valueOf(ar.get('expr0'))); 
			}
		}		
	}

	/**
	 * [aggregatHandler description]
	 * @param ar                [result from query ]
	 * @param status            [ of it's  LastNMonth, LastMonth or LastDays handeling  ]
	 */
	private void aggregatHandler(AggregateResult ar, Map<Id,Store__c> storeIdToStoreMap,String status)
	{

		Store__c  currStore = checkIfHaveAlredyInMapStore(ar,storeIdToStoreMap);

		if(status.equals('LastNMonth'))
		{
			fillStoreMSDateLastNmonths(currStore,ar);
		}
		if(status.equals('LastMonth'))
		{
			fillStoreMSDateLastmonth(currStore,ar);
		}
		if(status.equals('LastDays'))
		{
			fillStoreMSDateLastDays(currStore,ar);
		}
		
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		System.debug('Batch FINISH');	
	}
	
}