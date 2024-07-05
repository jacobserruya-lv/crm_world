@isTest
public with sharing class TWIST_i18nCustomLabels_TEST {
    
    @isTest
    static void test_translateLabelsWhenLanguageIsNullShouldReturnEmptyMap() {
        // Given
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Confirm_Button' };
        // When
        Map<String,Object> translation = TWIST_i18nCustomLabels.translateLabelsList(customLabels, null);
        // Then
        System.assert(translation.isEmpty(), 'ERROR');
    }

    @isTest
    static void test_translateLabelsWhenCustomLabelsIsEmptyShouldReturnEmptyMap() {
        // Given
        List<String> customLabels = new List<String>();
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nCustomLabels.translateLabelsList(customLabels, langCountry);
        // Then
        System.assert(translation.isEmpty(), 'ERROR');
    }

    @isTest
    static void test_translateLabelsNominalCase() {
        // Given
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Cancel_Button', 'IDENTITY_Activation_Confirm_Button', 'IDENTITY_LOGIN_Section_Title' };
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nCustomLabels.translateLabelsList(customLabels, langCountry);
        // Then
        // System.assertEquals(customLabels.size(), translation.size(), 'ERROR');
        System.assertEquals(customLabels, new List<String>(translation.keySet()), 'ERROR');
    }
      @isTest
    static void testTranslateSingleLabel() {
        // Arrange
        String label = 'IDENTITY_Activation_Confirm_Button';
        String language = 'fra-fr';

        // Act
        String result = TWIST_i18nCustomLabels.translateSingleLabel(label, language);

        // Assert
        System.assertNotEquals(result, null);
        System.assertEquals(result, 'CUSTOM_LABEL');
    }
}