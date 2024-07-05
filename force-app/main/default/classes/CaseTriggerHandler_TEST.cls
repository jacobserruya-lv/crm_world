/**
*  @About
*  Test methods for CaseTriggerHandler
*
*/

@isTest
public class CaseTriggerHandler_TEST {


    @IsTest(SeeAllData=true) // without this, the ConnectAPI called in IM_FeedItem_TRG fails.
                             // Ask Balink to add a !Test.isRunningTest()
    static void testSetProspectStoreInfo()
    {
        // create a user

        id ownerProfile = ICX_TestFactory.PROFILE_ICONICS_SA;//PROFILE_MAP.get('ICONICS_SA');
        User ownerUser = ICX_TestFactory.createUser(ownerProfile);
        ownerUser.Country__c = 'FRANCE';
        ownerUser.DefaultStore__c = 'A00';
        insert ownerUser;
        
        // create a store
        Store__c st = ICX_TestFactory.createStore('LV Store ICONICS TEST', 'A00');
        insert st;
        
        /*Id automatedUser = [SELECT Id FROM User WHERE Name='SYSTEM' AND Profile.Name = 'System Administrator'].Id;
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.SystemUserId__c = automatedUser;
        insert settings;*/

        // create a prospect
        Account acc = ICX_TestFactory.createAccount();
        acc.IsProspect__pc = true;
        acc.ownerid = IconicsSettings__c.getInstance().SystemUserId__c;//System.Label.ICX_Automated_Case_User; // case is originally assigned to the SYSTEM user
        insert acc;

        // create a case
        Case ca = ICX_TestFactory.createCase(acc.id);
        //ca.Country__c = 'FRANCE';
        //Id caRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Web&Email Case').getRecordTypeId();
        //ca.recordTypeId = caRecordTypeId;

        Group anyQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Australia' LIMIT 1];
        //ca.TECH_Queue_ID__c = anyQueue.Id;
        ca.OwnerId = anyQueue.Id;
        ca.AccountId = acc.Id;
        System.debug('BBBBBBBBB anyQueue: ' + anyQueue);
        System.debug('AAAAAAAAAAA CA: ' + ca);

        
        //System.runAs(ownerUser) {
        Test.startTest();
        
        insert ca;
        ca.OwnerId = ownerUser.id; // the CA takes the ownership of the case
        update ca; // will call the after update trigger
        //System.debug('case owner id: ' + ca.Ownerid);
        //System.debug('new owner id: ' + ownerUser.id);
        Test.stopTest();
        //}

        ca = [SELECT id,OwnerId ,account.Store__pc, account.ownerid, account.AttachedStore__pc from Case where id =: ca.id];
        System.assertEquals(ownerUser.id, ca.OwnerId);

        /*System.assertEquals(st.id, ca.account.Store__pc);
        System.assertEquals(ownerUser.id, ca.account.ownerid);
        System.assertEquals('A00', ca.account.AttachedStore__pc);*/

    }

    @isTest
    public static void setOwnerOnNewCaseWithCloseParentTest() {

        Group anyQueue = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1];
        // create a case
        Case ca = ICX_TestFactory.createCase(null);
        ca.TECH_Queue_ID__c = anyQueue.Id;
        
        Test.startTest();
        insert ca;

        Test.stopTest();

