@isTest
public with sharing class TWIST_i18nCustomLabels_CTRL_TEST {
    
    @isTest
    static void test_init() {
        // Given
        TWIST_i18nCustomLabels_CTRL ctrl = new TWIST_i18nCustomLabels_CTRL();
        // When
        ctrl.init();
        // Then
        System.assert(ctrl.customLabels.equals(new List<String> { 'label1', 'label2', 'label3'}), 'ERROR');
    }

}