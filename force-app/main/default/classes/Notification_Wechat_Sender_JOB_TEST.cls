@isTest
public class Notification_Wechat_Sender_JOB_TEST {
    
    
    @isTest
    static void testMethod2(){   
        BL_WS_Request request = new BL_WS_Request();
        
        Test.setMock(HttpCalloutMock.class, new CLT_CalloutMockInstance());
        BL_AppSettings.setAppSettings('Clienteling');

        RestRequest req = new RestRequest();
        req.params.put('s', 'test');
        RestContext.request = req;
        Notification_Wechat_Sender_JOB sj = new  Notification_Wechat_Sender_JOB();
        SchedulableContext sc ;
        sj.execute(sc ) ;
      

        Test.startTest();
           try{
           		 request.init('retail/v1/activities/tasks', 'path', (BL_UserInfo)Type.forName('CLT_UserInfo').newInstance());
               
                req.params.put('pageIndex',null);
                request.init('retail/v1/activities/tasks', 'path', (BL_UserInfo)Type.forName('CLT_UserInfo').newInstance());
            }
            catch(exception e){}
        
           req.params.put('pageIndex', '6');
            try{
           		 request.init('retail/v1/activities/tasks', 'path', (BL_UserInfo)Type.forName('CLT_UserInfo').newInstance());
            }
            catch(exception e){}
        
        	req.params.put('pageSize', 'adsfdf');
        	try{
           		 request.init('retail/v1/activities/tasks', 'path', (BL_UserInfo)Type.forName('CLT_UserInfo').newInstance());
            }
       		 catch(exception e){}

        	
        Test.stopTest();
    }
}