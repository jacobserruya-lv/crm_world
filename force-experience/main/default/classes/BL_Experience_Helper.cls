public with sharing class BL_Experience_Helper {
    public static Object getExperiencesByClubName(String clubName, Integer pageSize,Integer pageIndex) {
        List<String> membersFields =  new List<String> {'Status__c','rsvpState__c','rsvpDateTime__c','IsSelected__c','ParticipationStartDateTime__c','ParticipationEndDateTime__c','Brand_Experience_Variation__c', 'Notification_Request__c'};
        List<Brand_Experience_Variation_Member__c> members = getMembersByClubName(clubName, membersFields, pageSize, pageIndex);

        // Map members by variation Id
        Map<String, List<Object>> membersByVariations = new Map<String, List<Object>>();
        for (Brand_Experience_Variation_Member__c member : members) {
            for (String field : membersFields) {
                Map<String, Object> memberMap = member.getPopulatedFieldsAsMap();
                if (!memberMap.containsKey(field)) {
                    member.put(field, null);
                }
            }  

            String variationId = member.Brand_Experience_Variation__c;
            List<Object> variationMembers = membersByVariations.containsKey(variationId) ? membersByVariations.get(variationId) : new List<Object>();
            variationMembers.add(member);
            membersByVariations.put(variationId, variationMembers);
        }

        // Get variations by ids of the members variations
        List<String> variationsFields = new List<String> {'Name','DigitalEventTechPassword__c','DigitalEventTechReference__c','EndDateTime__c','PreviewDateTime__c','StartDateTime__c','Status__c','SubType__c','Type__c','DigitalEventTech__c','Reference__c','ContentUrl__c','OfferTypology__c','OfferCode__c','Brand_Experience__c', 'RequiredClientRegistration__c', 'RegistrationEndDateTime__c', 'RegistrationStartDateTime__c'};
        List<Brand_Experience_Variation__c> variations = getVariationsByIds(membersByVariations.keySet(), variationsFields);

        // Add members field to the each variation 
        List<Object> variationsFullRecords = new List<Object> ();
        for (Brand_Experience_Variation__c variation : variations) {
            for (String field : variationsFields) {
                Map<String, Object> variationMap = variation.getPopulatedFieldsAsMap();
                if (!variationMap.containsKey(field)) {
                    variation.put(field, null);
                }
            } 

            Map<String, Object> variationWithMembers = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(variation));
            variationWithMembers.put(
                'members',
                responseFormat(
                    membersByVariations.get(variation.Id)
                ) 
            );
            variationsFullRecords.add(variationWithMembers);
        }

        // Map variations by experience Id
        Map<String, List<Object>> variationsByExperiences = new Map<String, List<Object>>();
        for (Object variation : variationsFullRecords) {
            String experienceId = (String) ((Map<String, Object>) variation).get('Brand_Experience__c');
            List<Object> experienceVariations = variationsByExperiences.containsKey(experienceId) ? variationsByExperiences.get(experienceId) : new List<Object>();
            experienceVariations.add(variation);
            variationsByExperiences.put(experienceId, experienceVariations);
        }

        // Get experiences by ids of the variation experiences
        List<String> experiencesFields = new List<String>{'Name','Status__c','Reference__c'};
        List<Brand_Experience__c> experiences = getExperiencesByIds(variationsByExperiences.keySet(), experiencesFields);

        // Add variation field to the each experience 
        List<Object> experienceaFullRecords = new List<Object>();
        for (Brand_Experience__c experience : experiences) {
            for (String field : experiencesFields) {
                Map<String, Object> experienceMap = experience.getPopulatedFieldsAsMap();
                if (!experienceMap.containsKey(field)) {
                    experience.put(field, null);
                }
            } 

            Map<String, Object> experienceWithVariations = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(experience));
            experienceWithVariations.put(
                'variations',
                responseFormat(
                    variationsByExperiences.get(experience.Id)
                )
            );
            experienceaFullRecords.add(experienceWithVariations);
        }

        return responseFormat(experienceaFullRecords);
    }

    public static Object updateExperienceMemberById(String id, Object body) {
        Map<String, Object> memberBodyRequest = (Map<String, Object>) body;

        List<Brand_Experience_Variation_Member__c> memberResponse = [
            SELECT 
                Brand_Experience_Variation__r.Status__c,
                rsvpState__c,
                rsvpDateTime__c,
                ParticipationStartDateTime__c,
                ParticipationEndDateTime__c, 
                Status__c,
                Notification_Request__c
            FROM Brand_Experience_Variation_Member__c
            WHERE Id = :id
            WITH SECURITY_ENFORCED
        ];

        if (memberResponse.size() == 0) {
            throw new BL_Exceptions.BL_Exception('Member Id not found: ' + id);
        }

        Brand_Experience_Variation_Member__c member = memberResponse[0];

        if (memberBodyRequest.containsKey('rsvpState')) {
            member.rsvpState__c = (String) memberBodyRequest.get('rsvpState');
        }

        if (memberBodyRequest.containsKey('rsvpDateTime')) {
            String stringDateTime = (String) memberBodyRequest.get('rsvpDateTime');
            Datetime dt = (DateTime)JSON.deserialize('"' + stringDateTime + '"', DateTime.class);
            member.rsvpDateTime__c = dt;
        }

        if (memberBodyRequest.containsKey('participationStartDateTime')) {
            String stringDateTime = (String) memberBodyRequest.get('participationStartDateTime');
            Datetime dt = (DateTime)JSON.deserialize('"' + stringDateTime + '"', DateTime.class);
            member.ParticipationStartDateTime__c = dt;
        }

        if (memberBodyRequest.containsKey('participationEndDateTime')) {
            String stringDateTime = (String) memberBodyRequest.get('participationEndDateTime');
            Datetime dt = (DateTime)JSON.deserialize('"' + stringDateTime + '"', DateTime.class);
            member.ParticipationEndDateTime__c = dt;
        }
        if (memberBodyRequest.containsKey('notificationRequest')) {
            member.Notification_Request__c = (Boolean) memberBodyRequest.get('notificationRequest');

        }

        update member;
        return member;
    }

    private static List<Brand_Experience_Variation_Member__c> getMembersByClubName(String clubName, List<String> queryFields, Integer pageSize,Integer pageIndex) {
        List<String> variationStatusFilter = new List<String>{'Draft', 'Ready'};

        String membersQuery = 
            'SELECT ' + String.join(queryFields, ',') +
            ' FROM Brand_Experience_Variation_Member__c' +
                ' WHERE Status__c != \'' + 'Draft' + '\'' +
                ' AND Brand_Experience_Variation__r.Status__c NOT IN :variationStatusFilter ' +
                ' AND Brand_Experience_Variation__r.Brand_Experience__r.ClubName__r.Name = :clubName' +
                ' AND ClubMember__c != NULL' +
                ' AND ClubMember__r.isMember__c = TRUE' + 
                ' AND ClubMember__r.isClubEligible__c = TRUE' +
                ' AND ClubMember__r.clubName__c = :clubName';

                membersQuery += ' WITH SECURITY_ENFORCED';

        if (pageSize != null) {
            membersQuery += ' LIMIT :pageSize'; 
        }

        if (pageIndex != null) {
            membersQuery += ' OFFSET :pageIndex'; 
        }

        return Database.query(membersQuery);
    }

    private static List<Brand_Experience_Variation__c> getVariationsByIds(Set<String> variationIds, List<String> queryFields) {
        String variationsQuery = 'SELECT ' + String.join(queryFields, ',') + ' FROM Brand_Experience_Variation__c WHERE Id IN :variationIds WITH SECURITY_ENFORCED';
        return Database.query(variationsQuery);
    }

    private static List<Brand_Experience__c> getExperiencesByIds(Set<String> experienceIds, List<String> queryFields) {
        String experiencesQuery = 'SELECT ' + String.join(queryFields, ',') + ' FROM Brand_Experience__c WHERE Id IN :experienceIds WITH SECURITY_ENFORCED';
        return Database.query(experiencesQuery);
    }

    private  static Map<String, Object> responseFormat(List<Object> records) {
        return new Map<String, Object> {
            'totalSize' => records.size(),
            'records' => records
        };
    }
}