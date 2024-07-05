/*** Class Name SPO_OpportunityActionButtonController
*   Description: class handles transactions o order page (check user profile,update opportunity...)
*   Params: oppId => Opportunit Id used to find opportunity
*           foId => firm order id
*   ==============================
*   History:
***/

public class SPO_OpportunityActionButtonController {

    @AuraEnabled
    public static User getUser() {
        return [SELECT Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    @AuraEnabled
    public static Opportunity findOpportunityById(Id oppId) {

        Opportunity opp= [SELECT Name, ApplicationSource__c, StageName, SPO_DisplayOrder__c, SPO_OrderType__c, Send_to_ERP__c, SPO_Free__c, SPO_DepositAmount__c, SPO_CACode__c, SPO_StoreCode__c,SPO_Store__r.SalesServices__c,SPO_Store__r.isXstore__c, SPO_RMSClientId__c, SPO_BriefCode__c, // MIY-1895
                        SPO_SkuQuantity__c, SPO_UnitRetailPriceQuotation__c, SPO_SpecialOrderSKUCode__c, SPO_DepositNumber__c, SPO_StoreCurrency__c, SPO_DueAmount__c, 
                        SPO_DepositComment__c, SPO_UnitRetailPrice__c, SPO_BaseSku__c, SPO_TotalAmount__c, TECH_Nb_FO_Received_in_Store__c, OrderNumber__c,TECH_Nb_FO_Sent_to_MyPR__c,TECH_Nb_FO_Distribution_in_progress__c , SPO_StopBriefComment__c ,SPO_StopBriefReason__c FROM Opportunity WHERE Id = :oppId];
      
       return opp;
    }

    /*@AuraEnabled
    public static SPO_FirmOrder__c findLastFirmOrderByOppId(Id oppId) {
        SPO_FirmOrder__c firm;
        
        List<SPO_FirmOrder__c> firms = [SELECT SPO_FirmOrderNumber__c, SPO_DistributionStatus__c, SPO_FirmOrderStatus__c, SPO_Substatus__c
                     FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = :oppId];
         if (!firms.isEmpty()) {
             firm = firms.get(0);
         }
         return firm;
    }*/

    @AuraEnabled
    public static Opportunity updateOpportunity(Opportunity opp) {
        System.debug('+++updateOpportunity:in'+opp.StageName);
        if ('Deposit sent'.equals(opp.StageName)) {        
            addDeposit(opp);
       }  else if(('Closed Won'.equals(opp.StageName))) {
           opp.SPO_Date_Closed_Won__c = System.today();
           System.debug('+++closeWon:in');
            update opp;
        }
        else {
           opp.SPO_Date_Closed_Won__c = null;
            update opp;
        }
        return opp;
    }

    /**
     * Add deposit button logic:
     * 0. Make sure the deposit is not greater than the total amount // added by MTOU
     * 1. Validate the CA code.
     * 2. If this process is not Displya Order and not Free (gift checkbox checked) and the deposit amount is not blank, we call the Depost RMS service.
     * 3. Create all order items (firm order object) one for each quantity (Quantity = 3 ==> 3 firm orders).
     * 4. Pre filled fields for the referential section (for production view).
     */
    private static void addDeposit(Opportunity opp) {

        // Added by MTOU - 03/10/2016
        Boolean depositValidationResult=false;
        Boolean hasQuotation = !isWithoutQuotation(opp);
        if ((!hasQuotation && opp.SPO_DepositAmount__c > opp.SPO_UnitRetailPrice__c * opp.SPO_SkuQuantity__c) ||
                (hasQuotation && opp.SPO_DepositAmount__c > opp.SPO_TotalAmount__c)) {
            //this.showMessageOnTop = true;
            AuraHandledException ex = new AuraHandledException(Label.LV_SO_AddDepositError2);
            throw ex;
            //SO_UTIL.addErrorMessage(Label.LV_SO_AddDepositError2); // display error message when deposit amount is greater than the total amout
        }
         system.debug('SPO_DepositAmount__c : '+ opp.SPO_DepositAmount__c);
          if (opp.SPO_DepositAmount__c == null)
        {
            AuraHandledException ex = new AuraHandledException('You have to add a deposit');
            throw ex;

        }

        if( opp.SPO_DepositAmount__c>=(opp.Amount/2) || (opp.SPO_Store__r.SalesServices__c && opp.SPO_Store__r.isXstore__c)){ // MIY-2086
            depositValidationResult=true;
        }
         if(depositValidationResult==false){
                system.debug('enter in the condition');
                AuraHandledException ex = new AuraHandledException('The deposit is too low, it should be the half of the amount ' );
                throw ex;
            }  

        /*
		  * Added by J.C on December 2015
		  * The function launch a Web Service to create A deposit into the RMS and return back his ID.
		  * If the Callout succeed we continue, otherwise the Error message is shown to the User and the flow can't go on.
		  * ! In case of the Opp SPO_DisplayOrder__c being true or SPO_Free__c being true, we continue to the next step without the WS.
		  */
        String depositRmsId = null;
        system.debug('SPO_DepositAmount__c: ' + opp.SPO_DepositAmount__c);
        system.debug('SPO_DisplayOrder__c: ' + opp.SPO_DisplayOrder__c);
        if (opp.SPO_DisplayOrder__c == false &&
            // opp.SPO_Free__c == false  &&
                        opp.SPO_DepositAmount__c != null) {
            if (validateCaCodeWS(opp)) {

                System.debug('SO_BriefOrder_CTRL - addDeposit - inside deposit');
                try {
                    SO_WS_POSFacade.SO_CreateUpdateRmsDepositPaymentResult calloutResult =
                            SO_WS_POSFacade.createDepositOrPayment(false, opp,opp.SPO_Store__r.isXstore__c); // MIY-1895
                    //SO_CreateDepositPaymentRMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult =
                    //        SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(false, opp);
                    System.debug('SO_BriefOrder_CTRL - addDeposit - calloutResult = ' + calloutResult);

                    if (calloutResult != null && calloutResult.CalloutSuccessResult == true &&
                                    calloutResult.CalloutdepositPaymentRmsId != null) {
                        depositRmsId = calloutResult.CalloutdepositPaymentRmsId;
                    }
                } catch (Exception e) {
                    AuraHandledException ex = new AuraHandledException(e.getMessage());
                    throw ex;
                }
            }
        }
       
        // set a deposit date for display orders (technically speaking there is no deposit for display orders
        // but deposit date is required for planned delivery date calculation)
        else if (opp.SPO_DisplayOrder__c)
        {
            opp.SPO_DepositSentStatusDate__c = System.today();
        }

        // do not stop the process even if RMS is in error
        // depositRmsId = 'testMock';
        // if( depositRmsId != null
        //     || opp.SPO_DisplayOrder__c
        //     || opp.SPO_Free__c)
        // {

        List<SPO_FirmOrder__c> foList = createFirmOrders(opp);
        System.debug('Adding deposit');

        if (opp.SPO_OrderType__c == 'MTO on Catalog (Hardsided)') {
            System.debug('Updating flags for MTO');
            //opp.Send_to_ERP__c = true;
            for (SPO_FirmOrder__c fo : foList) {
                fo.SPO_TechETLStatus__c = 'A';
            }
        }
        //insert foList;

        opp.StageName = 'Creation in progress';// 'Deposit sent' removed / no more Deposit sent stage;
        opp.SPO_Date_Creation_in_progress__c = System.today();
        opp.SPO_DepositNumber__c = depositRmsId;
        update opp;
        insert foList;
        //}
        /*
		  * else
		  * {
		  * this.showMessageOnTop = true;
		  * SO_UTIL.addErrorMessage(Label.LV_SO_AddDepositError);
		  * }
		  */
    }

    public static List<SPO_FirmOrder__c> createFirmOrders(Opportunity opp){

        System.debug('SO_BriefOrder_CTRL - addDeposit - inside process create firm orders:');
        //Id recordTypeIdSP = Schema.SObjectType.SPO_FirmOrder__c.getRecordTypeInfosByName().get('Firm_Order').getRecordTypeId();
        //System.debug('recordTypeIdSP :' + recordTypeIdSP);
        List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
        for (Integer i = 1; i <= opp.SPO_SkuQuantity__c; i++) {
            foList.add(new SPO_FirmOrder__c(
                SPO_BriefName__c = opp.Id, 
                LineNumber__c = i,
               lock_serial_number__c = opp.SPO_LockNumber__c, //MIY-2120 
                SPO_FirmOrderStatus__c = 'Creation in progress',
                EstimatedLeadTimeTable__c = opp.SPO_EstimatedLeadTimeTable__c //MIY-1768
            ));
        }

        return foList;
    }

    private static Boolean isWithoutQuotation(Opportunity opp) {
        return opp.SPO_ProductCategory__c == SO_PicklistDependency.OPP_LEATHER_GOOD 
            && opp.SPO_OrderType__c == SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
    }


    private static Boolean validateCaCodeWS(Opportunity opp) {
        Boolean caValidationWsResult = false;
        
        System.debug('SFDC validateCaCodeWS');
        System.debug('SFDC this.opp.SPO_CACode__c: ' + opp);
        System.debug('SFDC this.opp.SPO_Store__c: ' + opp.SPO_Store__c);
        if (opp.SPO_Store__r.SalesServices__c && opp.SPO_Store__r.isXstore__c) {	
            return true ;} //MIY-2039
      
       // if(opp.SPO_CACode__c != SO_Session.theCurrentBrief.SPO_CACode__c){
        if(opp.SPO_CACode__c != null && opp.SPO_StoreCode__c != null ){
            SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults calloutResult = 
            SO_WS_POSFacade.verifyClientAdvisorEnquiry(opp.SPO_CACode__c, opp.SPO_StoreCode__c);
           
           //SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = 
           //SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS(opp.SPO_CACode__c, opp.SPO_StoreCode__c);
            System.debug('RMS VerifyClientAdvisorEnquiryRMS=' + calloutResult);
            caValidationWsResult = calloutResult.calloutSuccessResult;
        }
      //}
        if (!caValidationWsResult  && !Test.isRunningTest()) {
            // TODO Label
            AuraHandledException e = new AuraHandledException(
                String.format('Error for the input CA code {0} and the store code {1}', 
                    new String[]{opp.SPO_CACode__c, opp.SPO_StoreCode__c}) 
            );
            throw e;
        }
        
        
        System.debug('SO_BriefOrder_CTRL - validateCaCodeWS - caValidationWsResult: ' + caValidationWsResult);
        return caValidationWsResult;
    }

    @AuraEnabled
    public static List<Opportunity> updateFirmOrderDB(Id oppId){
        System.debug('$$$$ Opportunity sent from Orders brief SPO :' + oppId);

        List<SPO_FirmOrder__c> firmOrderToUpdate = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where SPO_BriefName__c =:oppId];
        
        set<id> firmOrderId = new set<id>();
        if(firmOrderToUpdate.size() > 0){
            for(SPO_FirmOrder__c firmOrder: firmOrderToUpdate){
            System.debug('$$$$ SPO firm order to update in updateFirmOrder method :' + firmOrder);
            System.debug('$$$$ SPO firm order status BEFORE update :' + firmOrder.SPO_FirmOrderStatus__c);
                if(firmOrder.SPO_FirmOrderStatus__c != 'Received in Store'){// Dont update the status if it is already 'Received in Store'
                    firmOrder.SPO_FirmOrderStatus__c = 'Received in Store'; 
                }
            
            firmOrderId.add(firmOrder.Id);//Add opp Id to use in below SOQL below to return opp to lightning componet to update Opp
            }   
        }
        
        update firmOrderToUpdate;

        List<SPO_FirmOrder__c> firmOrderAfterUpdate = new List<SPO_FirmOrder__c> ();
        if(firmOrderId.size() > 0){
        firmOrderAfterUpdate = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where Id In :firmOrderId];
        }

        for(SPO_FirmOrder__c firmOrderAfter: firmOrderAfterUpdate){
            System.debug('$$$$ SPO firm order status AFTER update :' + firmOrderAfter.SPO_FirmOrderStatus__c);
        }

        return [SELECT ApplicationSource__c, StageName, SPO_DisplayOrder__c, SPO_Free__c, SPO_DepositAmount__c, SPO_CACode__c,SPO_Store__r.SalesServices__c,SPO_Store__r.isXstore__c, SPO_StoreCode__c, SPO_RMSClientId__c, SPO_BriefCode__c, // MIY-1895
                        SPO_SkuQuantity__c, SPO_UnitRetailPriceQuotation__c, SPO_SpecialOrderSKUCode__c, SPO_DepositNumber__c, SPO_StoreCurrency__c, SPO_DueAmount__c, 
                        SPO_DepositComment__c, SPO_UnitRetailPrice__c, SPO_BaseSku__c, SPO_TotalAmount__c
                     FROM Opportunity WHERE Id = :oppId];
    }

