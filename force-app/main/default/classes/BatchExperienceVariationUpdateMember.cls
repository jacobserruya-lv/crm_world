global class BatchExperienceVariationUpdateMember implements Database.Batchable<sObject> {
    String query;
    List<Id> experiencesVariationsIds;

    global BatchExperienceVariationUpdateMember(List<Id> experiencesVariationsIdsToCheck){
      	experiencesVariationsIds = experiencesVariationsIdsToCheck;
        query =    'SELECT Id, Status__c, rsvpState__c ,Attendance__c,NominationStatus__c ,isSelected__c, Brand_Experience_Variation__r.Brand_Experience__r.RecordType.DeveloperName, Brand_Experience_Variation__r.Status__c,Brand_Experience_Variation__r.RequiredClientRegistration__c ' +
                    'FROM Brand_Experience_Variation_Member__c ' +
                   'WHERE Brand_Experience_Variation__c IN :experiencesVariationsIds ' ;
   
    }
/*+
                   'AND Brand_Experience_Variation__r.Brand_Experience__r.RecordType.DeveloperName = \'Club_Experience\''
                   */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Brand_Experience_Variation_Member__c> membersToCheck) {
       
        Map<Id,Brand_Experience_Variation_Member__c> mapMembersToUpdate = new Map<Id,Brand_Experience_Variation_Member__c>();
        
        for( Brand_Experience_Variation_Member__c member : membersToCheck){
            Boolean isRegistrationMandatory = member.Brand_Experience_Variation__r.RequiredClientRegistration__c == 'Mandatory';
            
            if (member.NominationStatus__c == 'Approved'){ 
               member.isSelected__c = !isRegistrationMandatory || member.rsvpState__c == 'Registered' ? true : false ;
               // mapMembersToUpdate.put(member.id,member);
                
            }
            else{
                member.isSelected__c = false;
              //  mapMembersToUpdate.put(member.id,member);
            }

            switch on member.Brand_Experience_Variation__r.Status__c {
            
                when 'Ready','Preview','Registration Opened','Participation Opened'{
                    
                    if (member.NominationStatus__c == 'Approved'){
                      member.rsvpState__c = String.isEmpty(member.rsvpState__c ) && isRegistrationMandatory  ? 'Not Registered' : member.rsvpState__c;
                        
                    }
                }

                when 'Ended' {
                    if((member.Attendance__c != 'Yes') && member.isSelected__c && member.Brand_Experience_Variation__r.Brand_Experience__r.RecordType.DeveloperName == 'Club_Experience'){
                        member.Attendance__c = 'No';
                        
                    }
                   
                }
               
            }
           
        }
        update membersToCheck;
        // if (!mapMembersToUpdate.isEmpty()) {
        //     update mapMembersToUpdate.values();
        // }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
  }
}