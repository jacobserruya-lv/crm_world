/** * File Name: Account_BeforeInsert
* Description : Before Insert trigger on Account
* @author : UNKOWN
* Modification Log =============================================================== 
*   RMOU 20/06/16 : Initialize isProspect flag
*  MTOU 28/07/2016: ICON Owner project - removing checkIfActifSA call
*   BALINK 11/02/2019: Tracking Source of account creation 
* */
trigger Account_BeforeInsert on Account (before insert) {
    /*If (IC_Utils.canTrigger('ACCOUNT')) {
        // Deactivated by MTOU - ICON Owner
        //IC_PersonAccount_TRG.checkIfActifSA(Trigger.new);
        If (IC_Utils.canTrigger('PROSPECT')){
            // Begin RMO
            // If accounts are created by a normal user, set isProspect flag to true
            if (!IC_UTils.isInterfaceDream()){
                for (Account a : Trigger.new)
                  a.IsProspect__pc = true;
            }
            // End RMO
            // line commented as replaced by 'Account Process' Process Builder
            //IC_PersonAccount_TRG.manageProspectBySettingField(Trigger.new);
        }
    }

    // TRACKING SOURCE
    Tracking_Settings__mdt[] tracking_settings = [SELECT MasterLabel FROM Tracking_Settings__mdt WHERE Value__c =: UserInfo.getUserName()];
    if(!tracking_settings.isEmpty()){
        for(Account acc : Trigger.new){
            if(String.isEmpty(acc.Source__c)){
                acc.Source__c = tracking_settings[0].MasterLabel;
            }
        }
    }*/
}