global with sharing class objectsInspection {

    @InvocableMethod(label='Objects Inspection for flow')
    public static List<String> getObjectsTypes(List<String> recordIds)
    {
        String objectId = recordIds[0];
        Id var =Id.valueOf(objectId);
       List<String> sObjectTypes = new List<String>();
       String sObjName = var.getSObjectType().getDescribe().getName();

    sObjectTypes.add(sObjName);
    
    return sObjectTypes;
        
    }

}