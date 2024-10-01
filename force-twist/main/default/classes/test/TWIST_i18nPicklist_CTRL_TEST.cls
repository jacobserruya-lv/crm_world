@isTest
public with sharing class TWIST_i18nPicklist_CTRL_TEST {

    @isTest
    static void test_initPicklistParam() {
        // Given
        PageReference pageRef = Page.TWIST_i18nPicklist;
        pageRef.getParameters().put('picklist','Countries');
        Test.setCurrentPage(pageRef);
        TWIST_i18nPicklist_CTRL ctrl = new TWIST_i18nPicklist_CTRL();
        // When
        ctrl.init();
        // Then
        System.assertNotEquals(ctrl.picklistValues, null,'ERROR');
    }

}