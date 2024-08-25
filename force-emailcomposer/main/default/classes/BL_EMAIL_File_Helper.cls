public with sharing class BL_EMAIL_File_Helper {
  
    public static List<ContentVersion> createContentVersions(List<Object> files) {
        List<ContentVersion> documents = new List<ContentVersion>();
        for(Object file : files){
            Map<String,Object> document =  (Map<String,Object>) file;

            ContentVersion newVers = new ContentVersion();
            newVers.Title = (String) document.get('title');
            newVers.VersionData = EncodingUtil.base64Decode((String) document.get('data'));
            newVers.PathOnClient = (String) document.get('title')  + '.' + (String) document.get('extension');
            newVers.IsAssetEnabled =  document.containsKey('isAssetEnabled') ? (Boolean) document.get('isAssetEnabled') : false ;
            documents.add(newVers);
        }
        if(!documents.isEmpty()){
            insert documents;
        }
        return documents;       
    }

    public static SObject getContentAsset(String contentDocumentId){
        return new BL_EasyQuery()
            .objectName('ContentAsset')
            .fields(new String[]{'Id', 'IsVisibleByExternalUsers', 'DeveloperName'})
            .condition('ContentDocumentId= \'' + contentDocumentId + '\'')
            .executeQuery()
            .getSObject();
    }

    public static Map<String,Object> getContentVersion(String contentVersionId){
        Map<String,Object> record = new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_CONTENT_VERSION)
            .condition( 'Id = \'' + contentVersionId + '\'')
            .executeQuery()
            .getMappedObject();

        return record;
    }

    public static void createContentDocumentLink( Map<String,Object> document, String recordId){
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = recordId;
        contentLink.ContentDocumentId = (String) document.get('contentDocumentId');
        contentLink.ShareType = 'V';
        
        insert contentLink;
    }
}