/**
 * 
 * @author 
 * @since 
 */
public class BL_FieldsMapping {
    @AuraEnabled public String     SFFieldPath          {get; set;}
    @AuraEnabled public String     Wrapper_Field_Name   {get; set;}
    @AuraEnabled public BL_UseCase UseCase              {get; set;}
    @AuraEnabled public String     UseCaseName          {get; set;}
    @AuraEnabled public Boolean    Save_to_SF           {get; set;}
    @AuraEnabled public Boolean    Send_to_Clienteling_App {get; set;}
    @AuraEnabled public Boolean    GetPicklistLabel     {get; set;}
    @AuraEnabled public Boolean    IsCurrency           {get; set;}
    @AuraEnabled public BL_UseCase InnerSelect_UseCase  {get; set;}
    @AuraEnabled public Boolean    Is_InnerSelect       {get; set;}
    @AuraEnabled public String     FieldType            {get; set;}
    @AuraEnabled public String     DeveloperName        {get; set;}
    @AuraEnabled public BL_UseCase Sub_UseCase          {get; set;}
    @AuraEnabled public Boolean    Is_Sub_UseCase          {get; set;}
    @AuraEnabled public String     TargetPlatform       {get; set;}


    private static Schema.SObjectField useCaseField = BL_ObjectDescriber.getFields(BL_Constants.BL_FIELD_MAPPING_MDT_NAME).get(BL_Constants.BL_FM_USECASE);
    private static Schema.SObjectField innerUseCaseField = BL_ObjectDescriber.getFields(BL_Constants.BL_FIELD_MAPPING_MDT_NAME).get(BL_Constants.BL_FM_INNER_SELECT_UC);
    private static Schema.SObjectField subUseCaseField = BL_ObjectDescriber.getFields(BL_Constants.BL_FIELD_MAPPING_MDT_NAME).get(BL_Constants.BL_FM_USECASE);

    private static Map<String, Map<String, BL_FieldsMapping>> fieldMappingMap = new Map<String, Map<String, BL_FieldsMapping>>();

    public BL_FieldsMapping() {
        this.Is_InnerSelect = false;
        this.Is_Sub_UseCase = false;
        this.IsCurrency = false;
        this.Save_to_SF = false;
        this.Send_to_Clienteling_App = false;
        this.GetPicklistLabel = false;
    }

    /**
     * BL_FieldsMapping contructor
     * @param fieldsMapping 
     */
    public BL_FieldsMapping(SObject fieldsMapping) {
        this.DeveloperName = (String)getValue(fieldsMapping, BL_Constants.BL_FM_DEVELOPER_NAME);
        this.SFFieldPath = (String)getValue(fieldsMapping, BL_Constants.BL_FM_SF_FIELDPATH);
        this.Wrapper_Field_Name = (String)getValue(fieldsMapping, BL_Constants.BL_FM_WRAPPER_FIELD_NAME);
        this.UseCase = fieldsMapping.isSet(BL_Constants.BL_FM_USECASE) ? new BL_UseCase(fieldsMapping.getSObject(useCaseField)) : null;
        this.Save_to_SF = (Boolean)getValue(fieldsMapping, BL_Constants.BL_FM_SAVE_TO_SF);
        this.Send_to_Clienteling_App = (Boolean)getValue(fieldsMapping, BL_Constants.BL_FM_SEND_TO_CLIENTELING);
        this.GetPicklistLabel = (Boolean)getValue(fieldsMapping, BL_Constants.BL_FM_GET_PICKLIST_LABEL);
        this.IsCurrency = (Boolean)getValue(fieldsMapping, BL_Constants.BL_FM_IS_CURRENCY);
        this.InnerSelect_UseCase = fieldsMapping.isSet(BL_Constants.BL_FM_INNER_SELECT_UC) ? new BL_UseCase(fieldsMapping.getSObject(innerUseCaseField)) : null;
        this.Is_InnerSelect = (Boolean)getValue(fieldsMapping, BL_Constants.BL_FM_IS_INNER_SELECT);
        this.Sub_UseCase = fieldsMapping.isSet(BL_Constants.BL_FM_USECASE) ? new BL_UseCase(fieldsMapping.getSObject(subUseCaseField)) : null;
        this.Is_Sub_UseCase = fieldsMapping.isSet(BL_Constants.BL_FM_IS_INNER_SELECT) ? (Boolean)getValue(fieldsMapping, BL_Constants.BL_FM_IS_INNER_SELECT) : false;
        this.TargetPlatform = (String)getValue(fieldsMapping, BL_Constants.BL_FM_TARGET_PLATFORM );

    }

    /**
     * 
     * @param useCase 
     * @returns `Map<String, BL_FieldsMapping>`
     * @description getValidMapping by useCase
     */
    public static Map<String, BL_FieldsMapping> getValidMapping(BL_UseCase useCase) {
        if(fieldMappingMap.get(useCase.Id) == null) {
            Map<String, BL_FieldsMapping> result = new Map<String, BL_FieldsMapping>();
            Map<String, SObjectField> fields = BL_ObjectDescriber.getFields(useCase.ObjectName);
            List<BL_FieldsMapping> fullMapping = getFullMapping(useCase.Id);
            for(BL_FieldsMapping mappingItem : fullMapping) {
                if(mappingItem != null){
                    String sfFieldPath = mappingItem.SFFieldPath;
                    system.debug(sfFieldPath);
                    if(fields.get(sfFieldPath)!=null) {
                        system.debug(fields.get(sfFieldPath).getDescribe().isAccessible());
                    } else {
                        system.debug('Not Accessible');
                    }
                    
                    if ((mappingItem.TargetPlatform == BL_WS_Router.clientPlatform || String.isBlank(mappingItem.TargetPlatform) || String.isBlank(BL_WS_Router.clientPlatform)) && (fields.get(sfFieldPath) != null && fields.get(sfFieldPath).getDescribe().isAccessible() == true || (sfFieldPath != null && sfFieldPath.contains('.')) || mappingItem.Is_InnerSelect || (mappingItem.Is_Sub_UseCase!= null && mappingItem.Is_Sub_UseCase))) {
                        if (!result.containsKey(sfFieldPath)){
                            result.put(sfFieldPath, mappingItem);
                        }
                    } 
                }
            }
            system.debug(result);
            fieldMappingMap.put(useCase.Id ,result);
            return result;
        } else {
            return fieldMappingMap.get(useCase.Id);
        }
        
    }

    /**
     * @param useCaseId 
     * @returns `List<BL_FieldsMapping>`
     * @description get the fields mapping of the usecase
     */
    public static List<BL_FieldsMapping> getFullMapping(Id useCaseId) {

        SObject useCase = new BL_EasyQuery()
        .objectName(BL_Constants.BL_USECASE_MDT_NAME)
        .allFields()
        .condition('Id =\'' + useCaseId + '\' ')
        .limitCount(1)
        .executeQuery()
        .getSObject();
        String mappingJson = (String) useCase.get(BL_Constants.BL_UC_FIELDS_MAPPING_JSON);

        if (String.isNotEmpty(mappingJson)) {
            return (List<BL_FieldsMapping>) System.JSON.deserialize(mappingJson, List<BL_FieldsMapping>.class);
        }
        return null;
    }

    private Object getValue(SObject fieldMapping, String fieldName) {
        if (fieldMapping != null && fieldMapping.isSet(fieldName)) {
            return fieldMapping.get(fieldName);
        }
        return null;
    }
}