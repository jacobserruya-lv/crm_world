@istest
private class Global_ClienteEditDispatch_VFCx_TEST{


    public static testMethod void testRedirectICONonly() {
      // test methos for ICON only users. Example is taken on SA user
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientEditDispatch_VFCx extension = new Global_ClientEditDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        
        Profile p = [select id from profile where id=:IC_Utils.getSAProfile()];
        
        
        User u = [select id from User where ProfileId=:p.id and IsActive=true limit 1]; 

        System.runAs(u){
            System.assertEquals(extension.redirectToPage().getUrl() ,'/apex/IC_ClientEditDesktop');
        }
    }            

    public static testMethod void testRedirectSTARonly() {
      // test methos for ICON only users. Example is taken on STAR Corporate user
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientEditDispatch_VFCx extension = new Global_ClientEditDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        
        Profile p = [select id from profile where id=:IC_Utils.getStarCorporateProfile()];
        
        
        User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
        insert u;
       
        
       // User u = [select id from User where ProfileId=:p.id and IsActive=true limit 1]; 

        System.runAs(u){
            System.assertEquals(extension.redirectToPage().getUrl() ,'/apex/STAR_ClientEditDesktop');
        }
    }            

    public static testMethod void testRedirectICONSTAR() {
      // test methos for ICON and STAR users. Example is taken on sysadmin user
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientEditDispatch_VFCx extension = new Global_ClientEditDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        
        Profile p = [select id from profile where id=:Label.IC_System_Admin_Profile_Id];
        
        
        User u = [select id from User where ProfileId=:p.id and IsActive=true limit 1]; 

        System.runAs(u){
            System.assertEquals(extension.redirectToPage().getUrl() ,'/apex/IC_STAR_ClientEditDesktop');
        }
    }            

}