import { LightningElement, api, track } from 'lwc';
import getQuickTextList from '@salesforce/apex/ICX_QuickTextControllerLC.getQuickTextList';
import getFolderList from '@salesforce/apex/ICX_QuickTextControllerLC.getFolderList';
import getRecentQuickTextList from '@salesforce/apex/ICX_QuickTextControllerLC.getRecentQuickTextList';
import addRecentlyViewed from '@salesforce/apex/ICX_QuickTextControllerLC.addRecentlyViewed';
import getMergeFields from '@salesforce/apex/ICX_QuickTextControllerLC.getMergeFields';

export default class icx_quickTextLwc extends LightningElement {
    //quickValue = '';
    placeholder = 'Search Quick Text';
    folderWrapperList;
    quickTextList;
    quickTextWrapperList;
    recentQuickTextWrapperList;

    @track searchResults; // track decorator to work in local environment
    hasFocus;
    blurTimeout;
    searchThrottlingTimeout;
    searchTerm;
    focusIndex = 0;
    @track quickTextIdOnMouse; // track decorator to work in local environment
    @api recordId;
    @api channel = 'Email';

    connectedCallback() {
        console.log("connectedCallback");

        getFolderList({ folderType : 'QuickText'})
        .then(result => {
            var folderWrapperList = [];
            this.structureHierarchy(result, null, 1, folderWrapperList);
 
            this.folderWrapperList = folderWrapperList;
            console.log("folderList", this.folderWrapperList);
    
            return getQuickTextList({ channel: this.channel });
        })
        .then(quickTexts => {
            console.log("quickTexts", quickTexts);
            if (quickTexts) {
                this.parse(quickTexts);
            }

            return getRecentQuickTextList({channel : this.channel});
        })
        .then(recentQuickTexts => {
            var folderWrapperList = this.folderWrapperList;
            var recentQuickTextWrapperList = [];
            for (var i = 0; i < recentQuickTexts.length; i++) {
                var recent = recentQuickTexts[i];
                //var quickTextWrapper = quickTextWrapperList.find(element => element.quickText.Id == recent.Id);
                var parentFolderWrapper = folderWrapperList.find(element => element.Id == recent.FolderId);
                var quickTextWrapper = {
                    folderWrapper : parentFolderWrapper,
                    quickText : recent,
                    label : (parentFolderWrapper === undefined ? '' : parentFolderWrapper.Label + ' • ') + recent.Name
                };
                recentQuickTextWrapperList.push(quickTextWrapper);
            }

            this.recentQuickTextWrapperList = recentQuickTextWrapperList;
            console.log("recentQuickTextWrapperList", recentQuickTextWrapperList);

        })
        .catch(error => {
            console.log("Error", error);
        });
        console.log("connectedCallback END");
    }

    // folderWrapperList
    structureHierarchy(folders, parentFolderId, levelNumber, folderWrapperList) {
        var parentFolderWrapper = (parentFolderId === null ? {} : folderWrapperList.find(element => element.Id == parentFolderId));
        //console.log("folders", folders, "parentFolderWrapper", JSON.stringify(parentFolderWrapper), "parentFolderId", parentFolderId, "levelNumber", levelNumber, "folderWrapperList", folderWrapperList);

//        if (folders.data) {
//            var folderResultList = folders.data.filter(element => element.ParentId == parentFolderId);
        if (folders) {
            var folderResultList = folders.filter(element => element.ParentId == parentFolderId);
            //console.log("folderResultList", folderResultList);
            if (folderResultList.length > 0) {
                for (var i = 0; i < folderResultList.length; i++) {
                    var newFolderWrapper = JSON.parse(JSON.stringify(parentFolderWrapper));
                    newFolderWrapper['level' + levelNumber] = folderResultList[i];
                    newFolderWrapper.Id = folderResultList[i].Id;
                    newFolderWrapper.Label = (newFolderWrapper.Label === undefined ? '' : newFolderWrapper.Label + ' • ') + folderResultList[i].Name;
                    folderWrapperList.push(newFolderWrapper);
                    //console.log("newFolderWrapper", newFolderWrapper, "folderResultList[i];", folderResultList[i]);
    
                    // get children folders for the current folder id
                    this.structureHierarchy(folders, folderResultList[i].Id, levelNumber + 1, folderWrapperList);
                }
            }
        }
    }

