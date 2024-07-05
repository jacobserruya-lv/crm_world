/**---------------------------------------------------------------------------------------------------------------
    Author/Company: Balink
    ----------------
    
    Description:
    ------------
    Search clients by segmentation/gender/birthday month/contact settings/last outreach/attached Store
    Create client lists for owners of clients returned by the filter.
    To improve performance, results are limited to 9000.

    History
    --------------
    July 2016 / Created by Balink


---------------------------------------------------------------------------------------------------------------*/
public without sharing class IC_TargetedClientsLists_VFCx_New {
  public static Set<String> dreamIdsSet ;
  public static Set<String> storeCodes ;
  public static Set<String> idSet;

  

  public class ProductFilter{
      public String purchaseDateFrom {get;set;}
      public String purchaseDateTo {get;set;}
      public List<String> Categories {get;set;}
      public List<String> ProductGenders {get;set;}
      public List<String> Materials {get;set;}
      public List<String> uploadedSKUIds {get;set;}
  }
  public class InterestFilter{
      public List<String> Categories {get;set;}
  }
  /*=================================================================================================================*/
public class ClientFilter {
  public String lastCorporateOutreachFrom {get;set;}
  public String lastCorporateOutreachTo {get;set;}
  public String lastStoreOutreachFrom {get;set;}
  public String lastStoreOutreachTo {get;set;}
  public List<String> segmentations {get;set;}
  public Boolean PersonDoNotCall {get;set;}
  public Boolean PersonHasOptedOutOfEmail {get;set;}
  public Boolean DoNotSMS {get;set;}
  public Boolean DoNotContactbyPost {get;set;}
  public List<String> selectedCas {get;set;}
  //public String preferredCA {get;set;}
  public List<String> Gender {get;set;}
  public List<String> Indic10K {get;set;}
  public List<String> birthdateMonths {get;set;}
  //public String birthdateMonth {get;set;}
}
  /*=================================================================================================================*/
   public static Boolean nullOrEmpty(Object o) {
      if( (null == o) ||
          ((o instanceof String) && (String.isEmpty((String)o))) ||
          ((o instanceof List<object>) && (0 == ((List<object>)o).size())) ||
          ((o instanceof Map<String,object>) && (((Map<String, Object>)o).isEmpty()))){
          system.debug('function - nullOrEmpty: first if - null ir empty');
          return true;
      }else if(o instanceof Map<String,object>){
          Map<String,object> mapObject = (Map<String,object>)o;
          for(String key : mapObject.keySet()) {
                  if(key != null && mapObject != null){
                     
                  }
              }    
      }
      else if(((o instanceof List<object>) && !(0 == ((List<object>)o).size()))){
          system.debug('function - nullOrEmpty: else if - list object');
          List<object> listObject = (List<object>)(o);
          for(object item : listObject){
              if(!nullOrEmpty(item)){
                  return false;
              }
          }
      }
      else{
          system.debug('GoodLife else');
          return false;
      }
      system.debug('GoodLife eof');
      return true;
  }
  /*=================================================================================================================*/
  public static Date StringToDate(String stringDate){
      system.debug('CHECKDATE'+Date.valueOf(stringDate));
      return Date.valueOf(stringDate);
  }
  /*=================================================================================================================*/
public class HierarchyLevel {
  Map<String,Object> children {get;set;}
  public String label {get;set;}
  public String value {get;set;}
}
  /*=================================================================================================================*/
  public class TransactionField{
      string fromValue{get;set;}
      string toValue{get;set;}
      public TransactionField(string fromValue,string toValue, string fieldValue){
          fromValue = fromValue;
          toValue = toValue;
          fieldValue = fieldValue;
      }
  }
  /*=================================================================================================================*/
  public class TransactionFilter{
      public String FirstTransactionDateFrom {get;set;}
      public String FirstTransactionDateTo {get;set;}
      public String LastTransactionDateFrom {get;set;}
      public String LastTransactionDateTo {get;set;}
      public Map<String, TransactionField> spent {get;set;}
      public String userCurrency {get;set;}
      public String period {get;set;}
  }
  /*=================================================================================================================*/
public class AcountResponse {
  public String ownerId;
  public String ownerName;
  public String PersonContactId;


  public AcountResponse(){}
  public AcountResponse(String pcId,String oId, String oName){
    ownerId = oId;
    ownerName = oName;
    PersonContactId = pcId;
  }
}
  /*=================================================================================================================*/
public class ClientListResponse {
  public Integer numberOfListsCreated;
  public Integer numberOfListsUpdated;
  public Integer numberOfMembersCreated;
  public Integer numberOfMembersCreatedforExistingCL;
  public Integer numberOfListFailures;
  public Integer numberOfListUpdateFailures;
  public Integer numberOfMembersFailures;
  public String errorMessage;
}
  /*=================================================================================================================*/
@RemoteAction
  public static List<User> findUserLike(String text) {
      text = '%' + text + '%';
      return [SELECT Id, Name FROM User WHERE name LIKE :text and isActive = true  limit 15  ];
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static List<User> findAdvisorLike(String text) {
      text = '%' + text + '%';
      return [SELECT Id, Name FROM User WHERE name LIKE :text and isActive = true  limit 15  ];
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static User getCurrentUser() {
      return [SELECT Id, Name, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c,
                      MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c, Country__c
                      FROM User
                      WHERE Id = :UserInfo.getUserId() ];
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static List<Account> targetClientSearch(String lastNameInTable,Map<String,HierarchyLevel> sFilter, ClientFilter cFilter, ProductFilter pFilter, InterestFilter iFilter, List<String> dreamIds, TransactionFilter transactionParams){
     String query = 'select Id, Name, Segmentation__pc, HistoricalSpendUSD__pc, LastTrans__pc, Owner.Name, Owner.LastName,DREAMId__c, Last36MSpendUSD__pc, Last36MSpendEUR__pc, Last36MSpendYEN__pc, Last36MSpendYUAN__pc from Account';
      List<Account> results = PerformClientSearch(query, lastNameInTable, sFilter, cFilter,pFilter,iFilter,dreamIds,transactionParams, false);
      return results;
  }
  /*=================================================================================================================*/
@RemoteAction
public static List<Account> transferClientSearch(String lastNameInTable,Map<String,HierarchyLevel> sFilter, ClientFilter cFilter, ProductFilter pFilter,InterestFilter iFilter, List<String> dreamIds, TransactionFilter transactionParams){
     String query = 'select Id, Name, Segmentation__pc, HistoricalSpendUSD__pc, LastTrans__pc, Owner.Name, Owner.LastName,DREAMId__c, Gender__pc, DreamSA__pc, Last36MSpendUSD__pc, Last36MSpendEUR__pc, Last36MSpendYEN__pc, Last36MSpendYUAN__pc from Account';
      List<Account> results = PerformClientSearch(query, lastNameInTable, sFilter, cFilter,pFilter,iFilter,dreamIds,transactionParams, true);
  return results;
}
  /*=================================================================================================================*/
  @RemoteAction
  public static Object AassignClients(List<String> clientIds, String advisorId){
      List<Account> clients = new List<Account>();
      List<CLM_CliListMember__c> cmtoInsert = new List<CLM_CliListMember__c>(); 
      for(String clientId : clientIds){
          clients.add(new Account(
              Id = clientId,
              ownerId = advisorId,
              TECH_TEMP_ReassignedBYTCL__c = true
              ));
      }
      update clients;
      List<Account> clientsUpdated=[Select Id, PersonContactId From Account Where Id IN : clients];
      CLI_CliList__c clList= new CLI_CliList__c(Name=clientIds.size()+' clients reattached to you',Active__c=true,ownerId = advisorId,TECH_IsReassignedClients__c=true);
      insert clList;
      for(Account acc :clientsUpdated){
          CLM_CliListMember__c cm =new CLM_CliListMember__c(ClientList__c=clList.Id,Client__c=acc.PersonContactId);
          cmtoInsert.add(cm);
      }
      if(cmtoInsert.size()>0){
          insert cmtoInsert;
      }

   return 0;
  }
  /*=================================================================================================================*/
  public static List<Account> PerformClientSearch(String query, String lastNameInTable, Map<String,HierarchyLevel> sFilter, ClientFilter cFilter, ProductFilter pFilter,InterestFilter iFilter, List<String> dreamIds, TransactionFilter transactionParams, Boolean includeTechnical){
      String additionalFilter = '';
      Set<String> temp = new Set<String>();
      
      if(!String.isEmpty(lastNameInTable))
          additionalFilter = ' and Id > \'' + lastNameInTable + '\' ';
      query += buildFilter(cFilter,sFilter,iFilter,additionalFilter,dreamIds,transactionParams,pFilter, includeTechnical);
      /* Limit the number of rows returned*/
      query += ' order by Id asc ';
      query += ' limit 300';
      system.debug('### CVER sQueryString:' + query);
      /* Execute the query*/
      temp = dreamIdsSet;
      return Database.query(query);
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static List<String> getPickListVal(String objectName, String fieldName,String excludedValue){
      return IC_Utils.getPickListVal(objectName, fieldName, excludedValue);
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static List<AcountResponse> launchSearchIds(Map<String,HierarchyLevel> sFilter, ClientFilter cFilter,
                                                   ProductFilter pFilter,InterestFilter iFilter, List<String> dreamIds,
                                                    TransactionFilter transactionParams, Boolean includeTechnical,
                                                     String lastCreatedDate){
  if(transactionParams == null)
          transactionParams = new TransactionFilter();
      

      
      String additionalFilter = '';
      if(!String.isEmpty(lastCreatedDate)){
          additionalFilter = ' and PersonContactId > \'' + lastCreatedDate + '\' ';
      }
      
      
      
      Set<String> temp = new Set<String>();
      String query = 'select PersonContactId, CreatedDate, Name, ownerId, owner.Name from Account ';
      query += buildFilter(cFilter,sFilter,iFilter,'',dreamIds, transactionParams,pFilter,includeTechnical);
      query += additionalFilter;
      query += ' order by PersonContactId asc ';
      /* Limit the number of rows returned */
      query += ' limit 900'; 
      system.debug('### CVER sQueryString:' + query);
      /* Execute the query */
      temp = dreamIdsSet;
      List<Account> accounts = (List<Account>) Database.query(query);
      system.debug('###  dreamIdsSet:' + dreamIdsSet);
      List<AcountResponse> accountIds = new List<AcountResponse>();
      for (Account acc : accounts){
          accountIds.add( new AcountResponse(acc.PersonContactId,acc.ownerId,acc.owner.Name));
      }
      return accountIds;
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static Integer wideSearch(Map<String,HierarchyLevel> sFilter, ClientFilter cFilter, ProductFilter pFilter,InterestFilter iFilter, List<String> dreamIds, TransactionFilter transactionParams, Boolean includeTechnical){
      if(transactionParams == null)
          transactionParams = new TransactionFilter();
      Set<String> temp = new Set<String>();
      String query = 'select COUNT() from Account ';
      query += buildFilter(cFilter,sFilter,iFilter,'',dreamIds, transactionParams,pFilter,includeTechnical);
      /* Limit the number of rows returned */
      system.debug('### CVER sQueryString:' + query);
      /* Execute the query */
      temp = dreamIdsSet;
      Integer accounts = (Integer) Database.countQuery(query);
      //system.debug('###  dreamIdsSet:' + dreamIdsSet);
      //List<AcountResponse> accountIds = new List<AcountResponse>();
      //for (Account acc : accounts){
      //    accountIds.add( new AcountResponse(acc.PersonContactId,acc.ownerId,acc.owner.Name));
      //}
      return accounts;
  }
  /*=================================================================================================================*/
  private static String buildTransactionFilter(TransactionFilter transactionParams){
      system.debug('GoodLife: transactionParams '+transactionParams);
      String query = '';
      if (!nullOrEmpty(transactionParams)) {
          if(transactionParams.FirstTransactionDateFrom != null){
              query += ' AND FirstTrans__pc >= ' +
                           transactionParams.FirstTransactionDateFrom;
          }
          if(transactionParams.FirstTransactionDateTo != null){
              query       += ' AND FirstTrans__pc <= '+
                           transactionParams.FirstTransactionDateTo;
          }
          if(transactionParams.LastTransactionDateFrom != null){
              query += ' And LastTrans__pc >= ' +
                           transactionParams.LastTransactionDateFrom;
          }
          if(transactionParams.LastTransactionDateTo != null){
              query  += ' AND LastTrans__pc <= '+
                           transactionParams.LastTransactionDateTo;
          }
          if(String.isEmpty(transactionParams.UserCurrency)){
              transactionParams.UserCurrency = 'EUR';
          }
          if(transactionParams.spent != null){
              for(String key : transactionParams.spent.keySet()) {
                  if(key != null && transactionParams.spent != null){
                     TransactionField item = transactionParams.spent.get(key);
                     if(item != null){
                          String field = transactionParams.period + key + transactionParams.UserCurrency + '__pc';
                          if(!nullOrEmpty(item.fromValue)){
                              query += ' AND ' + field + ' > ' + item.fromValue;
                          }
                          if(!nullOrEmpty(item.toValue)){
                              query += ' AND ' + field + ' < ' + item.toValue;
                          }
                     }
                  }
              }    
          }
      }
      system.debug('GoodLife transaction query: '+query);
      return query;
  }
  /*=================================================================================================================*/
  private static String buildProductFilter(ProductFilter productObject){
      idSet = new Set<String>();
      

      if(nullOrEmpty(productObject.purchaseDateFrom) &&
          nullOrEmpty(productObject.purchaseDateTo) &&
          nullOrEmpty(productObject.Categories) &&
          nullOrEmpty(productObject.ProductGenders) &&
          nullOrEmpty(productObject.Materials) &&
          nullOrEmpty(productObject.uploadedSKUIds)){
         return '';
      }
      system.debug('function - buildProductFilter: after if: '+productObject);
      
      String productSet = ' SELECT client__c FROM PPR_PurchProduct__c WHERE client__c != null ';
      if (!nullOrEmpty(productObject)) {
          if(productObject.purchaseDateFrom != null){
              productSet += ' AND PurchasedDate__c >= ' +
                           productObject.purchaseDateFrom;
          }
          if(productObject.purchaseDateTo != null){
              productSet       += ' AND PurchasedDate__c <= '+
                           productObject.purchaseDateTo;
          }
          system.debug('function - buildProductFilter: productSet1: '+productSet);
          if( productObject.ProductGenders != null && productObject.ProductGenders.size()> 0){
              //productObject.ProductGenders  = getProductGenders (productObject.ProductGenders);
              productSet += ' AND productgender__c in (' + inFilter(productObject.ProductGenders) + ') ';
          }
          if( productObject.Materials != null && productObject.Materials.size()> 0){
              //productObject.Materials  = getMaterials (productObject.Materials);
              productSet += ' AND   MacroMaterial__c in (' + inFilter(productObject.Materials) + ') ';
          }
          if( productObject.Categories != null && productObject.Categories.size()> 0)
              productSet += ' AND productline__c in (' + inFilter(productObject.Categories) + ') ';
          if( productObject.uploadedSKUIds != null && productObject.uploadedSKUIds.size()> 0)
              productSet += ' AND sku__c in (' + inFilter(productObject.uploadedSKUIds) + ') ';
      } /*
      productSet += ' order by PurchasedDate__c desc limit 1000000';
     
      system.debug('function - buildProductFilter: Productset in buildproductfilter: '+productSet);
      List<PPR_PurchProduct__c> productList = Database.query(productSet);
      system.debug('function - buildProductFilter: Productset in buildproductfilter result: '+productList);
      for(PPR_PurchProduct__c item : productList){
          idSet.add(item.Client__c);
      }
      system.debug('function - buildProductFilter: Productset in buildproductfilter result: '+productList);
      system.debug('function - buildProductFilter: Id set: '+idSet);
      String query = ' AND Id IN:idSet';
      */
      String query = ' AND Id IN ( '+ productSet +')';
      return query;
  }
  /*=================================================================================================================*/
  private static String buildInterestFilter(InterestFilter interestObject){
      idSet = new Set<String>();
      

      if(nullOrEmpty(interestObject.Categories)){
         return '';
      }
      
      String interestSet = ' SELECT client__c FROM Interests__c WHERE client__c != null ';
      if (!nullOrEmpty(interestObject)) {
          
          if( interestObject.Categories != null && interestObject.Categories.size()> 0)
              interestSet += ' AND Categories__c IN (' + inFilter(interestObject.Categories) + ')';
      } 
      String query = ' AND Id IN ( '+ interestSet +') ';
      return query;
  }
  /*=================================================================================================================*/
  public static String addStringsToQuery(String query, List<String> stringList,
                                         String conjunction, String condition, String field){
      system.debug('Shlop query2: '+query);
      if(stringList != null){
          for(String item : stringList){
                 if(item != null && item != ''){
                      query += ' ' + conjunction + ' ' + item + ' ' + condition + ': ' + field;
                 }
              }
          }
          system.debug('Shlop query3: '+query);
      return query;
  }
  /*=================================================================================================================*/
  private static String buildFilter(ClientFilter cFilter, Map<String,HierarchyLevel> sFilter,InterestFilter iFilter,String additionalFilter, 
                                    List<String> dreamIds, TransactionFilter transactionParams, ProductFilter pFilter, Boolean includeTechnical){
    /* Recover accounts that:
       - are person accounts
       - are assigned to an active user
       - are not assigned to the "DREAM" user
       - respect the search criteria defined by the user */
    String filter = ' where IsPersonAccount = true ';
    String userOrOwner = 'AttachedStore__pc';
    if(includeTechnical == false){
      filter += ' AND Owner.IsActive = true';
      userOrOwner = 'owner.DefaultStore__c';
    }
    

      /* STORE FILTER ONLY IF DREAM IDS is empty */
      //if( dreamIds == null || dreamIds.size() == 0 )
      filter += buildStoreFilter(sFilter,userOrOwner);
      filter += buildClientFilter(cFilter, includeTechnical);
      filter += buildProductFilter(pFilter);
      filter += buildInterestFilter(iFilter);
      filter += buildTransactionFilter(transactionParams);
      filter += buildDreamIdsFilter(dreamIds);
      filter += additionalFilter;
    
      system.debug('Id set: '+idSet);
      system.debug('buildFilter: filter: '+ filter);
    return filter;
  }
  /*=================================================================================================================*/
private static String buildDreamIdsFilter(List<String> dreamIds){
    dreamIdsSet = new Set<String>();
    String dreamIdFilter = '';
    for(String dreamId :dreamIds){
      dreamIdsSet.add(dreamId);
    }
  system.debug( '\n\n '+'dreamIdsSet:  ' + dreamIdsSet + '\n\n');
    if(dreamIds != null && dreamIds.size()>0){
        dreamIdFilter += ' and DREAMId__c in :temp ';
        /*
        dreamIdFilter += ' and DREAMId__c in (';
        dreamIdFilter += inFilter(dreamIds);
        dreamIdFilter += ') ';*/
    }
    return dreamIdFilter;
  }
  /*=================================================================================================================*/
private static String buildClientFilter(ClientFilter cFilter, Boolean includeTechnical){
  
      /* ---------------------------------
         ACCOUNT filters
        ---------------------------------*/
  
  
  String clientFilter  = '';
  String sDreamUserId = [select id from User where Name = 'DREAM' limit 1].Id;
  /* Clients assigned to DREAM are not recovered*/
      if(sDreamUserId != null)
          clientFilter += ' and OwnerId != \'' + sDreamUserId + '\' ';

      /* MTO Clients assigned to technical users are not recovered*/
      if(!includeTechnical)
        clientFilter += ' and isDREAM__c = false ';

      /* Segmentation*/
      if(cFilter.Segmentations != null && cFilter.Segmentations.size() > 0 ){
          clientFilter += ' and Segmentation__pc in (';
          clientFilter += inFilter(cFilter.Segmentations);
          clientFilter += ')';
      }
       /* Attached SA*/
      if( cFilter.selectedCas != null && cFilter.selectedCas.size() > 0 ){
          clientFilter += ' and OwnerId in (';
          clientFilter += inFilter(cFilter.selectedCas);
          clientFilter += ')';
      }

      /* Do Not Call*/
      if(cFilter.PersonDoNotCall != null){
          clientFilter += ' and PersonDoNotCall = ' + cFilter.PersonDoNotCall ;
      }
      /* Do Not Send Email */
  if(cFilter.PersonHasOptedOutOfEmail != null ){
          clientFilter += ' and PersonHasOptedOutOfEmail = ' + cFilter.PersonHasOptedOutOfEmail ;
          if(cFilter.PersonHasOptedOutOfEmail == false) 
            clientFilter+= ' and PersonEmail != null ';
      }
      /* Do Not SMS */
      if(cFilter.DoNotSMS != null ){
          clientFilter += ' and DoNotSMS__pc = ' + cFilter.DoNotSMS ;
      }
      /* Do Not Contact by Post */
      if(cFilter.DoNotContactbyPost != null ){
          clientFilter += ' and DoNotContactbyPost__pc = ' + cFilter.DoNotContactbyPost ;
      }
      /* Gender */
      if(cFilter.Gender != null  && cFilter.Gender.size() > 0){
          clientFilter += ' and Gender__pc in (';
          clientFilter += inFilter(cFilter.Gender);
          clientFilter += ')';
      }
      /* Indic 10K */
      if(cFilter.Indic10K != null  && cFilter.Indic10K.size() > 0){
          Boolean isRank = indexOf(cFilter.Indic10K,'10K This Year') > -1;
          if(isRank){
              String rank10K = cFilter.Indic10K.remove(indexOf(cFilter.Indic10K,'10K This Year'));
              clientFilter += ' and ( indic_10K_rank__c = \'10k YTM\' ';
          }
          if(cFilter.Indic10K.size()>0){
              clientFilter += isRank ?' OR': ' and';
          clientFilter += ' Ind_10K__c in (';
          clientFilter += inFilter(cFilter.Indic10K);
          clientFilter += ')';
          }
          clientFilter += isRank ?')': '';
      }
      /* Birthdate Month */
      if( cFilter.birthdateMonths != null && cFilter.birthdateMonths.size() > 0 ){
          clientFilter += ' and BirthdateMonth__pc  in (' + inFilter(cFilter.birthdateMonths) + ' ) ';
      }
      
      ///* Old Birthdate Month */
      //if( !String.isEmpty(cFilter.birthdateMonth) ){
      //    clientFilter += ' and BirthdateMonth__pc = \'' + cFilter.birthdateMonth + '\'';
      //}
       
      
      if(!String.isEmpty(cFilter.lastStoreOutreachFrom)){
        clientFilter += ' and LastContactDate__pc >= ' + cFilter.lastStoreOutreachFrom ;
      }
      
      if(!String.isEmpty(cFilter.lastStoreOutreachTo)){
        clientFilter += ' and LastContactDate__pc <= ' + cFilter.lastStoreOutreachTo ;
      }
      
      if(!String.isEmpty(cFilter.lastCorporateOutreachFrom)){
        clientFilter += ' and LastCorporateOutreach__c >= ' + cFilter.lastCorporateOutreachFrom ;
      }
      
      if(!String.isEmpty(cFilter.lastCorporateOutreachTo)){
        clientFilter += ' and LastCorporateOutreach__c <= ' + cFilter.lastCorporateOutreachTo ;
      }
        
      /*
       Spend Amount - 1
      if(iSpendAmount != null && iSpendAmount != 0){
          string sSpendNameField = sSpendField + sCurrency + '__pc';

          sQueryFilter += ' and ' + sSpendNameField + (sOperator=='less or equal'?'<=':'>=') + iSpendAmount;
      }

       Spend Amount - 2
      if(iSpendAmount2 != null && iSpendAmount2 != 0){
          string sSpendNameField2 = sSpendField2 + sCurrency + '__pc';

          sQueryFilter += ' and ' + sSpendNameField2 + (sOperator2=='less or equal'?'<=':'>=') + iSpendAmount2;
      }



       --------------------------------------------------------------
       TASK & EVENT filters - Doesn't support semi join inner selects
       --------------------------------------------------------------
       TO BE COMPLETED
      Set<String> accountIds= new set<String>();
      if ((oSearchAccount.TECH_OutreachFrom__pc != null || oSearchAccount.TECH_OutreachTo__pc != null) && OutreachScope.size() != 0) {
          List<String> RTList=new List<String>();
          orQueryString='SELECT AccountId FROM Task WHERE';


          Outreach Scope : Store / Corporate
          tempSetVal.clear();
          tempSetVal.addAll(OutreachScope);
          if(tempSetVal.contains(System.Label.IC_Last_Store_Outreach)) {RTList.add(IC_UTILS.getTaskRT());}
          if(tempSetVal.contains(System.Label.IC_Last_Corporate_Outreach)) {RTList.add(IC_UTILS.getTaskDreamRT());}
          orQueryString += ' RecordTypeId IN (' + inFilter(RTList) + ') ';

          Outreach Date Range
          if(oSearchAccount.TECH_OutreachFrom__pc != null){
              DateTime dOutreachDateFrom = DateTime.newInstance(oSearchAccount.TECH_OutreachFrom__pc, Time.newInstance(0, 0, 0, 0));
              orQueryString += ' AND activitydate >= ' + dOutreachDateFrom.format('yyyy-MM-dd');
          }

          if(oSearchAccount.TECH_OutreachTo__pc != null){
              DateTime dOutreachDateTo = DateTime.newInstance(oSearchAccount.TECH_OutreachTo__pc, Time.newInstance(0, 0, 0, 0));
              orQueryString += ' AND activitydate <= ' + dOutreachDateTo.format('yyyy-MM-dd');
          }

           Action Type
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
  */

  return clientFilter;
}
  /*=================================================================================================================*/
  @RemoteAction
  public static List<User> GetAdvisorsByStore(Map<String,HierarchyLevel> sFilter, String text, Boolean isTechnical){
      isTechnical = false; // Nehora: it seems isTechnical=true is irrelevant and it's not clear why exist. approved by Lisa.

      text = '\'' + text + '%\'';
      String identityProfile = IC_utils.getIdentityProfile();
      String usersQuery = 'SELECT Id, Name FROM user WHERE ( ProfileID <> \'' +identityProfile+ '\' AND (FirstName LIKE ' + text + ' OR LastName LIKE ' + text + ')' ;
      
      usersQuery += ' AND isActive = TRUE ';

      // if(!isTechnical) {
      //   usersQuery += ' AND isActive = TRUE  AND IsTechnicalUser__c = FALSE ';
      // }
      if( sFilter.containsKey('5') ){
          usersQuery += ' AND DefaultStore__c = \''+ sFilter.get('5').value + '\' ';
      }
      else if (sFilter.containsKey('4') ){
          usersQuery += ' AND MGMT_ZONE_SUB_LEVEL3__c = \''+ sFilter.get('4').value + '\' ';
      }
      else if (sFilter.containsKey('3')){
          usersQuery += ' AND MGMT_ZONE_SUB_LEVEL2__c = \''+ sFilter.get('3').value + '\' ';
      }
      else if (sFilter.containsKey('2')){
          usersQuery += ' AND MGMT_ZONE_SUB_LEVEL1__c = \''+ sFilter.get('2').value + '\' ';
      }
      else if (sFilter.containsKey('1')){
          usersQuery += ' AND MANAGEMENT_ZONE_LEVEL__c = \''+ sFilter.get('1').value + '\'';
      }
      usersQuery += ' ) ';
      // if(isTechnical){
          if(IC_Config__c.getInstance('Technical User Reassign') != null){
              String users = IC_Config__c.getInstance('Technical User Reassign').Value__c;
              if(users != null){
                  List<String> userList = users.split(';');
                  //usersQuery += ' OR ( IsTechnicalUser__c = true and DefaultStore__c = \'\' ) ';
                  usersQuery += ' OR (Id in:userList) ';    
              }    
          }
      // }
      usersQuery += ' ORDER BY Name';
      system.debug('function - GetAdvisorsByStore: usersQuery: ' + usersQuery);
      return Database.query(usersQuery);
  }
  /*=================================================================================================================*/
private static String buildStoreFilter(Map<String,HierarchyLevel> sFilter, String ownerDefaultStore){
  system.debug('function - buildStoreFilter \n\n sFilter: \n ' + sFilter + '\n\n');
      String storeFilter = '';
      if( sFilter.containsKey('1') || sFilter.containsKey('2') || sFilter.containsKey('3')|| sFilter.containsKey('4') || sFilter.containsKey('5')){
        storeCodes = new Set<String>();
        if( sFilter.containsKey('5') ){
          system.debug('function - buildStoreFilter: sFilter: \n ' + sFilter.get('5').value + '\n\n');
          storeCodes.add(sFilter.get('5').value ); /*+= ' and AttachedStore__pc  = \''  + sFilter.get('5').value + '\' ' ;*/
        }
        else {
          String myStoreQuery = 'Select RetailStoreId__c from Store__c ';
          if (sFilter.containsKey('4') ){
            myStoreQuery += ' WHERE MGMT_ZONE_SUB_LEVEL3__c = \''+ sFilter.get('4').value + '\'';
          }
          else if (sFilter.containsKey('3')){
            myStoreQuery += ' WHERE MGMT_ZONE_SUB_LEVEL2__c = \''+ sFilter.get('3').value + '\'';
          }  
          else if (sFilter.containsKey('2')){
            myStoreQuery += ' WHERE MGMT_ZONE_SUB_LEVEL1__c = \''+ sFilter.get('2').value + '\'';
          }  
          else if (sFilter.containsKey('1')){
            myStoreQuery += ' WHERE MANAGEMENT_ZONE_LEVEL__c = \''+ sFilter.get('1').value + '\'';
          }  
          
          system.debug('function - buildStoreFilter: myStoreQuery:' + myStoreQuery);
      /* Execute the query */
            List<Store__c> lstStore = Database.query(myStoreQuery);
          String strLstStore = '';
            for(Store__c s : lstStore){
                storeCodes.add(s.RetailStoreId__c);
            }
            
        }

        if(storeCodes != null && storeCodes.size() >0){
            storeFilter += ' and ' + ownerDefaultStore + ' IN :storeCodes'; // TODO Maybe change "and" to "or"
        } 
      }
      system.debug('function - buildStoreFilter: ' + storeCodes);
  return storeFilter;
}
  /*=================================================================================================================*/
private static string inFilter(list<String> lValues){
      string sValue = '';
      for(integer i=0; i<lValues.size(); i++){
          sValue += '\'' + lValues[i] + '\'';

          if(i != lValues.size()-1)
              sValue += ',';
      }
      return sValue;
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static ClientListResponse createClientList(List<AcountResponse> selectedClients, String listName,
                                                    String listDescription, String expirationDate, String typology, String offerCode){
    string separator = '!';
    ClientListResponse response = new ClientListResponse();
    response.numberOfListsCreated = 0;
    response.numberOfListsUpdated = 0;
    response.numberOfMembersCreated = 0;
    response.numberOfMembersCreatedforExistingCL = 0;
    response.numberOfMembersFailures = 0;
    response.numberOfListFailures = 0;
    response.numberOfListUpdateFailures = 0;
    map<Id, string> ownerIdToClientsMap = new map<Id, string>();
    set<Id> lUniqueOwnerIdFinal = new set<Id>();
    set<ID> lUniqueOwnerIdDoublon = new set<Id>();
    map<ID, CLI_CliList__c> ownerToListMap = new map<Id, CLI_CliList__c>();

    list<CLI_CliList__c> lClientsListsToInsert = new list<CLI_CliList__c>();
    list<CLM_CliListMember__c> lClientsListsMembersToInsert = new list<CLM_CliListMember__c>();
    list<CLI_CliList__c> allCltList = new list<CLI_CliList__c>();
    /*string sSAName = ''; */
    // TEMP WORKAROUND - EXCLUSIVE EXPERIENCE
    if(offerCode == 'exclu_nba_1_2020.'){
      offerCode = 'exclu_nba_1_2020';
    } 

      try{
          /* Construct a list of selected Clients */
          for(AcountResponse oAccount:selectedClients){
              /*create a map of ownerIds with all his associated clients*/
              if(!ownerIdToClientsMap.containsKey(oAccount.OwnerId)){
                /*sSAName += '<br/>• ' + oAccount.OwnerName;*/
                ownerIdToClientsMap.put(oAccount.OwnerId, '');
              }
              string newEntry = ownerIdToClientsMap.get(oAccount.OwnerId) + oAccount.PersonContactId + separator;
              ownerIdToClientsMap.put(oAccount.OwnerId, newEntry);
          }

          /* Check that the Client list do not exist for the owners 
           Client List for all Users */

           /* , temp_account_ids__c */

         allCltList = [SELECT id, name, OwnerId,TECH_TempAccountIds__c//
                  FROM CLI_CliList__c
                  WHERE OwnerId IN :ownerIdToClientsMap.keySet()
                  AND Name =: listName];

    for (CLI_CliList__c c : allCltList) {
       ownerToListMap.put (c.ownerid, c);
     }

     for (Id ownerId : ownerIdToClientsMap.keySet()) {
       if (!ownerToListMap.containsKey(ownerId)) {
         lUniqueOwnerIdFinal.add(ownerId);
       }else{
         lUniqueOwnerIdDoublon.add(ownerId);
       }
     }

     system.debug('### lUniqueOwnerIdFinal.size():' + lUniqueOwnerIdFinal.size());
     system.debug('### lUniqueOwnerIdFinal :' + lUniqueOwnerIdFinal);
     system.debug('### lUniqueOwnerIdDoublon.size():' + lUniqueOwnerIdDoublon.size());
     system.debug('### lUniqueOwnerIdDoublon :' + lUniqueOwnerIdDoublon);

          /* Creating Client List */
          if(!lUniqueOwnerIdFinal.isEmpty()){
              for(Id sOwnerId:lUniqueOwnerIdFinal){
                string clients = ownerIdToClientsMap.get(sOwnerId);
                response.numberOfMembersCreated += clients != null? clients.split('[!]').size():0;
                  lClientsListsToInsert.add(new CLI_CliList__c(
                      Name = listName,
                      ExpirationDate__c = Date.Valueof(expirationDate),
                      Description__c = listDescription,
                      Active__c = false,
                      TECH_LaunchAddMembersBatch__c = true,
                      TECH_DoNotLaunchWorkflow__c = true,
                      OwnerId = sOwnerId,
                      TECH_TempAccountIds__c = clients,
                      TECH_CreatedFromTCLScreen__c = true,
                      Typology__c = typology,
                      Offer_Code__c = offerCode
                      )
                  );
              }

              if(!lClientsListsToInsert.isEmpty()){
                  /* Create clients lists assigned to the specific SA */
                  Database.Saveresult[] lSR = Database.insert(lClientsListsToInsert, false);
                  /* Check Results */
                  for (integer i=0;i<lSR.size();i++){
                      Database.SaveResult oSR = lSR[i];

                      if(oSR.isSuccess()){
                        response.numberOfListsCreated ++;
                      }
                      else {
                        response.numberOfListFailures ++;
                      }
                  }
                  /* ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.IC_Client_List_Created.replaceAll('###CLNAME###', listName).replaceAll('###SANAME###', sSAName))); */
              }
          }
          /* TAKE CARE OF THIS. */

          /* ICI */
          if(!lUniqueOwnerIdDoublon.isEmpty()) {
            list<CLI_CliList__c> cliListToUpdate = new list<CLI_CliList__c>();
            /* lClientsListsMembersToInsert.clear(); */
            system.debug('### DANS IF :');
              for(ID ownerId : lUniqueOwnerIdDoublon){
                string accountIds = ownerIdToClientsMap.get(ownerId);
                if(accountIds == null) accountIds = '';
                response.numberOfMembersCreatedforExistingCL += accountIds != null? accountIds.split('[!]').size():0;
                CLI_CliList__c cliList = ownerToListMap.get(ownerId);
                if(cliList.TECH_TempAccountIds__c  == null )
                  cliList.TECH_TempAccountIds__c  = accountIds;
                else
                  cliList.TECH_TempAccountIds__c += (separator + accountIds);
                cliList.TECH_LaunchAddMembersBatch__c = true;
                cliListToUpdate.add(cliList);
              }
            if(!cliListToUpdate.isEmpty()){
              system.debug('### DANS SECOND INSERT');
              system.debug('### lClientsListsMembersToInsert' + lClientsListsMembersToInsert);
                /* Create clients lists members */
              //update cliListToUpdate;
                /* ApexPages.AddMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.IC_Client_List_Created.replaceAll('###CLNAME###', listName).replaceAll('###SANAME###', sSAName))); */
              Database.Saveresult[] lSR = Database.update(cliListToUpdate, false);
                  /* Check Results */
              for (integer i=0;i<lSR.size();i++){
                  Database.SaveResult oSR = lSR[i];

                  if(oSR.isSuccess()){
                    response.numberOfListsUpdated ++;
                  }
                  else {
                    response.numberOfListUpdateFailures ++;
                  }
              }
            }
          }


      }
      catch(Exception e){
        response.errorMessage = e.getMessage();
      }
      return response;

  }
  /*=================================================================================================================*/
  @RemoteAction
  public static List<CLI_CliList__c> GetClientLists(String listName, Map<String,HierarchyLevel> sFilter, string lastId) {
    
      listName = '\'%' + listName + '%\'';
      String query = 'SELECT Id,Name,Description__c,OwnerId, Owner.Name,CreatedDate, TECH_OwnerDefaultStore__c ' +
                   + 'FROM CLI_CliList__c WHERE Name like ' + listName + ' And Active__c = true';
      query += buildStoreFilter(sFilter, 'Owner_Default_Store__c');
      
      if(!String.isEmpty(lastId)){
          query += ' and Id > \'' + lastId + '\' ';
      }
      query += ' order by Id asc limit 300';
          system.debug('FUNC GetClientLists QUERY: ' + query);
      List<CLI_CliList__c> result = Database.query(query);
      Set<String> ownerIds = new Set<String>();
      for(CLI_CliList__c item: result)
      {
          ownerIds.add(item.OwnerId);
      }
      Map<Id,User> users = new Map<Id,User>([Select Id, toLabel(DefaultStore__c) FROM User WHERE Id IN :ownerIds]);
      
      for(CLI_CliList__c item: result)
      {
          item.TECH_OwnerDefaultStore__c =  users.get(item.OwnerId).DefaultStore__c;
      }

      return result;
  }
  /*=================================================================================================================*/
  @RemoteAction
  public static object DeactivateClientLists(List<String> listIds) {
      String message = 'Success';

      Set<String> clientsIdSet = new Set<String>();
      for(String id : listIds){
          clientsIdSet.add(id);
      }
      try{
          List<CLI_CliList__c> clientLists = [SELECT Id FROM CLI_CliList__c WHERE Id in:clientsIdSet];    
          for(CLI_CliList__c client : clientLists){
              client.Active__c  = false;
          }
          update clientLists;    
      }
      catch(exception ex){
          return ex;
      }
      
      return message;
  }
  /*=================================================================================================================*/
@RemoteAction
public static String getUserNameFromId (String inputId) {
  List<User> userList = [SELECT Id, Name FROM User WHERE Id = :inputId LIMIT 1];
  return userList[0].Name;
}

public static Integer indexOf(List<String> inList,String searchedString){
  for(Integer i = 0; i<inList.size(); i++){
      if(inList[i] == searchedString){
          return i;
      }
  }
  return -1;
}

/*
private static List<String> getProductGenders(List<String> genders){
  
  List<String> convertedGenders = new List<String>();
  for(String gender :genders){
    if(gender == 'Unisex'){
      convertedGenders.add('Other');
      convertedGenders.add('Unknown');
    }
    else if (gender == 'Women'){
      convertedGenders.add( 'Female');
    }
    else if (gender == 'Men'){
      convertedGenders.add('Male') ;
    }
  }
  return convertedGenders;
}*/

}