public with sharing class STAR_AccountPDFController {

public STAR_AccountPDFController(ApexPages.StandardController controller) {
        Account acc = (Account)controller.getRecord();
       // String accNum = acc.AccountNumber;
        //Assign "Account_[Ac].pdf" as a file name
        String fileName = 'AccountDetail.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);
    }
}