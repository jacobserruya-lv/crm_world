public without sharing class IDENTITY_Social_Login_Dashboard_CTRL {

    public static final AuthProvider KAKAO;
    public static final AuthProvider LINE;
    public static final AuthProvider WECHAT;
    public static final AuthProvider WECHAT_MOBILE;
    public static final List<AuthProvider> PROVIDERS;

    static {
        PROVIDERS = [SELECT Id, FriendlyName
            FROM AuthProvider
            WHERE FriendlyName IN ('Kakao', 'Line', 'WeChat', 'WeChat_Mobile')
            ORDER BY FriendlyName
        ];

        KAKAO = PROVIDERS[0];
        LINE = PROVIDERS[1];
        WECHAT = PROVIDERS[2];
        WECHAT_MOBILE = PROVIDERS[3];
    }

    public class DataSet {
        public DataSet(String label, Integer count) {
            this.label = label;
            this.count = count;
        }
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Integer count {get;set;}
    }

    @AuraEnabled
    public List < LineChartVar > myLineChartVarList;

    public class LineChartVar {
        string label;
        integer lineValue;
        integer weChatValue;
        integer weChatMobileValue;
        integer kakaoValue;

        public LineChartVar(string a, integer b, integer c, integer d, integer e) {
            label = a;
            lineValue = b;
            weChatValue = c;
            weChatMobileValue = d;
            kakaoValue = e;
        }
    }

    @AuraEnabled
    public static String getLoginHistoryByOrigin(String queryTime) {
        
        List < LineChartVar > myLineChartVarList = new List < LineChartVar > ();
        List < DataSet > dataSet = new List < DataSet > ();
        String loginTimeFieldQuery;
        String loginTimeConditionQuery;
        String loginTimeGroupQuery;
        String query;
        String returnResult;
        
        Map < Integer, String > monthsMap = new Map < Integer, String > {
            1 => 'Janvier',
            2 => 'Février',
            3 => 'Mars',
            4 => 'Avril',
            5 => 'Mai',
            6 => 'Juin',
            7 => 'Juillet',
            8 => 'Aout',
            9 => 'Septembre',
            10 => 'Octobre',
            11 => 'Novembre',
            12 => 'Décembre' 
        };

        date today = date.today();
        List < Integer > lastSixMonths = new List < Integer > {
            today.addMonths(-6).month(),
            today.addMonths(-5).month(),
            today.addMonths(-4).month(),
            today.addMonths(-3).month(),
            today.addMonths(-2).month(),
            today.addMonths(-1).month()
        };
        
        if(queryTime == 'last_six_months')
        {
            loginTimeFieldQuery = 'CALENDAR_MONTH(LoginTime) month,'; 
            loginTimeConditionQuery = 'LAST_N_MONTHS:6';
            loginTimeGroupQuery = ', CALENDAR_MONTH(LoginTime)';
        }
        else if(queryTime == 'current_month')
        {
            loginTimeFieldQuery = ''; 
            loginTimeConditionQuery = 'THIS_MONTH';
            loginTimeGroupQuery = '';
        }
        
        query = 'SELECT '+loginTimeFieldQuery+' AuthenticationServiceId, COUNT(Id) amount FROM LoginHistory WHERE LoginType = \'Chatter Communities External User Third Party SSO\' AND LoginTime = '+loginTimeConditionQuery+' GROUP BY AuthenticationServiceId'+loginTimeGroupQuery;        
        List < AggregateResult > result = Database.query(query);
        
        if (result != null && !result.isEmpty()) {
            
            System.debug('query result - login history: ' + result);

            if(queryTime == 'last_six_months')
            {
                for (Integer month: lastSixMonths) {
                    
                    String chartMonth = monthsMap.get(month);
                    Integer lineValue = 0;
                    Integer weChatValue = 0;
                    Integer weChatMobileValue = 0;
                    Integer kakaoValue = 0;

                    for (AggregateResult ar: result) {
                        if (ar.get('month') == month) {
                            if (ar.get('AuthenticationServiceId') == LINE.Id)
                                lineValue = (Integer) ar.get('amount');
                            if (ar.get('AuthenticationServiceId') == WECHAT.Id)
                                weChatValue = (Integer) ar.get('amount');
                            if (ar.get('AuthenticationServiceId') == WECHAT_MOBILE.Id)
                                weChatMobileValue = (Integer) ar.get('amount');
                            if (ar.get('AuthenticationServiceId') == KAKAO.Id)
                                kakaoValue = (Integer) ar.get('amount');
                        }
                    }

                    myLineChartVarList.add(new LineChartVar(chartMonth, lineValue, weChatValue, weChatMobileValue, kakaoValue));
                }    

                System.debug('myLineChartVarList: ' + myLineChartVarList);
                returnResult = JSON.Serialize(myLineChartVarList);
            }
            else if(queryTime == 'current_month')
            {
                for (AggregateResult ar: result) {
                    String provider;
                    if (ar.get('AuthenticationServiceId') == LINE.Id)
                        provider = 'Line';
                    else if(ar.get('AuthenticationServiceId') == KAKAO.Id)
                        provider = 'Kakao'; 
                    else if(ar.get('AuthenticationServiceId') == WECHAT.Id)
                        provider = 'WeChat';
                    else if(ar.get('AuthenticationServiceId') == WECHAT_MOBILE.Id)
                        provider = 'WeChat_Mobile'; 
                    Integer total = (Integer) ar.get('amount');

                    dataSet.add(new DataSet(provider, total));
                }                

                System.debug('dataSet: '+dataSet);
                returnResult = JSON.Serialize(dataSet);
            }            
        }
        else{
            returnResult = 'No data to display';
        }

        return returnResult;
    }

    @AuraEnabled
    public static List < DataSet > getVerificationCodeEmailsAmount() {
		
        // Amount of Verification Code Emails sent to users
        AggregateResult[] amount = [SELECT COUNT(Id) amount FROM Logs__c WHERE Level__c = 'INFO' AND Apex_Class__c = 'IDENTITY_Registration_CTRL' ];
        
        // Amount of distinct Users who got Verification Code Email
        Integer recordCount = (Integer) amount[0].get('amount');
        Integer sizeBlock = recordCount/2000 + (math.mod(recordCount,2000)!=0?1:0);
        Set<String> setUserIds = new Set<String>();
        Integer amountByUsers = 0;
        
        //Iterate aggregate result with blocks of 2000 to avoid SOQL exception in Production (too much data...)
        for(Integer i=0;i<sizeBlock;i++)
        {
            for (AggregateResult ar: [SELECT Record_Id__c, COUNT(Id) amountByUsers   FROM Logs__c WHERE Level__c = 'INFO' AND Apex_Class__c = 'IDENTITY_Registration_CTRL' AND Record_Id__c NOT IN :setUserIds GROUP BY Record_Id__c LIMIT 2000])
            {
                // save Record_Id__c in temp Set
                setUserIds.add(String.valueOf(ar.get('Record_Id__c')));                
                
                // aggregate count of distinct Users
                amountByUsers += 1;
            }
        }
        
        List < DataSet > dataSet = new List < DataSet > ();
        dataSet.add(new DataSet('amount', recordCount));
        dataSet.add(new DataSet('amountByUsers', amountByUsers));

        System.debug(dataSet);
        return dataSet;
    }

    @AuraEnabled
    public static List < DataSet > getEmailMobileUsers() {

        AggregateResult[] email  = [SELECT COUNT(Id) email  FROM User WHERE Is_Identity_User__c = true AND IsActive = true AND TECH_Email__c != null AND TECH_MobilePhone__c = null];
        AggregateResult[] mobile = [SELECT COUNT(Id) mobile FROM User WHERE Is_Identity_User__c = true AND IsActive = true AND TECH_Email__c != null AND TECH_MobilePhone__c != null];

        List < DataSet > dataSet = new List < DataSet > ();
        dataSet.add(new DataSet('email', (Integer) email[0].get('email')));
        dataSet.add(new DataSet('mobile', (Integer) mobile[0].get('mobile')));

        System.debug(dataSet);
        return dataSet;
    }

    @AuraEnabled
    public static List < DataSet > getResetPasswordAmount() {

        List<SetupAuditTrail> resetPassword = new List<SetupAuditTrail>();
        if(Test.isRunningTest()){
            resetPassword  = [SELECT Id  FROM SetupAuditTrail WHERE CreatedDate = LAST_N_DAYS:30 AND CreatedBy.Name IN ('Identity Integration', 'Identity Site Guest User') AND Action = 'changedpassword' LIMIT 100];
        }
        else{
            resetPassword  = [SELECT Id  FROM SetupAuditTrail WHERE CreatedDate = LAST_N_DAYS:30 AND CreatedBy.Name IN ('Identity Integration', 'Identity Site Guest User') AND Action = 'changedpassword' ];
        }        
        
        List < DataSet > dataSet = new List < DataSet > ();
        dataSet.add(new DataSet('amount', (Integer) resetPassword.size()));
        
        System.debug(dataSet);
        return dataSet;
    }

}