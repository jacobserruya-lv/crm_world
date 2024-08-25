public class ICX_Flow_AgentScriptController {

    public String languageCode {get; set;}
    public String labelName {get; set;}
    public String size {get; set;}
    public Boolean showCopyButton {get; set;}
    
    public ICX_Flow_AgentScriptController() {
        Map<String, String> params = System.currentPageReference().getParameters();
        this.languageCode = (params != null && String.isNotBlank(params.get('language')) ? params.get('language') : '' );
        this.labelName = (params != null && String.isNotBlank(params.get('label')) ? params.get('label') : '' );
        this.size = (params != null && String.isNotBlank(params.get('size')) ? params.get('size') : 'medium' );
        this.showCopyButton = (params != null && params.get('showCopyButton') != null ? Boolean.valueOf(params.get('showCopyButton')) : false);
        //languageCode = 'fr';
    }

    @AuraEnabled(cacheable=true)
    public static String getVisualforceHost() {
        return IconicsSettings__c.getInstance().VisualforceHost__c;
    }
}