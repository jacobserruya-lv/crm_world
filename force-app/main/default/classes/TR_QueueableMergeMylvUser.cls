/*
    ***************************************************************************************************
    * @File Name          : TR_QueueableMergeMylvUser.cls
    * @Description        : This Queueable was created to work around the error (DML operation on configuration object is not allowed after updating a non-configuration object (or vice versa): User, original object: Account ; getStatusCode = MIXED_DML_OPERATION ;) this is because of a DML operation on a configuration object (User) after having already performed a DML operation on a non-configuration object (Account)
    * @Author             : Imad.alsidchikh
    * @Group              : VO2
    * @Last Modified By   : Imad.alsidchikh 
    * @Last Modified On   : 14-09-2023
    * @Modification Log   :
    * Ver       Date               Author                            Modification
    * 1.0       14-09-2023         Imad.alsidchikh                   Initial Version
    ****************************************************************************************************
    */
    
    public class TR_QueueableMergeMylvUser implements Queueable {
        private List<User> recordsToUpdate;
        private List<User> uniqueUserstoUpdate;
        private  static Set<Id> techMergeIds = new Set<Id>();
        private  Map<String,String> finalUserToAnonymizeTechMerge = new Map<String,String>();
        private  static List<TECH_Merge_Manager__c> listMergeMangerRecoToUpdate = new List<TECH_Merge_Manager__c>();
    
        public TR_QueueableMergeMylvUser(List<User> records) {
            this.recordsToUpdate = records;
            
        }
    
        public void execute(QueueableContext context) {
            if (recordsToUpdate != null && !recordsToUpdate.isEmpty()) {
                
                uniqueUserstoUpdate=removeDuplicates(recordsToUpdate);
                Database.SaveResult[] results = Database.update(uniqueUserstoUpdate, false);
                for(Database.SaveResult re : results){
                //System.debug('result: '+re);
                Datetime currentDatetime = Datetime.now();
                String formattedDatetime = currentDatetime.format('yyyyMMddHHmmssSSS');
                    if(!re.isSuccess()){
                        System.debug('An Error Occured when anonymising User (' +re.getId() +') on '+formattedDatetime+' !');
                    }
                }
            }
        }
        public static List<User> removeDuplicates(List<User> userList) {
            Map<Id, User> userMap = new Map<Id, User>();
    
            for (User user : userList) {
                // Assuming that you want to identify duplicates based on the User Id
                userMap.put(user.Id, user);
            }
    
            // Convert the values of the map (unique Users) back to a list
            List<User> uniqueUsers = new List<User>(userMap.values());
    
            return uniqueUsers;
        }
    }