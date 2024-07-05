@RestResource(urlMapping='/contactability')
global without sharing class IDENTITY_WS_Contactability  {

    @HttpPost
    global static void create() {
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;

        try{
            Account acc = (Account)JSON.deserialize(RestContext.request.requestBody.toString(), Account.class);

            // UPSERT BY DREAM ID
            if(!String.isEmpty(acc.DREAMID__c)){
                if(upsertAccountByFieldValue('DREAMID__c', acc.DREAMID__c, acc)){
                    res.responseBody = Blob.valueOf(JSON.serialize(new Response(SUCCESS)));
                    return;
                }
            }

            // UPSERT BY SF ID
            if(!String.isEmpty(acc.Id)){
                if(upsertAccountByFieldValue('Id', acc.Id, acc)){
                    res.responseBody = Blob.valueOf(JSON.serialize(new Response(SUCCESS)));
                    return;
                }
            }

            // GET CLIENT BY FIRSTNAME / LASTNAME / EMAIL OR MOBILE
            if(!String.isEmpty(acc.Firstname) && !String.isEmpty(acc.Lastname) && (!String.isEmpty(acc.PersonEmail) || !String.isEmpty(acc.PersonMobilePhone))){
                upsertAccountByFieldsValue(acc);
                res.responseBody = Blob.valueOf(JSON.serialize(new Response(SUCCESS)));
                return;
            }

            // GET CLIENT BY EMAIL
            if(!String.isEmpty(acc.PersonEmail)){
                if(upsertAccountsByFieldValue('PersonEmail', acc.PersonEmail, acc)){
                    res.responseBody = Blob.valueOf(JSON.serialize(new Response(SUCCESS)));
                    return;
                }
            }

            // GET CLIENT BY MOBILE
            if(!String.isEmpty(acc.PersonMobilePhone)){
                if(upsertAccountsByFieldValue('PersonMobilePhone', acc.PersonMobilePhone, acc)){
                    res.responseBody = Blob.valueOf(JSON.serialize(new Response(SUCCESS)));
                    return;
                }
            }

            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new Response(ERROR, NO_CLIENT)));
        }
        catch(Exception ex){

            new Logs.ERROR('IDENTITY_WS_Contactability', 'API', ex);
            
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new Response(ERROR, ex.getMessage())));
        }
    }


    /*********   HELPER METHODS   *********/


    /*
    *** DESCRIPTION Get account according dream id or SF id
    *** RETURN      Boolean
    */
    global static Boolean upsertAccountByFieldValue(String field, String value, Account new_acc){
        Account[] accs = Database.query('SELECT Id FROM Account WHERE ' + field + ' = \'' + value + '\'');
        if(!accs.IsEmpty()){
            new_acc.Id = accs[0].Id;
            Database.upsert(new_acc);
            return true;
        }

        return false;
    }

    /*
    *** DESCRIPTION Get account according Firstname, Lastname, Email or Mobile or create new one
    *** RETURN      User
    */
    global static Boolean upsertAccountByFieldsValue(Account new_acc){
        Account[] accs;

        if(!String.isEmpty(new_acc.PersonEmail) && !String.isEmpty(new_acc.PersonMobilePhone)){
            accs = [SELECT Id
                FROM Account
                WHERE LastName =: new_acc.LastName AND FirstName =: new_acc.FirstName AND (PersonEmail =: new_acc.PersonEmail OR PersonMobilePhone =: new_acc.PersonMobilePhone)
                ORDER BY LastTrans__pc, LastModifiedDate DESC
            ];
        }
        else if(!String.isEmpty(new_acc.PersonEmail)){
            accs = [SELECT Id
                FROM Account
                WHERE LastName =: new_acc.LastName AND FirstName =: new_acc.FirstName AND PersonEmail =: new_acc.PersonEmail
                ORDER BY LastTrans__pc, LastModifiedDate DESC
            ];
        }
        else if(!String.isEmpty(new_acc.PersonMobilePhone)){
            accs = [SELECT Id
                FROM Account
                WHERE LastName =: new_acc.LastName AND FirstName =: new_acc.FirstName AND PersonMobilePhone =: new_acc.PersonMobilePhone
                ORDER BY LastTrans__pc, LastModifiedDate DESC
            ];
        }
        else {
            accs = new List<Account>();
        }

        if(!accs.isEmpty()){
            new_acc.Id = accs[0].Id;
        }
        
        Database.upsert(new_acc);

        return true;
    }

    /*
    *** DESCRIPTION Update all acounts according Email or Mobile Phone
    *** RETURN      User
    */
    global static Boolean upsertAccountsByFieldValue(String field, String value, Account new_acc){
        Account[] accs = Database.query('SELECT Id FROM Account WHERE ' + field + ' = \'' + value + '\'');
        if(!accs.IsEmpty()){
            Account[] accs_to_update = new List<Account>();
            for(Account acc : accs){
                Account acc_to_update = new_acc.clone(false);
                acc_to_update.Id = acc.Id;
                accs_to_update.add(acc_to_update);
            }

            Database.upsert(accs_to_update, false);
            return true;
        }

        return false;
    }


    /*********   HELPER WRAPPER   *********/
    static String SUCCESS = 'success';
    static String ERROR = 'error';
    static String NO_CLIENT = 'NO_CLIENT';

    global class Response {
        String status;
        String message;

        global Response(String status){
            this.status = status;
        }

        global Response(String status, String message){
            this.status = status;
            this.message = message;
        }
    }
}