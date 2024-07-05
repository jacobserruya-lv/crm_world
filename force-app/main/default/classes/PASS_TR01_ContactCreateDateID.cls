public without sharing class PASS_TR01_ContactCreateDateID {
  public static void ContactCreateDateID(List<User> userList) {
    List<Profile> profiles =[SELECT Id FROM Profile WHERE Name = 'Identity User' and UserLicense.name ='External Identity'];
    if (profiles.size()>0){
        String identityProfile = profiles[0].Id;
        List<Contact> cToUpdate = new List<Contact>();
          for(User u :userList){
              if(u.ProfileId==identityProfile) {
                  Contact c = new Contact(Id=u.ContactId,
                                          Date_Identity__c=datetime.now());
                      cToUpdate.add(c);
              }
          }
          if(cToUpdate.size()>0){
            update cToUpdate;
          }
    } 
  }
}