    parse(quickTexts) {
        this.quickTextList = quickTexts;
	
        var folderWrapperList = this.folderWrapperList;//component.get("v.folderWrapperList");
        //console.log('folderWrapperList', folderWrapperList);

        // Build QuickTextWrapper with the Folder Hierarchy
        var quickTextWrapperList = [];
        for (var i = 0; i < quickTexts.length; i++) {
            let quick = quickTexts[i];
            //console.log('quick', quick);
            
            var parentFolderWrapper = folderWrapperList.find(element => element.Id == quick.FolderId);
            //console.log('parentFolderWrapper', parentFolderWrapper);
            var quickTextWrapper = {
                folderWrapper : parentFolderWrapper,
                quickText : quick,
                label : (parentFolderWrapper === undefined ? '' : parentFolderWrapper.Label + ' • ') + quick.Name
            };
            quickTextWrapperList.push(quickTextWrapper);
        }
        this.quickTextWrapperList = quickTextWrapperList;
        //console.log('quickTextWrapperList', this.quickTextWrapperList);
    }

    handleFocus(event) {
        console.log("handleFocus");
        this.template.querySelector('[data-id="comboboxId"]').classList.remove('slds-hide');

        var recents = this.recentQuickTextWrapperList;
        console.log("recents", recents);
        this.searchResults = recents;
        // Prevent action if selection is not allowed
        /*if (!helper.isSelectionAllowed(component)) {
            return;
        }*/
        this.hasFocus = true;
    }

    get classFocus() {
        //this.template.querySelector('[data-id="comboboxId"]').classList.toggle('slds-hide');

        let basicClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ";
        return basicClass + ((this.hasFocus && Array.isArray(this.searchResults) && this.searchResults.length) ? 'slds-is-open' : 'slds-combobox-lookup');
    }

    handleBlur(event) {
        console.log("handleBlur");
        this.blurTimeout = setTimeout(() =>  {
            this.hasFocus = false;
            this.blurTimeout = null;
            this.template.querySelector('[data-id="comboboxId"]').classList.add('slds-hide');
        }, 300);
    }

    handleInput(event) {
        console.log("handleInput");
        //const newSearchTerm = event.target.value;
        const searchTerm = event.target.value;
        console.log("updateSearchTerm", searchTerm);
        // Cleanup new search term
        const updatedSearchTerm = searchTerm.trim().replace(/\*/g).toLowerCase();
        
        // Compare clean new search term with current one and abort if identical
        const curSearchTerm = this.searchTerm;
        if (curSearchTerm === updatedSearchTerm) {
            return;
        }

        // Update search term
        this.searchTerm = updatedSearchTerm;

        // Ignore search terms that are too small
        if (updatedSearchTerm.length < 2) {
            this.searchResults = [];
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = this.searchThrottlingTimeout;
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }

        searchTimeout = setTimeout(() =>  {
            // Send search event if it long enougth
            const searchTerm = this.searchTerm.toLowerCase();
            if (searchTerm.length >= 2) {
                var quickTextWrapperList = this.quickTextWrapperList;
                var quickTextResultList = quickTextWrapperList.filter(element => element.label.toLowerCase().indexOf(searchTerm) !== -1);

                // sort by label
                quickTextResultList.sort(function(a,b) {
                    if (a.label < b.label) return -1;
                    if (a.label > b.label) return 1;
                    return 0;
                });

                this.searchResults = quickTextResultList;
                //component.set('v.openMenu', true);
                this.focusIndex = null;
            }
            this.searchThrottlingTimeout = null;
        }, 300);

        this.searchThrottlingTimeout = searchTimeout;
    }

    handleComboboxClick(event) {
        console.log("handleComboboxClick");

        // Hide combobox immediatly
        const blurTimeout = this.blurTimeout;
        if (blurTimeout) {
            clearTimeout(blurTimeout);
        }
        this.hasFocus = false;
        this.template.querySelector('[data-id="comboboxId"]').classList.add('slds-hide');
    }

    // handle key pad: https://github.com/appiphony/Strike-Components/tree/master/aura/strike_lookup
    handleInputKeyDown(event) {
        console.log('handleInputKeyDown');
        var KEYCODE_TAB = 9;
        var keyCode = event.which || event.keyCode || 0;

        if (keyCode === KEYCODE_TAB) {
            this.closeMenu(event);
        }
    }

    closeMenu(event) {
        this.focusIndex = null;
        //this.openMenu = false;
    }

