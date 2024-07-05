global class BatchExVariationMembersForClubMembers implements Database.Batchable<sObject>, Database.Stateful {
    List<Brand_Experience_Variation__c> variations = new List<Brand_Experience_Variation__c> ();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> variationStatusFilter = new List<String> {'Ready', 'Preview', 'Registration Opened', 'Registration Closed','Selection Opened', 'Selection Closed', 'Participation Opened'};
        variations = [
            SELECT Id, Name, Status__c, RequiredClientRegistration__c, ClientRegistrationDateLimit__c,Brand_Experience__r.ClubName__c, EligibleClubMemberStatus__c, EligibleUnlockedBadge__c, EligibleAfricaMiddleEastCountries__c, EligibleEuropeCountries__c, EligibleAmericasCountries__c, EligibleAsiaPacificCountries__c
            FROM Brand_Experience_Variation__c
            WHERE Brand_Experience__r.RecordType.Name = 'Club Experience'
            AND TargetingMethod__c = 'Dynamic'
            AND Status__c IN :variationStatusFilter
        ];

        System.debug('variations.size(): ' + variations.size());

        return Database.getQueryLocator(
            'SELECT id, Club_and_Seasons__c, clubStatus__c, clientId__c, clientId__r.SPO_Country_code__pc, clientId__r.TECH_AttachedStoreCountry__c, (SELECT Id, badgeId__c, badgeFlag__c FROM Badges_Collections__r) ' +
            'FROM Club_MemberShip__c ' +
            'WHERE clubStatus__c != \'' + 'NOT ELIGIBLE' + '\' ' +
            'AND isClubEligible__c = TRUE'
        );
    }

    global void execute(Database.BatchableContext bc, List<Club_MemberShip__c> clubMembers) {
        System.debug('clubMembers.size(): ' + clubMembers.size());

        List<Brand_Experience_Variation_Member__c> variationMembers = new List<Brand_Experience_Variation_Member__c>();

        for (Brand_Experience_Variation__c variation : variations) {
            List<String> countriesFilter = getVariationEligibleCountriesFilter(variation);

            for (Club_MemberShip__c member : clubMembers) {
                String clientCountry = member.clientId__r.SPO_Country_code__pc != null ?
                                       member.clientId__r.SPO_Country_code__pc : 
                                       member.clientId__r.TECH_AttachedStoreCountry__c;

              
                Boolean isItTheSameClub = member.Club_and_Seasons__c == variation.Brand_Experience__r.ClubName__c;
                Boolean isEligibleCountry = countriesFilter.isEmpty() || countriesFilter.contains(clientCountry);
                Boolean isEligibleStatus = variation.EligibleClubMemberStatus__c == null || variation.EligibleClubMemberStatus__c.split(';').contains(member.clubStatus__c);
                Boolean isEligibleBadge = isEligibleBadge(variation, member);
              
                Boolean isRegistrationMandatory =  variation.RequiredClientRegistration__c == 'Mandatory';
                Boolean isParticipationOpenedAndMandatory = isRegistrationMandatory && variation.Status__c == 'Participation Opened' && variation.ClientRegistrationDateLimit__c ;
    
                if (!isParticipationOpenedAndMandatory && isItTheSameClub && isEligibleCountry && isEligibleStatus && isEligibleBadge) {                    
                    variationMembers.add(
                        new Brand_Experience_Variation_Member__c(
                            Client__c = member.clientId__c,
                            ClubMember__c = member.Id,
                            Brand_Experience_Variation__c = variation.Id,
                            IsSelected__c = !isRegistrationMandatory,
                            NominationSource__c = 'LV#54',
                            NominationStatus__c = getNominationStatus(variation),
                            rsvpState__c =  isRegistrationMandatory ? 'Not Registered' : null
                        )
                    );
                }
            }
        }

        System.debug('variationMembers: ' + variationMembers.size());

        Database.insert(variationMembers, false);
    }

    global void finish(Database.BatchableContext bc) {

    }

    private List<String> getVariationEligibleCountriesFilter(Brand_Experience_Variation__c variation) {
        List<String> countriesFilter = new List<String>();
        if (variation.EligibleAfricaMiddleEastCountries__c != null) {
            countriesFilter.addAll(variation.EligibleAfricaMiddleEastCountries__c.split(';'));
        }

        if (variation.EligibleEuropeCountries__c != null) {
            countriesFilter.addAll(variation.EligibleEuropeCountries__c.split(';'));
        }

        if (variation.EligibleAmericasCountries__c != null) {
            countriesFilter.addAll(variation.EligibleAmericasCountries__c.split(';'));
        }

        if (variation.EligibleAsiaPacificCountries__c != null) {
            countriesFilter.addAll(variation.EligibleAsiaPacificCountries__c.split(';'));
        }
        
        return countriesFilter;
    }

    private Boolean isEligibleBadge(Brand_Experience_Variation__c variation, Club_MemberShip__c member) {
        if (variation.RequiredClientRegistration__c == 'Mandatory' && variation.Status__c == 'Registration Closed') {
            return false;
        }

        if (variation.EligibleUnlockedBadge__c == null) return true;

        for (Badge_Collection__c badge : member.Badges_Collections__r) {
            if (badge.badgeFlag__c && badge.badgeId__c == variation.EligibleUnlockedBadge__c) return true;
        }

        return false;
    }

   
    private String getNominationStatus(Brand_Experience_Variation__c variation) {   
        switch on variation.Status__c {
            when 'Ready', 'Preview','Participation Opened','Registration Opened', 'Registration Closed' {
                return 'Approved';
            }
            when else {
                return null;
            }
        }
    }
}