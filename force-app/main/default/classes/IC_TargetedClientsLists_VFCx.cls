public with sharing class IC_TargetedClientsLists_VFCx {
    // Members
    public Id sDreamUserId {get;set;}
    public CLI_CliList__c oClientsList {get;set;}
    public Account oSearchAccount {get;set;}
    public PPR_PurchProduct__c oSearchPurchasedProduct {get;set;}
    public list<Account> lClientsList {get;set;}
    String[] OutreachScope = new String[]{};
    
    
    public List<SelectOption> getOutreachScopeItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(System.Label.IC_Last_Store_Outreach,System.Label.IC_Last_Store_Outreach));
        options.add(new SelectOption(System.Label.IC_Last_Corporate_Outreach,System.Label.IC_Last_Corporate_Outreach));
        return options;
    }
    
    //hch
   /* public List<SelectOption> getTurnoverDurings() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(System.Label.IC_Turnover_During,System.Label.IC_Turnover_During));
        return options;
    }
    public string[] TurnoverDuring {get;set;}
    */
    public String[] getOutreachScope() {
        return OutreachScope;
    }

    public void setOutreachScope(String[] OutreachScope) {
        this.OutreachScope = OutreachScope;
    }
    
    // Product Category - Multi picklist
    public list<SelectOption> getProductCategory(){
        Schema.DescribeFieldResult oFieldResult = PPR_PurchProduct__c.ProductLine__c.getDescribe();
        return multiPicklist(oFieldResult, false);
    }
    public list<string> lProductCategory {get;set;}
    //HCH
    // LogicOperator - radioBouton
     public List<SelectOption> getLogicOperators() {
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_LogicOperator__c.getDescribe();
        return multiPicklist(oFieldResult, false); 
    }
    public string LogicOp {get;set;}
    {
      LogicOp = 'OR';
    }
    // Segmentation - Single picklist
    public list<SelectOption> getSegmentation(){
        Schema.DescribeFieldResult oFieldResult = Account.Segmentation__pc.getDescribe();
        list<SelectOption> lOptions = new list<SelectOption>();
        lOptions = multiPicklist(oFieldResult, false);
        
        for(integer i=0; i<lOptions.size(); i++){
            if(lOptions[i].getValue() == 'Sleepers'){
                lOptions.remove(i);
                break;
            }
        }
        
        return lOptions;
    }  
    //hch
    public list<string> lSegmentation {get;set;}
    
    // BirthdateMonth - Single picklist
    public list<SelectOption> getBirthdateMonth(){
        Schema.DescribeFieldResult oFieldResult = Account.BirthdateMonth__pc.getDescribe();
        return multiPicklist(oFieldResult, true);
    }
    
    // Gender - Single picklist
    public list<SelectOption> getGender(){
        Schema.DescribeFieldResult oFieldResult = Account.Gender__pc.getDescribe();
        return multiPicklist(oFieldResult, true);
    }
                 
    // Action Type - Multi picklist
    public list<SelectOption> getActionType(){
        Schema.DescribeFieldResult oFieldResult = Task.ActionType__c.getDescribe();
        return multiPicklist(oFieldResult,true);
    }         
    public list<string> lActionType {get;set;}
    
    // Currencies picklist
    public list<SelectOption> getCurrency(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_Currencies__c.getDescribe();
        return multiPicklist(oFieldResult);
    }         
    public string sCurrency {get;set;}
    
    // Spend field picklist - 1
    public list<SelectOption> getSpendField(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_SpendFields__c.getDescribe();
        return multiPicklist(oFieldResult);
    }
    public list<SelectOption> getOperator(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_Operators__c.getDescribe();
        return multiPicklist(oFieldResult);
    }         
    public string sSpendField {get;set;}
    public string sOperator {get;set;} 
    public integer iSpendAmount {get;set;}
    
    // Spend field picklist - 2
    public list<SelectOption> getSpendField2(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_SpendFields__c.getDescribe();
        return multiPicklist(oFieldResult);
    }
    public list<SelectOption> getOperator2(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_Operators__c.getDescribe();
        return multiPicklist(oFieldResult);
    }
    //hch
    // Spend field picklist - 3
    public list<SelectOption> getOperator3(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_Operators__c.getDescribe();
        return multiPicklist(oFieldResult);
    }
    public integer iSpendAmount3 {get;set;} 
    public string sOperator3 {get;set;} 
    
    // Spend field picklist - 4
    public list<SelectOption> getOperator4(){
        Schema.DescribeFieldResult oFieldResult = Contact.TECH_Operators__c.getDescribe();
        return multiPicklist(oFieldResult);
    }
    public integer iSpendAmount4 {get;set;} 
    public string sOperator4 {get;set;} 
        
    // MTO - Purchased Product gender
    public list<SelectOption> getProductGender(){ 
        Schema.DescribeFieldResult oFieldResult = PPR_PurchProduct__c.ProductGender__c.getDescribe();
        list<SelectOption> lOptions = new list<SelectOption>();
        lOptions = multiPicklist(oFieldResult, true);
        return lOptions;
    } 
    //HCH  - Client Information Filter
    public string SMS {get;set;}
    public list<SelectOption> getlSMS(){
        list<SelectOption> lOptions = new list<SelectOption>();
        lOptions.add(new SelectOption('',''));
        lOptions.add(new SelectOption(System.Label.IC_contactable_filter_Account,System.Label.IC_contactable_filter_Account));
        lOptions.add(new SelectOption(System.Label.IC_not_contactable_filter_Account,System.Label.IC_not_contactable_filter_Account));
        return lOptions;
    }
    public string Email {get;set;}  
    public list<SelectOption> getlEmail(){
        list<SelectOption> lOptions = new list<SelectOption>();
        lOptions.add(new SelectOption('',''));
        lOptions.add(new SelectOption(System.Label.IC_contactable_filter_Account,System.Label.IC_contactable_filter_Account));
        lOptions.add(new SelectOption(System.Label.IC_not_contactable_filter_Account,System.Label.IC_not_contactable_filter_Account));
        return lOptions;
    }
    public string Call {get;set;}   
    public list<SelectOption> getlCall(){
        list<SelectOption> lOptions = new list<SelectOption>();
        lOptions.add(new SelectOption('',''));
        lOptions.add(new SelectOption(System.Label.IC_contactable_filter_Account,System.Label.IC_contactable_filter_Account));
        lOptions.add(new SelectOption(System.Label.IC_not_contactable_filter_Account,System.Label.IC_not_contactable_filter_Account));
        return lOptions;
    } 
    public string Post {get;set;}   
    public list<SelectOption> getlPost(){
        list<SelectOption> lOptions = new list<SelectOption>();
        lOptions.add(new SelectOption('',''));
        lOptions.add(new SelectOption(System.Label.IC_contactable_filter_Account,System.Label.IC_contactable_filter_Account));
        lOptions.add(new SelectOption(System.Label.IC_not_contactable_filter_Account,System.Label.IC_not_contactable_filter_Account));
        return lOptions;
    } 

               
    public string sSpendField2 {get;set;}
    public string sOperator2 {get;set;} 
    public integer iSpendAmount2 {get;set;} 
    
    //Constants
    public static integer NBROWS{get{return (ICONSettings__c.getInstance().Targeted_Clients_Lists_Nb_Rows__c==null?1000:Math.min(1000,ICONSettings__c.getInstance().Targeted_Clients_Lists_Nb_Rows__c).intValue());}}
    public Integer iFoundClientsCount {get{return lClientsList.size();}}
    public boolean bSearch {get;set;}
    public boolean bMaxRowsReached {get;set;}
    public boolean bRowReturned {get;set;}
    
    public User myUser {get;set;} 
    public String userHierarchyLvl0 {get;set;} // Zone Level for user
    public String userHierarchyLvl1 {get;set;} // Sub Level 1 for user
    public String userHierarchyLvl2 {get;set;} // Sub Level 2 for user
    public String userHierarchyLvl3 {get;set;} // Sub Level 3 for user
    public String userHierarchyStore {get;set;} // Store Level for user
    //public boolean bTurnoverDuringError {get;set;}
    
    // ---------------------------------
    // CONSTRUCTOR
    // ---------------------------------
    public IC_TargetedClientsLists_VFCx(){        
        // Init variables
        lProductCategory = new list<string>();
        lActionType = new list<string>();
        lSegmentation = new list<string>();
        sCurrency = '';
        sSpendField = '';
        sOperator = '';
        sSpendField2 = '';
        sOperator2 = '';
        sOperator3 = '';
        sOperator4 ='';
        bSearch = false;
        oClientsList = new CLI_CliList__c();
        oSearchAccount = new Account();
        oSearchPurchasedProduct = new PPR_PurchProduct__c();
        lClientsList = new list<Account>();

        
        // Recover DREAM User Id
        for(User oUser:[select id from User where Name = 'DREAM' limit 1]){
            sDreamUserId = oUser.Id;
        }
    }
    
    // ---------------------------------
    // searchClients method
    // STI 18/11/2015 - Added Store Hierarchy info as query criteria
    // ---------------------------------
    public void searchClients(){
        system.debug('### CVER START - searchClients');
        lClientsList.clear();
        bSearch = true;
        bMaxRowsReached = false;
        bRowReturned = false;
        //bTurnoverDuringError = false;
        iCurrentPage = 1;
        SortField = 'Name';
        PreviousSortField = 'Name';
        
        set<string> tempSetVal = new set<string>();

        
        string sQueryString = '';        
        string sQueryFilter = '';
        string orQueryString = ''; 

        
        //hch
         /* tempSetVal.clear();
          tempSetVal.addAll(TurnoverDuring);
          if(tempSetVal.contains(System.Label.IC_Turnover_During) && (iSpendAmount3 == null || iSpendAmount3 == 0) && (iSpendAmount4 == null || iSpendAmount4 == 0) ){
                bTurnoverDuringError = true;
            
          }    */
        
            // Recover accounts that:
            // - are person accounts
            // - are assigned to an active user
            // - are not assigned to the "DREAM" user
            // - respect the search criteria defined by the user 
            sQueryString = 'select Id, PersonContactId, Name, IsPersonAccount, Segmentation__pc, HistoricalSpendUSD__pc, LastTrans__pc, OwnerId, Owner.Name, Owner.LastName, TECH_Selected__pc, AttachedStore__pc ';
            sQueryString += ' from Account where IsPersonAccount = true';
            sQueryString += ' and Owner.IsActive = true';
            
            // Clients assigned to DREAM are not recovered
            if(sDreamUserId != null)
                sQueryString += ' and OwnerId != \'' + sDreamUserId + '\'';
            
            // MTO Clients assigned to technical users are not recovered
            sQueryString += 'and isDREAM__c = false';
            
            // ---------------------------------
            // ACCOUNT filters
            // ---------------------------------
            
            // -------- User Store Hierarchy ----------
            myUser = [ Select Id, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c From User Where Id = :UserInfo.getUserId()];
                
            userHierarchyLvl0 = myUser.MANAGEMENT_ZONE_LEVEL__c; // Zone Level for user
            userHierarchyLvl1 = myUser.MGMT_ZONE_SUB_LEVEL1__c; // Sub Level 1 for user
            userHierarchyLvl2 = myUser.MGMT_ZONE_SUB_LEVEL2__c; // Sub Level 2 for user
            userHierarchyLvl3 = myUser.MGMT_ZONE_SUB_LEVEL3__c; // Sub Level 3 for user
            userHierarchyStore = myUser.DefaultStore__c; // Store Level for user

            //Store filter if user is manager or animator
            if (IC_UTILS.isSAManager() || IC_UTILS.isSAAnimator()){
                 String managerStore = IC_UTILS.getUserStore();
                 managerStore = String.escapeSingleQuotes(managerStore);
                 sQueryString += ' and AttachedStore__pc = \''+ managerStore + '\'';
            }else if (!IC_UTILS.isSystemAdmin()){
                if(userHierarchyStore != null && userHierarchyStore != ''){ // if Store is defined on user, filter criteria on AttachedStore__pc field
                    String temp = String.escapeSingleQuotes(userHierarchyStore);
                    sQueryString += ' and AttachedStore__pc = \''+ temp + '\'';
                }else{// if no store on user, filter criteria based on Store__pc lookup on client compared to hierarchy management fields on user details from lower to top
                    String myStoreQuery = 'Select Id from Store__c ';
                    if(userHierarchyLvl3 != null && userHierarchyLvl3 != ''){
                        String temp = String.escapeSingleQuotes(userHierarchyLvl3);
                        myStoreQuery += ' WHERE MGMT_ZONE_SUB_LEVEL3__c = \''+ temp + '\'';
                    }else if(userHierarchyLvl2 != null && userHierarchyLvl2 != ''){
                        String temp = String.escapeSingleQuotes(userHierarchyLvl2);
                        myStoreQuery += ' WHERE MGMT_ZONE_SUB_LEVEL2__c = \''+ temp + '\'';
                    }else if(userHierarchyLvl1 != null && userHierarchyLvl1 != ''){
                        String temp = String.escapeSingleQuotes(userHierarchyLvl1);
                        myStoreQuery += ' WHERE MGMT_ZONE_SUB_LEVEL1__c = \''+ temp + '\'';
                    }else if(userHierarchyLvl0 != null && userHierarchyLvl0 != ''){
                        String temp = String.escapeSingleQuotes(userHierarchyLvl0);
                        myStoreQuery += ' WHERE MANAGEMENT_ZONE_LEVEL__c = \''+ temp + '\'';
                    }
                    system.debug('### DEBUG myStoreQuery:' + myStoreQuery);
    
                    // Execute the query
                    List<Store__c> lstStore = Database.query(myStoreQuery);
                    String strLstStore = '';
                    for(Store__c s : lstStore){
                        strLstStore += '\'' + s.Id + '\',';
                    }
                    strLstStore = strLstStore.removeEnd(',');
                    
                    if(lstStore != null && lstStore.size() >0){
                        sQueryString += ' and Store__pc IN ('+ strLstStore + ')';
                    }
                }
            }
            
            // Last Purchased date
            if(oSearchAccount.TECH_LastPurchasedDateFrom__pc != null){
                DateTime dLastPurchasedDateFrom = DateTime.newInstance(oSearchAccount.TECH_LastPurchasedDateFrom__pc, Time.newInstance(0, 0, 0, 0));
                sQueryFilter += ' and LastTrans__pc >= ' + dLastPurchasedDateFrom.format('yyyy-MM-dd');     
            }
            if(oSearchAccount.TECH_LastPurchasedDateTo__pc != null){
                DateTime dLastPurchasedDateTo = DateTime.newInstance(oSearchAccount.TECH_LastPurchasedDateTo__pc, Time.newInstance(0, 0, 0, 0));
                sQueryFilter += ' and LastTrans__pc <= ' + dLastPurchasedDateTo.format('yyyy-MM-dd');   
            }

            // Segmentation
            //hch
            tempSetVal.clear();
            tempSetVal.addAll(lSegmentation);
            if(!lSegmentation.isEmpty() && !tempSetVal.contains(System.Label.IC_All_Value)){
                sQueryFilter += ' and Segmentation__pc in ('; 
                sQueryFilter += inFilter(lSegmentation);
                sQueryFilter += ')';
            }           
    
            // DREAM Id
            if(oSearchAccount.DREAMID__c != null && oSearchAccount.DREAMID__c != ''){
                system.debug('### CVER DREAM Id:' + oSearchAccount.DREAMID__c);
                
                list<String> lDREAMIds = new List<String>();
                lDREAMIds = oSearchAccount.DREAMID__c.deleteWhitespace().split(',',-1);
                
                sQueryFilter += ' and DREAMId__c in ('; 
                sQueryFilter += inFilter(lDREAMIds);
                sQueryFilter += ')';
            }
        
            // Do Not Call       

            if(Call == System.Label.IC_not_contactable_filter_Account){
                sQueryFilter += ' and PersonDoNotCall = true';
            }else if(Call == System.Label.IC_contactable_filter_Account){
                sQueryFilter += ' and PersonDoNotCall = false'; 
            }
        
            
            // Do Not Send Email

            if(Email == System.Label.IC_not_contactable_filter_Account){
                sQueryFilter += ' and PersonHasOptedOutOfEmail = true';
            }else if(Email == System.Label.IC_contactable_filter_Account){
                sQueryFilter += ' and PersonHasOptedOutOfEmail = false';    
            }
            
            // Do Not SMS
            if(SMS == System.Label.IC_not_contactable_filter_Account){
                sQueryFilter += ' and DoNotSMS__pc = true';
            }else if(SMS == System.Label.IC_contactable_filter_Account){
                sQueryFilter += ' and DoNotSMS__pc = false';    
            }
            // Do Not Contact by Post
            if(Post == System.Label.IC_not_contactable_filter_Account){
                sQueryFilter += ' and DoNotContactbyPost__pc = true';
            }else if(Post == System.Label.IC_contactable_filter_Account){
                    sQueryFilter += ' and DoNotContactbyPost__pc = false';  
            }       
            
            // Birthdate Month
            if(oSearchAccount.BirthdateMonth__pc != null && !oSearchAccount.BirthdateMonth__pc.contains(System.Label.IC_All_Value)){
                sQueryFilter += ' and BirthdateMonth__pc = \'' + oSearchAccount.BirthdateMonth__pc + '\'';  
            }       
            
            // Gender Month
            if(oSearchAccount.Gender__pc != null  && !oSearchAccount.Gender__pc.contains(System.Label.IC_All_Value)){
                sQueryFilter += ' and Gender__pc = \'' + oSearchAccount.Gender__pc + '\'';  
            }   
            
            // Attached SA
            if(oSearchAccount.OwnerId != null){
                sQueryFilter += ' and OwnerId = \'' + oSearchAccount.OwnerId + '\'';
            }       
            
            // Spend Amount - 1
            if(iSpendAmount != null && iSpendAmount != 0){
                string sSpendNameField = sSpendField + sCurrency + '__pc';
    
                sQueryFilter += ' and ' + sSpendNameField + (sOperator=='less or equal'?'<=':'>=') + iSpendAmount;
            }
            
            // Spend Amount - 2
            if(iSpendAmount2 != null && iSpendAmount2 != 0){
                string sSpendNameField2 = sSpendField2 + sCurrency + '__pc';
    
                sQueryFilter += ' and ' + sSpendNameField2 + (sOperator2=='less or equal'?'<=':'>=') + iSpendAmount2;
            }           
            
            // ---------------------------------
            // PURCHASED PRODUCT filters
            // ---------------------------------
            
            if(oSearchPurchasedProduct.TECH_PurchasedDateFrom__c != null
                || oSearchPurchasedProduct.TECH_PurchasedDateTo__c != null
                || !lProductCategory.isEmpty()
                || (oSearchPurchasedProduct.SKU__c != null && oSearchPurchasedProduct.SKU__c != '')){
                    sQueryFilter += ' and Id in (Select Client__c from PPR_PurchProduct__c where Client__c != null';
                    
                    // Purchased date
                    if(oSearchPurchasedProduct.TECH_PurchasedDateFrom__c != null){ 
                        DateTime dPurchasedDateFrom = DateTime.newInstance(oSearchPurchasedProduct.TECH_PurchasedDateFrom__c, Time.newInstance(0, 0, 0, 0));
                        sQueryFilter += ' and PurchasedDate__c >= ' + dPurchasedDateFrom.format('yyyy-MM-dd');  
                    }
                    if(oSearchPurchasedProduct.TECH_PurchasedDateTo__c != null){
                        DateTime dPurchasedDateTo = DateTime.newInstance(oSearchPurchasedProduct.TECH_PurchasedDateTo__c, Time.newInstance(0, 0, 0, 0));
                        sQueryFilter += ' and PurchasedDate__c <= ' + dPurchasedDateTo.format('yyyy-MM-dd');    
                    }
                     
                    // Product Category
                    //hch   
                    tempSetVal.clear();
                    tempSetVal.addAll(lProductCategory);
                    if(!lProductCategory.isEmpty()){                    
                                sQueryFilter += ' and ProductLine__c in ('; 
                                sQueryFilter += inFilter(lProductCategory);
                                sQueryFilter += ')';        
                    }
                    // SKU
                    if(oSearchPurchasedProduct.SKU__c != null && oSearchPurchasedProduct.SKU__c != ''){
                        system.debug('### CVER SKU:' + oSearchPurchasedProduct.SKU__c);
                        
                        list<String> lSKU = new List<String>();
                        lSKU = oSearchPurchasedProduct.SKU__c.deleteWhitespace().split(',',-1);
                        
                        sQueryFilter += ' and SKU__c in ('; 
                        sQueryFilter += inFilter(lSKU);
                        sQueryFilter += ')';
                    }
                    
                    //Product gender - MTO      
                    if(oSearchPurchasedProduct.ProductGender__c != null && !oSearchPurchasedProduct.ProductGender__c.contains(System.Label.IC_All_Value)){
                        sQueryFilter += 'and ProductGender__c = \'' + oSearchPurchasedProduct.ProductGender__c + '\'';
                    }
                    sQueryFilter += ')';        
                }   
                
            
            
                    
                // --------------------------------------------------------------
            // TASK & EVENT filters - Doesn't support semi join inner selects
            // --------------------------------------------------------------
            // TO BE COMPLETED
            Set<String> accountIds= new set<String>();
            if ((oSearchAccount.TECH_OutreachFrom__pc != null || oSearchAccount.TECH_OutreachTo__pc != null) && OutreachScope.size() != 0) {
                List<String> RTList=new List<String>();
                orQueryString='SELECT AccountId FROM Task WHERE';       
                
                        
                //Outreach Scope : Store / Corporate
                tempSetVal.clear();
                tempSetVal.addAll(OutreachScope);
                if(tempSetVal.contains(System.Label.IC_Last_Store_Outreach)) {RTList.add(IC_UTILS.getTaskRT());}
                if(tempSetVal.contains(System.Label.IC_Last_Corporate_Outreach)) {RTList.add(IC_UTILS.getTaskDreamRT());}
                orQueryString += ' RecordTypeId IN (' + inFilter(RTList) + ') ';
    
                //Outreach Date Range
                if(oSearchAccount.TECH_OutreachFrom__pc != null){ 
                    DateTime dOutreachDateFrom = DateTime.newInstance(oSearchAccount.TECH_OutreachFrom__pc, Time.newInstance(0, 0, 0, 0));
                    orQueryString += ' AND activitydate >= ' + dOutreachDateFrom.format('yyyy-MM-dd');  
                }
    
                if(oSearchAccount.TECH_OutreachTo__pc != null){ 
                    DateTime dOutreachDateTo = DateTime.newInstance(oSearchAccount.TECH_OutreachTo__pc, Time.newInstance(0, 0, 0, 0));
                    orQueryString += ' AND activitydate <= ' + dOutreachDateTo.format('yyyy-MM-dd');    
                }
    
                // Action Type
                tempSetVal.clear();
                tempSetVal.addAll(lActionType);
                if(!lActionType.isEmpty() && !tempSetVal.contains(System.Label.IC_All_Value)){
                    orQueryString += ' AND actionType__c IN ('+inFilter(lActionType)+')';
                }
                orQueryString+=' AND AccountId != null GROUP BY accountId';
                
                list<SObject> searchOutreach= Database.query(orQueryString);
                
                system.debug('### XD OutReach Select   : ' + orQueryString);
                accountIds=IC_Utils.getIdList(searchOutreach,'AccountId');
                sQueryFilter+=' and Id IN :accountIds' ;
                
            }
            
            // Add filter condition to the query
            sQueryString += sQueryFilter;
    
            // Limit the number of rows returned
            integer iNbQueryRows = NBROWS+1;
            sQueryString += ' order by ' + SortField + ' asc limit ' + iNbQueryRows;
            system.debug('### CVER sQueryString:' + sQueryString);
            
            // Execute the query
            list<SObject> lSearchResult = Database.query(sQueryString);
            
            if(lSearchResult.size() > NBROWS){
                // Number of rows returned greater than the max number of rows defined
                bRowReturned = true;
                bMaxRowsReached = true;
            }
            else{
                if(lSearchResult.size() == 0){
                    // No row returned
                    bRowReturned = false;
                    ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.IC_CADreamIdNoResultFound));
                }
                else{
                    //bRowReturned = true;
                    
                    // Displays row returned
                    for (SObject oObject:lSearchResult){
                        Account oAccount = (Account) oObject;
                        oAccount.TECH_Selected__pc = true;
                        lClientsList.add((Account) oAccount);
                    }
                    // KCA: Correction Insufficient privilege error message
                    // Remove accounts attached to technical user
                    if (lClientsList != null && lClientsList.size() > 0) {
                        lClientsList = checkIfAttachedToTechnicalUser(lClientsList);
                    }
                    
                    // Remove accounts not in User scope
                    if (!IC_UTILS.isSystemAdmin()) {
                        if (lClientsList != null && lClientsList.size() > 0) {
                            lClientsList = checkUserRole (lClientsList);
                        }                   
                    }
                    if (lClientsList.size() == 0) {
                        // No row returned
                        bRowReturned = false;
                        ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.IC_CADreamIdNoResultFound));                    
                    } else {
                        bRowReturned = true;
                        lClientsListPagination = new IC_TargetedClientsLists_Pagination(lClientsList, iPagesize);
                    }
                }
            }             
    }
    
    // ---------------------------------
    // saveClientsLists method
    // ---------------------------------
    public PageReference saveClientsLists(){
        list<Account> lSelectedClientsList = new list<Account>();
        set<Id> lOwnerId = new set<Id>();
        list<Id> lUniqueOwnerId = new list<Id>();
        list<Id> lUniqueOwnerIdFinal = new list<Id>();
        map<ID, String> lUniqueOwnerIdDoublon = new map<Id, String>(); 
        map<ID, ID> maMap = new map<Id, Id>();          
        list<CLI_CliList__c> lClientsListsToInsert = new list<CLI_CliList__c>();
        list<CLM_CliListMember__c> lClientsListsMembersToInsert = new list<CLM_CliListMember__c>();
        list<CLI_CliList__c> allCltList = new list<CLI_CliList__c>();
        string sSAName = '';
        
        try{    
            // Construct a list of selected Clients 
            for(Account oAccount:lClientsList){
                if(oAccount.TECH_Selected__pc){
                    lSelectedClientsList.add(oAccount);
                    if(lOwnerId.add(oAccount.OwnerId)){
                        lUniqueOwnerId.add(oAccount.OwnerId);
                        sSAName += '<br/>• ' + oAccount.Owner.Name;
                    }
                }
            }
            
            system.debug('### CVER lSelectedClientsList.size():' + lSelectedClientsList.size());
            
            // Check required information - At least one Client has to be selected
            if(lSelectedClientsList.isEmpty()){
                ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.IC_Client_List_Required));
                return null;       
            }

            // Check required information - Client list name is required
            if(oClientsList.Name == null || oClientsList.Name == ''){
                ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.IC_Client_List_Name_Required));
                return null;
            }
            
            //Check that the Client list do not exist for the owners
            //Client List for all Users
            allCltList = [SELECT id, name, OwnerId FROM CLI_CliList__c WHERE OwnerId IN :lUniqueOwnerId];
 			Set <String> ownerAndList = new Set <String>();
 	
			for (CLI_CliList__c c : allCltList) {
 				ownerAndList.add (c.ownerid + c.name);	
 			}
 			 	
 			for (Id id : lUniqueOwnerId) {
 				if (!ownerAndList.contains(id+oClientsList.Name)) {
 					lUniqueOwnerIdFinal.add(id);
 				}
 			}
 			system.debug('### lUniqueOwnerIdFinal.size():' + lUniqueOwnerIdFinal.size());
 			system.debug('### lUniqueOwnerIdFinal :' + lUniqueOwnerIdFinal);
 			
 			for (Id ownerId : lUniqueOwnerId) {
 				if (ownerAndList.contains(ownerId+oClientsList.Name)) {
 					lUniqueOwnerIdDoublon.put(ownerId, oClientsList.Name);
 				}
 			}
 			system.debug('### lUniqueOwnerIdDoublon.size():' + lUniqueOwnerIdDoublon.size());
 			system.debug('### lUniqueOwnerIdDoublon :' + lUniqueOwnerIdDoublon);
 			
			for (CLI_CliList__c c : allCltList) {
				String maVar = string.valueof (c.ownerid) + string.valueof(c.name);
				String maVar2 = string.valueof (c.ownerid) + oClientsList.Name;
				system.debug('### maVar :' + maVar);
				system.debug('### maVar2 :' + maVar2);
				if(maVar.equals(maVar2)) {
					system.debug('### c.ownerid+oClientsList.Name:' + c.ownerid+oClientsList.Name);
					maMap.put(c.ownerid, c.id);
				}
				/*
				if(ownerAndList.contains(c.ownerid+oClientsList.Name)) {
					maMap.put(c.ownerid, c.id);
				} */
 //				ownerAndList.add (c.ownerid + c.name);
 //				maMap.put(c.id, c.ownerid);
 				
 			} 			
 			system.debug('### maMap.size():' + maMap.size());
 			system.debug('### maMap :' + maMap);
            
            //Creating Client List
            if(!lUniqueOwnerIdFinal.isEmpty()){
                for(Id sOwnerId:lUniqueOwnerIdFinal){ 
                    lClientsListsToInsert.add(new CLI_CliList__c(Name = oClientsList.Name,
                        Description__c = oClientsList.Description__c,
                        Active__c = true,
                        OwnerId = sOwnerId,
                        TECH_CreatedFromTCLScreen__c = true 
                        )
                    );
                }
                
                if(!lClientsListsToInsert.isEmpty()){
                    // Create clients lists assigned to the specific SA
                    Database.Saveresult[] lSR = Database.insert(lClientsListsToInsert, false);
                    
                    // Check Results
                    for (integer i=0;i<lSR.size();i++){
                        Database.SaveResult oSR = lSR[i];
        
                        if(oSR.isSuccess()){
                            for(Account oAccount:lSelectedClientsList){
                                if(oAccount.OwnerId == lClientsListsToInsert[i].OwnerId){
                                    lClientsListsMembersToInsert.add(new CLM_CliListMember__c(ClientList__c = oSR.getId(), Client__c = oAccount.PersonContactId));
                                }
                            }
                        }
                    }
                    
                    if(!lClientsListsMembersToInsert.isEmpty()){
                        // Create clients lists members
                        insert lClientsListsMembersToInsert;
                    }                   
                    
                    ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.IC_Client_List_Created.replaceAll('###CLNAME###', oClientsList.Name).replaceAll('###SANAME###', sSAName))); 
                }
            }
            //ICI
            if(!lUniqueOwnerIdDoublon.isEmpty()) {
            	lClientsListsMembersToInsert.clear();
            	system.debug('### DANS IF :');
                for(Account oAccount:lSelectedClientsList){
                    if(lUniqueOwnerIdDoublon.containsKey(oAccount.OwnerId)){
                    	system.debug('### DANS SECOND IF');
                        lClientsListsMembersToInsert.add(new CLM_CliListMember__c(ClientList__c = maMap.get(oAccount.OwnerId), Client__c = oAccount.PersonContactId));
                    }
                }  
	            if(!lClientsListsMembersToInsert.isEmpty()){
	            	system.debug('### DANS SECOND INSERT');
	            	system.debug('### lClientsListsMembersToInsert' + lClientsListsMembersToInsert);
	                // Create clients lists members
	                insert lClientsListsMembersToInsert;
	                ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.IC_Client_List_Created.replaceAll('###CLNAME###', oClientsList.Name).replaceAll('###SANAME###', sSAName))); 
	            }                           	
            }
            
            return null;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }       
    }    
    
    // ------------------------------------------------------
    // inFilter method
    // Return a string of multi values for a "IN" soql filter
    // ------------------------------------------------------
    private string inFilter(list<String> lValues){
        string sValue = '';
        for(integer i=0; i<lValues.size(); i++){
            sValue += '\'' + lValues[i] + '\'';
            
            if(i != lValues.size()-1)
                sValue += ',';
        }
        return sValue;
    }    
    
    // -------------------------
    // multiPicklist method
    // Generate a multi Picklist
    // -------------------------
    private list<SelectOption> multiPicklist(Schema.DescribeFieldResult oFieldResult, boolean addAll){
        list<SelectOption> lOptions = new list<SelectOption>();
        list<Schema.PicklistEntry> lPLE = oFieldResult.getPicklistValues();
        if (addAll) {
            lOptions.add(new SelectOption(System.Label.IC_All_Value, System.Label.IC_All));    
        }
        for(Schema.PicklistEntry oPLE:lPLE){
            lOptions.add(new SelectOption(oPLE.getValue(), oPLE.getLabel()));
        }       
        return lOptions;        
    }
    
     private list<SelectOption> multiPicklist(Schema.DescribeFieldResult oFieldResult){
        return multiPicklist(oFieldResult, false);
     }
    
    // -------------------------------
    // PAGINATION FUNCTIONALITY
    // -------------------------------    
    // members
    public IC_TargetedClientsLists_Pagination lClientsListPagination{get;set;}
    public boolean bPaginationUpd{get;set;}
    public integer iCurrentPage{get;set;}
    public boolean iSelectAll{get;set;}
    public static integer iPagesize{get{return (ICONSettings__c.getInstance().Targeted_Clients_Lists_PaginationSize__c==null?1000:integer.valueof(ICONSettings__c.getInstance().Targeted_Clients_Lists_PaginationSize__c));}}         
    
    
    // ---------------------------------
    // checkAll() method
    // ---------------------------------
    public PageReference checkAll(){
        lClientsListPagination.processCheckChange(lClientsList);
        iSelectAll = lClientsListPagination.iSelectAll;
        return null; 
    }  
    // ----------------------------
    // nextList() Pagination method
    // ----------------------------
    public PageReference nextList(){      
        bPaginationUpd = true;
        lClientsListPagination.getNext(iCurrentPage);
        iCurrentPage = lClientsListPagination.iPageNumber;
        
        return null; 
    }  
    
    // --------------------------------
    // previousList() Pagination method
    // --------------------------------
    public PageReference previousList(){         
        bPaginationUpd = true;
      
        lClientsListPagination.getPrevious(iCurrentPage);
        iCurrentPage = lClientsListPagination.iPageNumber;
        return null;
    } 

    // --------------------------------
    // firstList() Pagination method
    // --------------------------------    
    public PageReference firstList(){      
        bPaginationUpd = true;
        
        lClientsListPagination.getFirst();
        bPaginationUpd = false;
        iCurrentPage = lClientsListPagination.iPageNumber;
        return null;
    }

    // --------------------------------
    // lastList() Pagination method
    // --------------------------------        
    public PageReference lastList(){      
        bPaginationUpd = true;
              
        lClientsListPagination.getLast();
        bPaginationUpd = false;
        iCurrentPage = lClientsListPagination.iPageNumber;
        return null;
    }
    
    // -------------------------------
    // SORT FUNCTIONALITY
    // -------------------------------  
    
    // members
    public string SortField {get;set;}
    public string PreviousSortField {get;set;}
    public IC_TargetedClientsLists_Sort.SortDirection SortOrder {get;set;}
         
    // --------------------------------
    // doSort() Sort method
    // --------------------------------            
    public PageReference doSort(){
        list<IC_TargetedClientsLists_Sort> lClientsListSorted = new list<IC_TargetedClientsLists_Sort>();
        map<id, Account> mapClientsList = new map<id, Account>();
        list<Account> lTempClientsList = new list<Account>();
        
        for(Account oAccount:lClientsList){
            lClientsListSorted.add(new IC_TargetedClientsLists_Sort(oAccount.id, oAccount.Name, oAccount.Segmentation__pc, oAccount.HistoricalSpendUSD__pc, oAccount.LastTrans__pc, oAccount.Owner.LastName));
            mapClientsList.put(oAccount.id, oAccount);
        }
        
        SortOrder = IC_TargetedClientsLists_Sort.SortDirection.ASCENDING;
        
        // Check on which column to sort
        if(PreviousSortField == SortField){
            SortOrder = IC_TargetedClientsLists_Sort.SortDirection.DESCENDING;
            PreviousSortField = null;
        }
        else PreviousSortField = SortField;
        
        IC_TargetedClientsLists_Sort.SORT_DIR = SortOrder;
        
        if(SortField == 'Name')
            IC_TargetedClientsLists_Sort.SORT_FIELD = IC_TargetedClientsLists_Sort.SortField.Name;
        else if(SortField == 'Segmentation')
            IC_TargetedClientsLists_Sort.SORT_FIELD = IC_TargetedClientsLists_Sort.SortField.Segmentation;
        else if(SortField == 'HistoricalSpendUSD')
            IC_TargetedClientsLists_Sort.SORT_FIELD = IC_TargetedClientsLists_Sort.SortField.HistoricalSpendUSD;
        else if(SortField == 'LastTrans')
            IC_TargetedClientsLists_Sort.SORT_FIELD = IC_TargetedClientsLists_Sort.SortField.LastTrans;
        else if(SortField == 'OwnerName')
            IC_TargetedClientsLists_Sort.SORT_FIELD = IC_TargetedClientsLists_Sort.SortField.OwnerName;         
        else
            IC_TargetedClientsLists_Sort.SORT_FIELD = IC_TargetedClientsLists_Sort.SortField.Name; // this shouldn't be the case

        // Sort the list
        lClientsListSorted.sort();
        
        for(IC_TargetedClientsLists_Sort oTCLS:lClientsListSorted){
            lTempClientsList.add(mapClientsList.get(oTCLS.Id));
        }
        
        lClientsListPagination = new IC_TargetedClientsLists_Pagination(lTempClientsList, iPagesize);
        
        return null;
    }
    
    // --------------------------------
    // Remove a client who is attached to a technical user    
    // --------------------------------  
    private List<Account> checkIfAttachedToTechnicalUser (List<Account> lClientsList) {
        
        System.debug('### checkIfAttachedToTechnicalUser');
        System.debug('### lClientsList ' + lClientsList.size());
        
        List<ID> ownerId = new List <ID>();
        Set<ID> noTechnicalUser = new Set <ID>();
        List<Account> lClients = new List <Account>();
        
        for (Account ac : lClientsList) {
            ownerId.add(ac.ownerId);
        }       
        List <User> users = [Select Id, IsTechnicalUser__c from User WHERE id IN :ownerId];
        for (user u : users) {
            if(!u.IsTechnicalUser__c) {
                noTechnicalUser.add(u.id);
            }
        }
        for (Account ac : lClientsList) {
            if (noTechnicalUser.contains(ac.ownerid)) {
                lClients.add(ac);
            }
        }       
        return lClients;
    }
       
    // --------------------------------
    // Remove a user who is not in the user hierarchy
    // --------------------------------   
    private List<Account> checkUserStoreHierarchy (List<Account> lClientsList) {
        
        
        if (userHierarchyLvl0 == null || userHierarchyLvl0.equals('')) {
            return lClientsList;
        }
        
        List<Account> finalCLient = new List <Account>();
        List<ID> clientID = new List <ID>();
        Map<ID, String> mapCltStore = new Map<ID, String>();
        Map<String, String> mapZone = new Map<String, String>();
        Map<ID, Account> mapClient = new Map<ID, Account>();
            
        for (Account ac : lClientsList) {
            System.debug('### mapCltStore');
            mapCltStore.put(ac.id, ac.AttachedStore__pc);
            mapClient.put(ac.id, ac);
        }
        
        List<Store__c> cltStore = [Select Id, MANAGEMENT_ZONE_LEVEL__c, Name from Store__c where Name IN :mapCltStore.values()];
        
        for(Store__c c : cltStore) {
            System.debug('### mapZone');
            mapZone.put(c.Name, c.MANAGEMENT_ZONE_LEVEL__c);
        }
        
        System.debug('### userHierarchyLvl0  '+  userHierarchyLvl0);
        System.debug('### TT mapZone ' + mapZone);
        System.debug('### TT mapCltStore ' + mapCltStore);
        for (ID i : mapCltStore.keySet()) {
            System.debug('### For ID');         
            if(mapZone.containsKey(mapCltStore.get(i)) && mapZone.get(mapCltStore.get(i)).equals(userHierarchyLvl0)) {
                System.debug('### IF For ID');
                finalCLient.add (mapClient.get(i));
                System.debug('### finalCLient ' + finalCLient.size());
            }
        }
        return finalCLient;
    }  
    
    // --------------------------------
    // Remove a user who is not in the user sub role
    // --------------------------------   
    
    	private List<Account> checkUserRole (List<Account> lClientsList) {
		
		System.debug('### checkUserRole');
		System.debug('### lClientsList ' + lClientsList.size());

		List<Account> finalCLient = new List <Account>();
		List<ID> clientID = new List <ID>();
		Map<ID, ID> mapPrefCA = new Map<ID, ID>();
				
		for (Account ac : lClientsList) {
			mapPrefCA.put(ac.id, ac.ownerId);
		}
		//Role Id de user courant
		List<User> myUserRole = [Select Id, UserRoleId from User where Id = :UserInfo.getUserId()];		
		if (myUserRole.get(0).UserRoleId == null){
			 return lClientsList;
		}
		Set<ID> idUser = new Set <ID>();
		idUser.add(myUserRole.get(0).UserRoleId);
		// Role Id dans le scope du user
		Set<ID> userOK = new Set <ID>();
		userOK.add(myUserRole.get(0).UserRoleId);
		Set<ID> subRoleUser = IC_Utils.getAllSubRoleIds(idUser);
		if (subRoleUser != null & subRoleUser.size() > 0) {
			userOK.addAll(subRoleUser);
		}
		
		// Liste des Prefered CA
		List<User> pCA = [Select Id, UserRoleId from User where Id IN :mapPrefCA.values()];
		
		//Tri sur les Role dans le scope du user
		Set<Id> pCaFinal = new Set <Id>();
		for (User u : pCA) {
			if(userOK.contains(u.UserRoleId)){
				pCaFinal.add(u.id);
			}
		}
		
		
		for (Account ac : lClientsList) {
			if(pCaFinal.contains(ac.ownerid)) {
				finalCLient.add(ac);
			}
		}
		System.debug('### TT finalCLient ' + finalCLient);		
		return finalCLient;
	} 
      
}