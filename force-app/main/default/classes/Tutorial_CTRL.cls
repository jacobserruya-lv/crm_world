/**
     * Controller of the Tutorial page.
     * @createdBy   RMOU ,  07/04/2017
     */

public with sharing class Tutorial_CTRL {

	// Set of categories
	public Set<String> categories {
		get;
		private set;
	}

	// List of subjects with corresponding category
	public List<SubjectWrapper>subjectsWrappers {
		get;
		private set;
	}

	// List of Tutorial Entries
	public List<tEntryWrapper> tEntryWrappers {
		get;
		private set;
	}


	// Contructor
	public Tutorial_CTRL() {
		categories = new Set<String>();
		subjectsWrappers = new List<SubjectWrapper>();
		tEntryWrappers = new List<tEntryWrapper> ();

		// Map used to temporarily store Category / Subject hierarchy
		Map<String, Set<String>> mapSubjectsByCategories = new Map<String, Set<String>>();

		Map<Id, TutorialEntry__c> tEntryMap = new Map<Id, TutorialEntry__c> ([SELECT id, Title__c, Description__c, DocType__c, Subject__c, Category__c, Type__c, Language__c, Active__c, URL__c FROM TutorialEntry__c WHERE Active__c = true order by Subject__c ]);
		List<ContentDocumentLink> listFiles = new List<ContentDocumentLink>();

		if (!tEntryMap.isEmpty()){
			Set<Id> tEntryIds =tEntryMap.keySet();
			listFiles = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :tEntryIds ORDER BY ContentDocument.LastModifiedDate DESC];
		}

		// Filling up the various lists and sets
		for (TutorialEntry__c tEntry : tEntryMap.values()){
			categories.add(tEntry.category__c);
			tEntryWrappers.add(new tEntryWrapper(tEntry, tEntry.DocType__c == 'Vidéo' ? null : getFileId(listFiles, tEntry.id)));

			if (mapSubjectsByCategories.containsKey(tEntry.category__c)){
				mapSubjectsByCategories.get(tEntry.category__c).add(tEntry.subject__c);
			}
			else{
				mapSubjectsByCategories.put(tEntry.category__c, new Set<String>{tEntry.subject__c});
			}
		}

		// Filling list of Category / Subject pairs from the map
		for (String category : mapSubjectsByCategories.keySet()){
			for (String subject : mapSubjectsByCategories.get(category)){
				subjectsWrappers.add (new SubjectWrapper(subject, category));
			}
		}
	}

	// Returns the FileId for the corresponding TutorialEntry, null if it there is none
	private Id getFileId (List<ContentDocumentLink> listFiles, Id tId){
		for (ContentDocumentLink cdl : listFiles){
			if (cdl.LinkedEntityId == tId){
				return cdl.ContentDocumentId;
			}
		}

		return null;
	}

	// Wrapper class holding Category / Subject pairs used by the visualforce page
	public class SubjectWrapper{
		public String subject {get; set;}
		public String category {get; set;}

		public SubjectWrapper (String s, String c){
			subject = s;
			category = c;
		}
	}

	// Wrapper class holding TutorialEntries / FileId pairs used by the visualforce page
	public class tEntryWrapper{
		public TutorialEntry__c tEntry {get; set;}
		public Id fileId {get; set;}

		public tEntryWrapper (TutorialEntry__c t, Id i){
			tEntry = t;
			fileId = i;
		}
	}

}