public with sharing class TWIST_i18nPicklist_CTRL {
    
    public Map <String,String> picklistValues {get; set;}
    public static final String PICKLIST_COUNTRIES = 'Countries';

    public void init() {
        List<Schema.PicklistEntry> lstPickListValues;
        picklistValues = new Map<String, String> {};
        if(ApexPages.currentPage().getParameters().get('picklist') == PICKLIST_COUNTRIES){
            lstPickListValues = CountryMapping__mdt.Picklist__c.getDescribe().getPicklistValues();
        }
        if(lstPickListValues != null && !lstPickListValues.isEmpty()){
            for (PicklistEntry entry : lstPickListValues) {
                picklistValues.put(entry.getValue(), entry.getLabel());
            }
        }
    }
}