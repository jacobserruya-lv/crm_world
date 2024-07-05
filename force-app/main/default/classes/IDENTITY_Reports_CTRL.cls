public with sharing class IDENTITY_Reports_CTRL {

    @RemoteAction @ReadOnly
    public static Map<String,Integer> getActiveUsers(){
        AggregateResult[] isActive = [SELECT COUNT(Id) isActive FROM User WHERE IsActive = true AND Is_Identity_User__c = true];
        AggregateResult[] isNotActive = [SELECT COUNT(Id) isNotActive FROM User WHERE IsActive = false AND Is_Identity_User__c = true];

        return new Map<String,Integer> {
            'Active' => (Integer) isActive[0].get('isActive'),
            'Inactive' => (Integer) isNotActive[0].get('isNotActive')
        };
    }

    @RemoteAction @ReadOnly
    public static Map<String,Object> getLoginAmount(){

        AuthProvider line = [SELECT Id FROM AuthProvider WHERE FriendlyName = 'Line' LIMIT 1];
        AuthProvider wechat = [SELECT Id FROM AuthProvider WHERE FriendlyName = 'WeChat' LIMIT 1];
        AuthProvider kakao = [SELECT Id FROM AuthProvider WHERE FriendlyName = 'Kakao' LIMIT 1];

        AggregateResult[] line_amount = [
            SELECT CALENDAR_MONTH(LoginTime) month, COUNT(Id) amount, COUNT_DISTINCT(UserId) user_amount
            FROM LoginHistory 
            WHERE LoginType = 'Chatter Communities External User Third Party SSO' 
                AND AuthenticationServiceId = :line.Id
            GROUP BY CALENDAR_MONTH(LoginTime)
            ORDER BY CALENDAR_MONTH(LoginTime)];

        AggregateResult[] wechat_amount = [
            SELECT CALENDAR_MONTH(LoginTime) month, COUNT(Id) amount, COUNT_DISTINCT(UserId) user_amount
            FROM LoginHistory 
            WHERE LoginType = 'Chatter Communities External User Third Party SSO' 
                AND AuthenticationServiceId = :wechat.Id
            GROUP BY CALENDAR_MONTH(LoginTime)
            ORDER BY CALENDAR_MONTH(LoginTime)];

        AggregateResult[] kakao_amount = [
            SELECT CALENDAR_MONTH(LoginTime) month, COUNT(Id) amount, COUNT_DISTINCT(UserId) user_amount
            FROM LoginHistory 
            WHERE LoginType = 'Chatter Communities External User Third Party SSO' 
                AND AuthenticationServiceId = :kakao.Id
            GROUP BY CALENDAR_MONTH(LoginTime)
            ORDER BY CALENDAR_MONTH(LoginTime)];

        return new Map<String,Object> {
            'Line' => line_amount,
            'WeChat' => wechat_amount,
            'Kakao' => kakao_amount
        };
    }

    @RemoteAction @ReadOnly
    public static Map<String,Integer> getUsernameType(){ 
        AggregateResult[] mobile = [SELECT COUNT(Id) mobile FROM User WHERE Is_Identity_User__c = true AND TECH_MobilePhone__c != null];
        AggregateResult[] email = [SELECT COUNT(Id) email FROM User WHERE Is_Identity_User__c = true AND TECH_Email__c != null];

        return new Map<String,Integer> {
            'Mobile' => (Integer) mobile[0].get('mobile'),
            'Email' => (Integer) email[0].get('email')
        }; 
    }
}