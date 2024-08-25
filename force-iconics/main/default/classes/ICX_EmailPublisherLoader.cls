// NOT WORKING IN LIGHTNING 
// Setup > Support Settings > "Enable Default Email Templates or the Default Handler for Email Action"
global class ICX_EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global ICX_EmailPublisherLoader() {
        System.debug('ICX_EmailPublisherLoader');
    }
    
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        System.debug('ICX_EmailPublisherLoader > onInitDefaults');
        /*QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
        
        // Check if the quick action is the standard Case Feed send email action
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
                defaults.get(j).getTargetSObject().getSObjectType() == 
                EmailMessage.sObjectType && 
                defaults.get(j).getActionName().equals('Case.Email') && 
                defaults.get(j).getActionType().equals('Email')) {
                    sendEmailDefaults = 
                        (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                    break;
                }
        }
        
        if (sendEmailDefaults != null) {
            Case c = [SELECT Status, Reason FROM Case 
                      WHERE Id=:sendEmailDefaults.getContextId()];
            
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();    
            // Set bcc address to make sure each email goes for audit
            emailMessage.BccAddress = getBccAddress(c.Reason);
            
            if (sendEmailDefaults.getInReplyToId() == null) {
                Integer emailCount = [SELECT count() FROM EmailMessage 
                                      WHERE ParentId=:sendEmailDefaults.getContextId()];
                if (emailCount!= null && emailCount > 0) {
                    sendEmailDefaults.setTemplateId(
                        getTemplateIdHelper('ICONiCS_Test'));//Automatic_Response'));
                } else {
                    sendEmailDefaults.setTemplateId(
                        getTemplateIdHelper('ICONiCS_Test'));//('New_Case_Created'));
                }
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(false);
            } else {
                sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('ICONiCS_Test'));//('Default_reply_template'));
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(true);
            }
        }*/
    }
    
    /*private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [select id, name from EmailTemplate 
                          where developername = : templateApiName].id;   
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' + 
                         templateApiName + ' refer to Setup | Communications Templates ' 
                         + templateApiName);
        }
        return templateId;
    }
    private String getBccAddress(String reason) {
        if (reason != null && reason.equals('Technical')) 
        { return 'support_technical@mycompany.com'; } 
        else if (reason != null && reason.equals('Billing')) 
        { return 'support_billing@mycompany.com'; } 
        else { return 'support@mycompany.com'; }
    }*/
}