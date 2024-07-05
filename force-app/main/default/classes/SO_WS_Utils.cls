// BW - 2/01/2015

public with sharing class SO_WS_Utils {
	public static Boolean runForTest() {
		Boolean dontCall = false;
		SO_Settings__c WSCallNoCall = SO_Settings__c.getInstance('WSCallNoCall');
		if (WSCallNoCall != null) dontCall = (WSCallNoCall.Value__c.toLowercase().trim() == 'nocall');
		return dontCall;  	
	}
	
	public static String getEndPoint(String ws) {
		SO_Settings__c endPoint = SO_Settings__c.getInstance(ws);
		if (endPoint != null) return endPoint.Value__c.trim(); else return '';
	}

	public static Integer getWSTimeOut() {
		SO_Settings__c to = SO_Settings__c.getInstance('WSTimeOut');
		if (to != null) return Integer.valueOf(to.Value__c.trim()); else return 40000;
	}
}