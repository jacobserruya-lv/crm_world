@isTest
private class SO_QuotationContainer_TEST {
	
	@isTest static void testQuotationContainer() {
		SO_QuotationContainer qc = new SO_QuotationContainer();
		SO_UTIL.PickListWrapper plw = qc.productCategory;
		plw = qc.orderType;
		List<Attachment> attachmentListn = qc.attachmentList;
		String test = qc.opportunityOrderType;

	}
	

	
}