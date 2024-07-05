({
    goToOpenCase : function(component, event) {
        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.index; // Get its value i.e. the index

        var caseSelected = component.get("v.openCaseList")[index];
        console.log('caseSelected', caseSelected);

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseSelected.Id
        });
        navEvt.fire();
    },

    goToComplaintCase : function(component, event) {
        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.index; // Get its value i.e. the index

        var caseSelected = component.get("v.complaintList")[index];
        console.log('caseSelected', caseSelected);

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseSelected.Id
        });
        navEvt.fire();
    },

    goToCareService : function(component, event) {
        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.index; // Get its value i.e. the index

        var careSelected = component.get("v.careList")[index];
        //console.log('caseSelected', caseSelected);

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": careSelected.Id
        });
        navEvt.fire();
    }

})