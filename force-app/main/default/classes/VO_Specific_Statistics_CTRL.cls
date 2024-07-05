/*
* Controller of the VO_Specific_Statistics VFP AKA Console page - search page\
* @createdBy   Menashe Yamin ,  8/26/2015         
* Change 14.2016 - replace search to remote action 
* Sept 2016 / Xavier Templet / Integration of New Relic custom attributes 
* Oct 2016 / Xavier Templet / add RemoteAction getVOConfig for export2excel.js
* Feb 2017 / Romain Mouchel-Vallon / MultiStore
* Mar 2017 / Romain Mouchel-Vallon / KPI Limits removal
*/

global class VO_Specific_Statistics_CTRL { 

    //---------------- Public methods ----------------------------------------------
    public  String fromDate {get; Set;}
    public  String toDate {get; Set;}
    public  Boolean isUserFromFrance {get; Set;}
    public  SearchFilter_Wrapper searchParam {get; set;}
    private Map<Id,VO_Survey__c> idToSurveySearchResMap;
    public  VO_Survey__c surveyForModal{get; set;}
    public transient String jsonResultList {get; private set;}
    public SelectOption[] numberOfResultInpageSelectOption {get; set;}
    public List<String> numberOfResultInpage{get; set;}
    public String currNumberOfResultInpage {get; set;}
    public SelectOption[] surveyTypeValuesSelectOptions {get; set;}
    public  String currSurvayType {get; set;} //which survayType we need to see at the page.
    private List<VO_Survey__c> searchResults{get; set;}
    public  VO_SurvayTypeStat survayTypeStat {get; set;}
    public  Integer numOfDaysBefore {get; set;}
    public  User currUser{set; get;}
    public  User searchCurrUser {get;set;} //the user that I change in the inputFields in the VFP ;I created two in order the save the first data for the clear buttom
    public  Boolean isAdmin {get;set;}
    public  String TECH_User_Stores {get{return searchCurrUser.TECH_User_Stores__c;}}
    private List<Integer> answerToRepresentSortedByCSList {get;set;}
    public  List<AnswerHeader_Wrapper> headerWrapperListQ {get;set;}
    public  List<selectOption> segmentationPickListValue {get;set;}
    public  List<selectOption> channelPickListValue {get;set;}
    public  Boolean userReadOnlyOnSurveys {get;set;}
    public  Transient String jsonStoreByType {get;set;}
    public Map<String, List<String>> storeByTypeMap;

    public  String CCCSCSales {get{return VO_Utils.VOICE_CC_CSC_SALES;}}
    public  String CCWEBSales {get{return VO_Utils.VOICE_CC_WEB_SALES;}}
    public  String EOSales {get{return VO_Utils.VOICE_EO_SALES;}}


    //MY 2016.01.05 TRY TO AVODING GENERATE FUNCTION LIST IN THE MAIN SEARCH
    public List<String> answerOrderForAllSurveyType {get; set;}
    public transient Integer maxRecordsPerSerach {get;set;}
    
    //MY 2016.28.01 VOICE 2
    private List<Banned_Words__c> bannedWordList {get;set;}
    public String jsonBannedWordList {get;set;}

    public String VOICE_AFTER_SALES 
                            {get
                                {return VO_Utils.VOICE_AFTER_SALES ;}
                             set;
                            }  

    // BEGIN RMOU
    public List<selectOption> storesOptions {get; set;}
    public List<String> storesSelected {get; set;}
    public Integer lowestCommonLevel {get; set;}
    public String storesSelectedForExcel {
        get{
            List<String> tmp = new List<String>();

            for (String s : storesSelected){
                if (s != '--ALL--'){
                    tmp.add(picklistTranslationsMap.get(s));
                }
            }
            
            return String.join(new List<String>(tmp), ',');
        }
    }

    // Map holding store code translations
    private final Map<String, String> picklistTranslationsMap = new Map<String, String>();
    // END RMOU
    
    //New Relic
    public String userId {get; set;}
    public String userStore {get; set;}
    public String userCountry {get; set;}
    public String userManagement {get; set;}
    
    //public static String userStoreType {get;set;}
    
    public VO_Specific_Statistics_CTRL()
    {
            maxRecordsPerSerach = VO_Utils.DEFAULT_n_RESUALTS_PER_SEARCH;
            numOfDaysBefore = VO_Utils.BEFORE_n_DAYS; //this var only create  to pass to the components!because the components can't get from VO_UTILS:/
            initSurveyTypePermissions();
            initnumberOfResultInpageSelectOptionAndSetTheFirstValue();
            initFromAndToDate();
            initCurrUser();
            initStoresWithType();

            //MY 2016.05.01 TRY TO AVODING GENERATE FUNCTION LIST IN THE MAIN SEARCH
            answerOrderForAllSurveyType = initAnswerOrderForAllSurveyType();

            this.isUserFromFrance = UserInfo.getLocale().containsIgnoreCase('FR');
            this.segmentationPickListValue = VO_Utils.getPicklistValues('Account','Segmentation__pc','');
            this.channelPickListValue = VO_Utils.getPicklistValues('VO_Survey__c','Channel__c','');
            this.searchParam = new SearchFilter_Wrapper ();
            this.searchResults = new List<VO_Survey__c>();
            this.surveyForModal = new VO_Survey__c();
            this.userReadOnlyOnSurveys = initUserReadOnlyOnSurveys();

            //New Relic
            this.userId = UserInfo.getUserId();
            this.userStore = IC_UTILS.getUserStore();
            this.userCountry = IC_UTILS.getUserCountry();
            this.userManagement = IC_UTILS.getUserManagement();

            // BEGIN RMOU

            // Initializing translation map
            List<Schema.PicklistEntry> picklistValues = User.DefaultStore__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry pe : picklistValues){
                picklistTranslationsMap.put(pe.getValue(), pe.getLabel());
            }
            // Initializing stores list
            storesOptions = new List<selectOption>();
            storesSelected = new List<String>();
            updateStoreByType();
            if (searchCurrUser.TECH_User_Stores__c != null){
                lowestCommonLevel = calculateLowestCommonLevel();
                handleCommonHierarchy();
            }
    }
    

    public void updateStoreByType (){

        storesOptions.clear();
        storesSelected.clear();
        String surveyTypeKey;
        if(currSurvayType == VO_Utils.VOICE_CC_CSC_SALES ) // C&C CSC surveys should be available to store and CSC users 
        {
            surveyTypeKey = 'Store_CSC';
        }
        else if(currSurvayType == VO_Utils.VOICE_CC_WEB_SALES || currSurvayType == VO_Utils.VOICE_EO_SALES) // C&C Web and Endless offer surveys should be available to all type of users
        {
            surveyTypeKey = 'ALL';
        }
        else if(currSurvayType == VO_Utils.VOICE_WEB_SALES ){
            surveyTypeKey = 'WEB';
        }
        else if(currSurvayType == VO_Utils.VOICE_CSC_SALES){
            surveyTypeKey = 'CSC';
        }
        else{
            surveyTypeKey = 'Store';
        }
        Set<String> setStores = storeByTypeMap == null || storeByTypeMap.get(surveyTypeKey) == null ? new Set<String>() : new Set<String> (storeByTypeMap.get(surveyTypeKey));
        System.debug('updating');
        if (searchCurrUser.TECH_User_Stores__c != null){
            System.debug('1 : ' + searchCurrUser.TECH_User_Stores__c);
            List<String> stores = searchCurrUser.TECH_User_Stores__c.split(',');
            stores.sort();
            for (String s : stores){
                if (setStores != null && setStores.contains(s)){
                    storesOptions.add (new selectOption(s, s + ' - ' + (picklistTranslationsMap.get(s) == null ? '' : picklistTranslationsMap.get(s))));
                    storesSelected.add(s);
                }
            }
           /* if (!storesOptions.isEmpty()){
                storesOptions.add(0, new selectOption('--ALL--', '--ALL--'));
                storesSelected.add(0, '--ALL--');
            }*/
        }
        // Begin- Handling country users (users with a Level 4 and no store attached)
        else if(searchCurrUser.MGMT_ZONE_SUB_LEVEL3__c != null)
        {
            System.debug('2 : ' + searchCurrUser.MGMT_ZONE_SUB_LEVEL3__c);
            List<Store__c> storesToDisplay = [Select id, RetailStoreId__c from Store__c where MGMT_ZONE_SUB_LEVEL3__c =: searchCurrUser.MGMT_ZONE_SUB_LEVEL3__c AND RetailStoreId__c in:setStores AND Status__c = 'Open' ORDER BY RetailStoreId__c];  
            for(Store__c st : storesToDisplay)
            {
                String s = st.RetailStoreId__c;
                if (setStores != null && setStores.contains(s)){
                    System.debug('RetailStoreId__c: ' + s + ' translation: ' + picklistTranslationsMap.get(s));
                    storesOptions.add (new selectOption(s, s + ' - ' + (picklistTranslationsMap.get(s) == null ? '' : picklistTranslationsMap.get(s))));
                    storesSelected.add(s);
                }
            }
        }
        // End
        if (storesOptions.size() > 1){
            storesOptions.add(0, new selectOption('--ALL--', '--ALL--'));
            storesSelected.add(0, '--ALL--');
        }

        System.debug('storesOptions: ' + storesOptions);
        this.jsonStoreByType = JSON.serialize(storeByTypeMap);
    }

    private Integer calculateLowestCommonLevel (){

        if (searchCurrUser.TECH_User_Stores__c == null)
            return 0;
        if (searchCurrUser.TECH_User_Stores__c.split(',').size() == 1)
            return 4;

        Store__c[] stores = [SELECT id, RetailStoreId__c, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c FROM Store__c WHERE RetailStoreId__c IN :searchCurrUser.TECH_User_Stores__c.split(',')];
        String[] fields = new String[] {'MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c', 'MGMT_ZONE_SUB_LEVEL2__c', 'MGMT_ZONE_SUB_LEVEL3__c'};

        if (stores.size() == 0)
            return 4;

        Boolean allEqual = true;
        Integer lcl = -1;
        do{
            lcl++;
            String first = (String)stores[0].get(fields[lcl]);
            for (Integer i = 1; i<stores.size(); i++){
                String s = (String)stores[i].get(fields[lcl]);
                allEqual = allEqual && first == s;
            }
        }
        while (lcl < 3 && allEqual);

        if (lcl == 3 && allEqual)
            lcl++;

        return lcl;
    }

    private void handleCommonHierarchy(){
        String[] fields = new String[] {'MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c', 'MGMT_ZONE_SUB_LEVEL2__c', 'MGMT_ZONE_SUB_LEVEL3__c'};

        for (Integer i = 3; i>=lowestCommonLevel; i--){
            searchCurrUser.put(fields[i], null);
        }
    }

    @RemoteAction
    public static Boolean isAdmin (){
        return VO_Main_Statistics_CTRL.isAdmin(userinfo.getProfileId());
    }

    @RemoteAction
    public static Boolean hasStores (){
        return [SELECT TECH_User_Stores__c FROM User WHERE id = :UserInfo.getUserId()].TECH_User_Stores__c != null;
    }
    
    // END RMOU

    @RemoteAction
    public static String getVOConfig(String csName) {
        return VO_Config__c.getValues(csName).Value__c;
    } 

   

