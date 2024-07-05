global with sharing class BL_ICON_Onboarding extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET() {
        return BL_ICON_Onboarding_Helper.getOnboardings();
    }

}