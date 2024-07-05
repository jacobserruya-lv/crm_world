global without sharing class BL_ICON_TermsConditions extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePUT {
 
        global Object executePUT(){
            String id = (String)me.userDetails.get('id');
            User u = [SELECT HasAgreedWWVoiceTermsConditions__c	FROM User WHERE Id = :id];
            u.HasAgreedWWVoiceTermsConditions__c = true;
            update u;
            return new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_USER)
                .condition('id = \'' + id + '\'')
                .executeQuery()
                .getMappedObject();
        }
    }