// This logic should be implemented at integration level
// when mulesoft is creating a careService with no email or phone specified
// Worldwide the email or phone should not be override

trigger TodeleteAccountBeforeUpdate on Account (before update) {
    System.debug('triggeraccountBefore');
    String currentUserId = UserInfo.getUserId();
    System.debug('triggeraccountBefore' + UserInfo.getUserId());
    if(currentUserId == '0050H00000BVfjyQAD')
    {
    Set<Id> accountIds = new Set<Id>();
    for (Account acc : Trigger.new) {
        accountIds.add(acc.Id);
    }

    Map<ID, Account> lstAcc = new Map<ID, Account>([SELECT Id, PersonMobilePhone, PersonEmail, LocalMobilePhone__pc, LocalWorkPhone__pc, Store__pr.Store_CountryCode__c, Source__c, PersonHomePhone FROM Account WHERE Id IN :accountIds]);
    // Loop through all updated Account record
    for (Account acc : Trigger.new) {
        // Check if the Account's Store is set to China
        // if (lstAcc.get(acc.Id).Source__c == 'WeChat') {
            // Check if the PersonMobilePhone or PersonEmail fields have been cleared or set to empty
            if ((acc.PersonMobilePhone == null || String.isBlank(acc.PersonMobilePhone)) &&
                Trigger.oldMap.get(acc.Id).PersonMobilePhone != null) {
                // Set the PersonMobilePhone field to its original value
                acc.PersonMobilePhone = Trigger.oldMap.get(acc.Id).PersonMobilePhone;
            }
            if ((acc.PersonEmail == null || String.isBlank(acc.PersonEmail)) &&
                Trigger.oldMap.get(acc.Id).PersonEmail != null) {
                // Set the PersonEmail field to its original value
                acc.PersonEmail = Trigger.oldMap.get(acc.Id).PersonEmail;
            }
            if ((acc.LocalMobilePhone__pc == null || String.isBlank(acc.LocalMobilePhone__pc)) &&
                Trigger.oldMap.get(acc.Id).LocalMobilePhone__pc != null) {
                // Set the LocalMobilePhone__pc field to its original value
                acc.LocalMobilePhone__pc = Trigger.oldMap.get(acc.Id).LocalMobilePhone__pc;
            }
            if ((acc.LocalWorkPhone__pc == null || String.isBlank(acc.LocalWorkPhone__pc)) &&
                Trigger.oldMap.get(acc.Id).LocalWorkPhone__pc != null) {
                // Set the LocalWorkPhone__pc field to its original value
                acc.LocalWorkPhone__pc = Trigger.oldMap.get(acc.Id).LocalWorkPhone__pc;
            }
            if ((acc.PersonHomePhone == null || String.isBlank(acc.PersonHomePhone)) &&
                Trigger.oldMap.get(acc.Id).PersonHomePhone != null) {
                // Set the PersonHomePhone field to its original value
                acc.PersonHomePhone = Trigger.oldMap.get(acc.Id).PersonHomePhone;
            }
        // }
    }
    }
}