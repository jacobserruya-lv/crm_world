public class UserTriggerHandler {
    
    //======================================================================//
    // Handler methods go here
    // =====================================================================//
    public static void handleAfterUpdate(List<User> newUserList, List<User> oldUserList, Map<id, User> newUserMap, Map<id, User> oldUserMap)
    {
        removeLicenseForInactiveUsers(newUserList, oldUserMap, 'cnx','LiveMessageUserPsl');
        //addPermSetAssignmentToIconicsUser2(newUserList, oldUserMap, 'LiveMessageUserPsl');
        // addPermSetAssignmentToIconicsUser(newUserList, oldUserMap, 'mySearch');
    
        addPermSetAssignmentToIconicsUser2(newUserList, oldUserMap );


    }

    //======================================================================//
    // Private methods go here
    // =====================================================================//
    
    /**
     * @Description:
     * Helps remove licenses from installed packages for inactive users
     **/
    private static void removeLicenseForInactiveUsers(List<User> newUserList, Map<id, User> oldUserMap, String packageName ,String permissionSetAssignName){
        List<Id> inactiveUserIds = new List<Id>(); 
        Map<Id,UserPackageLicense> userLicenceToRemove = new Map<Id, UserPackageLicense>();
        List<SObject> listToDelete = new List<SObject> ();
         // get the installed package
        List<PackageLicense> packageLicenseList = [ SELECT id 
                                                    FROM PackageLicense 
                                                    WHERE namespacePrefix =: packageName];
        for(User u: newUserList) {
            // get inactive users
            if(!u.isActive && oldUserMap.get(u.id).isActive){
                inactiveUserIds.add(u.id); 
            }
        }
        if(!packageLicenseList.isEmpty() && !inactiveUserIds.isEmpty() ) {
            //get licenses allocated to those inactive users
            userLicenceToRemove = new Map<Id, UserPackageLicense>([ SELECT id , userId
                                                                    FROM UserPackageLicense
                                                                    WHERE PackageLicenseId =: packageLicenseList.get(0).id 
                                                                    AND userId in: inactiveUserIds]);
            listToDelete.addall(userLicenceToRemove.values());                                                      
        }
        // Remove Messaging User For inactive user  
        if(!inactiveUserIds.isEmpty()) {
            List<PermissionSetAssignment> PermissionSetAssignmentList = [SELECT Id, AssigneeId,permissionSetId 
                                                                         FROM PermissionSetAssignment 
                                                                         WHERE AssigneeId IN :inactiveUserIds AND PermissionSet.Name =:'Messaging_User'];
            List<PermissionSetLicenseAssign> PermissionSetLicenseAssignList = [ SELECT Id, AssigneeId,PermissionSetLicenseId 
                                                                                FROM PermissionSetLicenseAssign 
                                                                                WHERE AssigneeId IN :inactiveUserIds AND PermissionSetLicense.DeveloperName =:permissionSetAssignName];
            
                                                                                
            listToDelete.addall(PermissionSetAssignmentList);                                                      
            listToDelete.addall(PermissionSetLicenseAssignList);                                                      
        }
        if(!listToDelete.isEmpty()){
            try{
                // release licenses allocated to inactive users
                Database.delete(listToDelete, false);
            }catch(Exception e){
                system.debug('EXCEPTION CATCHED : ' + e.getMessage());
            }
        }
    }

    /*private static void addPermSetAssignmentToIconicsUser(List<User> newUserList, Map<Id, User> oldUserMap, String permissionSetName) {

        // Check if user becomes Active or with ICONICS profile
        //List<User> newUserList
        //for (User usr : [SELECT Profile.Name, isActive FROM User WHERE Id IN :newUserList AND IsActive = true AND Profile.Name LIKE 'ICONiCS%']) {
        //    if (usr.isActive && usr.isActive != oldUserMap.get(usr.Id).isActive
        //       || usr.ProfileId ) {
        //        
        //    }
        //}

        // filter on users with PermissionSet
        List<Id> userIdWithPermSetList = new List<Id>();
        for (PermissionSetAssignment assign : [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :newUserList AND PermissionSet.Name = :permissionSetName]) {
            userIdWithPermSetList.add(assign.AssigneeId);
        }
        System.debug('userIdWithPermSetList=' + userIdWithPermSetList);

        // Get Permission set Id
        Id permissionSetId;
        try {
            permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1].Id;
        } catch (Exception e) {}

        // Manage PermissionSetAssignment
        if (String.isNotBlank(permissionSetId)) {
            List<PermissionSetAssignment> permSetAssignList = new List<PermissionSetAssignment>();

            for (User usr : [SELECT Profile.Name, isActive FROM User WHERE Id IN :newUserList]) {
                if (usr.Profile.Name.toUpperCase().startsWith('ICONICS_SA') && usr.isActive) {
                    // Add permission set if the user has not it yet
                    if (!userIdWithPermSetList.contains(usr.Id)) {
                        PermissionSetAssignment psa = new PermissionSetAssignment();
                        psa.AssigneeId = usr.Id;
                        psa.PermissionSetId = permissionSetId;
                        permSetAssignList.add(psa);
                    }
                }
            }

            System.debug('permSetAssignList=' + permSetAssignList);
            if (!permSetAssignList.isEmpty()) {
                try {
                    Database.insert(permSetAssignList, false);
                } catch (DmlException e) {
                    // Ok if duplicate
                }
            }
        }
    }*/

    private static void addPermSetAssignmentToIconicsUser2(List<User> newUserList, Map<Id, User> oldUserMap/*, String permissionSetAssignName*/) {

        List<Id> userIdWithPermSetList2 = new List<Id>();
        Map<Id,List<Id>> userIdWithPermSetList = new  Map<Id,List<Id>>();
        List<SObject> permSetAssignList = new List<SObject>();
        List<String> permissionSetName = new List<String>{'mySearch','Live_Agent_User','Omni_Channel_Status_For_China_User'};
       /*List<String> permissionSetName = new List<String>{'Messaging_User','mySearch','Live_Agent_User'};
        Map<String,List<SObject>> permSetAssignMap= new Map<String,List<SObject>>{'LiveMessageUserPsl' => new List<SObject>(),
                                                                          'Messaging_User' => new List<SObject>(),
                                                                          'mySearch' => new List<SObject>(),
                                                                          'Live_Agent_User'=> new List<SObject>()};*/
        Map<String,List<SObject>> permSetAssignMap= new Map<String,List<SObject>>{
        'mySearch' => new List<SObject>(),
        'Live_Agent_User'=> new List<SObject>(),
        'Omni_Channel_Status_For_China_User'=> new List<SObject>()};
        
        
        List<PermissionSet> listPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE Name in :permissionSetName ];
        /*List<PermissionSetLicense> listPermissionSetLicenceId = [SELECT Id ,DeveloperName FROM PermissionSetLicense WHERE DeveloperName  =:permissionSetAssignName limit 1];

        for (PermissionSetLicenseAssign assign : [SELECT Id, AssigneeId,PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId IN :newUserList AND PermissionSetLicense.DeveloperName =:permissionSetAssignName]) {
            userIdWithPermSetList2.add(assign.AssigneeId);
        }*/
        
        for (PermissionSetAssignment assign : [SELECT Id, AssigneeId,permissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :newUserList AND PermissionSet.Name in:permissionSetName]) {
            if(!userIdWithPermSetList.containskey(assign.AssigneeId)){
                userIdWithPermSetList.put(assign.AssigneeId, new List<Id>());
            }
            userIdWithPermSetList.get(assign.AssigneeId).add(assign.permissionSetId);
        }
		list<User> userToUpdate = new list<User>();
        for (User usr : [SELECT Profile.Name,Country__c, isActive ,UserPermissionsLiveAgentUser FROM User WHERE Id IN :newUserList]) {
            if (usr.Profile.Name.toUpperCase().startsWith('ICONICS_SA') && usr.isActive) {
                if(usr.UserPermissionsLiveAgentUser==false){
                      usr.UserPermissionsLiveAgentUser=true;
               		  userToUpdate.add(usr); 
                }
                /*if(!userIdWithPermSetList2.contains(usr.Id) && !listPermissionSetLicenceId.isEmpty()){
                    permSetAssignMap.get(listPermissionSetLicenceId.get(0).DeveloperName).add(createPermissionSetLicenseAssignment(usr.Id,listPermissionSetLicenceId.get(0).Id));

                }*/
                // Add permission set if the user has not it yet
                for(PermissionSet permissionSetId:listPermissionSetId){ 
                    if(permissionSetId.Name == 'Omni_Channel_Status_For_China_User' && usr.Country__c == 'CHINA' && (!userIdWithPermSetList.containskey(usr.Id) || !userIdWithPermSetList.get(usr.Id).contains(permissionSetId.id))){
                        permSetAssignMap.get(permissionSetId.name).add(createPermissionSetAssignment(usr.Id,permissionSetId.id));
                    }
                    if(permissionSetId.Name != 'Omni_Channel_Status_For_China_User' && (!userIdWithPermSetList.containskey(usr.Id) || !userIdWithPermSetList.get(usr.Id).contains(permissionSetId.id))) {
                        permSetAssignMap.get(permissionSetId.name).add(createPermissionSetAssignment(usr.Id,permissionSetId.id));
                    }
                }
            }
        }
        if(!userToUpdate.isEmpty()){
            update userToUpdate; 
        }
        for(List<SObject> l : permSetAssignMap.values()){
            if(!l.isEmpty()){
                permSetAssignList.addAll(l);
            }
        }
        
        if (!permSetAssignList.isEmpty()) {
            try {
                Database.insert(permSetAssignList, false);
            } catch (DmlException e) {
                // Ok if duplicate
            }
        }
    }
    public static PermissionSetAssignment createPermissionSetAssignment(Id userId,Id permissionSetId){
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = permissionSetId;

        return psa;
    }
    /*public static PermissionSetLicenseAssign  createPermissionSetLicenseAssignment(Id userId,Id permissionSetId){
        
        PermissionSetLicenseAssign psa = new PermissionSetLicenseAssign();
        psa.AssigneeId = userId;
        psa.PermissionSetLicenseId = permissionSetId;

        return psa;
    }*/

}