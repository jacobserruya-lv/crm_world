/**
	Description: Batch used in the developper console in order to YTD fields for all clients
	Created for: SOW: IC007 ICON project
	Create date: 27/08/2013

	Update History
	--------------
	27/08/2013 / IC007/ Created by Laurent Loiseau
	03/01/2022 Updated by Rachel
	
	Issues / TODOs
	--------------
*/
global class IC_RefreshYTD_Batch implements Database.Batchable<sObject>{

	public String query;
	
	global IC_RefreshYTD_Batch(){
		
         //query = 'SELECT Id FROM Account where Id in(select Client__c from PPR_PurchProduct__c where PurchasedDate__c>2020-12-31 and PurchasedDate__c<2022-01-01)';
         query = 'SELECT Id FROM Account where Id in(select Client__c from PPR_PurchProduct__c where PurchasedDate__c>2020-12-31 and PurchasedDate__c<2022-01-01) and LastModifiedBy.Name != \'Rachel ATLAN\' ';
	 }
	 	
	global database.querylocator start(Database.BatchableContext CD){
		System.debug('#### START - IC_RefreshYTD_Batch');
		System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
	} 
    
	global void execute(Database.BatchableContext CD, List<sObject> scope){

		try{
			List<Account> lstAcc = new List<Account>();
            for(sObject o:scope){
                Account myAccount = (Account)o;
                myAccount.TurnoverYTDTaxFreeCNY__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYHEExotics__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYMenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYMenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYTravel__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeCNYWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeEUR__pc=0;
                myAccount.TurnoverYTDTaxFreeEURHEExotics__pc=0;
                myAccount.TurnoverYTDTaxFreeEURLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxFreeEURMenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeEURMenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeEURObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxFreeEURTravel__pc=0;
                myAccount.TurnoverYTDTaxFreeEURWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxFreeEURWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeEURWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeJPY__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYHEExotics__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYMenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYMenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYTravel__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeJPYWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeUSD__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDHEExotics__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDMenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDMenShoe__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDTravel__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxFreeUSDWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclCNY__pc=0;
                myAccount.TurnoverYTDTaxInclCNYACC__pc=0;
                myAccount.TurnoverYTDTaxInclCNYHEExotics__pc=0;
                myAccount.TurnoverYTDTaxInclCNYJEW__pc=0;
                myAccount.TurnoverYTDTaxInclCNYLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxInclCNYLG__pc=0;
                myAccount.TurnoverYTDTaxInclCNYMenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclCNYMenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclCNYObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxInclCNYPFM__pc=0;
                myAccount.TurnoverYTDTaxInclCNYRTW__pc=0;
                myAccount.TurnoverYTDTaxInclCNYSHOE__pc=0;
                myAccount.TurnoverYTDTaxInclCNYTravel__pc=0;
                myAccount.TurnoverYTDTaxInclCNYWAT__pc=0;
                myAccount.TurnoverYTDTaxInclCNYWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxInclCNYWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclCNYWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclEUR__pc=0;
                myAccount.TurnoverYTDTaxInclEURACC__pc=0;
                myAccount.TurnoverYTDTaxInclEURHEExotics__pc=0;
                myAccount.TurnoverYTDTaxInclEURJEW__pc=0;
                myAccount.TurnoverYTDTaxInclEURLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxInclEURLG__pc=0;
                myAccount.TurnoverYTDTaxInclEURMenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclEURMenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclEURObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxInclEURPFM__pc=0;
                myAccount.TurnoverYTDTaxInclEURRTW__pc=0;
                myAccount.TurnoverYTDTaxInclEURSHOE__pc=0;
                myAccount.TurnoverYTDTaxInclEURTravel__pc=0;
                myAccount.TurnoverYTDTaxInclEURWAT__pc=0;
                myAccount.TurnoverYTDTaxInclEURWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxInclEURWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclEURWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclJPY__pc=0;
                myAccount.TurnoverYTDTaxInclJPYACC__pc=0;
                myAccount.TurnoverYTDTaxInclJPYHEExotics__pc=0;
                myAccount.TurnoverYTDTaxInclJPYJEW__pc=0;
                myAccount.TurnoverYTDTaxInclJPYLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxInclJPYLG__pc=0;
                myAccount.TurnoverYTDTaxInclJPYMenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclJPYMenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclJPYObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxInclJPYPFM__pc=0;
                myAccount.TurnoverYTDTaxInclJPYRTW__pc=0;
                myAccount.TurnoverYTDTaxInclJPYSHOE__pc=0;
                myAccount.TurnoverYTDTaxInclJPYTravel__pc=0;
                myAccount.TurnoverYTDTaxInclJPYWAT__pc=0;
                myAccount.TurnoverYTDTaxInclJPYWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxInclJPYWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclJPYWomenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclUSD__pc=0;
                myAccount.TurnoverYTDTaxInclUSDACC__pc=0;
                myAccount.TurnoverYTDTaxInclUSDHEExotics__pc=0;
                myAccount.TurnoverYTDTaxInclUSDJEW__pc=0;
                myAccount.TurnoverYTDTaxInclUSDLeatherBag__pc=0;
                myAccount.TurnoverYTDTaxInclUSDLG__pc=0;
                myAccount.TurnoverYTDTaxInclUSDMenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclUSDMenShoe__pc=0;
                myAccount.TurnoverYTDTaxInclUSDObjNomadeHardsided__pc=0;
                myAccount.TurnoverYTDTaxInclUSDPFM__pc=0;
                myAccount.TurnoverYTDTaxInclUSDRTW__pc=0;
                myAccount.TurnoverYTDTaxInclUSDSHOE__pc=0;
                myAccount.TurnoverYTDTaxInclUSDTravel__pc=0;
                myAccount.TurnoverYTDTaxInclUSDWAT__pc=0;
                myAccount.TurnoverYTDTaxInclUSDWatchJewelry__pc=0;
                myAccount.TurnoverYTDTaxInclUSDWomenRtw__pc=0;
                myAccount.TurnoverYTDTaxInclUSDWomenShoe__pc=0;
                myAccount.YTDAccessoriesNbrProducts__pc=0;
                myAccount.YTDAccessoriesSpendEUR__pc=0;
                myAccount.YTDAccessoriesSpendUSD__pc=0;
                myAccount.YTDAccessoriesSpendYEN__pc=0;
                myAccount.YTDAccessoriesSpendYUAN__pc=0;
                myAccount.YTDJewelryNbrProducts__pc=0;
                myAccount.YTDJewelrySpendEUR__pc=0;
                myAccount.YTDJewelrySpendUSD__pc=0;
                myAccount.YTDJewelrySpendYEN__pc=0;
                myAccount.YTDJewelrySpendYUAN__pc=0;
                myAccount.YTDLeatherGoodNbrProducts__pc=0;
                myAccount.YTDLeatherGoodSpendEUR__pc=0;
                myAccount.YTDLeatherGoodSpendUSD__pc=0;
                myAccount.YTDLeatherGoodSpendYEN__pc=0;
                myAccount.YTDLeatherGoodSpendYUAN__pc=0;
                myAccount.YTDNbrProducts__pc=0;
                myAccount.YTDPerfumeNbrProducts__pc=0;
                myAccount.YTDPerfumeSpendEUR__pc=0;
                myAccount.YTDPerfumeSpendUSD__pc=0;
                myAccount.YTDPerfumeSpendYEN__pc=0;
                myAccount.YTDPerfumeSpendYUAN__pc=0;
                myAccount.YTDQtePurchaseCapucines__pc=0;
                myAccount.YTDQtePurchased__pc=0;
                myAccount.YTDQtePurchasedACC__pc=0;
                myAccount.YTDQtePurchasedBag__pc=0;
                myAccount.YTDQtePurchasedExotics__pc=0;
                myAccount.YTDQtePurchasedJEW__pc=0;
                myAccount.YTDQtePurchasedLG__pc=0;
                myAccount.YTDQtePurchasedMenRtw__pc=0;
                myAccount.YTDQtePurchasedMenShoe__pc=0;
                myAccount.YTDQtePurchasedObjNomadeHardsided__pc=0;
                myAccount.YTDQtePurchasedPFM__pc=0;
                myAccount.YTDQtePurchasedRTW__pc=0;
                myAccount.YTDQtePurchasedSHOE__pc=0;
                myAccount.YTDQtePurchasedTravel__pc=0;
                myAccount.YTDQtePurchasedWAT__pc=0;
                myAccount.YTDQtePurchasedWatchJewelry__pc=0;
                myAccount.YTDQtePurchasedWomenRtw__pc=0;
                myAccount.YTDQtePurchasedWomenShoe__pc=0;
                myAccount.YTDReadyToWearNbrProducts__pc=0;
                myAccount.YTDReadyToWearSpendEUR__pc=0;
                myAccount.YTDReadyToWearSpendUSD__pc=0;
                myAccount.YTDReadyToWearSpendYEN__pc=0;
                myAccount.YTDReadyToWearSpendYUAN__pc=0;
                myAccount.YTDShoesNbrProducts__pc=0;
                myAccount.YTDShoesSpendEUR__pc=0;
                myAccount.YTDShoesSpendUSD__pc=0;
                myAccount.YTDShoesSpendYEN__pc=0;
                myAccount.YTDShoesSpendYUAN__pc=0;
                myAccount.YTDSpendEUR__pc=0;
                myAccount.YTDSpendUSD__pc=0;
                myAccount.YTDSpendYEN__pc=0;
                myAccount.YTDSpendYUAN__pc=0;
                myAccount.YTDTotalDollarCapucines__pc=0;
                myAccount.YTDTotalEuroCapucines__pc=0;
                myAccount.YTDTotalYenCapucines__pc=0;
                myAccount.YTDTotalYuanCapucines__pc=0;
                myAccount.YTDWatchNbrProducts__pc=0;
                myAccount.YTDWatchSpendEUR__pc=0;
                myAccount.YTDWatchSpendUSD__pc=0;
                myAccount.YTDWatchSpendYEN__pc=0;
                myAccount.YTDWatchSpendYUAN__pc=0;
            	lstAcc.add(myAccount);              	
            }               
            update lstAcc;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}