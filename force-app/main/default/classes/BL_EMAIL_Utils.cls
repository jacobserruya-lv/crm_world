public with sharing class BL_EMAIL_Utils {
    public static Map<String,Object> getRecordDetail(String useCase, String recordId){
        return new BL_EasyQuery()
            .useCase(useCase)
            .condition('Id = \'' + recordId + '\'')
            .executeQuery()
            .getMappedObject();
    }
}