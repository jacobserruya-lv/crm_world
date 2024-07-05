global with sharing class BL_Experience extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePATCH {
    global Object executeGET() {
        String clubName = getPathParameter('clubname');

        Boolean isExperience = path.contains('experiences');
        Boolean isBadges = path.contains('badges');

        Integer pageSize = getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : null;
        Integer pageIndex = getQueryParameter('offset') != null ? Integer.valueOf(getQueryParameter('offset')) : null;

        if (isExperience) {
            return BL_Experience_Helper.getExperiencesByClubName(clubName, pageSize, pageIndex);
        }

        return null;
    }

    global Object executePATCH() {
        Boolean isExperienceMember = path.contains('members');

        if (isExperienceMember) {
            String id = getPathParameter('id');
            return BL_Experience_Helper.updateExperienceMemberById(id, requestBody);
        }

        return null;
    }
}