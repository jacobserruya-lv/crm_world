/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-14-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-14-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger Event_BeforeUpdate on Event (before update) {
    system.debug('*****AAAAAAAA');
    //Populate salesAmount and Transaction On appointment 
   list<Event> event = new list<event>();
    map<String, list<Event>> toAddStore = new map<String, list<Event>>();
    map<String, list<Event>> toAddStoreOwner = new map<String, list<Event>>();
    Map<String, String> appointmentRecordTypesMap = OnlineAppointments_Utils.getAppointmentRecordTypesId();
    for (event e : trigger.new){
    system.debug('@@@@@@@trigger : ' + e.Purchased_Product__c ); 
     system.debug('@@@@@@@trigger : ' + trigger.oldmap.get(e.id).Purchased_Product__c ); 
        if (e.Purchased_Product__c != trigger.oldmap.get(e.id).Purchased_Product__c){
        
            event.add(e);
        }        
        if(e.Store_Location__c == null){
            if(toAddStore.get(e.OwnerId) == null){
                toAddStore.put(e.OwnerId, new list<event>());
            }
            toAddStore.get(e.OwnerId).add(e);
        }
        system.debug('AAAAAAAAAA ATTENDANCE: ' + e.attendance__c); 
        if(e.attendance__c != trigger.oldmap.get(e.id).attendance__c){
            if(e.attendance__c == 'Yes'){
                e.ClientNoShow__c = false;
            }
            else {
                e.Sale__c = false;
                e.ClientNoShow__c = true;
                e.RelatedTicketNumber__c = null;
                e.SaleAmount__c = null;
            }
        }
        
        if((e.RecordTypeId == appointmentRecordTypesMap.get('Online_Appointment') && (e.Status__c != 'Assigned' && e.Status__c != 'Cancelled')) || e.RecordTypeId == appointmentRecordTypesMap.get('Availability')) {
            if(toAddStoreOwner.get(e.Store_Location__c) == null){
                toAddStoreOwner.put(e.Store_Location__c, new list<event>());
            }
            toAddStoreOwner.get(e.Store_Location__c).add(e);
        }

        if(e.Status__c == 'Cancelled' && trigger.oldMap.get(e.id).Status__c != e.Status__c) {
            e.Cancelation_Date__c = Datetime.now();
            e.RelatedTicketNumber__c = null;
            e.Sale__c = false;
            e.attendance__c = 'None';
            e.ClientNoShow__c = true;
            e.No_Transaction__c = true;
            e.SaleAmount__c = null;
        }
            if(e.RecordTypeId == appointmentRecordTypesMap.get('Online_Appointment') && e.My_Repairs__c != null) {        
                 // make event public for identity user 
                e.IsVisibleInSelfService = true; 
                //complete whatid by careservice Id for OnlineAppointment linked to CareService
                //e.WhatId = e.My_Repairs__c;
                }
           
       
    }

    if(toAddStore.size() > 0){
        IC_Event_TRG.setStoreAppointment(toAddStore);
    } 

    if(toAddStoreOwner.size() > 0){
        IC_Event_TRG.setStoreUserOwner(toAddStoreOwner);
    } 

    IC_Event_TRG.PopulateTransAppointement(event);

    
    If (IC_Utils.canTrigger('BANNEDWORDS')) {
        List<String> bannedWords = IC_BannedWords.checkWords(Trigger.new, 'Event');
        if(!bannedWords.isEmpty())
            Trigger.new[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,', ')}));
    }
}