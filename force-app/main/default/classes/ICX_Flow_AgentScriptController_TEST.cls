@isTest
public class ICX_Flow_AgentScriptController_TEST {

    @isTest
    public static void constructorTest() {
        //Observe how we set the Page here
        PageReference pageRef = Page.ICX_Flow_AgentScript;
        Test.setCurrentPage(pageRef);
        
        String lang = 'fr';
        String label = 'CustomLabelAPIName';

        Test.startTest();
        ApexPages.currentPage().getParameters().put('language', lang);
        ApexPages.currentPage().getParameters().put('label', label);
        ICX_Flow_AgentScriptController ctrl = new ICX_Flow_AgentScriptController();
        Test.stopTest();
        
        System.assertEquals(lang, ctrl.languageCode);
        System.assertEquals(label, ctrl.labelName);
    }
    
    @isTest
    public static void getVisualforceHost_Test() {
        String host = 'louisvuitton--pprod--c.cs95.visual.force.com';
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.VisualforceHost__c = host;
        insert settings;
        
        Test.startTest();
		System.assertEquals(host, ICX_Flow_AgentScriptController.getVisualforceHost());
        Test.stopTest();
    }
}