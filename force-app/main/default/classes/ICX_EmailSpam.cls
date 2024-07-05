public class ICX_EmailSpam {

    /*public static List<Id> checkSpam(List<EmailMessage> newEmailList) {
        // Case Id List to be in Spam
        List<Id> spamCaseIdList = new List<Id>();

        try {
            Map<String, ICX_EmailSpam__mdt> addressSpamMap = getEmailSpamMap('Address Regex');
            Map<String, ICX_EmailSpam__mdt> subjectSpamMap = getEmailSpamMap('Subject');
            
            for (EmailMessage email : newEmailList) {
                Boolean isSpam = false;
                if (email != null && !Label.ICX_NoReplyEmail.equalsIgnoreCase(email.FromAddress) && email.Incoming) {
                    isSpam = manageSpam(email, addressSpamMap, email.FromAddress);
                    if (!isSpam) {
                        isSpam = manageSpam(email, subjectSpamMap, email.Subject);
                    }

                    if (isSpam && String.isNotBlank(email.ParentId)) {
                        spamCaseIdList.add(email.ParentId);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('ERROR Exception:' + e);
        }

        return spamCaseIdList;
    }*/

    /* check if the case is a spam
    * Note: Case is created then EmailMessage
    * @return Map<Case, create case or Spam = true>
    * */
    public static Map<Case, SpamWrapper> checkSpam(List<Case> newCaseList) {
        // Case Id List to be in Spam
        //List<Id> spamCaseIdList = new List<Id>();
        //Map<Case, Boolean> caseSpamMap = new Map<Case, Boolean>();
        Map<Case, SpamWrapper> caseSpamMap = new Map<Case, SpamWrapper>();
        
        try {
            Map<String, ICX_EmailSpam__mdt> addressSpamMap = getEmailSpamMap('Address Regex');
            Map<String, ICX_EmailSpam__mdt> subjectSpamMap = getEmailSpamMap('Subject');
            
            for (Case request : newCaseList) {
                if (request != null && String.isNotBlank(request.SuppliedEmail) && !Label.ICX_NoReplyEmail.equalsIgnoreCase(request.SuppliedEmail)) {
                    String reason;
                    ICX_EmailSpam__mdt emailSpam = findSpam(addressSpamMap, request.SuppliedEmail);
                    if (emailSpam == null) {
                        emailSpam = findSpam(subjectSpamMap, request.Subject);
                        reason = (emailSpam != null ? 'Invalid Subject' : '');
                    } else {
                        reason = 'Invalid Email';
                    }
                    
                    /*if (isSpam && String.isNotBlank(email.ParentId)) {
                        spamCaseIdList.add(email.ParentId);
                    }*/
                    if (emailSpam != null) {
                        SpamWrapper wrapper = new SpamWrapper();
                        wrapper.createCase = emailSpam.CreateCase__c;
                        wrapper.reason = reason;
                        
                        //caseSpamMap.put(request, emailSpam.CreateCase__c);
                        caseSpamMap.put(request, wrapper);
                        /*if (emailSpam.CreateCase__c) {
                            request.Spam__c = true;
                        } else {
                            request.addError('SPAM: ' + request.SuppliedEmail + ' / ' + request.Subject);
                        }*/
                    }
                    
                }
            }
        } catch (Exception e) {
            System.debug('ERROR Exception:' + e);
        }
        
        //return spamCaseIdList;
        return caseSpamMap;
    }

    public class SpamWrapper {
        public Boolean createCase;
        public String reason;
    }
    
    // get Email address or email subject
    // Custom Metadata Type SOQL doesn't count to the governor limit
    private static Map<String, ICX_EmailSpam__mdt> getEmailSpamMap(String type) {
        Map<String, ICX_EmailSpam__mdt> spamMap = new Map<String, ICX_EmailSpam__mdt>();

        if (String.isNotBlank(type)) {
            for (ICX_EmailSpam__mdt spam : [SELECT Id, Value__c, CreateCase__c FROM ICX_EmailSpam__mdt WHERE Type__c = :type]) {
                spamMap.put(spam.Value__c, spam);
            }
        }
        return spamMap;
    }

    /*private static Boolean manageSpam(EmailMessage email, Map<String, ICX_EmailSpam__mdt> spamMap, String matcher) {
        Boolean isSpam = false;
        try {
            ICX_EmailSpam__mdt emailSpam = findSpam(spamMap, matcher);
            if (emailSpam != null) {
                isSpam = true;

                if (emailSpam.CreateCase__c) {
                    email.ICX_Spam__c = true;
                } else {
                    email.addError('email with ' + matcher + ' is considered as a spam');
                }
            }
        } catch (Exception e) {
            System.debug('ERROR Exception:' + e);
        }
        return isSpam;
    }*/

    /*private static Boolean manageSpam(Case request, Map<String, ICX_EmailSpam__mdt> spamMap, String matcher) {
        Boolean isSpam = false;
        try {
            ICX_EmailSpam__mdt emailSpam = findSpam(spamMap, matcher);
            if (emailSpam != null) {
                isSpam = true;

                if (emailSpam.CreateCase__c) {
                    request.Spam__c = true;
                } else {
                    request.addError('email with ' + matcher + ' is considered as a spam');
                }
            }
        } catch (Exception e) {
            System.debug('ERROR Exception:' + e);
        }
        return isSpam;
    }*/

    private static ICX_EmailSpam__mdt findSpam(Map<String, ICX_EmailSpam__mdt> spamMap, String matcher) {
        ICX_EmailSpam__mdt emailSpam;
        
        if (String.isNotBlank(matcher) && spamMap != null) {
            for (String regex : spamMap.keySet()) {
                // Check regex with insentive parameter (?i) and start or end with whatever caracters '.*' 
                if (Pattern.matches('(?i).*' + regex + '.*', matcher)) {
                    emailSpam = spamMap.get(regex);
                    break;
                }
            }
        }
        System.debug('findSpam=');
		return emailSpam;
    }

}