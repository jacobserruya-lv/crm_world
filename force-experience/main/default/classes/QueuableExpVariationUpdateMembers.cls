public with sharing class QueuableExpVariationUpdateMembers implements Queueable{
    private List<Id> experiencesVariationsIdsToCheck =  new List<Id>();
  

    public QueuableExpVariationUpdateMembers(List<Id> expVariationsIds) {
        this.experiencesVariationsIdsToCheck = expVariationsIds;
    }
    
    public void execute(QueueableContext queCont) {
        //execute some logic on objs list
        //perform update
        BatchExperienceVariationUpdateMember bExperienceVar = new BatchExperienceVariationUpdateMember(experiencesVariationsIdsToCheck);
        database.executeBatch(bExperienceVar,200);
    }
}