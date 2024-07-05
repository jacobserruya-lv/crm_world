public class ICX_AccountSummaryController {
    
    @AuraEnabled
    public static Account getAccountDetails(ID reqID)
    {
        return null;
        /*return [Select id, Salutation, FirstName, LastName, Name,
                Gender__pc, PreferredLanguage__pc, PersonBirthdate,
                DREAMID__c, Owner.name, AttachedStore__pc,
                PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc,
                PrimaryZipCode__pc, PrimaryCity__pc, PrimaryCountry__pc, 
                PersonMobilePhone, PersonHomePhone, PersonEmail,
                Segmentation__pc, indic10KImg__c, Typology__pc from Account where id in (Select Accountid from Case where id =:reqID)];*/
    }

}