@isTest
public class SO_OpportunityColorController_TEST {
    
    @isTest static void Test_findById() {
        
        Opportunity opp  		= new Opportunity();
        opp.Name = 'otest';
        opp.SPO_ProductCategory__c = 'Leather Goods';
        opp.SPO_OrderType__c = 'SPO/MTO';
        opp.SPO_CreationType__c = 'otest';
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        insert opp;
        System.debug('$$$$$$$$$$$'+opp.Id);
        
        Opportunity o = SO_OpportunityColorController.findById(opp.Id);
        
        System.assertEquals(opp.Id,o.Id);
        
    }
    //for code coverage
    @isTest
    static void test_getSPAPersonalizationJson() {
        SO_OpportunityColorController.getSPAPersonalizationJson();
    }
    
    //@isTest(SeeAllData=true) 
    static void Test_getPictoColorList() {
        
        SPO_Colors__c color = new SPO_Colors__c();
        color.Name = 'Monogram Empreinte Dune';
        
        insert color;
        
        List<SPO_Colors__c> ocolor = new List<SPO_Colors__c>();
        List<String> colorListNames = new List<String>();
        for (SPO_Colors__c c : [Select Name from SPO_Colors__c]) {
            colorListNames.add (c.Name);
        }

        Test.startTest();
        ocolor = SO_OpportunityColorController.getPictoColorList(colorListNames);
        Test.stopTest(); 
        String s = String.valueOf(ocolor);
        System.debug('***' + s);
        System.debug('***' + color.name);
  
        System.assert(s.contains(color.Name));
        System.assertEquals(colorListNames.size(), ocolor.size());        
    }
    
    @isTest static void Test_saveColor() {
        
        Opportunity opp  		= new Opportunity();
        opp.Name = 'otest';
        opp.SPO_ProductCategory__c = 'Leather Goods';
        opp.SPO_OrderType__c = 'SPO/MTO';
        opp.SPO_CreationType__c = 'otest';
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        
        insert opp;
        System.debug('$$$$$$$$$$$$$$'+opp.Name);
        opp.Name = 'OOOtest';
        Test.startTest();
        SO_OpportunityColorController.saveColor(opp);
        Test.stopTest();

        Opportunity newOpp = [SELECT id, Name FROM Opportunity WHERE id=:opp.id];
        System.debug('$$$$$$$$$$$$$$'+opp.Name);
        
        System.assertEquals('OOOtest', newOpp.Name);        
        
    }
    
    @isTest(SeeAllData=true)
    static void Test_getPictoColorMap() {
        
        SPO_Colors__c color = new SPO_Colors__c();
        color.Name = 'Monogram Empreinte Dune';
        
        List<String> colorListNames = new List<String>();
        for (SPO_Colors__c c : [Select Name from SPO_Colors__c]) {
            colorListNames.add (c.Name);    
        }
        Map<String, SPO_Colors__c> colorMap = new Map<String, SPO_Colors__c>();
        //colorMap.put(colorListNames[0],color);
        
        Test.startTest();
        colorMap = SO_OpportunityColorController.getPictoColorMap(colorListNames);
        Test.stopTest();
        SPO_Colors__c color1 = colorMap.get('Monogram Empreinte Dune');
        System.assertEquals(color1.Name,color.Name);
        
    }
    
    @isTest static void Test_getUserProfile() {
        
        User usr 		= IC_TestFactory.createUser('utest@tesr.fr');

        usr.ProfileId = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].id;
        
        insert usr;
        
        System.runAs(usr){
        
        Test.startTest();
        //getProfile of current user 
       	User usr1 = SO_OpportunityColorController.getUserProfile();
        Test.stopTest();
        
        System.debug('$$$$$$$$$$$$$$USR'+usr.Profile.Name);
        System.assertEquals(usr1.ProfileId,usr.ProfileId);
    	}
        
    }

    @isTest
    public static void testDependentOptions (){
        Map<String, List<String>> dependentOptionsMap = SO_OpportunityColorController.getDependentOptionsImpl('User', 'MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c');
        System.assertNotEquals(dependentOptionsMap, null);
        System.assert(!dependentOptionsMap.isEmpty());


        List<String> dependentOptions = SO_OpportunityColorController.getDependentOptions('User', 'MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c', 'AMERICAS');

        System.assertNotEquals(dependentOptions, null);
        System.assert(!dependentOptions.isEmpty());
    }
}