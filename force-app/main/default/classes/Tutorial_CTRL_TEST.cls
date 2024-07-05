/**
*	Test class for the Tutorial page controller
*	Created by RMOU, 10/04/2017
*/

@isTest
public class Tutorial_CTRL_TEST {
	
	@testSetup
	static public void init (){
		List<TutorialEntry__c> tEntries = new List<TutorialEntry__c>();

		tEntries.add(new TutorialEntry__c(category__c = 'category1', subject__c = 'subject1', active__c = true));
		tEntries.add(new TutorialEntry__c(category__c = 'category1', subject__c = 'subject2', active__c = true));
		tEntries.add(new TutorialEntry__c(category__c = 'category2', subject__c = 'subject1', active__c = true));
		tEntries.add(new TutorialEntry__c(category__c = 'category2', subject__c = 'subject3', active__c = true));

		insert tEntries;
	}

	@isTest
	static public void test (){
		Tutorial_CTRL controller = new Tutorial_CTRL();

		Test.setCurrentPage(Page.Tutorial);

		System.assertEquals(4, controller.tEntryWrappers.size());
		System.assertEquals(2, controller.categories.size());
		System.assertEquals(4, controller.subjectsWrappers.size());
	}
}