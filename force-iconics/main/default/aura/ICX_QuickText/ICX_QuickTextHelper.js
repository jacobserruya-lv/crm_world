({
    parse: function(component, result) {
        var quickTexts = result.getReturnValue();
        //console.log('quickTexts', quickTexts);
        component.set('v.quickTextList', quickTexts);
        //var parents = { undefined: { items: [] }};
        //quickTexts.forEach(quickText => parents[quickText.Id] = { items: [], name: quickText.Id, label: "Quick Text: " + quickText.Name, expanded: false});
        // quickTexts.forEach(quickText => { if(quickText.Folder.ParentId) { account.Contacts.forEach(contact => parents[account.Id].items.push({items: [], name: contact.Id, label: "Contact: "+contact.Name, expanded: false}))}});
        //quickTexts.forEach(quickText => parents[quickText.ParentId].items.push(parents[quickText.Id]));
        //component.set("v.data", parents[undefined].items);
	
        var folderWrapperList = component.get("v.folderWrapperList");

        // Build QuickTextWrapper with the Folder Hierarchy
        var quickTextWrapperList = [];
        for (var i = 0; i < quickTexts.length; i++) {
            let quick = quickTexts[i];
            
            var parentFolderWrapper = folderWrapperList.find(element => element.Id == quick.FolderId);
            var quickTextWrapper = {
                folderWrapper : parentFolderWrapper,
                quickText : quick,
                label : ($A.util.isEmpty(parentFolderWrapper) ? '' : parentFolderWrapper.Label + ' • ') + quick.Name
            };
            quickTextWrapperList.push(quickTextWrapper);
        }
        component.set("v.quickTextWrapperList", quickTextWrapperList);
        console.log('quickTextWrapperList', quickTextWrapperList);
    },

    getFolders : function(component, event) {
        var action = component.get("c.getFolderList");
        action.setParams({
            'folderType' : 'QuickText'
        });
        action.setCallback(this, function(result){
            if (result.getState() === "SUCCESS") {
                var folders = result.getReturnValue();
                console.log('getFolders', folders);
                //component.set("v.folders", folders);
                
                var folderWrapperList = [];
                this.structureHierarchy(component, folders, null, 1, folderWrapperList);
                console.log("CALLBACK", folderWrapperList);
                component.set("v.folderWrapperList", folderWrapperList);                
            }
        });
        $A.enqueueAction(action);
    },

/*    getInit : function(component, event) {
        var channel = component.get("v.channel");

        var action = component.get("c.getQuickTextWrapper");
        action.setParams({
            'channel' : channel,
            'folderType' : 'QuickText'
        });
        action.setCallback(this, function(result){
            if (result.getState() === "SUCCESS") {
                var returnValue = result.getReturnValue();
                component.set("v.folders", returnValue.folderList);
                component.set("v.quickTextList", returnValue.quickTextList);
                component.set("v.recentQuickTextList", returnValue.recentQuickTextList);
                
                // build Folder Hierarchy
                var folderWrapperList = [];
                this.structureHierarchy(component, returnValue.folderList, null, 1, folderWrapperList);
                console.log("CALLBACK", folderWrapperList);
                component.set("v.folderWrapperList", folderWrapperList);        
                
                // Build Quick Text Wrapper with Folder Hierarchy
                var quickTextWrapperList = [];
                for (var i = 0; i < returnValue.quickTextList.length; i++) {
                    let quick = returnValue.quickTextList[i];
            
                    var parentFolderWrapper = folderWrapperList.find(element => element.Id == quick.FolderId);
                    var quickTextWrapper = {
                        folderWrapper : parentFolderWrapper,
                        quickText : quick,
                        label : ($A.util.isEmpty(parentFolderWrapper) ? '' : parentFolderWrapper.Label + ' • ') + quick.Name
                    };
                    quickTextWrapperList.push(quickTextWrapper);
                }
                component.set("v.quickTextWrapperList", quickTextWrapperList);
                console.log('quickTextWrapperList', quickTextWrapperList);
            }
        });
        $A.enqueueAction(action);  
    },*/

    getRecentQuickTexts : function(component, event) {
        var action = component.get("c.getRecentQuickTextList");
        action.setParams({
            'channel' : 'Email'
        });
        action.setCallback(this, function(result){
            if (result.getState() === "SUCCESS") {
                var recents = result.getReturnValue();
                console.log('recents', recents);
                //component.set("v.recentQuickTextList", recents);

                //var quickTextWrapperList = component.get("v.quickTextWrapperList");
                var folderWrapperList = component.get("v.folderWrapperList");
                var recentQuickTextWrapperList = [];
                for (var i = 0; i < recents.length; i++) {
                    var recent = recents[i];
                    //var quickTextWrapper = quickTextWrapperList.find(element => element.quickText.Id == recent.Id);
                    var parentFolderWrapper = folderWrapperList.find(element => element.Id == recent.FolderId);
                    var quickTextWrapper = {
                        folderWrapper : parentFolderWrapper,
                        quickText : recent,
                        label : ($A.util.isEmpty(parentFolderWrapper) ? '' : parentFolderWrapper.Label + ' • ') + recent.Name
                    };
                    recentQuickTextWrapperList.push(quickTextWrapper);
                }

                component.set("v.recentQuickTextWrapperList", recentQuickTextWrapperList);
                console.log("recentQuickTextWrapperList", recentQuickTextWrapperList);
            }
        });
        $A.enqueueAction(action);
    },

    // folderWrapperList
    structureHierarchy : function(component, folders, parentFolderId, levelNumber, folderWrapperList) {
        //var folderWrapperList = component.get("v.folderWrapperList");

        var parentFolderWrapper = ($A.util.isEmpty(parentFolderId) ? {} : folderWrapperList.find(element => element.Id == parentFolderId));
        //console.log("parentFolderWrapper", JSON.stringify(parentFolderWrapper), "parentFolderId", parentFolderId, "levelNumber", levelNumber, "folderWrapperList", folderWrapperList);

        var folderResultList = folders.filter(element => element.ParentId == parentFolderId);
        //console.log("folderResultList", folderResultList);
        if (folderResultList.length > 0) {
            for (var i = 0; i < folderResultList.length; i++) {
                var newFolderWrapper = JSON.parse(JSON.stringify(parentFolderWrapper));
                newFolderWrapper['level' + levelNumber] = folderResultList[i];
                newFolderWrapper.Id = folderResultList[i].Id;
                newFolderWrapper.Label = ($A.util.isEmpty(newFolderWrapper.Label) ? '' : newFolderWrapper.Label + ' • ') + folderResultList[i].Name;
                folderWrapperList.push(newFolderWrapper);
                //console.log("newFolderWrapper", newFolderWrapper, "folderResultList[i];", folderResultList[i]);

                // get children folders for the current folder id
                this.structureHierarchy(component, folders, folderResultList[i].Id, levelNumber + 1, folderWrapperList);
            }
        } 
    },

    /*    structureHierarchy : function(component, folders, parentFolderId, levelNumber, folderWrapperList) {
        //var folderWrapperList = component.get("v.folderWrapperList");

        var parentFolderWrapper = ($A.util.isEmpty(parentFolderId) ? {} : folderWrapperList.find(element => element.Id == parentFolderId));
        //console.log("parentFolderWrapper", JSON.stringify(parentFolderWrapper), "parentFolderId", parentFolderId, "levelNumber", levelNumber, "folderWrapperList", folderWrapperList);

        var folderResultList = folders.filter(element => element.ParentId == parentFolderId);
        //console.log("folderResultList", folderResultList);
        if (folderResultList.length > 0) {
            for (var i = 0; i < folderResultList.length; i++) {
                var newFolderWrapper = JSON.parse(JSON.stringify(parentFolderWrapper));
                newFolderWrapper['level' + levelNumber] = folderResultList[i];
                newFolderWrapper.Id = folderResultList[i].Id;
                newFolderWrapper.Label = ($A.util.isEmpty(newFolderWrapper.Label) ? '' : newFolderWrapper.Label + ' • ') + folderResultList[i].Name;
                folderWrapperList.push(newFolderWrapper);
                console.log("newFolderWrapper", newFolderWrapper, "folderResultList[i];", folderResultList[i]);
                //component.set("v.folderWrapperList", folderWrapperList);

                // get children folders for the current folder id
                this.structureHierarchy(component, folders, folderResultList[i].Id, levelNumber + 1, folderWrapperList);
            }
        } 
    },
*/
    selectResult : function(component, recordId) {
        // Save selection
        const searchResults = component.get('v.searchResults');
        const selectedResult = searchResults.filter(result => result.quickText.Id === recordId);
        console.log("recordId", recordId, "selectedResult", selectedResult);
        if (selectedResult.length > 0) {
            this.fireEvent(component, selectedResult[0].quickText);

            //const selection = component.get('v.selection');
            //selection.push(selectedResult[0]);
            //component.set('v.selection', selection);

            //console.log("selectResult", JSON.stringify(selection));
            /*const searchEvent = component.getEvent('onSearchAction');
            searchEvent.setParams({
                "action": "ADD",
                "recordId": recordId,
                "item" : selectedResult[0]
            });
            searchEvent.fire();*/
        }
        // Reset search
        const searchInput = component.find('searchInput');
        searchInput.getElement().value = '';
        //component.set('v.searchTerm', '');
        component.set('v.searchResults', []);
    },

    updateSearchTerm : function(component, searchTerm) {
        // Cleanup new search term
        const updatedSearchTerm = searchTerm.trim().replace(/\*/g).toLowerCase();
        
        // Compare clean new search term with current one and abort if identical
        const curSearchTerm = component.get('v.searchTerm');
        if (curSearchTerm === updatedSearchTerm) {
            return;
        }

        // Update search term
        component.set('v.searchTerm', updatedSearchTerm);

        // Ignore search terms that are too small
        if (updatedSearchTerm.length < 2) {
            component.set('v.searchResults', []);
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = component.get('v.searchThrottlingTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                // Send search event if it long enougth
                const searchTerm = component.get('v.searchTerm').toLowerCase();
                if (searchTerm.length >= 2) {
                	var quickTextWrapperList = component.get("v.quickTextWrapperList");
                	var quickTextResultList = quickTextWrapperList.filter(element => element.label.toLowerCase().indexOf(searchTerm) !== -1);

                    // filter to search text
                    //const result = values.filter(word => word.label.includes(searchTerm));
                    //console.log("result", result);
                    
                    // sort by label
                    quickTextResultList.sort(function(a,b) {
                        if (a.label < b.label) return -1;
                        if (a.label > b.label) return 1;
                        return 0;
                    });

                	component.set('v.searchResults', quickTextResultList);
                    //component.set('v.openMenu', true);
                    component.set('v.focusIndex', null);
                }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },

    // https://github.com/appiphony/Strike-Components/blob/master/aura/strike_lookup/strike_lookupHelper.js
    moveRecordFocusUp: function(component, event, helper) {
       // var openMenu = component.get('v.openMenu');

        //if (openMenu) {
            var focusIndex = this.focusIndex;
            var options = component.find('lookupMenu').getElement().getElementsByTagName('li');

            if (focusIndex === null || focusIndex === 0) {
                focusIndex = options.length - 1;
            } else {
                --focusIndex;
            }

            this.focusIndex =  focusIndex;
        //}
    },
    moveRecordFocusDown: function(component, event, helper) {
        //var openMenu = component.get('v.openMenu');

        //if (openMenu) {
            var focusIndex = component.get('v.focusIndex');
            var options = component.find('lookupMenu').getElement().getElementsByTagName('li');

            if (focusIndex === null || focusIndex === options.length - 1) {
                focusIndex = 0;
            } else {
                ++focusIndex;
            }

            component.set('v.focusIndex', focusIndex);
        //}
    },

    updateValueByFocusIndex: function(component, event, helper) {
        var focusIndex = component.get('v.focusIndex');

        if (focusIndex == null) {
            focusIndex = 0;
        }

        var records = component.get('v.searchResults');

        if (focusIndex < records.length) {
            const updatedSelection = records[focusIndex];
            console.log("updatedSelection", updatedSelection);
            this.fireEvent(component, updatedSelection.quickText);
            //component.set('v.selection', updatedSelection);
            //component.set('v.value', records[focusIndex].value);
            //component.set('v.valueLabel', records[focusIndex].label);
            //component.set('v.valueSublabel', records[focusIndex].sublabel);
           // component.find('lookupInput').getElement().value = '';

            helper.closeMenu(component, event, helper);
            //helper.sendSelectedEvent(component, updatedSelection);
        } else if (focusIndex === records.length) {
            //helper.addNewRecord(component, event, helper);
        }

        //helper.closeMobileLookup(component, event, helper);
    },

    closeMenu: function(component, event, helper) {
        component.set('v.focusIndex', null);
        component.set('v.openMenu', false);
    },

	fireEvent : function(component, quickText) {
        this.addRecentlyViewed(component, quickText.Id);

        //var regex = /{!(.*?)}/;
        //var mergeFieldList = (!$A.util.isEmpty(quickText) && !$A.util.isEmpty(quickText.Message) ? quickText.Message.split(regex) : []);
		//console.log("mergeFieldList", mergeFieldList);
        
        //quickText = quickText.replace(/{!\s*(.*?)\s*}/g, '');
        //console.log('quickText replace', quickText);

        // Find all Merge Fields (remove the '}' caracter). Note : remove '{!' gives an compilation error so remove it in a loop
        var regex2 = /(?=\{!)(.*?)(?=\s*\})/gi; // /(?<=\\{!)(.*?)(?=\s*\})/gi;        
        var mergeFieldList = (!$A.util.isEmpty(quickText) && !$A.util.isEmpty(quickText.Message) ? quickText.Message.match(regex2) : []);
		//console.log("arr3", arr3);
        if (!$A.util.isEmpty(mergeFieldList)) {
            for(var i=0; i < mergeFieldList.length; i++) {
                mergeFieldList[i] = mergeFieldList[i].replace('{!', '');
                mergeFieldList[i] = mergeFieldList[i].trim(); // remove useless space
            }
        }

        var recordId = component.get("v.recordId");

        console.log("mergeFieldList", mergeFieldList);
        this.getFormattedQuickText(component, quickText, recordId, mergeFieldList);

        //console.log("fireEvent>quickText", quickText, "recordId", recordId);
        //const searchEvent = component.getEvent('onSearchAction');
    },

	// Add record to RecentlyViewed
    getFormattedQuickText : function(component, quickText, recordId, mergeFields) {
        console.log('getFormattedQuickText', quickText.Message, recordId, mergeFields);
        var action = component.get("c.getMergeFields");
        action.setParams({
            'quickText' : quickText.Message,
            'recordId' : recordId,//'5003D000003kZ5tQAE',//recordId,
            'mergeFieldList' : mergeFields//JSON.stringify(mergeFields)
        });
        action.setCallback(this, function(result) {
            if (result.getState() === "SUCCESS") {
                var quickTextFormatted = result.getReturnValue();
                console.log('quickTextFormatted', quickTextFormatted);
                
                const appEvent = $A.get("e.c:ICX_QuickTextEvent");
                appEvent.setParams({
                    "recordId": recordId,
                    "quickText" : quickText,
                    "quickTextFormatted" : quickTextFormatted
                });
                appEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

	// Add record to RecentlyViewed
    addRecentlyViewed : function(component, quickTextId) {
        var action = component.get("c.addRecentlyViewed");
        action.setParams({
            'quickTextId' : quickTextId
        });
        action.setCallback(this, function(result) {
            if (result.getState() === "SUCCESS") {
            }
        });
        $A.enqueueAction(action);
    },

})