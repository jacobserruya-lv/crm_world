({
    openPostAction: function (component) {
        // console.group(component.getType() + '.openPostAction');
        component.set('v.selectedTabId', 'collab');
        component.find('quickActionAPI').selectAction({actionName: 'FeedItem.TextPost'});
        // console.groupEnd();
    },
    handleRecordUpdated: function (component) {
        // console.group(component.getType() + '.handleRecordUpdated');
        if(component.get('v.record').ApplicationSource__c == 'SPO') {
            component.set('v.selectedTabId', 'details');
        } else {
            component.set('v.selectedTabId', 'collab');
        }
        // console.groupEnd();
    },
//MIY-1808 disable posting on collaboration based on user profile and order type (CA and Perso =>hide posting)
    doInit: function (cmp, evt, helper) {
       
        helper.getUserProfile(cmp);
        console.log("USER PROFILE " + cmp.get("v.userProfile"))

    },
    
})