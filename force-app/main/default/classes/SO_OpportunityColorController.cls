public class SO_OpportunityColorController {
    
    @AuraEnabled
    public static Opportunity findById(Id oppId) {
        return [SELECT Name, SPO_ProductCategory__c, SPO_OrderType__c, SPO_CreationType__c,SPO_ColorMetalicparts__c, StageName,  SPO_ExteriorMaterialColor1__c, SPO_ExteriorMaterial1__c, SPO_ExteriorMaterial1localcomment__c, SPO_ExtMaterialColor1localcomment__c,
                SPO_ExteriorMaterialColor2__c, SPO_ExteriorMaterial2__c, SPO_ExteriorMaterial2localcomment__c, SPO_ExtMaterialColor2localcomment__c,
                SPO_ExteriorMaterialColor3__c, SPO_ExteriorMaterial3__c, SPO_ExteriorMaterial3localcomment__c, SPO_ExtMaterialColor3localcomment__c,
                SPO_LiningInteriorMaterial1__c, SPO_LiningInteriorColor1__c, SPO_LiningColor1LocalComment__c, SPO_LiningMaterial1LocalComment__c,
                SPO_LiningInteriorMaterial2__c, SPO_LiningInteriorColor2__c, SPO_LiningColor2LocalComment__c, SPO_LiningMaterial2LocalComment__c,
                SPO_ColorMetalicPartsLocalComment__c
                FROM Opportunity WHERE Id = :oppId];
    }
    
    // waiting summer '17 with dependent picklist
    @AuraEnabled
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName) {
        return SO_PicklistFieldController.getDependentOptionsImpl(objApiName, contrfieldApiName, depfieldApiName);
    }
    
    @AuraEnabled
    public static List<String> getDependentOptions(String objApiName, String contrfieldApiName, String depfieldApiName, String contrFieldValue) {
        return SO_PicklistFieldController.getDependentOptions(objApiName, contrfieldApiName, depfieldApiName, contrFieldValue);
    }

    @AuraEnabled
    public static List<SPO_Colors__c> getPictoColorList(List<String> colorListNames) {
        System.debug('colorListNames=' + colorListNames);
        return 
            [SELECT Id, Name 
             ,SPO_Preview__c
             ,SPO_CodeCouleur__c
             ,SPO_Description__c
             ,SPO_Position__c
             ,SPO_StaticResourceName__c
             FROM SPO_Colors__c
             WHERE Name IN :colorListNames];
    }

    @AuraEnabled
    public static Map<String, SPO_Colors__c> getPictoColorMap(List<String> colorListNames) {
        Map<String, SPO_Colors__c> colorMap = new Map<String, SPO_Colors__c>();
        for (SPO_Colors__c color : getPictoColorList(colorListNames)) {
            colorMap.put(color.Name, color);
        }
        System.debug('getPictoColorMap>colorMap=' + colorMap);
        return colorMap;
    }

    @AuraEnabled
    public static void saveColor(Opportunity opportunity) {
        System.debug('save > opp=' + opportunity);
        update opportunity;
    }
    
    @AuraEnabled
    public static User getUserProfile() {
        return [SELECT Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

     @AuraEnabled
    public static Map<String, String> getSPAPersonalizationJson() {
        Map<String, String> picklistMap = new Map<String, String>();
        picklistMap.put('CREATIONTYPE', getCreationTypeJson());
        //picklistMap.put('UNIT', getUnitJson());
        picklistMap.put('COLORMETALIC', getColorMetalicJson());
        //picklistMap.put('PAINTING', getPaintingJson());
        //picklistMap.put('PAINTINGSTYLE', getPaintingStyleJson());
        //picklistMap.put('PRODUCTCATEGORY', getProductCategoryJson());
        //picklistMap.put('SPECIALEVENT', getSpecialEventJson());
        return picklistMap;
    }

    @AuraEnabled
    public static String getCreationTypeJson() {
        List<PicklistEntry> values = Opportunity.SPO_CreationType__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }
    

    @AuraEnabled
    public static String getColorMetalicJson() {
        List<PicklistEntry> values = Opportunity.SPO_ColorMetalicparts__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);        
    }
}