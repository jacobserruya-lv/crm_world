trigger NotificationParameterTrigger on Notification_Parameter__ChangeEvent (after insert) {

    Map<Id, Notification_Parameter__ChangeEvent> notificationsId = new Map<Id, Notification_Parameter__ChangeEvent>();
    
    for (Notification_Parameter__ChangeEvent event : Trigger.New) {
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        if (header.changetype == 'CREATE') {
            if(event.Field__c.toLowerCase().contains('url') && !event.Field__c.contains('_short')){
                notificationsId.put(event.Notification__c, event);
            }
        }
    }

    System.debug('NotificationParameterChangeEventTrigger');

    List<Notification__c> notifications = [SELECT Id, External_Id__c
        FROM Notification__c
        WHERE ID IN :notificationsId.keySet() AND Channel__c = 'SMS MARKETING CLOUD'];

    List<Notification_Parameter__c> newParameters = new List<Notification_Parameter__c>();
    for(Notification__c notif : notifications){

        Notification_Parameter__ChangeEvent event = notificationsId.get(notif.Id);
        String shortUrl = Akamai_API.getShortUrl(event.LongValue__c, 'IDENTITY');
        
        Notification_Parameter__c notification_parameter = new Notification_Parameter__c(
            Notification__c = notif.Id,
            Field__c = event.Field__c + '_short',
            LongValue__c = shortUrl,
            Type__c = event.Type__c
        );
        
        newParameters.add(notification_parameter);
    }

    try{
        insert newParameters;
    }
    catch(Exception ex){
        //new Logs.ERROR('Notification_Sender', 'Database', ex);
    }
}