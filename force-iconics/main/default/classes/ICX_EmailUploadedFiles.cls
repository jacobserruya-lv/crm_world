public with sharing class ICX_EmailUploadedFiles {
    @AuraEnabled
    public static boolean deleteAttachments(Id attachId){
        
        if(attachId != NULL){
            ContentDocument file = [Select Id from ContentDocument where Id = :attachId];
            delete file;
            return true;
        }
        else{
            return false;
        }
    }
 
}