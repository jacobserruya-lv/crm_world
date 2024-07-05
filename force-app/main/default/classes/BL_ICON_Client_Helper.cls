/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
///*
// * This class is a utilities class to the clients WS classes
// */
public without sharing class BL_ICON_Client_Helper {

    String runningUser; 
    public static Boolean isTypedTimeline = false; 

    public static String checkParameters(String clientId, String wcwid){
         if(clientId instanceOf Id){
            List<Account> client = (List<Account>) new BL_EasyQuery()
            .useCase(BL_ICON_CONSTANTS.USE_CASE_CLIENT)
            .condition('Id = \'' + clientId + '\'')
            .executeQuery()
            .getSObjects();

            if(!client.isEmpty())
                return client[0].Id;
        }
        else{
            String externalId = 'WeChat' + '_' + clientId;

            List<Social_Media_Identifier__c> socialMedia = (List<Social_Media_Identifier__c>) new BL_EasyQuery()
                                                    .useCase(BL_ICON_Constants.USE_CASE_SOCIAL_MEDIA_IDENTIFIER_BASIC)
                                                    .condition('Social_SF_External_Id__c = \'' + externalId + '\'')
                                                    .executeQuery()
                                                    .getSObjects();
    
            if(!socialMedia.isEmpty()){
                Social_Media_Identifier__c smi = socialMedia[0];
                if(String.isBlank(smi.Social_Enterprise_Id__c) && String.isNotBlank(wcwid)){
                    smi.Social_Enterprise_Id__c = wcwid;
                    update smi;
                    Social_Media_Identifier_CA__c sa_smi = new Social_Media_Identifier_CA__c();
                    sa_smi.CA__c = UserInfo.getUserId();
                    sa_smi.Client_Social_Media_Identifier__c = smi.Id;
                    sa_smi.TECH_ExternalId__c = UserInfo.getUserId() + '_' + smi.Id + '_' + 'WECHAT';
                    sa_smi.Status__c = 'bound';
                    Database.upsert(sa_smi, Social_Media_Identifier_CA__c.Fields.TECH_ExternalId__c);

                }
                if(smi.Tech_isBound__c == true){
                    return smi.Client__c;
                }
            }
        }
        throw new BL_Exceptions.RouterException('Id not found');
    }

    public static  Map<String, Object> getAllClientDetails(String clientId, Integer featuresSampleLimit, BL_UserInfo me){
        Map<String, Object> result = new Map<String, Object>();
        result.put('clientId', clientId);
        result.put('personalInfos', getClient(clientId));
        result.put('purchases', getPurchases(clientId,featuresSampleLimit, null, null, null));
        result.put('purchaseKPI', getPurchaseKPI(clientId,featuresSampleLimit));
        result.put('timelines', getClientTimeline(clientId,featuresSampleLimit));
        result.put('upcomingActivities', getClientUpcomings(clientId,featuresSampleLimit));
        result.put('ongoings', getClientOngoings(clientId,featuresSampleLimit));
        result.put('looks', getClientLooks(clientId, featuresSampleLimit, null));
        result.put('interactiveWardrobings', getClientIW(clientId, featuresSampleLimit, null));
        result.put('socialMediaIdentifiers', getSocialMediaIdentifier(clientId,featuresSampleLimit,me));
        result.put('interests', getClientInterests(clientId,featuresSampleLimit));

        // result.put('interestshistory', getClientInterestsHistory(clientId,featuresSampleLimit));
        // result.put('repairs', getClientRepairs(clientId,featuresSampleLimit));
        // result.put('surveys', getClientSurveys(clientId,featuresSampleLimit));
        // result.put('requests', getClientRequests(clientId,featuresSampleLimit));
        
        return result;
    }
    
    public static Object getClientByFeatures(String clientId, String features, Integer featuresSampleLimit, String featureId, BL_UserInfo me,  Integer pageIndex, Integer pageSize ){
        Map<String, Object> result = new Map<String, Object>();
        List<String> featuresList = features.split(';');
        Integer featuresListSize = featuresList.size();

        for(String f : featuresList){
            switch on f{
                when 'personal-infos' {
                    result.put('personalInfos', getClient(clientId));
                    result.put('clientId', clientId);
                }
                when 'looks' {
                    if(featureId != null)
                        return getClientLookById(clientId, featureId);
                    else if(featuresListSize == 1)
                        return getClientLooks(clientId,featuresSampleLimit, null);
                    else 
                        result.put('looks', getClientLooks(clientId,featuresSampleLimit, null));
                }
                when 'interactiveWardrobings' {
                    if(featureId != null)
                        return getClientIWById(clientId, featureId);
                    else if(featuresListSize == 1)
                        return getClientIW(clientId,featuresSampleLimit, null);
                    else 
                        result.put('interactiveWardrobings', getClientIW(clientId,featuresSampleLimit, null));
                }
                when 'purchases' {
                    if(featureId != null)
                        return getClientPurchaseById(clientId,featureId);
                    if(featuresListSize == 1)
                        return getPurchases(clientId,featuresSampleLimit, null, pageIndex, pageSize);
                    else
                        result.put('purchases', getPurchases(clientId,featuresSampleLimit, null, pageIndex, pageSize));
                }
                when 'repairs' {
                    if(featureId != null)
                        return getClientRepairById(clientId,featureId);
                    else if(featuresListSize == 1)
                        return getClientRepairs(clientId,featuresSampleLimit, null);
                    else
                        result.put('repairs', getClientRepairs(clientId,featuresSampleLimit, null));
                }
                 when 'surveys' {
                    if(featureId != null)
                        return getClientSurveyById(clientId,featureId);
                   if(featuresListSize == 1)
                       return getClientSurveys(clientId,featuresSampleLimit, null);
                   else 
                      result.put('surveys', getClientSurveys(clientId,featuresSampleLimit, null));
               }
                when 'requests' {
                    if(featureId != null)
                        return getClientRequestById(clientId,featureId);
                    if(featuresListSize == 1)
                        return getClientRequests(clientId,featuresSampleLimit, null);
                    else 
                        result.put('requests', getClientRequests(clientId,featuresSampleLimit, null));
                }
                when 'purchaseKPI' {
                    result.put('purchaseKPI', getPurchaseKPI(clientId,featuresSampleLimit));
                }
                when 'upcoming-activities' {
                    if(featureId != null)
                        return getClientUpcomingById(clientId,featureId);
                    if(featuresListSize == 1)
                        return getClientUpcomings(clientId,featuresSampleLimit);
                    else
                        result.put('upcomingActivities', getClientUpcomings(clientId,featuresSampleLimit));
                }
                when 'ongoings' {
                    if(featureId != null)
                        return getClientOngoingById(clientId,featureId);
                    if(featuresListSize == 1)
                        return getClientOngoings(clientId,featuresSampleLimit);
                    else
                        result.put('ongoings', getClientOngoings(clientId,featuresSampleLimit));
                }
                when 'timelines' {
                    if(featureId != null)
                        return getClientTimelineById(clientId,featureId);
                    if(featuresListSize == 1)
                        return  getClientTimeline(clientId,featuresSampleLimit);
                    else 
                        result.put('timelines', getClientTimeline(clientId,featuresSampleLimit));
                }
                when 'social-media-identifiers' {
                    if(featureId != null)
                        return  getSocialMediaIdentifierById(clientId,featureId, me);
                    if(featuresListSize == 1)
                        return getSocialMediaIdentifier(clientId,featuresSampleLimit,me);
                    else 
                        result.put('socialMediaIdentifiers', getSocialMediaIdentifier(clientId,featuresSampleLimit,me));
                }
                when 'interests' {
                    if(featureId != null)
                        return  getClientInterestById(clientId,featureId);
                    if(featuresListSize == 1)
                        return getClientInterests(clientId,featuresSampleLimit);
                    else 
                        result.put('interests', getClientInterests(clientId,featuresSampleLimit));
                }
                when 'nyorders' {
                    if(featureId != null)
                        return  getClientNYOrderById( clientId , featureId);
                    if(featuresListSize == 1)
                        return  getClientNYOrders(clientId,featuresSampleLimit, null);
                    else 
                        result.put('nyorders',  getClientNYOrders(clientId,featuresSampleLimit, null));
                }
                when 'xstoreOrders' {

                    if(featureId != null)
                        return  getClientXStoreOrderById( clientId , featureId);
                    if(featuresListSize == 1)
                        return  getClientXStoreOrders(clientId,featuresSampleLimit, null);
                    else 
                        result.put('xstoreOrders',  getClientXStoreOrders(clientId,featuresSampleLimit, null));
                }
                when 'interestsHistory' {
                    return   getClientInterestHistoryById(clientId);
                }
                when 'product-recommandation' {
                    result.put('productRecommendation', getProductRecommendation(clientId, me));
                }
            }
        } 
        return result;
    }

    

    public static Object upsertFeatureByClient(String clientId, String feature, Object record, BL_UserInfo me){
        switch on feature{
            when 'social-media-identifiers' {
                return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_SOCIAL_MEDIA_IDENTIFIER)
                .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
                .upsertWrappersWithChilds(new List<Object>{record}, Social_Media_Identifier__c.Field.Social_SF_External_Id__c, Social_Media_Identifier_CA__c.Field.TECH_ExternalId__c);
            }

            when 'assign' {
                String ownerId = ((Map<String, Object>) record).get('ownerId') != null ? (String) ((Map<String, Object>) record).get('ownerId') : UserInfo.getUserId();
                Account toUpdate = new Account(Id = clientId, OwnerId = ownerId);
                update toUpdate;
                return getClient(clientId);
            }

            when 'interests' {
                system.debug(record);
                List<Object> records = new List<Object>();
                for(Object obj : (List<Object>) record){
                    Map<String, Object> mapObj = (Map<String, Object>) obj;
                    mapObj.put('techExtId', clientId + '_' + (String)mapObj.get('categories') + '_CA');
                    mapObj.put('clientId', clientId);
                    mapObj.put('source', 'ICON');
                    mapObj.remove('id');
                    
                    records.add(obj);
                }
                return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_INTERESTS)
                .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
                .upsertWrappersWithChilds(records, Interests__c.Field.TECH_ExtId__c, null);

            }
        }

        return null;
    }


    public static Object updateFeatureByFeatureId(String clientId, String featureId,String feature, Object record, BL_UserInfo me){
       
        Object response = null;
        Map<String, Object> obj = ((Map<String, Object>) record);
        obj.put('id', featureId);
        
        switch on feature{
            when 'repairs' {
                response =  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES_FULL)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
            when 'requests' {
                response =  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST_FULL)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
            when 'xstoreOrders' {
                response =   new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS_FULL)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
            when 'nyorders' {
                response =   new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
           //  when 'surveys' {
           //     new BL_EasyQuery()
           //     .useCase(BL_ICON_Constants.USE_CASE_SURVEY_FULL)
           //     .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
           //     response =  new BL_WS_Response(new List<Object>{getClientSurveyById(clientId,featureId).record});
           // }
        }

        if((obj.containsKey('status') && (String) obj.get('status') == 'Closed') || (obj.containsKey('isClosedByIcon') && (Boolean) obj.get('isClosedByIcon'))){

            BL_ICON_Todos_Helper.closeToDoAssistant(featureId,(String) obj.get('to_do_type'));
        }
        return response;
    }

    public static Object getClient(String clientId) {
        List<Map<String, Object>> clientData = (List<Map<String, Object>>) new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_CLIENT)
        .condition('Id = \'' + clientId + '\'')
        .usage(BL_EasyQuery.Usage.FOR_REFERENCE)
        .limitCount(1)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
        
        /*
         Map<String, Object> identityUserData = (Map<String, Object>) new BL_EasyQuery()
                        .useCase(BL_ICON_Constants.USE_CASE_IDENTITY_USER)
                        .condition('accountId = \'' + clientId + '\'')
                        .limitCount(1)
                        .executeQuery()
                        .getMappedObject();
        
        if (clientData[0] != null && identityUserData != null) {
           clientData[0].put('identityUser',identityUserData);
        }     
        */   

        if(!clientData.isEmpty())
            return clientData[0];

        return null;
    }

    public static  Object getPurchases(String clientId, Integer featuresSampleLimit, TimingMode timingMode, Integer pageIndex, Integer pageSize){

        Object records ;
        String timingCondition = '';
        switch on timingMode {
            when  PAST {
                timingCondition = ' AND PurchasedDate__c <= TODAY ' ;

            }
        }
        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
            .condition('Client__c =  \''+ clientId + '\'' + timingCondition)
            .executeCount()
            .getTotalSize();

        if(featuresSampleLimit == -1){
            if(pageIndex != null && pageSize != null){
                records = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
                .condition('Client__c =  \''+ clientId + '\'' + timingCondition)
                .orderBy('PurchasedDate__c DESC')
                .pagination(pageIndex, pageSize)
                .executeQuery()
                .getMappedObjects();
            }
            else{
                records = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
                .condition('Client__c =  \''+ clientId + '\'' + timingCondition)
                .orderBy('PurchasedDate__c DESC')
                .executeQuery()
                .getMappedObjects();
            }
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
            .condition('Client__c =  \''+ clientId + '\'' + timingCondition)
            .orderBy('PurchasedDate__c DESC')
            .limitCount(1000)
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }

        if(timingMode != null){
            return records;
        }

        return new BL_WS_Response(totalSize, records, true, null, null);
    }

    public static  Object getClientPurchaseById(String clientId, String featureId){
        Object records = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
                .condition('Client__c =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
                .orderBy('PurchasedDate__c DESC')
                .executeQuery()
                .getResponseMappedObjects()
                .get('records');
       
        return new BL_WS_Response(records);
    }
    
    public static BL_WS_Response getSocialMediaIdentifier(String clientId, Integer featuresSampleLimit,BL_UserInfo me){
        Object records ;

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SOCIAL_MEDIA_IDENTIFIER)
            .condition('Client__c =  \''+ clientId + '\'')
            .executeCount()
            .getTotalSize();

        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SOCIAL_MEDIA_IDENTIFIER)
            .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
            .condition('Client__c =  \''+ clientId + '\'')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SOCIAL_MEDIA_IDENTIFIER)
            .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
            .condition('Client__c =  \''+ clientId + '\'')
            .limitCount(1000)
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    }


    public static BL_WS_Response getSocialMediaIdentifierById(String clientId, String featureId, BL_UserInfo me){
        Object records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SOCIAL_MEDIA_IDENTIFIER)
            .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
            .condition('Client__c =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        return new BL_WS_Response(records);
    }

    public static BL_WS_Response getClientTimeline(String clientId, Integer featuresSampleLimit) {
        
        User u = [SELECT DefaultStore__c, MANAGEMENT_ZONE_LEVEL__c, country__c, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
        
        List<Timeline> timelines = new List<Timeline>();
        timelines.addAll(toList((List<Map<String, Object>>)getClientEvents(clientId,featuresSampleLimit, TimingMode.PAST), 'Event'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientTasks(clientId,featuresSampleLimit, TimingMode.PAST), 'Task'));
        timelines.addAll(toList((List<Map<String, Object>>)getPurchases(clientId,featuresSampleLimit,TimingMode.PAST, null, null), 'Purchase'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientLooks(clientId, featuresSampleLimit, TimingMode.PAST), 'Look'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientIW(clientId, featuresSampleLimit, TimingMode.PAST), 'InteractiveWardrobing'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientRepairs(clientId,featuresSampleLimit, TimingMode.PAST), 'Repair'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientRequests(clientId,featuresSampleLimit, TimingMode.PAST), 'Request'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientSurveys(clientId,featuresSampleLimit, TimingMode.PAST), 'Survey'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientNYOrders(clientId,featuresSampleLimit, TimingMode.PAST), 'NYorder'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientXStoreOrders(clientId,featuresSampleLimit, TimingMode.PAST), 'XStoreOrder'));
        timelines.addAll(toList((List<Map<String, Object>>)getExclusiveSale(clientId), 'Exclusive'));
        timelines.addAll(toList((List<Map<String, Object>>)getClientExperienceVariation(clientId,featuresSampleLimit, TimingMode.PAST), 'ExperienceVariation'));


        if(isPilotZone(u)) {
            system.debug('iszone false');
            timelines.addAll(toList((List<Map<String, Object>>)getClientCampaign(clientId,featuresSampleLimit, TimingMode.PAST), 'Campaign'));
        }

        return sortTimeline(timelines, featuresSampleLimit, 'DESC');
    }

    
    public static Object getClientUpcomings(String clientId, Integer featuresSampleLimit) {
        List<Timeline> upcomings = new List<Timeline>();
        upcomings.addAll(toList((List<Map<String, Object>>)getClientEvents(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'Event'));
        upcomings.addAll(toList((List<Map<String, Object>>)getClientTasks(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'Task'));
        upcomings.addAll(getUpcomingAnniversaries(clientId));
        return sortTimeline(upcomings, featuresSampleLimit, 'ASC');
    }

    public static List<Timeline> getUpcomingAnniversaries(String clientId) {
        List<Timeline> upcomings = new List<Timeline>();
        Date d = Date.today().addDays(15);
        List<Account> client = [Select id, TECH_UpcomingWeddingDate__pc, TECH_UpcomingBirthdayDate__pc, lAstmodifiedBYID from account Where Id = : clientId AND (TECH_UpcomingWeddingDate__pc = NEXT_N_DAYS:15 or TECH_UpcomingWeddingDate__pc = TODAY or TECH_UpcomingBirthdayDate__pc = TODAY or TECH_UpcomingBirthdayDate__pc = NEXT_N_DAYS:15 )];
        if(client.size() > 0){
            if(client[0].TECH_UpcomingWeddingDate__pc != null && client[0].TECH_UpcomingWeddingDate__pc  >= Date.today() &&  client[0].TECH_UpcomingWeddingDate__pc  <= d){
                Timeline wedding = new Timeline(client[0].TECH_UpcomingWeddingDate__pc, new Timeline(client[0].TECH_UpcomingWeddingDate__pc, null, 'Wedding', clientId), 'Wedding', clientId);
                upcomings.add(wedding);
            }

            if(client[0].TECH_UpcomingBirthdayDate__pc != null && client[0].TECH_UpcomingBirthdayDate__pc  >= Date.today() &&  client[0].TECH_UpcomingBirthdayDate__pc  <= d){
                Timeline birthday = new Timeline(client[0].TECH_UpcomingBirthdayDate__pc, new Timeline(client[0].TECH_UpcomingBirthdayDate__pc, null, 'Birthday', clientId), 'Birthday', clientId);
                upcomings.add(birthday);
            }
            
        }
        return upcomings;
    }

    public static Object getExclusiveSale(String clientId) {

        String contactId = [select id, PersonContactId from Account where id =:clientId ]?.PersonContactId;
    
        return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EXCLUSIVE_OFFER)
            .condition('Client__c = \'' + contactId + '\' AND ClientList__r.ExpirationDate__c >= TODAY and  ClientList__r.Active__c = true AND ClientList__r.Type__c =\'' + 'Exclusive' + '\'')
            .orderBy('CreatedDate DESC')
            .executeQuery()
            .getMappedObjects();
    }



    public static Object getClientOngoings(String clientId, Integer featuresSampleLimit) {
        List<Timeline> ongoings = new List<Timeline>();
        
        ongoings.addAll(toList((List<Map<String, Object>>)getClientRepairs(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'Repair'));
        ongoings.addAll(toList((List<Map<String, Object>>)getClientRequests(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'Request'));
        ongoings.addAll(toList((List<Map<String, Object>>)getClientSurveys(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'Survey'));
        ongoings.addAll(toList((List<Map<String, Object>>)getClientNYOrders(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'NYorder'));
        ongoings.addAll(toList((List<Map<String, Object>>)getClientXStoreOrders(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'XStoreOrder'));
        ongoings.addAll(toList((List<Map<String, Object>>)getExclusiveSale(clientId), 'Exclusive'));
        ongoings.addAll(toList((List<Map<String, Object>>)getClientExperienceVariation(clientId,featuresSampleLimit, TimingMode.UPCOMING), 'ExperienceVariation'));
        return sortTimeline(ongoings, -1, 'DESC');
    }

    public static BL_WS_Response sortTimeline(List<Timeline> timelines, Integer featuresSampleLimit, String orderMode){
        List<Object>  resultTimeline = new List<Object>();
        timelines.sort();
        if(orderMode == 'ASC') {
            timelines = reverseTimelines(timelines);
        }
        resultTimeline = timelines;
        if(!isTypedTimeline) {
            resultTimeline = getItems(timelines);
        }

        if(resultTimeline.size() > featuresSampleLimit & featuresSampleLimit != -1){
            resultTimeline = BL_Utils.slice(resultTimeline,0, featuresSampleLimit);
        }
            
        return new BL_WS_Response(resultTimeline.size(), resultTimeline, true, null, null);
    }


    public static BL_WS_Response getClientTimelineById(String clientId, String featureId) {

        String entityName = BL_Utils.getEntityName(featureId);
        switch on entityName {
            when  'Task'{
                return new BL_WS_Response(getClientTaskById(clientId, featureId));
            }
            when 'Event' {
                return new BL_WS_Response(getClientEventById(clientId, featureId));
            }
            when 'CareService__c' {
                return new BL_WS_Response(getClientRepairById(clientId, featureId));
            }
            when 'Case' {
                return new BL_WS_Response(getClientRequestById(clientId, featureId));
            }
            when 'Look__c' {
                return new BL_WS_Response(getClientLookById(clientId, featureId));
            }
            when 'PPR_PurchProduct__c' {
                return new BL_WS_Response(getClientPurchaseById(clientId, featureId));
            }
            when 'Opportunity' {
                return new BL_WS_Response(getClientNYOrderById(clientId, featureId));
            }
            when 'Order__c' {
                return new BL_WS_Response(getClientXStoreOrderById(clientId, featureId));
            }
            /*
            when 'VO_Survey__c' {
                return new BL_WS_Response(getClientSurveyById(clientId, featureId));
            } 
            */
        }
        return null;
    }

    public static BL_WS_Response getClientUpcomingById(String clientId, String featureId) {
        
        String entityName = BL_Utils.getEntityName(featureId);
        switch on entityName {
            when  'Task'{
                return new BL_WS_Response(getClientTaskById(clientId, featureId));
            }
            when 'Event' {
                return new BL_WS_Response(getClientEventById(clientId, featureId));
            }
            when 'CareService__c' {
                return new BL_WS_Response(getClientRepairById(clientId, featureId));
            }
            when 'Case' {
                return new BL_WS_Response(getClientRequestById(clientId, featureId));
            }
            /*
            when 'VO_Survey__c' {
             return new BL_WS_Response(getClientSurveyById(clientId, featureId));
            }
         */
        }
        return null;
    }

    public static BL_WS_Response getClientOngoingById(String clientId, String featureId) {
        
        String entityName = BL_Utils.getEntityName(featureId);
        switch on entityName {
            when 'CareService__c' {
                return new BL_WS_Response(getClientRepairById(clientId, featureId));
            }
            when 'Case' {
                return new BL_WS_Response(getClientRequestById(clientId, featureId));
            }

            when 'Opportunity' {
                return new BL_WS_Response(getClientNYOrderById(clientId, featureId));
            }
            when 'Order__c' {
                return new BL_WS_Response(getClientXStoreOrderById(clientId, featureId));
            }
           /* 
            when 'VO_Survey__c' {
                return new BL_WS_Response(getClientSurveyById(clientId, featureId));
            }
           */
        }
        return null;
    }



    public static Object getClientNYOrders(String clientId ,Integer featuresSampleLimit, TimingMode timingMode) {

        Object records ;
        String statusCondition = ' AND ApplicationSource__c IN (\'PERSO\',\'SPO\') ';
        String orderby = '';

        switch on timingMode {
            when  PAST {
                statusCondition +=  ' AND StageName IN (\'Product delivered to client\',\'Cancelled by store\',\'Cancelled by production\')';
                orderby = 'Createddate DESC';
            }
            when  UPCOMING {
                statusCondition +=  ' AND StageName IN (\'Production to be launched\',\'Production in progress\',\'Distribution in progress \',\'Brief in progress\',\'Quotation in progress\',\'Quotation available \',\'Quotation accepted\',\'Quotation rejected\', \'Production to be launched\',\'Production in progress\', \'Distribution in progress\', \'Received in store\', \'Product delivered to client\')';
                orderby = 'Createddate ASC';
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS)
            .condition('AccountId =  \''+ clientId + '\'' + statusCondition)
            .executeCount()
            .getTotalSize();
        
        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS)
            .condition('AccountId =  \''+ clientId + '\'' + statusCondition)
            .orderBy(orderby)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS)
            .condition('AccountId =  \''+ clientId + '\'' + statusCondition)
            .orderBy(orderby)
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);

    }

    public static Object getClientNYOrderById(String clientId ,String featureId) {
       
       Object records =  new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS_FULL)
        .condition('AccountId =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
        .executeQuery()
        .getMappedObject();
        
        return new BL_WS_Response(records);
    }

    public static Object getClientXStoreOrderById(String clientId ,String featureId) {


        Object records =  new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS_FULL)
        .condition('Account__c =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
        .orderBy('CreatedDate DESC')
        .executeQuery()
        .getMappedObject();
       
        return new BL_WS_Response(records);
    }

    public static Object getClientXStoreOrders(String clientId ,Integer featuresSampleLimit, TimingMode timingMode) {

        Object records ;
        String statusCondition = ' AND Store__r.StoreType__c IN (\'Store\' , \'POP UP - OON\') ';
        String orderby = '';

        switch on timingMode {
            when  PAST {
                statusCondition +=  'AND nbShippingsOngoing__c = 0 AND maxDateOfShippings__c <= LAST_N_DAYS:7';
                orderby = 'Createddate DESC';
            }
            when  UPCOMING {
                statusCondition +=  ' AND nbShippingsOngoing__c > 0';
                orderby = 'Createddate ASC';
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS)
            .condition('Account__c =  \''+ clientId + '\'' + statusCondition)
            .executeCount()
            .getTotalSize();
        
        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS)
            .condition('Account__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy(orderby)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS)
            .condition('Account__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy(orderby)
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);

    }

    public static Object getClientTasks(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;

        String timingcondition = '';
        String orderby = '';

        switch on timingMode {
            when  PAST {
                timingcondition = ' AND (ActivityDate < TODAY  OR Status = \'Completed\') ' ;
                orderby = 'DESC';
            }
            when  UPCOMING {
                timingcondition = ' AND ActivityDate >= TODAY  AND Status != \'Completed\' ' ;
                orderby = 'ASC';
            }
        }
        String condition  =  'WhatId = \'' + clientId + '\' ' + timingcondition; 
       // String conditionTask = ' AND ActionType__c IN (\'WeChat\' ,\'Appointment\',\'Consignment\',\'Email\',\'Phone\',\'SMS\',\'Postal Mail\',\'Other\',\'Mobile Chat\', \'CSC\',\'MS\', \'Voice\', \'WhatsApp\', \'Card\', \'Social\', \'Chat\', \'Line, KakaoChat, WeChat\', \'Other Messenger and Social Media apps\') AND isWardrobing__c = FALSE';
        String conditionTask = ' AND ActionType__c IN (\'WeChat\' ,\'Appointment\',\'Consignment\',\'Email\',\'Phone\',\'SMS\',\'Postal Mail\',\'Other\',\'Mobile Chat\', \'CSC\',\'MS\', \'WhatsApp\', \'Card\', \'Social\', \'Chat\', \'Line, KakaoChat, WeChat\', \'Other Messenger and Social Media apps\') AND isWardrobing__c = FALSE';


        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TASK)
            .condition(condition + conditionTask)
            .orderBy('ActivityDate '+orderby+', CreatedDate DESC')
            .executeQuery()
            .getMappedObjects();
        }
        else{

            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TASK)
            .condition(condition + conditionTask)
            .orderBy('ActivityDate '+orderby+', CreatedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }
        return  records;
    }

    public static Object getClientTaskById(String clientId, String featureId) {
        Object records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TASK)
            .condition('Id = \'' + featureId + '\'')
            .executeQuery()
            .getMappedObject();
        return new BL_WS_Response(records);
    }

    public static Object getClientEvents(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;
        String OnlineAppointmentRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        String AppointmentsRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
        String GoldenRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();
        String EventAppointmentRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Event_Appointment')?.getRecordTypeId();

        List<String> listOfRecordTypesId= new list<String>{
            '\''+OnlineAppointmentRecordTypeId +'\'',
            '\''+AppointmentsRecordTypeId+'\'' ,
            '\''+GoldenRecordTypeId+'\'',
            '\''+EventAppointmentRecordTypeId+'\''
        };

        String timingcondition = '';
        String orderby = '';
        String currentTime = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', 'GMT');

        switch on timingMode {
            when  PAST {
                timingcondition = ' AND StartDateTime < ' + currentTime;
                orderby = 'DESC';
            }
            when  UPCOMING {
                timingcondition = ' AND StartDateTime >=' + currentTime ;
                orderby = 'ASC';
            }
        }
        String condition  =  'WhatId = \'' + clientId + '\' ' + timingcondition; 
        String conditionEvent = ' AND (RecordTypeId IN' + listOfRecordTypesId +' AND Status__c != \'Pending\' AND Status__c != \'Cancelled\')';

        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition(condition + conditionEvent)
            .orderBy('ActivityDate '+orderby+', CreatedDate DESC')
            .executeQuery()
            .getMappedObjects();
        }
        else{

            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition(condition + conditionEvent )
            .orderBy('ActivityDate '+orderby+', CreatedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }
        return  records;
    }

    public static Object getClientEventById(String clientId, String featureId) {
        Object records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition('Id = \'' + featureId + '\'')
            .executeQuery()
            .getMappedObject();
        return new BL_WS_Response(records);
    }

    public static Object getClientIW(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {

        Object records ;
        String timingcondition = '';
        switch on timingMode {
            when  PAST {
                timingcondition = ' AND CreatedDate <= TODAY ' ;
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_INTERACTIVE_WARDROBING)
            .addCondition('AccountId = \'' + clientId + '\' '+timingcondition)
            .executeCount()
            .getTotalSize();

        if(featuresSampleLimit == -1){
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_INTERACTIVE_WARDROBING)
            .addCondition('AccountId = \'' + clientId + '\' '+timingcondition)
            .orderBy('CreatedDate DESC')
            .executeQuery()
            .getMappedObjects();
        }
        else{
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_INTERACTIVE_WARDROBING)
            .addCondition('AccountId = \'' + clientId + '\' '+timingcondition)
            .orderBy('CreatedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }

        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);


    }  

    public static Object getClientIWById(String clientId, String featureId) {
        Object records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_INTERACTIVE_WARDROBING)
            .addCondition('LookId_IW__c = \'' + featureId + '\'')
            .orderBy('CreatedDate DESC')
            .executeQuery()
            .getMappedObject();
        return new BL_WS_Response(records);
    }


    public static Object getClientLooks(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;
        String timingcondition = '';
        switch on timingMode {
            when  PAST {
                timingcondition = ' AND CreatedDate <= TODAY ' ;
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_LOOK)
            .condition('Id IN (Select Look__c From Look_Share__c Where Client__c = \'' + clientId + '\' '+timingcondition+')')
            .executeCount()
            .getTotalSize();

        if(featuresSampleLimit == -1){
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_LOOK)
            .condition('Id IN (Select Look__c From Look_Share__c Where Client__c = \'' + clientId + '\' '+timingcondition+')')
            .orderBy('CreatedDate DESC')
            .executeQuery()
            .getMappedObjects();
        }
        else{
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_LOOK)
            .condition('Id IN (Select Look__c From Look_Share__c Where Client__c = \'' + clientId + '\' '+timingcondition+')')
            .orderBy('CreatedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }

        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    }
    
    public static Object getClientLookById(String clientId, String featureId) {
        Object records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_LOOK)
            .condition('Id = \'' + featureId + '\'')
            .orderBy('CreatedDate DESC')
            .executeQuery()
            .getMappedObject();
        return new BL_WS_Response(records);
    }

    public static Object getClientRepairs(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;
        String statusCondition = '';
        switch on timingMode {
            when  PAST {
                statusCondition = ' AND Followup_Status__c = \'Closed\' ' ;

            }
            when UPCOMING {
                statusCondition =  ' AND Followup_Status__c IN (\'\', \'New\', \'Pending\') '  ;

            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES)
            .condition('Client__c =  \''+ clientId + '\' ' +  statusCondition)
            .executeCount()
            .getTotalSize();
        
        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES)
            .condition('Client__c =  \''+ clientId + '\'' + statusCondition) 
            .orderBy('LastModifiedDate DESC, Followup_Status__c ASC')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES)
            .condition('Client__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy('LastModifiedDate DESC,  Followup_Status__c ASC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records'); 
        }
        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    }

    public static BL_WS_Response getClientRepairById(String clientId, String featureId) {
        Object records = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES_FULL)
                .condition('Client__c =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
                .executeQuery()
                .getMappedObject();

        return new BL_WS_Response(records);

    }
    
    public static Object getClientSurveys(String clientId, Integer featuresSampleLimit , TimingMode timingMode) {
        Object records ;
        String statusCondition = '';
        String managerCondition = '';
        boolean isManager = [
                    SELECT TECH_IsManager__c
                    FROM User
                    WHERE ID = :UserInfo.getUserId()
                ]?.TECH_IsManager__c;

       /* if(isManager == null){
            isManager = false;
        }*/
        
        if(!isManager){
            managerCondition = ' AND (GlobalScore__c = 4 OR GlobalScore__c = 5) ';
        }
        switch on timingMode {
            when  PAST {
                statusCondition = ' AND Solved__c = true AND Status__c = \'live\'  AND (SurveyType__c = \'Retail Post Purchase\' OR SurveyType__c = \'CSC Post Contact\')' + managerCondition ;
            }
            when UPCOMING {
                statusCondition =  ' AND Solved__c = false AND Status__c = \'live\' AND (SurveyType__c = \'Retail Post Purchase\' OR SurveyType__c = \'CSC Post Contact\')' +   managerCondition;

            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SURVEY)
            .condition('ClientDreamID__c =  \''+ clientId + '\'' + statusCondition)
            .executeCount()
            .getTotalSize();
        
        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SURVEY)
            .condition('ClientDreamID__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy('LastModifiedDate DESC')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SURVEY)
            .condition('ClientDreamID__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy('LastModifiedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    } 

    public static BL_WS_Response getClientSurveyById(String clientId, String featureId) {
        Map<String, Object> record =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SURVEY_FULL)
            .condition('ClientDreamID__c =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
            .executeQuery()
            .getMappedObject();

            if(record.get('idTransaction') != null){
                 Object transactions = new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
                    .condition('Client__c =  \''+ clientId + '\' AND TransactionRMSId__c = \''+ record.get('idTransaction') + '\'')
                    .executeQuery()
                    .getMappedObjects();

                record.put('transactions', transactions);
            }
       

        return new BL_WS_Response(record);
    } 
    
        public static Object getClientCampaign(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;
        String timingcondition = '';
        switch on timingMode {
            when  PAST {
                timingcondition = ' AND CreatedDate <= TODAY ' ;
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_CAMPAIGN)
            .condition('MK_Status__c IN (\'clicked\', \'open\', \'sent\') AND Client__c = \'' + clientId + '\' '+timingcondition+'')
            .executeCount()
            .getTotalSize();

        if(featuresSampleLimit == -1){
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_CAMPAIGN)
            .condition('MK_Status__c IN (\'clicked\', \'open\', \'sent\') AND Client__c = \'' + clientId + '\' '+timingcondition+'')
            .orderBy('CreatedDate DESC')
            .executeQuery()
            .getMappedObjects();
        }
        else{
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_CAMPAIGN)
            .condition('MK_Status__c IN (\'clicked\', \'open\', \'sent\') AND Client__c = \'' + clientId + '\' '+timingcondition+'')
            .orderBy('CreatedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }

        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    }
    
    public static Object getClientRequests(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;

        String statusCondition = '';
        switch on timingMode {
            when  PAST {
                statusCondition = ' AND (In_Store_Status__c = \'Closed\')' ;
               // statusCondition = ' AND ( Resolution__c = \'Reply made\' AND ClosedDate = LAST_N_DAYS:7)';

            }
            when UPCOMING {
               // statusCondition =  ' AND In_Store_Status__c IN (\'New\', \'Pending\') '  ;
                statusCondition =  ' AND  (In_Store_Status__c IN (\'New\', \'Pending\') AND Resolution__c = \'Request to Store\' AND Status IN (\'New\', \'Awaiting\'))'  ;

            }
        }

        Integer totalsize = new BL_EasyQuery()
                            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST)
                            .condition('AccountId =  \''+ clientId + '\'' + statusCondition)
                            .executeCount()
                            .getTotalSize();

        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST)
            .condition('AccountId =  \''+ clientId + '\'' + statusCondition)
            .orderBy('LastModifiedDate DESC')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST)
            .condition('AccountId =  \''+ clientId + '\'' + statusCondition)
            .orderBy('LastModifiedDate DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    } 

    public static List<Object> getClientsByClientIds(Map<String,Object> record ,Integer pageIndex,Integer pageSize){
       
       
        List<String> clientIds = new List<String>(); 
 
        for(Object o : (List<Object>)record.get('clientIds')){
            clientIds.add((String) o) ;
        }

        return [SELECT Id ,name,DREAMID__c, toLabel(Salutation), Segmentation__c FROM Account WHERE Id IN: clientIds ];
        
    }

    public static Object getClientsByDreamIds(Map<String,Object> record ,Integer pageIndex,Integer pageSize){
       

        List<String> clientIds = new List<String>(); 
        Object dreamIds = record.get('dreamIds');
        List<String> dreamIdList = (List<String>) JSON.deserialize(JSON.serialize(dreamIds), List<String>.class);

        if(dreamIdList.isEmpty()) return  new Map<String,Object> ();
   
        List<Map<String,Object>> clients = new BL_EasyQuery()
                                    .useCase('Client_Segmentation')
                                    .condition('DREAMID__c IN ' + BL_Utils.convertToString(dreamIdList))
                                    .executeQuery()
                                    .getMappedObjects();

        Map<String,Object> response = new Map<String,Object> ();
        for(Map<String,Object> client : clients ){
            response.put((String)client.get('dreamId'), client);
        }
        
        // List<Account> clients = [SELECT Id, Segment__c, Sub_Segment__c, DREAMID__c, FirstName, LastName, Salutation 
        // FROM Account 
        // WHERE DREAMID__c IN: dreamIdList ] ;

        return response;
    }

    public static List<Object> assignClients(Map<String,Object> record){
        String ownerId = ((Map<String, Object>) record).get('ownerId') != null ? (String) ((Map<String, Object>) record).get('ownerId') : UserInfo.getUserId();
        List<Object> clientIds = ((Map<String, Object>) record).get('clientIds') != null ? (List<Object>) ((Map<String, Object>) record).get('clientIds') : new List<String>();
        List<Account> toUpdate = new List<Account>();
        for(Object clientId : clientIds){
            toUpdate.add(new Account(Id = (String)clientId, OwnerId = ownerId));
        }
        update toUpdate;
        return toUpdate;

    }
    public static BL_WS_Response getClientRequestById(String clientId, String featureId) {
        
        Map<String,Object>  records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST_FULL)
            .condition('AccountId =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
            .executeQuery()
            .getMappedObject();
            
            List<Object> contentDocument = (List<Object>)new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CONTENT_DOCUMENT)
            .condition('LinkedEntityId IN (SELECT Id FROM EmailMessage WHERE  ParentId = \''+ featureId + '\')') 
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');


            if(!contentDocument.isEmpty()){
                if(records.containsKey('contentDocumentLinks')){     
                    contentDocument.addAll((List<Object>)records.get('contentDocumentLinks'));
                }
                records.put('contentDocumentLinks',contentDocument);
            }

            
            return new BL_WS_Response(records);
    } 
    
    public static Object getPurchaseKPI(String clientId, Integer featuresSampleLimit) {
        List<Map<String, Object>> clientKPI = (List<Map<String, Object>>) new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_KPI_NEW)
        .condition('Id = \'' + clientId + '\'')
        .usage(BL_EasyQuery.Usage.FOR_REFERENCE)
        .limitCount(1)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
        
        return clientKPI[0];
    }

    public static BL_WS_Response getClientInterests(String clientId, Integer featuresSampleLimit) {
        Object records ;

        Integer totalsize = new BL_EasyQuery()
                            .useCase(BL_ICON_Constants.USE_CASE_INTERESTS)
                            .condition('Client__c =  \''+ clientId + '\'')
                            .executeCount()
                            .getTotalSize();

        records = new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_INTERESTS)
        .condition('Client__c =  \''+ clientId + '\'')
        .orderBy('Priority__c')
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');

        return new BL_WS_Response(totalSize, records, true, null, null);
    } 

    public static BL_WS_Response getClientInterestById(String clientId, String featureId) {
        Object records = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_INTERESTS)
            .condition('Client__c =  \''+ clientId + '\' AND Id = \''+ featureId + '\'')
            .executeQuery()
            .getMappedObject();

        return new BL_WS_Response(records);
    } 

    public static BL_WS_Response getClientInterestHistoryById(String clientId) {
        String source = 'ICON';
        String field = 'isActive__c';
        Object records = new BL_EasyQuery()
        .objectname('Interests__history')
        .fields(new List<String>{'newValue','parent.categories__c','createdby.name','createdDate' })
        .condition('parent.client__c =  \''+ clientId + '\' AND Parent.source__c = \''+ source + '\'' )
        .orderBy('createddate DESC')
        .limitCount(5)
        .executeQuery()
        .getSObjects();
         //.getMappedObject();
         return new BL_WS_Response(records);

    } 
    public static String getProductRecommendation(String clientId, BL_UserInfo me) {

        List<Account> client = (List<Account>) new BL_EasyQuery()
            .useCase(BL_ICON_CONSTANTS.USE_CASE_CLIENT)
            .condition('Id = \'' + clientId + '\'')
            .executeQuery()
            .getSObjects();
        if(me.basicInfos.WWEmployeeNumber__c == null || client[0]?.DREAMID__c == null){
            throw new BL_Exceptions.RouterException('Invalid Client REST Method - LVMId or DreamId empty');    
        } 
        List<Product_Recommendation__c> records = (List<Product_Recommendation__c>)new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_PRODUCT_RECOMMENDATION)
            .condition('LVM_Id__c = \''+me.basicInfos.WWEmployeeNumber__c+'\' AND Dream_Id__c = \''+client[0].DREAMID__c+ '\'')
            .executeQuery()
            .getSObjects();

        if(records.isEmpty())
            return '';
        return records[0].ProductRecommendation__c;
    }

     /*public static Object getClientClubMembership(String clientId, Integer featuresSampleLimit, TimingMode timingMode) {
        Object records ;
        String timingcondition = '';
        switch on timingMode {
            when  PAST {
                timingcondition = ' AND Club_and_Seasons__r.clubSeasonEndDate__c < TODAY ' ;
            }
            when  UPCOMING {
                timingcondition = ' AND Club_and_Seasons__r.clubSeasonEndDate__c >= TODAY ' ;
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLUB_MEMBER)
            .condition('isClubEligible__c = true AND clientId__c = \'' + clientId + '\' '+timingcondition+'')
            .executeCount()
            .getTotalSize();

        if(featuresSampleLimit == -1){
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLUB_MEMBER)
            .condition('isClubEligible__c = true AND clientId__c = \'' + clientId + '\' '+timingcondition+'')
            .executeQuery()
            .getMappedObjects();
        }
        else{
            records =  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_CLUB_MEMBER)
            .condition('isClubEligible__c = true AND clientId__c = \'' + clientId + '\' '+timingcondition+'')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getMappedObjects();
        }

        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    }*/
    public static Object getClientExperienceVariation(String clientId, Integer featuresSampleLimit , TimingMode timingMode) {
        
        Object records ;
        String statusCondition = '';
        
        switch on timingMode {
            when  PAST {
                statusCondition = ' AND Brand_Experience_Variation__r.StartDateTime__c < today';

            }
            when UPCOMING {
                statusCondition =  ' AND Brand_Experience_Variation__r.StartDateTime__c >= today';
            }
        }

        Integer totalsize = new BL_EasyQuery()
            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
            .condition('Client__c =  \''+ clientId + '\'' + statusCondition)
            .executeCount()
            .getTotalSize();
        
        if(featuresSampleLimit == -1){
            records = new BL_EasyQuery()
            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
            .condition('Client__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy('Brand_Experience_Variation__r.StartDateTime__c DESC')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        else{
            records = new BL_EasyQuery()
            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
            .condition('Client__c =  \''+ clientId + '\'' + statusCondition)
            .orderBy('Brand_Experience_Variation__r.StartDateTime__c DESC')
            .pagination(0,featuresSampleLimit)
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        }
        if(timingMode!= null){
            return records;
        }
        return new BL_WS_Response(totalSize, records, true, null, null);
    } 
    

    public enum TimingMode { PAST, UPCOMING }
    // public enum OrderMode { ASC, DESC }

    public static Map<string, string>  activityfieldMap(){
        return new Map<String, String>{
            'Repair' => 'originalDeliveryDate',
            'Request' => 'lastModifiedDate',
            'Survey' => 'answerDate',
            'Look' => 'createdDate',
            'Event' => 'activityDateTime',
            'Task' => 'completedDates',
            'Purchase' => 'purchasedDate',
            'Exclusive' => 'createdDate',
            'NYorder' => 'createdDate',
            'XStoreOrder' => 'createdDate',
            'Campaign' => 'createdDate',
            'ExperienceVariation' => 'activityDate'
             // 'ClubMember'=> 'activityDate'
        };
    } 

    public static List<Timeline> toList(List<Map<String, Object>> items, String timelineType){
        List<Timeline> res = new List<Timeline>();
        for(Map<String, Object> item : items){
            item.put('type', timelineType);
            Datetime activityDate;
            String activityDateField = activityfieldMap().get(timelineType);
            if(item.get(activityDateField) instanceof Date) {
                activityDate = (Date) item.get(activityDateField);
            }
            else if(item.get(activityDateField) instanceof Datetime) {
                activityDate = ((Datetime) item.get(activityDateField));
            } else {
                activityDate = ((Datetime) item.get('lastModifiedDate'));
            }
            res.add(new Timeline(activityDate, item, timelineType, (String) item.get('id')));
            
        }
        return res;
    }

    public static List<Object> getItems(List<Timeline> timelines){
        List<Object> items = new List<Object>();
        for(Timeline tml : timelines){
            items.add(tml.item);
        }
        return items;
    }

    public static List<Timeline> reverseTimelines(List<Timeline> input ) {
        List<Timeline> reversed = new List<Timeline>();

        for(Integer i = input.size() - 1; i >= 0; i--){
            reversed.add(input[i]);
        }

        return reversed;
    }
    
        private static Boolean isPilotZone(User u) {
        String excludedZone  = [
                SELECT  Excluded_Zones__c 
                FROM Pilot_Setting__mdt 
                WHERE Application__c = 'ICON CAMPAIGN' LIMIT 1
            ]?.Excluded_Zones__c;
            
            
        if(String.isBlank(excludedZone) || String.isBlank(u.MANAGEMENT_ZONE_LEVEL__c)) {
            system.debug('iszone false');
            return true;
        }
        if (excludedZone.containsIgnoreCase(u.MANAGEMENT_ZONE_LEVEL__c)){
            return false;
        }
        return true;
    }



    public  class Timeline implements Comparable {
        public Datetime activityDate;
        public Object item;
        public String type;
        public String id;

        public Timeline(Datetime activityDate, Object item, String tmType, string tmid){
            this.activityDate = activityDate;
            this.item = item;
            this.type = tmType;
            this.id = tmid;
        }

        public Integer compareTo(Object compareTo){
            Timeline compareToTml = (Timeline)compareTo;
            if(activityDate == compareToTml.activityDate) return 0;
            if(activityDate < compareToTml.activityDate) return 1;
            return -1;
        }

    }
}