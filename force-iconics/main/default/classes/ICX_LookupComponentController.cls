public with sharing class ICX_LookupComponentController {

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String anOptionalParam) {
        // We're not using anOptionalParam parameter
        // it's just here to demonstrate custom params
        
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            Account (Id, Name , PersonEmail ,CreatedBy.Name WHERE id NOT IN :selectedIds),
            User (Id, Name, Email WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS];
        
        system.debug('searchResults: '+searchResults );


        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            if(string.isNotEmpty(account.PersonEmail)){
                results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name,  account.PersonEmail));
            }
                
        }

        // Extract Opportunities & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User [] users = ((List<User>) searchResults[1]);
        for (User user : users) {
            results.add(new LookupSearchResult(user.Id, 'User', userIcon, user.Name,user.Email));
        }

        return results;
    }
}