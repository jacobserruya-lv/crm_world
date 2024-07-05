trigger ClientListMember_BeforeInsertUpdate on CLM_CliListMember__c (before insert, before update) {
    
    for(CLM_CliListMember__c clm: trigger.new){
        clm.TECH_External_Id__c = clm.Client__c + '_' + clm.ClientList__c;
    }

}