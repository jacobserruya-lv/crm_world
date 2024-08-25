@istest
public with sharing class TWIST_RegistrationUtils_TEST {
    
    @isTest
    public static void test_setSocialData_passingInvalidBase64SocialIdShouldReturnEmptyMap() {
        // Given
        String base64SocialId = '!!!';

        // When
        Map<String,String> result = TWIST_RegistrationUtils.setSocialData(base64SocialId);

        // Then
        System.assert(result.isEmpty(), 'ERROR');
    }

    @isTest
    public static void test_setSocialData_passingEmptyBase64SocialIdShouldReturnEmptyMap() {
        // Given
        String base64SocialId1 = '';
        String base64SocialId2 = null;

        // When
        Map<String,String> result1 = TWIST_RegistrationUtils.setSocialData(base64SocialId1);
        Map<String,String> result2 = TWIST_RegistrationUtils.setSocialData(base64SocialId2);

        // Then
        System.assert(result1.isEmpty(), 'ERROR');
        System.assert(result2.isEmpty(), 'ERROR');
    }

    @isTest
    public static void test_setSocialData_nominalCase() {
        // Given
        Map<String,String> socialIdToBeEncoded = new Map<String,String> { 'key1' => '123', 'key2' => '    dummy-value     ' };
        String base64SocialId = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(socialIdToBeEncoded)));

        // When
        Map<String,String> result = TWIST_RegistrationUtils.setSocialData(base64SocialId);

        // Then
        System.assertEquals(socialIdToBeEncoded.keySet(), result.keySet(), 'ERROR');
        System.assertEquals(socialIdToBeEncoded.get('key1'), result.get('key1'), 'ERROR');
        System.assertEquals(socialIdToBeEncoded.get('key2').trim(), result.get('key2'), 'ERROR');
    }
    
    @isTest
    public static void test_setSocialMediaIdentifier() {
        // Given
        Test.startTest();
        List<Social_Media_Identifier__c> smiList = [SELECT Id FROM Social_Media_Identifier__c];
        List<Logs__c> logList = [SELECT Id FROM Logs__c];
        Integer originalSmiCount = smiList.size();
        Integer originalLogCount = logList.size();
        
        // When
        TWIST_RegistrationUtils.setSocialMediaIdentifier(
            Identity_TestFactory.createAccount('test1', 'test1', 'dummy@dummy-test.com', '133456789', '972', true),
            new Map<String,String> {
                'social_id' => 'dummy-value',
                'social_media_type' => 'Line',
                'nickname' => 'dummy-value'
            },
            'dummy-user-id'
        );

        // Then
        smiList = [SELECT Id FROM Social_Media_Identifier__c];
        logList = [SELECT Id FROM Logs__c];
        Test.stopTest();
        System.assertEquals(originalSmiCount + 1, smiList.size());
        System.assertEquals(originalLogCount + 1, logList.size());
    }

}