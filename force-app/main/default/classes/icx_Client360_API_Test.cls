@isTest
public class icx_Client360_API_Test {
    public static Integer UUID = 0;

    public static Integer getUUID(){ return( ++UUID ); }

    public static String makeUnique( String str ){
        return( '' + str + getUUID() );
    }

@testSetup static void setup()
{
    Id profileId =[select Id from Profile where Name = 'ICONiCS_SA'].Id;
    String alias = makeUnique( 'atest_' );
    String email = '' + alias + '@test.com';
    User currentUser = new User(
        username = email,
        email = email,
        alias = alias,
        profileId = profileId,
        emailEncodingKey = 'UTF-8',
        firstName = 'Nicollllas',
        lastName = alias,
        localeSIDKey = 'en_US',
        languageLocaleKey = 'en_US',
        timezoneSIDKey = 'America/Los_Angeles',
        Country__c = 'FRANCE'
    );
    
    
    insert currentUser;
}

    @isTest static void getSearchDataTest() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getSearchResults');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object result = icx_Client360_API.getSearchResults('Yan');
            System.assertNotEquals(null,result, 'The callout returned a null response.');
        }
        Test.stopTest();

      }
    @isTest static void getSearchDataTestError() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
       try {
        Test.startTest();
        mock.setStaticResource('C360Error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object result = icx_Client360_API.getSearchResults('Yan');
            System.assertNotEquals(null,result, 'The callout returned a null response.');

        }
        Test.stopTest();

           
       } catch (Exception e) {
                System.debug('getSearchDataTestError error : ' + e);

       }
        
      }
    @isTest static void getAdvancedSearchDataTest() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getSearchResults');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object result = icx_Client360_API.getAdvancedSearchResults('Yan');
            System.assertNotEquals(null,result, 'The callout returned a null response.');
        }
        Test.stopTest();

     }
    @isTest static void getAdvancedSearchDataTestError() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        
        try {
            Test.startTest();
            mock.setStaticResource('C360Error');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            system.runAs(currentUser)
            {

                Object result = icx_Client360_API.getAdvancedSearchResults('Yan');
                System.assertNotEquals(null,result, 'The callout returned a null response.');
            }
            Test.stopTest();
        } catch (System.Exception e) {
            System.debug('getAdvancedSearchDataTestError error : ' + e);

        }

     }
    // @isTest static void getPurchasesCategoryTest() {

    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('getProfileData');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     Object result = icx_Client360_API.getPurchasesCategory('1234');
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    //  }
    // @isTest static void getPurchasesHistoricalTest() {

    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('getProfileData');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     Object result = icx_Client360_API.getPurchasesHistorical('1234','Jean');
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    //  }
    // @isTest static void getPurchasesProductsTest() {

    //   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('getProfileData');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     Object result = icx_Client360_API.getPurchasesProducts('1234','5678');
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    //  }
    // @isTest static void getPurchasesProductsWithCategoriesTest() {

    //   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('getProfileData');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     Object result = icx_Client360_API.getPurchasesProductsWithCategories('1234','5678');
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    //  }
    // @isTest static void getContactActivitiesTest() {

    //   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('getProfileData');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     Object result = icx_Client360_API.getContactActivities();
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    //  }
    // @isTest static void getContactTest() {

    //   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('get_Mock_ProfileData');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     ICX_Client360_API_Helper.WrapperAccountKeyInfo result = icx_Client360_API.getContact('1');
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    //  }

    @isTest static void getProfileDataTest1() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getProfileDataUpdated');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object result = icx_Client360_API.getContact('1');
            System.assertNotEquals(null,result, 'The callout returned a null response.');
        }
        Test.stopTest();

     }
    @isTest static void getProfileDataTest1Error() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        try {
            Test.startTest();
            mock.setStaticResource('C360Error');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            system.runAs(currentUser)
            {

                Object result = icx_Client360_API.getContact('1');
                System.assertNotEquals(null,result, 'The callout returned a null response.');
            }
            Test.stopTest();
        } catch (Exception e ) {
            System.debug('getProfileDataTest1Error error : ' + e);
        }

     }
    @isTest static void getProfileDataTest2() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getProfileDataUpdated');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object result = icx_Client360_API.getContactInformation('1');
            System.assertNotEquals(null,result, 'The callout returned a null response.');
        }
        Test.stopTest();

     }

     @isTest static void getProfileDataTest2Error() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        try {
            Test.startTest();
            mock.setStaticResource('C360Error');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            system.runAs(currentUser)
            {

                Object result = icx_Client360_API.getContactInformation('1');
                System.assertNotEquals(null,result, 'The callout returned a null response.');
            }
            Test.stopTest();
        } catch (Exception e ) {
            System.debug('getProfileDataTest1Error error : ' + e);
        }

     }


    @isTest static void getPurchasesDataTest() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getPurchases');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object result = icx_Client360_API.getPurchases('1','1','NEXT',null,'3');
            System.assertNotEquals(null,result, 'The callout returned a null response.');
        }
        Test.stopTest();

    }

    @isTest static void getPurchasesDataTestError() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        try {
            Test.startTest();
            mock.setStaticResource('C360Error');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            system.runAs(currentUser)
            {

                Object result = icx_Client360_API.getPurchases('1','1','NEXT',null,'3');
                System.assertNotEquals(null,result, 'The callout returned a null response.');
            }
            Test.stopTest();
        } catch (Exception e) {}

    }

    @isTest static void getAggregatesDataTest() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getAggregatesData');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        system.runAs(currentUser)
        {

            Object resultObject = icx_Client360_API.getAggregate(currentUser.id);
            String resultString = JSON.serialize(resultObject);
            System.assertNotEquals(null,resultString, 'The callout returned a null response.');
        }
        Test.stopTest();

    }
    @isTest static void getAggregatesDataTestError() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        User currentUser = [SELECT Id,firstName FROM User WHERE firstName =: 'Nicollllas' LIMIT 1];
        
        try{
            Test.startTest();
            mock.setStaticResource('C360Error');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            system.runAs(currentUser)
            {

                Object resultObject = icx_Client360_API.getAggregate(currentUser.id);
                String resultString = JSON.serialize(resultObject);
                System.assertNotEquals(null,resultString, 'The callout returned a null response.');
            }
            Test.stopTest();
        } catch (Exception e) {}

    }


    // // @isTest static void getClientInformationTest() {

    // //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    // //     mock.setStaticResource('get_Mock_Client_Information_Data');
    // //     mock.setStatusCode(200);
    // //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    // //     Test.setMock(HttpCalloutMock.class, mock);
    // //     String result = icx_Client360_API.getClientInformations();
    // //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    // // }
    // @isTest static void getContactInformationTest() {

    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('get_Mock_Client_Information');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     Test.setMock(HttpCalloutMock.class, mock);
    //     ICX_Client360_API_Helper.WrapperClientInfo result = icx_Client360_API.getContactInformation('1324');
    //     System.assertNotEquals(null,result, 'The callout returned a null response.');

    // }
}