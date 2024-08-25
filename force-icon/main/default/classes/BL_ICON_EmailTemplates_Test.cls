/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@IsTest
public class BL_ICON_EmailTemplates_Test {
     @IsTest static void testExecuteGet() {
        try{
            Test.startTest();              
            BL_AppSettings.setAppSettings('Wechat');
            BL_ICON_EmailTemplates email = new BL_ICON_EmailTemplates();
            email.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            email.me.userDetails.put('storeCodeIso3','USA');
            email.pathParameters = new Map<String,String>{'lng' => null};
            email.executeGET();
            Test.stopTest();   
        } 
        catch (Exception ex){   
        }     
    }

}