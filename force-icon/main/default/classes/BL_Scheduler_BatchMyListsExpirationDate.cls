public with sharing class BL_Scheduler_BatchMyListsExpirationDate implements Schedulable{
        public void execute(SchedulableContext sc){
            Database.executeBatch(new BL_ICON_BatchMyListsExpirationDate(),200);
        }
}