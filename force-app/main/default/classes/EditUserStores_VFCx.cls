/*
* Controller of the EditUserStores VFP
* @createdBy   Romain Mouchel-Vallon 30/01/17
*/

public with sharing class EditUserStores_VFCx {

    public final Integer max_stores_per_user;

    // User record
	public final User myUser;
    // Temporary User
    public User currentUser {get; set;}
    // Stores that have been highlighted in the list
    public List<String> selectedStoresClicked {get; set;}
    // Stores that have been added to the list
    public List<selectOption> selectedStoresOptions {get; set;}
    // Map holding store code translations
    private final Map<String, String> picklistTranslationsMap = new Map<String, String>();
    // Should add button be disabled
    public Boolean isAddDisabled {
        get {
            return currentUser.DefaultStore__c == null || isSelected(selectedStoresOptions, currentUser.DefaultStore__c) || selectedStoresOptions.size() >= max_stores_per_user;
        }
    }
    // Should remove button be disabled
    public Boolean isRemoveDisabled {
        get {
            return selectedStoresOptions.isEmpty() || selectedStoresClicked.isEmpty();
        }
    }
    // Is Max nb Stores reached
    public Boolean isMaxNbStores {
        get {
            return selectedStoresOptions.size() >= max_stores_per_user;
        }
    }
    // Warning message
    public String warningMessage {
        get {
            return System.Label.Max_Nb_User_Stores.replace('{0}', '' + max_stores_per_user);
        }
    }

    // Constructor
    public EditUserStores_VFCx() {
        // Retrieving User record
        myUser = [SELECT id, FirstName, LastName, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c, TECH_User_Stores__c FROM User WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        // Deep copy to temporary User to duplicate field values
        currentUser = myUser.clone(false, true, false, false);

        // Initializing translation map
        List<Schema.PicklistEntry> picklistValues = User.DefaultStore__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe : picklistValues){
            picklistTranslationsMap.put(pe.getValue(), pe.getLabel());
        }
        
        // Initializing list
        selectedStoresOptions = new List<selectOption>();
        if (currentUser.TECH_User_Stores__c != null){
            for (String s : currentUser.TECH_User_Stores__c.split(','))
                selectedStoresOptions.add (new selectOption(s, picklistTranslationsMap.get(s)));
        }

        selectedStoresClicked = new List<String>();

        VO_Config__c nb = VO_Config__c.getValues('Max stores per user');
        max_stores_per_user = nb == null || !nb.Value__c.isNumeric() ? 5 : Integer.valueOf(nb.Value__c);
    }

    // Adds selected store to the list if it is not already there
    public void add(){
        if (currentUser.DefaultStore__c != null && !isSelected(selectedStoresOptions, currentUser.DefaultStore__c))
            selectedStoresOptions.add(new selectOption(currentUser.DefaultStore__c, picklistTranslationsMap.get(currentUser.DefaultStore__c)));
    }

    // Remove highlighted store(s) from the list
    public void remove(){
        removeAll(selectedStoresOptions, new Set<String>(selectedStoresClicked));
        selectedStoresClicked.clear();
    }

    // Updates TECH field and saves User record
    public PageReference validate(){
        myUser.TECH_User_Stores__c = '';
        List<String> stores = new List<String>();
        for (selectOption o : selectedStoresOptions)
            stores.add(o.getValue());

        myUser.TECH_User_Stores__c = String.join(stores, ',');

        update myUser;

        // Return to User detail page
        return new PageReference ('/' + myUser.id);
    }

    // cancel
    public PageReference cancel(){
        // Return to User detail page
        return new PageReference ('/' + myUser.id);
    }

    // Returns original list without values to remove
    private void removeAll (List<selectOption> l, Set<String> toRemove){
        List<selectOption> newList = new List<selectOption>();

        for (Integer i = 0; i<l.size(); i++)
            if (!toRemove.contains(l.get(i).getValue()))
                newList.add (new selectOption(l.get(i).getValue(), picklistTranslationsMap.get(l.get(i).getValue())));

        l.clear();
        l.addAll(newList);
    }

    // Returns whether store is in the list
    private Boolean isSelected(List<selectOption> l, String store){
        Boolean isFound = false;

        for (selectOption o : l)
            isFound = isFound || o.getValue() == store;

        return isFound;
    }
}