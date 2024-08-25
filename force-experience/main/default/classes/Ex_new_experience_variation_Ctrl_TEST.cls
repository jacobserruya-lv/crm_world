/*	* @author Keman WU
    * @date creation 02/05/2024
    * @description test class for Ex_new_experience_variation_Ctrl
*/
@isTest
public class Ex_new_experience_variation_Ctrl_TEST {
    @isTest static void myTest() {
        Id experienceRTId = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Club_Experience').getRecordTypeId();     	
       
        Store__c store= new Store__c(RetailStoreId__c = 'A06');
		insert store;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Brand_Experience__c experience = new Brand_Experience__c(Name='TEST',recordTypeId = experienceRTId, Experience_StartDate__c =  system.today(),Experience_EndDate__c=  system.today().addDays(2));
        insert experience;
            
        
       
        test.startTest();
        Id experienceId = Ex_new_experience_variation_Ctrl.getExperienceRecord(experience.Id).Id;
        List<Brand_Experience_Variation__c> variationList = new List<Brand_Experience_Variation__c> ();
        Id variaton1RTId = Ex_new_experience_variation_Ctrl.getPhysicalEventRecordTypeID();
        Id variaton2RTId = Ex_new_experience_variation_Ctrl.getContentRecordTypeID();
        Id variaton3RTId = Ex_new_experience_variation_Ctrl.getExclusiveOfferRecordTypeID();
        Id variaton4RTId = Ex_new_experience_variation_Ctrl.getDigitalEventRecordTypeID();
        
        Brand_Experience_Variation__c variation1 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId, Name='TEST variation 1',recordTypeId = variaton1RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);      
        variationList.add(variation1);
        Brand_Experience_Variation__c variation2 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId,Name='TEST variation 2',recordTypeId = variaton2RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);     
        variationList.add(variation2); 
        Brand_Experience_Variation__c variation3 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId,Name='TEST variation 3',recordTypeId = variaton3RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);     
        variationList.add(variation3); 
        Brand_Experience_Variation__c variation4 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId,Name='TEST variation 4',recordTypeId = variaton4RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);     
        variationList.add(variation4);  
        insert  variationList;
        System.assertequals('TEST',Ex_new_experience_variation_Ctrl.getExperienceRecord(experience.Id).Name);
        
        test.stopTest();
    }
}