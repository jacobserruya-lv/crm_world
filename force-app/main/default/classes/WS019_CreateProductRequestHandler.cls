/*
 * MYPR (MyProductRequest call)
 * createPR.wsdl is in SOAP 1.2. Salesforce WSDL2Apex supports SOAP 1.1.
 * soap12 tags commented in WSDL and just keep 1 wsdl:binding name="WSLV019.webService.v1_0_createPR_Binder_1" and 1 wsdl:port name="WSLV019.webService.v1_0_createPR_Port_1
 *
 * Update 2019-06-13: Changed firmOrderToUpdate to Map to debug issues with MIY-1283 - List was giving duplicate Id error
 * Update 2019-07-17: Refactored a lot of code to comply with new plan for MIY-1283
 */
public with sharing class WS019_CreateProductRequestHandler {

	@future(callout=true)
	public static void execute(Set<Id> firmOrderIdSet)
	{  
		Map<String,List<SPO_FirmOrder__c> > firmOrdersByStore = new Map<String, List<SPO_FirmOrder__c> >();
		Map<Id, SPO_FirmOrder__c> firmOrderToUpdate = new Map<Id, SPO_FirmOrder__c>();

		for (SPO_FirmOrder__c firmOrder : [ // MIY-1830  For ECO orders to be sent to MYPR ADDED ''SPO_BriefName__r.ApplicationSource__c = 'ECO' ''
			     SELECT Id,SPO_BriefName__r.SPO_StoreCode__c,ProductSKU__c,FirmOrderNumber__c,
			     SPO_BriefName__r.Account.Name, SPO_BriefName__r.SPO_CACode__c, SPO_BriefName__r.SPO_DisplayOrder__c
			     FROM SPO_FirmOrder__c
			     WHERE (IsProductRequest__c = true
                    AND Id IN :firmOrderIdSet) 
					OR (SPO_BriefName__r.ApplicationSource__c = 'ECO'  
                    AND Id IN :firmOrderIdSet) 
		     ]) {
			if (firmOrdersByStore.get(firmOrder.SPO_BriefName__r.SPO_StoreCode__c) == null)
			{  
				firmOrdersByStore.put(firmOrder.SPO_BriefName__r.SPO_StoreCode__c, new List<SPO_FirmOrder__c>());
			}
			firmOrdersByStore.get(firmOrder.SPO_BriefName__r.SPO_StoreCode__c).add(firmOrder);
		}

		System.debug('firmOrdersByStore: ' + firmOrdersByStore);
		for (String store : firmOrdersByStore.keySet())
		{ 
			for (SPO_FirmOrder__c firmOrder : firmOrdersByStore.get(store)) {
				WS019_CreateProductRequest.createPR myprCreate = createRequest(store, firmOrder);
				WS019_CreateProductRequest.WSLV019_webService_v1_0_createPR_Port_1 myprWS = new WS019_CreateProductRequest.WSLV019_webService_v1_0_createPR_Port_1();
				myprWS.endpoint_x = 'callout:EAI/ws/EAI_createPR/1.0.0'; // Setup > Named credentials > EAI
				myprWS.timeout_x = 12000;
				WS019_CreateProductRequest.createPRResponse myprResponse = myprWS.mainService(myprCreate);
				System.debug(myprResponse);
			
				if (myprResponse != null && myprResponse.createPRResponse != null) {
					if (myprResponse.createPRResponse.DataResponse != null) {
						for (WS019_CreateProductRequest.docTypeRef_reservationResponseLine responseLine : myprResponse.createPRResponse.DataResponse.reservationResponseLine) {
							System.debug('>> responseLine: ' + responseLine);
							SPO_FirmOrder__c firmOrderCopy = new SPO_FirmOrder__c(id=firmOrder.Id );
							if ('000'.equals(responseLine.errorCode)) {
								firmOrderCopy.SPO_TechETLStatus__c='Y';
								firmOrderCopy.MyPR_ID__c = responseLine.productRequestID;
							 	firmOrderCopy.IsProductRequest__c = true ; // MIY-1830  For ECO orders to be sent to MYPR
								firmOrderCopy.TECH_Comment__c = 'ProductRequest Id = '+ responseLine.productRequestID + ' - Estimated time of arrival = ' + responseLine.ETA;
							} else {
								System.debug('ERROR MyPR webservice responseLine=' + responseLine);
								// 102 - Product is not orderable
								if ('102'.equals(responseLine.errorCode)) {
									firmOrderCopy.SPO_TechETLStatus__c = '';
									firmOrderCopy.SPO_FirmOrderStatus__c = 'Cancelled by production';
								}	
								firmOrderCopy.TECH_Comment__c = 'MyPR ERROR: ' + responseLine.errorMessage + ' (' + responseLine.errorCode + ')';
							}
							firmOrderToUpdate.put(firmOrder.Id, firmOrderCopy);

						}
					} else if (myprResponse.createPRResponse.LvmHeaderResponse != null && String.isNotBlank(myprResponse.createPRResponse.LvmHeaderResponse.errorCode)) {
						// get global error 
						System.debug('ERROR MyPR webservice myprResponse.createPRResponse.LvmHeaderResponse=' + myprResponse.createPRResponse.LvmHeaderResponse);
						firmOrder.TECH_Comment__c = 'ERROR MyPR webservice: ' +
						                            myprResponse.createPRResponse.LvmHeaderResponse.errorCode + ' - ' +
						                            myprResponse.createPRResponse.LvmHeaderResponse.errorMessage;
						firmOrderToUpdate.put(firmOrder.Id, firmOrder);
					}
				}
			}
		}
		if (!firmOrderToUpdate.isEmpty()) {
			System.debug('firmOrderToUpdate=' + firmOrderToUpdate);
			update firmOrderToUpdate.values();
		}

	}


	// convert to format: 'YYYYMMDD HHMMSS'
	private static String convertDate(Datetime timeToChange) {
		String result;

		if (timeToChange != null) {
			String year = String.valueOf(timeToChange.year());
			String month = formatDigits(timeToChange.month());
			String day = formatDigits(timeToChange.day());

			String hour = formatDigits(timeToChange.hour());
			String minute = formatDigits(timeToChange.minute());
			String second = formatDigits(timeToChange.second());

			result = year + month + day + ' ' + hour + minute + second;
		}
		return result;
	}

	// format with 2 digits
	private static String formatDigits(Integer digit) {
		String result;

		if (digit != null) {
			result = String.valueOf(digit);
			if (digit < 10) {
				result = '0' + result;
			}
		}
		return result;
	}


	/**
	 * Update 2019-04-10: Modified to individual MyPR lines as per MIY-1283
     * Update 2019-07-17: Refactored a lot of code to comply with new plan for MIY-1283
	 */
	private static WS019_CreateProductRequest.createPR createRequest(String store, SPO_FirmOrder__c fo) {

		WS019_CreateProductRequest.createPR createPR = new WS019_CreateProductRequest.createPR();
		WS019_CreateProductRequest.createPR2 myprCreate = new WS019_CreateProductRequest.createPR2();
		createPR.createPR = myprCreate;
		myprCreate.LvmHeader = new WS019_CreateProductRequest.docTypeRef_LvmHeader();
		myprCreate.LvmHeader.version = '1.0';
		myprCreate.LvmHeader.consumer = 'SPO';

		WS019_CreateProductRequest.Data myprData = new WS019_CreateProductRequest.Data();

		WS019_CreateProductRequest.docTypeRef_reservationHeader myprHeader = new WS019_CreateProductRequest.docTypeRef_reservationHeader();
		myprHeader.storeCode = store;
		myprHeader.callingMode = 'SalesForce';
		myprHeader.localTimestamp = convertDate(System.now());
		myprData.reservationHeader = myprHeader;
		myprData.reservationLine = new List<WS019_CreateProductRequest.docTypeRef_reservationLine>();

		WS019_CreateProductRequest.docTypeRef_reservationLine myprLine = new WS019_CreateProductRequest.docTypeRef_reservationLine();
		myprLine.skuCode = fo.ProductSKU__c;
		myprLine.requestedQuantity = '1';
		string comment = 'Order number = ' + fo.FirmOrderNumber__c;
		if (fo.SPO_BriefName__r.SPO_DisplayOrder__c) {   // if parent order is a display order
			comment += ', Store Display' + ', CA Code = ' + fo.SPO_BriefName__r.SPO_CACode__c;
		} else {
			comment += ', Client = ' + fo.SPO_BriefName__r.Account.Name + ', CA Code = ' + fo.SPO_BriefName__r.SPO_CACode__c;
		}
		System.debug('>>> comment line: '+ comment);
		myprLine.comment = comment;
		myprData.reservationLine.add(myprLine);
		myprCreate.Data = myprData;

		return createPR;
	}
}