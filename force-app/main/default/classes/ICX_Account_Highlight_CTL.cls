public class ICX_Account_Highlight_CTL {

    @AuraEnabled
    /**
     * @description:
     * Retrieves the number of open complaint cases created within the last 20 days
     * and attached to a specific client
     * 
     * @param: 
     * clientID = ID of the client attached to the case
     **/
    public static Integer getClientNbOpenComplaintCases(String clientID)
    {
        return [SELECT id from Case where 
                status != 'Closed'
                AND Type = 'Complaints'
               	AND AccountId =: clientID
                AND createdDate = LAST_N_DAYS: 20
               ].size();
    }
    
    @AuraEnabled
    /**
     * @description:
     * Retrieves the number of closed complaint cases created within the last 20 days
     * and attached to a specific client
     * 
     * @param: 
     * clientID = ID of the client attached to the case
     **/
    public static Integer getClientNbClosedComplaintCases(String clientID)
    {
        return [SELECT id from Case where 
                status = 'Closed'
                AND Type = 'Complaints'
               	AND AccountId =: clientID
                AND createdDate = LAST_N_DAYS: 20
               ].size();
    }
    
    @AuraEnabled
    /**
     * @description:
     * Retrieves the number of open and closed complaint cases created within the last 20 days
     * and attached to a specific client
     * 
     * @param:
     * clientID = ID of the client attached to the case
     **/
    public static Integer getClientNbAllComplaintCases(String clientID)
    {
    	return [SELECT id from Case where 
                Type = 'Complaints'
               	AND AccountId =: clientID
                AND createdDate = LAST_N_DAYS: 20
               ].size();
    }
}