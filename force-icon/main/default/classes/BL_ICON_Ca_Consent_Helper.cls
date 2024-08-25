public with sharing class BL_ICON_Ca_Consent_Helper {


    public static Object getConsentUserStore(Integer pageIndex, Integer pageSize, BL_UserInfo me ) {

        Map<String,String> customFieldStringMap = new Map<String,String>{
        '{STORE_ID}' => '\''+  me.basicInfos.DefaultStore__c +'\'' 
        };

        BL_EasyQuery easyQuery = new BL_EasyQuery();

       easyQuery.setCustomFieldString(customFieldStringMap);

        Object records =  easyQuery
        .useCase(BL_ICON_Constants.USE_CASE_CA_CONSENT_TEAM )
        .condition('(DefaultStore__c = \''+  me.basicInfos.DefaultStore__c + '\'  AND IsActive =TRUE) OR Id = \'' +  UserInfo.getUserId() + '\'')  
        .orderBy('LastModifiedDate DESC')
        .pagination(pageIndex, pageSize)
        .executeQuery()
        .getMappedObjects();

        return new BL_WS_Response(records);
    }

    public static Object updateConsentUser(Object record){
        try{
            
            return new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_CA_CONSENT)
                    .upsertWrappersWithChilds(new List<Object>{record}, null, null);
			            
        } catch(Exception ex){
            return new Map<String,Object> {'status' =>'error ' + ex};
        }
    }

}