    handleInputKeyUp(event) {
        console.log('handleInputKeyUp');
        //if (component.get('v.disabled')) {
        //    return;
        //}

        var KEYCODE_ENTER = 13;
        var KEYCODE_UP = 38;
        var KEYCODE_DOWN = 40;
        var KEYCODE_ESC = 27;

        var keyCode = event.which || event.keyCode || 0;
        console.log('keyCode', keyCode);

        if (keyCode === KEYCODE_ENTER) {
            //console.log('handleInputKeyUp KEYCODE_ENTER', event.currentTarget);
            //const labelId = event.currentTarget.id;
            //console.log("labelId", labelId);
            //helper.selectResult(component, labelId);
            this.updateValueByFocusIndex(event);
        } else if (keyCode === KEYCODE_UP) {
            console.log('handleInputKeyUp KEYCODE_UP');
            this.moveRecordFocusUp(event);
        } else if (keyCode === KEYCODE_DOWN) {
            console.log('handleInputKeyUp KEYCODE_DOWN');
            this.moveRecordFocusDown(event);
        } else if (keyCode === KEYCODE_ESC) {
            this.closeMenu(event);
        } else {
        }
    }

    handleFocusIndexChanged() {
        var focusIndex = this.focusIndex;
        var lookupMenu = this.template.querySelector('.lookupMenuClass');//.getElement();
        console.log("lookupMenu", lookupMenu);
//        component.find('lookupMenu').getElement();

        var searchResults = this.searchResults;
        if (searchResults.length == 0) {
            return;
        }
        console.log('focusIndex', focusIndex);
        if (lookupMenu) {
            var options = lookupMenu.getElementsByTagName('li');
            var focusScrollTop = 0;
            var focusScrollBottom = 0;

            for (var i = 0; i < options.length; i++) {
                var optionSpan = options[i].getElementsByTagName('span')[0];

                if (i === focusIndex) {
                    optionSpan.classList.add('slds-has-focus');
                    this.quickTextIdOnMouse = this.searchResults[i].quickText.Message;
                    //$A.util.addClass(optionSpan, 'slds-has-focus');
                } else {
                    if (i < focusIndex) {
                        focusScrollTop += options[i].scrollHeight;
                    }

                    //$A.util.removeClass(optionSpan, 'slds-has-focus');
                    optionSpan.classList.remove('slds-has-focus');
                }
            }

            if (focusIndex !== null) {
                focusScrollBottom = focusScrollTop + options[focusIndex].scrollHeight;
            }

            if (focusScrollTop < lookupMenu.scrollTop) {
                lookupMenu.scrollTop = focusScrollTop;
            } else if (focusScrollBottom > lookupMenu.scrollTop + lookupMenu.clientHeight) {
                lookupMenu.scrollTop = focusScrollBottom - lookupMenu.clientHeight;
            }
        }
    }

    // https://github.com/appiphony/Strike-Components/blob/master/aura/strike_lookup/strike_lookupHelper.js
    moveRecordFocusUp(event) {
        // var openMenu = component.get('v.openMenu');
 
         //if (openMenu) {
             var focusIndex = this.focusIndex;
             const input = this.template.querySelector('ul');
             input.value = '';
     
             var options = this.searchResults;//component.find('lookupMenu').getElement().getElementsByTagName('li');
             console.log("options", options);
 
             if (focusIndex === null || focusIndex === 0) {
                 focusIndex = options.length - 1;
             } else {
                 --focusIndex;
             }
 
             this.focusIndex = focusIndex;
             this.handleFocusIndexChanged();
         //}
     }
     moveRecordFocusDown(event) {
         //var openMenu = component.get('v.openMenu');
 
         //if (openMenu) {
             var focusIndex = this.focusIndex;
             var options = this.searchResults;//component.find('lookupMenu').getElement().getElementsByTagName('li');
 
             if (focusIndex === null || focusIndex === options.length - 1) {
                 focusIndex = 0;
             } else {
                 ++focusIndex;
             }
 
             this.focusIndex = focusIndex;
             this.handleFocusIndexChanged();
         //}
     }
 
