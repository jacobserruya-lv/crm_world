public class SO_QuotationContainer {
    
	public SO_QuotationContainer() { }
        
	public Opportunity oneOpportunity 	{get; set;} 
	public String opportunityOrderType	{get; set;}
    
    public SO_UTIL.PickListWrapper productCategory	 { 

		get {
			if(null == productCategory) {
				productCategory = new SO_UTIL.PickListWrapper('Opportunity', 'SPO_ProductCategory__c', null,oneOpportunity);
			}
			return productCategory;
		} 
		set; 
	}
    
    public SO_UTIL.PickListWrapper orderType {
        
        get {
			if(null == orderType) {
				orderType = new SO_UTIL.PickListWrapper('Opportunity', 'SPO_OrderType__c', null,oneOpportunity);
			}
			return orderType;
		} 
		set; 
    }

    public List<Attachment> attachmentList { get; set; }

    public Map<String,String> colorNameToCodeMap { get; set; }
}