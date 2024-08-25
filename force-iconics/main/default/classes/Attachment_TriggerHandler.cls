public class Attachment_TriggerHandler {
    
    public static void afterInsert(List<Attachment> newAttachments) {
        //Attachment_TriggerHandler.createFileForEmailMessages(newAttachments);
    }

    /*public static void createFileForEmailMessages(List<Attachment> newAttachments) {
        List<ContentVersion> CVs = new List<ContentVersion>();
        Map<Integer, Id> indexParentMap = new Map<Integer, Id>();
        Map<Id, Id> cvParentMap = new Map<Id, Id>();
        Integer index = 0;
        List<Id> toDelete = new List<Id>();
        //Map<Id,EmailMessage> emails = new Map<Id,EmailMessage>();

        // Loop over the new attachments to find EmailMessage attachments
        for (Attachment a : newAttachments) {
            if (a.ParentId.getSObjectType() == EmailMessage.sObjectType) {
                // Create ContentVersion for each attachment
                ContentVersion cv = new ContentVersion();
                cv.VersionData = a.Body;
                cv.Title = a.Name;
                cv.PathOnClient = a.Name;
                // Add the new ContentVersion instance to a list
                CVs.add(cv.clone());

                // Save the index of a specific ContentVersion object in the list associated with his parent EmailMessage
                indexParentMap.put(index, a.ParentId);
                index++;

                // Save all the attachments in list to delete them after the process
                toDelete.add(a.Id);

                // Save the EmailMessage that will set Has_Files__c to true
                //if(emails.get(a.ParentId) == null) {
                //            emails.put(a.ParentId, new EmailMessage(Id = a.ParentId, Has_Files__c = true));
                //}
            }
        }

        if (CVs.size() > 0) {
            // Create the ContentVersion records - now we will have Ids
            Database.insert(CVs, false);
            
            List<Id> CvIDs = new List<Id>();
            //Map<Id, ContentDistribution> cvDistributionMap = new Map<Id, ContentDistribution>();
            for (Integer j=0; j<index; j++) {
                // Collect all the ContentVersion Ids for the query
                CvIDs.add(CVs[j].Id);
                // Save the connection between the ContentVersion record & the parentId that should be used for the ContentDocumentLink
                cvParentMap.put(CVs[j].Id, indexParentMap.get(j));
                //cvDistributionMap.put(CVs[j].Id, new ContentDistribution(ContentVersionId = CVs[j].Id, RelatedRecordId = indexParentMap.get(j)));
            }
            
            List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
            // Get all related ContentDocumentIds & create the ContentDocumentLink
            CVs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN : CvIDs];
            for (ContentVersion cv : CVs) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = cvParentMap.get(cv.Id);
                cdl.ShareType = 'V';
        //cdl.Visibility = 'AllUsers';
                CDLs.add(cdl.clone());

            }
            Database.insert(CDLs, false);

            //Database.insert(cvDistributionMap.values(), false);

            // Update the Has_Files__c of the emailMessages where the HasAttachments is false
            //List<EmailMessage> emailDetails = [SELECT Id, HasAttachment, Has_Files__c FROM EmailMessage WHERE Id IN : emails.keyset()];
            //for (EmailMessage e : emailDetails) {
            //    if (e.HasAttachment == true || e.Has_Files__c == true) {
            //        emails.remove(e.Id);
            //    }
            //}
            //Database.update(emails.values(), false);

            //deleteAttachments(toDelete);
        }
    }

    @future
    public static void deleteAttachments(List<Id> toDelete) {
        // Delete the old Attachments
        List<Attachment> toDeleteList = [SELECT Id FROM Attachment WHERE Id in : toDelete];
        Database.delete(toDeleteList, false);
    }*/
}