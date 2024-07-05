@isTest
private class RestResource_Utils_TEST {
    
    @isTest
    public static void test_prettyJSON() {
        // Given
        String firstName = 'John';
        String lastName = 'Doe';
        String phone = '(972)531231234';
        Account account = new Account(FirstName=firstName, LastName=lastName, Phone=phone);

        // When
        Map<String,Object> json = RestResource_Utils.prettyJSON(account);

        // Then
        System.assertEquals(3, json.size(), 'ERROR');
        System.assert(json.containsKey('FirstName'), 'ERROR');
        System.assert(json.containsKey('LastName'), 'ERROR');
        System.assert(json.containsKey('Phone'), 'ERROR');
        System.assertEquals(firstName, json.get('FirstName'), 'ERROR');
        System.assertEquals(lastName, json.get('LastName'), 'ERROR');
        System.assertEquals(phone, json.get('Phone'), 'ERROR');
    }

    @isTest
    public static void test_removeAttributes_whenOneMapValueIsInstanceOfListAndOneListValueIsInstanceOfMap() {
        // Given
        Map<String,Object> mapWhichNoAttributeShouldBeRemoved = new Map<String,Object> {
            'key1' => 'Sunday',
            'key2' => 606,
            'key3' => true
        };
        List<Object> list1 = new List<Object> { 'Saturday', 613, mapWhichNoAttributeShouldBeRemoved };
        Map<String,Object> map1 = new Map<String,Object> { 'key' => list1 };

        Map<String,Object> mapWhichOneAttributeShouldBeRemoved = new Map<String,Object> {
            'key1' => 'Sunday',
            'key2' => 606,
            'attributes' => true
        };
        List<Object> list2 = new List<Object> { 'Saturday', 613, mapWhichOneAttributeShouldBeRemoved };
        Map<String,Object> map2 = new Map<String,Object> { 'key' => list2 };
        Integer mapWhichOneAttributeShouldBeRemovedOriginalKeySetSize = mapWhichOneAttributeShouldBeRemoved.keySet().size(); // store here because this map is to be changed by reference

        // When
        Map<String,Object> mapResult1 = RestResource_Utils.removeAttributes(map1, new List<String>());
        Map<String,Object> mapResult2 = RestResource_Utils.removeAttributes(map2, new List<String>());

        // Then
        System.assert(mapResult1.keySet().equals(map1.keySet()), 'ERROR');
        System.assert(mapResult1.get('key') instanceOf List<Object>, 'ERROR');
        List<Object> listResult1 = (List<Object>) mapResult1.get('key');
        System.assertEquals(list1.size(), listResult1.size(), 'ERROR');
        System.assertEquals(list1.get(0), listResult1.get(0), 'ERROR');
        System.assertEquals(list1.get(1), listResult1.get(1), 'ERROR');
        System.assert(listResult1.get(2) instanceOf Map<String,Object>, 'ERROR');
        Map<String,Object> listMapAttribute1 = (Map<String,Object>) listResult1.get(2);
        System.assert(listMapAttribute1.keySet().equals(mapWhichNoAttributeShouldBeRemoved.keySet()), 'ERROR');
        System.assertEquals(mapWhichNoAttributeShouldBeRemoved.get('key1'), listMapAttribute1.get('key1'), 'ERROR');
        System.assertEquals(mapWhichNoAttributeShouldBeRemoved.get('key2'), listMapAttribute1.get('key2'), 'ERROR');
        System.assertEquals(mapWhichNoAttributeShouldBeRemoved.get('key3'), listMapAttribute1.get('key3'), 'ERROR');

        System.assert(mapResult2.keySet().equals(map2.keySet()), 'ERROR');
        System.assert(mapResult2.get('key') instanceOf List<Object>, 'ERROR');
        List<Object> listResult2 = (List<Object>) mapResult2.get('key');
        System.assertEquals(list2.size(), listResult2.size(), 'ERROR');
        System.assertEquals(list2.get(0), listResult2.get(0), 'ERROR');
        System.assertEquals(list2.get(1), listResult2.get(1), 'ERROR');
        System.assert(listResult2.get(2) instanceOf Map<String,Object>, 'ERROR');
        Map<String,Object> listMapAttribute2 = (Map<String,Object>) listResult2.get(2);
        System.assertEquals(mapWhichOneAttributeShouldBeRemovedOriginalKeySetSize - 1, listMapAttribute2.keySet().size(), 'ERROR');
        System.assertEquals(mapWhichOneAttributeShouldBeRemoved.get('key1'), listMapAttribute2.get('key1'), 'ERROR');
        System.assertEquals(mapWhichOneAttributeShouldBeRemoved.get('key2'), listMapAttribute1.get('key2'), 'ERROR');
        System.assertEquals(false, listMapAttribute1.containsKey('attributes'), 'ERROR');
    }

