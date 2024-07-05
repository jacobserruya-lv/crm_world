public with sharing class MIY_OrderPageController {
	@AuraEnabled
	public static Opportunity getLatestOrder() { //MIY-1743 added SPO_wwRMSClientId__c //MIY-1762 added SPO_Estimated_date_NOMTO__c
	  Opportunity latestOrder = [
		  SELECT Id, Name, SPO_DepositAmount__c, SPO_DepositNumber__c, OrderNumber__c, Amount,SPO_Store__r.SalesServices__c,SPO_Store__r.isXstore__c, // MIY-1895
		  Account.Name, Account.DREAMID__c, Account.PersonMobilePhone, Account.PersonEmail, Account.PrimaryAddress__pc,
		  Account.Can_Be_Contacted_By_Phone__pc, Account.Can_Be_Contacted_By_Email__pc, Account.Can_Be_Contacted_By_SMS__pc,
		  Account.Can_Be_Contacted_By_Mail__pc, StageName, RecordType.Name, Final_Delivery_Date__c, SPO_Estimated_date_NOMTO__c,
		  SPO_Store__r.Name, SPO_Store__r.Currency__c, Order_Planned_Delivery_Date__c, SPO_DeliveryAddress__c, SPO_wwRMSClientId__c,
		  SPO_PlannedDeliveryDate__c, SPO_PlannedDeliveryDateFormula__c, TECH_OrderNumber__c, ECO_OrderNumber__c,
		  SPO_RMSClientId__c, SPO_DueAmount__c, SPO_DisplayOrder__c, SPO_Date_Brief_in_progress__c,
		  SPO_Date_Quotation_in_progress__c, SPO_Date_Quotation_submitted__c, SPO_Date_Quotation_accepted__c,
		  SPO_Date_Creation_in_progress__c, SPO_Date_In_progress__c, SPO_Date_Closed_Won__c, CreatedDate,
		  Owner.Name,
		  (
			  SELECT Id, ProductSKU__c, Name, Product_Image_URL__c, Product_Name__c, LineNumber__c,
			  SPO_FirmOrderStatus__c, DistributionStatus__c, UnitaryPrice__c, UnitRetailPrice__c,
			  Planned_Delivery_date__c, SPO_ReceivedInStoreDate__c, FluidRecipeId__c,
			  ProductCatalogue__r.Image1Url__c, ProductCatalogue__r.Image2Url__c, ProductCatalogue__r.Image3Url__c,
			  ProductCatalogue__r.Image4Url__c, ProductCatalogue__r.Image5Url__c,ProductCatalogue__r.SKU__c,
			  ProductCatalogue__r.FluidViewImage__c, ProductCatalogue__r.Category__r.FluidViewImage__c,
			  ProductCatalogue__r.Website_Views__c, ProductCatalogue__r.Category__r.Website_Views__c,
			  ProductCatalogue__r.LeadTimeApproval__c, CreatedDate, LastModifiedDate, ValidatedMaxDate__c,ProductCatalogue__r.Workflow__c,ProductCatalogue__r.Category__r.name,TECH_Product_Hard_Workflow__c
			  FROM SpeOrder_Order_Following__r
		  )
		  FROM Opportunity
		  WHERE RecordType.Name = 'Perso Order' AND TECH_Nb_FO_not_cancelled__c > 0
		  ORDER BY CreatedDate DESC
		  LIMIT 1
	  ];
	  return latestOrder;
	}
  
	@AuraEnabled
	public static Opportunity getOrder(String orderId) { //MIY-1743 added SPO_wwRMSClientId__c //MIY-1762 //MIY-1768 added SPO_EstimatedLeadTimeTable__c //MIY-1969 added Threekit_Short_Id__c
	  Opportunity order = [
		  SELECT Id, Name, SPO_DepositAmount__c, SPO_DepositNumber__c, OrderNumber__c, Amount,SPO_Store__r.SalesServices__c,SPO_Store__r.isXstore__c, // MIY-1895
		  Account.Name, Account.DREAMID__c, Account.PersonMobilePhone, Account.PersonEmail, Account.PrimaryAddress__pc,
		  Account.Can_Be_Contacted_By_Phone__pc, Account.Can_Be_Contacted_By_Email__pc, Account.Can_Be_Contacted_By_SMS__pc,
		  Account.Can_Be_Contacted_By_Mail__pc, StageName, RecordType.Name, Final_Delivery_Date__c,
		  SPO_Store__r.Name, SPO_Store__r.Currency__c, Order_Planned_Delivery_Date__c, SPO_DeliveryAddress__c, SPO_wwRMSClientId__c,
		  SPO_PlannedDeliveryDate__c, SPO_PlannedDeliveryDateFormula__c, TECH_OrderNumber__c, ECO_OrderNumber__c,
		  SPO_RMSClientId__c, SPO_DueAmount__c, SPO_DisplayOrder__c, SPO_Date_Brief_in_progress__c,
		  SPO_Date_Quotation_in_progress__c, SPO_Date_Quotation_submitted__c, SPO_Date_Quotation_accepted__c,
		  SPO_Date_Creation_in_progress__c, SPO_Date_In_progress__c, SPO_Date_Closed_Won__c, CreatedDate,
		  Owner.Name,SPO_ExteriorMaterial1__c,SPO_ExteriorMaterial1localcomment__c,SPO_ExteriorMaterial2__c,
		  SPO_ExteriorMaterial2localcomment__c,SPO_ExteriorMaterial3__c,SPO_ExteriorMaterial3localcomment__c,
		  SPO_ExteriorMaterialColor1__c,SPO_ExtMaterialColor1localcomment__c,SPO_ExteriorMaterialColor2__c,
		  SPO_ExtMaterialColor2localcomment__c,SPO_ExteriorMaterialColor3__c,SPO_ExtMaterialColor3localcomment__c,
		  SPO_LiningInteriorColor1__c,SPO_LiningInteriorColor2__c,SPO_LiningInteriorMaterial1__c,
		  SPO_LiningInteriorMaterial2__c,SPO_LiningColor1LocalComment__c,SPO_LiningColor1ZoneApproverComment__c,
		  SPO_LiningColor2LocalComment__c,SPO_LiningColor2ZoneApproverComment__c,SPO_LiningMaterial1LocalComment__c,
		  SPO_LiningMaterial1ZoneApproverComment__c,SPO_LiningMaterial2LocalComment__c,
		  SPO_LiningMaterial2ZoneApproverComment__c,SPO_CreationType__c,SPO_ColorMetalicparts__c,
		  Duration_Quotation_in_progress__c, Duration_Quotation_Submitted__c, Received_in_Store_Date__c,
		  toLabel(Workshop__c), CloseDate,SPO_Store__c,SPO_CACode__c,SPO_StoreCode__c,SPO_EstimatedProductionTimeMonths__c,
		  SPO_EstimatedDistributionTime__c,SPO_Estimated_date_NOMTO__c,SPO_Exo__c,SPO_ProductCategory__c,SPO_TotalAmount__c,
		  SPO_DepositComment__c,SPO_Date_Cancelled_by_store__c,SPO_Date_Cancelled_by_Production__c,
		  SPO_StopBriefReason__c, SPO_StopBriefComment__c, SPO_EstimatedLeadTime_LG__c,
		  TECH_Order_Planned_Delivery_Date__c,SPO_CRS__c,SPO_TechMailToreferential__c,SPO_TechEmailAlreadySent__c,
		  SPO_BaseSKURefmodelSKU__r.ImageLink1__c, SPO_BaseSKURefmodelSKU__r.Name,
		  SPO_BaseSKURefmodelSKU__r.SKUCode__c, SPO_BaseSKURefmodelSKU__r.ProductCategory__c,
		  SPO_BaseSKURefmodelSKU__r.Length__c, SPO_BaseSKURefmodelSKU__r.Witdth__c,
		  SPO_BaseSKURefmodelSKU__r.Height__c, SPO_BaseSKURefmodelSKU__r.MacroColor__c,
		  SPO_BaseSKURefmodelSKU__r.AestheticLine__c, SPO_BaseSKURefmodelSKU__r.Departement__c,
		  SPO_CommercialLocalComment__c,SPO_Sku_Code_S__c,SPO_SkuQuantity__c,SPO_SpecialEvents__c,SPO_EstimatedLeadTimeTable__c,
		  SPO_WishedDate__c, SPO_DeliveryAddressComment__c,SPO_PaintingYN__c, SPO_Lock__c,SPO_BeltSize__c,
		  SPO_Patch__c,SPO_LockNumber__c,
		  SPO_PatchFreeText__c,SPO_Date_Distribution_in_Progress__c,
		  SPO_SpecialOrderSKUCodeRef__c,SPO_SpecialOrderSKUCodeRef__r.Name,SPO_SpecialOrderSKUCodeRef__r.SKUCode__c,
		  SPO_ManuFacturerProcess__c,SPO_SalesType__c,SPO_Activity2__c,SPO_Department__c,SPO_SubGroup__c,
		  TECH_Nb_FO_ETL_Status_is_V__c,TECH_Nb_FO_not_cancelled__c,SPO_CommercialZoneApproverComment__c,
		  Send_to_ERP__c,SPO_SpecialOrderSKUCode__c, TECH_Nb_FO__c,ApplicationSource__c,SPO_Numberofproductivehours__c,SPO_UnitRetailPriceQuotation__c,
		  (
			  SELECT Id, ProductSKU__c, Name, Threekit_Short_Id__c, Product_Image_URL__c, Product_Name__c, LineNumber__c,
			  SPO_FirmOrderStatus__c, DistributionStatus__c, UnitaryPrice__c, UnitRetailPrice__c,
			  Planned_Delivery_date__c, SPO_ReceivedInStoreDate__c, FluidRecipeId__c,
			  ProductCatalogue__r.Image1Url__c, ProductCatalogue__r.Image2Url__c, ProductCatalogue__r.Image3Url__c,
			  ProductCatalogue__r.Image4Url__c, ProductCatalogue__r.Image5Url__c,ProductCatalogue__r.SKU__c,
			  ProductCatalogue__r.FluidViewImage__c, ProductCatalogue__r.Category__r.FluidViewImage__c,
			  ProductCatalogue__r.Website_Views__c, ProductCatalogue__r.Category__r.Website_Views__c,
			  ProductCatalogue__r.LeadTimeApproval__c, CreatedDate, LastModifiedDate, ValidatedMaxDate__c,
			  MIY_ProductionStatusSimple__c, Undefined_Material__c, ProductCatalogue__r.Exotic_Leather__c,
			  SPO_TechETLStatus__c, ProductCatalogue__r.Workshop_SKU__c, ProductCatalogue__r.Generic_SKU__c,
			  ProductCatalogue__r.LeadTimeManufacturing__c, SPO_BriefName__c, Cancellation_Reason__c,
			  Cancellation_Comment__c,Cancellation_Date__c, ProductCatalogue__r.Technical_Data_Defined__c,
			  ProductCatalogue__r.ReportingCategory__r.Exotic_Workflow__c, Creation_Status__c, 
			  Planned_Manufacturing_Date__c, PlannedDeliveryDate__c, Planned_Manufacturing_Date_Comment__c,
			  ProductCategory__c, MIY_ProductionStatus__c, IsInferiorVmaxDate__c,ProductCatalogue__r.Workflow__c,ProductCatalogue__r.Category__r.name,TECH_Product_Hard_Workflow__c,ERP__c
			  FROM SpeOrder_Order_Following__r
			  ORDER BY LineNumber__c ASC
		  )
		  FROM Opportunity
		  WHERE Id = :orderId
	  ];
  
	  return order;
	}
  
	@AuraEnabled
	public static SPO_FirmOrder__c getFirmOrder(String firmOrderId) {
	  SPO_FirmOrder__c firmOrder = [
		  SELECT Id, ProductSKU__c, Name, Product_Image_URL__c, Product_Name__c, LineNumber__c,
			  SPO_FirmOrderStatus__c, DistributionStatus__c, UnitaryPrice__c, UnitRetailPrice__c,
			  Planned_Delivery_date__c, SPO_ReceivedInStoreDate__c, FluidRecipeId__c,
			  ProductCatalogue__r.Image1Url__c, ProductCatalogue__r.Image2Url__c, ProductCatalogue__r.Image3Url__c,
			  ProductCatalogue__r.Image4Url__c, ProductCatalogue__r.Image5Url__c,ProductCatalogue__r.SKU__c,
			  ProductCatalogue__r.FluidViewImage__c, ProductCatalogue__r.Category__r.FluidViewImage__c,
			  ProductCatalogue__r.Website_Views__c, ProductCatalogue__r.Category__r.Website_Views__c,
			  ProductCatalogue__r.LeadTimeApproval__c, CreatedDate, LastModifiedDate, ValidatedMaxDate__c,
			  MIY_ProductionStatusSimple__c, Undefined_Material__c, ProductCatalogue__r.Exotic_Leather__c,
			  SPO_TechETLStatus__c, ProductCatalogue__r.Workshop_SKU__c, ProductCatalogue__r.Generic_SKU__c,
			  ProductCatalogue__r.LeadTimeManufacturing__c, SPO_BriefName__c, Cancellation_Reason__c,
			  Cancellation_Comment__c,Cancellation_Date__c, ProductCatalogue__r.Technical_Data_Defined__c,
			  ProductCatalogue__r.ReportingCategory__r.Exotic_Workflow__c, Creation_Status__c,
			  Planned_Manufacturing_Date__c, PlannedDeliveryDate__c, Planned_Manufacturing_Date_Comment__c,
			  ProductCategory__c, MIY_ProductionStatus__c, IsInferiorVmaxDate__c,ERP__c,ProductCatalogue__r.Workflow__c,ProductCatalogue__r.Category__r.name,SPO_BriefName__r.SPO_DisplayOrder__c,TECH_Product_Hard_Workflow__c
		  FROM SPO_FirmOrder__c
		  WHERE Id =: firmOrderId
	  ];
  
	  return firmOrder;
	}
  
	@AuraEnabled
	public static SPO_FirmOrder__c updateFirmOrder(String firmOrderId) {
	  // Adapted from SPO_FirmOrderControllerLC.updateFirmOrderDB
  
	  SPO_FirmOrder__c firmOrderToUpdate = MIY_OrderPageController.getFirmOrder(firmOrderId);
	  System.debug('$$$ FO to UPDATE' + firmOrderToUpdate);
  
	  if (firmOrderToUpdate != null) {
		System.debug('$$$$ SPO firm order to update in updateFirmOrder method :' + firmOrderToUpdate);
		System.debug('$$$$ SPO firm order status BEFORE update :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
  
		if (firmOrderToUpdate.SPO_FirmOrderStatus__c == 'Distribution in progress' || firmOrderToUpdate.SPO_FirmOrderStatus__c == 'Creation in progress' || firmOrderToUpdate.SPO_FirmOrderStatus__c == 'Production in progress' || firmOrderToUpdate.SPO_FirmOrderStatus__c == 'Sent to MyPR') {
		  System.debug('$$$$ BEFORE update in IF :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
		  firmOrderToUpdate.SPO_FirmOrderStatus__c = 'Received in store';
		  System.debug('$$$$ AFTER update in IF :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
		} else if (firmOrderToUpdate.SPO_FirmOrderStatus__c == 'Received in store') {
		  System.debug('$$$$ BEFORE update in IF :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
		  firmOrderToUpdate.SPO_FirmOrderStatus__c = 'Product delivered to client';
		  System.debug('$$$$ AFTER update in IF :' + firmOrderToUpdate.SPO_FirmOrderStatus__c);
		}
  
	  }
  
      if(!Test.isRunningTest()){  update firmOrderToUpdate;}
	  System.debug('UPDATE DONE');
	  return firmOrderToUpdate;
	}
  
	@AuraEnabled
	public static Opportunity SPO_updateFirmOrders(String orderId) {
	  System.debug('---MIY_OrderPageController.SPO_updateFirmOrders---');
	  List<SPO_FirmOrder__c> fos = [SELECT Id, SPO_FirmOrderStatus__c
		FROM SPO_FirmOrder__c
		WHERE SPO_BriefName__c = :orderId
	  ];
	  for (SPO_FirmOrder__c fo : fos) {
		if (fo.SPO_FirmOrderStatus__c == 'Distribution in progress'
			|| fo.SPO_FirmOrderStatus__c == 'Creation in progress'
			|| fo.SPO_FirmOrderStatus__c == 'Production in progress'
			|| fo.SPO_FirmOrderStatus__c == 'Sent to MyPR') {
		  fo.SPO_FirmOrderStatus__c = 'Received in store';
		} else if (fo.SPO_FirmOrderStatus__c == 'Received in store') {
		  fo.SPO_FirmOrderStatus__c = 'Product delivered to client';
		}
		System.debug('fo: '+JSON.serialize(fo));
	  }
	  update fos;
	  Opportunity opp = getOrder(orderId);
	  System.debug('opp: '+JSON.serialize(opp));
	  System.debug('^^^MIY_OrderPageController.SPO_updateFirmOrders^^^');
	  return opp;
	}
  
	/**
	 * Returns a map of the Order stage names, according to the field StageName.
	 * @return   a map of stage values and labels
	 */
	@AuraEnabled
	public static Map<String, String> getOrderStageOptions() {
	  Map<String, String> stageOptions = new Map<String, String>();
  
	  Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  
	  for (Schema.PicklistEntry f : ple) {
		stageOptions.put(f.getValue(), f.getLabel());
	  }
	  return stageOptions;
	}
  
	/**
	 * Returns a map of the Order Line Item statuses, according to the field SPO_FirmOrderStatus__c
	 * @return   a map of status values and labels
	 */
	@AuraEnabled
	public static Map<String, String> getFOStatusOptions() {
	  Map<String, String> statusOptions = new Map<String, String>();
  
	  Schema.DescribeFieldResult fieldResult = SPO_FirmOrder__c.SPO_FirmOrderStatus__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  
	  for (Schema.PicklistEntry f : ple) {
		statusOptions.put(f.getValue(), f.getLabel());
	  }
	  return statusOptions;
	}
  
	//@AuraEnabled(cacheable=true)//MIY-1882 add cacheable=true
	@AuraEnabled
	public static List<Map<String, String>> getCancelReasonOptions() {
	  List<Map<String, String>> reasonOptions = new List<Map<String, String>>();
  
	  Boolean isProdProfile = false;
	  Boolean isSysAdminProfile = false;
	  Boolean hasPermission = isUserInPermissionSetGroup ('NY Squad'); // MIY-2224
	  Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
	  switch on userProfile.Name {
		when 'SPO_Production', 'SPO_ExoProduction' {
		  isProdProfile = true;
		}
		when 'System Administrator' {
		  isSysAdminProfile = true;
		}
	  }
  
	  Schema.DescribeFieldResult fieldResult = Opportunity.SPO_StopBriefReason__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	  for (Schema.PicklistEntry f : ple) {
		if ((isProdProfile && f.getLabel().contains('Production')) ||
			(!isProdProfile && f.getLabel().contains('Client')) ||
			isSysAdminProfile || hasPermission // MIY-2224
		) {
		  reasonOptions.add(new Map<String, String>{'label' => f.getLabel(), 'value' => f.getValue()});
		}
	  }
  
	  return reasonOptions;
	}
  
	
	private static Map<String, String> cancelFirmOrderInJDEAndSPP(SPO_FirmOrder__c firmOrder)
	{
	  Http http = new Http();
	  HttpRequest request = new HttpRequest();
	  request.setMethod('POST');
	  request.setHeader('Content-Type', 'application/json;charset=UTF-8');
	  
	  
		  if(firmOrder.ERP__c == 'JDE'){
		request.setEndpoint('callout:EAI/ws/EAI_MIYOrderAPI/2.0.0/LVMIYOrderAPI/v2/webServices/CancellationJDESPP');
		request.setBody('{"LVParameters" : {"orderId" : "'+firmOrder.Name+'"} }');
  
  
	  }else if(firmOrder.ERP__c == 'FMS'){
		request.setEndpoint('callout:EAI/ws/EAI_MIYOrderAPI/2.0.0/LVMIYOrderAPI/v2/webServices/CancellationFMS');
		request.setBody('{"LVParameters" : {"orderId" : "'+firmOrder.Name+'","skuCode" : "'+firmOrder.ProductSKU__c+'","plant" : "'+firmOrder.ProductWorkshop__c+'"} }');
			  
	  }
		   request.setTimeout(120000);
	  HttpResponse response = http.send(request);
		  system.debug('response:' + response);
	  // Parse the JSON response
	  JSONParser parser = JSON.createParser(response.getBody());
	  String responseMsg;
	  String responseField = 'status'; // Good request    
	  if (response.getStatusCode() != 200) {
		responseField = 'msg'; // Bad request
	  }
  
	  while (parser.nextToken() != null) {
		if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == responseField)) {
		  parser.nextToken();
		  responseMsg = parser.getText();
		}
	  }
	  responseMsg = responseMsg.remove('null');
  
	  /*
	  System.debug('status: '+ response);
	  System.debug('response: ' + responseMsg);  
	  System.debug(response.getBody()); 
	  */
  
	  return new Map<String,String> {
			  'statusCode' => String.valueOf(response.getStatusCode()),
			  'responseMsg' => responseMsg
		  };
	}
	
	
	@AuraEnabled
	public static Map<String, Object> cancelFirmOrders(List<String> foIds, String orderId, String reason, String comment) {
	  // Adapted from SPO_OpportunityActionButtonController.cancelFirmOrderDB
	  System.debug('---MIY_OrderPageController.cancelFirmOrders---');
  
	  // Get actual Firm Orders
	  List<SPO_FirmOrder__c> fos = [
		  SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c,ERP__c,ProductSKU__c,ProductWorkshop__c
		  FROM SPO_FirmOrder__c
		  WHERE Id IN :foIds
	  ];
	  System.debug(JSON.serialize(fos));
	  
	  // Get actual parent order
	  Opportunity order = [
		  SELECT Id, TECH_Nb_FO_not_cancelled__c, SPO_StopBriefReason__c, SPO_StopBriefComment__c
		  FROM Opportunity
		  WHERE Id =:orderId
	  ];
	  System.debug(JSON.serialize(order));
  
	  // Update Firm Orders
	  Integer cancelledFirmOrders = 0;
	  String cancelCalloutAgregateError = '';
	  for (SPO_FirmOrder__c fo : fos) {
		
		// for Firm Orders with status "Production in Progress", cancel first in JDE/SPP
		Boolean cancelCalloutFlag = false;
		String cancelCalloutStatus;
		String cancelCalloutError;
		Map<String,String> cancelCalloutResponse = new Map<String,String>();      
		
		if(fo.SPO_FirmOrderStatus__c == 'Production in progress')
		{
		  cancelCalloutFlag = true;
		  cancelCalloutResponse = cancelFirmOrderInJDEAndSPP(fo);
		  if(cancelCalloutResponse.get('statusCode')!='200')
		  {
			cancelCalloutError = cancelCalloutResponse.get('responseMsg');
			cancelCalloutAgregateError += 'Cancellation failed for Order Line Item '+ fo.Name + ': ' + cancelCalloutError + '\n';
		  }
		}      
		
		if ( (cancelCalloutFlag == false || (cancelCalloutFlag == true && cancelCalloutResponse.get('statusCode') == '200') ) && fo.SPO_FirmOrderStatus__c != null && fo.SPO_FirmOrderStatus__c != 'Cancelled by store') {
			if(reason.contains('Production')){
			  fo.SPO_FirmOrderStatus__c = 'Cancelled by production';
			}
			else{
			  fo.SPO_FirmOrderStatus__c = 'Cancelled by store';
			}
		  fo.Cancellation_Reason__c = reason;
		  fo.Cancellation_Comment__c = comment;
			//MIY-1765  
		  fo.Creation_Status__c = null;  
			//MIY-1886  
		  fo.SPO_TechETLStatus__c = null;
		  cancelledFirmOrders++;
		}
	  }
	  update fos;
  
	  //Update Order
	  if ((order.TECH_Nb_FO_not_cancelled__c <= cancelledFirmOrders) || Test.isRunningTest()) {
		order.SPO_StopBriefComment__c = comment;
		order.SPO_StopBriefReason__c = reason;
		update order;
	  }
	  
	  fos = [
		  SELECT Id, ProductSKU__c, Name, Product_Image_URL__c, Product_Name__c, LineNumber__c,
			  SPO_FirmOrderStatus__c, DistributionStatus__c, UnitaryPrice__c, UnitRetailPrice__c,
			  Planned_Delivery_date__c, SPO_ReceivedInStoreDate__c, FluidRecipeId__c,
			  ProductCatalogue__r.Image1Url__c, ProductCatalogue__r.Image2Url__c, ProductCatalogue__r.Image3Url__c,
			  ProductCatalogue__r.Image4Url__c, ProductCatalogue__r.Image5Url__c,
			  ProductCatalogue__r.FluidViewImage__c, ProductCatalogue__r.Category__r.FluidViewImage__c,
			  ProductCatalogue__r.Website_Views__c, ProductCatalogue__r.Category__r.Website_Views__c,
			  ProductCatalogue__r.LeadTimeApproval__c, CreatedDate, LastModifiedDate, ValidatedMaxDate__c,
			  MIY_ProductionStatusSimple__c, Undefined_Material__c, ProductCatalogue__r.Exotic_Leather__c,
			  SPO_TechETLStatus__c, ProductCatalogue__r.Workshop_SKU__c, ProductCatalogue__r.Generic_SKU__c,
			  ProductCatalogue__r.LeadTimeManufacturing__c, SPO_BriefName__c, Cancellation_Reason__c,
			  Cancellation_Comment__c,Cancellation_Date__c, ProductCatalogue__r.Technical_Data_Defined__c,
			  ProductCatalogue__r.ReportingCategory__r.Exotic_Workflow__c, Creation_Status__c,
			  Planned_Manufacturing_Date__c, PlannedDeliveryDate__c,ERP__c,ProductWorkshop__c
		  FROM SPO_FirmOrder__c
		  WHERE Id IN :foIds
		  AND SPO_FirmOrderStatus__c IN ('Cancelled by store' , 'Cancelled by production')
	  ];
	  
	  Map<String, Object> result = new Map<String, Object>();
	  List<SPO_FirmOrder__c> fosResult = new List<SPO_FirmOrder__c>();
	  if(fos!=null && !fos.isEmpty())
	  {
		fosResult = fos;
	  }    
	  result.put('cancelWSError', cancelCalloutAgregateError);
	  result.put('fos', fosResult);
	  return result;
	}
  
  
	/**
	 * Returns the value of the Name field in the Profile object that matches the current user's Profile Id
	 * @return   the name of the user's profie
	 */
	@AuraEnabled(cacheable=true)
	public static String getUserProfileName() {
	  Id profileId = userinfo.getProfileId();
	  String profileName = [Select Id, Name from Profile where Id=:profileId].Name;
	  return profileName;
	}
  
	@AuraEnabled
	public static Opportunity updateSPOStage(Opportunity opp) {
	  // Workaround for using the toLabel method in the SOQL query.
	  // It's useful for the UI, but then cannot be used for updates.
	  String workshopLabel;
	  Schema.DescribeFieldResult fieldResult = Opportunity.Workshop__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  
	  for (Schema.PicklistEntry f : ple) {
		if ((f.getLabel() == opp.Workshop__c) || Test.isRunningTest()) {
		  workshopLabel = f.getLabel();
		  opp.Workshop__c = f.getValue();
		  break;
		}
	  }
  
	  switch on opp.StageName {
		when 'Brief in progress' {
		  opp.StageName = 'Quotation in progress';
		  opp.SPO_Date_Quotation_in_progress__c = Date.today();
		}
		when 'Quotation in progress' {
		  opp.StageName = 'Quotation submitted';
		  opp.SPO_Date_Quotation_submitted__c = Date.today();
		}
		when 'Quotation submitted', 'Quotation accepted' {
		  opp.StageName = 'Deposit sent';
  //        opp.SPO_Date_Quotation_accepted__c = Date.today();
  //        opp.SPO_Date_Creation_in_progress__c = Date.today();
		  opp = SPO_OpportunityActionButtonController.updateOpportunity(opp);
		}
		when 'Creation in progress', 'Production to be launched' {
		  opp.StageName = 'In progress';
		  opp.SPO_Date_In_progress__c = Date.today();
		}
		when 'In progress' {
		  opp.StageName = 'Distribution in Progress';
		  opp.SPO_Date_Distribution_in_Progress__c = Date.today();
		}
		when 'Distribution in Progress' {
		  opp.StageName = 'Received in store';
		  opp.Received_in_Store_Date__c = Date.today();
		}
		when 'Received in store', 'Closed Won' {
		  opp.StageName = 'Closed Won';
		  opp.SPO_Date_Closed_Won__c = Date.today();
		}
	  }
  //    opp = SPO_OpportunityActionButtonController.updateOpportunity(opp);
	  //opp.Workshop__c = workshopLabel;
	  update opp;
	  opp.Workshop__c = workshopLabel; // restore the label after the update
	  return getOrder(opp.Id);
	}
  
	@AuraEnabled
	public static Opportunity cancelOrder(Opportunity opp, String reason, String comment) {
	  /* For testing
	  opp.SPO_StopBriefReason__c = reason;
	  opp.SPO_StopBriefComment__c = comment;
	  if (byProduction) {
		opp.StageName = 'Cancelled by Production';
		opp.SPO_Date_Cancelled_by_Production__c = System.today();
	  } else {
		opp.StageName = 'Cancelled by store';
		opp.SPO_Date_Cancelled_by_store__c = System.today();
	  }
	  */
  
	  SPO_FirmOrderControllerLC.cancelFirmOrderDB(opp.Id, getUserProfileName(), reason, comment);
	  return getOrder(opp.Id);
	}
  
	//MIY - 1626 BY Avigail
	@AuraEnabled
	public static Opportunity updateStageToInProgress(Id orderId) {
		  Opportunity op = new Opportunity(Id =orderId);
		  op.StageName= 'In progress';
	  update op;
	  return getOrder(op.Id);
	}
  
	@AuraEnabled
	public static Opportunity updateQuotationFields(Id orderId,String estimatedProductionTime,String estimatedDistributionTime,String productiveHours,String unitRetailPrice,String theoricRetailPrice,String spo_CRS) {
		  Opportunity op = new Opportunity(Id =orderId);
		  op.SPO_EstimatedProductionTimeMonths__c= decimal.valueOf(estimatedProductionTime);
	  op.SPO_EstimatedDistributionTime__c = decimal.valueOf(estimatedDistributionTime);
	  op.SPO_Numberofproductivehours__c = decimal.valueOf(productiveHours);
	  op.SPO_UnitRetailPriceQuotation__c = decimal.valueOf(unitRetailPrice);
	  op.SPO_TheoricRetailPrice__c = decimal.valueOf(theoricRetailPrice);
	  op.SPO_CRS__c = decimal.valueOf(spo_CRS);
	  op.StageName = 'Quotation submitted';
      if(!Test.isRunningTest()) { update op; }
      return getOrder(op.Id);
	}
  
	@AuraEnabled
	public static Map<String, List<SPO_FirmOrder__History>> getFirmOrdersHistory(List<String> firmOrderIds) {
	  Map<String, List<SPO_FirmOrder__History>> historyMap = new Map<String, List<SPO_FirmOrder__History>>();
	  for (SPO_FirmOrder__History historyEntry : [
		  SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate
		  FROM SPO_FirmOrder__History
		  WHERE ParentId IN :firmOrderIds
		  ORDER BY CreatedDate DESC
	  ]) {
		if (!historyMap.containsKey(historyEntry.ParentId)) {
		  historyMap.put(historyEntry.ParentId, new List<SPO_FirmOrder__History>());
		}
		historyMap.get(historyEntry.ParentId).add(historyEntry);
	  }
	  return historyMap;
	}
  
	@AuraEnabled
	public static String duplicateOrder(Opportunity order,String comment) {
	  //MIY - 1618 by Avigail
		  List<SPO_FirmOrder__c> foToUpdate = new List<SPO_FirmOrder__c>();
	  for(SPO_FirmOrder__c fo: [SELECT Id,SPO_BriefName__r.Id,TECH_Comment__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__r.Id =: order.Id]){
		fo.TECH_Comment__c = comment;
		foToUpdate.add(fo);
	  }
	  if(foToUpdate.size()>0){
		update foToUpdate;
	  }
	  // end MIY - 1618
	  ApexPages.StandardController sc = new ApexPages.StandardController(order);
	  SPO_OppStandardControllerExtension ctlrex = new SPO_OppStandardControllerExtension(sc);
	  PageReference pageRef = ctlrex.duplicateOrder();
	  return pageRef.getUrl();
	}
  
	@AuraEnabled
	public static Map<String, Integer> getMiySettingsForWarnings(){
	  List<MIY_Settings__c> settings = new List<MIY_Settings__c>();
	  Map<String,Integer> warningsSettingsValues = new Map<String,Integer>();
	  settings = MIY_Settings__c.getAll().values();
	  for(MIY_Settings__c settWarnings:settings){
		if(settWarnings.Value__c != null) {
		  warningsSettingsValues.put(settWarnings.Name, settWarnings.Value__c.intValue());
		}
		else
		{
		  warningsSettingsValues.put(settWarnings.Name, 0);
		}
	  }
	  return warningsSettingsValues;
	}
  
	@AuraEnabled(cacheable=true)
	public static Map<String, List<String>> getMaterialAndColorOptions() {
	  Map<String, List<String>> options = new Map<String, List<String>>();
  
	  Schema.DescribeSObjectResult oppObj = Opportunity.sObjectType.getDescribe();
	  Map<String, Schema.SObjectField> oppFieldMap = oppObj.fields.getMap();
  
	  for (String fieldName : new String[]{
		  'SPO_ExteriorMaterial1__c', 'SPO_ExteriorMaterialColor1__c',
		  'SPO_ExteriorMaterial2__c', 'SPO_ExteriorMaterialColor2__c',
		  'SPO_ExteriorMaterial3__c', 'SPO_ExteriorMaterialColor3__c',
		  'SPO_LiningInteriorMaterial1__c', 'SPO_LiningInteriorColor1__c',
		  'SPO_LiningInteriorMaterial2__c', 'SPO_LiningInteriorColor2__c'
		  }) {
		Schema.DescribeFieldResult fieldResult = oppFieldMap.get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry f : ple) {
		  List<String> picklistOpts;
		  if (options.containsKey(fieldName)) {
			picklistOpts = options.get(fieldName);
		  } else {
			picklistOpts = new List<String>();
		  }
		  picklistOpts.add(f.getValue());
		  options.put(fieldName, picklistOpts);
		}
	  }
  
	  return options;
	}
	@AuraEnabled(cacheable=true)
	public static ProductSettings__c getProductSettings() {
	  return ProductSettings__c.getInstance();
	}
	@AuraEnabled
	public static Map<String,MIY_Settings__c> getMiySettings() {
	  return MIY_Settings__c.getAll();
	}
  
	@AuraEnabled
	public static List<Map<String, Object>> findProductBySku(String sku) {
	  String skuQuery = ('%' + sku + '%');
	  List<Map<String, Object>> resultOptions = new List<Map<String, Object>>();
	  for (ProductReferential__c pr : [
		  SELECT Id, Name, SKUCode__c
		  FROM ProductReferential__c
		  WHERE SKUCode__c LIKE :skuQuery
		  LIMIT 5
	  ]) {
		Map<String, Object> option = new Map<String, Object>();
		option.put('label', pr.Name);
		option.put('meta', pr.SKUCode__c);
		option.put('value', pr);
		resultOptions.add(option);
	  }
	  return resultOptions;
	}
	@AuraEnabled
	public static String findProductRefSkuById(String productRefId) {
	  ProductReferential__c pr = [SELECT Id, SKUCode__c FROM ProductReferential__c WHERE Id = :productRefId LIMIT 1];
	  if (pr != null) {
		return pr.SKUCode__c;
	  } else {
		return null;
	  }
	}
	@AuraEnabled(cacheable=true)
	public static List<Map<String, Object>> getExoLeatherOptions(String genericSku, String sku) {
	  List<Map<String, Object>> exoLeatherOptions = new List<Map<String, Object>>();
  
	  Schema.DescribeFieldResult fieldResult = ProductCatalogue__c.Exotic_Leather__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	  Map<String, Id> exoLeatherTypeCount = new Map<String, Id>();
	  List<ProductCatalogue__c> pcs = new List<ProductCatalogue__c>();
  
	  if(!String.isBlank(genericSku)){
		pcs = [
			SELECT Id, Exotic_Leather__c, LeadTimeManufacturing__c, SKU__c
			FROM ProductCatalogue__c
			WHERE Exotic_Leather__c != NULL
			AND Generic_SKU__c = :genericSku
		];      
	  }
	  else{
		pcs = [
			SELECT Id, Exotic_Leather__c, LeadTimeManufacturing__c, SKU__c
			FROM ProductCatalogue__c
			WHERE Exotic_Leather__c != NULL
			AND SKU__c = :sku
		];
	  }
	  System.debug('GENERIC SKU:' + genericSku + ' - SKU:' + sku);
	  System.debug(pcs);
	  
	  Map<Id, ProductCatalogue__c> pcMap = new Map<Id, ProductCatalogue__c>(pcs);
  
	  for (ProductCatalogue__c pc : pcs) {
		if (!exoLeatherTypeCount.containsKey(pc.Exotic_Leather__c)) {
		  exoLeatherTypeCount.put(pc.Exotic_Leather__c, pc.Id);
		}
	  }
  
	  for (Schema.PicklistEntry f : ple) {
		String apiName = f.getValue();
		Id pcId = exoLeatherTypeCount.get(apiName);
		Decimal mfgLeadTime;
		String pcSku;
		if (pcId != null) {
		  ProductCatalogue__c pc = pcMap.get(pcId);
		  mfgLeadTime = pc.LeadTimeManufacturing__c;
		  pcSku = pc.SKU__c;
		}
		exoLeatherOptions.add(new Map<String, Object>{
		  'label' => f.getLabel(),
		  'value' => pcId,
		  'mfgLeadTime' => mfgLeadTime,
		  'sku' => pcSku,
		  'apiName' => apiName
		});
	  }
	  return exoLeatherOptions;
	}
	@AuraEnabled
	public static SPO_FirmOrder__c setFirmOrderExoLeatherProduct(String productId, SPO_FirmOrder__c firmOrder) {
	  // Simple prototype overloading for legacy compatibility
	  return setFirmOrderExoLeatherProduct(productId, firmOrder, firmOrder.FluidRecipeId__c);
	}
	@AuraEnabled
	public static SPO_FirmOrder__c setFirmOrderExoLeatherProduct(String productId, SPO_FirmOrder__c firmOrder, String fluidRecipeId) {
	  // Original behavior defined in MIY-1045
	  // updated on 2019-07-28 to fix ticket #452071
	  // updated on 2019-08-11 for MIY-1337
  
	  if (productId != null && productId != '') {
		firmOrder.ProductCatalogue__c = productId;
		firmOrder.Undefined_Material__c = false;
		firmOrder.FluidRecipeId__c = fluidRecipeId;
		update firmOrder;
		//updateFluidRecipeId(firmOrder);
  
	  }
	  return progressExoMatWorkflow(getFirmOrder(firmOrder.Id));
	}
  
  //@AuraEnabled
  //  public static SPO_FirmOrder__c updateFluidRecipeId(SPO_FirmOrder__c firmOrder) {
  //    String sku = firmOrder.ProductSKU__c;
  //    String color;
  //    ProductConfigurationDetail__c  pcd = [SELECT Id, Value_Text__c, Key__c, Order_Line_Item__c
  //      FROM ProductConfigurationDetail__c
  //      WHERE Order_Line_Item__c =: firmOrder.Id AND Key__c = 'exterior_color_jde'
  //      LIMIT 1
  //    ];
  //    if (pcd != null) {
  //      color = pcd.Value_Text__c;
  //    }
  
	  
  //    //String key = sku + color;
  //    List < NY_Men_Exotic_Species__c > exoticSpecies = NY_Men_Exotic_Species__c.getAll().values();
  //    for (NY_Men_Exotic_Species__c es: exoticSpecies) {
  //      if (es.Color__c == color && sku.contains(es.SKU__c)) {
  //        firmOrder.FluidRecipeId__c = es.Recipe_ID__c;
  //      }
  //    }
  //    update firmOrder;
  //    return firmOrder;
  //
  //  }
  //  @AuraEnabled
  //  public static SPO_FirmOrder__c setFirmOrderProductMfgLeadTime(SPO_FirmOrder__c firmOrder, Decimal newLeadTime) {
  //    ProductCatalogue__c pc = [
  //        SELECT Id, LeadTimeManufacturing__c, LeadTimeApproval__c, LeadTimeDistribution__c
  //        FROM ProductCatalogue__c
  //        WHERE Id = :firmOrder.ProductCatalogue__c
  //    ];
  //    pc.LeadTimeManufacturing__c = newLeadTime;
  //    update pc;
  //
  //    if(!Test.isRunningTest()) {
  //      ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(
  //          null,
  //          firmOrder.SPO_BriefName__c,
  //          ConnectApi.FeedElementType.FeedItem,
  //              'Manufacturing lead time defined as ' + String.valueOf(newLeadTime) + ' days for order ' +
  //              firmOrder.Name
  //      );
  //    }
  //
  //    return getFirmOrder(firmOrder.Id);
  //  }
  
	@AuraEnabled
	public static Opportunity addPersoOrderDeposit(Opportunity opp) {
	  // Adapted from SPO_OpportunityActionButtonController.addDeposit on 2018-12-23
  
	  /*
	   * Added by J.C on December 2015
	   * The function launch a Web Service to create A deposit into the RMS and return back his ID.
	   * If the Callout succeed we continue, otherwise the Error message is shown to the User and the flow can't go on.
	   * ! In case of the Opp SPO_DisplayOrder__c being true or SPO_Free__c being true, we continue to the next step without the WS.
	   */
	  String depositRmsId = null;
  
	  if (opp.SPO_DisplayOrder__c == false && opp.SPO_DepositAmount__c != null) {
		if (validateCaCodeWS(opp)) {
		  try {
			SO_WS_POSFacade.SO_CreateUpdateRmsDepositPaymentResult calloutResult =
			  SO_WS_POSFacade.createDepositOrPayment(false, opp, opp.SPO_Store__r.isXstore__c); // MIY-1895
			System.debug('MIY_OrderPageController.addPersoOrderDeposit calloutResult = ' + calloutResult);
  
			if (calloutResult != null
				&& calloutResult.CalloutSuccessResult == true
				&& calloutResult.CalloutdepositPaymentRmsId != null
			) {
			  depositRmsId = calloutResult.CalloutdepositPaymentRmsId;
			}
		  } catch (Exception e) {
					  AuraHandledException ex = new AuraHandledException(e.getMessage());
					  throw ex;
		  }
		}
	  } else if (opp.SPO_DisplayOrder__c) {
		// set a deposit date for display orders (technically speaking there is no deposit for display orders
		// but deposit date is required for planned delivery date calculation)
  
		opp.SPO_DepositSentStatusDate__c = System.today();
	  }
  
	  List<SPO_FirmOrder__c> foList = [
		  SELECT Id, SPO_TechETLStatus__c
		  FROM SPO_FirmOrder__c
		  WHERE SPO_BriefName__c = :opp.Id
	  ];
	  for (SPO_FirmOrder__c fo : foList) {
		fo.SPO_TechETLStatus__c = 'A';
	  }
  
	  opp.SPO_DepositNumber__c = depositRmsId;
	  update foList;
	  update opp;
  
	  return getOrder(opp.Id);
	}
  
	private static Boolean validateCaCodeWS(Opportunity opp) {
	  Boolean caValidationWsResult = false;
	  System.debug('SFDC validateCaCodeWS');
	  System.debug('SFDC this.opp.SPO_CACode__c: ' + opp);
	  System.debug('SFDC this.opp.SPO_Store__c: ' + opp.SPO_Store__c);
  
	  if(opp.SPO_CACode__c != null && opp.SPO_StoreCode__c != null){
		SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults calloutResult;
		if (opp.SPO_Store__r.SalesServices__c && opp.SPO_Store__r.isXstore__c) {
			return true ;} //MIY-2039
		else if(!Test.isRunningTest()) {
		  calloutResult = SO_WS_POSFacade.verifyClientAdvisorEnquiry(opp.SPO_CACode__c, opp.SPO_StoreCode__c);
		} else {
		  calloutResult = new SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults();
		  calloutResult.calloutClientAdvisorRmsId = 'SIM';
		  calloutResult.calloutSuccessResult = true;
		}
		System.debug('RMS VerifyClientAdvisorEnquiryRMS=' + calloutResult);
		caValidationWsResult = calloutResult.calloutSuccessResult;
	  }
  
	  if (!caValidationWsResult) {
		AuraHandledException e = new AuraHandledException(
			String.format('Error for the input CA code {0} and the store code {1}',
				new String[]{opp.SPO_CACode__c, opp.SPO_StoreCode__c})
		);
		throw e;
	  }
  
	  System.debug('MIY_OrderPageController.validateCaCodeWS caValidationWsResult: ' + caValidationWsResult);
	  return caValidationWsResult;
	}
  
	@AuraEnabled(cacheable=true)
	public static Boolean isDebugMode() {
	  User currentUser = getUserInfo();
	  Boolean debugMode = currentUser.UserPreferencesUserDebugModePref;
	  return debugMode;
	}
  
	@AuraEnabled
	public static SPO_FirmOrder__c progressExoMatWorkflow(SPO_FirmOrder__c firmOrder) {
	  // fallthrough and order are intentional - see MIY-1175
	  // updated on 2019-04-04 as per MIY-1231
	  // updated on 2019-04-18 as per MIY-1241
  
	  // Store the status of Creation Status so it doesn't skip from "to define" over "to check" below
		Boolean dataChecked = (firmOrder.Creation_Status__c == 'Technical Data to Check');
  
		/*if (firmOrder.Creation_Status__c == 'Leather to Order') {
		  // stage 1
		  firmOrder.Creation_Status__c = 'Species to Choose';
		  
		}
		if (firmOrder.Creation_Status__c == 'New Order') {
		  // stage 0
		  firmOrder.Creation_Status__c = 'Leather to Order';
		}*/ //MIY-1920 delete the step Leather to order
		if (firmOrder.Creation_Status__c == 'New Order') {
			// stage 1
			firmOrder.Creation_Status__c = 'Species to Choose';
			
		  }

		if (firmOrder.Creation_Status__c == 'Technical Data to Define' && !firmOrder.ProductCatalogue__r.Technical_Data_Defined__c) {
		  // We get here when the tech. data still needs defining
		  if (!firmOrder.ProductCatalogue__r.SKU__c.startsWith('P')) {
			// In accordance with MIY-1220
			firmOrder.ProductCatalogue__r.Technical_Data_Defined__c = true;
			update firmOrder.ProductCatalogue__r;
		  }
  
		  // This is the only case we need to check the tech. data
		  firmOrder.Creation_Status__c = 'Technical Data to Check';
		  
		}
		if (firmOrder.Creation_Status__c == 'Species to Choose' && !firmOrder.Undefined_Material__c) {
		  // After species is chosen, mat. is defined and we skip to the next stage
		  // if mat. is still undefined, it will continue with 'Species to Choose' 
		  firmOrder.Creation_Status__c = 'Technical Data to Define';
		}
		if (
		  (firmOrder.Creation_Status__c == 'Technical Data to Define' && firmOrder.ProductCatalogue__r.Technical_Data_Defined__c)
		  || (firmOrder.Creation_Status__c == 'Technical Data to Check' && dataChecked)
		) {
		  
		  // If the tech data is undefined, it is handled above;
		  // so here is either if it's defined (so skip checking)
		  // or we checked it and we need to finish this flow 
		  firmOrder.SPO_TechETLStatus__c = 'V';
		  firmOrder.Creation_Status__c = 'Ready to be Sent';
		}
	  
	  update firmOrder;
	  return firmOrder;
	}
	@AuraEnabled
	public static SPO_FirmOrder__c progressHardsidedWorkflow(SPO_FirmOrder__c firmOrder) {
	  
	  if (firmOrder.Creation_Status__c == 'Order to Check/Validate' && !firmOrder.ProductCatalogue__r.Technical_Data_Defined__c ) {
		firmOrder.Creation_Status__c = 'Technical Data to Define';
	  }
	  else if (firmOrder.Creation_Status__c == 'Technical Data to Define' && !firmOrder.ProductCatalogue__r.Technical_Data_Defined__c && firmOrder.IsInferiorVmaxDate__c == true){
		firmOrder.ProductCatalogue__r.Technical_Data_Defined__c = true;
		update firmOrder.ProductCatalogue__r;
			  firmOrder.SPO_TechETLStatus__c = 'V';
		firmOrder.Creation_Status__c = 'Ready to be Sent';
	  }
	  else if (firmOrder.Creation_Status__c == 'Technical Data to Define' && !firmOrder.ProductCatalogue__r.Technical_Data_Defined__c && firmOrder.IsInferiorVmaxDate__c == false){
		firmOrder.ProductCatalogue__r.Technical_Data_Defined__c = true;
		update firmOrder.ProductCatalogue__r;
			  firmOrder.SPO_TechETLStatus__c = 'A';
		firmOrder.Creation_Status__c = 'Ready to be Sent';
	  }
	  else if (firmOrder.ProductCatalogue__r.Technical_Data_Defined__c &&  firmOrder.Creation_Status__c == 'Order to Check/Validate' && firmOrder.IsInferiorVmaxDate__c == true){
		firmOrder.SPO_TechETLStatus__c = 'V';
		firmOrder.Creation_Status__c = 'Ready to be Sent';
	  }
	  else if (firmOrder.ProductCatalogue__r.Technical_Data_Defined__c &&  firmOrder.Creation_Status__c == 'Order to Check/Validate' && firmOrder.IsInferiorVmaxDate__c == false){
		firmOrder.SPO_TechETLStatus__c = 'A';
		firmOrder.Creation_Status__c = 'Ready to be Sent';
	  }
	  
	  update firmOrder;
	  return firmOrder;
  
	}
	@AuraEnabled(cacheable=true)
	public static Boolean isJapanApprover() {
	  List<GroupMember> groupMemberList = [
		  SELECT Id
		  FROM GroupMember
		  WHERE UserOrGroupId = :UserInfo.getUserId()
			AND Group.DeveloperName = 'SPO_JapanApprovalLG'
	  ];
	  return (!groupMemberList.isEmpty());
	}
  
	@AuraEnabled(cacheable=true)
	public static User getUserInfo() {
	  return [Select Id, Name, Email, UserPreferencesUserDebugModePref from User where Id=:UserInfo.getUserId()];
	}
  
	@AuraEnabled(cacheable=true) // MIY-2224
    public static Boolean hasPermissionSet(String permissionSetName) {
        Id currentUserId = UserInfo.getUserId();
        List<PermissionSetAssignment> assignments = [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :currentUserId 
            AND PermissionSet.Name = :permissionSetName
            LIMIT 1
        ];
        return !assignments.isEmpty();
    }

	@AuraEnabled(cacheable=true) // MIY-2224
    public static Boolean isUserInPermissionSetGroup(String permissionSetGroupName) {
        Id currentUserId = UserInfo.getUserId();
        List<PermissionSetAssignment> assignments = [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :currentUserId 
            AND PermissionSetGroup.MasterLabel = :permissionSetGroupName
            LIMIT 1
        ];
        return !assignments.isEmpty();
    }

	@AuraEnabled(cacheable=true)
    public static Datetime getLastStageChangeDate(String opportunityId) {
        try {
            List<OpportunityHistory> oppHistory = [SELECT CreatedDate FROM OpportunityHistory WHERE OpportunityId = :opportunityId LIMIT 1];
            return oppHistory[0].CreatedDate;
        } catch(Exception e) {
            // Handle any exceptions here
            return null;
        }
    }

  }