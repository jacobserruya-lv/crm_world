public with sharing class EventAppointmentTriggerHandler {
    public static void handleTrigger(List<Event> newList, Map<Id, Event> newMap, List<Event> oldList, Map<Id, Event> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when AFTER_INSERT {
                handleAfterInsert(newList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(newList,oldMap);
            }
            when BEFORE_DELETE {
                handleBeforeDelete(oldList);
            }
            when else {
                //do nothing for AFTER_UNDELETE, AFTER_DELETE, or BEFORE_UPDATE, BEFORE_INSERT
            }
        }
    }

    public static void handleAfterInsert(List<Event> newList) {
        populateMemberFields(newList, 'insert');
    }
    public static void handleAfterUpdate(List<Event> newList , Map<Id,Event> oldMembers) {
        List<Event> relevantEvents = new List<Event>();
        for (Event appntmnt : newList) {
            if (appntmnt.StartDateTime!=oldMembers.get(appntmnt.Id).StartDateTime || appntmnt.EndDateTime!=oldMembers.get(appntmnt.Id).EndDateTime) {
                relevantEvents.add(appntmnt);
            }
        }
        if (!relevantEvents.isEmpty()) {
            populateMemberFields(relevantEvents, 'update');
        }
    }
    public static void handleBeforeDelete(List<Event> oldList) {
        populateMemberFields(oldList, 'delete');
    }

    private static void populateMemberFields(List<Event> apptmntList, String operation){
        map<Id, Event> appointmentsMap= new Map<Id, Event> ();
        Map<Id, Brand_Experience_Variation_Member__c> membersForUpdated = new Map<Id, Brand_Experience_Variation_Member__c>();// in order to avoid multiple
        // Map<Id, Brand_Experience_Variation__c> variationsForUpdated = new Map<Id, Brand_Experience_Variation__c>();// in order to avoid multiple


        for (Event appntmnt : apptmntList) {
            if (appntmnt.Subject=='Event') {
                appointmentsMap.put(appntmnt.Id, appntmnt); 
            }
        }
        for (Event appntmnt : [SELECT Id, Event__r.Appointment_Start__c, Event__r.Appointment_End__c, Event__r.Nb_Appointment__c FROM EVENT WHERE Id IN: appointmentsMap.keySet()]) { 
            System.debug('**appntmnt: '+appntmnt);
            if (!appointmentsMap.isEmpty()) {
                if (appointmentsMap.get(appntmnt.Id)!=null) {
                        appntmnt.Event__r.Nb_Appointment__c = appntmnt.Event__r.Nb_Appointment__c==null?0:appntmnt.Event__r.Nb_Appointment__c;
                    if (operation=='delete') {
                        appntmnt.Event__r.Appointment_Start__c =null;
                        appntmnt.Event__r.Appointment_End__c = null;
                        appntmnt.Event__r.Nb_Appointment__c --;
                        // variationsForUpdated.put(appntmnt.Event__r.Brand_Experience_Variation__c, appntmnt.Event__r.Brand_Experience_Variation__r);
                    }
                    else { //insert/update
                        appntmnt.Event__r.Appointment_Start__c = appointmentsMap.get(appntmnt.Id).StartDateTime;
                        appntmnt.Event__r.Appointment_End__c = appointmentsMap.get(appntmnt.Id).EndDateTime ;
                        if (operation=='insert') {
                            appntmnt.Event__r.Nb_Appointment__c ++;
                            // variationsForUpdated.put(appntmnt.Event__r.Brand_Experience_Variation__c, appntmnt.Event__r.Brand_Experience_Variation__r);
                        }
                    }
                    membersForUpdated.put(appntmnt.Event__c, appntmnt.Event__r);
                }
            }
        }
        System.debug('**membersForUpdated: '+membersForUpdated);

        if (!membersForUpdated.isEmpty()) {
            update membersForUpdated.values();
        }
        // if (!variationsForUpdated.isEmpty()) {
        //     update variationsForUpdated.values();
        // }
    }
}