@isTest
public with sharing class StringUtils_TEST {
    
    @isTest
    public static void test_isValidBase64() {
        // Given
        String s1 = 'VGhpcyBzdHJpbmcgaGFzIGFjdHVhbGx5IGJlZW4gYmFzZTY0IGVuY29kZWQh';
        String s2 = 'This string is not base64 encoded!';

        // Then
        System.assert(StringUtils.isValidBase64(s1));
        System.assert(!StringUtils.isValidBase64(s2));
    }

    @isTest
    public static void test_camelCaseToKebabCase() {
        // Given
        String input1 = null;
        String input2 = '';
        String input3 = '123';
        String input4 = 'camelCaseString';
        String input5 = 'kebab-case-string';

        // Then
        System.assertEquals(null, StringUtils.camelCaseToKebabCase(input1));
        System.assertEquals('', StringUtils.camelCaseToKebabCase(input2));
        System.assertEquals(input3, StringUtils.camelCaseToKebabCase(input3));
        System.assertEquals('camel-case-string', StringUtils.camelCaseToKebabCase(input4));
        System.assertEquals(input5, StringUtils.camelCaseToKebabCase(input5));
    }

    @isTest
    static void test_generateRandomString() {
        // Given
        Integer length = 10;
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        // When
        String randomString = StringUtils.generateRandomString(length, chars);
        // Then
        System.assertEquals(length, randomString.length(), 'ERROR');
    }

}