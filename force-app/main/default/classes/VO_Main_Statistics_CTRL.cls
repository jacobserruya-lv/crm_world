/**
     * Controller of the VO_Main_Statistics page 
     * @createdBy   Menashe Yamin ,  8/26/2015         
     */

global class VO_Main_Statistics_CTRL  {
    

	public  Map<String, VO_SurvayTypeStat> survayTypeStatMap {get; set;}
	public  Map<String, VO_SurvayTypeStat>  latestSurvayTypeStatMap  {get; set;} // was old urvayTypeStatMap but Bernard change it to compering with the last 1 month
	public  Integer numOfDaysBefore {get; set;}
	public  List<String> permissionToSeeSurveyTypeList {get;set;}
	public List<String > surveyTypeOrderingByCS {get;set;}
	private final static Integer LastMonth = 1;
	public Integer rateBetweenMonths {get;set;}

	public Date todayLessNmonths 
					{get
						{
						  return date.today().addMonths(-VO_Utils.LAST_n_MONTHS);
						 }
					 private set;
					}


	public VO_Main_Statistics_CTRL(){
		this.numOfDaysBefore = VO_Utils.BEFORE_n_DAYS; //this var only create  to pass to the components!because the components can't get from VO_UTILS:/
		this.rateBetweenMonths = VO_Utils.LAST_n_MONTHS/LastMonth;
		this.initUserPermissionToSeeSurveyTypeList();//permissionSetForUsers by the permission set
		this.initStatic();
		//batch or not ?

	}

	/**
	 * @scenario	[if the user is not admin he should see only the statistics there are allow to him be the permission set.
	 * admin can see all
	 * also we have a ordering how each survey type that are define by custom seeting look at VO_Utils.PERMISSIONSET_PRIORITIES]
	 * @result	[ initlize the UserPermissionToSeeSurveyTypeList list - the ording list of survey type that user can see at the page ]
 	 * @createdBy  	Menash Yamin 
	 */
	private void initUserPermissionToSeeSurveyTypeList()
	{
		List<String> userPermissionSetNameList = getUserPermissionSet(Userinfo.getUserId());
		List<String> permissionSetPrioritiesList = VO_Utils.SURVERY_TYPE_ORDERING.split(';');

		permissionToSeeSurveyTypeList = new list<String> ();
		//Admin can see anyone
		if(!isAdmin(userinfo.getProfileId()))
		{
			for(String permissinProrities :permissionSetPrioritiesList)
			{
				for(String ps:userPermissionSetNameList)
				{
					if(permissinProrities.equals(ps))
					{
						permissionToSeeSurveyTypeList.add(permissinProrities);
					}
				}
			}
		}
		else
		{
			for(String permissinProrities :permissionSetPrioritiesList)
			{
				permissionToSeeSurveyTypeList.add(permissinProrities);
			}
		}
	}

/**
 * @param  userId [user id..]
 * @return        [List of all the labels of the permission set that this user have]
 * @createdBy  	Menash Yamin 
 */
	public static List<String> getUserPermissionSet(String userId)
	{
		List<String> permissionLabelList = new List<String> ();
		List<PermissionSetAssignment> lstcurrentUserPerSet =  [SELECT Id, PermissionSet.Name,PermissionSet.label,AssigneeId
								                                 FROM PermissionSetAssignment
								                                 WHERE AssigneeId = :userId];
        for(PermissionSetAssignment ps :lstcurrentUserPerSet)
        {
        	permissionLabelList.add(ps.PermissionSet.label);
        }

        return permissionLabelList;

	}
/**
 * @param  userProfileId [profile id of the user that we want to check if he admin]
 * @return               [True- admin, false -otherwise]
 * @createdBy  	Menash Yamin 
 */
	public static boolean isAdmin(String userProfileId)
	{
		List<Profile> prof = [SELECT Id, Name 
								 FROM Profile 
								 WHERE Id=:userProfileId LIMIT 1];
		return prof[0].Name.equals('System Administrator');
	}

	/**
	 * [init surveyTypeOrderingByCS List. in this list will be the surveyTypes that the user can see 
	 *  by the order the admin set in the custom setting named:'main statistics survey type ordering' VO UAT 55 ]
	 * @scenario	[we get a list of surveyType name that the user can see and ordering them by the cs named above
	 *				 and only if the name of the list are in the list from the user permission and also is 
	 *				 in the custom setting we will add him . first we will do for on the custom setting list in
	 *				order to keep the order .]
	 * @result	[survayTypeStatMap that contain key -survay type ;value -all the statistics that needed ]
 	 * @createdBy  	Menash Yamin 11.10.15         
 	 * @lastModifiedBy 	Menash Yamin 11.10.15
	 */
	private List<String> initSurveyTypeOrderingByCS(Set<String> surveyTypeList)
	{
		List<String> survayTypeOrdringFromCSList = VO_Utils.SURVERY_TYPE_ORDERING.split(';');
		List<String> ansList = new List<String>();
		for(String surveyTypeCS : survayTypeOrdringFromCSList)
		{
			for(String surveyTypeUserPermission:surveyTypeList)
			{
				if(surveyTypeCS.equals(surveyTypeUserPermission))
				{
					ansList.add(surveyTypeCS);
				}
			}
		}



		return ansList;
	}

	/**
	 * @scenario	[init all the variables that needed in order to create the page and then aggragate the statistics for all the surveys 
	 * the user have permission in one of those 2 methods
	 * barch - the new solution - when there is a batch that calc all the surveys and store there result in there store
	 * OldSolution - query on all surveys in the system (don't act well when there are many surveys! ]
	 * @result	[survayTypeStatMap that contain key -survay type ;value -all the statistics that needed ]
 	 * @createdBy  	Menash Yamin.        
	 */
	private void initStatic ()
	{
		this.survayTypeStatMap = VO_SurvayTypeStat.initSurvayTypeStatMap(permissionToSeeSurveyTypeList);
		this.latestSurvayTypeStatMap = VO_SurvayTypeStat.initSurvayTypeStatMap(permissionToSeeSurveyTypeList);
		this.surveyTypeOrderingByCS = initSurveyTypeOrderingByCS(this.survayTypeStatMap.keySet());
		if(VO_Utils.MS_USE_BATCH)
		{
			mainStatisticBatchSolution();
		}
		else
		{
			mainStatisticOldSolution();
		}
		
	}
	/**
	 * [mainStatisticBatchSolution calc statisitic by BATCH]
	 */
	private void mainStatisticBatchSolution()
	{
		initSurveyTypeDataByStores();
	}

	/**
	 * [mainStatisticOldSolution 
	 * old sol-with the AggregateResult on all the surveys -bad sol when we have many surveys]
	 */
	private void mainStatisticOldSolution()
	{
		try 
		{	        
			List<AggregateResult> results = retSurvayData(permissionToSeeSurveyTypeList);
			List<AggregateResult> lastResults = retLastSurvayData(permissionToSeeSurveyTypeList);

			VO_SurvayTypeStat.updatesurvayTypeStatMap (this.survayTypeStatMap, results);
			VO_SurvayTypeStat.updatesurvayTypeStatMap (this.latestSurvayTypeStatMap, lastResults);


			List<AggregateResult> resultsLastNdays = retSurvayDataInTheLastNdays(permissionToSeeSurveyTypeList);
			VO_SurvayTypeStat.updatesurvayTypeStatMapForLastNdays(this.survayTypeStatMap, resultsLastNdays);
		}
		catch (Exception e)
		{

			throw e;
		}
	}

	/**
	 * @scenario	[Soql on survays that created in the last month ]
	 * @result	[ list of AggregateResult of that data ]
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 20.09.15
	 */
	private static List<AggregateResult> retLastSurvayData (List<String> permissionToSeeSurveyTypeList){
		Date fromm = date.today().addMonths(-LastMonth);

		List<AggregateResult> results = [SELECT COUNT(Id), SurveyType__c, Status__c, Type__c
										 FROM VO_Survey__c
										 WHERE AnswerDate__c > :fromm
										 AND SurveyType__c IN:permissionToSeeSurveyTypeList
										 AND store__c !=Null
										 GROUP BY SurveyType__c, Status__c, Type__c];
		System.debug('results : :' + results);
		return results;
	}



	/**
	 * @scenario	[Soql on survays that created in the past N months ]
	 * @result	[ list of AggregateResult of that data ]
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 20.09.15
	 */
	private static List<AggregateResult> retSurvayData (List<String> permissionToSeeSurveyTypeList){
		Date d = date.today().addMonths(-VO_Utils.LAST_n_MONTHS);

		List<AggregateResult> results = [SELECT COUNT(Id), SurveyType__c, Status__c, Type__c
										 FROM VO_Survey__c
										 WHERE AnswerDate__c > :d
										 AND SurveyType__c IN:permissionToSeeSurveyTypeList
										 AND store__c !=Null
										 GROUP BY SurveyType__c, Status__c, Type__c];
		System.debug('results : :' + results);
		return results;
	}
	
	/**
	 * @scenario	[Soql on survays that created in the past N months and M days from now  ]
	 * @result	[ list of AggregateResult of that data ]
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 20.09.15
	 */
	private static List<AggregateResult> retSurvayDataInTheLastNdays (List<String> permissionToSeeSurveyTypeList){
		Date dDays = date.today().addDays(-VO_Utils.BEFORE_n_DAYS);
		Date dMonth = date.today().addMonths(-VO_Utils.LAST_n_MONTHS);
		System.debug('results dDays : :' + dDays);
		System.debug('results dMonth : :' + dMonth);
		List<AggregateResult> results = [SELECT COUNT(Id), SurveyType__c, Status__c, Type__c
										 FROM VO_Survey__c
										 WHERE AnswerDate__c < :dDays 
										 AND AnswerDate__c > :dMonth
										 AND store__c !=Null
										 AND SurveyType__c IN:permissionToSeeSurveyTypeList
										 GROUP BY SurveyType__c, Status__c, Type__c];
		System.debug('results : :' + results);
		return results;
	}

	//Batch using
	/**
	 * [initSurveyTypeDataByStores Aggregate the results by query on all stores
	 * ]
	 */
	private void initSurveyTypeDataByStores()
	{
		List<AggregateResult> allStoresList = new List<AggregateResult> ();
		List<AggregateResult> allStoresPartTwoList = new List<AggregateResult> ();
		try
		{
			allStoresList = database.query(queryStoreCreator());
			allStoresPartTwoList = database.query(queryStoreCreatorPart2());//Need another query because we have limit of 100 fields and the first one reach that
			if(allStoresPartTwoList.size()>0)
			{
				allStoresList.add(allStoresPartTwoList[0]);
			}
		}
		catch (Exception e)
		{
			throw e;
		}

		if(!allStoresList.isEmpty())
		{
			updatesurvayTypeStatMapByStores(allStoresList);
		}
	}

	/**
	 * [initStoreToZeroForAllMSfields description]
	 * @param  aggreateStore [new Store object ]
	 * @return               [the param store after put zero in all MS fields]
	 */
	public static Store__c initStoreToZeroForAllMSfields(Store__c aggreateStore)
	{
		aggreateStore.MS_Sales_Total__C = 0;
		aggreateStore.MS_Sales_New__C = 0;
		aggreateStore.MS_Sales_Pending__C = 0; 
		aggreateStore.MS_Sales_Closed__C = 0; 
		aggreateStore.MS_Sales_NoAction__C = 0; 
		aggreateStore.MS_Sales_dcNew__C = 0; 
		aggreateStore.MS_Sales_dcPending__C = 0; 
		aggreateStore.MS_Sales_pmNew__C = 0; 
		aggreateStore.MS_Sales_pmPending__C = 0; 
		aggreateStore.MS_Sales_raNew__C = 0; 
		aggreateStore.MS_Sales_raPending__C = 0; 
		aggreateStore.MS_Sales_raPending7D__C = 0;
		aggreateStore.MS_AS_raPending7D__C = 0 ;

		aggreateStore.MS_AS_Total__C = 0; 
		aggreateStore.MS_AS_New__C = 0; 
		aggreateStore.MS_AS_Pending__C  = 0; 
		aggreateStore.MS_AS_Closed__C = 0; 
		aggreateStore.MS_AS_NoAction__C = 0; 
		aggreateStore.MS_AS_dcNew__C = 0; 
		aggreateStore.MS_AS_dcPending__C = 0; 
		aggreateStore.MS_AS_pmNew__C = 0; 
		aggreateStore.MS_AS_pmPending__C = 0; 
		aggreateStore.MS_AS_raNew__C = 0; 
		aggreateStore.MS_AS_raPending__C = 0; 
		aggreateStore.MS_WS_Total__C = 0; 
		aggreateStore.MS_WS_New__C = 0; 
		aggreateStore.MS_WS_Pending__C = 0; 
		aggreateStore.MS_WS_Closed__C = 0; 
		aggreateStore.MS_WS_NoAction__C = 0; 
		aggreateStore.MS_WS_dcNew__C = 0; 
		aggreateStore.MS_WS_dcPending__C = 0; 
		aggreateStore.MS_WS_pmNew__C = 0; 
		aggreateStore.MS_WS_pmPending__C = 0; 
		aggreateStore.MS_WS_raNew__C = 0; 
	 	aggreateStore.MS_WS_raPending__C = 0; 
	    aggreateStore.MS_WS_raPending7D__C = 0; 
	    aggreateStore.MS_CSC_Total__C = 0; 
		aggreateStore.MS_CSC_New__C = 0; 
		aggreateStore.MS_CSC_Pending__C = 0; 
		aggreateStore.MS_CSC_Closed__C = 0; 
		aggreateStore.MS_CSC_NoAction__C = 0; 
		aggreateStore.MS_CSC_dcNew__C = 0; 
		aggreateStore.MS_CSC_dcPending__C = 0; 
		aggreateStore.MS_CSC_pmNew__C = 0; 
		aggreateStore.MS_CSC_pmPending__C = 0; 
		aggreateStore.MS_CSC_raNew__C = 0; 
		aggreateStore.MS_CSC_raPending__C = 0; 
		aggreateStore.MS_CSC_raPending7D__C = 0; 
		aggreateStore.MS_Sales_Total_LastMonth__C = 0; 
	    aggreateStore.MS_CSC_Total_LastMonth__C = 0; 
	    aggreateStore.MS_Sales_raNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_CSC_dcNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_Sales_pmNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_CSC_pmNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_Sales_dcNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_CSC_raNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_AS_Total_LastMonth__C = 0; 
	    aggreateStore.MS_WS_Total_LastMonth__C  = 0; 
	    aggreateStore.MS_AS_dcNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_WS_dcNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_AS_pmNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_WS_pmNewAndPending_LastMonth__C = 0; 
	    aggreateStore.MS_AS_raNewAndPending_LastMonth__C = 0; 
		aggreateStore.MS_WS_raNewAndPending_LastMonth__C = 0;
		
		aggreateStore.MS_Sales_Detractor_NPS__c = 0;
		aggreateStore.MS_Sales_Promotor_NPS__c = 0;
		aggreateStore.MS_AS_Detractor_NPS__c = 0;
		aggreateStore.MS_AS_Promotor_NPS__c = 0;
		aggreateStore.MS_WS_Detractor_NPS__c = 0;
		aggreateStore.MS_WS_Promotor_NPS__c = 0;
		aggreateStore.MS_CSC_Detractor_NPS__c = 0;
		aggreateStore.MS_CSC_Promotor_NPS__c = 0;
		aggreateStore.MS_Sales_Promotor_NPS_LastMonth__c = 0;
		aggreateStore.MS_Sales_Detractor_NPS_LastMonth__c = 0;
		aggreateStore.MS_CSC_Promotor_NPS_LastMonth__c = 0;
		aggreateStore.MS_CSC_Detractor_NPS_LastMonth__c = 0;
		aggreateStore.MS_AS_Promotor_NPS_LastMonth__c = 0;
		aggreateStore.MS_AS_Detractor_NPS_LastMonth__c = 0;
		aggreateStore.MS_WS_Promotor_NPS_LastMonth__c = 0;
		aggreateStore.MS_WS_Detractor_NPS_LastMonth__c = 0;

		//MY 24.11.2015 :  new calc of types precentes in 24/11
		aggreateStore.MS_Sales_Total_DC__c = 0;
		aggreateStore.MS_Sales_Total_RA__c = 0;
		aggreateStore.MS_Sales_Total_PR__c = 0;

		aggreateStore.MS_WS_Total_DC__c = 0;
		aggreateStore.MS_WS_Total_RA__c = 0;
		aggreateStore.MS_WS_Total_PR__c = 0;

		aggreateStore.MS_AS_Total_DC__c = 0;
		aggreateStore.MS_AS_Total_RA__c = 0;
		aggreateStore.MS_AS_Total_PR__c = 0;
		
		aggreateStore.MS_CSC_Total_DC__c = 0;
		aggreateStore.MS_CSC_Total_RA__c = 0;
		aggreateStore.MS_CSC_Total_PR__c = 0;

		aggreateStore.MS_Sales_Total_DC_Last_Month__c = 0;
		aggreateStore.MS_Sales_Total_RA_Last_Month__c = 0;
		aggreateStore.MS_Sales_Total_PR_Last_Month__c = 0;
		
		aggreateStore.MS_WS_Total_DC_Last_Month__c = 0;
		aggreateStore.MS_WS_Total_RA_Last_Month__c = 0;
		aggreateStore.MS_WS_Total_PR_Last_Month__c = 0;
		
		aggreateStore.MS_AS_Total_DC_Last_Month__c = 0;
		aggreateStore.MS_AS_Total_RA_Last_Month__c = 0;
		aggreateStore.MS_AS_Total_PR_Last_Month__c = 0;
		
		
		aggreateStore.MS_CSC_Total_DC_Last_Month__c = 0;
		aggreateStore.MS_CSC_Total_RA_Last_Month__c = 0;
		aggreateStore.MS_CSC_Total_PR_Last_Month__c = 0;
		
		return aggreateStore;
		
	}

/**
 * [createAndInitAggreateStore : return store object after initilize all the MS fields to zero]
 * @return [return store object after init  ]
 */
	private Store__c createAndInitAggreateStore()
	{
		Store__c aggreateStore = new Store__c();	
		aggreateStore = initStoreToZeroForAllMSfields(aggreateStore);
		return aggreateStore;
	}

/**
 * [aggrateFromAllStoresPartTwo in this func we sum up all the result from the AggregateResult query into 
 * our demi Store object.
 * part two - for the second query (that we had to do beacuse we have more then 100 fields in the first) ]
 * @param aggreateStore [The store that will have in the end all the MS data after all the calc]
 * @param allStoresList [AggregateResult of a query about all the stores]
 */
	private void aggrateFromAllStoresPartTwo(Store__c aggreateStore,AggregateResult allStoresList)
	{
		aggreateStore.MS_Sales_Total_DC__c  += (allStoresList.get('expr0') == null) ? 0 : Integer.valueOf(allStoresList.get('expr0'));
		aggreateStore.MS_Sales_Total_RA__c  += (allStoresList.get('expr1') == null) ? 0 : Integer.valueOf(allStoresList.get('expr1'));
		aggreateStore.MS_Sales_Total_PR__c += (allStoresList.get('expr2') == null) ? 0 : Integer.valueOf(allStoresList.get('expr2'));

		aggreateStore.MS_WS_Total_DC__c  += (allStoresList.get('expr3') == null) ? 0 : Integer.valueOf(allStoresList.get('expr3'));
		aggreateStore.MS_WS_Total_RA__c  += (allStoresList.get('expr4') == null) ? 0 : Integer.valueOf(allStoresList.get('expr4'));
		aggreateStore.MS_WS_Total_PR__c  += (allStoresList.get('expr5') == null) ? 0 : Integer.valueOf(allStoresList.get('expr5'));

		aggreateStore.MS_AS_Total_DC__c  += (allStoresList.get('expr6') == null) ? 0 : Integer.valueOf(allStoresList.get('expr6'));
		aggreateStore.MS_AS_Total_RA__c  += (allStoresList.get('expr7') == null) ? 0 : Integer.valueOf(allStoresList.get('expr7'));
		aggreateStore.MS_AS_Total_PR__c  += (allStoresList.get('expr8') == null) ? 0 : Integer.valueOf(allStoresList.get('expr8'));
		
		aggreateStore.MS_CSC_Total_DC__c  += (allStoresList.get('expr9') == null) ? 0 : Integer.valueOf(allStoresList.get('expr9'));
		aggreateStore.MS_CSC_Total_RA__c  += (allStoresList.get('expr10') == null) ? 0 : Integer.valueOf(allStoresList.get('expr10'));
		aggreateStore.MS_CSC_Total_PR__c  += (allStoresList.get('expr11') == null) ? 0 : Integer.valueOf(allStoresList.get('expr11'));

		aggreateStore.MS_Sales_Total_DC_Last_Month__c  += (allStoresList.get('expr12') == null) ? 0 : Integer.valueOf(allStoresList.get('expr12'));
		aggreateStore.MS_Sales_Total_RA_Last_Month__c  += (allStoresList.get('expr13') == null) ? 0 : Integer.valueOf(allStoresList.get('expr13'));
		aggreateStore.MS_Sales_Total_PR_Last_Month__c  += (allStoresList.get('expr14') == null) ? 0 : Integer.valueOf(allStoresList.get('expr14'));
		
		aggreateStore.MS_WS_Total_DC_Last_Month__c  += (allStoresList.get('expr15') == null) ? 0 : Integer.valueOf(allStoresList.get('expr15'));
		aggreateStore.MS_WS_Total_RA_Last_Month__c  += (allStoresList.get('expr16') == null) ? 0 : Integer.valueOf(allStoresList.get('expr16'));
		aggreateStore.MS_WS_Total_PR_Last_Month__c  += (allStoresList.get('expr17') == null) ? 0 : Integer.valueOf(allStoresList.get('expr17'));
		
		aggreateStore.MS_AS_Total_DC_Last_Month__c  += (allStoresList.get('expr18') == null) ? 0 : Integer.valueOf(allStoresList.get('expr18'));
		aggreateStore.MS_AS_Total_RA_Last_Month__c  += (allStoresList.get('expr19') == null) ? 0 : Integer.valueOf(allStoresList.get('expr19'));
		aggreateStore.MS_AS_Total_PR_Last_Month__c  += (allStoresList.get('expr20') == null) ? 0 : Integer.valueOf(allStoresList.get('expr20'));
		
		
		aggreateStore.MS_CSC_Total_DC_Last_Month__c  += (allStoresList.get('expr21') == null) ? 0 : Integer.valueOf(allStoresList.get('expr21'));
		aggreateStore.MS_CSC_Total_RA_Last_Month__c  += (allStoresList.get('expr22') == null) ? 0 : Integer.valueOf(allStoresList.get('expr22'));
		aggreateStore.MS_CSC_Total_PR_Last_Month__c  += (allStoresList.get('expr23') == null) ? 0 : Integer.valueOf(allStoresList.get('expr23'));

	}

/**
 * [aggrateFromAllStoresPartTwo in this func we sum up all the result from the AggregateResult query into 
 * our demi Store object. ]
 * @param aggreateStore [The store that will have in the end all the MS data after all the calc]
 * @param allStoresList [AggregateResult of a query about all the stores]
 */
	private void aggrateFromAllStores(Store__c aggreateStore,AggregateResult allStoresList)
	{
		System.debug('allStoresList : : : ' + allStoresList); 
		aggreateStore.MS_Sales_Total__C += (allStoresList.get('expr0') == null) ? 0 : Integer.valueOf(allStoresList.get('expr0'));
		aggreateStore.MS_Sales_New__C += (allStoresList.get('expr1') == null) ? 0 : Integer.valueOf(allStoresList.get('expr1'));
		aggreateStore.MS_Sales_Pending__C += (allStoresList.get('expr2') == null) ? 0 : Integer.valueOf(allStoresList.get('expr2')); 
		aggreateStore.MS_Sales_Closed__C += (allStoresList.get('expr3') == null) ? 0 : Integer.valueOf(allStoresList.get('expr3')); 
		aggreateStore.MS_Sales_NoAction__C += (allStoresList.get('expr4') == null) ? 0 : Integer.valueOf(allStoresList.get('expr4')); 
		aggreateStore.MS_Sales_dcNew__C += (allStoresList.get('expr5') == null) ? 0 : Integer.valueOf(allStoresList.get('expr5'));
		aggreateStore.MS_Sales_dcPending__C += (allStoresList.get('expr6') == null) ? 0 : Integer.valueOf(allStoresList.get('expr6')); 
		aggreateStore.MS_Sales_pmNew__C += (allStoresList.get('expr7') == null) ? 0 : Integer.valueOf(allStoresList.get('expr7')); 
		aggreateStore.MS_Sales_pmPending__C += (allStoresList.get('expr8') == null) ? 0 : Integer.valueOf(allStoresList.get('expr8'));
		aggreateStore.MS_Sales_raNew__C += (allStoresList.get('expr9') == null) ? 0 : Integer.valueOf(allStoresList.get('expr9'));
		aggreateStore.MS_Sales_raPending__C += (allStoresList.get('expr10') == null) ? 0 : Integer.valueOf(allStoresList.get('expr10')); 
		aggreateStore.MS_Sales_raPending7D__C += (allStoresList.get('expr11') == null) ? 0 : Integer.valueOf(allStoresList.get('expr11')); 
		
		aggreateStore.MS_AS_Total__C += (allStoresList.get('expr12') == null) ? 0 : Integer.valueOf(allStoresList.get('expr12'));
		aggreateStore.MS_AS_New__C += (allStoresList.get('expr13') == null) ? 0 : Integer.valueOf(allStoresList.get('expr13'));
		aggreateStore.MS_AS_Pending__C  += (allStoresList.get('expr14') == null) ? 0 : Integer.valueOf(allStoresList.get('expr14'));
		aggreateStore.MS_AS_Closed__C += (allStoresList.get('expr15') == null) ? 0 : Integer.valueOf(allStoresList.get('expr15'));
		aggreateStore.MS_AS_NoAction__C += (allStoresList.get('expr16') == null) ? 0 : Integer.valueOf(allStoresList.get('expr16')); 
		aggreateStore.MS_AS_dcNew__C += (allStoresList.get('expr17') == null) ? 0 : Integer.valueOf(allStoresList.get('expr17'));
		aggreateStore.MS_AS_dcPending__C += (allStoresList.get('expr18') == null) ? 0 : Integer.valueOf(allStoresList.get('expr18')); 
		aggreateStore.MS_AS_pmNew__C += (allStoresList.get('expr19') == null) ? 0 : Integer.valueOf(allStoresList.get('expr19')); 
		aggreateStore.MS_AS_pmPending__C += (allStoresList.get('expr20') == null) ? 0 : Integer.valueOf(allStoresList.get('expr20'));
		aggreateStore.MS_AS_raNew__C += (allStoresList.get('expr21') == null) ? 0 : Integer.valueOf(allStoresList.get('expr21'));
		aggreateStore.MS_AS_raPending__C += (allStoresList.get('expr22') == null) ? 0 : Integer.valueOf(allStoresList.get('expr22'));
	 	aggreateStore.MS_AS_raPending7D__C += (allStoresList.get('expr23') == null) ? 0 : Integer.valueOf(allStoresList.get('expr23')); 
		
		aggreateStore.MS_WS_Total__C += (allStoresList.get('expr24') == null) ? 0 : Integer.valueOf(allStoresList.get('expr24'));
		aggreateStore.MS_WS_New__C += (allStoresList.get('expr25') == null) ? 0 : Integer.valueOf(allStoresList.get('expr25'));
		aggreateStore.MS_WS_Pending__C += (allStoresList.get('expr26') == null) ? 0 : Integer.valueOf(allStoresList.get('expr26'));
		aggreateStore.MS_WS_Closed__C += (allStoresList.get('expr27') == null) ? 0 : Integer.valueOf(allStoresList.get('expr27'));
		aggreateStore.MS_WS_NoAction__C += (allStoresList.get('expr28') == null) ? 0 : Integer.valueOf(allStoresList.get('expr28'));
		aggreateStore.MS_WS_dcNew__C += (allStoresList.get('expr29') == null) ? 0 : Integer.valueOf(allStoresList.get('expr29')); 
		aggreateStore.MS_WS_dcPending__C += (allStoresList.get('expr30') == null) ? 0 : Integer.valueOf(allStoresList.get('expr30')); 
		aggreateStore.MS_WS_pmNew__C += (allStoresList.get('expr31') == null) ? 0 : Integer.valueOf(allStoresList.get('expr31'));
		aggreateStore.MS_WS_pmPending__C += (allStoresList.get('expr32') == null) ? 0 : Integer.valueOf(allStoresList.get('expr32'));
		aggreateStore.MS_WS_raNew__C += (allStoresList.get('expr33') == null) ? 0 : Integer.valueOf(allStoresList.get('expr33'));
	 	aggreateStore.MS_WS_raPending__C += (allStoresList.get('expr34') == null) ? 0 : Integer.valueOf(allStoresList.get('expr34'));
	    aggreateStore.MS_WS_raPending7D__C += (allStoresList.get('expr35') == null) ? 0 : Integer.valueOf(allStoresList.get('expr35')); 
	    
	    aggreateStore.MS_CSC_Total__C += (allStoresList.get('expr36') == null) ? 0 : Integer.valueOf(allStoresList.get('expr36')); 
		aggreateStore.MS_CSC_New__C += (allStoresList.get('expr37') == null) ? 0 : Integer.valueOf(allStoresList.get('expr37'));
		aggreateStore.MS_CSC_Pending__C += (allStoresList.get('expr38') == null) ? 0 : Integer.valueOf(allStoresList.get('expr38'));
		aggreateStore.MS_CSC_Closed__C += (allStoresList.get('expr39') == null) ? 0 : Integer.valueOf(allStoresList.get('expr39'));
		aggreateStore.MS_CSC_NoAction__C += (allStoresList.get('expr40') == null) ? 0 : Integer.valueOf(allStoresList.get('expr40'));
		aggreateStore.MS_CSC_dcNew__C += (allStoresList.get('expr41') == null) ? 0 : Integer.valueOf(allStoresList.get('expr41')); 
		aggreateStore.MS_CSC_dcPending__C += (allStoresList.get('expr42') == null) ? 0 : Integer.valueOf(allStoresList.get('expr42')); 
		aggreateStore.MS_CSC_pmNew__C += (allStoresList.get('expr43') == null) ? 0 : Integer.valueOf(allStoresList.get('expr43'));
		aggreateStore.MS_CSC_pmPending__C += (allStoresList.get('expr44') == null) ? 0 : Integer.valueOf(allStoresList.get('expr44')); 
		aggreateStore.MS_CSC_raNew__C += (allStoresList.get('expr45') == null) ? 0 : Integer.valueOf(allStoresList.get('expr45'));
		aggreateStore.MS_CSC_raPending__C += (allStoresList.get('expr46') == null) ? 0 : Integer.valueOf(allStoresList.get('expr46')); 
		aggreateStore.MS_CSC_raPending7D__C += (allStoresList.get('expr47') == null) ? 0 : Integer.valueOf(allStoresList.get('expr47')); 
		
		aggreateStore.MS_Sales_Total_LastMonth__C += (allStoresList.get('expr48') == null) ? 0 : Integer.valueOf(allStoresList.get('expr48')); 
	    aggreateStore.MS_CSC_Total_LastMonth__C += (allStoresList.get('expr49') == null) ? 0 : Integer.valueOf(allStoresList.get('expr49'));

	    aggreateStore.MS_Sales_raNewAndPending_LastMonth__C += (allStoresList.get('expr50') == null) ? 0 : Integer.valueOf(allStoresList.get('expr50')); 
	    
	    aggreateStore.MS_CSC_dcNewAndPending_LastMonth__C += (allStoresList.get('expr51') == null) ? 0 : Integer.valueOf(allStoresList.get('expr51'));
	    aggreateStore.MS_Sales_pmNewAndPending_LastMonth__C += (allStoresList.get('expr52') == null) ? 0 : Integer.valueOf(allStoresList.get('expr52')); 
	    aggreateStore.MS_CSC_pmNewAndPending_LastMonth__C += (allStoresList.get('expr53') == null) ? 0 : Integer.valueOf(allStoresList.get('expr53'));
	    
	    aggreateStore.MS_Sales_dcNewAndPending_LastMonth__C += (allStoresList.get('expr54') == null) ? 0 : Integer.valueOf(allStoresList.get('expr54')); 
	    aggreateStore.MS_CSC_raNewAndPending_LastMonth__C += (allStoresList.get('expr55') == null) ? 0 : Integer.valueOf(allStoresList.get('expr55'));
	    aggreateStore.MS_AS_Total_LastMonth__C += (allStoresList.get('expr56') == null) ? 0 : Integer.valueOf(allStoresList.get('expr56'));
	    
	    aggreateStore.MS_WS_Total_LastMonth__C  += (allStoresList.get('expr57') == null) ? 0 : Integer.valueOf(allStoresList.get('expr57'));
	    
	    aggreateStore.MS_AS_dcNewAndPending_LastMonth__C += (allStoresList.get('expr58') == null) ? 0 : Integer.valueOf(allStoresList.get('expr58')); 
	    aggreateStore.MS_WS_dcNewAndPending_LastMonth__C += (allStoresList.get('expr59') == null) ? 0 : Integer.valueOf(allStoresList.get('expr59'));
	    
	    aggreateStore.MS_AS_pmNewAndPending_LastMonth__C += (allStoresList.get('expr60') == null) ? 0 : Integer.valueOf(allStoresList.get('expr60')); 
	    aggreateStore.MS_WS_pmNewAndPending_LastMonth__C += (allStoresList.get('expr61') == null) ? 0 : Integer.valueOf(allStoresList.get('expr61')); 
	    aggreateStore.MS_AS_raNewAndPending_LastMonth__C += (allStoresList.get('expr62') == null) ? 0 : Integer.valueOf(allStoresList.get('expr62'));
		aggreateStore.MS_WS_raNewAndPending_LastMonth__C += (allStoresList.get('expr63') == null) ? 0 : Integer.valueOf(allStoresList.get('expr63'));
	
		aggreateStore.MS_Sales_Detractor_NPS__c += (allStoresList.get('expr64') == null) ? 0 : Integer.valueOf(allStoresList.get('expr64')); 
	    aggreateStore.MS_Sales_Promotor_NPS__c += (allStoresList.get('expr65') == null) ? 0 : Integer.valueOf(allStoresList.get('expr65')); 
	    aggreateStore.MS_AS_Detractor_NPS__c += (allStoresList.get('expr66') == null) ? 0 : Integer.valueOf(allStoresList.get('expr66'));
		aggreateStore.MS_AS_Promotor_NPS__c += (allStoresList.get('expr67') == null) ? 0 : Integer.valueOf(allStoresList.get('expr67'));
		aggreateStore.MS_WS_Detractor_NPS__c += (allStoresList.get('expr68') == null) ? 0 : Integer.valueOf(allStoresList.get('expr68')); 
	    aggreateStore.MS_WS_Promotor_NPS__c += (allStoresList.get('expr69') == null) ? 0 : Integer.valueOf(allStoresList.get('expr69')); 
	    aggreateStore.MS_CSC_Detractor_NPS__c += (allStoresList.get('expr70') == null) ? 0 : Integer.valueOf(allStoresList.get('expr70'));
		aggreateStore.MS_CSC_Promotor_NPS__c += (allStoresList.get('expr71') == null) ? 0 : Integer.valueOf(allStoresList.get('expr71'));

		aggreateStore.MS_Sales_Promotor_NPS_LastMonth__c += (allStoresList.get('expr72') == null) ? 0 : Integer.valueOf(allStoresList.get('expr72')); 
	    aggreateStore.MS_Sales_Detractor_NPS_LastMonth__c += (allStoresList.get('expr73') == null) ? 0 : Integer.valueOf(allStoresList.get('expr73')); 
	    aggreateStore.MS_CSC_Promotor_NPS_LastMonth__c += (allStoresList.get('expr74') == null) ? 0 : Integer.valueOf(allStoresList.get('expr74'));
		aggreateStore.MS_CSC_Detractor_NPS_LastMonth__c += (allStoresList.get('expr75') == null) ? 0 : Integer.valueOf(allStoresList.get('expr75'));
		aggreateStore.MS_AS_Promotor_NPS_LastMonth__c += (allStoresList.get('expr76') == null) ? 0 : Integer.valueOf(allStoresList.get('expr76')); 
	    aggreateStore.MS_AS_Detractor_NPS_LastMonth__c += (allStoresList.get('expr77') == null) ? 0 : Integer.valueOf(allStoresList.get('expr77')); 
	    aggreateStore.MS_WS_Promotor_NPS_LastMonth__c += (allStoresList.get('expr78') == null) ? 0 : Integer.valueOf(allStoresList.get('expr78'));
		aggreateStore.MS_WS_Detractor_NPS_LastMonth__c += (allStoresList.get('expr79') == null) ? 0 : Integer.valueOf(allStoresList.get('expr79'));


		List<String> fieldsPerSurveyType = new List<String> {'Total__C','New__C','Pending__C','Closed__C','NoAction__C'};
		List<String> surveyTypeShortCut = 
											new List<String> {'Sales_','AS_','WS_','CSC_'};
		String  kpiStr = '';
		kpiStr = '\nTotal__C + New__C  Pending__C  Closed__C NoAction__C\n\n';
										
		for(String surT : surveyTypeShortCut)
		{
			kpiStr += ' \nSurveyType: '+ surT + '\n';
			for(String field : fieldsPerSurveyType)
			{
				kpiStr += aggreateStore.get('MS_'+surT+field) + ' ';
			}
			kpiStr += '\n\n';
		}


	}

	/**
	 * [updatesurvayTypeStatMapByStores put all the result from allStoresList List and 
	 * save the result in a Store sObject that sum up all those result in is MS fields]
	 * @param allStoresList [description]
	 */
	private void updatesurvayTypeStatMapByStores(List<AggregateResult> allStoresList)
	{
		Store__c aggreateStore = createAndInitAggreateStore();
		aggrateFromAllStores(aggreateStore, allStoresList[0]);
		if(allStoresList.size()>0)
		{
			aggrateFromAllStoresPartTwo(aggreateStore, allStoresList[1]);
		}		
		surveyTypeToSurveyData(aggreateStore);
	}

/**
 * [insertDataToSurvayTypeStat update the VO_SurvayTypeStat of the corresponding surveyType in the surveyTypeToSurveyMap]
 * @param surveyType         [survey type we are working on]
 * @param surveyTypeToSurvey [map from survey type to the VO_SurvayTypeStat object of him]
 * @param aggreateStore      [the store that aggragate all the statisic from all types and crossing ]
 */
	private void insertDataToSurvayTypeStat(String surveyType, Map<String,VO_SurvayTypeStat> surveyTypeToSurvey ,Store__c aggreateStore )
	{

		Map<String,String> surveyTypeToSurveyTypeFieldName = 
											new map<String,String> {VO_Utils.VOICE_SALES => 'Sales_', 
																	VO_Utils.VOICE_AFTER_SALES => 'AS_', 
											 						VO_Utils.VOICE_WEB_SALES => 'WS_', 
											 						VO_Utils.VOICE_CSC_SALES => 'CSC_'};

		Map<String,String> typeToTypeFieldName = new map<String,String> { VO_Utils.VOICE_SURVEY_TYPE_SALES_PROMOTER => 'pm', 
																		  VO_Utils.VOICE_SURVEY_TYPE_RECOVERY_ACT=>'ra',
																		  VO_Utils.VOICE_SURVEY_TYPE_DELIGHTED_CLIENT =>'dc'};
		
		VO_SurvayTypeStat currSurveyTypeStat= surveyTypeToSurvey.get(surveyType);
        
        currSurveyTypeStat.title = surveyType;
		currSurveyTypeStat.survayTypeUrl = surveyType.replace(' ', '_');

		currSurveyTypeStat.pmNew = 			 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'pmNew__c'));
		currSurveyTypeStat.pmPending = 		 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'pmPending__c'));
		
		//MY 24.11.2015 :  new calc of types precentes in 24/11
		currSurveyTypeStat.promoterClients = Integer.valueOf(aggreateStore.get('MS_' +  surveyTypeToSurveyTypeFieldName.get(surveyType)+ 'Total_PR__c'));

		currSurveyTypeStat.total = 			 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Total__c'));
        currSurveyTypeStat.tNew = 			 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'New__c'));
        currSurveyTypeStat.tPending = 		 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Pending__c'));
        currSurveyTypeStat.tClosed = 		 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Closed__c'));
        currSurveyTypeStat.tNoAaction = 	 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'NoAction__c'));
        
        currSurveyTypeStat.dcNew = 			 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'dcNew__c'));
        currSurveyTypeStat.dcPending = 		 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'dcPending__c'));
		
		//MY 24.11.2015 :  new calc of types precentes in 24/11
		currSurveyTypeStat.delightedClients =Integer.valueOf(aggreateStore.get('MS_' +  surveyTypeToSurveyTypeFieldName.get(surveyType)+ 'Total_DC__c'));


        currSurveyTypeStat.raNew = 			 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'raNew__c'));
        currSurveyTypeStat.raPending = 		 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'raPending__c'));
		
		//MY 24.11.2015 :  new calc of types precentes in 24/11		
		currSurveyTypeStat.recoveryAct = Integer.valueOf(aggreateStore.get('MS_' +  surveyTypeToSurveyTypeFieldName.get(surveyType)+ 'Total_RA__c'));


        currSurveyTypeStat.raPending7D = 	 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'raPending7D__c'));
        currSurveyTypeStat.tDetractor = 	 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Detractor_NPS__c'));
        currSurveyTypeStat.tPromotor = 		 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Promotor_NPS__c'));

        currSurveyTypeStat.totalNmonth =  	 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Total_LastMonth__c'));
        currSurveyTypeStat.tNDetractor = 	 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Detractor_NPS_LastMonth__c'));
        currSurveyTypeStat.tNPromotor = 	 Integer.valueOf(aggreateStore.get('MS_' + surveyTypeToSurveyTypeFieldName.get(surveyType)+'Promotor_NPS_LastMonth__c'));

        currSurveyTypeStat.NPS = 0;
		currSurveyTypeStat.isPromoterClients = VO_Utils.VOICE_AFTER_SALES.equals(surveyType);

	} 


	/**
	 * [surveyTypeToSurveyData get from the aggreateStore the data for each survey type and update the survayTypeStatMap and the latestSurvayTypeStatMap]
	 * @param aggreateStore [Store with all the Data of the MS in his fields ]
	 */
	private void surveyTypeToSurveyData(Store__c aggreateStore)
	{
	    for(String surveyType:this.survayTypeStatMap.keySet())
	    {
	    	insertDataToSurvayTypeStat(surveyType,this.survayTypeStatMap,aggreateStore);
	    }
	    for(String surveyType:this.latestSurvayTypeStatMap.keySet())
	    {
	    	insertDataToSurvayTypeStat(surveyType,this.latestSurvayTypeStatMap,aggreateStore);
	    }  
	}

	private String queryStoreCreator()
	{
        String queryStr = 'SELECT ';
        queryStr += 'SUM(MS_Sales_Total__C), SUM(MS_Sales_New__C), 	   SUM(MS_Sales_Pending__C),  SUM(MS_Sales_Closed__C), SUM(MS_Sales_NoAction__C),';
        queryStr += 'SUM(MS_Sales_dcNew__C), SUM(MS_Sales_dcPending__C), SUM(MS_Sales_pmNew__C), 	 SUM(MS_Sales_pmPending__C), ';
        queryStr += 'SUM(MS_Sales_raNew__C), SUM(MS_Sales_raPending__C), SUM(MS_Sales_raPending7D__C),';

        queryStr += 'SUM(MS_AS_Total__C),    SUM(MS_AS_New__C),    	SUM(MS_AS_Pending__C),    SUM(MS_AS_Closed__C),    SUM(MS_AS_NoAction__C), ';
        queryStr += 'SUM(MS_AS_dcNew__C), 	SUM(MS_AS_dcPending__C), SUM(MS_AS_pmNew__C),		 SUM(MS_AS_pmPending__C), ';
        queryStr += 'SUM(MS_AS_raNew__C), 	SUM(MS_AS_raPending__C),SUM(MS_AS_raPending7D__C), ';
        
        queryStr += 'SUM(MS_WS_Total__C),    SUM(MS_WS_New__C),    	SUM(MS_WS_Pending__C),    SUM(MS_WS_Closed__C),    SUM(MS_WS_NoAction__C), ';
        queryStr += 'SUM(MS_WS_dcNew__C),	SUM(MS_WS_dcPending__C),	SUM(MS_WS_pmNew__C), SUM(MS_WS_pmPending__C) ,';
        queryStr += 'SUM(MS_WS_raNew__C), 	SUM(MS_WS_raPending__C),  SUM(MS_WS_raPending7D__C),';

        queryStr += 'SUM(MS_CSC_Total__C),   SUM(MS_CSC_New__C),   	   SUM(MS_CSC_Pending__C),   SUM(MS_CSC_Closed__C),   SUM(MS_CSC_NoAction__C),';
		queryStr += 'SUM(MS_CSC_dcNew__C),	SUM(MS_CSC_dcPending__C)  ,SUM(MS_CSC_pmNew__C),     SUM(MS_CSC_pmPending__C) ,SUM(MS_CSC_raNew__C),';
		queryStr += 'SUM(MS_CSC_raPending__C),					       SUM(MS_CSC_raPending7D__C),';
		
		queryStr += 'SUM(MS_Sales_Total_LastMonth__C),           SUM(MS_CSC_Total_LastMonth__C),             SUM(MS_Sales_raNewAndPending_LastMonth__C),';
		queryStr += 'SUM(MS_CSC_dcNewAndPending_LastMonth__C),   SUM(MS_Sales_pmNewAndPending_LastMonth__C), SUM(MS_CSC_pmNewAndPending_LastMonth__C),';
		queryStr += 'SUM(MS_Sales_dcNewAndPending_LastMonth__C), SUM(MS_CSC_raNewAndPending_LastMonth__C),   SUM(MS_AS_Total_LastMonth__C), ';
		queryStr += 'SUM(MS_WS_Total_LastMonth__C),              SUM(MS_AS_dcNewAndPending_LastMonth__C),    SUM(MS_WS_dcNewAndPending_LastMonth__C),';
		queryStr += 'SUM(MS_AS_pmNewAndPending_LastMonth__C),    SUM(MS_WS_pmNewAndPending_LastMonth__C),    SUM(MS_AS_raNewAndPending_LastMonth__C),';
		queryStr += 'SUM(MS_WS_raNewAndPending_LastMonth__C), ';

		queryStr += 'SUM(MS_Sales_Detractor_NPS__c), 	SUM(MS_Sales_Promotor_NPS__c), ';
		queryStr += 'SUM(MS_AS_Detractor_NPS__c), 		SUM(MS_AS_Promotor_NPS__c), ';
		queryStr += 'SUM(MS_WS_Detractor_NPS__c), 		SUM(MS_WS_Promotor_NPS__c) , ';
		queryStr += 'SUM(MS_CSC_Detractor_NPS__c), 		SUM(MS_CSC_Promotor_NPS__c), ';

		queryStr += 'SUM(MS_Sales_Promotor_NPS_LastMonth__c), 	SUM(MS_Sales_Detractor_NPS_LastMonth__c), ';
		queryStr += 'SUM(MS_CSC_Promotor_NPS_LastMonth__c),		SUM(MS_CSC_Detractor_NPS_LastMonth__c), ';
		queryStr += 'SUM(MS_AS_Promotor_NPS_LastMonth__c), 	 	SUM(MS_AS_Detractor_NPS_LastMonth__c), ';
		queryStr += 'SUM(MS_WS_Promotor_NPS_LastMonth__c), 	 	SUM(MS_WS_Detractor_NPS_LastMonth__c)';
		queryStr += ' FROM Store__c';
		
		return queryStr;
	}

	private String queryStoreCreatorPart2()
	{
		String queryStr = 'SELECT ';

		//MY 24.11.2015 :  new calc of types precentes in 24/11
		queryStr += 'SUM(MS_Sales_Total_DC__c), SUM(MS_Sales_Total_RA__c),SUM(MS_Sales_Total_PR__c),';
		queryStr += 'SUM(MS_WS_Total_DC__c),     SUM(MS_WS_Total_RA__c),   SUM(MS_WS_Total_PR__c),';
		queryStr += 'SUM(MS_AS_Total_DC__c),     SUM(MS_AS_Total_RA__c),   SUM(MS_AS_Total_PR__c),';
		queryStr += 'SUM(MS_CSC_Total_DC__c),    SUM(MS_CSC_Total_RA__c),  SUM(MS_CSC_Total_PR__c),';

		queryStr += 'SUM(MS_Sales_Total_DC_Last_Month__c), SUM(MS_Sales_Total_RA_Last_Month__c),SUM(MS_Sales_Total_PR_Last_Month__c),';
		queryStr += 'SUM(MS_AS_Total_DC_Last_Month__c),    SUM(MS_AS_Total_RA_Last_Month__c)   ,SUM(MS_AS_Total_PR_Last_Month__c),';
		queryStr += 'SUM(MS_WS_Total_DC_Last_Month__c),   SUM(MS_WS_Total_RA_Last_Month__c),   SUM(MS_WS_Total_PR_Last_Month__c),';
		queryStr += 'SUM(MS_CSC_Total_DC_Last_Month__c),   SUM( MS_CSC_Total_RA_Last_Month__c) ,   SUM(MS_CSC_Total_PR_Last_Month__c)';
		queryStr += ' FROM Store__c';
		
		return queryStr;

	}


	//My : Method only for inner use.
	// reset all the KPI data.
	public static void updateAllStoresMSfieldsToZero()
	{
		List<Store__c> storeList = [select id FRom Store__c ];
		system.debug('storeList size : ' + storeList.size());
		for(Store__c str : storeList)
		{
		   str = initStoreToZeroForAllMSfields(str);
		}
		update storeList;
	}
}