/**
 * [initUserReadOnlyOnSurveys check if user have access to change surveys or not]
 * @return [true- if have only ready permission
 *          false -otherwise - can change surveys]
 */

    public static boolean initUserReadOnlyOnSurveys ()
    {
        // Query optimized by TLA 25/12/2015 
        Id id = UserInfo.getProfileId();
        
        String profilesReadOnlySurveyStatusRaw = '';
        if (VO_Config__c.getInstance('ProfilesReadOnlySurveyStatus') != null)
            profilesReadOnlySurveyStatusRaw = VO_Config__c.getInstance('ProfilesReadOnlySurveyStatus').Value__c;
            
        Set<String> profilesReadOnlySurveyStatusSet = new Set<String>(profilesReadOnlySurveyStatusRaw.split(','));
        
        if(!profilesReadOnlySurveyStatusSet.contains(id)){
        List<VO_Survey__c> surveyList = [SELECT Id 
                                        FROM  VO_Survey__c
                                        WHERE answerDate__c <= TODAY
                                        ORDER BY answerDate__c desc
                                        LIMIT 1 ];
        List<UserRecordAccess> userRecAcc = new List<UserRecordAccess>();

            if(!surveyList.isEmpty())
            {                    
                userRecAcc = [SELECT  RecordId,MaxAccessLevel
                         FROM UserRecordAccess
                         WHERE UserId =:userinfo.getUserId()
                         AND RecordId =:surveyList[0].id];

                return userRecAcc[0].MaxAccessLevel =='Read';
            }
        return  false;
        
        }
        else
        {
            return true;
        }
    }


    //Nadav
    /**
     * [initStoresWithType return map as json when the key is the survey type and the value is the stores that 
     * are with this survey type]
     */
    private void initStoresWithType()
    {
        storeByTypeMap = new Map<String,List<String>>();
        List<Store__c> stroreList = [SELECT Id, Name, RetailStoreId__c, StoreType__c, MGMT_ZONE_SUB_LEVEL3__c FROM Store__c];
                        System.debug (stroreList);

        if(stroreList != Null && stroreList.size() > 0){
            for(Store__c currStore : stroreList){
                if(currStore.StoreType__c != Null) {
                    List<String> storesByTypeList = storeByTypeMap.get(currStore.StoreType__c);
                    if(storesByTypeList == Null){
                        storesByTypeList = new List<String>{currStore.RetailStoreId__c};
                    }
                    else{
                        storesByTypeList.add(currStore.RetailStoreId__c);
                    }
                    storeByTypeMap.put(currStore.StoreType__c,storesByTypeList);
                }
                    
             }
        }
        // Click and Collect/Endless Offer consideration
        // C&C CSC surveys should be accessible to both store and CSC users. C&C Web and Endless Offer surveys should be accessible to Store, web and CSC users
        List<String> ccCSCStoretype = new List<String>();
        List<String> allStoreType = new List<String>();
        for(Store__c st : stroreList)
        {
            if(st.StoreType__c == 'Store' || st.StoreType__c == 'CSC')
            {
                ccCSCStoretype.add(st.RetailStoreId__c);
            }
            allStoreType.add(st.RetailStoreId__c);
        }
        storeByTypeMap.put('Store_CSC', ccCSCStoretype);
        storeByTypeMap.put('ALL', allStoreType);
        // End Click and Collect/Endless Offer consideration
        
        for (String s : storeByTypeMap.keySet()){
            if (storeByTypeMap.get(s).size() > 0)
                storeByTypeMap.get(s).add(0, '--ALL--');
        }

        System.debug ('storeByTypeMap: ' + storeByTypeMap);
        this.jsonStoreByType = JSON.serialize(storeByTypeMap);
    }

