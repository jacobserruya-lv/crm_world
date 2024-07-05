/**
BW - 10/11/2015
*/
@isTest
public with sharing class VO_Email_StoreManager_Test {
    
    //private final static String PS_AFTERSALES_NAME = VO_Utils.VOICE_AFTER_SALES;
    private final static String PS_AFTERSALES_NAME = 'VOICE Store After Sales';
    //private final static String PS_SALES_NAME = VO_Utils.VOICE_SALES;
    private final static String PS_SALES_NAME = 'VOICE Store Local Sales';
    
    @testSetup
    public static void setup1 (){
        User u = IC_TestFactory.createUser('john@acme.com');
        u.ProfileId = IC_UTILS.getSAProfile();
        insert u;
        
        PermissionSet ps;
        ps = [Select Id from PermissionSet Where label =: PS_AFTERSALES_NAME LIMIT 1];
        if (ps == NULL){
            ps = new PermissionSet(Name = 'Test1', label = PS_AFTERSALES_NAME);
            System.debug(ps);
            insert ps;
        }
        
        PermissionSetAssignment per = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        System.debug(per);
        
        ps = [Select Id from PermissionSet Where label =: PS_SALES_NAME LIMIT 1];
        if (ps == NULL){
            ps = new PermissionSet(Name = 'Test1', label = PS_SALES_NAME);
            System.debug(ps);
            insert ps;
        }
        
        PermissionSetAssignment per2 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        insert new List<PermissionSetAssignment> {per2,per};
        System.debug(per2);
    }
    
    @testSetup
    public static void setup (){		
        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        
        User usr = IC_TestFactory.createUser('dreamuserLV161548@lvtest.com');
        usr.profileId = IC_UTILS.getSysAdminProfile();
        usr.email = 'xxx@noemail.com';
        usr.DefaultStore__c = 'P3';
        //usr.UserRoleId = role.Id;
        usr.DREAMId__c = '123456';
        usr.isactive = true;
        insert usr;
        
        VO_Config__c cs = new VO_Config__c(Name = 'NUM OF Q', Value__c = '50');
        insert cs;
        
        Account acc = IC_TestFactory.createAccount();
        acc.DREAMID__c = '14712';
        insert acc;
        
        Store__c st = new Store__c(Name='STLesChamps', RetailStoreId__c = 'P3');
        insert st;
        
        ICONSettings__c iconSet = new ICONSettings__c();
        iconSet.ExcepPurchaseUSD__c=70;
        iconSet.Exceptional_Purchase_Currency__c='USD';	
        insert iconSet;
        
        VO_Survey__c srv = new VO_Survey__c(Status__c='New', Scoring__c='Recovery act', StoreID__c='P3', Store__c = st.Id ,DreamIDText__c = '14712', AnswerDate__c = Date.today());
        VO_Survey__c srv2 = new VO_Survey__c(Status__c='New', Scoring__c='Delighted', StoreID__c='P3', Store__c = st.Id ,DreamIDText__c = '14712', AnswerDate__c = Date.today());
        insert new List<VO_Survey__c> {srv2,srv};
        //		Group gr = new Group(Name='VoiceStoreManager', DeveloperName = 'VoiceStoreManager');
        //		insert gr;
        //		GroupMember gm = new GroupMember(GroupId = gr.Id, UserOrGroupId=usr.Id );
        //		insert gm;
        VO_Config__c cfg = new VO_Config__c(Name='EmailAlertUserGroup', Value__c='VoiceStoreManager');
        VO_Config__c cfg2 = new VO_Config__c(Name='server', Value__c='c.cs1');
		insert new List<VO_Config__c> {cfg,cfg2};        
        
        
    }
    
    static testMethod void myUnitTest() {
        User u = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User LIMIT 1];
        
        VO_Email_StoreManager_CTRL cont = new VO_Email_StoreManager_CTRL();
        cont.storeCode = 'P3';
        cont.isAfterSalesUser = false;
        cont.isSalesUser = false;
        cont.userId = u.id;
        cont.getStoreName();
        cont.getNbRecoveryActs();
        cont.getNbDelighteds();
        cont.getNbPromoters();
    }
}