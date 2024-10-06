/*
CreatedDate: July 2022
Company: Balink
Author: Naomi Baroghel
Description: New Controller for new Client page
*/

public without sharing class ICX_Client360_SF {
  @AuraEnabled(cacheable=true)
  public static Integer getrecordsListSize(Id accountId, String objectName, String condition) {
Date threeMonthAgo = (Date.Today()).addMonths(-3);
    System.debug('clientId' + accountId);
    System.debug('objectName' + objectName);
    System.debug('condition' + condition);
    String query = 'SELECT COUNT() FROM ' + objectName + ' ' + condition;
    Integer listSize = Database.countQuery(query);
    System.debug('Display the list size' + listSize);
    return listSize;
  }


  //need to have another function then getrecordsListSize because we cannot used RecordType in dynamic query
  @AuraEnabled(cacheable=true)
  public static Integer getrecordsListSizeRemoteConsent(Id accountId) {
    Id RCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent').getRecordTypeId();
    return [SELECT COUNT() FROM CASE WHERE AccountId =: accountId AND RecordTypeId =:RCRecordTypeId ];
  }

  // @AuraEnabled(cacheable=true)
  // public static String getAppName() {
  //   UserAppInfo userAppInfo = [
  //     SELECT Id, AppDefinitionId
  //     FROM UserAppInfo
  //     WHERE UserId = :UserInfo.getUserId()
  //     LIMIT 1
  //   ];
  //   AppDefinition appDefinition = [
  //     SELECT DurableId, Label
  //     FROM AppDefinition
  //     WHERE DurableId = :userAppInfo.AppDefinitionId
  //     LIMIT 1
  //   ];
  //   return appDefinition.Label;
  // }

  @AuraEnabled(cacheable=true)
  public static PermissionSetAssignment isGroupMember(Id userId) {
    PermissionSetAssignment member = [
      SELECT Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId AND PermissionSet.Name = 'Icx_authToMerge'
    ];
    System.debug('Display here the permission set member =========>>>>>>>>>>>>' + member);
    return member;
    /*
    GroupMember member = [
      SELECT Id, Group.DeveloperName
      FROM GroupMember
      WHERE UserOrGroupId = :userId AND Group.DeveloperName = :'authToMerge'
    ];
    System.debug('Display here the geuop member =========>>>>>>>>>>>>' + member);
    return member;
    */
  }

  @AuraEnabled(cacheable=true)
  public static List<Case> getAllRequests(Id accountId, Boolean isComplaint, Boolean isRemoteConsent, Boolean isClienteling) {

    String query = 'SELECT Id,  CaseNumber, Type, CreatedDate, Status, RecordType.Name FROM Case WHERE AccountId =: accountId ';
    if (isComplaint == true) query += ' AND Type = \'Complaints\' ';
    else if(isRemoteConsent == true) {
      Id RCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent').getRecordTypeId();
      query += ' AND RecordTypeId =: RCRecordTypeId ';
    } else if(isClienteling == true) query += ' AND RecordType.DeveloperName = \'Clienteling\' AND Status = \'New\'  ';
    else query += ' AND Type != \'Complaints\' AND  RecordType.DeveloperName != \'Remote_Consent\'  AND  RecordType.DeveloperName != \'Clienteling\' ' ;
    query += ' ORDER BY CreatedDate DESC LIMIT 3' ;
    System.debug('getAllRequests query' + query);

    List<Case> myListRequests = (List<Case>) Database.query(query);

    System.debug('getAllRequests myListRequests' + myListRequests);

    return myListRequests;
  }

  @AuraEnabled(cacheable=true)
  public static List<Alias_Member__c> getAliases(Id accountId) {
    List<Alias_Member__c> myListAliases = [
      SELECT Id, Alias__r.Name, Alias__r.Status__c
      FROM Alias_Member__c
      WHERE Client__c = :accountId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.debug('myListAliases' + myListAliases);
    return myListAliases;
  }

  //future use 
  // @AuraEnabled(cacheable=true)
  // public static List<Club_MemberShip__c> getClubMemberShip(Id accountId) {
  //   List<Club_MemberShip__c> myListClubMemberShip = [
  //     SELECT
  //       Id,
  //       Client_Status__c,
  //       Client_App_Activated__c,
  //       clientId__r.MK_Last_Navigation_Date_LVApp__c,
  //       memberDate__c,
  //       clubStatus__c,
  //       Club_status__c,
  //       lastLoginClub__c,
  //       isClubEligible__c
  //     FROM Club_MemberShip__c
  //     WHERE clientId__c = :accountId AND clubName__c = 'Sneakers'
  //     ORDER BY CreatedDate DESC
  //     LIMIT 1
  //   ];

  //   System.debug('myListClubMemberShip' + myListClubMemberShip);

  //   return myListClubMemberShip;
  // }

  @AuraEnabled(cacheable=true)
  public static List<Map<String, String>> getPurchases(Id accountId) {
    List<PPR_PurchProduct__c> myListPurchases = [
      SELECT
        id,
        Name,
        Quantity__c,
        Amount__c,
        CurrencyCode__c,
        SKU__c,
        StoreRetailCode__c,
        PurchasedDate__c,
        Image_Url__c,
        CAName__c
      FROM PPR_PurchProduct__c
      WHERE Client__c = :accountId
      ORDER BY PurchasedDate__c DESC
      LIMIT 3
    ];

    System.debug('myListPurchases' + myListPurchases);

    Set<String> listStoreNameUsed = new Set<String>();

    for (PPR_PurchProduct__c purchase : myListPurchases) {
      listStoreNameUsed.add(purchase.StoreRetailCode__c);
    }

    List<Store__c> listStoreName = [
      SELECT Id, Name, RetailStoreId__c
      FROM Store__c
      WHERE RetailStoreId__c IN :listStoreNameUsed
    ];

    Map<String, string> listStores = new Map<String, String>();

    for (Store__c store : listStoreName) {
      listStores.put(store.RetailStoreId__c, store.name);
    }

    List<Map<String, String>> purchasesProductsListWrapper = new List<Map<String, String>>();

    for (PPR_PurchProduct__c myPurchasesProduct : myListPurchases) {
      Map<String, String> currentPurchases = new Map<String, String>();

      currentPurchases.put('id', myPurchasesProduct.id);
      currentPurchases.put('name', myPurchasesProduct.Name);
      currentPurchases.put('sku', myPurchasesProduct.SKU__c);
      currentPurchases.put('quantity', String.valueOf(myPurchasesProduct.Quantity__c));
      currentPurchases.put('sales', String.valueOf(myPurchasesProduct.Amount__c));
      currentPurchases.put('currencyCode', myPurchasesProduct.CurrencyCode__c);
      currentPurchases.put('storeName',  myPurchasesProduct.StoreRetailCode__c!=null?listStores.get(myPurchasesProduct.StoreRetailCode__c):'');
      currentPurchases.put('purchasedProductDate',myPurchasesProduct.PurchasedDate__c!=null?String.valueOf(myPurchasesProduct.PurchasedDate__c).replace('-', '.'):'');
      currentPurchases.put('OwnerName', myPurchasesProduct.CAName__c);
      currentPurchases.put('productImage', myPurchasesProduct.Image_Url__c);

      purchasesProductsListWrapper.add(currentPurchases);
    }

    return purchasesProductsListWrapper;
  }

  @AuraEnabled(cacheable=true)
  public static ICX_Client360_API_Helper.purchasesWrapper getPurchasesTable(
    Id accountId,
    Integer myLimit,
    Integer myOffset
  ) {
    List<PPR_PurchProduct__c> myListPurchases = [
      SELECT
        Id,
        Name,
        Quantity__c,
        Amount__c,
        CurrencyCode__c,
        SKU__c,
        StoreRetailCode__c,
        PurchasedDate__c,
        Image_Url__c,
        CAName__c,
        TransactionStoreType__c,
        ProductLine__c
      FROM PPR_PurchProduct__c
      WHERE Client__c = :accountId
      ORDER BY PurchasedDate__c DESC
      LIMIT :myLimit
      OFFSET :myOffset
    ];

    System.debug('myListPurchases' + myListPurchases);

    Set<String> listStoreNameUsed = new Set<String>();

    for (PPR_PurchProduct__c purchase : myListPurchases) {
      listStoreNameUsed.add(purchase.StoreRetailCode__c);
    }

    List<Store__c> listStoreName = [
      SELECT Id, Name, RetailStoreId__c
      FROM Store__c
      WHERE RetailStoreId__c IN :listStoreNameUsed
    ];

    Map<String, string> listStores = new Map<String, String>();

    for (Store__c store : listStoreName) {
      listStores.put(store.RetailStoreId__c, store.name);
    }

    ICX_Client360_API_Helper.purchasesWrapper purchasesList = new ICX_Client360_API_Helper.purchasesWrapper();
    if (myListPurchases.size() > 0) {
      for (PPR_PurchProduct__c myPurchasesProduct : myListPurchases) {
        ICX_Client360_API_Helper.purchases purchaseWrapper = new ICX_Client360_API_Helper.purchases();

        purchaseWrapper.productName = myPurchasesProduct.Name;
        purchaseWrapper.purchasedProductDate = myPurchasesProduct.PurchasedDate__c!=null?String.valueOf(myPurchasesProduct.PurchasedDate__c).replace('-', '.'):'';
        purchaseWrapper.type = myPurchasesProduct.TransactionStoreType__c;
        purchaseWrapper.StoreName = myPurchasesProduct.StoreRetailCode__c!=null?listStores.get(myPurchasesProduct.StoreRetailCode__c):'';
        purchaseWrapper.categorie = myPurchasesProduct.ProductLine__c;
        purchaseWrapper.sku = myPurchasesProduct.SKU__c;
        purchaseWrapper.size = null;
        purchaseWrapper.article = myPurchasesProduct.Name;
        purchaseWrapper.OwnerName = myPurchasesProduct.CAName__c;
        purchaseWrapper.quantity = String.valueOF(myPurchasesProduct.Quantity__c);
        purchaseWrapper.sales = String.valueOF(myPurchasesProduct.Amount__c);
        purchaseWrapper.currencyCode = myPurchasesProduct.CurrencyCode__c;
        purchaseWrapper.paymentMethod = null;
        purchaseWrapper.transactionNumber = myPurchasesProduct.Id;
        purchaseWrapper.productImage = myPurchasesProduct.Image_Url__c;

        purchasesList.purchases.add(purchaseWrapper);
      }
    }

    return purchasesList;
  }

  @AuraEnabled(cacheable=true)
  public static List<ICX_Client360_API_Helper.WrapperLabelValueList> getCallingCampaigns(
    Id accountId
  ) {
    List<Calling_Campaign__c> myListCallingCampaigns = [
      SELECT Id, Name, Status__c, Product_Name__c
      FROM Calling_Campaign__c
      WHERE Client__c = :accountId
      ORDER BY CreatedDate DESC
      LIMIT 3
    ];

    System.debug('myListCallingCampaigns' + myListCallingCampaigns);

    List<ICX_Client360_API_Helper.WrapperLabelValueList> callingCampaignsListWrapper = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();
    Integer counter = 0;
    for (Calling_Campaign__c myCallingCampaign : myListCallingCampaigns) {
      ICX_Client360_API_Helper.WrapperLabelValueList currentCallingCampaignsListWrapper = new ICX_Client360_API_Helper.WrapperLabelValueList();

      currentCallingCampaignsListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'itemNumber',
          myCallingCampaign.Name,
          'text-top'
        )
      );
      currentCallingCampaignsListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Product Name',
          myCallingCampaign.Product_Name__c,
          'text'
        )
      );
      currentCallingCampaignsListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Status',
          myCallingCampaign.Status__c,
          'text-status'
        )
      );

      currentCallingCampaignsListWrapper.Id = string.valueOf(myCallingCampaign.Id);

      callingCampaignsListWrapper.add(currentCallingCampaignsListWrapper);

      counter++;
    }

    return callingCampaignsListWrapper;
  }

  @AuraEnabled(cacheable=true)
  public static List<ICX_Client360_API_Helper.WrapperLabelValueList> getFamilies(Id accountId) {
    List<Family_Member__c> myListFamilies = [
      SELECT Id, Family__r.Name, Duplicate_Type__c, Family__r.Status__c
      FROM Family_Member__c
      WHERE Client__c = :accountId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.debug('myListFamilies' + myListFamilies);

    List<ICX_Client360_API_Helper.WrapperLabelValueList> familiesListWrapper = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();
    for (Family_Member__c myFamily : myListFamilies) {
      ICX_Client360_API_Helper.WrapperLabelValueList currentFamiliesListWrapper = new ICX_Client360_API_Helper.WrapperLabelValueList();

      currentFamiliesListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'itemNumber',
          myFamily.Family__r.Name,
          'text-top'
        )
      );
      currentFamiliesListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Duplicate Type',
          myFamily.Duplicate_Type__c,
          'text'
        )
      );
      currentFamiliesListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Status',
          myFamily.Family__r.Status__c,
          'text'
        )
      );

      currentFamiliesListWrapper.Id = string.valueOf(myFamily.Id);

      familiesListWrapper.add(currentFamiliesListWrapper);
    }

    return familiesListWrapper;
  }

  @AuraEnabled(cacheable=true)
  public static List<ICX_Client360_API_Helper.OrderWrapper> getOrders(
    Id accountId,
    Integer pageSize,
    Integer pageIndex
  ) {
    system.debug(' in get order  ' + pageSize + '  ' + pageIndex + ' ' + accountId);
Date threeMonthAgo = (Date.Today()).addMonths(-3);

    List<OrderLine__c> myListOrders = [
      SELECT
        Id,
        Order__c,
        Order__r.Id,
        Order__r.OrderDate__c,
        Order__r.OrderNumber__c,
        SKU__c,
        Order__r.Store__r.Name,
        Order__r.Store__r.RetailStoreId__c,
        OrderShipping__r.Status__c,
        ProductReferential__r.SPO_ImageLink1FrontView__c,
        Order__r.Store__r.StoreType__c
      FROM OrderLine__c
      WHERE
        Order__r.Account__c = :accountId
        AND ((OrderShipping__r.status__c = 'Fulfilled'
        AND OrderShipping__r.StatusDate__c <= THIS_WEEK
        AND OrderShipping__r.StatusDate__c >=: threeMonthAgo)
        OR OrderShipping__r.status__c != 'Fulfilled')
      ORDER BY CreatedDate DESC
      LIMIT :pageSize
      OFFSET :pageIndex
    ];

    List<ICX_Client360_API_Helper.OrderWrapper> orderList = new List<ICX_Client360_API_Helper.OrderWrapper>();
    System.debug('myListOrders' + myListOrders);

    // String imagePlaceholder = imagesResource+'/images/imgUndefinedLV.png';
    for (OrderLine__c orderLine : myListOrders) {
      System.debug('orderLine' + orderLine);

      ICX_Client360_API_Helper.OrderWrapper orderWrapper = new ICX_Client360_API_Helper.OrderWrapper();
      orderWrapper.Id = orderLine.Order__r.Id;
      orderWrapper.orderDate = orderLine.Order__r?.OrderDate__c;
      orderWrapper.orderNumber = orderLine.Order__r?.OrderNumber__c;
      orderWrapper.sku = orderLine.SKU__c;
      orderWrapper.storeName = orderLine.Order__r?.Store__r?.Name;
      orderWrapper.retailStoreId = orderLine.Order__r?.Store__r?.RetailStoreId__c;
      orderWrapper.status = orderLine.OrderShipping__r?.Status__c;
      orderWrapper.productImage = orderLine.ProductReferential__r?.SPO_ImageLink1FrontView__c;
      orderWrapper.type = orderLine.Order__r?.Store__r?.StoreType__c;

      // orderWrapper.productImage = 'https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis-vuitton--LP0001_PM2_Front%20view.jpg';

      orderList.add(orderWrapper);
    }

    System.debug('orderList' + orderList);
    return orderList;
  }

  @AuraEnabled(cacheable=true)
  public static List<ICX_Client360_API_Helper.WrapperLabelValueList> getCareServiceRecords(
    Id accountId,
    Integer myLimit,
    Integer myOffset,
    String type
  ) {
    system.debug('The Offset' + myOffset);
    system.debug('The Limit' + myLimit);
    Id CareServicerRecordTypeId;
    String query = 'SELECT Id, name, transactionId__c, createdDate__c,myRepairStatus__c, sku__c, product_Name__c,product_Image__c,ICONiCS_Status__c,ICONiCS_Status_Detail__c,RecordType.DeveloperName FROM CareService__c where client__c = : accountId';

    if (type == 'Distant') {
      CareServicerRecordTypeId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();
      System.debug('Now is the Distant record type id' + CareServicerRecordTypeId);
      query += ' AND RecordTypeId=: CareServicerRecordTypeId ';
    } else if (type == 'Store') {
      CareServicerRecordTypeId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();
      System.debug('Now is the Store record type id' + CareServicerRecordTypeId);
      query += ' AND RecordTypeId=: CareServicerRecordTypeId ';
    }

    query += ' ORDER BY CreatedDate DESC ';
    query += ' LIMIT:myLimit OFFSET:myOffset';

    List<CareService__c> myListDistantCareService = (List<CareService__c>) Database.query(query);

    System.debug(' myListDistantCareService' + myListDistantCareService);

    List<ICX_Client360_API_Helper.WrapperLabelValueList> careServiceListWrapper = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();
    for (CareService__c myCareService : myListDistantCareService) {
      ICX_Client360_API_Helper.WrapperLabelValueList currentCareServiceListWrapper = new ICX_Client360_API_Helper.WrapperLabelValueList();

      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'itemNumber',
          myCareService.Name,
          'text-top'
        )
      );
      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Type',
          myCareService.RecordType.DeveloperName == 'DistantCareService' ? 'DISTANT' : 'STORE',
          type == 'ALL' ? 'text' : 'text-hide'
        )
      );

      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Repair Number',
          myCareService.TransactionId__c,
          'text'
        )
      );
      // currentCareServiceListWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Deposit Date', myCareService.CreatedDate__c!=null?myCareService.CreatedDate__c.format():'','text'));
      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          myCareService.RecordType.DeveloperName == 'DistantCareService'
            ? 'ICONiCS Status Detail'
            : 'MyRepair Status',
          myCareService.RecordType.DeveloperName == 'DistantCareService'
            ? myCareService.ICONiCS_Status_Detail__c
            : myCareService.MyRepairStatus__c,
          'text-status'
        )
      );

      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value('SKU', myCareService.SKU__c, 'text')
      );
      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'Product Name',
          myCareService.Product_Name__c,
          'text'
        )
      );
      currentCareServiceListWrapper.item.add(
        ICX_Client360_API_Helper.Create_WrapperLabel_Value(
          'productImage',
          myCareService.Product_Image__c,
          'image-html'
        )
      );

      currentCareServiceListWrapper.Id = string.ValueOf(myCareService.Id);

      careServiceListWrapper.add(currentCareServiceListWrapper);
    }

    return careServiceListWrapper;
  }


  public class SObJectResult {
    @AuraEnabled
    public String recName;
    @AuraEnabled
    public Id recId;

    public SObJectResult(String recNameTemp, Id recIdTemp) {
      recName = recNameTemp;
      recId = recIdTemp;
    }
  }

  //futur use ?
  // @AuraEnabled(cacheable=true)
  // public static List<ICX_Client360_API_Helper.WrapperLabelValueList> getSurveys(Id accountId)
  // {
  //     List<VO_Survey__c> mySurveysList = [SELECT Name,
  //                                                ClientDreamID__c,
  //                                                AnswerDate__c,
  //                                                Store__r.Name,
  //                                                TransactionProductCategoryCode__c,
  //                                                Scoring__c
  //                                     FROM VO_Survey__c
  //                                     WHERE ClientDreamID__c = : accountId];

  //     System.debug('mySurveysList'+ mySurveysList);

  //     List<ICX_Client360_API_Helper.WrapperLabelValueList> surveyListWrapper = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();

  //     integer counter = 0;
  //     for(VO_Survey__c mySurvey : mySurveysList)
  //     {
  //         ICX_Client360_API_Helper.WrapperLabelValueList myCurrentSurveyWrapper = new ICX_Client360_API_Helper.WrapperLabelValueList();

  //         myCurrentSurveyWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Survey Number',mySurvey.Name,'text-top'));
  //         myCurrentSurveyWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Store',mySurvey.Store__r.Name,'text'));
  //         myCurrentSurveyWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Answer Date',mySurvey.AnswerDate__c!=null?mySurvey.AnswerDate__c.format():'','text'));
  //         myCurrentSurveyWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Product Name',mySurvey.TransactionProductCategoryCode__c,'text'));
  //         myCurrentSurveyWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Scoring',mySurvey.Scoring__c,'text'));

  //         myCurrentSurveyWrapper.Id = string.ValueOf(mySurvey.Id);

  //         surveyListWrapper.add(myCurrentSurveyWrapper);

  //         counter++;
  //     }

  //     return surveyListWrapper;
  // }

  @AuraEnabled(cacheable=true)
  public static List<Interests__c> getTags(Id accountId) {
    List<Interests__c> myTagsList = [
      SELECT Categories__c, Client__c, source__c, CreatedDate
      FROM Interests__c
      WHERE Client__c = :accountId AND source__c != NULL
      LIMIT 3
    ];
    System.debug('The tags info' + myTagsList);
    return myTagsList;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, Boolean> getAuthorizationProfiles(Id userId, String objectName) {
    List<Id> listPermissionSetAssignmentId = new List<Id>();

    for (PermissionSetAssignment currentPermissionSetAssignment : [
      SELECT PermissionSetId
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId
    ]) {
      listPermissionSetAssignmentId.add(currentPermissionSetAssignment.PermissionSetId);
    }

    List<ObjectPermissions> permissionList = [
      SELECT
        Id,
        PermissionsModifyAllRecords,
        PermissionsViewAllRecords,
        PermissionsEdit,
        PermissionsDelete,
        PermissionsCreate,
        SobjectType,
        ParentId,
        Parent.Label,
        Parent.Profile.Name,
        Parent.ProfileId
      FROM ObjectPermissions
      WHERE ParentID IN :listPermissionSetAssignmentId AND SobjectType = :objectName
    ];

    Map<String, Boolean> permissionMap = new Map<String, Boolean>();

    for (ObjectPermissions currentObjectPermissions : permissionList) {
      permissionMap.put(
        'PermissionsEdit',
        permissionMap.containsKey('PermissionsEdit') && permissionMap.get('PermissionsEdit')
          ? permissionMap.get('PermissionsEdit')
          : currentObjectPermissions.PermissionsEdit
      );
      permissionMap.put(
        'PermissionsDelete',
        permissionMap.containsKey('PermissionsDelete') && permissionMap.get('PermissionsDelete')
          ? permissionMap.get('PermissionsEdit')
          : currentObjectPermissions.PermissionsDelete
      );
      permissionMap.put(
        'PermissionsCreate',
        permissionMap.containsKey('PermissionsCreate') && permissionMap.get('PermissionsCreate')
          ? permissionMap.get('PermissionsCreate')
          : currentObjectPermissions.PermissionsCreate
      );
      permissionMap.put(
        'PermissionsViewAllRecords',
        permissionMap.containsKey('PermissionsViewAllRecords') &&
          permissionMap.get('PermissionsViewAllRecords')
          ? permissionMap.get('PermissionsViewAllRecords')
          : currentObjectPermissions.PermissionsViewAllRecords
      );
      permissionMap.put(
        'PermissionsModifyAllRecords',
        permissionMap.containsKey('PermissionsModifyAllRecords') &&
          permissionMap.get('PermissionsModifyAllRecords')
          ? permissionMap.get('PermissionsModifyAllRecords')
          : currentObjectPermissions.PermissionsModifyAllRecords
      );
    }

    return permissionMap;
  }

  @AuraEnabled(cacheable=true)
  public static Id getUserProfileId(ID userId) {
    return [SELECT Id, ProfileId FROM User WHERE Id = :userId].ProfileId;
  }

  @AuraEnabled(cacheable=true)
  public static ICX_Client360_API_Helper.accountWrapper getContact(Id accountId) {
    Account result = [
      SELECT
        toLabel(Salutation),
        Gender_IMG__pc,
        Name,
        FirstName,
        LastName,
        Firstname2__pc,
        Lastname2__pc,
        PersonBirthdate,
        Birthday_Cake_IMG__c,
        PersonMobilePhone,
        PersonHomePhone,
        Phone,
        PrimaryAddressCompacted__pc,
        PersonEmail,
        LocalMobilePhone__pc,
        LocalHomePhone__pc,
        LocalWorkPhone__pc,
        HomeAddressCountryCode__pc,
        PrimaryAddress__pc,
        Can_Be_Contacted_By_Email__pc,
        Can_Be_Contacted_By_Mail__pc,
        Can_Be_Contacted_By_Phone__pc,
        Can_Be_Contacted_By_SMS__pc,
        PreferredLanguage__pc,
        Language_IMG__pc,
        Segmentation_To_Display__c,
        indic10KImg__c,
        DREAMID__c,
        Age_Calculator__c,
        Segmentation__pc,
        Sub_Segment__c,
        Store__pc,
        Store__pr.Name,
        Store__pr.StoreType__c,
        Store__pr.RetailStoreId__c,
        OwnerId,
        Owner.Name,
        FirstTrans__pc,
        LastTrans__pc,
        LastContactDate__pc,
        Typology__pc,
        Id,
        Parallel_Market_IMG__c,
        RMSId__pc,
        NationalityCountryCode__pc,
        AttachedStore__pc,
        Status_RMSID__c,
        Error_RMSID__c,
        Purchaser__pc,
        TypologyCode__pc,
        PrimaryCity__pc,
        Subscribed_to_Digital_Concierge__c,
        Date_Identity__pc,
        ParallelMarket_Status__pc,
        ParallelMarket_StatusDate__pc
      FROM Account
      WHERE Id = :accountId
    ];

    ICX_Client360_API_Helper.accountWrapper contact = new ICX_Client360_API_Helper.accountWrapper();
    contact.salutation = result.Salutation;
    contact.Gender_IMG = result.Gender_IMG__pc;
    contact.firstName = result.FirstName;
    contact.lastName = result.lastName;
    contact.firstName2 = result.Firstname2__pc;
    contact.lastName2 = result.Lastname2__pc;
    contact.name = result.Name;
    contact.birthdate = result.PersonBirthdate != null ? result.PersonBirthdate.format() : '';
    contact.Birthday_Cake_IMG = result.Birthday_Cake_IMG__c;
    contact.age = String.valueOf(result.Age_Calculator__c);
    contact.PersonMobilePhone = result.PersonMobilePhone;
    contact.PersonHomePhone = result.PersonHomePhone;
    contact.Phone = result.Phone;
    contact.email = result.PersonEmail;
    contact.address = result.PrimaryAddress__pc != null
      ? result.PrimaryAddress__pc.replace('<br>', '')
      : null;
    contact.country = result.HomeAddressCountryCode__pc;
    contact.Can_Be_Contacted_By_Email = result.Can_Be_Contacted_By_Email__pc;
    contact.Can_Be_Contacted_By_Phone = result.Can_Be_Contacted_By_Phone__pc;
    contact.Can_Be_Contacted_By_SMS = result.Can_Be_Contacted_By_SMS__pc;
    contact.Can_Be_Contacted_By_Address = result.Can_Be_Contacted_By_Mail__pc;
    contact.Prefered_Language = result.PreferredLanguage__pc;
    contact.Language_IMG = result.Language_IMG__pc;
    contact.segmentationClient = result.Segmentation_To_Display__c;
    contact.displayedSegment  = result.Sub_Segment__c;
    contact.indic10KImg = result.indic10KImg__c;
    contact.dreamID = result.DREAMID__c;
    contact.StoreID = result.Store__pc;
    contact.StoreName = result.Store__pr.Name;
    contact.StoreRetailID = result.Store__pr.RetailStoreId__c;
    contact.OwnerName = result.Owner.Name;
    contact.OwnerID = result.OwnerId;
    contact.firstPurchaseDate = result.FirstTrans__pc != null ? result.FirstTrans__pc.format() : '';
    contact.lastPurchaseDate = result.LastTrans__pc != null ? result.LastTrans__pc.format() : '';
    contact.lastContact = result.LastContactDate__pc != null
      ? result.LastContactDate__pc.format()
      : '';
    contact.Parallel_Market_IMG = result.Parallel_Market_IMG__c;
    contact.greyMarketStatus = result.ParallelMarket_Status__pc;
    contact.greyMarketStatusDate = String.valueOF(result.ParallelMarket_StatusDate__pc);
    contact.Subscribed_to_Digital_Concierge = result.Subscribed_to_Digital_Concierge__c;

    // contact.isUserIdentity = result.Date_Identity__pc!=null?true:false;

    User userIdentity = IsIdentityUser(result.Id);
    contact.userId =  userIdentity != null ? userIdentity.id : null;
    contact.isUserIdentity = userIdentity != null ? true : false;
    contact.hasdateIdentity =  result.Date_Identity__pc!=null?true:false;
    contact.isActiveUser =  userIdentity != null ? userIdentity.IsActive : false;
    //contact.emailUser =  result.Date_Identity__pc!=null?userIdentity.email:null; 

    if (userIdentity != null /*&& userIdentity.isActive == true*/) {
      String str = '';
      if (userIdentity.TECH_Email__c != null) {
        contact.myLVemail = userIdentity.TECH_Email__c;
      } else {
        contact.myLVemail = userIdentity.Email;
      }
      if (userIdentity.TECH_Email__c != null && userIdentity.TECH_MobilePhone__c != null) {
        if (
          !userIdentity.TECH_Email__c.contains(System.Label.ICX_Identity_Username_Suffix) &&
          userIdentity.TECH_Email__c.contains(userIdentity.TECH_MobilePhone__c)
        )
          str += userIdentity.TECH_Email__c + ' ';
      }

      if (userIdentity.TECH_MobilePhone__c != null) {
        str += userIdentity.TECH_MobilePhone__c + ' | ';
      }
      if (userIdentity.IsActive == true) {
        str += ' Active ';
      } else {
        str += ' Inactive ';
      }
      if (userIdentity.LastLoginDate != null) {
        str += 'Last Login: ' + userIdentity.LastLoginDate.format('MMM yyyy');
        contact.lastActivityDate = userIdentity.LastLoginDate.format('MMM yyyy');
      }

      contact.lastActivity = str;
    }

    system.debug(' contact : ' + contact);

    return contact;
  }

  @AuraEnabled(cacheable=true)
  public static ICX_Client360_API_Helper.WrapperLabelValueList getKeyInformation(Id accountId) {
    Account result = [
      SELECT
        Typology__pc,
        Nationality__pc,
        PersonBirthdate,
        Gender__pc,
        PersonEmail,
        PersonMobilePhone,
        PrimaryAddress__pc,
        PrimaryCountry__pc
      FROM Account
      WHERE Id = :accountId
    ];

    ICX_Client360_API_Helper.WrapperLabelValueList clientKeyInfoWrapper = new ICX_Client360_API_Helper.WrapperLabelValueList();
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value('Typology', result.Typology__pc, 'text')
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value(
        'Nationality/Passport',
        result.Nationality__pc,
        'text'
      )
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value(
        'Birthdate',
        result.PersonBirthdate != null ? result.PersonBirthdate.format() : '',
        'text'
      )
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value('Gender', result.Gender__pc, 'text')
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value('Email', result.PersonEmail, 'text')
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value(
        'Mobile Phone',
        result.PersonMobilePhone,
        'phone'
      )
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value(
        'Address',
        result.PrimaryAddress__pc != null ? result.PrimaryAddress__pc.replace('<br>', ' ') : null,
        'text'
      )
    );
    clientKeyInfoWrapper.item.add(
      ICX_Client360_API_Helper.Create_WrapperLabel_Value(
        'Country/Region',
        result.PrimaryCountry__pc,
        'text'
      )
    );

    clientKeyInfoWrapper.Id = '0';

    return clientKeyInfoWrapper;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getCountry() {
    Map<String, String> countryCodeMap = new Map<String, String>();
    for (CountryMapping__mdt currentPickList : [
      SELECT Picklist__c, Iso3Code__c
      FROM CountryMapping__mdt
      WHERE Picklist__c != NULL AND Iso3Code__c != NULL
    ]) {
      countryCodeMap.put(currentPickList.Picklist__c, currentPickList.Iso3Code__c);
    }

    return countryCodeMap;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getStore() {
    Map<String, String> storeCodeMap = new Map<String, String>();
    for (Store__c currentpicklist : [
      SELECT Name, RetailStoreId__c
      FROM Store__c
      WHERE Name != NULL AND RetailStoreId__c != NULL
    ]) {
      storeCodeMap.put(currentpicklist.Name, currentpicklist.RetailStoreId__c);
    }
    return storeCodeMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<Decimal> getPhoneCode() {
    List<Decimal> phoneCodeList = new List<Decimal>();
    for (CountryMapping__mdt currentCode : [
      SELECT Calling_Code__c
      FROM CountryMapping__mdt
    ]) {
      phoneCodeList.add(currentCode.Calling_Code__c);
    }
    return phoneCodeList;
  }

  @AuraEnabled(cacheable=true)
  public static Id getPurchasedProductId(String transactionNumber) {
    system.debug(' purchased product transaction number :' + transactionNumber);
    return [
      SELECT Id
      FROM PPR_PurchProduct__c
      WHERE TechTransactionId__c = :transactionNumber
      LIMIT 1
    ]
    ?.Id;
  }
  @AuraEnabled(cacheable=true)
  public static String getDreamID(String accountId) {
    return [SELECT Id, DREAMID__c FROM Account WHERE Id = :accountId LIMIT 1]?.DREAMID__c;
  }
  @AuraEnabled(cacheable=true)
  public static String getContactId(String accountId) {
    return [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ]
    ?.PersonContactId;
  }

  @AuraEnabled(cacheable=true)
  public static Account getAccount(String accountId) {
    return [SELECT Id, DREAMID__c FROM Account WHERE Id = :accountId LIMIT 1];
  }

  @AuraEnabled(cacheable=true)
  public static User IsIdentityUser(String recordId) {
    User IdentityUser;
    system.debug(recordId);
    if (String.isNotBlank(recordId)) {
      list<user> ListIdentityUser = [
        SELECT Id, IsActive, LastLoginDate, TECH_Email__c, TECH_MobilePhone__c, Email
        FROM User
        WHERE AccountId = :recordId
        LIMIT 1
      ];
      IdentityUser = (ListIdentityUser.isEmpty() ? null : ListIdentityUser.get(0));
    }
    return IdentityUser;
  }

  @AuraEnabled(cacheable=false)
  public static Export_Purchases_Tracability__c getExportTracabilty(string dreamId) {
    system.debug('getExportTracabilty dreamId' + dreamId);


    // Query for the related Export_Purchases_Tracability__c record
    List<Export_Purchases_Tracability__c> records = [
      SELECT Id, DreamId__c, Status__c, Public_File_Link__c, API_Error_Message__c
      FROM Export_Purchases_Tracability__c
      WHERE DreamId__c = :dreamId
      ORDER BY CreatedDate DESC
    ];

    system.debug('records' + records);
    if (!records.isEmpty() && records.size() > 0) {
      system.debug('records' + records[0]);
      system.debug('records' + records[0].Status__c);
      return records[0];
    } else {
      return null;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<ICX_Client360_API_Helper.SurveyWrapper> getSurvey(  
    Id accountId,
    Integer pageSize,
    Integer pageIndex
  ){
    String newAccountId = string.valueOf(accountId);
    String clientId = string.valueOf(newAccountId.substring(0,newAccountId.length()-3));
    system.debug('getSurvey parameters  ' + pageSize + '  ' + pageIndex + ' ' + accountId);
    List<VO_Survey__c> myListSurveys = [SELECT id, 
                                          CreatedDate,
                                          SurveyType__c,
                                          GlobalScore__c, 
                                          CAName__c,
                                          CAScore__c, 
                                          Store__c, 
                                          Solved__c 
                                   FROM VO_Survey__c 
                                   WHERE ClientSFID__c =: clientId 
                                   AND SurveyType__c != 'Retail Post Aftersales'
                                   ORDER BY CreatedDate DESC
                                   LIMIT :pageSize
                                   OFFSET :pageIndex
                                   ];
                                   
    System.debug('getSurvey myListSurveys' + myListSurveys);

    List<ICX_Client360_API_Helper.SurveyWrapper> surveyList = new List<ICX_Client360_API_Helper.SurveyWrapper>();
    
    for (VO_Survey__c survey : myListSurveys) {

      ICX_Client360_API_Helper.SurveyWrapper surveyWrapper = new ICX_Client360_API_Helper.SurveyWrapper();
      surveyWrapper.id = survey.Id;
      surveyWrapper.createdDate = survey.CreatedDate.format('MMM dd yyyy');
      surveyWrapper.surveyType = survey.SurveyType__c;
      surveyWrapper.CAScore = survey.CAScore__c;
      surveyWrapper.globalScore = survey.GlobalScore__c;
      surveyWrapper.status = survey.Solved__c == true ? 'Resolved' : 'Pending';

      surveyList.add(surveyWrapper);
    }

    System.debug('getSurvey surveyList' + surveyList);
    return surveyList;
  }


  @AuraEnabled(cacheable=true)
  public static List<ICX_Client360_API_Helper.SurveyWrapper> getSurveyListView(  
    Id userId,
    Integer pageSize,
    Integer pageIndex,
    Boolean isManager,
    Boolean isDigital,
    Boolean isMySurveys
    ){

    system.debug('getSurvey parameters  '+pageSize+' '+pageIndex+' '+userId+' '+isManager+' '+isDigital+' ');

    List<VO_Survey__c> myListSurveys = new List<VO_Survey__c>();
    Set<string> myTeamWWEmployeeNumber = new Set<string>();
    // Set<string> myTeamDigital = new Set<string>();

    // Id myUserRoleId = UserInfo.getUserRoleId();
    List<User> myUserInfos = [SELECT Id, UserRoleId, UserRole.Name, WWEmployeeNumber__c 
                              FROM User 
                              WHERE Id = :userId 
                              LIMIT 1];

    Id myUserRoleId = myUserInfos[0]?.UserRoleId;
    String myWWEmployeeNumber = myUserInfos[0]?.WWEmployeeNumber__c;
    String myUserRoleName = myUserInfos[0]?.UserRole.Name;

   
    // List<User> myListUserTeamDigital = [SELECT Id, WWEmployeeNumber__c FROM User WHERE UserRoleId =: myUserRoleId];
    // for(user WWemployeeNumber : myListUserTeamDigital) {
    //   if(WWemployeeNumber.WWEmployeeNumber__c != null){
    //     myTeamDigital.add(WWemployeeNumber.WWEmployeeNumber__c);
    //   }
    // }

    // system.debug('myListUserTeamDigital : '+myListUserTeamDigital);


    
    if(isManager) {
      List<User> myTeam = [SELECT Id, WWEmployeeNumber__c FROM User WHERE UserRole.ParentRoleId =: myUserRoleId ];

      for(user WWemployeeNumber : myTeam) {
          if(WWemployeeNumber.WWEmployeeNumber__c != null){
            myTeamWWEmployeeNumber.add(WWemployeeNumber.WWEmployeeNumber__c);
          }
        }
    }

    if(isDigital) {
      
      String query = 'SELECT id, CreatedDate,SurveyType__c,ClientDreamID__r.Name,ClientDreamID__r.Segmentation__c,' +
        'GlobalScore__c,  CAName__c, CAScore__c, Store__c, AdvisorWWId__c, AdvisorCSRole__c, Solved__c FROM VO_Survey__c WHERE ';
        
        if(isManager) query += ' AdvisorWWId__c IN :myTeamWWEmployeeNumber ';
  
        // else if() query+= ' AdvisorWWId__c IN :myTeamDigital ';

        else query+= ' AdvisorCSRole__c = :myUserRoleName ';

        query += 'AND ( SurveyType__c = \'ONLINE POST DELIVERY\'  OR  SurveyType__c = \'ONLINE POST PAYMENT\') ' + 
        ' ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :pageIndex';

        myListSurveys = Database.query(query);

    } else {

        String query = 'SELECT id, CreatedDate,SurveyType__c,ClientDreamID__r.Name,ClientDreamID__r.Segmentation__c,' +
        'GlobalScore__c,  CAName__c, CAScore__c, Store__c, AdvisorWWId__c, Solved__c FROM VO_Survey__c WHERE AdvisorWWId__c ';

        if(isManager) {
          if(isMySurveys) query += '  = :myWWEmployeeNumber ';
          else query +=' IN :myTeamWWEmployeeNumber ';
        }
        else query += ' =:myWWEmployeeNumber ';

        query += ' AND SurveyType__c = \'CSC POST CONTACT\'  ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :pageIndex';
        
        myListSurveys = Database.query(query);

    }

    Map<String,String> advisorCSRole = new Map<String,String>();
  
    List<string> listAdvisorId = new List<string>();
    for(VO_Survey__c survey : myListSurveys) {
      if(survey.AdvisorWWId__c != null )listAdvisorId.add(survey.AdvisorWWId__c);
    }

    List<User> listUserRoles = [SELECT id, Name, UserRole.Name, WWEmployeeNumber__c  
                            FROM User
                            WHERE WWEmployeeNumber__c IN :listAdvisorId]; 
                    
    for(User usRole :listUserRoles) {
      advisorCSRole.put( usRole.WWEmployeeNumber__c , usRole.UserRole.Name);
    }

                                  
    List<ICX_Client360_API_Helper.SurveyWrapper> surveyList = new List<ICX_Client360_API_Helper.SurveyWrapper>();
    
    for (VO_Survey__c survey : myListSurveys) {

      ICX_Client360_API_Helper.SurveyWrapper surveyWrapper = new ICX_Client360_API_Helper.SurveyWrapper();
      
      surveyWrapper.id = survey.Id;
      surveyWrapper.createdDate = survey.CreatedDate.format('MMM dd yyyy');
      surveyWrapper.surveyType = survey.SurveyType__c;
      surveyWrapper.clientName = survey.ClientDreamID__r?.Name;
      surveyWrapper.segmentation = survey.ClientDreamID__r?.Segmentation__c;
      surveyWrapper.globalScore = survey.GlobalScore__c;
      surveyWrapper.status = survey.Solved__c == true ? 'Resolved' : 'Pending';
      if(isDigital){ 
        // surveyWrapper.advisorCSRole = advisorCSRole.get(survey.AdvisorWWId__c);
        surveyWrapper.advisorCSRole = survey.AdvisorCSRole__c != null ? survey.AdvisorCSRole__c : advisorCSRole.get(survey.AdvisorWWId__c);
      }
      else { 
        surveyWrapper.CAName = survey.CAName__c;
      }
      surveyWrapper.CAScore = survey.CAScore__c;

      surveyList.add(surveyWrapper);
    }

    return surveyList;
  }

  // Get MutiMatch accountId => ContactId 
  @AuraEnabled(cacheable=true)
  public static List<Account> getMultiMatch(Id recordId) {
    String objectName = recordId.getSObjectType().getDescribe().getName();

    List<Account> accountList = new List<Account>{};

    if ('Case'.equalsIgnoreCase(objectName)) {
      case req = [SELECT Id, SuppliedEmail FROM Case WHERE Id = :recordId];

      if(String.IsNotBlank(req.SuppliedEmail)){
        for(Account a : [SELECT Id, Name, PersonContactId, CreatedDate, LastModifiedDate, Segmentation__c, TECHPreferredCA__c  
                FROM Account WHERE PersonEmail = :req.SuppliedEmail AND (NOT name LIKE 'anonymize%') LIMIT 100])
        {        
          accountList.add(a);
        }
      }
    }
    else if ('Task'.equalsIgnoreCase(objectName)){
      Task t = [SELECT Id, InOut__c, LVM_SFDCAccountIds__c, LVM_SFDCAccounts_Identify__c, Phone_Calling_Number__c, 
                Phone_Number__c FROM Task WHERE Id = :recordId];
      String accountIds = t.LVM_SFDCAccountIds__c;
      String direction = t.InOut__c;
      String phoneNumber = t.Phone_Calling_Number__c;

      Boolean outCond = String.IsNotBlank(phoneNumber) && direction == 'Out';
      Boolean inCond = String.IsNotBlank(accountIds) && String.IsNotBlank (phoneNumber) && direction == 'In' && accountIds.startsWith('!!!');
      Boolean updateTaskCond = String.IsNotBlank(recordId) && (inCond || outCond);
      Boolean splitCondAlt = String.IsNotBlank(accountIds) && (! accountIds.startsWith('!!!'));

      //if(inCond || outCond){
        for(Account a : [SELECT Id, Name, PersonContactId, CreatedDate, LastModifiedDate, Segmentation__c, TECHPreferredCA__c  
                          FROM Account WHERE (Phone = :phoneNumber OR PersonMobilePhone = :phoneNumber 
                          OR PersonHomePhone = :phoneNumber) AND (NOT name LIKE 'anonymize%') LIMIT 100])
        {        
          accountList.add(a);
        }
      //}
    }   
    return accountList;
  }

  @AuraEnabled(cacheable=false)
  public static String updateClient(String accountId, String contactId, String recordId, String objectName) {
    if(objectName == 'Case'){
      Case c = new Case(
        Id = recordId,
        AccountId = accountId,
        ContactId = contactId
      );
      update c;
      return c.Id;
    }
     
       if(objectName == 'Task'){
        Task t = new Task(
          Id = recordId,
          WhatId = accountId
         //  WhatId = contactId
        );
        update t;
        return t.Id ;
      }


    return null;
  }

  @AuraEnabled(cacheable=true)
  public static List<Map<String,String>>  getStylingSF(Id accountId, Integer pageSize, Integer pageIndex){

    List<Task> myListStyling = [SELECT Id,
                                       Subject, 
                                       LookId_IW__c, 
                                       AccountId, 
                                       Validity_Date_IW__c, 
                                       OwnerId, 
                                       Preview_URL_IW__c, 
                                       Owner.Name, 
                                       CreatedDate, 
                                       ActivityDate, 
                                       LastModifiedDate, 
                                       IsWardrobing__c, 
                                       Type 
                                FROM Task 
                                WHERE LookId_IW__c != null AND IsWardrobing__c = true AND AccountId = : accountId 
                                ORDER BY CreatedDate DESC 
                                LIMIT :pageSize
     							              OFFSET :pageIndex
                                ];

    List<Map<String,String>> myListStylingMap = new List<Map<String,String>>();

    for(Task myStyle : myListStyling) {
      Map<String, String> myStyleMap = new Map<String, String>{
        'name' => myStyle.Subject,
        'ownerName' => myStyle.Owner.Name,
        'createdDate' => myStyle.CreatedDate.format('MMM dd yyyy'),
        'nature' => myStyle.Type,
        'imgSrc' => myStyle.Preview_URL_IW__c,
        'id' => myStyle.LookId_IW__c
      };
      myListStylingMap.add(myStyleMap);
    }
    return myListStylingMap;
  }

  @AuraEnabled(cacheable=true)
  public static  Map<String, Object>  getStylingLinkAzure(String wardrobingId, String accountId){
    Map<String, Object> myLink = new Map<String, Object>();    
    try {
     myLink =  ICX_WS_Styling.getStylingLink(wardrobingId, accountId);
    } catch (Exception e) {
      System.debug('thrown an error: '+e);
    }
    return myLink;
  }


  @AuraEnabled(cacheable=true)
  public static List<Fraud_Comment__c> getRelatedComments(Id parentRecordId) {
      return [
          SELECT Id, Comment__c, TechOwnerName__c, Client__c, Reason__c, CreatedDate
          FROM Fraud_Comment__c
          WHERE Client__c = :parentRecordId
          ORDER BY CreatedDate DESC
      ];
  }
    
}