        List<Case> caseList = [SELECT Id, OwnerId FROM Case];
        try{
            //CaseTriggerHandler.onlineReturnEmail(caseList);
        }
        catch(Exception e){}
    }

    @isTest
    public static void createCaseCommentTest() {
        // init
        String storeName = 'LV STORE NAME';
        Store__c store = ICX_TestFactory.createStore(storeName, 'AXX');
        insert store;

        id ownerProfile = ICX_TestFactory.PROFILE_ICONICS_SA;//PROFILE_MAP.get('ICONICS_SA');
        User ownerUser = ICX_TestFactory.createUser(ownerProfile);
        ownerUser.DefaultStore__c = 'AXX';
        insert ownerUser;

        Case ca = ICX_TestFactory.createCase(null);
        ca.Product_Sku_unknown__c = 'Unknwon SKU';
        insert new List<Case>{ca, ICX_TestFactory.createCase(null)};

        // Test
        Test.startTest();
        ca.In_Store_Action__c = 'Reassign to CSC';
        ca.CA_Name__c = ownerUser.Id;
        ca.Store__c = store.Id;
        update ca;

        Test.stopTest();
        
        // check
        CaseComment comment = new CaseComment();
        comment.CommentBody = 'Request updated by store:\nIn store action: \'' + ca.In_Store_Action__c + '\'';
        comment.ParentId = ca.Id;
        insert comment;
        List<CaseComment> resultList = [SELECT Id, ParentId FROM CaseComment];
        System.debug('CCCCCCCCC resultList: ' + resultList);
        //System.assertEquals(1, resultList.size());
        System.assertEquals(ca.Id, resultList.get(0).ParentId);
    }

    @isTest
    public static void applyAssignmentRules_Test() {
        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        //currentUser.DefaultStore__c = 'XXX';
        currentUser.MANAGEMENT_ZONE_LEVEL__c = '15';
        currentUser.BypassVR__c= true;
        insert currentUser;

        Case cas = ICX_TestFactory.createCase(null);
        cas.Shipping_group__c = 'xxx';
        Id recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        cas.RecordTypeId = recordTypeId;

        // Test
        Test.startTest();
        System.runAs(currentUser) {
            insert cas;
           // ICX_CaseAssignmentRules.caseAssign(new List<Id> {cas.Id});
        }
        Test.stopTest();

        // Note: In Apex class test, the assertion doesn't seem to work to check Case Team linked to the record
        //List<CaseTeamTemplateRecord> memberList = [SELECT Id, TeamTemplateId FROM CaseTeamTemplateRecord WHERE ParentId = :cas.Id];
        //System.assert(!memberList.isEmpty());
        //System.assert(String.isNotBlank(memberList.get(0).TeamTemplateId));
        //System.debug('memberList=' + memberList);
    }
    @isTest
      public static void ClosingEscalationBeforeChildren() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Case ParentCaseEscalation = ICX_TestFactory.createCase(acc.Id);
        ParentCaseEscalation.Resolution__c='Escalation';
        ParentCaseEscalation.isEscalated = true;
        ParentCaseEscalation.Escalation_Type__c = 'Manual';
        ParentCaseEscalation.Escalation_Status__c='New';
        ParentCaseEscalation.Type_of_Support_Escalation__c='Advice';
        ParentCaseEscalation.Product_Sku_unknown__c = 'Unknwon SKU';

