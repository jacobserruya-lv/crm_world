@isTest

public class SPO_FirmOrderControllerLC_TEST {
    
    
    @isTest static void Test_getUser(){
        
        User usr = IC_TestFactory.createUser('utest@test.fr','00ei0000000guuuAAA');
        
        insert usr;
        User u = SPO_FirmOrderControllerLC.getUser();
        
        
    }
    
    @isTest static void Test_getFirmOrderList(){
        
        Opportunity opp  		= new Opportunity();
        opp.Name = 'otest';
        opp.SPO_ProductCategory__c = 'Leather Goods';
        opp.SPO_OrderType__c = 'SPO/MTO';
        opp.SPO_CreationType__c = 'otest';
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        insert opp;
        System.debug('$$$$$$$$$$$'+opp.Id);
        
        SPO_FirmOrder__c fo  		= new SPO_FirmOrder__c();
        fo.SPO_BriefName__c=opp.Id;
        fo.Name = 'Test FO 1';
        fo.LineNumber__c = 001;
        insert fo;    
        List<SPO_FirmOrder__c> foList = SPO_FirmOrderControllerLC.getFirmOrderList(opp.Id);
        
        System.assertEquals(1,foList.size());
        
    }
	@isTest
    public static void Test_updateFirmOrders(){

        Opportunity opp         = new Opportunity();
        opp.Name = 'otest';
        //opp.SPO_ProductCategory__c = 'Leather goods';
        //opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
        opp.SPO_CreationType__c = 'otest';
        opp.SPO_ProductCategory__c = 'Leather goods' ;
        opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)' ;
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        
        insert opp;
        
        Opportunity o = [SELECT id, Name FROM Opportunity Where Name = 'otest'];
        
        List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
        /*foList.add(new SPO_FirmOrder__c(
            SPO_BriefName__c = o.id,
            Name = 'Test FO 1',
            LineNumber__c = 001,
        SPO_FirmOrderStatus__c ='Sent to MyPR'));
        foList.add(new SPO_FirmOrder__c(
            SPO_BriefName__c = o.id,
            Name = 'Test FO 2',
            LineNumber__c = 002, SPO_FirmOrderStatus__c ='Sent to MyPR'));*/
        
        SPO_FirmOrder__c fo1 = new SPO_FirmOrder__c( SPO_BriefName__c = o.id,
            Name = 'Test FO 1',
            LineNumber__c = 001);
        SPO_FirmOrder__c fo2 = new SPO_FirmOrder__c( SPO_BriefName__c = o.id,
            Name = 'Test FO 2',
            LineNumber__c = 002);
        foList.add(fo1);
		foList.add(fo2);
        
        insert foList;
       
        fo1.SPO_FirmOrderStatus__c = 'Sent to MyPR';
        fo2.SPO_FirmOrderStatus__c = 'Sent to MyPR';
        
        update foList;
        
        
		list<SPO_FirmOrder__c> newFoList = [SELECT id, SPO_FirmOrderStatus__c, SPO_BriefName__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = :o.id];
       
        list<SPO_FirmOrder__c> testFOlist = SPO_FirmOrderControllerLC.updateFirmOrderDB(o.id);

        for (SPO_FirmOrder__c fo : testFOlist){
            System.assertEquals('Received in Store', fo.SPO_FirmOrderStatus__c);
        }
    }    
    
    @isTest static void Test_cancelFirmOrderDB() {
        
        Opportunity opp         = new Opportunity();
        opp.Name = 'otest';
        //opp.SPO_ProductCategory__c = 'Leather goods';
        //opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
        opp.SPO_CreationType__c = 'otest';
        opp.SPO_ProductCategory__c = 'Leather goods' ;
        opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)' ;
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        
        insert opp;


        List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
        foList.add(new SPO_FirmOrder__c(
            SPO_BriefName__c = opp.id,
            Name = 'Test FO 1',
            LineNumber__c = 001,
            SPO_TechETLStatus__c = 'V'));
        foList.add(new SPO_FirmOrder__c(
            SPO_BriefName__c = opp.id,
            Name = 'Test FO 2',
            LineNumber__c = 002, 
            SPO_TechETLStatus__c = 'V'));

        insert foList;

        List<SPO_FirmOrder__c> updFoList = SPO_FirmOrderControllerLC.cancelFirmOrderDB(opp.id,'test','Client - Client decision','test');

        list<SPO_FirmOrder__c> newFoList = [SELECT id, SPO_FirmOrderStatus__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = :opp.id];

        for (SPO_FirmOrder__c fo : newFoList){
            System.assertEquals('Cancelled by store', fo.SPO_FirmOrderStatus__c);
        }
        
        
    }
    
    
    
    
    
    
}