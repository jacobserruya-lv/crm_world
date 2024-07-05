public class ICX_RequestPaymentCtrl {
    @AuraEnabled (Cacheable=false)  
    public static void requestPayment(Id careServiceId ) {
        CareService__c care = [select id,StoreRetailCode__c,TotalAmount_Updated__c,ICONiCS_Status_Detail__c,Last_ICONiCS_Status_Changed_Date__c,Confirm_Address_Send_Date__c,MyRepairStatus__c,Last_MyRepair_Status_Changed_Date__c,MYLV_Care_Status__c,Last_MYLV_Care_Status_Changed_Date__c from CareService__c where id=:careServiceId];
        ICX_Repair_Store__mdt repairCountry = ICX_Repair_Store__mdt.getInstance(String.valueOf(care.StoreRetailCode__c));
        
        //Integrated PBL
        if(repairCountry.Integrated_PBL__c==true){ 
            //Free of charge           
            if(care.TotalAmount_Updated__c==0){
                care.ICONiCS_Status_Detail__c = 'Confirm Address';
                care.MYLV_Care_Status__c = 'confirm_address';
                care.MyRepairStatus__c = 'receivedAndAcceptedInStore';
                care.Last_ICONiCS_Status_Changed_Date__c = system.today();
                care.Last_MYLV_Care_Status_Changed_Date__c = system.today();
                care.Last_MyRepair_Status_Changed_Date__c = system.today();
                care.Confirm_Address_Send_Date__c = system.now();
            }else{
                //PBL Adyen
                care.ICONiCS_Status_Detail__c = 'Waiting for Payment';
                care.MYLV_Care_Status__c = 'awaiting_payment';
                care.MyRepairStatus__c = 'receivedAndAcceptedInStore';
                care.Last_ICONiCS_Status_Changed_Date__c = system.today();
                care.Last_MYLV_Care_Status_Changed_Date__c = system.today();
                care.Last_MyRepair_Status_Changed_Date__c = system.today();
            }
           //Manual PBL
        }else{          
           
                care.ICONiCS_Status_Detail__c = 'Payment Review';
                care.MYLV_Care_Status__c = 'payment_contact';
                care.MyRepairStatus__c = 'receivedAndAcceptedInStore';
                care.Last_ICONiCS_Status_Changed_Date__c = system.today();
                care.Last_MYLV_Care_Status_Changed_Date__c = system.today();
                care.Last_MyRepair_Status_Changed_Date__c = system.today();
           
        }
        
        Update care;
    }    
       
 
}