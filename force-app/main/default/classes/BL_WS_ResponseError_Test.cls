/**
* @group Clienteling 
* @since Juny 2020
* @description Test class for BL_WS_ResponseError
*/

@isTest
public class BL_WS_ResponseError_Test {
    
        @isTest
    static void testMethod3(){
       		List<String> fields  = new List<String>();
            fields.add('test');
            Test.startTest();
       			 BL_WS_ResponseError r = new BL_WS_ResponseError('test','202',fields,'error','123');
            Test.stopTest();

    }
   

}