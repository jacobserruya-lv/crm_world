/** * File Name: FileUploadController
* Description : Handles picture uploading for any SObject Type
* @author : RMOU
* Modification Log =============================================================== 
* 
* */
public with sharing class FileUploadController {
    // Object Name
    private String objectType;
    // Record ID
    private ID id;
    
    // Constructor
    public FileUploadController (){
        // Get record ID
        id = ApexPages.currentPage().getParameters().get('id');
        // Get record's Object Type
        Schema.SObjectType token = id.getSobjectType();
        // Get Object's Name
        Schema.DescribeSObjectResult dr = token.getDescribe();
        objectType = dr.getName();
    }
    
    public String getObjectType (){
        return objectType;
    }
    
    public ID getId (){
        return id;
    }
}