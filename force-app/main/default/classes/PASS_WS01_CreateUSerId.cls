/*  
*** Balink January 2017
*** DESCRIPTION: WebService From LV to SF with goal to create new User Identity
***
*/
@RestResource(urlMapping='/CreateIdentity')
global with sharing class PASS_WS01_CreateUSerId  {

    /*
    *** DESCRIPTION Create a user Identity.
    ***             Before, save the actual database.
    ***             Throw exceptions in case of duplicata, required field missing ... and rollback the database.   
    *** RETURN      The new user with its id and username
    */
    @HttpPost
    global static IDENTITY_Utils.ResponseHandler createUserIdentity() {
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        // The body response must be as array format 
        IDENTITY_Utils.ResponseHandler response = new IDENTITY_Utils.ResponseHandler();
        List<IDENTITY_Utils.ResponseHandler> resL = new List<IDENTITY_Utils.ResponseHandler>();
        
        Savepoint sp = Database.setSavepoint();

        Map<String,Object> parameters = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());

        try {

            User uIdentity;
            Account account = Identity_Utils.toAccount(parameters);

            // Set Login Phone
            if(String.isEmpty(account.LoginPhone__pc) && !String.isEmpty(account.LocalLoginPhone__pc) && !String.isEmpty(account.LoginPhoneCallingCode__pc)){
                account.LoginPhone__pc = Identity_Utils.getMobilePhone(account.LoginPhoneCallingCode__pc, account.LocalLoginPhone__pc);
            }

            // Migration Case: email and phone are sent; if user already exsit, update it else create new one 
            String userId;
            if(!String.isEmpty(account.LoginPhone__pc) && !String.isEmpty(account.PersonEmail)){
                List<User> users = [SELECT Id FROM User WHERE (TECH_Email__c =: account.PersonEmail OR TECH_MobilePHone__c =: account.LoginPhone__pc)];
                if(!users.isEmpty()){
                    userId = users[0].Id;
                }
            }

            if(String.isEmpty(userId)){
                uIdentity = Identity_Utils.createMylvClient(account, (String)parameters.get('password'));
            }
            else {
                uIdentity = Identity_Utils.updateMylvClient(account, userId);
                Identity_Utils.updatePassword(userId, (String)parameters.get('password'));
            }

            uIdentity = new User( 
                Id = uIdentity.Id,
                Username = uIdentity.Username
            );

            // 1. SELECT AccountID FROM User
            String newAccountId = [
                SELECT AccountId
                FROM User
                WHERE Id =: uIdentity.Id
                LIMIT 1
            ].AccountId;

            response = new IDENTITY_Utils.ResponseHandler('success', Label.SM_user_created, uIdentity, newAccountId);
            resL.add(response);

            res.statusCode = 200;
            res.responseBody = Blob.valueOf( JSON.serialize(resL) );
            return response;
        } 
        catch(Exception e) {

            Database.rollback(sp);

            String error = getExceptionMessage(e.getMessage(), (String)parameters.get('password'));
            response = new IDENTITY_Utils.ResponseHandler('error', error);
            resL.add(response);

            res.statusCode = 400;
            res.responseBody = Blob.valueOf( JSON.serialize(resL) );

            return response;
        }
    }

    public static String getExceptionMessage(String message, String password) {
        if(message.contains('INVALID_NEW_PASSWORD')) {
            if(password.length() < 6 || !Pattern.matches('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$', password)) {
                return Label.EM_password_too_short_or_not_contains_number_or_uppercase;
            }
            else {
                return Label.EM_password_too_easy;
            }
        }
        else if(message.contains('INVALID_PASSWORD_TOO_LONG')) {
            return Label.EM_password_too_long;
        }
        else if(message.contains('INVALID_EMAIL_ADDRESS')) {
            return Label.EM_invalid_email_adress;
        }
        else if(message.contains('REQUIRED_FIELD_MISSING')) {
            return Label.EM_required_field_missing;
        }
        else if(message.contains('PORTAL_USER_ALREADY_EXISTS_FOR_CONTACT')) {
            return Label.EM_user_already_exist;
        }
        else if(message.contains('DUPLICATE_VALUE') || message.contains('DUPLICATE_USERNAME')) {
            return Label.EM_Duplicate_Username;
        }

        return message;
    }
}