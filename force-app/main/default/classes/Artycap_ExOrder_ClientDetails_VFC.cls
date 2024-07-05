global without sharing class Artycap_ExOrder_ClientDetails_VFC {
	private Exclusive_Campaign_Order__c selectedOrder;
    private Account selectedAccount;
    global Account accDetails {get; set;}
    private User currentUser;

   /**
     * Default user currency
    **/
    global static String getDefaultUserCurrency(){
        return IC_UTILS.getDefaultUserCurrency();
    }

    public Artycap_ExOrder_ClientDetails_VFC(ApexPages.StandardController controller) {
        
        this.selectedOrder = (Exclusive_Campaign_Order__c) controller.getRecord();
    }

    global Artycap_ExOrder_ClientDetails_VFC() {
        String OrderId = ApexPages.currentPage().getParameters().get('id');
        Exclusive_Campaign_Order__c currentOrder = [Select id, Client__c from Exclusive_Campaign_Order__c where id = :OrderId];
        List<Account> accDetailsList = [Select PerfumesInterest__pc, AccessoriesInterest__pc, Can_Be_Contacted_By_Mail__pc, JewelleryInterest__pc, LeatherGoodsInterest__pc, OtherInterest__pc, RTWInterest__pc, ShoesInterest__pc, WatchesInterest__pc,
                     Name, owner.name, TECH_OwnerManuallyChanged__c, PersonalInterest1__pc, PersonalInterest2__pc, PersonalInterest3__pc, ServiceInterest__pc, EventInterest__pc, ProductInterest__pc,
                    PersonAssistantName, PersonAssistantPhone, Spouse__pc,  Children__pc, Pets__pc,ShopsFor__pc, FoodPreferences__pc, BeveragePreferences__pc,
                    ownerId, Phone,  Can_Be_Contacted_By_SMS__pc,  PrimaryZipCode__pc,AnniversaryDay__pc, AnniversaryMonth__pc, AnniversaryYear__pc, Title__pc,
                    (Select Id from Client_List_Members__pr where  ClientList__r.ownerId = :UserInfo.getUserId() Limit 1),
                    Typology__pc, Segmentation__pc, PrimaryStateProvince__pc, PrimaryCountry__pc, PrimaryCity__pc, PrimaryAddressLine3__pc, PrimaryAddressLine2__pc, PrimaryAddressLine1__pc,
                    PreferredContactChannel__pc, PassportNumber__pc, Occupation__pc, Nationality__pc, LastName, Id, Gender__pc, FlowerFlag__pc, FlowerFlagIcon__pc, FirstName, Company__pc, BirthdateYear__pc, BirthdateMonth__pc,
                    BirthdateDay__pc, AttachedStore__pc, Jacket__pc, Pant__pc, Shirt__pc, Shoes__pc, Ring__pc, Knit__pc, Dress__pc, Skirt__pc, Suit__pc, Belt__pc, PersonDoNotCall,
                    PersonHomePhone, PersonMobilePhone, PersonEmail, Can_Be_Contacted_By_Email__pc,
                    FirstTrans__pc, LastTrans__pc, HistoricalAccessoriesNbrProducts__pc, HistoricalAccessoriesSpendUSD__pc, HistoricalPerfumeNbrProducts__pc, HistoricalPerfumeSpendUSD__pc, HistoricalJewelryNbrProducts__pc, HistoricalJewelrySpendUSD__pc, HistoricalLeatherGoodNbrProducts__pc,
                    HistoricalLeatherGoodSpendUSD__pc, HistoricalReadyToWearSpendUSD__pc, HistoricalShoesNbrProducts__pc, HistoricalShoesSpendUSD__pc, HistoricalWatchNbrProducts__pc, HistoricalWatchSpendUSD__pc,
                    YTDAccessoriesNbrProducts__pc, YTDAccessoriesSpendUSD__pc, YTDPerfumeNbrProducts__pc, YTDPerfumeSpendUSD__pc, YTDJewelryNbrProducts__pc, YTDJewelrySpendUSD__pc, YTDLeatherGoodNbrProducts__pc, YTDLeatherGoodSpendUSD__pc, YTDReadyToWearNbrProducts__pc, YTDReadyToWearSpendUSD__pc,
                    YTDShoesNbrProducts__pc, YTDShoesSpendUSD__pc, YTDWatchNbrProducts__pc, YTDWatchSpendUSD__pc,
                    HistoricalAccessoriesSpendEUR__pc, HistoricalPerfumeSpendEUR__pc, HistoricalJewelrySpendEUR__pc,HistoricalReadyToWearNbrProducts__pc,
                    HistoricalLeatherGoodSpendEUR__pc, HistoricalReadyToWearSpendEUR__pc, HistoricalShoesSpendEUR__pc, HistoricalWatchSpendEUR__pc,
                    YTDAccessoriesSpendEUR__pc, YTDPerfumeSpendEUR__pc, YTDJewelrySpendEUR__pc, YTDLeatherGoodSpendEUR__pc, YTDReadyToWearSpendEUR__pc,
                    YTDShoesSpendEUR__pc, YTDWatchSpendEUR__pc,
                    HistoricalAccessoriesSpendYEN__pc, HistoricalPerfumeSpendYEN__pc, HistoricalJewelrySpendYEN__pc,
                    HistoricalLeatherGoodSpendYEN__pc, HistoricalReadyToWearSpendYEN__pc, HistoricalShoesSpendYEN__pc, HistoricalWatchSpendYEN__pc,
                    YTDAccessoriesSpendYEN__pc, YTDPerfumeSpendYEN__pc, YTDJewelrySpendYEN__pc, YTDLeatherGoodSpendYEN__pc, YTDReadyToWearSpendYEN__pc,
                    YTDShoesSpendYEN__pc, YTDWatchSpendYEN__pc,
                    HistoricalAccessoriesSpendYUAN__pc, HistoricalPerfumeSpendYUAN__pc, HistoricalJewelrySpendYUAN__pc,
                    HistoricalLeatherGoodSpendYUAN__pc, HistoricalReadyToWearSpendYUAN__pc, HistoricalShoesSpendYUAN__pc, HistoricalWatchSpendYUAN__pc,
                    YTDAccessoriesSpendYUAN__pc, YTDPerfumeSpendYUAN__pc, YTDJewelrySpendYUAN__pc, YTDLeatherGoodSpendYUAN__pc, YTDReadyToWearSpendYUAN__pc,
                    YTDShoesSpendYUAN__pc, YTDWatchSpendYUAN__pc,
                    YTDSpendUSD__pc, YTDSpendEUR__pc, YTDSpendYEN__pc, YTDSpendYUAN__pc, YTDNbrProducts__pc, HistoricalSpendUSD__pc, HistoricalSpendEUR__pc,HistoricalSpendYEN__pc, HistoricalSpendYUAN__pc, HistoricalNbrProducts__pc, PersonContactId, Salutation, DreamId__c,
                    Lastname2__pc, Firstname2__pc, AttachedStoreCountry__pc, LastModifierStoreCountry__pc, PreferredLanguage__pc, IsProspect__pc, ComplaintClosingDate__pc
                    From Account
                    Where id = :currentOrder.Client__c];

       if (accDetailsList != null && accDetailsList.size() > 0) {
            accDetails = accDetailsList[0];

            // Retrieve the current user information to check LV Interest, Lifestyle and Size information visibility
            currentUser  = [SELECT Id, country__c,ProfileId FROM USER WHERE Id = :UserInfo.getUserId() limit 1];

            if (!IC_Factory.isAdmin() && IC_Factory.isPIPACountry(accDetails.LastModifierStoreCountry__pc) && IC_Factory.getPIPACountryCode(currentUser.Country__c) != accdetails.LastModifierStoreCountry__pc){
               accDetails.PreferredContactChannel__pc = null;

               // Size Information
               accDetails.Jacket__pc = null;
               accDetails.Dress__pc = null;
               accDetails.Knit__pc = null;
               accDetails.Pant__pc = null;
               accDetails.Shirt__pc = null;
               accDetails.Skirt__pc = null;
               accDetails.Suit__pc = null;
               accDetails.Belt__pc = null;
               accDetails.Shoes__pc = null;
               accDetails.Ring__pc = null;

               // Lifestyle & Family
               accDetails.Spouse__pc = null;
               accDetails.AnniversaryMonth__pc = null;
               accDetails.AnniversaryDay__pc = null;
               accDetails.Children__pc = null;
               accDetails.Pets__pc = null;
               accDetails.ShopsFor__pc = null;
               accDetails.PersonalInterest1__pc = null;
               accDetails.PersonalInterest2__pc = null;
               accDetails.PersonalInterest3__pc = null;
               accDetails.FoodPreferences__pc = null;
               accDetails.BeveragePreferences__pc = null;
               accDetails.PersonAssistantName = null;
               accDetails.PersonAssistantPhone = null;

               //LV Interests
               accDetails.AccessoriesInterest__pc = null;
               accDetails.JewelleryInterest__pc = null;
               accDetails.LeatherGoodsInterest__pc = null;
               accDetails.RTWInterest__pc = null;
               accDetails.ShoesInterest__pc = null;
               accDetails.WatchesInterest__pc = null;
               accDetails.PerfumesInterest__pc = null;
               accDetails.OtherInterest__pc = null;
               accDetails.ServiceInterest__pc = null;
               accDetails.EventInterest__pc = null;
           }
        }
    }
    
}