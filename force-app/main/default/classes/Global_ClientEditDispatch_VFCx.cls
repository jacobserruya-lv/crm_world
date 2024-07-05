public class Global_ClientEditDispatch_VFCx {

  private ApexPages.StandardController controller;
    
    public Account currentAccount{get;set;}
  

    public Global_ClientEditDispatch_VFCx (ApexPages.StandardController stdController){

        controller = stdController; 
        this.currentAccount = (Account) stdController.getRecord();
        System.debug('Current Account : ' + this.currentAccount);

    }

    /*----------------------------------redirectToPage--------------------------------------
    // Creation: STI  03/09/2015
    //--------------------------------------------------------------------------------------
    // redirects user to appropriate client page according to user profile
    //--------------------------------------------------------------------------------------*/
    public PageReference redirectToPage() {

        try{
            System.Debug('Profile ID: ' + UserInfo.getProfileId());
            
            String userProfileId = UserInfo.getProfileId();
            
            // If ICON only user, redirects to IC_ClientEditDesktop page
            //ICON_Corporate, ICON_LV Administrator, ICON_LV_Country_Admin, ICON_SA, ICON_SA_Animator, ICON_SA_Manager
            if (IC_Utils.isCorporate()
              || IC_Utils.isLVAdmin()
              || IC_Utils.isLVCountryAdmin()
              || IC_Utils.isSA()
              || IC_Utils.isSAAnimator()
              || IC_Utils.isSAManager()) { 
        return new PageReference('/apex/IC_ClientEditDesktop?' + getParameters()); 
            
            // If STAR only user, redirects to STAR_ClientEditDesktop page
            // STAR_CORPORATE
            }else if (IC_Utils.isSTARCorporate()){
              return new PageReference('/apex/STAR_ClientEditDesktop?' + getParameters()); 
            
            // Else (ICON & STAR or other profile such as admins and technical profiles), redirects to IC_STAR_ClientEditDesktop page
            //Admin sys, ICON_Interface DREAM, ICON Monitoring, ICON_STAR_Corporate & any new profile
            }else{
              return new PageReference('/apex/IC_STAR_ClientEditDesktop?' + getParameters()); 
            }
        }
        catch(Exception e)
        {
            System.debug('=====================' + e.getTypeName());
            System.debug('=====================' + e.getCause());
            System.debug('=====================' + e.getMessage());
            return null;
        }     
    }

    /*----------------------------------getParameters --------------------------------------
    // Creation: STI  03/09/2015
    //--------------------------------------------------------------------------------------
    // builds a string containing parameters received in page
    // This string can be concatened after a url to send these parameters
    //--------------------------------------------------------------------------------------*/
    private String getParameters(){

        string param = '';
        try{
            //retrieving parameters
            Map<String, String> strMap = ApexPages.currentPage().getParameters();
            
            //list of parameters to retrieve
            String[] keys = new String[]{'retURL', 'cancelURL', 'Id'};
            //string building
            for(String s : keys){
                if(strMap.containsKey(S)) param += s + '=' +  strMap.get(s) + '&';
            }
            //deletion of extra "&"
            if(param.length() > 0) 
                param = param.substring(0, param.length()-1);
        }
        catch(Exception e)
        {
            System.debug('=====================' + e.getTypeName());
            System.debug('=====================' + e.getCause());
            System.debug('=====================' + e.getMessage());
        }
        return param;
    }


}