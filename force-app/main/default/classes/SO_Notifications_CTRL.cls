public without sharing class SO_Notifications_CTRL {

  //  private static Map<SO_OrderPageSwitch.LogicalUserRoleEnum, Set<String>> roleStageFilter;
  //  private static final String FIRMORDER_STATUS = 'Sent to store';
  //  private static final Integer NOTIFICATIONS_LIMIT = 2000;

    
  //  public String storeCodesAvailableListStr    {get; private set;}
  //  public String storeSelectedValue            {get; set;}

  //  static {
  //      roleStageFilter = new Map<SO_OrderPageSwitch.LogicalUserRoleEnum, Set<String>> {
  //          SO_OrderPageSwitch.LogicalUserRoleEnum.Store => new Set<String> {
  //              'Brief in progress',
  //              'Quotation submitted'
  //          } 
  //         ,SO_OrderPageSwitch.LogicalUserRoleEnum.Production => new Set<String> {
  //              'Quotation in progress',
  //              'Deposit sent'
  //          }
  //         ,SO_OrderPageSwitch.LogicalUserRoleEnum.Other => new Set<String> {

  //         }
  //      };          
  //  }

  //  private SO_OrderPageSwitch orderPageSwitch;
  //  public List<ViewLine> viewLineList { get; set; }
  //  private Map<String, List<ViewLine>> viewLineListByStoreCodeMap;
  //  private List<ViewLine> viewLineAllList;

  //  public Boolean isAsnieresUser { 
  //      get {return SO_Util.isAsnieresUser();}
  //  }

  //  public Integer globalMessageCounter { get; private set;}

  //  public SO_Notifications_CTRL() {
  //      this(true);
  //  }

  //  public SO_Notifications_CTRL(Boolean forViewList) {
  //      init(forViewList);
  //  }
    
  //  private void init(Boolean forViewList)
  //  {
  //      this.orderPageSwitch = new SO_OrderPageSwitch();
  //      this.viewLineListByStoreCodeMap = new Map<String, List<ViewLine>>();
  //      this.viewLineAllList = new List<ViewLine>();
  //      this.storeCodesAvailableListStr = '';
  //      this.storeSelectedValue = '';
  //      try
  //      {
  //          this.storeSelectedValue = this.orderPageSwitch.currentUser.DefaultStore__c != NULL ? 
  //                                      this.orderPageSwitch.currentUser.DefaultStore__c : 
  //                                      Label.LV_SO_All;
  //          retRelevantMsgList(forViewList);
  //      }
  //      catch(Exception e)
  //      {
  //          SO_UTIL.exceptionDump(e);
  //      }
  //  }

  //  public void retRelevantMsgList(Boolean forViewList) {
  //      globalMessageCounter = 0;
  //      String query = retQuery();
  //      System.debug('query >> ' + query);
  //      List<Opportunity> opportunityList = Database.query(query);
  //      System.debug('retRelevantMsgList - opportunityList size: ' + opportunityList.size());
  //      Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>(opportunityList);
  //      //Map<ID, List<SPO_Message__c>> oppIdToMsgMap = new Map<ID, List<SPO_Message__c>>();
  //      this.viewLineList = new List<ViewLine>();
  //      //to do
  //      Map<ID, String> targetPageMap = this.orderPageSwitch.buildTargetPageMap(opportunityList);
  //      Map<ID, Set<String>> permissionMap = SO_OrderPageSwitch.permissionByUserMap;
  //      Set<String> permissionForCurrUser = permissionMap.get(UserInfo.getUserId());

  //      System.debug('permissionForCurrUser >> ' + permissionForCurrUser);

  //      //Map<String, String> permRolesSetToCat = new Map<String, String>(SO_OrderPageSwitch.productionPermissionSetToCategory);
  ////      permRolesSetToCat.putAll(SO_OrderPageSwitch.otherPermissionSetToCategory);

  //      //List<PermissionSetAssignment> permissionByUserList = SO_OrderPageSwitch.retPermissionByUser(permRolesSetToCat.keySet(), new Set<ID> { UserInfo.getUserId() });

  //      //List<PermissionSetAssignment> permissionByUserList = SO_OrderPageSwitch.retPermissionByUser(SO_OrderPageSwitch.productionPermissionSetToCategory.keySet(), 
  //      //                                                  new Set<Id> { UserInfo.getUserId() });
  //      //Boolean hasPermissionSet = !permissionByUserList.isEmpty();

  //      for(Integer X = 0; X < opportunityList.size(); X++) {

  //          Opportunity oneOpp = opportunityList[X];
  //          System.debug('retRelevantMsgList >> Id >> ' + oneOpp.Id + ' oneOpp.StageName >> ' + oneOpp.StageName + 'orderPageSwitch.sfoUserRole >> ' + this.orderPageSwitch.sfoUserRole);

  //          SO_OrderPageSwitch.LogicalUserRoleEnum logicalUserRoleByObject = this.orderPageSwitch.sfoUserRoleByObject(oneOpp); 
  //          String logicalUserRoleName = logicalUserRoleByObject.name();
  //          String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { logicalUserRoleName });

  //          if(oneOpp.SPO_Store__c == null || String.isBlank(oneOpp.SPO_Store__r.RetailStoreId__c))
  //          {
  //              continue;
  //          }

  //          //if((SO_OrderPageSwitch.LogicalUserRoleEnum.Production == logicalUserRoleByObject 
  //          //  || SO_OrderPageSwitch.LogicalUserRoleEnum.Other == logicalUserRoleByObject) 
  //          //   && hasPermissionSet 
  //          //   && !permissionForCurrUser.contains(oneOpp.SPO_ProductCategory__c))
  //          //{
  //          if((SO_OrderPageSwitch.LogicalUserRoleEnum.Production == logicalUserRoleByObject 
  //              || SO_OrderPageSwitch.LogicalUserRoleEnum.Other == logicalUserRoleByObject) 
  //             && permissionForCurrUser != null 
  //             && !permissionForCurrUser.contains(oneOpp.SPO_ProductCategory__c))
  //          {
  //              //hasPermission = false;
  //              continue;
  //          }
  //          System.debug('hasPermission, oneOpp >> ' + oneOpp.Id + ' Product Category >> ' + oneOpp.SPO_ProductCategory__c);


  //          //TODDO: not need
  //          if(!roleStageFilter.containsKey(logicalUserRoleByObject)) 
  //          {
  //              continue;
  //          }

  //          Boolean isValid = roleStageFilter.get(logicalUserRoleByObject).contains(oneOpp.StageName);

  //          //check if has unread messages
  //          Integer iconMode;   
  //          String  msgLastModifiedDate;
  //          Boolean hasUnreadMsg = false;
  //          Integer msgIndex = 0;

  //          while(!hasUnreadMsg && SO_UTIL.isNotEmpty(oneOpp.SpeORDER_Messages__r) && msgIndex < oneOpp.SpeORDER_Messages__r.size()) 
  //          {
  //              SPO_Message__c oneMsg = oneOpp.SpeORDER_Messages__r[msgIndex];
  //              if(logicalUserRoleName != oneMsg.SPO_WritterRole__c && false == (Boolean)oneMsg.get(fieldTmpl)) 
  //              {
  //                  iconMode = isValid ? 1 : 2;
  //                  hasUnreadMsg = isValid = true;
  //                  msgLastModifiedDate = oneMsg.CreatedDate.date().format();
  //              }
  //              ++msgIndex; 
  //          }

  //          if(!isValid
  //             && logicalUserRoleByObject == SO_OrderPageSwitch.LogicalUserRoleEnum.Store
  //             && SO_UTIL.isNotEmpty(oneOpp.SpeOrder_Order_Following__r))  
  //          {
  //              SPO_FirmOrder__c actualOrder = SO_OrderPageSwitch.retActualOrder(oneOpp.SpeOrder_Order_Following__r);
  //              isValid = FIRMORDER_STATUS.equalsIgnoreCase(actualOrder.SPO_Substatus__c);
  //              iconMode = isValid ? 1 : 2;
  //          }

  //          if(!isValid) {
  //              continue;
  //          }

  //          ++globalMessageCounter;

  //          if(!forViewList) {
  //              continue;
  //          }

  //          //set avaialbe store codes
  //          if(!this.viewLineListByStoreCodeMap.containsKey(oneOpp.SPO_Store__r.RetailStoreId__c))
  //          {
  //              this.viewLineListByStoreCodeMap.put(oneOpp.SPO_Store__r.RetailStoreId__c, new List<ViewLine>());
  //          }

  //          String pageLink = targetPageMap.get(oneOpp.Id); 
  //          //add opportunity   
  //          ViewLine currentViewLine = new ViewLine(oneOpp, pageLink);
  //          if(hasUnreadMsg) {
  //              currentViewLine.mode = iconMode;
  //              currentViewLine.lastModifiedDate = msgLastModifiedDate;
  //          }

  //          this.viewLineListByStoreCodeMap.get(oneOpp.SPO_Store__r.RetailStoreId__c).add(currentViewLine);
  //          this.viewLineAllList.add(currentViewLine);
            
  //      }
  //      System.debug('SO_Notifications_CTRL - retRelevantMsgList - this.viewLineListByStoreCodeMap: ' + this.viewLineListByStoreCodeMap);
  //      if(!this.viewLineAllList.isEmpty())
  //      {
  //          this.viewLineListByStoreCodeMap.put(Label.LV_SO_All, this.viewLineAllList);
  //      }
  //      retSelectedViewLineList();
  //      setCodesAvailablePicklist();
  //  }

  //  private void setCodesAvailablePicklist()
  //  {
  //      Set<String> storeCodesAvailableList = new Set<String>();
  //      for(String storeCode : this.viewLineListByStoreCodeMap.keySet())
  //      {
  //          if(!this.viewLineListByStoreCodeMap.get(storeCode).isEmpty())
  //          {
  //              storeCodesAvailableList.add(storeCode);
  //          }
  //      }
  //      this.storeCodesAvailableListStr = JSON.serialize(storeCodesAvailableList);
  //  }

  //  public void retSelectedViewLineList()
  //  {
  //      this.viewLineList.clear();
  //      if(this.viewLineListByStoreCodeMap.containsKey(this.storeSelectedValue))
  //      {
  //          this.viewLineList = this.viewLineListByStoreCodeMap.get(this.storeSelectedValue).clone();
  //      }
  //  }

  //  public String retQuery() {

  //      String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { this.orderPageSwitch.sfoUserRoleName });

  //      String query = 'SELECT Id, Name'; 
  //      query +=',StageName';
  //      query +=',Account.Name';
  //      query +=',SPO_Store__c';
  //      query +=',SPO_Store__r.Name';
  //      query +=',SPO_Store__r.RetailStoreId__c';
  //      query +=',SPO_OrderType__c';
  //      query +=',LastModifiedDate';
  //      query +=',CreatedDate';
  //      query +=',SPO_StoreCode__c';
  //      query +=',SPO_CACode__c';
  //      query +=',SPO_ProductCategory__c';
  //      query +=',OwnerId';
  //      query +=',SPO_CreationType__c';
  //      query +=',SPO_NoPersonNeeded__c';
  //      query +=',SPO_BriefCode__c';

  //      query +=',(';
  //      query +='SELECT Id, Name, CreatedDate'; 
  //      query +=',SPO_Message__c';
  //      query +=',SPO_WritterRole__c';
  //      query +=',SPO_ReadByother__c';
  //      query +=',SPO_ReadByProduction__c';
  //      query +=',SPO_ReadByStore__c';
  //      query +=',SPO_BriefConcerned__c';
  //      query +=',SPO_BriefConcerned__r.Account.Name';
  //      query +=',SPO_BriefConcerned__r.LastModifiedDate';
  //      query +=',SPO_BriefConcerned__r.CreatedDate';
  //      query +=',SPO_BriefConcerned__r.Name';
  //      query +=',SPO_BriefConcerned__r.SPO_OrderType__c';
  //      query +=',SPO_BriefConcerned__r.SPO_ProductCategory__c';
  //      query +=',SPO_BriefConcerned__r.SPO_Store__r.Name';
  //      query +=',SPO_BriefConcerned__r.StageName';
  //      query +=',SPO_BriefConcerned__r.SPO_StoreCode__c';
  //      query +=',SPO_BriefConcerned__r.SPO_CACode__c';
        
  //      query +=' FROM SpeORDER_Messages__r ORDER BY CreatedDate DESC';
  //      //query += ' WHERE (SPO_WritterRole__c = ' + SO_UTIL.addApostrophe(orderPageSwitch.sfoUserRoleName) 
  //      //query += ' AND ' + fieldTmpl + ' = false'; 
  //      query +=')';
  //      query +=',(';
  //      query +='SELECT Id, Name';
  //      query +=',SPO_BriefName__c'; 
  //      query +=',SPO_Substatus__c';
  //      query +=',SPO_FirmOrderStatus__c';
  //      query +=' FROM SpeOrder_Order_Following__r';
  //      query +=')'; 
  //      query +=' FROM Opportunity';

  //      //TODO ask if Store user must have store:
  //      //query +=' WHERE SPO_Store__r.RetailStoreId__c = ' + SO_UTIL.addApostrophe(this.orderPageSwitch.currentUser.DefaultStore__c);
  //      //END TODO
        
  //      //query +=' OR OwnerId = ' + SO_UTIL.addApostrophe((String)this.orderPageSwitch.currentUser.Id);        
  //      //query +=' WHERE OwnerId = ' + SO_UTIL.addApostrophe((String)this.orderPageSwitch.currentUser.Id); 

  //      //MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c
  //      List<String> fieldsInQuery = new List<String>();
  //      if(this.orderPageSwitch.sfoUserRole != SO_OrderPageSwitch.LogicalUserRoleEnum.Production
  //          && String.isNotBlank(this.orderPageSwitch.currentUser.MANAGEMENT_ZONE_LEVEL__c))
  //      {
  //          if(String.isNotBlank(this.orderPageSwitch.currentUser.MANAGEMENT_ZONE_LEVEL__c))
  //          {
  //              fieldsInQuery.add('SPO_Store__r.MANAGEMENT_ZONE_LEVEL__c=' + SO_UTIL.addApostrophe(this.orderPageSwitch.currentUser.MANAGEMENT_ZONE_LEVEL__c));
  //          }

  //          if(String.isNotBlank(this.orderPageSwitch.currentUser.MGMT_ZONE_SUB_LEVEL1__c))
  //          {
  //              fieldsInQuery.add('SPO_Store__r.MGMT_ZONE_SUB_LEVEL1__c=' + SO_UTIL.addApostrophe(this.orderPageSwitch.currentUser.MGMT_ZONE_SUB_LEVEL1__c));
  //          }

  //          if(String.isNotBlank(this.orderPageSwitch.currentUser.MGMT_ZONE_SUB_LEVEL2__c))
  //          {
  //              fieldsInQuery.add('SPO_Store__r.MGMT_ZONE_SUB_LEVEL2__c=' + SO_UTIL.addApostrophe(this.orderPageSwitch.currentUser.MGMT_ZONE_SUB_LEVEL2__c));
  //          }

  //          if(String.isNotBlank(this.orderPageSwitch.currentUser.MGMT_ZONE_SUB_LEVEL3__c))
  //          {
  //              fieldsInQuery.add('SPO_Store__r.MGMT_ZONE_SUB_LEVEL3__c=' + SO_UTIL.addApostrophe(this.orderPageSwitch.currentUser.MGMT_ZONE_SUB_LEVEL3__c));
  //          }

  //          if(String.isNotBlank(this.orderPageSwitch.currentUser.DefaultStore__c))
  //          {
  //              fieldsInQuery.add('SPO_Store__r.RetailStoreId__c=' + SO_UTIL.addApostrophe(this.orderPageSwitch.currentUser.DefaultStore__c));
  //          }

  //          query += ' WHERE OwnerId = ' + SO_UTIL.addApostrophe((String)this.orderPageSwitch.currentUser.Id);

  //          if(!fieldsInQuery.isEmpty())
  //          {
  //              query += ' OR (' + String.join(fieldsInQuery, ' AND ') + ')';
  //          }

  //      }

  //      query += ' LIMIT ' + NOTIFICATIONS_LIMIT;
  //      return query;

  //  }

  //  public class ViewLine {

  //      //public ID      targetId       { get; set; }
  //      public Integer mode             { get; set; }
  //      public String  clientName       { get; set; }
  //      public String  lastModifiedDate { get; set; }
  //      public String  createdDate      { get; set; }
  //      public String  orderName        { get; set; }
  //      public String  orderDescription { get; set; }
  //      public String  orderType        { get; set; }
  //      public String  productCategory  { get; set; }
  //      public String  store            { get; set; }
  //      public String  stageName        { get; set; }
  //      public String  pageLink         { get; set; }
  //      public String  storeCode        { get; set; }
  //      public String  caCode           { get; set; }
  //      public String  softOrHardSided  { get; set; }
  //      public String  noPersoNeeded    { get; set; }
  //      public String  briefCode        { get; set; }

  //      public ViewLine(SPO_Message__c msg, String pageLink) {
  //          this(pageLink, msg.SPO_BriefConcerned__r);
  //          mode = 2;

  //      }

  //      public ViewLine(Opportunity opp, String pageLink) {
  //          this(pageLink, opp);
  //          mode = 0;
  //      }

  //      private ViewLine(String pageLink, Opportunity target) {

  //          System.debug('ViewLine.target.StageName >> ' + target.StageName);

  //          lastModifiedDate    = target.LastModifiedDate.date().format();//(No. 1)
  //          createdDate         = target.CreatedDate.date().format();//(No. 1)
  //          //mode(2)
  //          clientName          = target.Account.Name;//(No. 3)
  //          orderName           = target.Name;//(No. 4)
  //          orderType           = target.SPO_OrderType__c;//(No. 5)
  //          store               = target.SPO_Store__r.Name;//(No. 6)
  //          storeCode           = target.SPO_StoreCode__c;//(No. 7)
  //          caCode              = target.SPO_CACode__c;//(No. 8)
  //          stageName           = target.StageName;//(No. 9)

  //          productCategory     = target.SPO_ProductCategory__c;
            

  //          if(String.isNotBlank(pageLink)) {
  //              String prefix = pageLink.contains('?') ? '&id=' : '?id=';
  //              this.pageLink = pageLink + prefix + target.Id; 
  //          }

  //          softOrHardSided     = target.SPO_CreationType__c;//(No. 11)
  //          noPersoNeeded       = ''+target.SPO_NoPersonNeeded__c;//(No. 12)
  //          //briefCode           = target.SPO_BriefCode__c;//(No.13)
  //      }
  //  }
}