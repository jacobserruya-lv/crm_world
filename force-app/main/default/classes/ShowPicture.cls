/**
* @author Sebastian Munoz
* @createdDate 04/06/2010
* --
* Updated by Romain Mouchel-Vallon to handle generic type of objects
* On 31/05/2016
*/
public with sharing class ShowPicture{

    public  Attachment  file        { set; get; }
    public  Boolean     hasPicture  { set; get; }
    private String      parentId    { set; get; }
    
    public String imageURL{get;set;}
    
    /**
    * Constructor
    */
    public ShowPicture( ApexPages.StandardController stdController ){
        
        imageURL='/servlet/servlet.FileDownload?file=';
        
        this.parentId       = stdController.getId();
        this.hasPicture     = false;
                
        // Begin RMOU
        // List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
        //                                From Attachment 
        //                                where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
        String objName = stdController.getRecord().getSObjectType().getDescribe().getName();
        String attachName = (objName.equals('Account') ? 'Contact' : objName) + ' Picture';
        List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
                                        From Attachment 
                                        where ParentId =: this.parentId and name = :attachName limit 1];
        // End RMOU
        if( attList.size() > 0 ){
            this.file       = attList.get( 0 );
            this.file.Body  = Blob.valueOf('AuxString');
            this.hasPicture = true;
            imageURL=imageURL+attList[0].id;
        }
    }
    
    /**
    * Test method: Environment: no picture uploaded. Then upload one and show it.
    */
    public static testMethod void noPicture(){
        
        Test.startTest();
        
        TestUtilities tu = TestUtilities.generateTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
        ShowPicture cTest = new ShowPicture( sc );     
        System.assert( cTest.file == null, 'ERROR: should not an image  ' );       
        Test.stopTest();
    }
    
    /**
    * Test method: Environment: a picture was uploaded then replace this with other.
    */
    public static testMethod void noPictureAndUploadOne(){
        
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );

        tu.aAttachment.ParentId = sc.getid();
        tu.aAttachment.name = 'Contact Picture';
        insert tu.aAttachment;

        ShowPicture cTest = new ShowPicture( sc );     
        System.assert( cTest.file != null, 'Error no file attached' );     
        System.assert( tu.aAttachment.ParentId == cTest.file.ParentId, 'Error ParentId must be: ' + tu.aAttachment.ParentId );     
        System.assert( tu.aAttachment.name == cTest.file.name, 'Error name must be: ' + tu.aAttachment.name );
        Test.stopTest();
    }

    public static testMethod void pictureAndUploadOther(){
        
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );

        tu.aAttachment.ParentId = sc.getid();
        tu.aAttachment.name = 'Contact Picture';
        insert tu.aAttachment;
        
        //Replace
        tu.aAttachment.Body = Blob.valueOf('String Othe value');
        update tu.aAttachment;
        ShowPicture cTest = new ShowPicture( sc );
          
        System.assert( tu.aAttachment.ParentId == cTest.file.ParentId, 'Error ParentId must be: ' + tu.aAttachment.ParentId );     
        System.assert( tu.aAttachment.name == cTest.file.name, 'Error name must be: ' + tu.aAttachment.name );
        Test.stopTest();
    }
}