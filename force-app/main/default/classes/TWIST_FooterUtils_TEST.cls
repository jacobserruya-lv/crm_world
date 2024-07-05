@isTest
public with sharing class TWIST_FooterUtils_TEST {
    
    private static final Map<String,Object> lvApiResponse = getLvApiResponse();
    private static final String footerLinkBaseUrl = 'https://dummy-base-url.com';
    
    @isTest
    public static void test_initFooterConfig() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        
        // When
        TWIST_FooterUtils.initFooterConfig(footerConfig);
        
        // Then
        System.assertEquals(2, footerConfig.keySet().size(), 'ERROR');
        System.assert(footerConfig.containsKey(TWIST_FooterUtils.SOCIAL_KEY), 'ERROR');
        System.assert(footerConfig.containsKey(TWIST_FooterUtils.SECTION_KEY), 'ERROR');
    }
    
    @isTest
    public static void test_addFooterConfigFromSF_whenLanguageCountryDoesNotExist() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        String baseUrl = 'https://dummy-url.com/';
        String langCountry = 'zzz-zz';
        String dispatchCountry = '';
        String origin = 'mylv';
        
        // When
        TWIST_FooterUtils.addFooterConfigFromSF(footerConfig, baseUrl, langCountry, dispatchCountry, origin);
        
        // Then
        System.assertEquals(3, footerConfig.keySet().size(), 'ERROR');
        System.assert(footerConfig.containsKey(TWIST_FooterUtils.IS_MOBILE_APP_KEY), 'ERROR');
        System.assert(footerConfig.containsKey(TWIST_FooterUtils.SHIP_TO_URL_KEY), 'ERROR');
    }
    
    @isTest
    public static void test_addFooterConfigFromSF_nominalCase() {
        // Given
        Map<String,Object> footerConfig1 = new Map<String,Object>();
        Map<String,Object> footerConfig2 = new Map<String,Object>();
        Map<String,Object> footerConfig3 = new Map<String,Object>();
        String baseUrl = 'https://dummy-url.com';
        Set<String> expectedKeys = new Set<String> {
            TWIST_FooterUtils.IS_MOBILE_APP_KEY,
            TWIST_FooterUtils.SHIP_TO_URL_KEY,
            TWIST_FooterUtils.CLIENT_SERVICE_PHONE_NUMBER_KEY,
            TWIST_FooterUtils.DISPLAY_USER_RIGHTS_LOGO_KEY,
            TWIST_FooterUtils.COUNTRY_FLAG_KEY,
            TWIST_FooterUtils.SITEMAP_LINK_KEY,
            TWIST_FooterUtils.HIDE_FLAG_COUNTRY_KEY,
            TWIST_FooterUtils.ADDITIONAL_TEXT_KEY
        };
        
        // When
        TWIST_FooterUtils.addFooterConfigFromSF(footerConfig1, baseUrl, 'ara-ae', 'KW', 'mylv');
        TWIST_FooterUtils.addFooterConfigFromSF(footerConfig2, baseUrl, 'eng-us', '', 'mylv');
        TWIST_FooterUtils.addFooterConfigFromSF(footerConfig3, baseUrl, 'ara-ae', 'KW', 'lvapp');
        
        // Then
        System.assertEquals(expectedKeys, footerConfig1.keySet(), 'ERROR');
        System.assertEquals(false, footerConfig1.get(TWIST_FooterUtils.IS_MOBILE_APP_KEY), 'ERROR');
        System.assertEquals(baseUrl + '/dispatch?noDRP=true', footerConfig1.get(TWIST_FooterUtils.SHIP_TO_URL_KEY), 'ERROR');
        
        System.assertEquals(expectedKeys, footerConfig2.keySet(), 'ERROR');
        System.assertEquals(false, footerConfig2.get(TWIST_FooterUtils.IS_MOBILE_APP_KEY), 'ERROR');
        System.assertEquals(baseUrl + '/dispatch?noDRP=true', footerConfig2.get(TWIST_FooterUtils.SHIP_TO_URL_KEY), 'ERROR');
        
        System.assertEquals(expectedKeys, footerConfig3.keySet(), 'ERROR');
        System.assertEquals(true, footerConfig3.get(TWIST_FooterUtils.IS_MOBILE_APP_KEY), 'ERROR');
        System.assertEquals(baseUrl + '/dispatch?noDRP=true', footerConfig3.get(TWIST_FooterUtils.SHIP_TO_URL_KEY), 'ERROR');
    }
    
    @isTest
    public static void test_addFooterConfigFromSF_whenCustomExceptionIsThrown() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        TWIST_FooterUtils.forceThrowException = true;
        
        // When
        TWIST_FooterUtils.addFooterConfigFromSF(footerConfig, 'https://dummy-url.com/', 'ara-ae', 'KW', 'mylv');
        
        // Then
        System.assert(TWIST_UTILS.isMapResponseOfTypeFailureResponseObject(footerConfig), 'ERROR');
    }
    
    @isTest
    public static void test_addFooterConfigFromLV_getFooterConfigFromLvApi() { // dumb test for the sake of code coverage
        // Given
        Map<String,Object> apiResponse = new Map<String,Object> {
            'key1' => 'value',
            'key2' => new List<String> { 'a', 'b', 'c' },
            'key3' => false,
            'key4' => 555
        };
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(JSON.serialize(apiResponse)));
        
        // When
        Map<String,Object> result = TWIST_FooterUtils.getFooterConfigFromLvApi('http://dummy-url.com');
        
        // Then
        System.assert(apiResponse.equals(result), 'ERROR');
    }
    
    @isTest  
    public static void test_addFooterConfigFromLV_addLegalNoticeAndPrivacyConfig() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        List<Object> legalSectionConfig = (List<Object> ) lvApiResponse.get(TWIST_FooterUtils.LEGAL_SECTION_KEY);
        
       	// When
       	Map<String,Object> legalNoticeConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, TWIST_FooterUtils.ID_ELEM_KEY, TWIST_FooterUtils.ID_ELEM_LEGAL_NOTICE);  
        Map<String,Object> privacyPolicyConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, TWIST_FooterUtils.LABEL_KEY, TWIST_FooterUtils.ID_ELEM_PRIVACY_POLICY);
        
        TWIST_FooterUtils.addLegalNoticeAndPrivacyConfig(footerConfig, lvApiResponse, footerLinkBaseUrl);
        
        // Then
        System.assertEquals(6, legalSectionConfig.size(), 'ERROR');
        System.assertEquals(legalNoticeConfig.get(TWIST_FooterUtils.LABEL_KEY), 'Legal Notices');
        System.assertEquals(legalNoticeConfig.get(TWIST_FooterUtils.URL_KEY), 'https://dummy-base-url.com/eng-us/legal-notices');
        System.assertEquals(privacyPolicyConfig.get(TWIST_FooterUtils.LABEL_KEY), 'Privacy Policy');
        System.assertEquals(privacyPolicyConfig.get(TWIST_FooterUtils.URL_KEY), 'https://dummy-base-url.com/eng-us/legal-notices#privacy-policy');
    }

    @isTest
    public static void test_addFooterConfigFromLV_addCaliforniaTransparencyConfigForUs() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        List<Object> legalSectionConfig = (List<Object> ) lvApiResponse.get(TWIST_FooterUtils.LEGAL_SECTION_KEY);
        
        // When
       	TWIST_FooterUtils.addCaliforniaTransparencyConfigForUs(footerConfig, lvApiResponse, footerLinkBaseUrl);
        Map<String,Object> transparencyConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, TWIST_FooterUtils.ID_ELEM_KEY, TWIST_FooterUtils.ID_ELEM_TRANSPARENCY_US);
        
        // Then
        System.assertEquals(6, legalSectionConfig.size(), 'ERROR');
        System.assertEquals(transparencyConfig.get(TWIST_FooterUtils.LABEL_KEY), 'California Supply Chains Act');
        System.assertEquals(transparencyConfig.get(TWIST_FooterUtils.URL_KEY), 'https://dummy-base-url.com/eng-us/california-transparency');
    }

    @isTest
    public static void test_addFooterConfigFromLV_addConfidentialityConfigForFrenchCanada() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        List<Object> legalSectionConfig = (List<Object> ) lvApiResponse.get(TWIST_FooterUtils.LEGAL_SECTION_KEY);
        
        // When
       	Map<String,Object> confidentialityConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, TWIST_FooterUtils.LABEL_KEY, TWIST_FooterUtils.ID_ELEM_CONFIDENTIALITY_FRA_CA);
        TWIST_FooterUtils.addConfidentialityConfigForFrenchCanada(footerConfig, lvApiResponse, footerLinkBaseUrl);
        
        // Then
        System.assertEquals(6, legalSectionConfig.size(), 'ERROR');
        System.assertEquals(confidentialityConfig.get(TWIST_FooterUtils.LABEL_KEY), 'Confidentialité');
        System.assertEquals(confidentialityConfig.get(TWIST_FooterUtils.URL_KEY), 'https://dummy-base-url.com/fra-ca/mentions-legales#confidentialite');
    }
    
    @isTest
    public static void test_addFooterConfigFromLV_addSectionsConfig() {
        // Given
        String clientServicePhoneNumber = '+33123456789';
        Map<String,Object> footerConfig = new Map<String,Object>();
        TWIST_FooterUtils.initFooterConfig(footerConfig);
        
        // When
        TWIST_FooterUtils.addSectionsConfig(footerConfig, lvApiResponse, footerLinkBaseUrl, clientServicePhoneNumber);
        Map<String,Object> sectionsConfig = (Map<String,Object>) footerConfig.get(TWIST_FooterUtils.SECTION_KEY);
        Map<String,Object> helpSectionConfig = (Map<String,Object>) sectionsConfig.get(TWIST_FooterUtils.HELP_SECTION_KEY);
        List<Object> contentConfig = (List<Object>) helpSectionConfig.get(TWIST_FooterUtils.CONTENT_KEY);
        Map<String,Object> clientServiceMessageConfig = TWIST_ListUtils.filterByMapKeyValues(contentConfig, TWIST_FooterUtils.TYPE_ELEM_KEY, TWIST_FooterUtils.TYPE_ELEM_TEXT);
        String clientServiceMessageLabel = String.valueOf(clientServiceMessageConfig.get(TWIST_FooterUtils.LABEL_KEY));
        
        // Then
        Map<String,Object> sectionConfig;
        System.assertEquals(4, sectionsConfig.keySet().size(), 'ERROR');

        System.assert(sectionsConfig.containsKey(TWIST_FooterUtils.HELP_SECTION_KEY), 'ERROR');
        sectionConfig = (Map<String,Object>) sectionsConfig.get(TWIST_FooterUtils.HELP_SECTION_KEY);
        System.assert(!sectionConfig.isEmpty(), 'ERROR');

        System.assert(sectionsConfig.containsKey(TWIST_FooterUtils.SERVICES_SECTION_KEY), 'ERROR');
        sectionConfig = (Map<String,Object>) sectionsConfig.get(TWIST_FooterUtils.SERVICES_SECTION_KEY);
        System.assert(!sectionConfig.isEmpty(), 'ERROR');

        System.assert(sectionsConfig.containsKey(TWIST_FooterUtils.ABOUT_SECTION_KEY), 'ERROR');
        sectionConfig = (Map<String,Object>) sectionsConfig.get(TWIST_FooterUtils.ABOUT_SECTION_KEY);
        System.assert(!sectionConfig.isEmpty(), 'ERROR');

        System.assert(sectionsConfig.containsKey(TWIST_FooterUtils.CONNECT_SECTION_KEY), 'ERROR');
        sectionConfig = (Map<String,Object>) sectionsConfig.get(TWIST_FooterUtils.CONNECT_SECTION_KEY);
        System.assert(!sectionConfig.isEmpty(), 'ERROR');

        // System.assert(!clientServiceMessageLabel.contains('{{clientServicePhoneNumber}}'), 'ERROR'); // TODO encore utile ? Attente réunion avec les devs de l'API
        // System.assert(clientServiceMessageLabel.contains(clientServicePhoneNumber), 'ERROR');
    }
    
    @isTest
    public static void test_addFooterConfigFromLV_addSocialConfig() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        TWIST_FooterUtils.initFooterConfig(footerConfig);
        
        // When
        TWIST_FooterUtils.addSocialConfig(footerConfig, lvApiResponse, footerLinkBaseUrl);
        
        // Then
        System.assert(footerConfig.containsKey(TWIST_FooterUtils.SOCIAL_KEY), 'ERROR');
        Map<String,Object> socialConfig = (Map<String,Object>) footerConfig.get(TWIST_FooterUtils.SOCIAL_KEY);
        System.assert(!socialConfig.isEmpty(), 'ERROR');
    }

    @isTest
    public static void test_addFooterConfigFromLV_addUkStatementConfig() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        TWIST_FooterUtils.initFooterConfig(footerConfig);
        
        // When
        TWIST_FooterUtils.addUkStatementConfig(footerConfig, lvApiResponse, footerLinkBaseUrl);
        
        // Then
        System.assert(footerConfig.containsKey(TWIST_FooterUtils.UK_STATEMENT_KEY), 'ERROR');
        Map<String,Object> ukStatementConfig = (Map<String,Object>) footerConfig.get(TWIST_FooterUtils.UK_STATEMENT_KEY);
        System.assert(!ukStatementConfig.isEmpty(), 'ERROR');
    }
    
    @isTest
    public static void test_addFooterConfigFromLV_whenCustomExceptionIsThrown() {
        // Given
        Map<String,Object> footerConfig = new Map<String,Object>();
        TWIST_FooterUtils.forceThrowException = true;
        
        // When
        TWIST_FooterUtils.addFooterConfigFromLV(footerConfig, 'https://dummy-url.com/api', 'https://dummy-url.com/', '+0123456789', 'zzz-zz');
        
        // Then
        System.assert(TWIST_UTILS.isMapResponseOfTypeFailureResponseObject(footerConfig), 'ERROR');
    }
    
    @testVisible
    private static Map<String,Object> getLvApiResponse() { // updated on 2023-09-04
        Map<String,Object> response = new Map<String,Object>();
        
        // Adding key "folder"
        response.put('folders', new List<Object> {
            new Map<String,Object> {
                'typeElem' => 'folder',
                'label' => 'Follow Us',
                'content' => new List<Map<String,Object>> {
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_instagram_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Instagram',
                        'url' => 'http://instagram.com/louisvuitton',
                        'iconId' => 'instagram'
                    },
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_facebook_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Facebook',
                        'url' => 'http://www.facebook.com/louisvuitton',
                        'iconId' => 'facebook'
                    },
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_twitter_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Twitter',
                        'url' => 'http://www.twitter.com/louisvuitton',
                        'iconId' => 'twitter'
                    },
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_youtube_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Youtube',
                        'url' => 'http://www.youtube.com/louisvuitton',
                        'iconId' => 'youtube'
                    },
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_snapchat_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'SnapChat',
                        'url' => 'https://us.louisvuitton.com/eng-us/magazine/articles/snapchat',
                        'iconId' => 'snapchat'
                    },
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_pinterest_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Pinterest',
                        'url' => 'http://www.pinterest.com/LouisVuitton/',
                        'iconId' => 'pinterest'
                    },
                    new Map<String,Object> {
                        'icon' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/picture/allcountry/followus/sh_foursquare_white.png',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Foursquare',
                        'url' => 'http://www.foursquare.com/louisvuitton',
                        'iconId' => 'foursquare'
                    }
                },
                'idElem' => 'follow_us'
            }
        });
        // Adding key "legalSection"
        response.put('legalSection', new List<Object> {
            new Map<String,Object> {
                'redirection' => 'internal',
                'typeElem' => 'link',
                'label' => 'Legal Notices',
                'url' => '/eng-us/legal-notices',
                'idElem' => 'legalnotice'
            },
            new Map<String,Object> {
                'redirection' => 'internal',
                'typeElem' => 'link',
                'label' => 'Privacy Policy',
                'url' => '/eng-us/legal-notices#privacy-policy',
                'idElem' => ''
            },
            new Map<String,Object> {
                'redirection' => 'internal',
                'typeElem' => 'link',
                'label' => 'California Supply Chains Act',
                'url' => '/eng-us/california-transparency',
                'idElem' => 'ca_transparency'
            },
            new Map<String,Object> {
                'redirection' => 'scriptLink',
                'typeElem' => 'scriptLink',
                'label' => 'Do Not Sell or Share My Personal Information',
                'script' => 'openCCSettings()',
                'idElem' => 'do not sell or share my personal information'
            },
            new Map<String,Object> {
                'typeElem' => 'folder',
                    'label' => 'MSA Transparency',
                    'content' => new List<Map<String,Object>> {
                     	new Map<String,Object> {
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'LOUIS VUITTON UK 2016 STATEMENT',
                        'url' => 'https://me-i3f.louisvuitton.com/content/dam/lv/online/other/allcountry/legalnotice/LV%20UK%20_%20Modern%20Slavery%20Act%20_%202016%20Signed%20Statement.pdf'
                    }
                },
             'idElem' => 'msa_transparency'
            },
            new Map<String,Object> {
                'label' => 'Confidentialité',
                'redirection' => 'internal',  
                'typeElem' => 'link',
                'url' => '/fra-ca/mentions-legales#confidentialite'
            }
        });
        
        // Adding key "sections"
        response.put('sections', new List<Object> {
            new Map<String,Object> {
                'labelKey' => 'Contact Us',
                'url' => '/eng-us/contact-us',
                'subsections' => new List<Object> {},
                'sectionType' => 'internalLink',
                'identifier' => 'SingleCountries'
            },
            new Map<String,Object> {
                'labelKey' => 'Stores',
                'url' => '/eng-us/stores',
                'subsections' => new List<Object> {},
                'sectionType' => 'externalLink',
                'identifier' => 'NXpfDA'
            },
            new Map<String,Object> {
                'labelKey' => 'Sustainability',
                'url' => '/eng-us/magazine/sustainability',
                'subsections' => new List<Object> {},
                'sectionType' => 'externalLink',
                'identifier' => 'YTdeVe'
            },
            new Map<String,Object> {
                'labelKey' => 'Apps',
                'url' => '/eng-us/apps',
                'subsections' => new List<Object> {},
                'sectionType' => 'internalLink',
                'identifier' => 'apps'
            },
            new Map<String,Object> {
                'labelKey' => 'Follow Us',
                'subsections' => new List<Object> {
                    new Map<String,Object> {
                        'icon' => 'allcountry/followus/sh_instagram_white.png',
                        'labelKey' => 'Instagram',
                        'url' => 'http://instagram.com/louisvuitton',
                        'subsections' => new List<Object> {},
                        'sectionType' => 'externalLink',
                        'iconID' => 'instagram'
                    },
                    new Map<String,Object> {
                        'icon' => 'allcountry/followus/sh_facebook_white.png',
                        'labelKey' => 'Facebook',
                        'url' => 'http://www.facebook.com/louisvuitton',
                        'subsections' => new List<Object> {},
                        'sectionType' => 'externalLink',
                        'iconID' => 'facebook'
                    },
                    new Map<String,Object> {
                        'icon' => 'allcountry/followus/sh_youtube_white.png',
                        'labelKey' => 'Youtube',
                        'url' => 'https://www.youtube.com/louisvuitton',
                        'subsections' => new List<Object> {},
                        'sectionType' => 'externalLink',
                        'iconID' => 'youtube'
                    },
                    new Map<String,Object> {
                        'icon' => 'allcountry/followus/sh_snapchat_white.png',
                        'labelKey' => 'SnapChat',
                        'url' => 'https://us.louisvuitton.com/eng-us/magazine/articles/snapchat',
                        'subsections' => new List<Object> {},
                        'sectionType' => 'externalLink',
                        'iconID' => 'snapchat'
                    },
                    new Map<String,Object> {
                        'icon' => 'allcountry/followus/sh_pinterest_white.png',
                        'labelKey' => 'Pinterest',
                        'url' => 'http://www.pinterest.com/LouisVuitton/',
                        'subsections' => new List<Object> {},
                        'sectionType' => 'externalLink',
                        'iconID' => 'pinterest'
                    },
                    new Map<String,Object> {
                        'icon' => 'allcountry/followus/sh_foursquare_white.png',
                        'labelKey' => 'Foursquare',
                        'url' => 'https://foursquare.com/louisvuitton',
                        'subsections' => new List<Object> {},
                        'sectionType' => 'externalLink',
                        'iconID' => 'foursquare'
                    }
                },
                'sectionType' => 'folder',
                'identifier' => 'follow_us'
            },
            new Map<String,Object> {
                'labelKey' => 'Legal Notices',
                'url' => '/eng-us/legal-notices',
                'subsections' => new List<Object> {},
                'sectionType' => 'internalLink',
                'identifier' => 'legalnotice'
            },
            new Map<String,Object> {
                'labelKey' => 'Privacy Policy',
                'url' => 'https://us.louisvuitton.com/eng-us/legal-notices#privacy-policy',
                'subsections' => new List<Object> {},
                'sectionType' => 'externalLink',
                'identifier' => 'KpBTuS'
            },
            new Map<String,Object> {
                'labelKey' => 'California Supply Chains Act',
                'url' => '/eng-us/california-transparency',
                'subsections' => new List<Object> {},
                'sectionType' => 'internalLink',
                'identifier' => 'ca_transparency'
            },
            new Map<String,Object> {
                'labelKey' => 'Careers',
                'url' => '/eng-us//careers/home',
                'subsections' => new List<Object> {},
                'sectionType' => 'internalLink',
                'identifier' => 'homeVC'
            },
            new Map<String,Object> {
                'labelKey' => '+1.866.VUITTON',
                'url' => 'tel:+1.866.884.8866',
                'subsections' => new List<Object> {},
                'sectionType' => 'externalLink',
                'identifier' => 'XmYQuR'
            },
            new Map<String,Object> {
                'labelKey' => 'Do Not Sell or Share My Personal Information',
                'script' => 'openCCSettings()',
                'subsections' => new List<Object> {},
                'sectionType' => 'scriptLink'
            }
        });
        
        // Adding key "icons"
        response.put('icons', new List<Object> {});
        
        // Adding key "categories"
        response.put('categories', new List<Object> {
            new Map<String,Object> {
                'content' => new List<Object> {
                    new Map<String,Object> {
                        'typeElem' => 'text',
                        'label' => 'Our Client Advisors are available to assist you by phone at <a style="color:black; text-decoration:underline; cursor:pointer;" href="tel:+1.866.VUITTON">+1.866.VUITTON</a>. You can also <a style="color:black; text-decoration:underline; cursor:pointer;" href="https://us.louisvuitton.com/eng-us/contact-us">chat</a> or <a style="color:black; text-decoration:underline; cursor:pointer;" href="https://us.louisvuitton.com/eng-us/email-us">email us</a>.',
                        'description' => 'Our Client Advisors are available to assist you by phone at <a href="tel:{{clientServicePhoneNumber}}">{{clientServicePhoneNumber}}</a>. You can also <a href="https://us.louisvuitton.com/eng-us/contact-us">chat</a> or <a href="https://us.louisvuitton.com/eng-us/email-us">email us</a>.',
                        'isText' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'FAQs',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/faq',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Product Care',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/care-service',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Stores',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/stores',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    }
                },
                'title' => 'Help'
            },
            new Map<String,Object> {
                'content' => new List<Object> {
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Repairs',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/faq/services',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Personalization',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/stories/personalization',
                        'idElem' => 'personalization',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Art of Gifting',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/stories/gifting',
                        'idElem' => 'art_of_gifting',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Download our Apps',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/apps',
                        'idElem' => 'apps',
                        'iconId' => '',
                        'isLink' => true
                    }
                },
                'title' => 'Services'
            },
            new Map<String,Object> {
                'content' => new List<Object> {
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Fashion Shows',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/magazine/fashion-shows',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Arts & Culture',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/magazine/arts-and-culture',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'La Maison',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/magazine/la-maison',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Sustainability',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/magazine/sustainability',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'internal',
                        'typeElem' => 'link',
                        'label' => 'Latest News',
                        'url' => 'https://me-i3f.louisvuitton.com/eng-us/magazine',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Careers',
                        'url' => 'https://jobs.louisvuitton.com/en',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    },
                    new Map<String,Object> {
                        'icon' => '',
                        'redirection' => 'external',
                        'typeElem' => 'link',
                        'label' => 'Foundation Louis Vuitton',
                        'url' => 'https://www.fondationlouisvuitton.fr/en',
                        'idElem' => '',
                        'iconId' => '',
                        'isLink' => true
                    }
                },
                'title' => 'About Louis Vuitton'
            },
            new Map<String,Object> {
                'content' => new List<Object> {
                    new Map<String,Object> {
                        'typeElem' => 'text',
                        'label' => '<a style="color:black; text-decoration:underline; cursor:pointer;" href="https://us.louisvuitton.com/eng-us/mylv/newsletter">Sign up</a> for Louis Vuitton emails and receive the latest news from the Maison, including exclusive online pre-launches and new collections.',
                        'description' => '<a href="https://us.louisvuitton.com/eng-us/mylv/newsletter">Sign up</a> for Louis Vuitton emails and receive the latest news from the Maison, including exclusive online pre-launches and new collections.',
                        'isText' => true
                    }
                },
                'title' => 'Email Sign-Up'
            }
        });
        
        return response;
    }
    
}