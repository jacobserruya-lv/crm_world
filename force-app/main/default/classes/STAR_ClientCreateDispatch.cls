/** * File Name: STAR_ClientCreateDispatch
* Description : Dispatches to the standard Client edit Page layout for allowed Profiles
* @author : RMOU
* Modification Log =============================================================== 
* Sep 2016 / RMOU / PIPA Law enhancement
* */
public class STAR_ClientCreateDispatch {
    
    // Standard controller
    private ApexPages.StandardController controller;
    
    // Constructor
    public STAR_ClientCreateDispatch (ApexPages.StandardController controller){
        this.controller = controller;
    }
    
    public PageReference dispatch ()
    {
        PageReference result = null;
        // Star, Icon Users and Admins allowed to create rospects on desktop
        if (IC_Utils.IsStarCorporate() || IC_Utils.isICONSTARCorporate() || IC_Utils.isSA() || IC_Utils.isSystemAdmin()){
            // If allowed to edit Client's personal data
            if (IC_Factory.CanPIPACountryEditClient(IC_Utils.getUserCountry()))
            {
                // Get the Meta Data for Account  
                Schema.DescribeSObjectResult describeResult = controller.getRecord().getSObjectType().getDescribe();  
                // Create PageReference for creating a new sObject and add any inbound page parameters.  
                result = new PageReference('/' + describeResult.getKeyPrefix() + '/e?');
                Map<String, String> params = ApexPages.currentPage().getParameters();
                // Don't add save_new parameter to prevent session issues
               	params.remove('save_new');
                result.getParameters().putAll(params);
                
                result.setRedirect(true);
                // Bypass original override not to be redirected in a loop
                result.getParameters().put ('nooverride', '1');
            }
            else
            {
                result = new PageReference('/apex/IC_PIPARestrictedNewClient?');
                Map<String, String> params = ApexPages.currentPage().getParameters();
                result.getParameters().putAll(params);
            }
        }
        return result;
    }
}