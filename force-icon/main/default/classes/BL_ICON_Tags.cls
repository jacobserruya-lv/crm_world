global with sharing class BL_ICON_Tags extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePOST, BL_WS_Interfaces.DispatchableDELETE{
    global Object executeGET(){
        String clientId = null;
        String pathId = getQueryParameter('clientId');
        String wcwid;
        if(getQueryParameter('wcwid') != null){
            wcwid = getQueryParameter('wcwid'); 
        }
        if (String.isNotEmpty(pathId) || String.isNotEmpty(wcwid)) {
            clientId = BL_ICON_Client_Helper.checkParameters(pathId, wcwid);
        }

        // String featureId = (getPathParameter('featureId') != null ? getPathParameter('featureId') : null);
        String features = (getQueryParameter('features') != null ? getQueryParameter('features') : null);

        if (String.isNotEmpty(clientId) && features == null)
            return BL_ICON_Tags_Helper.getAllMyClientTags(clientId, me);
        else if(String.isNotEmpty(clientId) && features != null){
            return BL_ICON_Tags_Helper.getMyClientTagsByFeatures(clientId, features, me);
        } else if(features != null){
            return BL_ICON_Tags_Helper.getMyTagsByFeatures(features, me);
        }
        else {
            return BL_ICON_Tags_Helper.getAllMyTags(me);
        }
    }

    global Object executePOST(){
        List<Object> records = getRequestRecords();

        //  for each records, modify the future_key_dates if exists
        for(Object record: records){
            Map<String, Object> recordmapped = (Map<String, Object>) record;
            if(recordmapped.containsKey('future_key_dates')){
                Object futureKeyDates = recordMapped.get('future_key_dates');
                if(futureKeyDates != null){
                    recordMapped.put('future_key_dates', JSON.serialize(futureKeyDates));
                }
                
            }
        }
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_TAG)
                .upsertWrappersWithChilds(records, Tag__c.Fields.ExternalId__c, null);
    }

    global Object executeDELETE(){
        String tagId = (getPathParameter('tagId') != null ? getPathParameter('tagId') : null);
        if (String.isNotBlank(tagId)){
            Tag__c tag = new Tag__c(Id=tagId);
            // delete tag;
            tag.Is_Deleted__c = true;
            update tag;
        } else {
            List<Object> records = getRequestRecords();
            List<String> externalIds = new List<String>();
            List<Tag__c> tagsToUpdate = new List<Tag__c>();
            for(Object rec : records){
                map<String, Object> obj = (map<String, Object>) rec;
                String extId = obj.get('externalId') != null ? (String) obj.get('externalId') : null;
                if(String.isNotBlank(extId)){
                    externalIds.add(extId);
                    tagsToUpdate.add(new Tag__c(ExternalId__c=extId, Is_Deleted__c =true));
                }           
            }
                // List<Tag__c> tagsTodelete = [Select Id from Tag__c where ExternalId__c IN :externalIds];
                // delete tagsTodelete;
            upsert tagsToUpdate ExternalId__c;
        }
        
        return true;
    }
}