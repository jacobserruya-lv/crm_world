@isTest
public with sharing class MapUtils_TEST {
    
    @isTest
    public static void test_getMapByKeys_nominalCase() {
        // Given
        Map<String,Object> m = new Map<String,Object> {
            'key1' => false,
            'key2' => 123,
            'key3' => 'string'
        };
        Set<String> keyset1 = new Set<String> { 'key1', 'key3', 'key2' };
        Set<String> keyset2 = new Set<String> { 'key1', 'key3' };
        Set<String> keyset3 = new Set<String> { 'key2' };
        Map<String,Object> expected1 = m.clone();
        Map<String,Object> expected2 = m.clone();
        expected2.remove('key2');
        Map<String,Object> expected3 = m.clone();
        expected3.remove('key1');
        expected3.remove('key3');

        // When
        Map<String,Object> result1 = MapUtils.getMapByKeys(m, keyset1);
        Map<String,Object> result2 = MapUtils.getMapByKeys(m, keyset2);
        Map<String,Object> result3 = MapUtils.getMapByKeys(m, keyset3);

        // Then
        System.assertEquals(expected1, result1, 'ERROR');
        System.assertEquals(expected2, result2, 'ERROR');
        System.assertEquals(expected3, result3, 'ERROR');
    }

    @isTest
    public static void test_getMapByKeys_shouldReturnEmptyMap() {
        // Given
        Map<String,Object> emptyMap = new Map<String,Object>();
        Map<String,Object> m = new Map<String,Object> {
            'key1' => false,
            'key2' => 123,
            'key3' => 'string'
        };
        Set<String> keyset1 = new Set<String>();
        Set<String> keyset2 = new Set<String> { 'key4', 'key5' };

        // When
        Map<String,Object> result1 = MapUtils.getMapByKeys(emptyMap, keyset1);
        Map<String,Object> result2 = MapUtils.getMapByKeys(emptyMap, keyset2);
        Map<String,Object> result3 = MapUtils.getMapByKeys(m, keyset1);
        Map<String,Object> result4 = MapUtils.getMapByKeys(m, keyset2);
        
        // Then
        System.assert(result1.isEmpty(), 'ERROR');
        System.assert(result2.isEmpty(), 'ERROR');
        System.assert(result3.isEmpty(), 'ERROR');
        System.assert(result4.isEmpty(), 'ERROR');
    }

    @isTest
    public static void test_getMapByKeys_shouldReturnNull() {
        // Given
        Map<String,Object> m = new Map<String,Object> {
            'key1' => false,
            'key2' => 123,
            'key3' => 'string'
        };
        Set<String> keyset = new Set<String> { 'key1', 'key2' };

        // When
        Map<String,Object> result1 = MapUtils.getMapByKeys(m, null);
        Map<String,Object> result2 = MapUtils.getMapByKeys(null, keyset);
        Map<String,Object> result3 = MapUtils.getMapByKeys(null, null);
        
        // Then
        System.assertEquals(null, result1, 'ERROR');
        System.assertEquals(null, result2, 'ERROR');
        System.assertEquals(null, result3, 'ERROR');
    }

}