     handleResultClick(event) {
        console.log("handleResultClick");
        //let recordId = event.currentTarget.id;
        let quickTextSelectedId = event.currentTarget.dataset.id;//event.target.dataset.id;
        console.log("quickTextSelectedId", quickTextSelectedId);
        // Save selection
        let searchResults = this.searchResults;
        let selectedResult = searchResults.filter(result => result.quickText.Id === quickTextSelectedId);
        console.log("quickTextSelectedId", quickTextSelectedId, "selectedResult", selectedResult);
        if (selectedResult.length > 0) {
            this.fireEvent(selectedResult[0].quickText);
        }
        // Reset search
        const input = this.template.querySelector('input');
        input.value = '';
        this.quickTextIdOnMouse = null;

        this.searchResults = [];
        this.template.querySelector('[data-id="comboboxId"]').classList.add('slds-hide');
    }

    handleQuickTextMouseEnter(event) {
        let quickTextSelectedId = event.target.dataset.id;
        console.log("quickTextSelectedId", quickTextSelectedId);
        
        let quickList = this.searchResults;
        let quickMessage = quickList.filter(quick => quick.quickText.Id === quickTextSelectedId);
        console.log("quickMessage", quickMessage);

        this.quickTextIdOnMouse = quickMessage[0].quickText.Message;
    }

	fireEvent(quickText) {
        //this.addRecentlyViewed(component, quickText.Id);
        addRecentlyViewed({ quickTextId : quickText.Id});

        // Find all Merge Fields (remove the '}' caracter). Note : remove '{!' gives an compilation error so remove it in a loop
        var regex2 = /(?=\{!)(.*?)(?=\s*\})/gi; // /(?<=\\{!)(.*?)(?=\s*\})/gi;        
        var mergeFieldList = (quickText && quickText.Message ? quickText.Message.match(regex2) : []);
		//console.log("arr3", arr3);
        if (mergeFieldList) {
            for(var i=0; i < mergeFieldList.length; i++) {
                mergeFieldList[i] = mergeFieldList[i].replace('{!', '');
                mergeFieldList[i] = mergeFieldList[i].trim(); // remove useless space
            }
        }
        console.log("mergeFieldList", mergeFieldList);

        var recordId = this.recordId;

        this.getFormattedQuickText(quickText, recordId, mergeFieldList);

        // Reset search
        const input = this.template.querySelector('input');
        input.value = '';
        this.quickTextIdOnMouse = null;

        this.searchResults = [];
        this.template.querySelector('[data-id="comboboxId"]').classList.add('slds-hide');

        // If the user selects a value by Enter key then reset the focusIndex
        this.focusIndex = 0;
    }

	// Add record to RecentlyViewed
    getFormattedQuickText(quickText, recordId, mergeFields) {
        console.log('getFormattedQuickText', quickText.Message, recordId, mergeFields);
        getMergeFields({
            'quickText' : quickText.Message,
            'recordId' : recordId,//'5003D000003kZ5tQAE',//recordId,
            'mergeFieldList' : mergeFields//JSON.stringify(mergeFields)
        })
        .then(quickTextFormatted => {
            console.log('quickTextFormatted', quickTextFormatted);
            
            /*const appEvent = $A.get("e.c:ICX_QuickTextEvent");
            appEvent.setParams({
                "recordId": recordId,
                "quickText" : quickText,
                "quickTextFormatted" : quickTextFormatted
            });
            appEvent.fire();*/
            const selectEvent = new CustomEvent('select', {
                detail: {
                    quickTextFormatted : quickTextFormatted,
                    recordId : recordId
                }
            });
            this.dispatchEvent(selectEvent);
        })
        .catch(error => {
            console.log("Error", error);
        });
    }

    updateValueByFocusIndex(event) {
        var focusIndex = this.focusIndex;

        if (focusIndex == null) {
            focusIndex = 0;
        }

        var records = this.searchResults;

        if (focusIndex < records.length) {
            const updatedSelection = records[focusIndex];
            console.log("updatedSelection", updatedSelection);
            this.fireEvent(updatedSelection.quickText);
            //component.set('v.selection', updatedSelection);
            //component.set('v.value', records[focusIndex].value);
            //component.set('v.valueLabel', records[focusIndex].label);
            //component.set('v.valueSublabel', records[focusIndex].sublabel);
           // component.find('lookupInput').getElement().value = '';

            this.closeMenu(event);
            //sendSelectedEvent(component, updatedSelection);
        } else if (focusIndex === records.length) {
            //helper.addNewRecord(component, event, helper);
        }

        //helper.closeMobileLookup(component, event, helper);
    }
}