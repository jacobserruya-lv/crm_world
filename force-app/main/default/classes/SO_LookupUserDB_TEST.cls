@isTest
private class SO_LookupUserDB_TEST {
	
	@isTest 
	public static void searchDBTest (){

        String objectName = 'User';
        String fld_API_Text = 'Name';
        String fld_API_Val = 'Email';
        Integer lim = 20;
        String fld_API_Search = 'Name';
        String searchText = 'SYSTEM';
        String filter = 'AND isActive = true';

        Test.startTest();
        String resultJSON = SO_LookupUserDB.searchDB(objectName, fld_API_Text, fld_API_Val, lim, fld_API_Search, searchText, filter);
        Test.stopTest();

        System.debug (resultJSON);
        List<SO_LookupUserDB.ResultWrapper> result = (List<SO_LookupUserDB.ResultWrapper>) JSON.deserialize(resultJSON, List<SO_LookupUserDB.ResultWrapper>.class);

        System.assert(!result.isEmpty());

        Set<Id> resultIds = new Set<Id>();
        for (SO_LookupUserDB.ResultWrapper r : result){
        	resultIds.add(((User)(r.obj)).id);
        }

        User u = [SELECT id FROM User WHERE Name = 'SYSTEM'];

        System.assert(resultIds.contains(u.id));
	}
	
}