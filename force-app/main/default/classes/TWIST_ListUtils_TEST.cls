@isTest
public with sharing class TWIST_ListUtils_TEST {
    
    @isTest
    public static void test_filterByMapKeyValues_boundaryCase() {
        System.assertEquals(new Map<String,Object>(), TWIST_ListUtils.filterByMapKeyValues(null, 'key', 'value'), 'ERROR');
        System.assertEquals(new Map<String,Object>(), TWIST_ListUtils.filterByMapKeyValues(new List<Object>(), 'key', 'value'), 'ERROR');
    }

    @isTest
    public static void test_filterByMapKeyValues_shouldReturnEmptyMap() {
        // Given
        List<Map<String,Object>> listToFilter = new List<Map<String,Object>> {
            new Map<String,Object> {
                'animal' => 'dog',
                'sound' => 'wof',
                'age' => 3.5,
                'male' => true
            },
            new Map<String,Object> {
                'animal' => 'dog',
                'sound' => 'wof',
                'age' => 1,
                'male' => false
            },
            new Map<String,Object> {
                'animal' => 'cat',
                'sound' => 'meow',
                'age' => 2,
                'male' => true
            }
        };

        // When
        Map<String,Object> result1 = TWIST_ListUtils.filterByMapKeyValues((List<Object>) listToFilter, 'animal', 'fish');
        Map<String,Object> result2 = TWIST_ListUtils.filterByMapKeyValues((List<Object>) listToFilter, 'dummy_key', 'dummy_value');

        // Then
        System.assertEquals(new Map<String,Object>(), result1, 'ERROR');
        System.assertEquals(new Map<String,Object>(), result2, 'ERROR');
    }

    @isTest
    public static void test_filterByMapKeyValues_shouldReturnMap() {
        // Given
        List<Map<String,Object>> listToFilter = new List<Map<String,Object>> {
            new Map<String,Object> {
                'animal' => 'dog',
                'sound' => 'wof',
                'age' => 3.5,
                'male' => true
            },
            new Map<String,Object> {
                'animal' => 'dog',
                'sound' => 'wof',
                'age' => 1,
                'male' => false
            },
            new Map<String,Object> {
                'animal' => 'cat',
                'sound' => 'meow',
                'age' => 2,
                'male' => true
            }
        };

        // When
        Map<String,Object> result = TWIST_ListUtils.filterByMapKeyValues((List<Object>) listToFilter, 'male', false);

        // Then
        System.assertEquals('dog', String.valueOf(result.get('animal')), 'ERROR');
        System.assertEquals('wof', String.valueOf(result.get('sound')), 'ERROR');
        System.assertEquals(1, Integer.valueOf(result.get('age')), 'ERROR');
    }
}