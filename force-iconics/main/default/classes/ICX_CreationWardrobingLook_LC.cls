public class ICX_CreationWardrobingLook_LC {
   
    @AuraEnabled 
    public static string getRecords(Id RecordId){
        string Gender='';
        string is10K= '';
        string DreamId= '';
        string masterSku= '';
        
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        System.debug(sObjName);
        if(sObjName == 'Account'){
           Account myAccount = [select id, DREAMID__c,Ind_10K__c,Gender__pc from Account where id=: RecordId] ;
           is10K = myAccount.Ind_10K__c;
           Gender = myAccount.Gender__pc;
           DreamId = myAccount.DREAMID__c;
        }else if(sObjName == 'PPR_PurchProduct__c')
        {
            PPR_PurchProduct__c myPurchProduct =[select id,sku__c,RMSSKUCode__c,Client__r.DREAMID__c, Client__r.Ind_10K__c,Client__r.Gender__pc from  PPR_PurchProduct__c where id=: RecordId];
            is10K= myPurchProduct.Client__r.Ind_10K__c;
            Gender= myPurchProduct.Client__r.Gender__pc;
            DreamId = myPurchProduct.Client__r.DREAMID__c; 
            masterSku = myPurchProduct.RMSSKUCode__c;
        }
	    return  valueToUrl(DreamId,Gender,is10K,masterSku);
    }
    
    
    public static string valueToUrl(String mydreamId,String mygender,String myis10k,String mymasterSku){
            string gender,is10k;
            if(mygender == 'Female'){
                gender = '1';  
            }else if(mygender == 'Male'){
                gender = '2';  
            }else{
                gender ='0'; 
            }
            if(myis10k != 'None'){
                is10k = 'true';
            }else{
                is10k = 'false';
            }
        string url = '?dreamId=' + mydreamId +
                      '&gender=' + gender + 
                      '&is10k='+ is10k +
                      '&masterSku='+ mymasterSku;
        return url;
        }
    
    
}