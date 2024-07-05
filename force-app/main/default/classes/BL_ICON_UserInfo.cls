/**
 * 
 * @author Jeremy Martiano
 * @since March 2020
 * @description Class to handle all the User Info 
 * required for the webservices (i:e Profile,Role stores reference,... ) 
 * in order to retrieve the right data. Each application will have his User Info that can extends and inherits this class.
 * @group Clienteling
 */
global with sharing class BL_ICON_UserInfo extends BL_UserInfo{

    public BL_ICON_UserInfo(){
        super();
    }

    public BL_ICON_UserInfo(String useCase){
        super(useCase);
    }
    
    global override Map<String,Object> extendInfos(){

        List<Map<String,Object>> storesList = new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_STORE)
        .condition( 'RetailStoreId__c = \'' +  basicInfos.DefaultStore__c + '\'')
        .executeQuery()
        .getMappedObjects();

        String localLVCOM = 'eng-e1'; 
        String localCatalog ='en_E1' ; 

        String isoCode3 = storesList.size() > 0 ? (String)storesList[0].get('countryIsoCode3'): null ;

        Boolean isCommissioningPilot = IC_UTILS.isUserInPilot('ICON_Commissioning');
        Boolean isEngagedPilot = IC_UTILS.isUserInPilot('ICON_Pilot_Settings');

        //Interactive Wardrobing
        if(String.IsnotEmpty(isoCode3)){
        
            List<CountryLanguage__c> local = [SELECT ATG_Locale__c, Catalogue_Locale__c FROM CountryLanguage__c WHERE Default__c = true AND Country__r.Iso3Code__c =: isoCode3 Limit 1];
            CountryLanguage__c country = !local.isEmpty() ? local.get(0) : null;
            localLVCOM = String.IsnotEmpty(country?.ATG_Locale__c) ? country?.ATG_Locale__c : 'eng-e1' ;
            localCatalog = String.IsnotEmpty(country?.Catalogue_Locale__c) ? country?.Catalogue_Locale__c : 'en_E1' ;      
        }

        return new Map<String,Object>{
            'storeName' => (storesList.size() > 0 ? storesList[0].get('name'): null) ,
            'storeCodeIso3' => (storesList.size() > 0 ? storesList[0].get('countryIsoCode3'): null), 
            'storeCodeIso2' => (storesList.size() > 0 ? storesList[0].get('countryIsoCode2'): null),
            'timeZoneId' => (storesList.size() > 0 ? storesList[0].get('timeZoneId'): null),
            'localLvSite' => localLVCOM,
            'ecomStore' => (storesList.size() > 0 ? storesList[0].get('ecomStore'): null),
            'countryLabel' => (storesList.size() > 0 ? storesList[0].get('storeCountry'): null),
            'localCatalog'=> localCatalog,
            'isCommissioningPilot' => isCommissioningPilot,
            'isEngagedPilot' => isEngagedPilot
        };
    }

    global override Map<String, String> userMergeFields() {
        return new Map<String, String>{
            'USER_ID'    => BL_Utils.toString(basicInfos.Id),
            'STORE_CODE' => BL_Utils.toString(basicInfos.DefaultStore__c)/*,
            'PROFILE_ID' => BL_Utils.toString(basicInfos.ProfileId)*/
        };
    }
}