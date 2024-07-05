public with sharing class WechatWork_Notification_Center {
    
    @future(callout=true)
    public static Void sendNotification(String appid, String userids,String page, String title, String description, String paramsJson){
        
        Object params = (Object) JSON.deserializeUntyped(paramsJson) ;
        Map<String, Object> body = new Map<String, Object> {
            'touser'=> userids,
            'msgtype' => 'miniprogram_notice',
            'miniprogram_notice' => new Map<String, Object> {
                'appid'=> '{appid}',
                'page'=> page,
                'title'=> title,
                'description'=> description,
                'emphasis_first_item'=> true,
                'content_item'=> params
            }
        };
        String bodyJson  = JSON.serialize(body);
        system.debug(bodyJson);
        HTTP_Utils response = new HTTP_Utils()
                    .post('callout:LV_ICON_WECOM/wcw/messaging/mp?app_id='+appid)
                    .header('Content-Type', 'application/json;charset=UTF-8')
                    .body(bodyJson)
                    .call();

    }

    public static void WCW_OSA_notification(List<Event> appointmentList, Map<ID, Account> clients){
        Set<String> ownerIds = IC_UTILS.getIdList(appointmentList,'OwnerId');
        Map<Id,User> userMap = new Map<ID, User>([SELECT Id, DefaultStore__c, Tech_isManager__c, WWEmployeeNumber__c From User Where Id IN : ownerIds]);
        Map<String, List<Event>> storeUnassignedApts = new Map<String, List<Event>>();
        Map<String, List<Event>> caAssignedApts = new Map<String, List<Event>>();
        Map<String, List<Event>> caCancelledApts = new Map<String, List<Event>>();
        for(Event apt : appointmentList) {
            switch on apt.Status__c {
                when  'Assigned'{
                    if(caAssignedApts.get(apt.ownerid) == null){
                        caAssignedApts.put(apt.ownerid, new List<Event>());
                    }
                    caAssignedApts.get(apt.ownerid).add(apt);
                }
                when  'Cancelled'{
                    if(caCancelledApts.get(apt.ownerid) == null){
                        caCancelledApts.put(apt.ownerid, new List<Event>());
                    }
                    caCancelledApts.get(apt.ownerid).add(apt);
                }
                when  'Not Assigned'{
                    if(storeUnassignedApts.get(apt.Store_Location__c) == null){
                        storeUnassignedApts.put(apt.Store_Location__c, new List<Event>());
                    }
                    storeUnassignedApts.get(apt.Store_Location__c).add(apt);
                }
                when else {
                    
                }
            }
        }

        for (String caid : caAssignedApts.keySet()){
            Boolean single = caAssignedApts.get(caid).size() == 1;
            Event firstApt;
            Account client;
            if(single) {
                firstApt = caAssignedApts.get(caid)[0];
                client = clients.get(firstApt.WhatId);
            }
           
            List<Map<String, String>> params = new List<Map<String, String>>();
            params.add(new Map<String, String>{
                'key'=> '顾客姓名',
                'value'=> (single ? client.Lastname + ' ' + client.FirstName : ''+caAssignedApts.get(caid).size())
            });
            params.add(new Map<String, String>{
                'key'=> '摘要',
                'value'=> '一个新的顾客微信预约已指派给你'
            });
            if(single) {
                params.add(new Map<String, String>{
                    'key'=> '时间',
                    'value'=> OnlineAppointments_Utils.getStoreLocalTime('Asia/Shanghai', firstApt.StartDateTime).format('MM月dd日 下午HH:mm点','GMT') 
                });
                params.add(new Map<String, String>{
                    'key'=> '预约类型',
                    'value'=> (firstApt.AppointmentType__c == 'inStore' ? '到店服务预约' : '远程服务预约')
                });
            }


            sendNotification(
                'ICON',
                userMap.get(caid).WWEmployeeNumber__c ,
                'pages/agenda/agenda' + (single ? '?aptId='+firstApt.Id : ''),
                '新指派预约',
                '新指派预约',
                JSON.serialize(params));
        }

        for (String caid : caCancelledApts.keySet()){

            Boolean single = caCancelledApts.get(caid).size() == 1;
            Event firstApt;
            Account client;
            if(single) {
                firstApt = caCancelledApts.get(caid)[0];
                client = clients.get(firstApt.WhatId);
            }
           
            List<Map<String, String>> params = new List<Map<String, String>>();
            params.add(new Map<String, String>{
                'key'=> '顾客姓名',
                'value'=> (single ? client.Lastname + ' ' + client.FirstName : ''+caCancelledApts.get(caid).size())
            });
            params.add(new Map<String, String>{
                'key'=> '摘要',
                'value'=> '你的顾客取消了与你的预约'
            });
            if(single) {
                params.add(new Map<String, String>{
                    'key'=> '时间',
                    'value'=> OnlineAppointments_Utils.getStoreLocalTime('Asia/Shanghai', firstApt.StartDateTime).format('MM月dd日 下午HH:mm点','GMT') 
                });
                params.add(new Map<String, String>{
                    'key'=> '预约类型',
                    'value'=> (firstApt.AppointmentType__c == 'inStore' ? '到店服务预约' : '远程服务预约')
                });
            }

            sendNotification(
                'ICON',
                userMap.get(caid).WWEmployeeNumber__c ,
                'pages/agenda/agenda' + (single ? '?aptId='+firstApt.Id : ''),
                '预约取消',
                '预约取消',
                JSON.serialize(params));
        }

        if(storeUnassignedApts.size() > 0) {
            Map<Id,Store__c> storesMap = new Map<Id,Store__c>([Select Id, retailStoreId__c FRom Store__c where Id IN :storeUnassignedApts.keySet()]);
            List<String>storeIds = new list<String>();
            for(Store__c s : storesMap.values()){
                storeIds.add(s.retailStoreId__c);
            }
            List<User> managers = [SELECT Id, DefaultStore__c, Tech_isManager__c, WWEmployeeNumber__c From User Where DefaultStore__c IN : storeIds AND Tech_isManager__c = true];
            Map<String,List<String>> storeManagerMap = new Map<String,List<String>>();
            for(User u : managers){
                if( storeManagerMap.get(u.DefaultStore__c) == null ){
                        storeManagerMap.put(u.DefaultStore__c, new List<String>());
                }
                if(String.isNotBlank(u.WWEmployeeNumber__c)) {
                    storeManagerMap.get(u.DefaultStore__c).add(u.WWEmployeeNumber__c);
                }
            }
            for (String storeId : storeUnassignedApts.keySet()){
                if(storeManagerMap.get(storesMap.get(storeId).retailStoreId__c) == null || storeManagerMap.get(storesMap.get(storeId).retailStoreId__c).size() == 0) {
                    continue;
                }
                system.debug(storeUnassignedApts);
                system.debug(storeUnassignedApts.get(storeId));
                Boolean single = storeUnassignedApts.get(storeId).size() == 1;
                Event firstApt;
                Account client;
                if(single) {
                    firstApt = storeUnassignedApts.get(storeId)[0];
                    client = clients.get(firstApt.WhatId);
                }
               
                List<Map<String, String>> params = new List<Map<String, String>>();
                params.add(new Map<String, String>{
                    'key'=> '顾客姓名',
                    'value'=> (single ? client.Lastname + ' ' + client.FirstName : ''+storeUnassignedApts.get(storeId).size())
                });
                params.add(new Map<String, String>{
                    'key'=> '摘要',
                    'value'=> '你的店铺有一个新的顾客微信预约需要指派'
                });
                if(single) {
                    params.add(new Map<String, String>{
                        'key'=> '时间',
                        'value'=> OnlineAppointments_Utils.getStoreLocalTime('Asia/Shanghai', firstApt.StartDateTime).format('MM月dd日 下午HH:mm点','GMT') 
                    });
                    params.add(new Map<String, String>{
                        'key'=> '预约类型',
                        'value'=> (firstApt.AppointmentType__c == 'inStore' ? '到店服务预约' : '远程服务预约')
                    });
                }


                sendNotification(
                    'ICON',
                    String.join(storeManagerMap.get(storesMap.get(storeId).retailStoreId__c),'|') ,
                    'pages/agenda/agenda'+ (single ? '?aptId='+firstApt.Id : ''),
                    '新未指派预约',
                    '新未指派预约',
                    JSON.serialize(params));
            }
        }
        
    }
}