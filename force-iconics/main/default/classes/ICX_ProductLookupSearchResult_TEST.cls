@isTest
public class ICX_ProductLookupSearchResult_TEST {

    @isTest
    public static void ICX_ProductLookupSearchResult_ConstructorTest() {

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;

        // No real assert validation required for this wrapper class
        ICX_ProductLookupSearchResult result = new ICX_ProductLookupSearchResult(call.Id, 'Task', 'icon', true, 'title', 'subtitle', false, null);
        //Id id, String sObjectType, String icon, Boolean isIconUrl, String title, String subtitle, Boolean readOnly, ICX_ProductEnquired__c qualification
        System.assertEquals(call.Id, result.getId()); 
    }

    @isTest
    public static void ICX_ProductLookupSearchResult_Constructor2Test() {

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;

        // No real assert validation required for this wrapper class
        ICX_ProductLookupSearchResult result = new ICX_ProductLookupSearchResult(call.Id, 'Task', 'icon', true, 'title', 'subtitle', null, null, null);
        //Id id, String sObjectType, String icon, Boolean isIconUrl, String title, String subtitle, Boolean readOnly, ICX_ProductEnquired__c qualification
        System.assertEquals(call.Id, result.getId()); 
    }

    @isTest
    public static void getterCheck() {
        ICX_ProductLookupSearchResult result = new ICX_ProductLookupSearchResult(null, 'Task', 'icon', true, 'title', 'subtitle', null, null, null);
        result.getId();
        result.getSObjectType();
        result.getIcon();
        result.getTitle();
        result.getSubtitle();
        result.getIsIconUrl();
        result.getRelatedId();
        result.getRelatedName();
        result.getQualification();
        result.cloneForRequestCreation = true;
        
        System.assertEquals('Task',result.getSObjectType()); 
    }
}