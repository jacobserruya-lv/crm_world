/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-16-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class BL_ICON_Look_Helper {
    public static List<Map<String, Object>> shareLooks(Map<String,Object> requestBody){
        String lookId = (requestBody.get('lookId') != null ? (String) requestBody.get('lookId') : null);
        String reqClientId = (requestBody.get('clientId') != null ? (String) requestBody.get('clientId') : null);
        String channel = (requestBody.get('channel') != null ? (String) requestBody.get('channel') : null);
        String ownerId = (requestBody.get('ownerId') != null ? (String) requestBody.get('ownerId') : UserInfo.getUserId());


        String clientId = BL_ICON_Client_Helper.checkParameters(reqClientId, null);

        requestBody.put('externalId' , lookId + clientId + channel);
        requestBody.put('clientId' , clientId);
        if(ownerId != null)
            requestBody.put('createdBy.id' , ownerId);
            
        List<Map<String,Object>> LookShareRecords = new List<Map<String,Object>>();
        LookShareRecords.add(requestBody);
        try{
            List<Look_Share__c> lookShares = (List<Look_Share__c>) new BL_EasyQuery()
                                         .useCase(BL_ICON_Constants.USE_CASE_LOOKSHARE)
                                         .convertWrapperToSObject(LookShareRecords);
            upsert lookShares;

            Datetime validDtate = datetime.now();
            Look__c look = new Look__c(Id= lookId, is_Draft__c = false, Validity_Date__c = validDtate.addYears(1).date());
            update look;

        } catch(Exception e){
            system.debug(e.getMessage());
        }
        

       

        List<Map<String,Object>> taskRecords = new List<Map<String,Object>>();
        requestBody.put('subject' , channel.toUpperCase() + ' message sent');
        requestBody.put('priority' , 'Normal');
        requestBody.put('activityDate' , system.Date.today());
        requestBody.put('isWardrobing' , true);
        requestBody.put('outreachType' , 'Mobile Chat');
        requestBody.put('status' , 'Completed');
        requestBody.put('ownerId' , String.IsnotBlank(ownerId) ? ownerId : UserInfo.getUserId());

        taskRecords.add(requestBody);
            
        List<Task> tasks = (List<Task>) new BL_EasyQuery()
                            .useCase(BL_ICON_Constants.USE_CASE_TASK)
                            .convertWrapperToSObject(taskRecords);
        insert tasks;
            
        return (List<Map<String, Object>>) new BL_EasyQuery().useCase(BL_ICON_Constants.USE_CASE_LOOKSHARE).condition('ExternalId__c = \'' + lookId + clientId + channel + '\'' ).executeQuery().getMappedObjects(); 
        
    }


    public static List<Map<String,Object>> getLooks(Integer pageIndex, Integer pageSize, BL_UserInfo me){
        return new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_LOOK)
        .condition(' OwnerId = \'' + me.basicInfos.Id + '\' ') /*AND (Id NOT IN (SELECT Look__c from Look_Share__c))*/
        .orderBy('CreatedDate DESC')
        .pagination(pageIndex, pageSize)
        .executeQuery()
        .getMappedObjects();
    }

    public static List<Map<String,Object>> getLooksById(Integer pageIndex, Integer pageSize, BL_UserInfo me, String lookId){
        List<Map<String,Object>> look =  new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_LOOK)
        .condition('Id = \'' + lookId  + '\' ')
        .orderBy('CreatedDate DESC')
        .pagination(pageIndex, pageSize)
        .executeQuery()
        .getMappedObjects();

        if(look.size() > 0){
            if(String.isBlank((String)look[0].get('shortUrlSharing')) && String.isNotBlank((String)look[0].get('lvUrlSharing'))){
                try{
                    look[0].put('shortUrlSharing', WRDB_WS_Look.getShortenedLookLVURL((String)look[0].get('lvUrlSharing')));
                }catch(Exception e){
            		system.debug(e.getMessage());
        		}
            }
        }

        return look;
    }
    //Validity_Date__c >= TODAY AND OwnerId = \'' + me.basicInfos.Id + '\' AND 
}