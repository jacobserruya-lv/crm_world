global with sharing class BL_EMAIL_Sender extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST {
   
    global Object executePOST(){

        Object record = getRequestRecord();
        String application = (getQueryParameter('application') != null ? getQueryParameter('application') : null);

        return BL_EMAIL_Sender_Helper.sendEmail((Map<String, Object>) record, application);
    }
}


