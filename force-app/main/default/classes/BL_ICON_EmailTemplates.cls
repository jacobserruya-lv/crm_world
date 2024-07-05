/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-16-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BL_ICON_EmailTemplates extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{
    
    global Object executeGET(){
        String lng = (me.userDetails.get('storeCodeIso3') != null ? (String) me.userDetails.get('storeCodeIso3') : 'USA');
        String features = (getQueryParameter('features') != null ? getQueryParameter('features') : 'sms');
        System.debug('AAAAA FEATURE: ' + features);
        return new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_EMAIL_TEMPLATE)
        .condition('IsActive = true  and (Folder.DeveloperName like \'%Mobile\' or Folder.DeveloperName like \'%'+ features +'\') and folder.type =\'Email\'')
        .orderBy('Folder.Name ASC, Name ASC, CreatedDate DESC')
        .limitCount(400)
        .executeQuery()
        .getMappedObjects();
    }
}