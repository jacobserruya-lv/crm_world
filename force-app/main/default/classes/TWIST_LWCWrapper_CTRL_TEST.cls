@isTest
public class TWIST_LWCWrapper_CTRL_TEST {
    @isTest
    static void testInit() {
         // Given
         Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
         Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
         List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
         String utmCampaign = picklistValuesOfferCode.get(0).getValue();
 
        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('lang-country','eng-e1');
        pageRef.getParameters().put('origin','mylv');
        pageRef.getParameters().put('cid','cid123');
        pageRef.getParameters().put('utm_campaign',utmCampaign);
        Test.setCurrentPage(pageRef);
        TWIST_LWCWrapper_CTRL controller = new TWIST_LWCWrapper_CTRL();
        PageReference result = controller.init();
        TWIST_LWCWrapper_CTRL.getLVappRedirectionLink('cid123', 'myexclusive');
        System.assertNotEquals(null, controller.utagDataStringified);
    }

}