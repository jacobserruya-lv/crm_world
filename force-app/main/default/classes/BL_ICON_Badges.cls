global with sharing class BL_ICON_Badges extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{

    global Object executeGET(){
       
       return BL_ICON_Badges_Helper.getBadges(me.basicInfos.Id,  me.basicInfos.DefaultStore__c);
        
    }

}