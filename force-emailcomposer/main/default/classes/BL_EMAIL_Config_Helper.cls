public without sharing class BL_EMAIL_Config_Helper {
    
    public static Map<String, Object> getConfigByFeatures(String features, String applicationName){
        Map<String, Object> result = new Map<String, Object>();
        List<String> featuresList = features.split(';');

        for(String f : featuresList){
            switch on f{
                when 'senderAddresses'{
                    result.put(BL_EMAIL_Constants.JSONRoot_SenderAddresses, BL_EMAIL_Config_Helper.getSenderAddresses());
                } 
                when 'settings' {
                    result.put('settings', getSettingByApp(applicationName));
                }
                when 'templateImages' {
                    result.put('templateImages', getTempaleImages());
                }
            }
        }
        return result;
    }

    public static Object  getTempaleImages(){
        return new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_ICONICS_SETTINGS)
            .executeQuery()
            .getSObject();
    }

    public static List<Object> getSenderAddresses(){
        List<Map<String,Object>> records = new List<Map<String,Object>>();

        Map<String,Object> user = new  Map<String,Object> {
            'id'=> UserInfo.getUserId(),
            'name' => UserInfo.getName(),
            'email' => UserInfo.getUserEmail(),
            'type' => 'User'
        };

        records.add(user);  
        records.addAll(getOrgWideEmailAddress());
    
        return records;    
    }

    public static Map<String,Object> getSenderAddressByEmail(String email){    
        
        
        return getSenderByAddress(email);
    }

    public static Map<String,Object> getSenderByAddress(String value){

        Map<String,Object> record = new Map<String,Object>();

        List<OrgWideEmailAddress> records = [
            SELECT Id, Address, DisplayName 
            FROM OrgWideEmailAddress
            WHERE Address =: value
            LIMIT 1
        ];

        OrgWideEmailAddress owa = records.isEmpty() ? null : records.get(0);
        
        if(owa != null)   {
            record = new Map<String,Object> { 
                'id'=> owa.Id,
                'name' => owa.DisplayName,
                'email' => owa.Address,
                'type' => 'OrgWideEmailAddress'
            };
        }
        
        return record;
    }


    public static List<Map<String,Object>> getOrgWideEmailAddress(){
        List<Map<String,Object>> records = new List<Map<String,Object>>();

        Map<Id,OrgWideEmailAddress> owea = new Map<Id,OrgWideEmailAddress>([
            SELECT Id, Address, DisplayName 
            FROM OrgWideEmailAddress
        ]);
        
        for(OrgWideEmailAddress owa : owea.values() ){

            Map<String,Object> record = new Map<String,Object> { 
                'id'=> owa.Id,
                'name' => owa.DisplayName,
                'email' => owa.Address,
                'type' => 'OrgWideEmailAddress'
            };
            records.add(record);    
        }

        return records;
    }
    

    public static Map<String,Object> getSettingByApp(String application){
        Map<String,Object> record = new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_EMAIL_CONFIGURATOR)
            .condition( 'application__c = \'' + application + '\'')
            .executeQuery()
            .getMappedObject();

        return record;
    }


}