    @AuraEnabled
    public static SPO_FirmOrder__c updateFirmOrderReceivedInStore(Id foId){
        System.debug('$$$$ firmOrder sent from Orders brief SPO :' + foId);

        List<SPO_FirmOrder__c> firmOrderToUpdate = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where Id =:foId];
        
        set<id> firmOrderId = new set<id>();
        if(firmOrderToUpdate.size() > 0){
            for(SPO_FirmOrder__c firmOrder: firmOrderToUpdate){
            System.debug('$$$$ SPO firm order to update in updateFirmOrder method :' + firmOrder);
            System.debug('$$$$ SPO firm order status BEFORE update :' + firmOrder.SPO_FirmOrderStatus__c);
                if(firmOrder.SPO_FirmOrderStatus__c != 'Received in Store'){// Dont update the status if it is already 'Received in Store'
                    firmOrder.SPO_FirmOrderStatus__c = 'Received in Store'; 
                }
                //else if(firmOrder.SPO_FirmOrderStatus__c != 'Received in Store' && firmOrder.SPO_FirmOrderStatus__c != 'Cancelled by store' && firmOrder.SPO_FirmOrderStatus__c != 'Cancelled by production' ){
                   // firmOrder.SPO_FirmOrderStatus__c = 'Cancelled by store';
               // }
            
            firmOrderId.add(firmOrder.Id);//Add opp Id to use in below SOQL below to return opp to lightning componet to update Opp
            }   
        }
        