/**
 * [initSurveyTypePermissions init SurveyTypePermissions select option with the survey type
 * that this user have access to.]
 */
    private void initSurveyTypePermissions()
    {
        isAdmin = VO_Main_Statistics_CTRL.isAdmin(userinfo.getProfileId());
        List<SelectOption> surveyTypePickFromSchemeList = VO_Utils.getPicklistValues('VO_Survey__c','SurveyType__c','');
        System.debug('surveyTypePickFromSchemeList: \n' + surveyTypePickFromSchemeList);
        List<String> userPermissionSetNameList= VO_Main_Statistics_CTRL.getUserPermissionSet(Userinfo.getUserId());
        System.debug('userPermissionSetNameList: ' + userPermissionSetNameList);
        //Boolean isAdmin = VO_Main_Statistics_CTRL.isAdmin(userinfo.getProfileId());
        if(!isAdmin)
        {
            this.surveyTypeValuesSelectOptions = initSurveyTypeValuesSelectOptions(userPermissionSetNameList,surveyTypePickFromSchemeList);
        }
        else
        {
            this.surveyTypeValuesSelectOptions = surveyTypePickFromSchemeList;
        }
        initCurrSurvayType(isAdmin);
    }

/**
 * [initCurrSurvayType init the current SurvayType when the page load
 * if we have param in url - he will be the survey type
 * otherwise - the survey type that will be will deteram by the  PERMISSIONSET_PRIORITIES (a custom setting )
 * also we will check that to this user have the permission to this survey type]
 * @param isAdmin [if the user is admin or not]
 */
    private void initCurrSurvayType(Boolean isAdmin)
    {
        List<String> permissionSetPrioritiesListFromCS = VO_Utils.PERMISSIONSET_PRIORITIES.split(';');

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('surveyType')))
        {
            this.currSurvayType = ApexPages.currentPage().getParameters().get('surveyType').replace('_', ' ');
            return;
        }

        if(permissionSetPrioritiesListFromCS.isEmpty())
        {
            this.currSurvayType = VO_Utils.VOICE_AFTER_SALES;
            return;
        }
        if(!isAdmin)
        {
            for(String csprSetPri : permissionSetPrioritiesListFromCS)
            {
                for(SelectOption surveyTypePickList :surveyTypeValuesSelectOptions)
                {
                    if(csprSetPri.equals(surveyTypePickList.getValue()))
                    {
                        this.currSurvayType = csprSetPri ; 
                        return;
                    }
                }
            }
        }
        else
        {
            this.currSurvayType = permissionSetPrioritiesListFromCS[0];
        }       
    }

    /**
     * [initCurrUser get the search filter that the user have in his record and set them in the search section already]
     */
    public void initCurrUser()
    {
        List<User> userList =new List<User>();

        try
        {
            userList = [SELECT id, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c ,MGMT_ZONE_SUB_LEVEL2__c,
                         MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c, TECH_User_Stores__c
                        FROM User
                        WHERE id =:UserInfo.getUserId()];
            if(!userList.isEmpty())
            {
                currUser = userList[0];
            }
        }
        catch(Exception e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }
        if(currUser == null)
        {
            currUser = new User();
        }
        searchCurrUser = currUser.clone(false,true,false,false);
    }

 
    /**
     * [initnumberOfResultInpageSelectOptionAndSetTheFirstValue 
     * this function are set the values in the list of how surveys per each page by custom setting VO_Utils.STR_RESULT_IN_SEARCH_PAGE]
     */
    private void initnumberOfResultInpageSelectOptionAndSetTheFirstValue()
    {
        this.numberOfResultInpageSelectOption  = new List<SelectOption>();
        this.numberOfResultInpage =new List<String>();

        try 
        {           
            for (String option : VO_Utils.STR_RESULT_IN_SEARCH_PAGE.split(';'))
            {
                this.numberOfResultInpageSelectOption.add( new SelectOption(option, option));
                this.numberOfResultInpage.add(option);
            }
            this.currNumberOfResultInpage = this.numberOfResultInpageSelectOption[0].getValue();
        }
        catch (Exception  e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error initnumberOfResultInpageSelectOptionAndSetTheFirstValue function '));
            throw e;
        }
    }   
    
        /**
     * [init the SurveyType picklist by the permissions of the user.]
     * @scenario    [ ]
     * @return  [selectOption array of with those values]
     * @createdBy   Menash Yamin 19.10.15         
     * @lastModifiedBy  Menash Yamin 19.10.15 
     */

    private SelectOption[] initSurveyTypeValuesSelectOptions(List<String> userPermissionSetNameList, List<SelectOption> surveyTypePickFromSchemeList)
    {
        List<SelectOption> selectOptionFromTheuserPermission = new List<SelectOption>();

        for(SelectOption surveyTypePickList : surveyTypePickFromSchemeList)
        {
            for(String prSetPri : userPermissionSetNameList)
            {
                if(surveyTypePickList.getValue().equals(prSetPri))
                {
                    selectOptionFromTheuserPermission.add(surveyTypePickList);
                }
            }
        }

        return selectOptionFromTheuserPermission;
    }

    /**
     * [init the FromDate and toDATE in the search.]
     * @scenario    [calc the date from the custom setting from today and today ]
     * @createdBy   Menash Yamin 10.09.15         
     * @lastModifiedBy  Menash Yamin 21.09.15
     */
    private void initFromAndToDate()
    {
        this.fromDate = Datetime.now().addDays(-VO_Utils.DEFAULT_n_DAYS_FROM_DATE_SEARCH).format('MM-dd-yyyy');
        this.toDate = Datetime.now().format('MM-dd-yyyy');
    }

     /**
     * [pare to date the string value that came from the input]
     * @scenario    [we split the text by the format yyyy-mm-dd]
     * @return [return this date as a Date object]
     * @createdBy   Menash Yamin 30.09.15         
     * @lastModifiedBy  Menash Yamin 30.09.15
     */
    public static Date fromStringToDate(String someDate)
    {
        List<String> ls =someDate.split('-');
        Date ans;
        try 
        {   
            ans = Date.newInstance(Integer.valueOf(ls[2]), Integer.valueOf(ls[0]), Integer.valueOf(ls[1]));
            return ans;
        }
        catch (Exception  e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error fromStringToDate function '));
            throw e;
        }
        return null;
    }