    @isTest
    static void test_removeAttributes_ReturnsNullWhenFirstParameterIsNull() {
        UnitTestsHelper.assertNull(RestResource_Utils.removeAttributes(null, new List<String>()));
    }

    @isTest
    static void test_getFieldType_returnsNullWhenObjectFieldNameDoesNotExist() {
        UnitTestsHelper.assertNull(RestResource_Utils.getFieldType('dummyFieldName', 'Account'));
    }

    @isTest
    static void test_createObject() {
        // Given
        DateTime anonymizationDate = DateTime.now();
        Map<String,Object> jsonMap = new Map<String,Object> {
            'personbirthdate' => Date.today(),
            'anonymization_date__c' => anonymizationDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'),
            'accountsource' => 'Web',
            'numberofemployees' => 50,
            'annualrevenue' => Double.valueOf(10000000),
            'vic__c' => true
        };

        // When
        SObject sObj = new Account();
        SObject result = RestResource_Utils.createObject(jsonMap, 'Account', sObj);

        // Then
        System.assertEquals(jsonMap.get('personbirthdate'), result.get('personbirthdate'), 'ERROR');
        System.assertEquals(anonymizationDate, result.get('anonymization_date__c'), 'ERROR');
        System.assertEquals(jsonMap.get('accountsource'), result.get('accountsource'), 'ERROR');
        System.assertEquals(jsonMap.get('numberofemployees'), result.get('numberofemployees'), 'ERROR');
        System.assertEquals(jsonMap.get('annualrevenue'), result.get('annualrevenue'), 'ERROR');
        System.assertEquals(jsonMap.get('vic__c'), result.get('vic__c'), 'ERROR');
    }

    @isTest
    static void test_removeNulls_whenNoNullValueIsFound() {
        // Given
        Map<String,Object> aMap = new Map<String,Object> {
            'key1' => 'fafa',
            'key2' => 513705,
            'key3' => true,
            'key4' => new List<Object> { 'Monday', true, false }
        };
        String jsonString = JSON.serialize(aMap);

        // When
        Map<String,Object> resultMap = (Map<String,Object>) JSON.deserializeUntyped(RestResource_Utils.removeNulls(jsonString));

        // Then
        System.assert(aMap.keySet().equals(resultMap.keySet()), 'ERROR');
        for (String key: resultMap.keySet()) {
            System.assertEquals(aMap.get(key), resultMap.get(key), 'ERROR');
        }
    }

    @isTest
    static void test_removeNulls_whenNullValuesAreFound() {
        // Given
        Map<String,Object> aMap = new Map<String,Object> {
            'key1' => 'fafa',
            'key2' => 513705,
            'key3' => true,
            'key4' => null,
            'key5' => 0,
            'key6' => new List<Object> { 'Monday', true, false },
            'key7' => null,
            'key8' => new List<Object> { null, null, null },
            'key9' => new Map<String,Object> { 'key1' => null, 'key2' => null }
        };
        String jsonString = JSON.serialize(aMap);

        // When
        Map<String,Object> resultMap = (Map<String,Object>) JSON.deserializeUntyped(RestResource_Utils.removeNulls(jsonString));

        // Then
        System.assertEquals(aMap.size() - 2, resultMap.size(), 'ERROR');
        for (String key: resultMap.keySet()) {
            System.assertEquals(aMap.get(key), resultMap.get(key), 'ERROR');
        }
    }

    @isTest
    static void test_ErrorClassInstanciation() {
        UnitTestsHelper.assertNotNull(new RestResource_Utils.Error('dummy error message', 'dummy code'));
    }

}