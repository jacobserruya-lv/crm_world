trigger Tags on Tag__c (after insert) {
    List<Event> keyDates = new List<Event>();
    static String KeyDatesRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Key_Dates').getRecordTypeId();

    for ( Tag__c tag : Trigger.new){
        if(tag.Type__c == 'key_dates'){
            try{

                //  loop over the future_key_dates to generate events
                String futureKeyDatesStr = tag.Future_Key_Dates__c;
                if(futureKeyDatesStr != null) {
                    List<Object> futureKeyDates = (List<Object>)JSON.deserializeUntyped(futureKeyDatesStr);
                    for (Object keyDateObject : futureKeyDates) {
                        Date keyDate = Date.valueOf((String)keyDateObject);
                        Event kd = new Event();
                        kd.StartDateTime = keyDate;
                        kd.DurationInMinutes = 60;
                        kd.WhatId = tag.Client__c;
                        kd.OwnerId = tag.CreatedById;
                        kd.Subject = tag.Value_MP__c;
                        kd.recordTypeId = KeyDatesRecordTypeId;
                        keyDates.add(kd);
                    }
                }
                
            }catch (Exception e){
                System.debug('Error occured for tag ');
                System.debug(tag);
                system.debug(e.getMessage());
            }
            

            
        }
    }
    try {
        if(keyDates.size() > 0){
        System.debug('################');
        System.debug(keyDates);
        insert keyDates;
    }
    } catch (Exception e) {
        System.debug(e);
    }
    

}