/**
*MY 05/01/2016
* initAnswerOrderForAllSurveyType will contain a List per survey type 
* and in this list there will be the 
*/
    private List<String> initAnswerOrderForAllSurveyType()
    {
        List<String> ans  = new List<String>();
        System.debug('surveyTypeValuesSelectOptions :' + surveyTypeValuesSelectOptions);
        try
        {
            for(SelectOption so : this.surveyTypeValuesSelectOptions)
            {
                System.debug('surveyTypeOption: ' + so.getLabel() + ' columns');
                ans.add(VO_Config__c.getValues(so.getLabel() + ' columns').Value__c);
            }
        }
        catch(Exception e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'class:VO_Specific_Statistics_CTRL method:initAnswerOrderForAllSurveyType ;CS is missing or wrong format'));
            System.debug('class:VO_Specific_Statistics_CTRL method:initAnswerOrderForAllSurveyType ;CS is missing or wrong format');
        }
        return ans;
    }


  

    /**
     * MY: 2016/01/28 VOICE 2
     * init bannedWordList only one time.
     */
    private void initBannedWordList()
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
 * [initModal action function init the modal with the id and get the survey from the server just to keep him update as can
 * and also already change him to pending if we need to ]
 * @return [description]
 */
    public PageReference initModal ()
    {
        String id = ApexPages.currentPage().getParameters().get('id');
        //MY: 2016/01/28 VOICE 2
        initBannedWordList();
        this.surveyForModal = new VO_Survey__c ();
        try
        {
           List<VO_Survey__c> surveyList = getSurveyById(id); 
            if(!surveyList.isEmpty())
            {
                this.surveyForModal = surveyList[0];
            }

        }
        catch(DMLexception e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'class:VO_Specific_Statistics_CTRL method:initModal ;DMLexception'));

        }
        if(this.surveyForModal.Status__c == 'New' && !userReadOnlyOnSurveys)
        {
            this.surveyForModal.Status__c = 'Pending';
        }
        try
        {
            update this.surveyForModal;
        }
        catch(DMLexception e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'class:VO_Specific_Statistics_CTRL method:initModal ;DMLexception'));
        }
        return null;
    }

/**
 * [clickOnEye action function when we click on the eye in the actions in the table
 * this function will change the survey status to pending(if needed ofcourse)]
 * @return [description]
 */
    public PageReference clickOnEye ()
    {
        String id = ApexPages.currentPage().getParameters().get('eyeId');
        VO_Survey__c currsurv ;

        List<VO_Survey__c> surveyList = getSurveyById(id); 

        if(!surveyList.isEmpty())
        {
            currsurv = surveyList[0];
             if(currsurv.Status__c == 'New' && !userReadOnlyOnSurveys)//NEW DEMENED
            {
                currsurv.Status__c = 'Pending';
            }
            try
            {
                update currsurv;
            }
            catch(DMLexception e)
            {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'class:VO_Specific_Statistics_CTRL method:clickOnEye ;DMLexception'));

            }


        }
        return null;
    }

    /**
     * [addNewComment update the Comment_History__c with the format that decided in the relavent survey that choose
     * in the modal]
     * @param survey          [the modal survey]
     * @param commentFromForm [the text that the user wrote]
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
     * [clickSaveModal action function when the user click on save button]
     * @return [description]
     */
    public PageReference clickSaveModal ()
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
        
        if(this.surveyForModal.Status__c == 'New' && !userReadOnlyOnSurveys)
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
            this.surveyForModal = null;
        }
        catch(DMLexception e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'class:VO_Specific_Statistics_CTRL method:clickSaveModal ;DMLexception'));

        }
        return null;
    }

    /**
     * [clickSaveModal action function when the user click on close button]
     * @return [description]
     */
    public PageReference clickCloseCaseModal ()
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
        if(!userReadOnlyOnSurveys)
        {
            this.surveyForModal.Status__c = 'Closed';
        }
        try
        {
            update this.surveyForModal;
            this.surveyForModal = null;
        }
        catch(DMLexception e)
        {

        }
        return null;
    }

/**
 * [clearForm clear search section form
 * currUser is the user as we take him from the db.
 * searchCurrUser the object that we do the manupultions in the search section!
 * so when we clone the regular when we acutaly restore the value of the user that in the page.]
 * @return [description]
 */
    public PageReference clearForm ()
    {
        searchCurrUser = currUser.clone(false,true,false,false);
        searchParam.survey.CAName__c = null;
        // BEGIN RMOU
        storesSelected.clear();
        if (searchCurrUser.TECH_User_Stores__c != null){
            storesSelected.add('--ALL--');
            for (String s : searchCurrUser.TECH_User_Stores__c.split(',')){
                storesSelected.add(s);
            }
        }
        // END RMOU

        return null;
    }


    /**
     * [getSurveyById get survey by id]
     * @param  id [survey id]
     * @return    [the survey with that id ]
     */
    public  List<VO_Survey__c> getSurveyById (String id)
    {
       List<VO_Survey__c> surveyList =  [SELECT id,SurveyType__c,ClientNameText__c, StoreName__c, ClientName__c, DreamIDText__c, Segmentation__c, Type__c,
                            Status__c, AnswerDate__c, Follow_up_by__c, Channel__c, Comment_History__c,
                            Action_delegated_to_CA__c,RootCause__c, ClientDreamID__c, Assign_To__c, STOREDELIVERY__c,STOREORDER__c,Device_Type__c
                            FROM VO_Survey__c
                            WHERE  id =:id ];
        return surveyList;

    }


///////////////////////////////////////////////////////////////Remote ACTION functions - New Search /////////////////////////////////////////////
    
/**
 * [mainSearchRemote ]
 * @param  fromDate       [from which date]
 * @param  toDate         [to which date]
 * @param  currSurvayType [what is the survey type]
 * @param  fieldFilter    [the specficiest field that choose]
 * @param  valueOf        [the value of the ecficiest field that choose]
 * @return                [json with the result of all the surveys that we get from the query with the changes we will do]
 */
    @RemoteAction
    global static String mainSearchRemote(String fromDate, String toDate,String currSurvayType, String fieldFilter,String valueOf)
    {
        Date fromDatedate = fromStringToDate(fromDate);
        // Begin RMOU -- removed the addDays(1) which created discrepancies
        Date toDatedate = fromStringToDate(toDate);
        // End RMOU
        String query = queryCreatorRemote(currSurvayType,fieldFilter,valueOf, false);
        System.Debug (query);
        Map<Id,VO_Survey__c> idToSurveySearchResMap = new Map<Id,VO_Survey__c>((List<VO_Survey__c>)Database.query(query));
        
        List<SurveyTable_Wrapper> surveyTable_WrapperList;
        List<VO_Survey__c> searchResults = idToSurveySearchResMap.values();
        ID surveyId = null;
        if (searchResults.size() > 0) {
            surveyId = searchResults[0].Id;
        }        String jsonResultList = '';
        if (!searchResults.isEmpty())
        {
            surveyTable_WrapperList = generateSearchResToSurveyTable_Wrapper(searchResults,null);
            jsonResultList = JSON.serialize(surveyTable_WrapperList);
        } 
        return jsonResultList;
    }

