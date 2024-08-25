/**
* Class used to serialize a single Lookup search result item
* The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
* https://github.com/pozil/sfdc-ui-lookup/blob/master/src/main/default/classes/LookupSearchResult.cls
* https://developer.salesforce.com/blogs/2018/07/10-tips-for-implementing-an-efficient-lightning-lookup-component.html
*/
public class ICX_ProductLookupSearchResult {
    
    private Id id;
    private String sObjectType;
    private String icon;
    private Boolean isIconUrl; // icon or image
    private String title;
    private String subtitle;
    //private Boolean readOnly;
    private Id relatedId;
    private String relatedName;
    private ICX_ProductEnquired__c qualification;

    // use to create a new record whereas the record is already related to a record (ex: Product in a Task then this product can be reused for a New Request based on the Task)
	@AuraEnabled
    public Boolean cloneForRequestCreation {get; set;}
    
    public ICX_ProductLookupSearchResult(Id id, String sObjectType, String icon, Boolean isIconUrl, String title, String subtitle, Boolean readOnly, ICX_ProductEnquired__c qualification) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.isIconUrl = isIconUrl;
        this.title = title;
        this.subtitle = subtitle;
        // this.readOnly = readOnly;
        this.qualification = qualification;
    }
    public ICX_ProductLookupSearchResult(Id id, String sObjectType, String icon, Boolean isIconUrl, String title, String subtitle, Id relatedId, String relatedName, ICX_ProductEnquired__c qualification) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.isIconUrl = isIconUrl;
        this.title = title;
        this.subtitle = subtitle;
        this.relatedId = relatedId;
        this.relatedName = relatedName;
        this.qualification = qualification;
    }
    @AuraEnabled
    public Id getId() {
        return id;
    }
    
    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }
    
    @AuraEnabled
    public String getIcon() {
        return icon;
    }
    
    @AuraEnabled
    public String getTitle() {
        return title;
    }
    
    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }
    
    @AuraEnabled
    public Boolean getIsIconUrl() {
        return isIconUrl;
    }
    
    /*@AuraEnabled
public Boolean getReadOnly() {
return readOnly;
}*/
    
    @AuraEnabled
    public Id getRelatedId() {
        return relatedId;
    }
    
    @AuraEnabled
    public String getRelatedName() {
        return relatedName;
    }

    @AuraEnabled
    public ICX_ProductEnquired__c getQualification() {
        return qualification;
    }

}