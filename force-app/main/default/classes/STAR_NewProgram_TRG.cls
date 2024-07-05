/*** File Name: STAR_NewProgram_TRG
* Description : Class called in triggers
* @author : UNKNOWN
* Modification Log =============================================================== 
	MTOU 13/06/2016 new method named "UpdateClients"
	MTOU 21/06/2016 filtering by program record type id

***/

public with sharing class STAR_NewProgram_TRG {
    
        public static void NewProgam (List<Program__c>  newValues){
            
            System.debug('### newValues :' +newValues.size());
    		Id TemplateRecTypeID = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Template Program').getRecordTypeId();
            
            if (!IC_UTILS.empty (newValues)) {
                
                System.debug('### newValues :' +newValues.size());
                List<Gift__c> gifts = new List<Gift__c>();
                
                for (Program__c p : newValues) {
                    // create default gifts only for Template programs
                    if(p.RecordTypeId == TemplateRecTypeID)
                    {
                         Gift__c firstGift = new Gift__c ();
                         firstGift.Gift_Name__c='Néo Nano Fuschia';
                         firstGift.Welcome_Package__c=true;  
                         firstGift.ProgramId__c = p.Id; 
                         
                         Gift__c secondGift = new Gift__c ();
                         secondGift.Gift_Name__c='Pochette Jour Taiga Grizzli';
                         secondGift.Welcome_Package__c=true;  
                         secondGift.ProgramId__c = p.Id;    
                         
                         Gift__c thirdGift = new Gift__c ();
                         thirdGift.Gift_Name__c='Dom Pérignon P2';
                         thirdGift.Welcome_Package__c=true;  
                         thirdGift.ProgramId__c = p.Id; 
                         
                          Gift__c forthGift = new Gift__c ();
                         forthGift.Gift_Name__c='Leather Envelope';
                         forthGift.Welcome_Package__c=true;  
                         forthGift.ProgramId__c = p.Id; 
                         
                          Gift__c fifthGift = new Gift__c ();
                         fifthGift.Gift_Name__c='Guerlain Sunscreen';
                         fifthGift.Welcome_Package__c=true;  
                         fifthGift.ProgramId__c = p.Id;    
                         
                          Gift__c sixthGift = new Gift__c ();
                         sixthGift.Gift_Name__c='Guerlain Cosmetics';
                         sixthGift.Welcome_Package__c=true;  
                         sixthGift.ProgramId__c = p.Id; 
                         
                         gifts.add(firstGift);
                         gifts.add(secondGift); 
                         gifts.add(thirdGift); 
                         gifts.add(forthGift); 
                         gifts.add(fifthGift); 
                         gifts.add(sixthGift); 
                         
                         System.debug('### gifts :' +gifts.size());
                	}  
                }          
                insert gifts;    
            }   


    }
    
    	
    // 
     
     /*** 	
     * <p>
     * This method is used to update client's information after a program creation/update 
     * For all attached clients, update their "invited" field after a program creation
     * @param  pList: list of program to be created
     * @return void
     */    		 
    public static void UpdateClients (List<Program__c>  pList)
    {   
        List<id> accountIdList = new List<id>();
        List<Account> accToUpdate = new list<Account>();
        for (Program__c prog : pList)
        {
            accountIdList.add(prog.AccountId__c);
        } 
        // get attached clients from programs
        List<Account> accountsList = [SELECT id, Invited__pc from Account where Id in: accountIdList];  
        // for all attached clients, set to true their "invited" field
        for(Account acc: accountsList)
        {
            acc.Invited__pc=true; 
            accToUpdate.add(acc);
        }
        // update clients if they exist
        if(accToUpdate.size() > 0)
        {
            update accToUpdate;
        }
    } 
    	
}