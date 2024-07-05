/** * File Name: STAR_ClientCreateDispatch_TEST
* Description : Test class for STAR_ClientCreateDispatch
* @author : RMOU
* Modification Log =============================================================== 
* 
* */
@isTest
public class STAR_ClientCreateDispatch_TEST {
    // Star user test
    @isTest
    public static void starTest (){        
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        STAR_ClientCreateDispatch extension = new STAR_ClientCreateDispatch(controller);
        
        ID p = IC_Utils.getStarCorporateProfile();
        
        User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
        insert u;
                
        //User u = [SELECT id FROM User WHERE ProfileId=:p AND IsActive=true LIMIT 1]; 

        System.runAs(u){
            System.assertNotEquals(null, extension.dispatch());
        }
    }
    
    // Icon Star user test
    @isTest
    public static void iconStarTest (){        
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        STAR_ClientCreateDispatch extension = new STAR_ClientCreateDispatch(controller);
        
        ID p = IC_Utils.getIconStarCorporateProfile();
                
        User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
        insert u;
       
        
       // User u = [select id from User where ProfileId=:p.id and IsActive=true limit 1]; 

        System.runAs(u){
            System.assertNotEquals(null, extension.dispatch());
        }
    }
    
    // Icon user test
    @isTest
    public static void iconTest (){        
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        STAR_ClientCreateDispatch extension = new STAR_ClientCreateDispatch(controller);
        
        ID p = IC_Utils.getSAProfile();
                
        User u = [SELECT id FROM User WHERE ProfileId=:p AND IsActive=true LIMIT 1]; 

        System.runAs(u){
            System.assertNotEquals(null, extension.dispatch());
        }
    }
    
    // Non-Star user test
    @isTest
    public static void notStarTest (){
        ApexPages.StandardController controller = new ApexPages.StandardController(new Account());
        STAR_ClientCreateDispatch extension = new STAR_ClientCreateDispatch(controller);
        
        ID ps = IC_Utils.getStarCorporatePRofile();
        ID pis = IC_Utils.getIconStarCorporateProfile();
        ID pi = IC_Utils.getSAProfile();
        ID pa = IC_Utils.getSysAdminProfile();
        
        User u = [SELECT id FROM User WHERE ProfileId <> :ps AND ProfileID <> :pis AND ProfileID <> :pi AND ProfileId <> :pa AND IsActive=true LIMIT 1];
        
        System.runAs(u){
            System.assertEquals(null, extension.dispatch());
        }
    }
}