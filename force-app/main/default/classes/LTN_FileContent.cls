/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-22-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class LTN_FileContent {
	@AuraEnabled
    public static String getFileContent(Id recordId){
        List<ContentDocumentLink> cdList= [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId order by ContentDocument.createddate DESC];
        if(!cdList.isEmpty())
        { 
          string  contentDocId = cdList[0].ContentDocumentId ;        
          blob fileData = [SELECT IsLatest,versionData FROM ContentVersion WHERE IsLatest=true AND ContentDocumentId =: contentDocId].versionData;
          return fileData.toString();
        }
        else return null;
    } 
    
    @AuraEnabled
    public static void updateFileContent(Id recordId, String newFileContent){
        string resultMessage;
        string contentDocId = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId].ContentDocumentId;
        ContentVersion[] cvs = [SELECT Id, versionData FROM ContentVersion WHERE IsLatest=true AND ContentDocumentId =:contentDocId  ORDER BY CreatedDate DESC];
        Blob fileContent = Blob.valueOf(newFileContent);
        cvs[0].versionData = fileContent;
        
        try {
        	update cvs[0];
        }
            catch(Exception e) {
            resultMessage = e.getMessage();
        }
    }
}