/**
 * [KPISearchRemote ]
 * @param  fromDate       [from which date]
 * @param  toDate         [to which date]
 * @param  currSurveyType [what is the survey type]
 * @param  fieldFilter    [the specficiest field that choose]
 * @param  valueOf        [the value of the ecficiest field that choose]
 * @param  searchFromId   [Unused - Last id of the previous query (to chain calls and get all results despite 50k limit)]
 * @return                [json with the result of all the surveys that we get from the query with the changes we will do]
 */
    @RemoteAction
    global static String KPISearchRemote(String fDate, String tDate, String currSurveyType, String fieldFilter, String valueOf, Id searchFromId){

        Date fromDatedate = fromStringToDate(fDate);
        Date toDatedate = fromStringToDate(tDate);

        String query = queryCreatorRemote(currSurveyType, fieldFilter, valueOf, true);

        if (searchFromId != null){
            query += ' AND Id >= \'' + searchFromId + '\' ';
        }
        query += ' LIMIT ' + VO_Utils.DEFAULT_n_RESUALTS_PER_SEARCH_EXCEL;

        System.debug(query);

        List<VO_Survey__c>searchResults = Database.query(query);
        String jsonResultList = '';

        Map<String, String> results = new Map<String, String>();

        // NOT USED : for potential follow up queries
        results.put('hasMore', ''+(searchResults.size() == VO_Utils.DEFAULT_n_RESUALTS_PER_SEARCH_EXCEL));
        if (!searchResults.isEmpty()){
            results.put('lastId', searchResults.get(searchResults.size()-1).id);
        }

        results.putAll(computeKPIResults(searchResults));

        jsonResultList = JSON.serialize(results);

        return jsonResultList;
    }

    /**
     * [queryCreatorRemote description]
     * @param  currSurvayType [survey type ]
     * @param  fieldFilter    [the specficiest field that choose]
     * @param  valueOf        [the value of the ecficiest field that choose]
     * @param  isKPI          [is the query for KPI graph]
     * @return                [String of the query that should be done]
     */
    public static String queryCreatorRemote(String currSurvayType, String fieldFilter,String valueOf, Boolean isKPI)
    {
        String ans = '';
        String userStoretype = getUserStoreType();

        if (isKPI){
            // We only need those fields for the KPI graph
            ans += 'SELECT id, Type__c, Status__c, AnswerDate__c';
        }
        else{
            ans += 'SELECT Id, SurveyType__c, Comment_History__c,SurveyComment__c, Status__c,'; 
            ans += ' StoreID__c, Type__c, Assign_To__c,STOREDELIVERY__c,STOREORDER__c,Device_Type__c,';
            ans += ' AnswerDate__c, ClientNameText__c, DreamIDText__c, SegmentationText__c,';
            ans += ' Channel__c, RootCause__c, TransactionProductCategoryCode__c,';
            ans += ' Action_delegated_to_CA__c, Follow_up_by__c, StoreNameText__c,ClientDreamID__c';
            ans +=  queryCreatorAddOnesForAnsForRemote(currSurvayType);
        }
  

        ans += ' FROM VO_Survey__c';
        ans += ' WHERE ';
        ans += ' AnswerDate__c >=: fromDatedate';
        ans += ' AND AnswerDate__c <=: toDatedate';
        ans += ' AND SurveyType__c=\''+ String.escapeSingleQuotes(currSurvayType) + '\'';

        valueOf = valueOf.remove('[').remove(']').replaceAll(' ', '');

        // BEGIN RMOU
        
        Boolean isAdmin = VO_Main_Statistics_CTRL.isAdmin(userinfo.getProfileId());
        Boolean hasStores = [SELECT TECH_User_Stores__c FROM User WHERE id = :UserInfo.getUserId()].TECH_User_Stores__c != null;

        if (!isAdmin && !fieldFilter.contains('StoreID__c') && hasStores){
            fieldFilter = fieldFilter.contains(';') ? 'StoreID__c;' + fieldFilter.subString(fieldFilter.indexOf(';') + 1, fieldFilter.length()) : 'StoreID__c';
            valueOf = valueOf.contains(';') ? '--NOSTORE--;' + valueOf.substring(valueOf.indexOf(';') + 1, valueOf.length()) : '--NOSTORE--';
        }

        // END RMOU

        if(String.isNotBlank(fieldFilter) && String.isNotBlank(valueOf))
        {
            if(fieldFilter.split(';').size() == 2 && valueOf.split(';').size() == 2 ) //when we have CA field too
            {
                // C&C filtering rules: survey delivery store must match the user's default store for all store users
                if((currSurvayType == VO_Utils.VOICE_CC_CSC_SALES ||currSurvayType == VO_Utils.VOICE_CC_WEB_SALES) && userStoretype == 'Store')
                {
                    ans += ' AND STOREDELIVERY__c IN (\''+ String.join(String.escapeSingleQuotes(valueOf.split(';')[0]).split(','), '\',\'') + '\')'; 
                }
                // Endless Offer filtering rules: survey store order must match the user's default store for all CSC users
                else if(currSurvayType == VO_Utils.VOICE_EO_SALES && userStoretype == 'CSC')
                {
                    ans += ' AND STOREORDER__c IN (\''+ String.join(String.escapeSingleQuotes(valueOf.split(';')[0]).split(','), '\',\'') + '\')';  
                }
                else
                {
                    // BEGIN RMOU
                    ans += ' AND '+String.escapeSingleQuotes(fieldFilter.split(';')[0]) +' IN (\''+ String.join(String.escapeSingleQuotes(valueOf.split(';')[0]).split(','), '\',\'') + '\')';
                    // END RMOU
                }
                ans += ' AND '+String.escapeSingleQuotes(fieldFilter.split(';')[1]) +' LIKE \'%'+ String.escapeSingleQuotes(valueOf.split(';')[1]) + '%\' ';
            }
            else
            {
                // C&C filtering rules: survey delivery store must match the user's default store for all store users
                if((currSurvayType == VO_Utils.VOICE_CC_CSC_SALES ||currSurvayType == VO_Utils.VOICE_CC_WEB_SALES) && userStoretype == 'Store')
                {
                    ans += ' AND STOREDELIVERY__c IN (\''+ String.join(String.escapeSingleQuotes(valueOf).split(','), '\',\'') + '\')';  
                }
                // Endless Offer filtering rules: survey store order must match the user's default store for all CSC users
                else if(currSurvayType == VO_Utils.VOICE_EO_SALES && userStoretype == 'CSC')
                {
                    ans += ' AND STOREORDER__c IN (\''+ String.join(String.escapeSingleQuotes(valueOf.split(';')[0]).split(','), '\',\'') + '\')';
                }
                else
                {
                    // BEGIN RMOU
                    ans += ' AND '+String.escapeSingleQuotes(fieldFilter) +' IN (\''+ String.join(String.escapeSingleQuotes(valueOf).split(','), '\',\'') + '\')';
                    // END RMOU
                }
                
            }

        }

        if (!isKPI){
            ans += ' ORDER BY AnswerDate__c DESC';
            ans += ' LIMIT ' + (VO_Utils.DEFAULT_n_RESUALTS_PER_SEARCH + 1);//MY:20.01.2016: due to adding more then EFAULT_n_RESUALTS_PER_SEARCH records massage.
        }

        return ans;
    }

/**
 * [queryCreatorAddOnesForAnsForRemote add the fields that relate to the question ]
 * @return                [string of those fields in format of soql]
 */
    public static String queryCreatorAddOnesForAnsForRemote(String currSurvayType)
    {
        return addQuestionToQuery(initAnswerToRepresentList(currSurvayType));
    
    }

