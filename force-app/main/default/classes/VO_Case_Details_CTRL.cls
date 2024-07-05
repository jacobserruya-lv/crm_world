/**
     * Controller of the VO_Case_Details.
     * @createdBy   SSI ,  8/26/2015
     * @modified&RefactoringBy   Menashe Yamin ,  21/02/2016
     * Sept 2016 / Xavier Templet / Integration of New Relic custom attributes
     */

public without sharing class VO_Case_Details_CTRL {

    // Public Objects
    public String surveyID                            {get;set;}
    public String accountID                           {get;set;}

    public List<VO_Survey__c> surveyCLient_lst        {get;set;}  //all client surveys
    public VO_Survey__c  vo_survey                    {get;set;}  //the survey to display
    public Account client                             {get;set;}  //The cclient to display
    public List<PPR_PurchProduct__c> purchasedProduct_lst   {get;set;}
    public User currUser {get;set;}
    public VO_Survey__c surveyForModal{get;set;}
    public Map<String, VO_Feedback_Wrappers.AnswerList_Wrapper> ansListWrapperMap {get;set;}
    public List<VO_Feedback_Wrappers.AnswerList_Wrapper> ansListWrapperList
    {
        get
        {
            if(this.ansListWrapperMap != null)
            {
                return this.ansListWrapperMap.values();
            }
            return new List<VO_Feedback_Wrappers.AnswerList_Wrapper>();
        }
        private set;
    }

    public Long historicalSpendOfCurrUserForPDF {get;set;}
    private final static  String DEFUALT_CURRENCY = 'USD';
    //private final static Integer PRODUCT_PRUCHASED_LIMIT = 200;
   private static Integer PRODUCT_PRUCHASED_LIMIT
    {
        get
        {
            return VO_Utils.PDF_PPRODUCT_LIMIT;
        }
        set;
    }
    private final static Integer CLIENT_FEEDBACK_HISTORY_LIMIT =5;

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


    public  Boolean userReadOnlyOnSurveys {get;set;}

    //MY VOICE 2 :Banned Words2016.28.01
    private List<Banned_Words__c> bannedWordList {get;set;}
    public String jsonBannedWordList {get;set;}
    public String hostCS {
        get{
            return VO_Config__c.getValues(VO_Utils.CS_NAME_OF_HOST_NAME_CASE_DETAIL).Value__c;
        }
        private set;
    }
    //New Relic
    public String userId {get; set;}
    public String userStore {get; set;}
    public String userCountry {get; set;}
    public String userManagement {get; set;}
    public String othersDetails {get; set;}

    public VO_Case_Details_CTRL(ApexPages.StandardController stdController)
    {
        init();
        initUserInfo();
        ansListWrapperMap = initAnswerMap(vo_survey);
        initSurveyForModal();
        if(this.client != null)
        {
            inithistoricalSpendOfCurrUserForPDF();
        }
        this.userReadOnlyOnSurveys = VO_Specific_Statistics_CTRL.initUserReadOnlyOnSurveys();
        initBannedWordList();

        //New Relic
        this.userId = UserInfo.getUserId();
        this.userStore = IC_UTILS.getUserStore();
        this.userCountry = IC_UTILS.getUserCountry();
        this.userManagement = IC_UTILS.getUserManagement();
    }



    /**
     * Created by SSI on Sept 2015
     * Modifided by MY 21/02/2016
     * [init the data that we need for the page
     * current client survry,PurchasedProduct and othere surveys that this cleint fill]
     */
    public void init(){
        this.surveyID = Apexpages.currentPage().getParameters().get('surveyID'); //get surveyId from URL
        this.accountID = Apexpages.currentPage().getParameters().get('accountId');

        initCurrSurvey();
        if(this.accountID == null || this.accountID =='')
        {//MY:in case that the user didn't had the client of the survey
            this.accountID = this.vo_survey.ClientDreamID__c;
        }

        initCurrClientAndPurchasedProduct();
        initOtherSurveyOfClient();
    }

    /**
     * [initOtherSurveyOfClient init surveyCLient_lst var that store all the surveys that this
     * client fill]
     */
    private void initOtherSurveyOfClient()
    {
        surveyCLient_lst = new List<VO_Survey__c>();
        try{
            surveyCLient_lst =  [SELECT Id,Name, Action_delegated_to_CA__c,StoreID__c,StoreName__c,AnswerDate__c ,Channel__c,ClientDreamID__c,ClientDreamID__r.PersonHomePhone,
                                        ClientDreamID__r.PersonMobilePhone, ClientDreamID__r.PersonEmail, ClientDreamID__r.Gender__pc,ClientName__c,ClientDreamID__r.PrimaryAddressLine1__pc , Comment_History__c,
                                        DreamID__c,Follow_up_by__c,IDTransaction__c,
                                       Segmentation__c, Status__c,  Store__c,SurveyComment__c,
                                        SurveyLanguage__c,  SurveyType__c,  Type__c ,Store__r.RetailStoreId__c
                                    FROM VO_Survey__c
                                    WHERE ClientDreamID__c =: accountID
                                    ORDER BY AnswerDate__c
                                    LIMIT: CLIENT_FEEDBACK_HISTORY_LIMIT
                                    ];

            List<VO_Survey__c> wihtoutMySurvey = new List<VO_Survey__c>();
            for(VO_Survey__c sr : surveyCLient_lst)
            {
                if(vo_survey.id != sr.Id)
                {
                    wihtoutMySurvey.add(sr);
                }
            }
               surveyCLient_lst = wihtoutMySurvey;
        }
        catch(Exception e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }
    }

    /**
     * [initCurrClientAndPurchasedProduct init the curr client var with all the data we need to shoe
     * and also his PurchasedProduct by matchig 3 fields Client__c,TransactionRMSId__c and StoreRetailCode__c]
     */
    private void initCurrClientAndPurchasedProduct()
    {
        List<Account> clientList   = new List<Account>();
        purchasedProduct_lst = new List<PPR_PurchProduct__c>();
        try{
            clientList =     [SELECT Id,Name,TECHPreferredCA__c, DREAMID__c,Gender__pc,Segmentation__pc,PersonHomePhone,PrimaryAddressLine1__pc ,PrimaryAddressLine2__pc ,PrimaryAddressLine3__pc ,
                                    PrimaryZipCode__pc ,PrimaryCity__pc ,PrimaryStateProvince__pc ,PersonMobilePhone,PersonEmail,
                                    AttachedStore__pc, LastContactDate__pc,HistoricalNbrProducts__pc ,
                                    HistoricalSpendEUR__pc , HistoricalSpendUSD__pc ,HistoricalSpendYEN__pc, HistoricalSpendYUAN__pc,
                                    ComplaintClosingDate__pc, FirstTrans__pc,PrimaryAddress__pc, AccountNumber,
                                    owner.Name ,IsPersonAccount, LastCSCClientContact__pc, FlowerFlag__pc
                                FROM Account
                                WHERE id=: this.accountID];
            }
        catch(DMLexception e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }

        if(clientList.size()>0){
            this.client = clientList[0];
            try{
                // On Endless offer surveys retrieve pproducts with a store that matches the survey store order
                if(vo_survey.surveytype__c == VOICE_EO_SALES)
                {
                purchasedProduct_lst = [SELECT
                                        id, DreamIdSA__c, RMSCAId__c, SAName__c, DesignationRepaired__c, PurchasedDate__c, Amount__c, CurrencyCode__c,
                                        Name, ProductLine__c, Quantity__c, TransactionRMSId__c,OrderATGId__c,
                                        TransactionTotalAmount__c, TicketNumber__c, TechTransactionId__c,
                                        TechPurchProductKey__c
                                        FROM PPR_PurchProduct__c
                                        WHERE TransactionRMSId__c =: vo_survey.IDTransaction__c
                                        AND Client__c = :accountID
                                        AND StoreRetailCode__c = :vo_survey.STOREORDER__c
                                        ORDER BY PurchasedDate__c
                                        LIMIT: PRODUCT_PRUCHASED_LIMIT];
                }
                // On other survey types, retrieve pproducts with a store that matches the survey store
                else
                {
                purchasedProduct_lst = [SELECT
                                        id, DreamIdSA__c, RMSCAId__c, SAName__c, DesignationRepaired__c, PurchasedDate__c, Amount__c, CurrencyCode__c,
                                        Name, ProductLine__c, Quantity__c, TransactionRMSId__c,OrderATGId__c,
                                        TransactionTotalAmount__c, TicketNumber__c, TechTransactionId__c,
                                        TechPurchProductKey__c
                                        FROM PPR_PurchProduct__c
                                        WHERE TransactionRMSId__c =: vo_survey.IDTransaction__c
                                        AND Client__c = :accountID
                                        AND StoreRetailCode__c = :vo_survey.Store__r.RetailStoreId__c
                                        ORDER BY PurchasedDate__c
                                        LIMIT: PRODUCT_PRUCHASED_LIMIT];
   
                }

            }
            catch(Exception e){
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
            }

        }

    }

/**
 * [queryGetSurveyCreator generate query for the current survey]
 * @return [description]
 */
    private String queryGetSurveyCreator()
    {
        String queryStr='SELECT Id, DreamIDText__c, Action_delegated_to_CA__c,AnswerDate__c,Channel__c,ClientDreamID__c,ClientDreamID__r.PersonHomePhone,ClientDreamID__r.PersonMobilePhone,ClientDreamID__r.Gender__pc,';
        queryStr += 'ClientName__c,ClientDreamID__r.PrimaryAddressLine1__pc , Comment_History__c,DreamID__c,Follow_up_by__c,IDTransaction__c,';
        queryStr += 'Segmentation__c,Status__c,Store__c,StoreID__c, StoreName__c,SurveyComment__c,';
        queryStr += 'SurveyLanguage__c, SurveyType__c,  Type__c ,Store__r.Name,Store__r.RetailStoreId__c,RootCause__c ,TechPurchProductKey__c,CAName__c, STOREDELIVERY__c,TECHStore_Delivery_del__c,Assign_To__c,STOREORDER__c,';


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
        queryStr += ' WHERE id=: surveyID';
        return queryStr;
    }

/**
 * [initCurrSurvey init the curr survey by the param in the url]
 */
    private void initCurrSurvey()
    {
        List<VO_Survey__c> surveyList = new List<VO_Survey__c>();
        String queryClientSurvey = queryGetSurveyCreator();

        try{

            surveyList = Database.query(queryClientSurvey);
        }
        catch(Exception e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }
        if(surveyList.size()>0){
            this.vo_survey = surveyList[0];
            system.debug('Salesforce SSI survey : ' + vo_survey);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Bad id specified!'));
            return ;
        }

    }

/**
 * MY: 2016/01/28 VOICE 2
 * init bannedWordList only one time.
 */
    public void initBannedWordList()
    {
        Set<String> banWordSet = new Set<String>();

        if(this.bannedWordList == null )
        {
            this.bannedWordList = [select Word__c from Banned_Words__c];
            for (Integer i = 0; i< bannedWordList.size(); i++)
            {
                banWordSet.add(bannedWordList[i].Word__c.toLowerCase()); // contains distict contacts
            }

            this.jsonBannedWordList = JSON.serialize(banWordSet);
        }

    }

/**
 * [inithistoricalSpendOfCurrUserForPDF init the this field that will be the currency in the pdf.
 *
 * !!!NEED TO BE REMOVE BECAUSE WE USE FOR PDF ONLY IN VO_SPECIFIC STATISICT FOR PDF!!!!
 * I left this only for support]
 */
    private void inithistoricalSpendOfCurrUserForPDF ()
    {
        historicalSpendOfCurrUserForPDF = 0;
        if(this.client.HistoricalSpendUSD__pc !=null)
        {
            historicalSpendOfCurrUserForPDF = this.client.HistoricalSpendUSD__pc.round(System.RoundingMode.CEILING);//usd is the defualt
        }
        if(currUser.Currency__c =='EUR')
        {
            if(this.client.HistoricalSpendEUR__pc != null)
            {
                historicalSpendOfCurrUserForPDF = this.client.HistoricalSpendEUR__pc.round(System.RoundingMode.CEILING);
            }
        }
        if(currUser.Currency__c =='JPY')
        {
            if(this.client.HistoricalSpendYEN__pc != null)
            {
                historicalSpendOfCurrUserForPDF = this.client.HistoricalSpendYEN__pc.round(System.RoundingMode.CEILING) ;
            }
        }
        if(currUser.Currency__c =='CNY')
        {
            if(this.client.HistoricalSpendYUAN__pc != null)
            {
                historicalSpendOfCurrUserForPDF = this.client.HistoricalSpendYUAN__pc.round(System.RoundingMode.CEILING);
            }
        }
    }
    /**
     * [initSurveyForModal init the survey of the model with our current survey]
     */
    private void initSurveyForModal()
    {
        this.surveyForModal = vo_survey;
    }

/**
 * @param  survey [current survey]
 * @return        [map that deteram who is multy Q and who not - please look on the Wrapper
 * to  understand it more]
 */
    public static Map<String, VO_Feedback_Wrappers.AnswerList_Wrapper> initAnswerMap(VO_Survey__c survey)
    {
        List<VO_Feedback_Wrappers.Answer_Wrapper> ansList = initListOfAnsWrapper(survey);
        Map<String, VO_Feedback_Wrappers.AnswerList_Wrapper> ansListWrapperMap = new Map<String, VO_Feedback_Wrappers.AnswerList_Wrapper>();

        for(VO_Feedback_Wrappers.Answer_Wrapper ans :ansList)
        {
            if(!ansListWrapperMap.containsKey(ans.section))
            {
                ansListWrapperMap.put(ans.section, new VO_Feedback_Wrappers.AnswerList_Wrapper());
            }
            ansListWrapperMap.get(ans.section).answerList.add(ans);
            ansListWrapperMap.get(ans.section).count++;

        }
        for(VO_Feedback_Wrappers.AnswerList_Wrapper ansList_Wrapper :ansListWrapperMap.values()){
            if(ansList_Wrapper.count == 1){
                ansList_Wrapper.isAnsIsNum = isNumber(ansList_Wrapper.answerList[0].answer);
            }
            // 29/12/2016: MTOU: checking if a group of questions has at least one answer
            else if(ansList_Wrapper.count > 1)
            {
                for(Integer i=0; i<ansList_Wrapper.count; i++)
                {
                    if(ansList_Wrapper.answerList[i].answer != null)
                    {
                        ansList_Wrapper.hasNoAns = false;
                    }
                }
            }
            // End MTOU
        }
        system.debug('## ansListWrapperMap: ' + ansListWrapperMap);
        return ansListWrapperMap;
    }




    /**
     * [initListOfAnsWrapper init the ans&Q from the survey of the client  as a list.
     * in this function we transfer the survey ans fields to our wrapper in order to get absraction to determ
     * which q are multy and who not]
     * @param  survey [current survey]
     * @return        [answer wrapper for multy and regular answer from the survey]
     */
    public static List<VO_Feedback_Wrappers.Answer_Wrapper> initListOfAnsWrapper (VO_Survey__c survey)
    {
        List<VO_Feedback_Wrappers.Answer_Wrapper> ansList = new List<VO_Feedback_Wrappers.Answer_Wrapper>();
        VO_Feedback_Wrappers.Answer_Wrapper tmpAns ;

        for(Integer i = 1; i <= VO_Utils.NUM_OF_Q; ++i)
        {
            tmpAns = new VO_Feedback_Wrappers.Answer_Wrapper();
            try{
                tmpAns.orderInAnswer = i;
                if(i<10)
                {

                    tmpAns.answer = (String)survey.get('Q0'+i+'Answer__c');
                    tmpAns.num = Integer.valueOf((Decimal)survey.get('Q0'+i+'Number__c'));
                    tmpAns.section = (String)survey.get('Q0'+i+'Section__c');
                    tmpAns.shortName = (String)survey.get('Q0'+i+'Shortname__c');
                    tmpAns.title = (String)survey.get('Q0'+i+'Title__c');
                }
                else
                {
                    tmpAns.answer = (String)survey.get('Q'+i+'Answer__c');
                    tmpAns.num = Integer.valueOf((Decimal)survey.get('Q'+i+'Number__c'));
                    tmpAns.section = (String)survey.get('Q'+i+'Section__c');
                    tmpAns.shortName = (String)survey.get('Q'+i+'Shortname__c');
                    tmpAns.title = (String)survey.get('Q'+i+'Title__c');
                }
            }
            catch (Exception e)
            {
                continue;
            }
            if(validtionOnAns(tmpAns))
            {
                ansList.add(tmpAns);
            }
        }
        ansList.sort();//by Q0XXNumber__c field - I override comperable; we will sort the questions and sub questions by this fields in the page
        return ansList;
    }
    /**
     * [validtionOnAns description]
     * @param  tmpAns [the wrapper]
     * @return        [true - have section so we can add him the the ansList.otherwise we dont]
     */
    public static boolean validtionOnAns(VO_Feedback_Wrappers.Answer_Wrapper tmpAns)
    {
        return String.isNotBlank(tmpAns.section);

    }


    /**
     * @param  value [value of ans]
     * @return       [if the value is string or number]
     */
    public static boolean isNumber (String value)
    {
        try
        {
            Integer.valueOf(value.remove(',')); //if the number is 10,00 sintax..
        }
        catch (Exception  e)
        {
            return false;
        }
        return true;
    }

    /**
     * [initUserInfo get the user info about his currency ]
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
 * [addNewComment update the Comment_History__c field with the comment that the user gave him]
 * @param survey          [current survey]
 * @param commentFromForm [the comment that the user wrote]
 */
    private void addNewComment(VO_Survey__c survey, String commentFromForm)
    {

        String newComment ='';
        Date today = Date.today();
        if(String.isNotBlank(commentFromForm))
        {
           newComment = '\n' + today.year() + '-' + today.month() + '-' + today.day() ;
           newComment += ' ' + UserInfo.getName() + '\n';
           newComment += commentFromForm + '\n';

        }

        if(String.isNotBlank(this.surveyForModal.Comment_History__c)){
            this.surveyForModal.Comment_History__c = newComment + this.surveyForModal.Comment_History__c;
        }
        else
        {
            this.surveyForModal.Comment_History__c = newComment;
        }
    }
/**
 * [clickSaveModal function that call when user click on save the modal and handel all
 * the bussiness logic that define in the spec]
 */
    public PageReference clickSaveModal ()
    {
        if(this.surveyForModal != null)
        {
            String commentFromForm = ApexPages.currentPage().getParameters().get('Comment');
            String chanelFromForm = ApexPages.currentPage().getParameters().get('Chanel');
            String rootFromForm = ApexPages.currentPage().getParameters().get('Root');
            String caFromForm = ApexPages.currentPage().getParameters().get('CA');
            String rootMultyFromForm = ApexPages.currentPage().getParameters().get('RootMulty');

            if(rootMultyFromForm !=null){
                this.surveyForModal.RootCause__c = rootMultyFromForm;
            }

            if(caFromForm !=null)
            {
                if( caFromForm.equals('false'))
                {
                    this.surveyForModal.Action_delegated_to_CA__c = false;
                }
                else
                {
                    this.surveyForModal.Action_delegated_to_CA__c = true;
                }
            }

            if(String.isNotBlank(chanelFromForm))
            {
                this.surveyForModal.Channel__c = chanelFromForm;
            }
            addNewComment(this.surveyForModal,commentFromForm);


            if(this.surveyForModal.Status__c == 'New' && !userReadOnlyOnSurveys || this.surveyForModal.Channel__c!='No action')//NEW DEMENED
            {
                this.surveyForModal.Status__c = 'Pending';
            }

            if((this.surveyForModal.Status__c == 'New' || this.surveyForModal.Status__c == 'Pending')
                && !userReadOnlyOnSurveys && chanelFromForm.equals('No action'))
            {
                    this.surveyForModal.Status__c = 'No action';
            }


            try
            {
                update this.surveyForModal;
            }
            catch(DMLexception e)
            {
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
            }
        }
        return null;
    }

/**
 * [clickCancelCaseModal when user exit from the modal]
 */
    public PageReference clickCancelCaseModal ()
    {
        System.debug('Start clickSaveModal');
        if(this.surveyForModal != null)
        {
            if(this.surveyForModal.Status__c == 'New' && !userReadOnlyOnSurveys)//NEW DEMENED
            {
                this.surveyForModal.Status__c = 'Pending';
            }
            try
            {
                update this.surveyForModal;
            }
            catch(DMLexception e)
            {
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
            }
        }


        return null;
    }

/**
 * [clickCloseCaseModal function that call when user click on close case in the modal]
 * @return [description]
 */
 public PageReference clickCloseCaseModal ()
 {
     /*update 14/09/2016 delegated to ca*/

     if(this.surveyForModal != null)
     {
         String commentFromForm = ApexPages.currentPage().getParameters().get('Comment');
         String chanelFromForm = ApexPages.currentPage().getParameters().get('Chanel');
         String rootFromForm = ApexPages.currentPage().getParameters().get('Root');
         String caFromForm = ApexPages.currentPage().getParameters().get('CA');
         String rootMultyFromForm = ApexPages.currentPage().getParameters().get('RootMulty');

         if(rootMultyFromForm !=null){
             this.surveyForModal.RootCause__c = rootMultyFromForm;
         }
         if(ApexPages.currentPage().getParameters().get('app')=='ICON')
          {
             this.surveyForModal.Action_delegated_to_CA__c = true;
         }
         else if(caFromForm !=null)
          {

             if( caFromForm.equals('false'))
              {
                  this.surveyForModal.Action_delegated_to_CA__c = false;
             }
              else
             {
                  this.surveyForModal.Action_delegated_to_CA__c = true;
              }
          }
         if(String.isNotBlank(chanelFromForm))
         {
             this.surveyForModal.Channel__c = chanelFromForm;
         }

         addNewComment(this.surveyForModal,commentFromForm);
         this.surveyForModal.Status__c = 'Closed';
         try
         {
             update this.surveyForModal;
         }
         catch(DMLexception e)
         {
             apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
         }
     }
     return null;
 }
}