/**
 * Controller for ICX_Case_SpamButton Visualforce page
 * Difficult in Spring '18 to call a Lightning Component with a Custom button (Visualforce calls a Lightning App with ltng:outApp calling a Lightning Component with force:recordData)
 * In a Lightning Console, a Visualforce page can't manage the Javascript API with tabs methods. So, the Visualforce page tab stays open and it's difficult to redirect to the Case detail page in the same tab or close the tab
 * 
 * <aura:application extends="ltng:outApp">
 *   <aura:dependency resource="c:ICX_CaseSpam_Action" />
 *   <aura:dependency resource="markup://force:*" type="EVENT"/> <!-- useful to use event such as force:navigateToSObject event -->
 * </aura:application>
 **/
public class ICX_Case_SpamButtonController {
    
    private final Case cas;
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public ICX_Case_SpamButtonController(ApexPages.StandardController stdController) {
        
        //Skip blow line for test class else it will give error
        if(!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Status','Spam__c'});
        }
        this.cas = (Case) stdController.getRecord();
    }

    public PageReference updateCase() {
        //System.debug('updateCase');
        //System.debug('cas.Status/ cas.Spam__c:' + cas.Status  + ',' + cas.Spam__c);
        //if ('Closed' != cas.Status && !cas.Spam__c) {
        if ('New'.equals(cas.Status) && !cas.Spam__c) {
            cas.Spam__c = true;
            cas.SpamReason__c = 'Manual';
            update cas;
        }
        return new PageReference('/' + cas.Id);
    }
}