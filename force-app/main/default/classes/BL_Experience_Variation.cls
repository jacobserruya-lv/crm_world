global with sharing class BL_Experience_Variation  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET , BL_WS_Interfaces.DispatchablePOST ,BL_WS_Interfaces.DispatchablePUT, BL_WS_Interfaces.DispatchableDELETE{

    
    enum UseCase {EXPERIENCE_VARIATION_BY_ID ,EXPERIENCE_VARIATION_LIST,VARIATION_MEMBERS_LIST, VARIATION_MEMBER_BY_ID, EXPERIENCE_VARIATION_EVITES, EXPERIENCE_VARIATION_KPI, EXPERIENCE_VARIATION_GUEST, EXPERIENCE_VARIATION_SAVE} 

    private UseCase getUseCase(){

        switch on path {
            when '/experience-variations' {

                return UseCase.EXPERIENCE_VARIATION_LIST;
            } 
            when '/experience-variations/{id}' {

                return UseCase.EXPERIENCE_VARIATION_BY_ID;
            }
            when '/experience-variations/{id}/members' {

                return UseCase.VARIATION_MEMBERS_LIST;
            }
            when '/experience-variations/members/{id}' {

                return UseCase.VARIATION_MEMBER_BY_ID;
            }
            when '/experience-variations/{id}/evites' {

                return UseCase.EXPERIENCE_VARIATION_EVITES;
            }
            when '/experience-variations/{id}/kpi' {

                return UseCase.EXPERIENCE_VARIATION_KPI;
            }
            when '/experience-variations/members/{id}/guests' {
                return UseCase.EXPERIENCE_VARIATION_GUEST;
            }
            when '/experience-variations/members/{id}/save' {
                return UseCase.EXPERIENCE_VARIATION_SAVE;
            }
        }

        return null;
    }
  
    global Object executeGET() {

        Integer pageSize = getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : null;
        Integer pageIndex = getQueryParameter('offset') != null ? Integer.valueOf(getQueryParameter('offset')) : null;

        switch on getUseCase() {
            when EXPERIENCE_VARIATION_LIST {

                String storeId = getQueryParameter('storeId'); 
                String experienceType = getQueryParameter('experienceType');
                String variationType = getQueryParameter('variationType');  
                String startAfter = getQueryParameter('startAfter'); 
                String endBefore = getQueryParameter('endBefore'); 

                return new BL_WS_Response( 
                    BL_Experience_Variation_Helper.getAllVariation(experienceType, startAfter, endBefore, pageSize, pageIndex, storeId, me)
                ); 
            }
            when EXPERIENCE_VARIATION_BY_ID {

                String experienceVarId = getPathParameter('id');

                return new BL_WS_Response(
                    BL_Experience_Variation_Helper.getVariationeById(experienceVarId, me)
                );
            }
            when VARIATION_MEMBERS_LIST {

                List<String> caIdsList = new List<String>();
                List<String> statusList = new List<String>();

                List<Map<String, Object>> myTeamList = new List<Map<String, Object>>();

                String experienceVarId = getPathParameter('id');
                String status = getQueryParameter('status');

                String storeCode = (getQueryParameter('storeCode') != null ? getQueryParameter('storeCode') : null);  
                Boolean myTeam = (getQueryParameter('myTeam') != null && getQueryParameter('myTeam') == 'true' ? true : false);
               
                statusList = status != null ? status.split(';') : statusList;
                caIdsList = (getQueryParameter('caIds') != null ? (getQueryParameter('caIds')).split(';') : caIdsList);

                if(myTeam){
                    myTeamList = (List<Map<String, Object>>) BL_ICON_Team.getTeamMembers(true,me);
                    for(Map<String, Object> teamMember : myTeamList){
                        caIdsList.add((String) teamMember.get('id'));
                    }
                }
            
                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.getVariationMember(experienceVarId, statusList, pageSize, pageIndex, me,storeCode,caIdsList)
                );
               
            }
            when VARIATION_MEMBER_BY_ID {

                String memberId = getPathParameter('id');
                
                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.getVariationMemberById(memberId, me)
                );
            } 
            when EXPERIENCE_VARIATION_EVITES {
                
                String experienceVarId = getPathParameter('id');

                return new BL_WS_Response(
                    BL_Experience_Variation_Helper.getEvitesByVariation(experienceVarId,me)
                );
            }  
            when EXPERIENCE_VARIATION_KPI {
                
                String experienceVarId = getPathParameter('id');

                String features = getQueryParameter('features') != null ? String.valueOf(getQueryParameter('features')) : '' ; 

                List<String> featuresList = features.split(';');

                // return new BL_WS_Response(
                //     BL_Experience_Variation_Helper.getKPIsByVariation(experienceVarId,me,featuresList)
                // );

                return BL_Experience_Variation_Helper.getKPIsByVariation(experienceVarId,me,featuresList);

            }  
        }
        return null;
    }

    global Object executePOST(){

        switch on getUseCase() {
            when VARIATION_MEMBERS_LIST {

                String experienceVarId = getPathParameter('id');
                List<Object> records = getRequestRecords();

                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.createVariationMembers(records, experienceVarId)
                );
            }
        }
        return null;
    }

    global Object executePUT(){

        switch on getUseCase() {
            when VARIATION_MEMBER_BY_ID {
                String memberId = getPathParameter('id');
                Object record =  getRequestRecord();

                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.updateVariationMembers(record, memberId, me)
                );
            }
            when EXPERIENCE_VARIATION_GUEST{
                String memberId = getPathParameter('id');
                Object record =  getRequestRecord();

                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.upsertGuestsPerMember(record, memberId, me)
                );
            }
            when EXPERIENCE_VARIATION_SAVE{
                String memberId = getPathParameter('id');
                Object record =  getRequestRecord();

                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.saveMemberandRelated(record, memberId, me)
                );
            }
        }
        return null;
    }

    global Object executeDELETE(){
        switch on getUseCase() {
            when EXPERIENCE_VARIATION_GUEST{
                Object record =  getRequestRecord();

                return new BL_WS_Response(
                    BL_Experience_Variation_Member_Helper.deleteGuests(record)
                );
            }
        }
        return null;
    }
}