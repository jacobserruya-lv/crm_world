trigger Event_BeforeInsert on Event (before insert) {

    //Populate salesAmount and Transaction On appointment 
    list<Event> event = new list<event>();
    map<String, list<Event>> toAddStore = new map<String, list<Event>>();
    map<String, list<Event>> toAddStoreOwner = new map<String, list<Event>>();
    Map<String, String> appointmentRecordTypesMap = OnlineAppointments_Utils.getAppointmentRecordTypesId();
    
    for (event e : trigger.new){

        if (e.Purchased_Product__c != null){
            event.add(e);
        }
        if(e.Store_Location__c == null){
            if(toAddStore.get(e.OwnerId) == null){
                toAddStore.put(e.OwnerId, new list<event>());
            }
            toAddStore.get(e.OwnerId).add(e);
        }
        if(e.RecordTypeId == appointmentRecordTypesMap.get('Online_Appointment') && e.Status__c != 'Assigned' || e.RecordTypeId == appointmentRecordTypesMap.get('Availability')){
            if(toAddStoreOwner.get(e.Store_Location__c) == null){
                toAddStoreOwner.put(e.Store_Location__c, new list<event>());
            }
            toAddStoreOwner.get(e.Store_Location__c).add(e);
        }
        if(e.RecordTypeId == appointmentRecordTypesMap.get('Online_Appointment')) {
            e.Subject = 'Online Appointment';
                               
            if(e.My_Repairs__c != null) { // make event public for identity user 
                e.IsVisibleInSelfService = true; 
            }           
        }
        else if(e.RecordTypeId == appointmentRecordTypesMap.get('Availability')) {
            e.Subject = 'Availability';
        }
    }
    
    if(toAddStore.size() > 0){
        IC_Event_TRG.setStoreAppointment(toAddStore);
    } 

    if(toAddStoreOwner.size() > 0){
        IC_Event_TRG.setStoreUserOwner(toAddStoreOwner);
    } 

    IC_Event_TRG.PopulateTransAppointement(event);
    
    if(IC_Utils.canTrigger('BANNEDWORDS')) {
        List<String> bannedWords = IC_BannedWords.checkWords(Trigger.new, 'Event');
        if(!bannedWords.isEmpty())
            Trigger.new[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,', ')}));
    }
}