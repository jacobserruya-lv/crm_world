/**

 */
@isTest
private class STAR_ProgramView_VFCx_TEST {

    static testMethod void DisplayProgramAndRelatedList() {
        
        Event__c evt;
        Program__c prg;
        Gift__c gft;
        Hotel__c htl;
        Experience__c exp;
        Restaurant__c rest;
        Transport__c trp;
        
        //Create new Account
        Account account = IC_TestFactory.createAccount();
        insert account;
        
               
        //Create new STAR Event ('Event__c' Object ). It will be used when STAR Program is created
        evt = new Event__c();
        evt.Name='EventTest';
        evt.Start_Date__c =Date.today();
        evt.End_Date__c =Date.today();      
        evt.Location__c='PariSelecs';
        evt.Level__c='International';
        evt.Theme__c='Art & Culture';
        evt.Type__c='Exhibition';
        
        insert evt;
        
        //Create new Program
        prg = New Program__c();
        prg.name='ProgramTest';
        prg.AccountId__c = account.Id;
        prg.EventId__c = evt.id;
        //prgView.IdProgram= prg.id; 
        insert prg;
        
        //Create Gift related to the Program [ProgramTest]
        gft = new Gift__c();
        //gft.Name='GiftTest';
        gft.Gift_Name__c='Wine';
        gft.ProgramId__c=prg.id;
        
        insert gft;
        
                
        //Create Experience Related to the program [ProgramTest]
        exp = new Experience__c();
        exp.Experience_Name__c='Other';
        exp.ProgramId__c=prg.id;
        
        insert exp;
        
        // Create Hotel Related to the program [ProgramTest]
        htl = new Hotel__c();
        htl.HotelName__c='HotelTest';
        htl.ProgramId__c=prg.id;
        htl.Location__c='Paris';
        htl.To__c=Date.today();
        htl.From__c=Date.today();
        
        insert htl;
        
        
        // Create Restaurant Related to the program [ProgramTest]
         rest = new Restaurant__c();
         rest.Restaurant_Name__c='RestaurantTest';
         rest.ProgramId__c=prg.id;
         rest.Booking_Date_Time__c=DateTime.newInstance(1993, 6, 6, 3, 3, 3);
        
        insert rest;
        
        // Create Transport Related to the program [ProgramTest]
         trp = new Transport__c();
         trp.ProgramId__c=prg.id;
         trp.Type__c='VTC';
        
        insert trp;
        
        Test.setCurrentPageReference(new PageReference('/apex/STAR_ProgramViewXls'));
        System.currentPageReference().getParameters().put('id', prg.Id);

        STAR_ProgramView_VFCx prgView = new STAR_ProgramView_VFCx();
     
        STAR_ProgramView_VFCx.getLocale();
        STAR_ProgramView_VFCx.getLang();
        
        List<Gift__c> giftLists = prgView.getGiftProg();
        system.debug('giftLists :' +giftLists.size());
        //System.assertequals(giftLists.size(), 3); 
        
        List<Experience__c> experienceLists = prgView.getExperienceProg();
        //System.assertequals(experienceLists.size(), 1);
        
        List<Hotel__c> hotelLists = prgView.getHotelProg();
        system.debug('hotelLists :' +hotelLists.size());
        //System.assertequals(hotelLists.size(), 1);
        
        List<Restaurant__c> restaurantLists = prgView.getRestaurantProg();
        //System.assertequals(restaurantLists.size(), 1); 
        
        List<Transport__c> transportLists = prgView.getTransportProg();
        //System.assertequals(transportLists.size(), 1);  
        
    }
}