@isTest
private class TWIST_PwdlessEmailVerif_CTRL_TEST {
    
    public final static String PWDLESS_EMAIL_VERIFICATION = 'PasswordlessEmailVerification';
    public final static String EMAIL = 'email';
    public final static String IDENTIFIER_ISSUED = 'IDENTIFIER_ISSUED';
         
    @isTest static void test() {
        
        PageReference pageRef;
        TWIST_PwdlessEmailVerif_CTRL ctrl;
        
        Headless_Identity_Flow_Instance__c pwdlessEmailVerifRequest = new Headless_Identity_Flow_Instance__c (
            Flow_Type__c = PWDLESS_EMAIL_VERIFICATION,
            Username__c = 'userName@test.com', 
            Verification_Method__c = EMAIL,
            Status__c = IDENTIFIER_ISSUED,
        	Identifier__c = 'existing',
            Locale__c = 'eng-us'
        );
        insert pwdlessEmailVerifRequest;
        
        
        Test.startTest();
        

            // ERROR - MISSING LOCALE
            pageRef = Page.TWIST_PwdlessEmailVerif;
            pageRef.getParameters().put('identifier','existing');
            pageRef.getParameters().put('redirect-uri','https://eu.louisvuitton.com');
            Test.setCurrentPage(pageRef);
            ctrl = new TWIST_PwdlessEmailVerif_CTRL();
            ctrl.redirect();
            
            // SUCCESS - REDIRECTION
            pageRef = Page.TWIST_PwdlessEmailVerif;
            pageRef.getParameters().put('identifier','existing');
            pageRef.getParameters().put('redirect-uri','https://eu.louisvuitton.com');
        	pageRef.getParameters().put('locale','fra-fr');
            Test.setCurrentPage(pageRef);
            ctrl = new TWIST_PwdlessEmailVerif_CTRL();
            ctrl.redirect();

        Test.stopTest();
    }
    
}