public class ICX_ReceiptCareServiceCtl {
     private final CareService__c care;
     List<CareServiceLineItem__c> quotations;
     String upperCaseRepairNumber;
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public ICX_ReceiptCareServiceCtl(ApexPages.StandardController stdController) {
        this.care = (CareService__c)stdController.getRecord();
    }

 public List<CareServiceLineItem__c> getQuotations() {
       
            quotations = [SELECT Quantity__c, InstructionCode__c, Instruction_Name_ICONiCS__c FROM CareServiceLineItem__c where CareService__c=:care.id ];
        return quotations;
    }
     public String getUppercaseRepairNumber() {       
            upperCaseRepairNumber=  care.transactionId__c.toUpperCase();
        return upperCaseRepairNumber;
    }
}