        update firmOrderToUpdate;

        List<SPO_FirmOrder__c> firmOrderAfterUpdate = new List<SPO_FirmOrder__c> ();
        if(firmOrderId.size() > 0){
        firmOrderAfterUpdate = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where Id In :firmOrderId];
        }

        for(SPO_FirmOrder__c firmOrderAfter: firmOrderAfterUpdate){
            System.debug('$$$$ SPO firm order status AFTER update :' + firmOrderAfter.SPO_FirmOrderStatus__c);
        }

        return  [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where Id =:foId];
    }
    
	@AuraEnabled
	public static SPO_FirmOrder__c getOpportunityByFirmOrder(Id foId){
		System.debug('CALL APEX METHOD Get Opp by FO');

		SPO_FirmOrder__c newFo= [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c
		                         FROM SPO_FirmOrder__c Where Id =:foId];
		System.debug('Order related to firm order :' +newFo.SPO_BriefName__c);
		System.debug('FirmOrder returned :' +newFo);

		return newFo;
	}
    
    
    @AuraEnabled
	public static Opportunity updateStopOrderField(Opportunity opp){
		System.debug('$$$$$$$$$$$$$$$$ before update ' + opp.SPO_StopBriefComment__c);
		opp.SPO_StopBriefComment__c = opp.SPO_StopBriefComment__c;
		opp.SPO_StopBriefReason__c = opp.SPO_StopBriefReason__c;
		update opp;
		System.debug('$$$$$$$$$$$$$$$$ after update ' + opp.SPO_StopBriefComment__c);
		System.debug('$$$$$$$$$$$$$$$$ after update Stage' + opp.StageName);

		return opp;
	}
                                                   
    @AuraEnabled
	public static SPO_FirmOrder__c cancelFirmOrderDB(Id foId, Opportunity opp ){

		SPO_FirmOrder__c fo = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c
		                       FROM SPO_FirmOrder__c Where Id =:foId];
		

		Opportunity order = [SELECT Id, TECH_Nb_FO_not_cancelled__c
		                     FROM Opportunity Where Id =:fo.SPO_BriefName__c];


		if(fo.SPO_FirmOrderStatus__c != null &&  fo.SPO_FirmOrderStatus__c !='Cancelled by store') {
			System.debug('Mise a jour du status du firm order');
			fo.SPO_FirmOrderStatus__c = 'Cancelled by store';
		}
		System.debug('+++ Eval TECH_Nb_FO_not_cancelled__c= '+order.TECH_Nb_FO_not_cancelled__c);
		if(order.TECH_Nb_FO_not_cancelled__c==1) {
			System.debug('+++ TECH_Nb_FO_not_cancelled__c==1 Opp.Stopreason='+opp.SPO_StopBriefReason__c);
		 	updateStopOrderField(opp);
		}


		update fo;
		return fo;
	}

    
       @AuraEnabled
    public static String getSORJson() {
        List<PicklistEntry> values = Opportunity.SPO_StopBriefReason__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }
                                                     

    
  /*   @AuraEnabled
    public static SPO_FirmOrder__c cancelFirmOrder(Id foId){
        System.debug('$$$$ firmOrder sent from Orders brief SPO :' + foId);

        SPO_FirmOrder__c firmOrderToUpdate = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where Id =:foId];
        
       //set<id> firmOrderId = new set<id>();
        //if(firmOrderToUpdate.size() > 0){
            //for(SPO_FirmOrder__c firmOrder: firmOrderToUpdate){
            System.debug('$$$$ SPO firm order to update in updateFirmOrder method :' + firmOrderToUpdate);
            System.debug('$$$$ SPO firm order status BEFORE update :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
                if(firmOrderToUpdate.SPO_FirmOrderStatus__c != 'Cancelled by store'){// Dont update the status if it is already 'Received in Store'
                    firmOrderToUpdate.SPO_FirmOrderStatus__c = 'Cancelled by store'; 
                }
            
               
        
        
        update firmOrderToUpdate;
       
            System.debug('$$$$ SPO firm order status AFTER update :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
        

        return  [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where Id =:foId];
    }*/
    



    /*@AuraEnabled
    public static Opportunity updateOppToERP(Opportunity opp)  {
        // SO_BriefOrder_CTRL
        System.debug('SO_BriefOrder - createOrderInERP - click');

        try {
            String skuCode = getSKUCode(opp.SPO_SpecialOrderSKUCodeRef__c);
            opp.SPO_SpecialOrderSKUCode__c = skuCode;
            opp.StageName = 'Creation in progress';

            List<SPO_FirmOrder__c> firmOrderList = retFirmOrders(opp.Id);
            for (SPO_FirmOrder__c fo : firmOrderList) {
                fo.SPO_FirmOrderStatus__c = 'Creation in progress';
                fo.SPO_Substatus__c       = 'Technical data';
                fo.SPO_TechETLStatus__c   = 'A';
            }
            
            update opp;
            update firmOrderList;
        } 
        catch (Exception ex) {SO_UTIL.addErrorMessage(ex);}

        return opp;
    }

    @AuraEnabled
    public static Opportunity updateOppToReferential(Opportunity opp) {
        // SO_BriefOrder_CTRL
        System.debug('SO_BriefOrder_CTRL - sendToReferential - click');

        try {
            String skuCode = getSKUCode(opp.SPO_SpecialOrderSKUCodeRef__c);
            opp.SPO_SpecialOrderSKUCode__c = skuCode;
            opp.StageName = 'Creation in progress';

            opp.SPO_TechMailToreferential__c = true;

            List<SPO_FirmOrder__c> firmOrderList = retFirmOrders(opp.Id);
            for (SPO_FirmOrder__c fo : firmOrderList) {
                fo.SPO_FirmOrderStatus__c = 'Creation in progress';
                fo.SPO_Substatus__c       = 'Codification';
            }

            update opp;
            update firmOrderList;
        } 
        catch (Exception ex) {SO_UTIL.addErrorMessage(ex);}

        return opp;
    }

    private static String getSKUCode(Id productRefId) {
        String ans = null;
        List<ProductReferential__c> productRefList = [SELECT SKUCode__c FROM ProductReferential__c WHERE Id =: productRefId];
        if(!productRefList.isEmpty()) {
            ans = productRefList[0].SKUCode__c;
        }

        return ans;
    }

    private static List<SPO_FirmOrder__c> retFirmOrders(Id oppId) {
        return [SELECT SPO_FirmOrderNumber__c, SPO_RevisedDeliveryDate__c, SPO_FirmOrderStatus__c, SPO_Substatus__c
                                        FROM SPO_FirmOrder__c 
                                        WHERE SPO_BriefName__c = :oppId];
    }*/

    /**
    * code from VF SO_BriefOrder > initUnitRetailPriceRMS
    **/
    /*@AuraEnabled
    public static Opportunity getPrice(Opportunity opp)  {
        // SO_BriefOrder_CTRL

        Boolean hasQuotation = !isWithoutQuotation(opp);
        if(!hasQuotation && isValidForPriceCall(opp)) {

            if(String.isNotBlank(opp.SPO_StoreCode__c) && String.isNotBlank(opp.SPO_BaseSku__c)) {
                
                SO_WS_POSFacade.PriceResponse calloutResult = SO_WS_POSFacade.retrieveArticlePrice(opp.SPO_StoreCode__c, opp.SPO_BaseSku__c);
                System.debug('getPrice > ' + calloutResult);
                
                if (opp.SPO_UnitRetailPrice__c != calloutResult.unitRetailPrice
                        && opp.SPO_Number_Of_decimals_Store__c != calloutResult.numberOfDecimalsStore) {

                    opp.SPO_UnitRetailPrice__c = calloutResult.unitRetailPrice;
                    opp.SPO_Number_Of_decimals_Store__c = calloutResult.numberOfDecimalsStore;                    
                    //update opp;
                }
    
                //$('#rmsArticlePriceToDisplayNoQuotationId').val(jsonRMSPriceData.unitRetailPrice.toFixed(jsonRMSPriceData.numberOfDecimalsStore) + $('#rmsArticlePriceToDisplayNoQuotationId').val());
                if (!calloutResult.isValid) {
                    // TODO Label
                    throw new AuraHandledException(calloutResult.errorMessage);
                }
            }
        }
    
        return opp;
    }

    private static Boolean isValidForPriceCall(Opportunity opp) {
        return  opp.StageName == 'Brief in progress' ||
                opp.StageName == 'Quotation in progress' ||
                opp.StageName == 'Quotation submitted' ||
                opp.StageName == 'Quotation accepted';
    }*/
}