/**
 * [initAnswerToRepresentList description]
 * @param  currSurvayType [survey type]
 * @return                [list of the order of the question and which question that should be in the table and need to query about them too]
 */
    public static List<Integer> initAnswerToRepresentList(String currSurvayType)
    {
        List<String> csSurveyAnswerStringList = new List<String>();
        List<Integer> ansList =  new List<Integer>();
        try
        {
            csSurveyAnswerStringList = VO_Config__c.getValues(currSurvayType + ' columns').Value__c.split(';');
        }
        catch(Exception e)
        {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CS is missing or wrong format'));
            System.debug('class:VO_Specific_Statistics_CTRL method:initAnswerToRepresentList ;CS is missing or wrong format');
        }   

        Set<Integer> numSet = new Set<Integer>();
        for(String q : csSurveyAnswerStringList)
        {
            try 
            {           
                numSet.add(Integer.valueOf(q));
            }
            catch (Exception  e)
            {
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'class:VO_Specific_Statistics_CTRL method:initAnswerToRepresentList ;CS is missing or wrong format'));
                continue ;
            }
        }
        ansList.addAll(numSet);
        return ansList;
    }

    /**
     * [addQuestionToQuery description]
     * @param  answerToRepresentSortedByCSList [answer order List from the custom setting]
     * @return                                 [List of the answer that we should appear in the table]
     */
    public static String addQuestionToQuery(List<Integer> answerToRepresentSortedByCSList)
    {
        string ans = '' ;
        for(Integer i : answerToRepresentSortedByCSList)
        {
            if(i<10)
            {
                ans +=',Q0' + i +'Answer__c ';
                
            }
            else
            {
                //begin MTOU - concatenating Q40 and Q19 answers
                /*if(i == 40)
                   ans +=',Q40Answer__c, Q19Answer__c '; 
                else*/
                    ans +=',Q' + i +'Answer__c ';
            }  
        }
        system.debug('## MTOU addQuestionToQuery ans: ' + ans);
        return ans;
    }

    /**
     * [retLastSurveyBySurveyType we need to be able to get the last survey by survey type in order to set the headers of the table.
     * they are depend in the last survey that in the system]
     * @param  currSurvayType [survey type]
     * @return                [the last survey in the system from this survey type]
     */
    public static VO_Survey__c retLastSurveyBySurveyType(String currSurvayType)
    {
        List<VO_Survey__c> surveyList = [SELECT Id 
                                FROM  VO_Survey__c
                                WHERE answerDate__c <= TODAY
                                AND SurveyType__c =: currSurvayType
                                ORDER BY answerDate__c desc
                                LIMIT 1 ];
        return surveyList.isEmpty() ? null : surveyList[0];

    }

    /**
     * @param  currSurvayType [survey type///]
     * @return                [list of al the relavent data in order to preasent the headers ]
     */
    @RemoteAction
    public static List<AnswerHeader_Wrapper> initHeaderWrapperListQRemoteAction(String currSurvayType)
    {
        System.debug('initHeaderWrapperListQRemoteAction: ');
        ID surveyId = null;
        List<AnswerHeader_Wrapper> ans = new List<AnswerHeader_Wrapper>();
        VO_Survey__c lastSurvey =  retLastSurveyBySurveyType(currSurvayType);
        if (lastSurvey != null) {
            surveyId = lastSurvey.Id;
            System.debug('-----------' + surveyId);
            ans = updateHeaderWrapperListQ(initAnswerToRepresentList(currSurvayType), surveyId);
        }
        system.debug('## MTO ans: '+ ans);
        return ans;
    }

    /**
     * [updateHeaderWrapperListQ description]
     * @param  answerToRepresentSortedByCSList [from the CS]
     * @param  surveyID                        [survey id that we take from him the header]
     * @return                                [list of al the relavent data in order to preasent the headers ]
     */
    public static List<AnswerHeader_Wrapper> updateHeaderWrapperListQ(List<Integer> answerToRepresentSortedByCSList, ID surveyID)
    {
        List<AnswerHeader_Wrapper> ansWrapperList = new List<AnswerHeader_Wrapper>();
        String shortname = '' ;
        String title = '' ;
        String origanSFansNum = '';
        VO_Survey__c srv = null;
        if (surveyId != null) srv = getTitleAndShortName(answerToRepresentSortedByCSList, surveyID);
        for(Integer i=0;i<answerToRepresentSortedByCSList.size();i++) {
            shortname = '';
            title = '';
            if(srv != null) {
                Integer j = answerToRepresentSortedByCSList[i];
                if (j<10) {
                    shortname = (String)srv.get('Q0'+j+'Shortname__c');
                    title = (String)srv.get('Q0'+j+'Title__c');
                }
                else {           
                    shortname = (String)srv.get('Q'+j+'Shortname__c');
                    title = (String)srv.get('Q'+j+'Title__c');

                }
                origanSFansNum = j+'';
            }
            ansWrapperList.add(new AnswerHeader_Wrapper(title, shortname,origanSFansNum));
        }
    return ansWrapperList;
    }

    /**
     * [getTitleAndShortName description]
     * @return     get the fields that relavent to the headers 
     */
    private static VO_Survey__c getTitleAndShortName(List<Integer> answerToRepresentSortedByCSList, ID surveyID) {
        String query = '';
        for(Integer i=0;i<answerToRepresentSortedByCSList.size();i++) {
            Integer j = answerToRepresentSortedByCSList[i];
            query += (j< 10 ? ', Q0' +j+'Title__c, Q0'+j+'Shortname__c ' : ', Q' +j+'Title__c, Q'+j+'Shortname__c ');
        }
        query = 'select Id ' + query + ' from VO_Survey__c where Id = \'' + surveyID + '\' limit 1';
        List<VO_Survey__c> lsrv = Database.query(query);
        if (lsrv.size() == 1)
            return lsrv[0];
        else
            return null;
    }
    
     /**
     *  Indicates the type of store the user is affected to
     * */
    public static String getUserStoreType()
    {
        String userStoreType = '';
        List<User> l = [Select id, DefaultStore__c from User where id =: UserInfo.getUserId() ];

        if (l.isEmpty())
            return userStoretype;

        User currentUser = l[0];

        if(currentUser.DefaultStore__c != null)
        {
            List<Store__c> s = [Select StoreType__c from Store__c where RetailStoreId__c =: currentUser.DefaultStore__c];
            if (s.isEmpty())
                return userStoretype;

            Store__c userDefaultStore = s[0];
            if(userDefaultStore != null)
            {
                userStoreType = userDefaultStore.StoreType__c;
            }
        }
        return userStoreType;
        
    }

/////////////////////////////////////////////////////////////////////////////////END REMOTE ACTION CHANGES//////////////////////////

