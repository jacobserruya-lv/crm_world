trigger Interest on Interests__c (before insert) {
    for (Interests__c interest : trigger.new){
        if(interest.source__c == 'ONEDATA' && interest.isActive__c == false){
            interest.isActive__c = true;
        }
    }
}