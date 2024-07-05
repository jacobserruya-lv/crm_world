global with sharing class BL_EMAIL_File extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST {
  
    global Object executePOST(){
        Object record = getRequestRecord();
        Map<String, Object> data = (Map<String, Object>) record;
        String recordId = data.containsKey('recordId') ? (String) data.get('recordId') : null;

        List<ContentVersion> contentVersions = BL_EMAIL_File_Helper.createContentVersions(new List<Object>{record}); 
        Map<String,Object> content = new Map<String,Object>();
        String imageUrl;

        if(!contentVersions.isEmpty()){
            Id contentVersionId = contentVersions.get(0)?.Id;
            content = BL_EMAIL_File_Helper.getContentVersion(contentVersions.get(0)?.Id);
                               
            if((Boolean) content.get('isAssetEnabled')) {
                ContentAsset asset = (ContentAsset) BL_EMAIL_File_Helper.getContentAsset((String) content.get('contentDocumentId'));

                if(asset != null){
                    asset.IsVisibleByExternalUsers = true;
                    update asset;

                    imageUrl = String.format('https://{0}/file-asset-public/{1}?oid={2}', 
                                        new string[]{DomainCreator.getContentHostname(), asset.DeveloperName, UserInfo.getOrganizationId()}
                                    );       
                                    
                    content.put('imageUrl', imageUrl);         
                } 
            } else if(String.isNotEmpty(recordId)){

                BL_EMAIL_File_Helper.createContentDocumentLink(content, recordId);
            } 
        }       
        return content;
    }
}