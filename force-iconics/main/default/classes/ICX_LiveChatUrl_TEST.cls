@isTest
public class ICX_LiveChatUrl_TEST {
 
    @testSetup static void setup() {
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
         
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.Nature__c = 'Product Information';
        lct.LiveChatVisitorId = lcv.id;
		insert lct;    
    }
    @isTest
    public static void getData_Test() {
        Test.startTest();
		String str = '';
        LiveChatTranscript lct = [select id FROM LiveChatTranscript];       
        str = ICX_LiveChatUrl.getData(lct.id);
  		Test.stopTest();
    }

}