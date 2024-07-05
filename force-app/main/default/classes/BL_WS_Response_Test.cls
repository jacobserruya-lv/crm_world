/**
* @group Clienteling 
* @since Juny 2020
* @description Test class for BL_WS_Response
*/

@isTest
public class BL_WS_Response_Test {
    
    @isTest
    static void testMethod1(){
         
        List<Sobject> items = new List<Sobject>();
        Map<String,Object> map1 = new Map<String,Object>{'isEasyQuery'=>true};

        Test.startTest();
   		     BL_WS_Response response = new BL_WS_Response(10, 10,true, 30, 6);
        	 BL_WS_Response response1 = new BL_WS_Response(10, 10, true, 'select id from Account');
   		     BL_WS_Response response2 = new BL_WS_Response(items);
    	     BL_WS_Response response3 = new BL_WS_Response(map1);
        Test.stopTest();
    }

}