@RestResource(urlMapping='/FinalizeOrderLine/*')
global with sharing class MIY_WS_FinalizeOrderLine {
	@HttpPost
	global static String doPost(String lineItemId) {
		SPO_FirmOrder__c lineItem = [
            SELECT Id, SPO_FirmOrderStatus__c 
            FROM SPO_FirmOrder__c 
            WHERE FirmOrderNumber__c = :lineItemId 
            LIMIT 1
        ];

        if (lineItem.SPO_FirmOrderStatus__c == 'Received in store') {
			lineItem.SPO_FirmOrderStatus__c = 'Product delivered to client';
            update lineItem;
		}

		return JSON.serialize(lineItem);
	}
}