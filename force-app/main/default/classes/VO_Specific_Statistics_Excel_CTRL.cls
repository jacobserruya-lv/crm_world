public with sharing class VO_Specific_Statistics_Excel_CTRL {
	public String lvl1Value {get; set;}
	public String lvl2Value {get; set;}
	public String lvl3Value {get; set;}
	public String lvl4Value {get; set;}
	public String storeName {get; set;}
	public String ca {get; set;}
	public String fromDate {get; set;}
	public String toDate {get; set;}
	public String surveyType {get; set;}
	public List<VO_Survey__c> surveyList {get;set;}
	private List<Integer> answerToRepresentSortedByCSList {get;set;}
	public List<String> headerListQ {get;set;}
	public  Map<Id,VO_Survey__c> idToSurveySearchResMap {get;set;}
	public Integer amountOfsuerveyExported {get;set;}
	public List<VO_Specific_Statistics_CTRL.SurveyTable_Wrapper> surveyTable_WrapperList {get;set;}
	public User currUser{get;set;}


	public VO_Specific_Statistics_Excel_CTRL() {
		initParamtersFromPostCall();
		surveyList = getSurveysByParams();
		this.currUser = new User(MANAGEMENT_ZONE_LEVEL__c = this.lvl1Value, MGMT_ZONE_SUB_LEVEL1__c = this.lvl2Value,
								 MGMT_ZONE_SUB_LEVEL2__c = this.lvl3Value, MGMT_ZONE_SUB_LEVEL3__c = this.lvl4Value
								 , DefaultStore__c = storeName);


	}


	private void initParamtersFromPostCall()
	{
		this.lvl1Value = ApexPages.currentPage().getParameters().get('lvl1');
		this.lvl2Value = ApexPages.currentPage().getParameters().get('lvl2');
		this.lvl3Value = ApexPages.currentPage().getParameters().get('lvl3');
		this.lvl4Value = ApexPages.currentPage().getParameters().get('lvl4');
		this.storeName = ApexPages.currentPage().getParameters().get('storeName');
		this.ca = ApexPages.currentPage().getParameters().get('ca');
		this.fromDate = ApexPages.currentPage().getParameters().get('fromDate');
		this.surveyType = ApexPages.currentPage().getParameters().get('surveyType');
		this.toDate = ApexPages.currentPage().getParameters().get('toDate');
	}


	private String queryCreatorAddOnesForAns()
	{
		this.answerToRepresentSortedByCSList = VO_Specific_Statistics_CTRL.initAnswerToRepresentList(this.surveyType);
		return VO_Specific_Statistics_CTRL.addQuestionToQuery(this.answerToRepresentSortedByCSList);
	}

	private String queryCreator()
	{
		String ans='';

		ans += 'SELECT Id, SurveyType__c, Comment_History__c,SurveyComment__c, Status__c,'; 
		ans += ' Store__r.RetailStoreId__c, Store__r.Name, Type__c,';
		ans += ' AnswerDate__c, ClientName__c, DreamID__c, Segmentation__c,';
		ans += ' Channel__c, Root_Cause__c, DreamIDText__c,';
		ans += ' Action_delegated_to_CA__c, Follow_up_by__c, StoreName__c,ClientDreamID__c, createdDate';
		ans +=  queryCreatorAddOnesForAns();
		ans += ' FROM VO_Survey__c';
		ans += ' WHERE ';
		ans += ' AnswerDate__c >=: fromDatedate';
		ans += ' AND AnswerDate__c <=: toDatedate';


		if(!String.isBlank(this.surveyType ))
		{
			ans += ' AND SurveyType__c=\''+ this.surveyType + '\'';
		}
		if (!String.isBlank(this.lvl1Value ))
		{
			ans += ' AND store__r.MANAGEMENT_ZONE_LEVEL__c=\'' + this.lvl1Value  + '\'';
		}
		if (!String.isBlank(this.lvl2Value))
		{
			ans += ' AND store__r.MGMT_ZONE_SUB_LEVEL1__c=\'' + this.lvl2Value + '\'';
		}
		if (!String.isBlank(this.lvl3Value))
		{
			ans += ' AND store__r.MGMT_ZONE_SUB_LEVEL2__c=\'' + this.lvl3Value + '\'';
		}
		if (!String.isBlank(this.lvl4Value))
		{
			ans += ' AND store__r.MGMT_ZONE_SUB_LEVEL3__c=\'' + this.lvl4Value + '\'';
		}
		if (!String.isBlank(this.storeName))
		{
			ans += ' AND store__r.RetailStoreId__c=\'' + this.storeName + '\'';
		}
		if (!String.isBlank(this.ca))
		{
			ans += ' AND CAName__c=\'' + this.ca + '\'';
		}
		ans += ' ORDER BY CreatedDate DESC';
		ans += ' LIMIT ' + VO_Utils.DEFAULT_n_RESUALTS_PER_SEARCH ;


		return ans;
	}

	private List<VO_Survey__c> getSurveysByParams()
	{
		Date fromDatedate = VO_Specific_Statistics_CTRL.fromStringToDate(this.fromDate);
		Date toDatedate = VO_Specific_Statistics_CTRL.fromStringToDate(this.toDate).addDays(1);
		String queryStr = queryCreator();
		system.debug('this.queryStr : ' + queryStr);
		


		try
		{
			this.idToSurveySearchResMap = new Map<Id,VO_Survey__c>((List<VO_Survey__c>)Database.query(queryStr));
			this.headerListQ = VO_Specific_Statistics_CTRL.updateHeaderListQ(this.idToSurveySearchResMap.values(),this.answerToRepresentSortedByCSList);
			surveyTable_WrapperList = VO_Specific_Statistics_CTRL.generateSearchResToSurveyTable_Wrapper(this.idToSurveySearchResMap.values(),this.answerToRepresentSortedByCSList);
			amountOfsuerveyExported =surveyTable_WrapperList.size();
		}
		catch(DMLexception e)
		{
			amountOfsuerveyExported = 0;
			throw e;
			return null;
		}

		system.debug('this.idToSurveySearchResMap : ' + this.idToSurveySearchResMap);
		system.debug('this.headerListQ : ' + this.headerListQ);
		return null;
	}
}