public with sharing class ExperienceVariationMemberTriggerHandler {
    public static void handleTrigger(List<Brand_Experience_Variation_Member__c> newList, Map<Id, Brand_Experience_Variation_Member__c> newMap, List<Brand_Experience_Variation_Member__c> oldList, Map<Id, Brand_Experience_Variation_Member__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when AFTER_INSERT {
                handleAfterInsert(newList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(newList,oldMap);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(newList,oldMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    public static void handleBeforeInsert(List<Brand_Experience_Variation_Member__c> newList) {

        Set<Id> clientIds = new Set<Id>();
        Set<Id> experienceVariationIds = new Set<Id>();


        for (Brand_Experience_Variation_Member__c member : newList) {

            experienceVariationIds.add(member.Brand_Experience_Variation__c);
            clientIds.add(member.Client__c); 
        }
        List<Account> clients = BL_Experience_Variation_Utils.getRelatedClients(clientIds);
        Map<Id,Id> preferredCAByClient = BL_Experience_Variation_Utils.getPreferredCAByClient(clients);

        Map<Id, Brand_Experience_Variation__c> variationById = BL_Experience_Variation_Utils.getMapVariationById(experienceVariationIds);

        for (Brand_Experience_Variation_Member__c member : newList) {
            Boolean isRegistrationByCA = variationById.get(member.Brand_Experience_Variation__c).Registration_by_CA__c == true; 
            Boolean isRegistrationMandatory = variationById.get(member.Brand_Experience_Variation__c).RequiredClientRegistration__c == 'Mandatory';
            Boolean isVariationPublished = variationById.get(member.Brand_Experience_Variation__c).Status__c == 'Ready';

            member.UniqueKey__c = member.Brand_Experience_Variation__c + '_' + member.Client__c;

            if(String.IsEmpty(member.Assigned_CA__c)) member.Assigned_CA__c = preferredCAByClient.get(member.Client__c); //need to check for no club ?
           

                switch on member.NominationStatus__c {
                    when  'Approved' {  
                        member.rsvpState__c =  String.isEmpty(member.rsvpState__c ) &&  isRegistrationMandatory  ? 'Not Registered' : member.rsvpState__c;
                        member.Status__c = isRegistrationByCA && isVariationPublished ? 'To Contact':member.rsvpState__c == 'Not Registered' ? 'Not Registered' : 'Ready';
                    }
                    when 'Pending' {
                        member.Status__c = 'Pending';
                    }
                    when 'Refused'{
                        member.Status__c = 'Rejected' ;
                    }
                }         
        }
    }

    public static void handleAfterInsert(List<Brand_Experience_Variation_Member__c> newList) {
        try{
        
            List<Push_Notification_Item__c> notificationItems = new List<Push_Notification_Item__c>();
            
            for (Brand_Experience_Variation_Member__c member : [SELECT Id, NominationStatus__c, NominationSource__c, Assigned_CA__c, Brand_Experience_Variation__r.Name, Brand_Experience_Variation__r.Status__c 
                FROM Brand_Experience_Variation_Member__c WHERE ID IN: newList AND Brand_Experience_Variation__r.Status__c IN ('Ready', 'Participation Opened') AND NominationStatus__c = 'Approved']) {
                    if(member.NominationSource__c == 'Desktop' || member.NominationSource__c  == 'Client_target'){
                        String caLanguage = UserInfo.getLocale();
                        String variationName = member.Brand_Experience_Variation__r.Name;
                        String assignedCA =  member.Assigned_CA__c ; 
                        String memberId =  member.Id;

                        String placeholder = IM_SendPushNotifications.getNotificationTemplate(caLanguage, 'Experience_member_approved__c');
                        List<String> fillers = new String[]{variationName};
                            
                        Push_Notification_Item__c push = new Push_Notification_Item__c(
                                Body__c = String.format(placeholder, fillers),
                                Type__c = 'Variation_Member',
                                ObjectId__c = memberId,
                                UserRecipient__c  = assignedCA
                            );

                        notificationItems.add(push);  
                    }
                    
            }
            if(!notificationItems.isEmpty()){
                Database.insert(notificationItems, false);
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public static void handleBeforeUpdate(List<Brand_Experience_Variation_Member__c> newList , Map<Id,Brand_Experience_Variation_Member__c> oldMembers) {

        Set<Id> experienceVariationIds = new Set<Id>();
        for (Brand_Experience_Variation_Member__c member : newList) {
            experienceVariationIds.add(member.Brand_Experience_Variation__c);
        }

        Map<Id, Brand_Experience_Variation__c> variationById = BL_Experience_Variation_Utils.getMapVariationById(experienceVariationIds);
       
        
        for (Brand_Experience_Variation_Member__c member : newList) {

            Brand_Experience_Variation_Member__c oldMember = oldMembers.get(member.Id);
            Brand_Experience_Variation__c  experienceVariation = variationById.get(member.Brand_Experience_Variation__c);
       

            handleStatus(member,oldMember,experienceVariation);
           
        }
    }


    public static void handleStatus(Brand_Experience_Variation_Member__c member, Brand_Experience_Variation_Member__c oldMember,Brand_Experience_Variation__c experienceVariation) {

        Boolean isNominationStatusChanged = oldMember.NominationStatus__c != member.NominationStatus__c;
        Boolean isRegistrationStatusChanged = oldMember.rsvpState__c != member.rsvpState__c;
        Boolean isParticipationStatusChanged = oldMember.Attendance__c != member.Attendance__c;
        Boolean isParticipationDateChanged = oldMember.ParticipationStartDateTime__c != member.ParticipationStartDateTime__c  && member.ParticipationStartDateTime__c!= null;
      //  Boolean isExperience = experienceVariation.Brand_Experience__r.RecordTypeId == BL_Experience_Variation_Utils.getRecordTypeExperience('Experience');
        Boolean isNoSelection = experienceVariation.ClientSelection__c == 'No Selection' || string.isEmpty(experienceVariation.ClientSelection__c);
        Boolean isRegistrationByCA =  experienceVariation.Registration_by_CA__c == true;
        if (isNominationStatusChanged) {
            switch on member.NominationStatus__c {
                when 'Pending' {
                    member.rsvpState__c = null;
                    member.RsvpDateTime__c = null;
                    member.Status__c = 'Pending';
                }
                when  'Approved' {  
                    Boolean isRegistrationMandatory = experienceVariation.RequiredClientRegistration__c == 'Mandatory';
                  
                    switch on experienceVariation.Status__c {
                        when 'Draft' {
                            member.Status__c = 'Ready';
                        }
                        when 'Ready','Preview','Registration Opened','Registration Closed','Participation Opened'{
                            
                            member.rsvpState__c =  String.isEmpty(member.rsvpState__c ) &&  isRegistrationMandatory  ? 'Not Registered' : member.rsvpState__c;
                            member.isSelected__c = !isRegistrationMandatory || member.rsvpState__c == 'Registered' ? true : false ;  
                            member.Status__c = isRegistrationByCA? 'To Contact': member.rsvpState__c == 'Not Registered' ? 'Not Registered' : 'Ready';
                        }
                    }
                }
                when 'Refused' {
                    member.Status__c = 'Rejected';
                }
            }
        }

        if (isRegistrationStatusChanged && isNoSelection ) {
            member.isSelected__c = member.rsvpState__c == 'Registered' ;    
            switch on member.rsvpState__c {
                when  'Registered' {
                    member.Attendance__c = 'None';
                    member.Status__c = 'Registered';
                    member.RsvpDateTime__c = System.Now();

                }
                when  'Not Registered' {
                    member.Attendance__c = null;
                    member.Status__c = isRegistrationByCA && member.NominationStatus__c == 'Approved' ? 'To Contact' : ' Not Registered';
                    member.RsvpDateTime__c = null;
                }
                when 'Declined' {
                    member.Attendance__c = null;
                    member.Status__c = 'Declined';
                    member.RsvpDateTime__c = System.Now();

                }
                when 'Removed' {
                    member.Attendance__c = null;
                    member.Status__c = 'Removed Manually';
                    member.RsvpDateTime__c = System.Now();

                }
            }
           
          
        }

        if (isParticipationStatusChanged) {
            switch on member.Attendance__c {
                when  'Yes' {
                    member.Status__c = 'Participated';
                }
                when 'No' {
                    member.Status__c = 'Not Participated';
                }
            }
        }

        if (isParticipationDateChanged && member.isSelected__c){
            member.Status__c = 'Participated';
            member.Attendance__c = 'Yes';
        }
    }
   
    public static void handleAfterUpdate(List<Brand_Experience_Variation_Member__c> newList , Map<Id,Brand_Experience_Variation_Member__c> oldMembers) {

        try {
            List<String> nominationStatuses = new List<String> {'Approved', 'Refused'};
            List<Push_Notification_Item__c> notificationItems = new List<Push_Notification_Item__c>();
            Map<Id, List<Brand_Experience_Variation_Member_Guest__c>> guestsToMemberForStatus= new Map<Id, List<Brand_Experience_Variation_Member_Guest__c>>();
            Map<Id, List<Brand_Experience_Variation_Member_Guest__c>> guestsToMemberForAttendance= new Map<Id, List<Brand_Experience_Variation_Member_Guest__c>>();
            Map<Id, Brand_Experience_Variation_Member__c> memberWithAppointmentForUpdate = new  Map<Id, Brand_Experience_Variation_Member__c>();
            Map<Id, Brand_Experience_Variation_Member__c> oldMemberWithAppointment = new  Map<Id, Brand_Experience_Variation_Member__c>();

            for (Brand_Experience_Variation_Member__c member : [SELECT Id, NominationStatus__c, Assigned_CA__c, Client__r.Name, rsvpState__c,Attendance__c, Brand_Experience_Variation__r.Status__c, (SELECT Id, Status__c, Brand_Experience_Variation_Member__r.rsvpState__c, Brand_Experience_Variation_Member__r.Attendance__c FROM Activation_Member_s_Guests__r) FROM Brand_Experience_Variation_Member__c WHERE ID IN: newList]) {

                Brand_Experience_Variation_Member__c oldMember = oldMembers.get(member.Id);
                String nominationStatus = member.NominationStatus__c;

                if(oldMember.NominationStatus__c != nominationStatus && nominationStatuses.contains(nominationStatus) && String.isNotEmpty(member.Assigned_CA__c) 
                    && (member.Brand_Experience_Variation__r.Status__c == 'Ready' || member.Brand_Experience_Variation__r.Status__c == 'Participation Opened')){

                    String caLanguage = UserInfo.getLocale();
                    String clientName = member.Client__r.Name;
                    String assignedCA =  member.Assigned_CA__c ; 
                    String memberId =  member.Id;

                    String placeholder = IM_SendPushNotifications.getNotificationTemplate(caLanguage, 'VariationMemberNomination__c');
                    List<String> fillers = new String[]{clientName , nominationStatus };
                        
                    Push_Notification_Item__c push = new Push_Notification_Item__c(
                        Body__c = String.format(placeholder, fillers),
                        Type__c = 'Variation_Member',
                        ObjectId__c = memberId,
                        UserRecipient__c  = assignedCA
                    );

                    notificationItems.add(push);
                }
                
                if (oldMember.rsvpState__c != member.rsvpState__c && (member.rsvpState__c=='Declined' ||member.rsvpState__c=='Removed' || member.rsvpState__c=='Registered')) {
                    guestsToMemberForStatus.put(member.Id, member.Activation_Member_s_Guests__r);
                }
                if (oldMember.attendance__c != member.attendance__c && member.attendance__c!='None' && member.attendance__c!=null) {
                    guestsToMemberForAttendance.put(member.Id, member.Activation_Member_s_Guests__r);
                }
                if (member.Assigned_CA__c!=oldMember.Assigned_CA__c || member.attendance__c!= oldMember.attendance__c) {
                    memberWithAppointmentForUpdate.put(member.Id, member);
                    oldMemberWithAppointment.put(oldMember.Id, oldMember);
                }
            }
            handleAppointmentUpdate(memberWithAppointmentForUpdate, oldMemberWithAppointment);
            handleGuestStatus(guestsToMemberForStatus, guestsToMemberForAttendance);
            if(!notificationItems.isEmpty()){
                Database.insert(notificationItems, false);
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }
    private static void handleGuestStatus(Map<Id, List<Brand_Experience_Variation_Member_Guest__c>> guestsToMemberForStatus, Map<Id, List<Brand_Experience_Variation_Member_Guest__c>> guestsToMemberForAttendance) {
        List<Brand_Experience_Variation_Member_Guest__c> guestsForUpdate = new List<Brand_Experience_Variation_Member_Guest__c>();
            if (!guestsToMemberForAttendance.isEmpty()) {
                for (List<Brand_Experience_Variation_Member_Guest__c> guestmembers : guestsToMemberForAttendance.values()) {
                    for (Brand_Experience_Variation_Member_Guest__c guest : guestmembers) {
                        guest.Status__c= guest.Brand_Experience_Variation_Member__r.attendance__c=='Yes'? 'Participated': 'Not Participated';
                        guestsForUpdate.add(guest);
                    }
                }
            }
            if (!guestsToMemberForStatus.isEmpty()) {
                for (List<Brand_Experience_Variation_Member_Guest__c> guestmembers : guestsToMemberForStatus.values()) {
                    for (Brand_Experience_Variation_Member_Guest__c guest : guestmembers) {
                        switch on guest.Brand_Experience_Variation_Member__r.rsvpState__c {
                            when 'Registered' {
                                guest.Status__c = 'Registered';
                            }
                            when  'Declined' {  
                                guest.Status__c = 'Declined';
                            }
                            when 'Removed' {
                                guest.Status__c = 'Removed Manually';
                            }
                        }
                        guestsForUpdate.add(guest);      
                    }
                }
            }
        if (!guestsForUpdate.isEmpty()) {
            update guestsForUpdate;
        }        
    } 
    private static void handleAppointmentUpdate(Map<Id, Brand_Experience_Variation_Member__c> memberWithIdsMap, Map<Id, Brand_Experience_Variation_Member__c> oldMemberWithIdsMap) {
        //Done in this way, following the following restriction:System.UnexpectedException: There is an implementation restriction on Activities__r. When you query this relationship, security evaluation is implemented for users who don't have administrator permissions, and no other filters may be applied to the aggregate query.
        Map<Id, Event> eventsForUpdated = new Map<Id, Event>();// in order to avoid multiple
        for (Event e :  [SELECT Attendance__c,OwnerId, Event__c, Event__r.Attendance__c, Event__r.Assigned_CA__c FROM Event WHERE Event__c IN: memberWithIdsMap.keySet() AND Event__r.Brand_Experience_Variation__r.Required_Appointment__c!=null]) {
            // currently, there is only 1 appointment per member.
            if (e.Event__r.Attendance__c!=oldMemberWithIdsMap.get(e.Event__c).Attendance__c) {
                e.Attendance__c=e.Event__r.Attendance__c;
                eventsForUpdated.put(e.Id, e);
            }
            if (e.Event__r.Assigned_CA__c!=oldMemberWithIdsMap.get(e.Event__c).Assigned_CA__c) {
                e.OwnerId=e.Event__r.Assigned_CA__c;
                eventsForUpdated.put(e.Id, e);
            }
        }
   
        System.debug('**eventsForUpdated: '+eventsForUpdated);
        if (!eventsForUpdated.isEmpty()) {
            update eventsForUpdated.values();
        }
    }
}