@isTest
private class Logs_TEST {
    
    @isTest
	public static void test_constructor_globalTest() {
		// Given
        String level = 'level';
        String apexClass = 'apexClass';
        String category = 'category';
        String application = 'application';
        String message = 'message';
        String status_code = 'status_code';
        String type = 'type';
        String details = 'details';
        String recordId = 'recordId';
        String endpoint = 'endpoint';
        String request = 'request';
        String headers = 'headers';
        String parameters = 'parameters';
        String response = 'response';
        String addressIp = 'addressIp';
        CustomException exception_case = new CustomException('message');
        HTTP_Utils http = new HTTP_Utils();
		Map<String,Object> logMap = new Map<String,Object> {
            'level' => level,
            'apexClass' => apexClass,
            'category' => category,
            'application' => application,
            'message' => message,
            'status_code' => status_code,
            'type' => type,
            'details' => details,
            'recordId' => recordId,
            'endpoint' => endpoint,
            'request' => request,
            'headers' => headers,
            'parameters' => parameters,
            'response' => response,
            'addressIp' => addressIp,
            'exception_case' => exception_case,
            'http' => http
		};

		// When ,
		Test.startTest();
		Logs logs = new Logs(logMap);
		Test.stopTest();

		// Then
        System.assertEquals(level, logs.level, 'ERROR');
        System.assertEquals(apexClass, logs.apexClass, 'ERROR');
        System.assertEquals(category, logs.category, 'ERROR');
        System.assertEquals(application, logs.application, 'ERROR');
        System.assertEquals(message, logs.message, 'ERROR');
        System.assertEquals(status_code, logs.status_code, 'ERROR');
        System.assertEquals(type, logs.type, 'ERROR');
        System.assertEquals(details, logs.details, 'ERROR');
        System.assertEquals(recordId, logs.recordId, 'ERROR');
        System.assertEquals(endpoint, logs.endpoint, 'ERROR');
        System.assertEquals(request, logs.request, 'ERROR');
        System.assertEquals(headers, logs.headers, 'ERROR');
        System.assertEquals(parameters, logs.parameters, 'ERROR');
        System.assertEquals(response, logs.response, 'ERROR');
        System.assertEquals(addressIp, logs.addressIp, 'ERROR');
        System.assertEquals(exception_case.getMessage(), logs.exception_case.getMessage(), 'ERROR');
        System.assertEquals(http, logs.http, 'ERROR');
	}
    @isTest
	public static void test_SpecificClass() {
		// Given
        String level = 'INFO';
        String apexClass = 'IDENTITY_Registration_CTRL';
		Map<String,Object> logMap = new Map<String,Object> {
            'level' => level,
            'apexClass' => apexClass
		};

		// When ,
		Test.startTest();
		Logs logs = new Logs(logMap);
		Test.stopTest();
        // Then
        System.assertEquals(level, logs.level, 'ERROR');
        System.assertEquals(apexClass, logs.apexClass, 'ERROR');
	}
    
    @isTest
    public static void testWillWrite() {
        // Créez des données de test JSON
        String jsonData = '{"Apex_Class__c": "IDENTITY_Registration_CTRL", "Message__c": "EMAIL SENT"}';

        // Appelez la méthode à tester
        Test.startTest();
        Logs.willWrite(jsonData);
        Test.stopTest();

        // Vérifiez que l'objet a été inséré avec succès
        List<Logs__c> logsList = [SELECT Id, Apex_Class__c, Message__c FROM Logs__c WHERE Apex_Class__c = 'IDENTITY_Registration_CTRL' LIMIT 1];
        System.assertNotEquals(0, logsList.size(), 'L\'objet Logs__c n\'a pas été inséré avec succès.');
    }

    @isTest
    public static void testWillWriteException() {
        // Créez des données de test JSON incorrectes
        String jsonData = 'Invalid JSON';

        // Appelez la méthode à tester
        Test.startTest();
        Logs.willWrite(jsonData);
        Test.stopTest();
    }

    @isTest
    public static void test_constructor_isFutureAttribute() {
        // Given
        Boolean isFuture1;
        Boolean isFuture2 = true;
        Boolean isFuture3 = false;

        // When
        Test.startTest();
		Logs logs1 = new Logs(new Map<String,Object> { 'isFuture' => isFuture1 });
		Logs logs2 = new Logs(new Map<String,Object> { 'isFuture' => isFuture2 });
		Logs logs3 = new Logs(new Map<String,Object> { 'isFuture' => isFuture3 });
		Test.stopTest();

        // Then
        System.assertEquals(false, logs1.isFuture, 'ERROR');
        System.assertEquals(true, logs2.isFuture, 'ERROR');
        System.assertEquals(false, logs3.isFuture, 'ERROR');
    }

    @isTest
    public static void test_constructor_needSalesforceIpAttribute() {
        // Given
        Boolean needSalesforceIp1;
        Boolean needSalesforceIp2 = true;
        Boolean needSalesforceIp3 = false;

        // When
        Test.startTest();
		Logs logs1 = new Logs(new Map<String,Object> { 'needSalesforceIp' => needSalesforceIp1 });
		Logs logs2 = new Logs(new Map<String,Object> { 'needSalesforceIp' => needSalesforceIp2 });
		Logs logs3 = new Logs(new Map<String,Object> { 'needSalesforceIp' => needSalesforceIp3 });
		Test.stopTest();

        // Then
        System.assertEquals(false, logs1.needSalesforceIp, 'ERROR');
        System.assertEquals(true, logs2.needSalesforceIp, 'ERROR');
        System.assertEquals(false, logs3.needSalesforceIp, 'ERROR');
    }
    
    @isTest
    static void test_method_one() {
        Test.startTest();
        new Logs.ERROR('Fractalist_API', 'CALLOUT', new CustomException('ERROR'));
        new Logs.ERROR('Fractalist_API', 'CALLOUT', new CustomException('ERROR'), 'details');
        new Logs.ERROR('Fractalist_API', 'CALLOUT', new CustomException('ERROR'), 'details', '001GYJDGJd1456');
        new Logs.ERROR('Fractalist_API', 'CALLOUT', 'ERROR');
        new Logs.ERROR('Fractalist_API', 'CALLOUT', 'ERROR', 'details');
        new Logs.ERROR('Fractalist_API', 'CALLOUT', 'ERROR', 'request', 'response');
        
        new Logs.INFO('Fractalist_API', 'CALLOUT', 'INFO');
        new Logs.INFO('Fractalist_API', 'CALLOUT', 'INFO', 'details');
        new Logs.INFO('Fractalist_API', 'CALLOUT', 'INFO', 'request', 'response', 'status');
        
        new Logs.WARN('Fractalist_API', 'CALLOUT', 'WARN');
        
        new Logs.DEBUG('Fractalist_API', 'CALLOUT', 'WARN');
        
        new Logs.FUTURE('INFO', 'Fractalist_API', 'CALLOUT', 'endpoint', 'request', 'response', new CustomException('ERROR'), 'INFO', 'request', 'response', 'status', false);
        Test.stopTest();
    }

    class CustomException extends Exception{}

}