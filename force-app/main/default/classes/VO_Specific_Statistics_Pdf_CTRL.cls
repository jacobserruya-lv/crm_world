public with sharing class VO_Specific_Statistics_Pdf_CTRL {
    
    public List<String> idLists {get;set;} //survey ID list
    public List<VO_Survey__c> surveyList {get;set;}  //list for soql purpose
    public User currUser {get;set;}
    public String historicalSpendOfCurrUserForPDF {get;set;}
    public Map<String,List<PPR_PurchProduct__c>> surveyIdTopurchasedProductListMap {get;set;}
    public Map<String,List<PPR_PurchProduct__c>> techPurchProductIdFromPPobjToPurchasedProductListMap {get;set;}
    public Map<String,List<VO_Feedback_Wrappers.AnswerList_Wrapper>> surveyToAnswerListWrapperMap {get;set;}
    public Map<String,List<VO_Survey__c>> surveyIdToClientSurveyListMap {get;set;}
    //private final static Integer PRODUCT_PRUCHASED_LIMIT = 200;
    private static Integer PRODUCT_PRUCHASED_LIMIT
    {
        get
        {
            return VO_Utils.PDF_PPRODUCT_LIMIT;
        }
        set;
    }
    private final static Integer CLIENT_FEEDBACK_HISTORY = 5;
    private final static  String DEFUALT_CURRENCY = 'USD';

    public String VOICE_SALES  
                                {get
                                    {return VO_Utils.VOICE_SALES ;}
                                 set;
                                }  
    public String VOICE_AFTER_SALES 
                                {get
                                    {return VO_Utils.VOICE_AFTER_SALES ;}
                                 set;
                                }  
    public String VOICE_WEB_SALES  
                                {get
                                    {return VO_Utils.VOICE_WEB_SALES ;}
                                 set;
                                }  
    public String VOICE_CSC_SALES   
                                {get
                                    {return VO_Utils.VOICE_CSC_SALES ;}
                                 set;
                                } 
    public String VOICE_CC_CSC_SALES
                                {get
                                    {return VO_Utils.VOICE_CC_CSC_SALES ;}
                                set;
                                }
    public String VOICE_CC_WEB_SALES
                                {get
                                    {return VO_Utils.VOICE_CC_WEB_SALES ;}
                                set;
                                }  
    public String VOICE_EO_SALES
                                {get
                                    {return VO_Utils.VOICE_EO_SALES ;}
                                set;
                                }   

    public List<VO_Survey__c> lastSurvey{get;set;}
    public String hostCS {
        get{
            return VO_Config__c.getValues(VO_Utils.CS_NAME_OF_HOST_NAME_CASE_DETAIL).Value__c;
        }
        private set;
    }

    public Map<String,String> fromTypeAndStatusToImagesNameMap {get;set;}

    public VO_Specific_Statistics_Pdf_CTRL() 
    {
        //MY : if - numOfIds==0 ->it's a pdf from VO_Specific_Statistics
        Integer numOfIds = initLengthOfIds();
        this.idLists = initIdLists(numOfIds);
        initSurveryPdfList(this.idLists);
        initTechPurchProductIdFromPPobjToPurchasedProductListMap();
        initUserInfo();
        initSurveyToAnswerListWrapperMap(surveyList);//FEEDBACK
        initSurveyIdToClientSurveyListMap(surveyList);//Client FEEDBACK HISTORY
        pageBreakHandling();//
        initFromTypeAndStatusToImagesName();

    }

    private void initFromTypeAndStatusToImagesName()
    {
        fromTypeAndStatusToImagesNameMap =new Map<String,String>();
        fromTypeAndStatusToImagesNameMap.put('Neutral','neutral.png');
        fromTypeAndStatusToImagesNameMap.put('Promoter','promoter.png');
        fromTypeAndStatusToImagesNameMap.put('Recovery Act','recovery.png');
        fromTypeAndStatusToImagesNameMap.put('Delighted Client','delighted.png');
        fromTypeAndStatusToImagesNameMap.put('Pending','pending.png');
        fromTypeAndStatusToImagesNameMap.put('New','new.png');
        fromTypeAndStatusToImagesNameMap.put('Closed','closed.png');
        fromTypeAndStatusToImagesNameMap.put('No action','noaction.png');
        fromTypeAndStatusToImagesNameMap.put('','');

    }

/*
    MY :CR No. 21
    31.01.2016
    Need to create page break between each survey.
    Because of restircation of the render as pdf of salesforce we will manage two lists
    one off all except the last and one only the last.
    the reason that I decided to store the last in list is because I want to take the power of the 
    repeat in case the list is empty instead to handle null var and because I want to do copy past..
 */
    private void pageBreakHandling()
    {
        if(this.surveyList.size() == 0)
        {
            this.lastSurvey = new List<VO_Survey__c>();
        }
        else if(this.surveyList.size() == 1)
        {
            this.lastSurvey = this.surveyList;
            this.surveyList = new List<VO_Survey__c>();
        }
        else if(this.surveyList.size() > 1)
        {
            this.lastSurvey = new List<VO_Survey__c>();
            this.lastSurvey.add(this.surveyList.remove(this.surveyList.size() -1));
        }

    }

    /**
     * [initSurveyToAnswerListWrapperMap key-survey ;value wrapper of answer in order to show in the pdf the answers right(multy Q and so on)]
     * @param surveyList [description]
     */
    private void initSurveyToAnswerListWrapperMap(List<VO_Survey__c> surveyList)
    {
        surveyToAnswerListWrapperMap = new Map<String,List<VO_Feedback_Wrappers.AnswerList_Wrapper>>();
        for(VO_Survey__c surv:surveyList)
        {
            surveyToAnswerListWrapperMap.put(surv.id,VO_Case_Details_CTRL.initAnswerMap(surv).values());
        }
        system.debug('## surveyToAnswerListWrapperMap: ' + surveyToAnswerListWrapperMap);
    }

    /**
     * [retClientIdToSuveryIdList map between client to survey id ]
     * @param  surveyList [that the user click on]
     */
    private Map<Id,id> retClientIdToSuveryIdList(List<VO_Survey__c> surveyList)
    {
        Map<Id,id> ansMap = new Map<Id,id>();
        for(VO_Survey__c surv:surveyList)
        {
            ansMap.put(surv.ClientDreamID__c, surv.Id);
        }
        return ansMap;
    }

/**
 * [retSurveryClintList the clients detials from the surveys]
 * @param  suveryClientIdList [the client Id of the surveys that the user want to see in pdf]
 * @return                    [description]
 */
    private List<VO_Survey__c> retSurveryClintList(Set<Id> suveryClientIdList)
    {
        List<VO_Survey__c> ansList = new List<VO_Survey__c> ();

        ansList =  [SELECT Id,Name, Action_delegated_to_CA__c,StoreID__c,StoreName__c,AnswerDate__c,Channel__c,ClientDreamID__c,ClientDreamID__r.PersonHomePhone,
                                    ClientDreamID__r.PersonMobilePhone,ClientDreamID__r.Gender__pc,ClientName__c,ClientDreamID__r.PrimaryAddressLine1__pc , Comment_History__c,
                                    DreamID__c,Follow_up_by__c,IDTransaction__c,ClientDreamID__r.AttachedStore__pc,
                                    Segmentation__c, Status__c,  Store__c,SurveyComment__c,  
                                    SurveyLanguage__c,  SurveyType__c,  Type__c ,Store__r.RetailStoreId__c,
                                    TechPurchProductKey__c,ClientDreamID__r.LastCSCClientContact__pc
                            FROM VO_Survey__c 
                            WHERE ClientDreamID__c IN: suveryClientIdList
                            ORDER BY AnswerDate__c
                            ];
        System.debug('retsurveryClintList: queryres : ' +ansList);
        return ansList;
    }

/**
 * [initSurveyIdToClientSurveyListMap map between SurveyId to ClientSurveyList(the other surveys that he did)]
 * @param surveyList [description]
 */
    private void initSurveyIdToClientSurveyListMap(List<VO_Survey__c> surveyList)
    {
        surveyIdToClientSurveyListMap = new Map<String,List<VO_Survey__c>>();
        Map<Id, Id> clientIdToSuveryIdList = retClientIdToSuveryIdList(surveyList);
        List<VO_Survey__c> surveryClintList = retSurveryClintList(clientIdToSuveryIdList.keySet());

        for(VO_Survey__c pickSurv :surveyList)
        {
            surveyIdToClientSurveyListMap.put(pickSurv.Id, new List<VO_Survey__c>());
        }

        for(VO_Survey__c surv : surveryClintList)
        {
            Id surveyToShow = clientIdToSuveryIdList.get(surv.ClientDreamID__c);
            if(surveyToShow != surv.Id 
                && surveyIdToClientSurveyListMap.get(surveyToShow).size() < CLIENT_FEEDBACK_HISTORY)
            {
                surveyIdToClientSurveyListMap.get(surveyToShow).add(surv);
            }
        }

    }
/**
 * [retPurchasedProductListBysurveyTransactionId get PurchasedProductList By surveyTransactionId]
 */
    private List<PPR_PurchProduct__c> retPurchasedProductListBysurveyTransactionId(List<String> surveyTransactionIdList)
    {
        List<PPR_PurchProduct__c> ans = new List<PPR_PurchProduct__c>();
        ans = [SELECT id, SAName__c,DreamIdSA__c, RMSCAId__c, PurchasedDate__c, Amount__c, CurrencyCode__c, 
                      Name, DesignationRepaired__c, ProductLine__c, Quantity__c, TransactionRMSId__c,
                      TransactionTotalAmount__c, TicketNumber__c, TechTransactionId__c, TechPurchProductKey__c,
                      OrderATGId__c
                      FROM PPR_PurchProduct__c 
                      WHERE TransactionRMSId__c In: surveyTransactionIdList 
                      ORDER BY PurchasedDate__c
                      LIMIT: PRODUCT_PRUCHASED_LIMIT];
        return ans;
    }
/**
 * [initSurveyTransactionIdList get the IDTransaction__c from the surveys]
 * @param  surveyList [description]
 * @return            [description]
 */
    private List<String> initSurveyTransactionIdList(List<VO_Survey__c> surveyList)
    {
        List<String> ans = new List<String>();
        for(VO_Survey__c surv:surveyList)
        {
            ans.add(surv.IDTransaction__c);
        }
        return ans;
    }

/**
 * [initSurveyTechPurchProductKey TechPurchProductKey__c his a formula fields we created - look at the spec]
 * @param  surveyList [description]
 * @return            [description]
 */
    private List<String> initSurveyTechPurchProductKey(List<VO_Survey__c> surveyList)
    { 
        List<String> ans = new List<String>();
        for(VO_Survey__c surv:surveyList)
        {
            ans.add(surv.TechPurchProductKey__c);
        }
        return ans;
    }

/**
 * [initTechPurchProductIdFromPPobjToPurchasedProductListMap matching betewnn the key to pproduct]
 */
    private void initTechPurchProductIdFromPPobjToPurchasedProductListMap()
    {
        List<PPR_PurchProduct__c> purchasedProductList ;

        List<String> surveyTransactionIdList = initSurveyTransactionIdList(surveyList);
        List<String> surveyTechPurchProductKey = initSurveyTechPurchProductKey(surveyList);
        purchasedProductList = retPurchasedProductListBysurveyTransactionId(surveyTransactionIdList);
        techPurchProductIdFromPPobjToPurchasedProductListMap = new Map<String,List<PPR_PurchProduct__c>>();

        //we have it because we don't have contias key in VFP:( 
        for(String purchProdKey :surveyTechPurchProductKey)
        {
            if(!techPurchProductIdFromPPobjToPurchasedProductListMap.containsKey(purchProdKey))
            {
                techPurchProductIdFromPPobjToPurchasedProductListMap.put(purchProdKey,new List<PPR_PurchProduct__c>());
            }
        }

        for(PPR_PurchProduct__c purchProd :purchasedProductList)
        {
            system.debug('purchProd.TechPurchProductKey__c: ' + purchProd.TechPurchProductKey__c);
            if(techPurchProductIdFromPPobjToPurchasedProductListMap.containsKey(purchProd.TechPurchProductKey__c))
            {
                techPurchProductIdFromPPobjToPurchasedProductListMap.get(purchProd.TechPurchProductKey__c).add(purchProd);
            }
        }
        System.debug('techPurchProductIdFromPPobjToPurchasedProductListMap: ' + techPurchProductIdFromPPobjToPurchasedProductListMap);
    }
/**
 * [initUserInfo in order to know which currency we need to show in the pdf]
 */
    public void initUserInfo()
    {
        List<User> userList = new List<User>();
        try
        {
            userList = [SELECT Currency__c
            FROM User
            WHERE ID=:UserInfo.getUserId()];
        }
        catch(Exception e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }
        if(!userList.isEmpty())
        {
            this.currUser = userList[0];
            if(this.currUser.Currency__c==null)
            {
                this.currUser.Currency__c = DEFUALT_CURRENCY;
            }
        }
    }
/**
 * [queryCreator create the query in order to get all the surveys objects that we need (get as param )]
 * @return [description]
 */
    private String queryCreator()
    {
        String queryStr='SELECT Id, DreamIDText__c, Action_delegated_to_CA__c,AnswerDate__c,Channel__c,ClientDreamID__c,';
        queryStr += 'ClientName__c, Comment_History__c,DreamID__c,Follow_up_by__c,IDTransaction__c,ClientDreamID__r.owner.Name,ClientDreamID__r.TECHPreferredCA__c,';
        queryStr += 'Segmentation__c,    Status__c,  Store__c,   StoreID__c, StoreName__c,SurveyComment__c,';
        queryStr += 'SurveyLanguage__c, SurveyType__c,  Type__c ,Store__r.Name,Store__r.RetailStoreId__c,';
        queryStr += 'ClientDreamID__r.DREAMID__c,ClientDreamID__r.Gender__pc,ClientDreamID__r.Segmentation__pc,ClientDreamID__r.Id,';
        queryStr += 'ClientDreamID__r.PersonHomePhone,ClientDreamID__r.PrimaryAddressLine1__pc,ClientDreamID__r.PrimaryAddressLine2__pc,';
        queryStr += 'ClientDreamID__r.PrimaryAddressLine3__pc,ClientDreamID__r.PrimaryZipCode__pc,ClientDreamID__r.PrimaryCity__pc,';
        queryStr += 'ClientDreamID__r.PrimaryStateProvince__pc,ClientDreamID__r.PersonMobilePhone,ClientDreamID__r.PersonEmail,ClientDreamID__r.AttachedStore__pc,';
        queryStr += 'ClientDreamID__r.LastContactDate__pc,ClientDreamID__r.HistoricalNbrProducts__pc,ClientDreamID__r.HistoricalSpendEUR__pc,';
        queryStr += 'ClientDreamID__r.HistoricalSpendUSD__pc,ClientDreamID__r.HistoricalSpendYEN__pc,ClientDreamID__r.HistoricalSpendYUAN__pc,ClientDreamID__r.Name,';
        queryStr += 'ClientDreamID__r.ComplaintClosingDate__pc,ClientDreamID__r.FirstTrans__pc,ClientDreamID__r.PrimaryAddress__pc,ClientDreamID__r.AccountNumber,ClientDreamID__r.IsPersonAccount,';
        queryStr += 'TechPurchProductKey__c, ClientDreamID__r.LastCSCClientContact__pc,ClientDreamID__r.FlowerFlag__pc,';
        // C&C and EO
        queryStr += 'STOREDELIVERY__c,TECHStore_Delivery_del__c,Assign_To__c,STOREORDER__c,';

        for(integer i=1;i<=VO_Utils.NUM_OF_Q;i++)
        {
            if(i<10)
            {
                queryStr +='Q0' +i+'Title__c,' + 'Q0' + i +'Answer__c,' + ' Q0' +i + 'Number__c,' + 'Q0'+i+'Section__c,' +'Q0'+i+'Shortname__c,';
            }
            else
            {
                queryStr +='Q' +i+'Title__c,' + 'Q' + i +'Answer__c,' + ' Q' +i + 'Number__c,' + 'Q'+i+'Section__c,' +'Q'+i+'Shortname__c ,';
            }       
        }
        queryStr = queryStr.removeEnd(',');

        queryStr += ' FROM VO_Survey__c';
        queryStr += ' WHERE id IN: idLists';
        return queryStr;
    }
/**
 * [initSurveryPdfList init the SurveryPdfList var with the objects that we the id that we get as param]
 * @param idLists [lis of ids of surveys]
 */
    private void initSurveryPdfList(List<String> idLists)
    {
        String queryStr = queryCreator();
        System.debug('queryStr : \n' + queryStr);
        this.surveyList = new List<VO_Survey__c>();
        try{

            this.surveyList =Database.query(queryStr);
        }
        catch(Exception e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }
    }

    /*VOICE 2: CR 18 
    MY:21.01.2016
    */
    //private PageReference updateStatusToPendingIfNewWhileEnterPdf(List<VO_Survey__c> surveyList)
    //{
    //    List<VO_Survey__c> surveyNeedToUpdateList = new List<VO_Survey__c>();

    //    for(VO_Survey__c sur : surveyList)
    //    {
    //        if(sur.Status__c == 'New')
    //        {
    //            sur.Status__c = 'Pending';
    //            surveyNeedToUpdateList.add(sur);
    //        }
    //    }

    //    try{
    //        update surveyNeedToUpdateList;
    //    }
    //    catch(Exception e){
    //        apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
    //    }

    //    return null;
    //}

/**
 * [initLengthOfIds we get as param the number of pdf that the user click on in order to detarn the length of the params with the id]
 * @return [description]
 */
    private Integer initLengthOfIds()
    {
        Integer ans = 0;
        try
        {
            ans = Integer.valueOf(ApexPages.currentPage().getParameters().get('size'));
        }
        catch (Exception  e)
        {
            //if - numOfIds==0 ->it's a pdf from VO_Specific_Statistics
            System.debug('Need parameters!');
            return ans;
        }
        return ans;
    }
/**
 * [initIdLists description]
 * @param  numOfIds [the number of ids ]
 * @return          [list with id of surveys]
 */
    private List<String> initIdLists(Integer numOfIds)
    {
        List<String> ans = new List<String>();
        String idParam ;
        if(numOfIds > 0)
        {  
            for(Integer i=0;i<numOfIds;i++)
            {
                idParam = ApexPages.currentPage().getParameters().get(''+i);
                ans.add(idParam);
            }
            System.debug('initIdLists1 ans ' + ans);
        }
        else //if - numOfIds==0 ->it's a pdf from case Details.
        {
            try
            {
                ans.add(idParam = ApexPages.currentPage().getParameters().get('surveyID'));
                System.debug('initIdLists2 ans ' + ans);
            }
            catch(Exception e)
            {
                System.debug('initIdLists Exception ' + e);
                
            }
            
        }
        return ans;
    }

}