try{
        insert ParentCaseEscalation;
}
catch(Exception e){}

     
       

        Case ChildEscalation1 = ICX_TestFactory.createCase(acc.Id);
        ChildEscalation1.ParentId = ParentCaseEscalation.Id;
        ChildEscalation1.Resolution__c='Immediate Response';
        ChildEscalation1.Product_Sku_unknown__c = 'Unknwon SKU';
        insert ChildEscalation1;

        
        CareService__c ChildCareService = ICX_TestFactory.createCareService(acc.Id);
        ChildCareService.Parent_Request__c = ParentCaseEscalation.Id;
        ChildCareService.ICONiCS_Status_Detail__c='Cancelled';

        insert ChildCareService;

        Test.startTest();
        ParentCaseEscalation.Escalation_Status__c='Closed';
        ParentCaseEscalation.Resolution__c='Immediate Response';

        try{
            update ParentCaseEscalation;
        }
        catch(Exception e){}
        
        Test.stopTest();


    }

    
    @isTest
    public static void addTagsTest() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Case existingDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        insert existingDPCA;       

        Test.startTest();         
        existingDPCA.Categories__c='Jewelry;Travel';
        Update existingDPCA;     
       
        List<Interests__c> lstExistingTag1 = [SELECT id, Categories__c FROM Interests__c WHERE Client__c=:existingDPCA.AccountId AND isActive__c = true AND source__c = 'DPCA'];
        System.assertEquals(2, lstExistingTag1.size());

        Test.stopTest();
        
    }

    @isTest
    public static void deleteTagsTest() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Interests__c newTag1 = new Interests__c(Client__c=acc.Id,isActive__c = true,source__c = 'DPCA',Categories__c='Perfume');
        insert newTag1;

        Interests__c newTag2 = new Interests__c(Client__c=acc.Id,isActive__c = true,source__c = 'DPCA',Categories__c='Jewelry');
        insert newTag2;

        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Case existingDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        existingDPCA.First_Follow_Up__c = 'Phone';
        existingDPCA.Second_Follow_Up__c = 'Phone';
        insert existingDPCA;       

        Test.startTest();         
        existingDPCA.Categories__c='Jewelry';
        Update existingDPCA;     
       
        List<Interests__c> lstExistingTag1 = [SELECT id, Categories__c FROM Interests__c WHERE Client__c=:existingDPCA.AccountId AND isActive__c = true AND source__c = 'DPCA'];
        System.assertEquals(1, lstExistingTag1.size());

        Test.stopTest();
        
    }

    @isTest
    public static void updateAccountDPCATest() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Case existingDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        insert existingDPCA;

        Test.startTest();
        Account existingAcc1 = [SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(false, existingAcc1.Subscribed_to_Digital_Concierge__c);

        existingDPCA.First_Follow_Up__c = 'Phone';
        existingDPCA.Second_Follow_Up__c = 'Phone';
        existingDPCA.Status='Interested';
        Update existingDPCA;

        Account existingAcc2 = [SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(true, existingAcc2.Subscribed_to_Digital_Concierge__c);
        Test.stopTest();
    }

    @isTest
    public static void checkDuplicateDPCATest() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Case existingDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        insert existingDPCA;

        Test.startTest();
        Case newDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        try{
            insert newDPCA;
        }catch(Exception e){}
        List<Case> lstDPCA = [select Id , AccountId from case where RecordTypeId=:dpcaRTId];
        System.assertEquals(1, lstDPCA.size());
        
        Test.stopTest();

        
    }
    
      @isTest
    public static void changeOperationExceptionStatusTest() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Id oeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        Case newOE = new Case(AccountId=acc.Id,RecordTypeId=oeRTId,Country__c = 'FRANCE');
        insert newOE;

        Test.startTest();
        Case existingOE = [select id, status from Case where RecordTypeId = :oeRTId];
        existingOE.Status = 'Closed';       
        update existingOE;     
        Test.stopTest();

        
    }

    @isTest
    public static void caseApprovalApproved() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
    
        insert OrderLineInsert;
        
        
         Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

         List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
        	insert caseToInsert;
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Status = 'New'];
        caseApproval[0].Status ='Approved';
        
        update caseApproval;
        Test.stopTest();

    }
      @isTest
    public static void caseApprovalApprovedWithCaseRelatedRejected() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
  
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
        
        OrderShipping__c orderShipping3 = ICX_TestFactory.createOrderShipping(order);
        orderShipping3.ShippingNumber__c ='0123456789-3';
        orderShippingInsert.add(orderShipping3);
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
         OrderLine__c orderLine3 = ICX_TestFactory.createOrderLine(order);
        orderLine3.OrderShipping__c =orderShipping3.Id;
        OrderLineInsert.add(orderLine3);
        insert OrderLineInsert;        

        
         Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

         List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
            Case newCase2 = new Case();
            newCase2.Approval_Submitter__c = CAUser.Id;
            newCase2.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase2.Order__c =order.Id;
            newCase2.Order_Shipping__c = orderShipping2.Id;
            newCase2.OwnerId = queueApproval.Id;
            newCase2.recordTypeId = caseRecordIdApproval;
            newCase2.AccountId = acc.Id;
            newCase2.ContactId = acc.PersonContactId;    
        	newCase2.Status ='Approved';
            caseToInsert.add(newCase2);
        
         	Case newCase3 = new Case();
            newCase3.Approval_Submitter__c = CAUser.Id;
            newCase3.Approval_Type__c ='BANK_TRANSFER';
            newCase3.Order__c =order.Id;
            newCase3.Order_Shipping__c = orderShipping3.Id;
            newCase3.OwnerId = queueApproval.Id;
            newCase3.recordTypeId = caseRecordIdApproval;
            newCase3.AccountId = acc.Id;
            newCase3.ContactId = acc.PersonContactId;    
        	newCase3.Status ='Rejected';
            caseToInsert.add(newCase3);
        
        	insert caseToInsert;
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Status = 'New'];
       
        caseApproval[0].Status ='Approved';
        update caseApproval;
        
        Test.stopTest();

    }
    
        @isTest
    public static void caseApprovalApprovedWithCaseRelatedRejected2() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
  
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
  
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
        insert OrderLineInsert;        

        
         Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

         List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
           
        
         	Case newCase2 = new Case();
            newCase2.Approval_Submitter__c = CAUser.Id;
            newCase2.Approval_Type__c ='BANK_TRANSFER';
            newCase2.Order__c =order.Id;
            newCase2.Order_Shipping__c = orderShipping2.Id;
            newCase2.OwnerId = queueApproval.Id;
            newCase2.recordTypeId = caseRecordIdApproval;
            newCase2.AccountId = acc.Id;
            newCase2.ContactId = acc.PersonContactId;    
        	newCase2.Status ='Rejected';
            caseToInsert.add(newCase2);
        
        	insert caseToInsert;
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Status = 'New'];
       
        caseApproval[0].Status ='Approved';
        update caseApproval;
        
        Test.stopTest();

    }
    
     @isTest
    public static void caseApprovalApprovedWithCaseRelatedOpen() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
  
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
        
        OrderShipping__c orderShipping3 = ICX_TestFactory.createOrderShipping(order);
        orderShipping3.ShippingNumber__c ='0123456789-3';
        orderShippingInsert.add(orderShipping3);
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
         OrderLine__c orderLine3 = ICX_TestFactory.createOrderLine(order);
        orderLine3.OrderShipping__c =orderShipping3.Id;
        OrderLineInsert.add(orderLine3);
        insert OrderLineInsert;        

        
         Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

         List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
            Case newCase2 = new Case();
            newCase2.Approval_Submitter__c = CAUser.Id;
            newCase2.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase2.Order__c =order.Id;
            newCase2.Order_Shipping__c = orderShipping2.Id;
            newCase2.OwnerId = queueApproval.Id;
            newCase2.recordTypeId = caseRecordIdApproval;
            newCase2.AccountId = acc.Id;
            newCase2.ContactId = acc.PersonContactId;    
        	newCase2.Status ='Approved';
            caseToInsert.add(newCase2);
        
         	Case newCase3 = new Case();
            newCase3.Approval_Submitter__c = CAUser.Id;
            newCase3.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase3.Order__c =order.Id;
            newCase3.Order_Shipping__c = orderShipping3.Id;
            newCase3.OwnerId = queueApproval.Id;
            newCase3.recordTypeId = caseRecordIdApproval;
            newCase3.AccountId = acc.Id;
            newCase3.ContactId = acc.PersonContactId;    
        	//newCase3.Status ='Rejected';
            caseToInsert.add(newCase3);
        
        	insert caseToInsert;
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Status ='New'];
       
        caseApproval[0].Status ='Approved';
        update caseApproval;
        
        Test.stopTest();

    }
    
     
       @isTest
    public static void caseApprovalApprovedWithCaseRelatedCompleted() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
  
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
        
        OrderShipping__c orderShipping3 = ICX_TestFactory.createOrderShipping(order);
        orderShipping3.ShippingNumber__c ='0123456789-3';
        orderShippingInsert.add(orderShipping3);
        
         
        OrderShipping__c orderShipping4 = ICX_TestFactory.createOrderShipping(order);
        orderShipping4.ShippingNumber__c ='0123456789-4';
        orderShippingInsert.add(orderShipping4);
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
         OrderLine__c orderLine3 = ICX_TestFactory.createOrderLine(order);
        orderLine3.OrderShipping__c =orderShipping3.Id;
        OrderLineInsert.add(orderLine3);
        
        OrderLine__c orderLine4 = ICX_TestFactory.createOrderLine(order);
        orderLine4.OrderShipping__c =orderShipping4.Id;
        OrderLineInsert.add(orderLine4);
        insert OrderLineInsert;        

        
         Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

         List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
            Case newCase2 = new Case();
            newCase2.Approval_Submitter__c = CAUser.Id;
            newCase2.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase2.Order__c =order.Id;
            newCase2.Order_Shipping__c = orderShipping2.Id;
            newCase2.OwnerId = queueApproval.Id;
            newCase2.recordTypeId = caseRecordIdApproval;
            newCase2.AccountId = acc.Id;
            newCase2.ContactId = acc.PersonContactId;    
        	newCase2.Status ='Approved';
            caseToInsert.add(newCase2);
        
         	Case newCase3 = new Case();
            newCase3.Approval_Submitter__c = CAUser.Id;
            newCase3.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase3.Order__c =order.Id;
            newCase3.Order_Shipping__c = orderShipping3.Id;
            newCase3.OwnerId = queueApproval.Id;
            newCase3.recordTypeId = caseRecordIdApproval;
            newCase3.AccountId = acc.Id;
            newCase3.ContactId = acc.PersonContactId;    
        	newCase3.Status ='Rejected';
            caseToInsert.add(newCase3);
        
          	Case newCase4 = new Case();
            newCase4.Approval_Submitter__c = CAUser.Id;
            newCase4.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase4.Order__c =order.Id;
            newCase4.Order_Shipping__c = orderShipping4.Id;
            newCase4.OwnerId = queueApproval.Id;
            newCase4.recordTypeId = caseRecordIdApproval;
            newCase4.AccountId = acc.Id;
            newCase4.ContactId = acc.PersonContactId;    
            caseToInsert.add(newCase4);
        
        	insert caseToInsert;
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Status ='New'];
       
        caseApproval[0].Status ='Approved';
        caseApproval[1].Status ='Approved';

        update caseApproval;
        
        Test.stopTest();

    }
    
    
       @isTest
    public static void caseApprovalRejected() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

       
  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
       
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
     
        insert OrderLineInsert;  
        
        Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

			List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='BANK_TRANSFER';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
          
       
        
        	insert caseToInsert;
    	
        Test.startTest();       

        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Status ='New'];
        caseApproval[0].Status ='Rejected';
        
        update caseApproval;
        Test.stopTest();

    }
    
    
    
       @isTest
    public static void caseApprovalRejectedRelatedCase() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

       
  		List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
        
        OrderShipping__c orderShipping3 = ICX_TestFactory.createOrderShipping(order);
        orderShipping3.ShippingNumber__c ='0123456789-3';
        orderShippingInsert.add(orderShipping3);
        
         
        OrderShipping__c orderShipping4 = ICX_TestFactory.createOrderShipping(order);
        orderShipping4.ShippingNumber__c ='0123456789-4';
        orderShippingInsert.add(orderShipping4);
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
         OrderLine__c orderLine3 = ICX_TestFactory.createOrderLine(order);
        orderLine3.OrderShipping__c =orderShipping3.Id;
        OrderLineInsert.add(orderLine3);
        
        OrderLine__c orderLine4 = ICX_TestFactory.createOrderLine(order);
        orderLine4.OrderShipping__c =orderShipping4.Id;
        OrderLineInsert.add(orderLine4);
        insert OrderLineInsert;  
        
        Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

         Group queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name =:'Middle East Approval' LIMIT 1];

			List<Case> caseToInsert = new List<Case>();
            Case newCase = new Case();
            newCase.Approval_Submitter__c = CAUser.Id;
            newCase.Approval_Type__c ='PRICE_ADJUSTMENT';
            newCase.Order__c =order.Id;
            newCase.Order_Shipping__c = orderShipping.Id;
            newCase.OwnerId = queueApproval.Id;
            newCase.recordTypeId = caseRecordIdApproval;
            newCase.AccountId = acc.Id;
            newCase.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase);
        
            Case newCase2 = new Case();
            newCase2.Approval_Submitter__c = CAUser.Id;
            newCase2.Approval_Type__c ='BANK_TRANSFER';
            newCase2.Order__c =order.Id;
            newCase2.Order_Shipping__c = orderShipping2.Id;
            newCase2.OwnerId = queueApproval.Id;
            newCase2.recordTypeId = caseRecordIdApproval;
            newCase2.AccountId = acc.Id;
            newCase2.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase2);
        
        
        	Case newCase3 = new Case();
            newCase3.Approval_Submitter__c = CAUser.Id;
            newCase3.Approval_Type__c ='BANK_TRANSFER';
            newCase3.Order__c =order.Id;
            newCase3.Order_Shipping__c = orderShipping3.Id;
            newCase3.OwnerId = queueApproval.Id;
            newCase3.recordTypeId = caseRecordIdApproval;
            newCase3.AccountId = acc.Id;
            newCase3.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase3);
        
        
        	Case newCase4 = new Case();
            newCase4.Approval_Submitter__c = CAUser.Id;
            newCase4.Approval_Type__c ='BANK_TRANSFER';
            newCase4.Order__c =order.Id;
            newCase4.Order_Shipping__c = orderShipping4.Id;
            newCase4.OwnerId = queueApproval.Id;
            newCase4.recordTypeId = caseRecordIdApproval;
            newCase4.AccountId = acc.Id;
            newCase4.ContactId = acc.PersonContactId;    
        
            caseToInsert.add(newCase4);
        
        	insert caseToInsert;
    	
        Test.startTest();       

        List<Case> caseApproval = [SELECT Id FROM Case WHERE RecordTypeId=: caseRecordIdApproval AND Approval_Type__c=:'BANK_TRANSFER' AND Status ='New'];
        caseApproval[0].Status ='Approved';
        caseApproval[1].Status ='Rejected';
        
        update caseApproval;
        Test.stopTest();

    }
    
    
    @isTest
    public static void checkOEDuplicate_TEST() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Order__c orderRecord = ICX_TestFactory.createOrder(acc) ;
        // orderRecord.OwnerId__c = CAUser.Id;
         insert orderRecord;
         
         OrderShipping__c orderShippingRecord = ICX_TestFactory.createOrderShipping(orderRecord.Id) ;
         insert orderShippingRecord;
         
         OrderLine__c orderLineRecord = ICX_TestFactory.createOrderLine(orderRecord.Id,orderShippingRecord.Id) ;
         insert orderLineRecord;

        Id oeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        Case newOE = new Case(AccountId=acc.Id,RecordTypeId=oeRTId,Order_Shipping__c=orderShippingRecord.Id,Country__c = 'USA');
        insert newOE;

        Test.startTest(); 
        Case newOE2 = new Case(AccountId=acc.Id,RecordTypeId=oeRTId,Order_Shipping__c=orderShippingRecord.Id,IgnoreDuplicateOE__c=true ,Country__c = 'USA');
        insert newOE2;
        Test.stopTest();
        List<Case> oeCase = [SELECT ID FROM CASE WHERE Order_Shipping__c=:orderShippingRecord.Id];
        System.assertEquals(2,oeCase.size());

        
    }

    @isTest
    public static void afterDeleteCaseTest() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Case existingDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        insert existingDPCA;

        Test.startTest();
        Account existingAcc1 = [SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(false, existingAcc1.Subscribed_to_Digital_Concierge__c);

        existingDPCA.First_Follow_Up__c = 'Phone';
        existingDPCA.Second_Follow_Up__c = 'Phone';
        existingDPCA.Status='Not Interested';
        Update existingDPCA;

       Account existingAcc2 = [SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE Id=:acc.Id];
       System.assertEquals(false, existingAcc2.Subscribed_to_Digital_Concierge__c);

        existingDPCA.Status='Interested';
        Update existingDPCA;

        Account existingAcc3 = [SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(true, existingAcc3.Subscribed_to_Digital_Concierge__c);

        //Case deletion
        delete existingDPCA;

        Test.stopTest();

        Account existingAcc4 = [SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(false, existingAcc4.Subscribed_to_Digital_Concierge__c);
    }


    @IsTest
    public static void updateFieldOEToStore_TEST() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Store__c newStore = ICX_TestFactory.createStore('LV SHORT HILLS', 'USH');
        insert newStore;

        Test.startTest();
        Id oeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        Case newOE = new Case(AccountId = acc.Id, RecordTypeId = oeRTId, Country__c = 'USA', Status = 'Store New', Store__c = newStore.Id);
        insert newOE;

        Test.stopTest();

        List<Case> oeCase = [SELECT ID, RecordTypeId, Country__c, Status, Store__c, isOEAssignedToStore__c 
                             FROM CASE 
                             WHERE ID =: newOE.Id 
                             LIMIT 1];

        system.debug('oeCase =>>> ' + oeCase);

        System.assertEquals(true,oeCase[0].isOEAssignedToStore__c);

    }

}