/***************************************************************************************************
* @File Name          : TR_C360Flow_Queueable_TEST.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad ASC
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 08-31-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       08-22-2022         Imad ASC                           Initial Version
*****************************************************************************************************/
@isTest
public class TR_C360Flow_Queueable_TEST {
    static testmethod void test1() {
        String body = TR_C360_Utils.getC360Json('001');
        C360_Tech_Event_Return_Flow__e evt = new C360_Tech_Event_Return_Flow__e ();
        evt.Body_Json__c = body;
        system.debug(body);
        Test.startTest();        
        System.enqueueJob(new TR_C360Flow_Queueable(evt,System.now()));
        Test.stopTest();
        List<Account> acct = [SELECT PersonEmail,PassportNumber__pc FROM Account WHERE PersonEmail ='IASC001@IASCtest.com' LIMIT 1];
    }
}