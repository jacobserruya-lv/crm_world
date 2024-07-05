/**
* @group Clienteling 
* @since Juny 2020
* @description Test class for BL_Log
*/

@isTest
public class BL_Log_Test {
    
    @isTest
    static void testMethod1(){  
        BL_Log log = new BL_Log();
        Test.startTest();
        BL_Log.toSObject(log);
        Test.stopTest();
    }

}