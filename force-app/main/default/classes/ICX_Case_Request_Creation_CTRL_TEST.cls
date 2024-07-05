@isTest
public class ICX_Case_Request_Creation_CTRL_TEST {

    @isTest
    public static void getNextPage_TEST() {
        // init
        Case cas = ICX_TestFactory.createCase(null);
        insert cas;
        
        ICX_Case_Request_Creation_CTRL ctrl = new ICX_Case_Request_Creation_CTRL(null);
        
        //Map<String, Object> flowMap = new Map<String, Object>();
        //flowMap.put('VarNewCaseID', cas.Id);
        //ctrl.myFlow = new Flow.Interview.ICX_CaseCreation(flowMap);
        //ctrl.myFlow.start();
        
        // Test
        PageReference resultPage = ctrl.getNextPage();

        // Check
        System.assertEquals(null, resultPage);
    }
}