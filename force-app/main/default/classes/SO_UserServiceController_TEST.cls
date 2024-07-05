@isTest
public class SO_UserServiceController_TEST {
   
        @isTest static void Test_getUser(){
        
        User usr = IC_TestFactory.createUser('utest@test.fr','00ei0000000guuuAAA');
        
        insert usr;
        User u = SPO_OpportunityActionButtonController.getUser();
        
        
    }

}