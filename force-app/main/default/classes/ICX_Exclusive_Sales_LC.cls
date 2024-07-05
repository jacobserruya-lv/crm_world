public class ICX_Exclusive_Sales_LC {
    
    @Auraenabled
    public static List<Exclusive_Experience__c>  getExculisveSales(Id recordId){
        Map<string,boolean> options = new Map<string,boolean>();
        List<Exclusive_Experience__c> ExclusiveExperienceList =  new List<Exclusive_Experience__c>();
        List<Schema.PicklistEntry>  fieldResult = Exclusive_Experience__c.Offer_Code__c.getDescribe().getPicklistValues();
        
        for( Schema.PicklistEntry f : fieldResult ){
             options.put(f.getLabel(),f.isActive());
        }
        for(Exclusive_Experience__c exxr : [select Id , Name, Offer_Code__c ,Mylv_Url_Short__c from Exclusive_Experience__c where Account_Id__c =: recordId] ){

            if(options.get(exxr.Offer_Code__c) == true){
                ExclusiveExperienceList.add(exxr);
            }
        }
        return ExclusiveExperienceList;
    }
    
}