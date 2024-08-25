@isTest
public with sharing class TWIST_AppSettings_UTIL_TEST {
    
    public static final Map<String,String> akamaizedCommunityUrl = new Map<String,String> {
        'key' => 'akamaizedCommunityUrl',
        'value' => 'https://account-dev.louisvuitton.com/'
    };

    @isTest
    public static void test_description() {
        // Given
        String key = akamaizedCommunityUrl.get('key');

        // When
        Object result = TWIST_AppSettings_UTIL.getSetting(key);

        // Then
        System.assertEquals(akamaizedCommunityUrl.get('value'), (String) result);
    }
    
}