/////////////////////////////Start OF OLD SEARCH FUNCTIONS /////////////////////////////////////////
    public PageReference mainSearch ()
    {
        Date fromDatedate = fromStringToDate(fromDate);
        Date toDatedate = fromStringToDate(toDate).addDays(1);

        DateTime refDate1 = DateTime.newInstance(fromdatedate.year(), fromdatedate.month(), fromdatedate.day(), 0, 0, 0);
        DateTime refDate2 = DateTime.newInstance(todatedate.year(), todatedate.month(), todatedate.day(), 0, 0, 0);

        String query = queryCreator(false);
        List<SurveyTable_Wrapper> surveyTable_WrapperList;
        try 
        {
            this.idToSurveySearchResMap = new Map<Id,VO_Survey__c>((List<VO_Survey__c>)Database.query(query));
            retAggregateResSurvayData(this.idToSurveySearchResMap.keySet());
            this.searchResults = idToSurveySearchResMap.values();
            ID surveyId = null;
            if (this.searchResults.size() > 0) {
                surveyId = this.searchResults[0].Id;
                this.headerWrapperListQ = updateHeaderWrapperListQ(this.answerToRepresentSortedByCSList, surveyId);
            }
            this.jsonResultList = '';
            if (!this.searchResults.isEmpty())
            {
                surveyTable_WrapperList = generateSearchResToSurveyTable_Wrapper(this.searchResults, this.answerToRepresentSortedByCSList);
               //05.01.2016 :MY : comment removeBRinComments function
               //MY-made the BR in the client-side;BW did a batch for the leading zero;
               // removeBRinComments(surveyTable_WrapperList);
                this.jsonResultList = JSON.serialize(surveyTable_WrapperList);
                system.debug('## jsonResultList: ' + jsonResultList);
            } 
            
        }
        catch (DMLexception  e)
        {
            throw e;
            return null;
        }
        return null;
    }

    private String queryCreatorAddOnesForAns(  )
    {
        this.answerToRepresentSortedByCSList = initAnswerToRepresentList(currSurvayType); //set(group) and not list in case the admin will put the same number twice

        return addQuestionToQuery(this.answerToRepresentSortedByCSList);
    }

    private String queryCreator(Boolean isAggregate)
    {
        Date fromDatedate = fromStringToDate(fromDate);
        Date toDatedate = fromStringToDate(toDate).addDays(1);

        String ans='';
        if(isAggregate)
        {
            ans +='SELECT COUNT(Id), SurveyType__c, Status__c, Type__c';
        }
        else
        {
            ans += 'SELECT Id, SurveyType__c, Comment_History__c,SurveyComment__c, Status__c,'; 
            ans += ' StoreID__c, Type__c,Assign_To__c,STOREDELIVERY__c,STOREORDER__c,Device_Type__c,';
            ans += ' AnswerDate__c, ClientNameText__c, DreamIDText__c, SegmentationText__c,';
            ans += ' Channel__c, RootCause__c,';
            ans += ' Action_delegated_to_CA__c, Follow_up_by__c, StoreNameText__c,ClientDreamID__c';
            ans +=  queryCreatorAddOnesForAns();
        }
        ans += ' FROM VO_Survey__c';
        ans += ' WHERE ';

        ans += ' AnswerDate__c >=: fromDatedate';
        ans += ' AND AnswerDate__c <=: toDatedate';
        ans += ' AND SurveyType__c=\''+ currSurvayType + '\'';

        // Begin RMOU
        if (!String.isBlank(searchCurrUser.TECH_User_Stores__c))
        {
            ans += ' AND StoreID__c IN (\'' + String.join(searchCurrUser.TECH_User_Stores__c.split(','), '\',\'') + '\')';
        }
        // END RMOU
        else if (!String.isBlank(searchCurrUser.MGMT_ZONE_SUB_LEVEL3__c))
        {
            ans += ' AND MGMT_ZONE_SUB_LEVEL3__c=\'' + searchCurrUser.MGMT_ZONE_SUB_LEVEL3__c + '\'';
        }
        else if (!String.isBlank(searchCurrUser.MGMT_ZONE_SUB_LEVEL2__c))
        {
            ans += ' AND MGMT_ZONE_SUB_LEVEL2__c=\'' + searchCurrUser.MGMT_ZONE_SUB_LEVEL2__c + '\'';
        }

        else if (!String.isBlank(searchCurrUser.MGMT_ZONE_SUB_LEVEL1__c))
        {
            ans += ' AND MGMT_ZONE_SUB_LEVEL1__c=\'' + searchCurrUser.MGMT_ZONE_SUB_LEVEL1__c + '\'';
        }
        else if (!String.isBlank(searchCurrUser.MANAGEMENT_ZONE_LEVEL__c))
        {
            ans += ' AND MANAGEMENT_ZONE_LEVEL__c=\'' + searchCurrUser.MANAGEMENT_ZONE_LEVEL__c + '\'';
        }
        if (!String.isBlank(searchParam.survey.CAName__c))
        {
            ans += ' AND CAName__c=\'' + searchParam.survey.CAName__c + '\'';
        }
        if(isAggregate)
        {
            ans += ' AND Id IN:idsFromSearchSet'; 
            ans += ' GROUP BY SurveyType__c, Status__c, Type__c';   
        }
        else
        {
            ans += ' ORDER BY AnswerDate__c DESC';
            ans += ' LIMIT ' + VO_Utils.DEFAULT_n_RESUALTS_PER_SEARCH ;
        }
        return ans;
    }
    
    public PageReference changeSurveyType()
    {
        this.headerWrapperListQ = initHeaderWrapperListQRemoteAction(this.currSurvayType);
        return null;
    }

    /**
     * @scenario    []
     * @result  [ ]
     * @createdBy   Menash Yamin         
     * @lastModifiedBy  Menash Yamin 
     */
    private void retAggregateResSurvayData (Set<Id> idsFromSearchSet)
    {
        Date fromDatedate = fromStringToDate(fromDate);
        Date toDatedate = fromStringToDate(toDate).addDays(1);
        String queryStr = queryCreator(true);
        List<AggregateResult> results = Database.query(queryStr);
        Map<String, VO_SurvayTypeStat> survayTypeStatMap = new Map<String, VO_SurvayTypeStat>();
        survayTypeStatMap.put(currSurvayType, new VO_SurvayTypeStat(currSurvayType));
        VO_SurvayTypeStat.updatesurvayTypeStatMap (survayTypeStatMap, results);
        this.survayTypeStat = survayTypeStatMap.get(currSurvayType);
    }


    //for the title in the tooltip  
    //private void removeBRinComments(List<SurveyTable_Wrapper> surveyTable_WrapperList)
    //{
    //    Integer numAnsValue;
    //    for(SurveyTable_Wrapper stw:surveyTable_WrapperList)
    //    {
    //        if(stw.survey.Comment_History__c != null){
    //            // BW
    //            //stw.survey.Comment_History__c = String.join(stw.survey.Comment_History__c.split('\n'),'  ');
    //            //stw.survey.Comment_History__c.replace('\n',' ');
    //        }

    //        //for leading zero
    //        for(Integer ansNum=0; ansNum<stw.answerTableList.size() ;ansNum++)
    //        {
    //            // BW
    //            //try 
    //            //{  

    //                // BW
    //               if (stw.answerTableList[ansNum].isNumeric() && stw.answerTableList[ansNum].length() == 1)         
    //               //numAnsValue = Integer.valueOf(stw.answerTableList[ansNum]);
    //               //if(numAnsValue < 10)
    //               {
    //                stw.answerTableList[ansNum] = '0'+stw.answerTableList[ansNum];
    //               }
    //   /*         }
    //            catch (Exception  e)
    //            {
                    
    //            }
    //   */     }

    //    }
    //}
    //
    //
    //
    //
    public static List<String> updateHeaderListQ(List<VO_Survey__c> searchResults ,List<Integer> answerToRepresentSortedByCSList)
    {
        List<String> ansList = new List<String>();
        String shortname = '' ;
        if(!searchResults.isEmpty()){

            for(Integer i=0;i<answerToRepresentSortedByCSList.size();i++)
            {
                if(answerToRepresentSortedByCSList[i]<10)
                {
                    shortname = (String)searchResults[0].get('Q0'+answerToRepresentSortedByCSList[i]+'Shortname__c');
                }
                else
                {
                    shortname = (String)searchResults[0].get('Q'+answerToRepresentSortedByCSList[i]+'Shortname__c');
                    
                }
                if(shortname == null)
                {
                    shortname = '';
                }
                ansList.add(shortname);
            }
        }
        return ansList;
    }
