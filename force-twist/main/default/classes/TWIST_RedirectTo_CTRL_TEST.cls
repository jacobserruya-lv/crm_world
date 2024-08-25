/**
* @File Name          : TWIST_RedirectTo_CTRL_TEST
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 15-12-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       15-12-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
@isTest
private class TWIST_RedirectTo_CTRL_TEST {
    
    @isTest 
    static void test_RedirectToController() {   
        PageReference pageRef = Page.TWIST_RedirectTo; 
        pageRef.getParameters().put('partialURL','myURL');
        Test.setCurrentPage(pageRef); 
        Test.startTest();
        TWIST_RedirectTo_CTRL redirectCtrl = new TWIST_RedirectTo_CTRL();
        redirectCtrl.redirect();
        Test.stopTest();
    }
}