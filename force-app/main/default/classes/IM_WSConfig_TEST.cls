@isTest
private class IM_WSConfig_TEST {
    
    @isTest 
    static void test_method_one() {
        User u = IC_TestFactory.createUser('test@test.com');
        u.ProfileId = IC_UTILS.getSAManagerProfile();
        u.Country__c = 'Argentina';
        u.Primary_App__c = 'Icon';
        u.IsActive = true;
        u.IsTechnicalUser__c = false;
        insert u;

        test.startTest();
        System.runAs(u){
            RestRequest request = new RestRequest();
            request.requestUri =
                'https://louisvuitton--devrelease.cs11.my.salesforce.com/services/apexrest/GetPicklistValue';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            IM_WSConfig.WSConfig();
            IM_WSConfig.WSConfig();
            IM_WSConfig.WSConfigPost();
        }
        test.stopTest();
    }

    @TestSetup
    public static void setup() {

        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );

        insert new IM_PicklistConfig__c(Name='Event_ActionType__c',
            FieldName__c = 'ActionType__c',
            ObjectName__c = 'Event',
            Values__c = 'Email;SMS;Phone;Face to Face;Call;Letter',
            GetCustomLabels__c = true
        );
        insert new IM_PicklistConfig__c(Name='Event_ActionType__c',
            FieldName__c = 'ActionType__c',
            ObjectName__c = 'Event',
            Values__c = 'Email;SMS;Phone;Face to Face;Call;Letter'
        );
        insert new IM_PicklistConfig__c(Name='Event_ActionType__c',
            FieldName__c = 'ActionType__c',
            ObjectName__c = 'Event',
            Values__c = '',
            Exclude_Fields__c = 'aa'
        );
        insert new IM_PicklistConfig__c(Name='Survey_RootCause__c',
            FieldName__c = 'RootCause__c',
            ObjectName__c = 'VO_Survey__c',
            Values__c = '',
            ControllingFieldName__c = 'SurveyType__c'
        );
            
        insert new CountryConfig__c(
            Name='Argentina',ClientNameDisplay__c='LNFN',
            Kakao__c=true,Law_Settings__c=true,Line__c=true,SecondName__c=true,
            Wechat__c=true,WhatsApp__c=true
        );
        insert new CountryConfig__c(
            Name='USA',ClientNameDisplay__c='LNFN',
            Kakao__c=true,Law_Settings__c=true,Line__c=true,SecondName__c=true,
            Wechat__c=true,WhatsApp__c=true
        );
    }
    
}