/////////////////////////////END OF OLD SEARCH FUNCTIONS /////////////////////////////////////////


    

    /**
     * [generateSearchResToSurveyTable_Wrapper change the survey list to the SurveyTable_Wrapper]
     */
    public static List<SurveyTable_Wrapper> generateSearchResToSurveyTable_Wrapper(List<VO_Survey__c> searchResults,List<Integer>  answerToRepresentSortedByCSList)
    {
        List<SurveyTable_Wrapper> ans = new List <SurveyTable_Wrapper>();
        for(VO_Survey__c srv :searchResults)
        {
            //MY 2016.05.01 TRY TO AVODING GENERATE FUNCTION LIST IN THE MAIN SEARCH - do in in the smart table!
            //ans.add(new SurveyTable_Wrapper(srv,createAnsList(srv,answerToRepresentSortedByCSList)));
            ans.add(new SurveyTable_Wrapper(srv,null));
        }
        return ans;
    }

    /*  Computes the KPI values from the list of Surveys
    *   Returns a Map of values used by for the KPI chart
    */
    public static Map<String, String> computeKPIResults(List<VO_Survey__c> searchResults){
        Map<String, String> resultMap = new Map<String, String>{
            'New'           => '0',
            'Pending'       => '0',
            'closed'        => '0',
            'no action'     => '0',
            'KPIPC'         => '0',
            'PMNew'         => '0',
            'PMpending'     => '0',
            'KPIDC'         => '0',
            'DCnew'         => '0',
            'DCpending'     => '0',
            'KPIRA'         => '0',
            'RAnew'         => '0',
            'RApending'     => '0',
            'RApending7d'   => '0',
            'PM'            => '0',
            'DC'            => '0',
            'RA'            => '0'
        };

        for (VO_Survey__c survey : searchResults){
            if(survey.Type__c == 'Recovery Act')
            {
                resultMap.put('RA', '' + (Integer.valueOf(resultMap.get('RA'))  +1));
            }
            if(survey.Type__c == 'Delighted Client')
            {
                resultMap.put('DC', '' + (Integer.valueOf(resultMap.get('DC'))  +1));
            }

            if(survey.Type__c == 'Promoter')
            {
                resultMap.put('PM', '' + (Integer.valueOf(resultMap.get('PM'))  +1));
            }

            if(survey.Status__c =='No action')
            {
                resultMap.put('no action', '' + (Integer.valueOf(resultMap.get('no action')) +1));
            }
            if(survey.Status__c =='Closed')
            {
                resultMap.put('closed', '' + (Integer.valueOf(resultMap.get('closed')) +1));
            }
            if(survey.Status__c =='New')
            {
                resultMap.put('New', '' + (Integer.valueOf(resultMap.get('New')) +1));
                if(survey.Type__c == 'Recovery Act')
                {
                    resultMap.put('RAnew', '' + (Integer.valueOf(resultMap.get('RAnew')) +1));
                }
                if(survey.Type__c == 'Delighted Client')
                {
                    resultMap.put('DCnew', '' + (Integer.valueOf(resultMap.get('DCnew')) +1));
                }
                if(survey.Type__c == 'Promoter')
                {
                    resultMap.put('PMNew', '' + (Integer.valueOf(resultMap.get('PMNew')) +1));
                }
            }
            if(survey.Status__c =='Pending')
            {
                resultMap.put('Pending', '' + (Integer.valueOf(resultMap.get('Pending')) +1));
                if(survey.Type__c == 'Recovery Act')
                {
                    resultMap.put('RApending', '' + (Integer.valueOf(resultMap.get('RApending')) +1));
                    if(survey.AnswerDate__c < Date.today().addDays(-7))
                    {
                        resultMap.put('RApending7d', '' + (Integer.valueOf(resultMap.get('RApending7d')) +1));
                    }
                }
                if(survey.Type__c == 'Delighted Client')
                {
                    resultMap.put('DCpending', '' + (Integer.valueOf(resultMap.get('DCpending')) +1));

                }
                if(survey.Type__c == 'Promoter')
                {
                    resultMap.put('PMpending', '' + (Integer.valueOf(resultMap.get('PMpending')) +1));
                }
            }
        }

        Integer total = Integer.valueOf(resultMap.get('New')) + Integer.valueOf(resultMap.get('Pending')) + Integer.valueOf(resultMap.get('closed')) + Integer.valueOf(resultMap.get('no action'));

        if (total != 0){
            resultMap.put('KPIPC', '' + Math.roundToLong(100*(Decimal.valueOf(resultMap.get('PM'))) / total));
            resultMap.put('KPIDC', '' + Math.roundToLong(100*(Decimal.valueOf(resultMap.get('DC'))) / total));
            resultMap.put('KPIRA', '' + Math.roundToLong(100*(Decimal.valueOf(resultMap.get('RA'))) / total));
        }

        return resultMap;
    }

/////////// STARR VOICE 2: CR 18  MY:21.01.2016  action before export to PDF  //////
/**
 * [changeSurveyStatusAfterexportToPDF change the surveys that picked in the export PDF and change there status
 * if requeird ]
 * @param  surveyIdList [description]
 * @return              [description]
 */
    @RemoteAction
    public static List<String> changeSurveyStatusAfterexportToPDF(List<String> surveyIdList)
    {
        List<VO_Survey__c> surveyList = getSurveysByIdList(surveyIdList);
        Boolean userReadOnlyOnSurveys = initUserReadOnlyOnSurveys();
        List<VO_Survey__c> surveyNeedToUpdateList = new List<VO_Survey__c>();
        
        for(VO_Survey__c sur : surveyList)
        {
            if(sur.Status__c == 'New'&& !userReadOnlyOnSurveys) //NEW Demand DY 29.03.2016
            {
                sur.Status__c = 'Pending';
                surveyNeedToUpdateList.add(sur);
            }
        }
        try{
            update surveyNeedToUpdateList;
        }
        catch(Exception e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Dml Exception'));
        }

        List<String> ans = new List<String>();
        for(VO_Survey__c sur : surveyNeedToUpdateList)
        {
            ans.add(sur.id);
        }

        return ans;
    }
    /**
     * [getSurveysByIdList you can guess :)]
     * @param  ids [ids of surveys]
     * @return     [List of those ids]
     */
    public static List<VO_Survey__c> getSurveysByIdList (List<String> ids)
    {
       List<VO_Survey__c> surveyList =  [SELECT id, Type__c,Status__c 
                            FROM VO_Survey__c
                            WHERE  id IN: ids ];
        return surveyList;

    }
/////////// END VOICE 2: CR 18  MY:21.01.2016  action before export to PDF  //////

    public class SearchFilter_Wrapper{
        public Store__c store {get; Set;}
        public VO_Survey__c survey {get; Set;}

        public SearchFilter_Wrapper()
        {
            this.store = new Store__c();
            this.survey = new VO_Survey__c();
        }
    }

    public class SurveyTable_Wrapper
    {
        public VO_Survey__c survey {get;set;}
        public List<String> answerTableList {get;set;}
        public SurveyTable_Wrapper(VO_Survey__c survey, List<String> answerTableList)
        {
            this.survey = survey;
            this.answerTableList = answerTableList;
        }
    }

    public class AnswerHeader_Wrapper
    {
        public String title {get;set;}
        public String shortname {get;set;}
        public String origanSFansNum {get;set;}
        public AnswerHeader_Wrapper(String title, String shortname)
        {
            this.title = title;
            this.shortname = shortname;
            this.origanSFansNum = '';
        }

        public AnswerHeader_Wrapper(String title, String shortname, String origanSFansNum)
        {
            this.title = title;
            this.shortname = shortname;
            this.origanSFansNum = origanSFansNum;
        }
    }

}