public with sharing class IC_ClientEditDesktop_VFCx {


    public String clientName{get;set;}
    private ApexPages.StandardController stdController;
    public Account client{get;set;}
    private User currentUser;
    private Boolean isNew;
    public List<SelectOption> salutationOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add (new SelectOption ('', '--None--'));
            for (Schema.PicklistEntry p : Account.salutation.getDescribe().getPicklistValues())
            {
                options.add (new SelectOption (p.getValue(), p.getLabel()));
            }

            return options;
        }
    }
    //public Boolean isPersonAccount{get;set;}
    //public Boolean isStarAccount{get;set;}
    //public Boolean isInStarApp{get;set;}

    public IC_ClientEditDesktop_VFCx(ApexPages.StandardController standardController)
    {
        stdController = standardController;
        client = (Account)standardController.getRecord();

        if (client.id != null)
        {
            isNew = false;
            this.client = [Select 
                        //Client Information
                        DreamId__c, owner.name,FirstName, DreamSA__pc,LastName, Segmentation__pc,PersonBirthdate,Occupation__pc,Nationality__pc,
                        Company__pc,Typology__pc, PreferredContactChannel__pc, AttachedStore__pc, PassportNumber__pc, Title__pc,
                        // Address Information
                        PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc,PrimaryCity__pc,PrimaryZipCode__pc,PrimaryStateProvince__pc, PrimaryCountry__pc,
                        // Contact Information
                        PersonDoNotCall,DoNotSMS__pc,PersonHomePhone,PersonMobilePhone,Phone,PersonEmail,PersonHasOptedOutOfEmail,DoNotContactbyPost__pc, PreferredLanguage__pc, Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, Can_Be_Contacted_By_Email__pc, Can_Be_Contacted_By_Mail__pc,Invited__pc,
                        //Size informaiton
                        Gender__pc, Belt__pc, Jacket__pc,Shoes__pc, Dress__pc, Ring__pc, Knit__pc, Pant__pc, Shirt__pc, Skirt__pc, Suit__pc,
                        //Accessories Purchase History
                        YTDAccessoriesSpendYUAN__pc, HistoricalAccessoriesNbrProducts__pc, YTDAccessoriesSpendYEN__pc,HistoricalAccessoriesSpendEUR__pc,YTDAccessoriesSpendUSD__pc,HistoricalAccessoriesSpendUSD__pc,
                        YTDAccessoriesSpendEUR__pc, HistoricalAccessoriesSpendYEN__pc,YTDAccessoriesNbrProducts__pc, HistoricalAccessoriesSpendYUAN__pc,
                        //Jewelry Purchase History
                        YTDJewelryNbrProducts__pc, HistoricalJewelryNbrProducts__pc, YTDJewelrySpendEUR__pc, HistoricalJewelrySpendEUR__pc, YTDJewelrySpendUSD__pc, HistoricalJewelrySpendUSD__pc,
                        YTDJewelrySpendYEN__pc, HistoricalJewelrySpendYEN__pc, YTDJewelrySpendYUAN__pc, HistoricalJewelrySpendYUAN__pc,
                        //Leather Purchase History
                        YTDLeatherGoodSpendYUAN__pc, HistoricalLeatherGoodSpendYUAN__pc, YTDLeatherGoodSpendYEN__pc, HistoricalLeatherGoodNbrProducts__pc,YTDLeatherGoodSpendUSD__pc,
                        HistoricalLeatherGoodSpendEUR__pc, YTDLeatherGoodSpendEUR__pc, HistoricalLeatherGoodSpendUSD__pc, YTDLeatherGoodNbrProducts__pc, HistoricalLeatherGoodSpendYEN__pc,
                        //Wear Purchase History
                        YTDReadyToWearSpendYUAN__pc,HistoricalReadyToWearNbrProducts__pc,YTDReadyToWearNbrProducts__pc, HistoricalReadyToWearSpendEUR__pc, YTDReadyToWearSpendEUR__pc,
                        HistoricalReadyToWearSpendUSD__pc, YTDReadyToWearSpendUSD__pc, HistoricalReadyToWearSpendYEN__pc, YTDReadyToWearSpendYEN__pc, HistoricalReadyToWearSpendYUAN__pc,
                        //Shoes Purchase History
                        YTDShoesNbrProducts__pc, HistoricalShoesNbrProducts__pc, YTDShoesSpendEUR__pc, HistoricalShoesSpendEUR__pc,YTDShoesSpendUSD__pc, HistoricalShoesSpendUSD__pc,
                        YTDShoesSpendYEN__pc, HistoricalShoesSpendYEN__pc, YTDShoesSpendYUAN__pc, HistoricalShoesSpendYUAN__pc,
                        //Watch Purchase History
                        HistoricalWatchNbrProducts__pc, YTDWatchNbrProducts__pc, HistoricalWatchSpendEUR__pc, YTDWatchSpendEUR__pc, HistoricalWatchSpendYUAN__pc, YTDWatchSpendUSD__pc,
                        HistoricalWatchSpendYEN__pc, YTDWatchSpendYEN__pc,HistoricalWatchSpendUSD__pc, YTDWatchSpendYUAN__pc,
                        //Perfume Purchase History
                        HistoricalPerfumeNbrProducts__pc, YTDPerfumeNbrProducts__pc, HistoricalPerfumeSpendEUR__pc, YTDPerfumeSpendEUR__pc, HistoricalPerfumeSpendYUAN__pc, YTDPerfumeSpendUSD__pc,
                        HistoricalPerfumeSpendYEN__pc, YTDPerfumeSpendYEN__pc,HistoricalPerfumeSpendUSD__pc, YTDPerfumeSpendYUAN__pc,
                        //Purchase History
                        LastTrans__pc, FirstTrans__pc, YTDSpendEUR__pc, HistoricalSpendEUR__pc,YTDSpendUSD__pc, HistoricalSpendUSD__pc, YTDSpendYUAN__pc, HistoricalSpendYUAN__pc,
                        YTDSpendYEN__pc, HistoricalSpendYEN__pc, YTDNbrProducts__pc, HistoricalNbrProducts__pc,
                        //Lifestyle & Family
                        Spouse__pc,  PersonalInterest1__pc, AnniversaryDay__pc, PersonalInterest2__pc, AnniversaryMonth__pc, PersonalInterest3__pc, Children__pc, FoodPreferences__pc,
                        Pets__pc, BeveragePreferences__pc, ShopsFor__pc, PersonAssistantName, PersonAssistantPhone, Anniversary__pc, AnniversaryYear__pc,
                        // LV Interests
                        AccessoriesInterest__pc, JewelleryInterest__pc, LeatherGoodsInterest__pc, RTWInterest__pc, ShoesInterest__pc, WatchesInterest__pc, PerfumesInterest__pc, OtherInterest__pc,
                        ServiceInterest__pc, EventInterest__pc,
                        // Last 36 Month Fields
                        Last36MNbrProducts__pc, Last36MAccessoriesNbrProducts__pc, Last36MAccessoriesSpendEUR__pc, Last36MAccessoriesSpendUSD__pc, Last36MAccessoriesSpendYEN__pc, Last36MAccessoriesSpendYUAN__pc, Last36MJewelryNbrProducts__pc, Last36MJewelrySpendEUR__pc, Last36MJewelrySpendUSD__pc, Last36MJewelrySpendYEN__pc, Last36MJewelrySpendYUAN__pc, Last36MLeatherGoodNbrProducts__pc, Last36MLeatherGoodSpendEUR__pc, Last36MLeatherGoodSpendUSD__pc, Last36MLeatherGoodSpendYEN__pc, Last36MLeatherGoodSpendYUAN__pc, Last36MReadyToWearNbrProducts__pc, Last36MReadyToWearSpendEUR__pc, Last36MReadyToWearSpendUSD__pc, Last36MReadyToWearSpendYEN__pc, Last36MReadyToWearSpendYUAN__pc, Last36MShoesNbrProducts__pc, Last36MShoesSpendEUR__pc, Last36MShoesSpendUSD__pc, Last36MShoesSpendYEN__pc, Last36MShoesSpendYUAN__pc, Last36MSpendEUR__pc, Last36MSpendUSD__pc, Last36MSpendYEN__pc, Last36MSpendYUAN__pc, Last36MWatchNbrProducts__pc, Last36MWatchSpendEUR__pc, Last36MWatchSpendUSD__pc, Last36MWatchSpendYEN__pc, Last36MWatchSpendYUAN__pc,
                        // System Information
                        TECH_DreamIdSA__pc, IsDream__c, TECH_ManualReassignmentDate__c, TECH_OwnerManuallyChanged__c,  ToDelete__c, DreamIdMasterClient__c,
                        // Other
                        LastModifierStoreCountry__pc,isPersonAccount,FlowerFlagIcon__pc,Name,
                        //Client OInformation STAR
                        account.salutation,
                        // STAR Dietary Requirements
                        Star_Allergy__pc, Star_AllergyDetails__pc,Star_Beveragepreferences__pc, Star_FoodPreferences__pc, Star_DetailsDietaryReq__pc, Star_ContactPrefDetails__pc, Star_LVInterestsDetails__pc, Star_CommentPhotoBook__pc,
                        // STAR Lifestyle / LV Interest
                        BirthdateDay__pc, BirthdateMonth__pc, BirthdateYear__pc,
                        // STAR Contact
                        HomePhoneCountrycode__pc
                        From Account
                        Where Id = :client.Id] ;
             Account tempClient = [SELECT Name, Salutation,isPersonAccount  from Account where Id = :client.Id];
             clientName = translateClientName(tempClient.Salutation)+' '+tempClient.Name;
         }
         else
        {
            System.debug ('## New Client');
            isNew = true;
            RecordType recType = [SELECT id FROM RecordType WHERE DeveloperName='ACC_PersonAccount' AND SObjectType='Account' limit 1];
            client = new Account(RecordTypeId=recType.id, Ownerid=UserInfo.getUserid());
        }

        // Retrieve the current user information to check LV Interest, Lifestyle and Size information visibility
        currentUser  = [SELECT Id, country__c,profileId FROM USER WHERE Id = :UserInfo.getUserId() limit 1];

            if(!IC_Factory.isAdmin() && IC_Factory.isPIPACountry(client.LastModifierStoreCountry__pc) && IC_Factory.getPIPACountryCode(currentUser.Country__c) != client.LastModifierStoreCountry__pc)
            {
                client.PreferredContactChannel__pc = null;

                // Size Information
                client.Jacket__pc = null;
                client.Dress__pc = null;
                client.Knit__pc = null;
                client.Pant__pc = null;
                client.Shirt__pc = null;
                client.Skirt__pc = null;
                client.Suit__pc = null;
                client.Belt__pc = null;
                client.Shoes__pc = null;
                client.Ring__pc = null;

                // Lifestyle & Family
                client.Spouse__pc = null;
                client.AnniversaryMonth__pc = null;
                client.AnniversaryYear__pc = null;
                client.AnniversaryDay__pc = null;
                client.Children__pc = null;
                client.Pets__pc = null;
                client.ShopsFor__pc = null;
                client.PersonalInterest1__pc = null;
                client.PersonalInterest2__pc = null;
                client.PersonalInterest3__pc = null;
                client.FoodPreferences__pc = null;
                client.BeveragePreferences__pc = null;
                client.PersonAssistantName = null;
                client.PersonAssistantPhone = null;

                //LV Interests
                client.AccessoriesInterest__pc = null;
                client.JewelleryInterest__pc = null;
                client.LeatherGoodsInterest__pc = null;
                client.RTWInterest__pc = null;
                client.ShoesInterest__pc = null;
                client.WatchesInterest__pc = null;
                client.PerfumesInterest__pc = null;
                client.OtherInterest__pc = null;
                client.ServiceInterest__pc = null;
                client.EventInterest__pc = null;
            }

        //isPersonAccount = (this.client.RecordTypeId == IC_UTILS.getPersonAccountRT());
        //isStarAccount = (this.client.RecordTypeId == IC_UTILS.getStarAccountRT());

        //system.debug('####### isPersonAccount :' +isPersonAccount);
        //system.debug('####### isStarAccount :' +isStarAccount);

        //isInStarApp = IC_UTILS.inStarApp();
        //system.debug('##### isInStarApp:' +isInStarApp);
    }

    /**
    * Check changes on Account when edited by non PIPA user last modified by a PIPA user.
    **/
    private Boolean areFieldsChanged() {
        return
            client.PreferredContactChannel__pc != null ||
            // Size Information
            client.Jacket__pc != null ||
            client.Dress__pc != null ||
            client.Knit__pc != null ||
            client.Pant__pc != null ||
            client.Shirt__pc != null ||
            client.Skirt__pc != null ||
            client.Suit__pc != null ||
            client.Belt__pc != null ||
            client.Shoes__pc != null ||
            client.Ring__pc != null ||
            // Lifestyle & Family
            client.Spouse__pc != null ||
            client.AnniversaryYear__pc != null ||
            client.AnniversaryMonth__pc != null ||
            client.AnniversaryDay__pc != null ||
            client.Children__pc != null ||
            client.Pets__pc != null ||
            client.ShopsFor__pc != null ||
            client.PersonalInterest1__pc != null ||
            client.PersonalInterest2__pc != null ||
            client.PersonalInterest3__pc != null ||
            client.FoodPreferences__pc != null ||
            client.BeveragePreferences__pc != null ||
            client.PersonAssistantName != null ||
            client.PersonAssistantPhone != null ||
            //LV Interests
            client.AccessoriesInterest__pc != null ||
            client.JewelleryInterest__pc != null ||
            client.LeatherGoodsInterest__pc != null ||
            client.RTWInterest__pc != null ||
            client.ShoesInterest__pc != null ||
            client.WatchesInterest__pc != null ||
            client.PerfumesInterest__pc != null ||
            client.OtherInterest__pc != null ||
            client.ServiceInterest__pc != null ||
            client.EventInterest__pc != null;
    }

    /**
    * save changes for new or edit task.
    **/
    public PageReference saveClient() {

            if(areFieldsChanged())
            {
                try{
                    System.debug('Fields changed');
                    if (isNew)
                        insert client;
                    else
                        update client;
                }catch(DMLException ex){
                    System.debug('XXX>'+ex.getMessage());
                }
            }

        else // The client was last modified out of PIPA
        {
            try{
                if (isNew)
                    insert client;
                else
                    update client;
            }catch(DMLException ex){
                System.debug('XXX>'+ex.getMessage());
            }
        }
        if (ApexPages.hasMessages())
        {
            return null;
        }
        else
            return (new Pagereference('/'+client.Id));
    }

    public static String translateClientName(String clientNameCode){
        String clientNameLabel = '';
        list<Schema.PicklistEntry> ctrPLV =  IC_UTILS.getFieldDescribe('Contact', 'Salutation').getPicklistValues();
        for(Schema.PicklistEntry plv : ctrPLV){
            if(plv.getValue() == clientNameCode){
                clientNameLabel = plv.getLabel();
                return clientNameLabel;
            }
        }
        return clientNameLabel;
    }

}