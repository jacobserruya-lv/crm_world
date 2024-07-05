({

    setInfoText: function (cmp, helper, values) {
        if (cmp.get('v.localItems').length === 0) {
            cmp.set("v.infoText", "No items to select...");
        }
        else if (values.length == 0) {
            cmp.set("v.infoText", "Select an option...");
        }
        else if (values.length == 1) {
            cmp.set("v.infoText", values[0]);
        }
        else if (values.length > 1) {
            cmp.set('v.infoText', values.length + ((cmp.get('v.type') == "store") ? ' stores' : ' items') + ' selected');
        }
        cmp.set('v.numSelected', values.length);
    },

    handleSelection: function (cmp, event, helper, action) {
        //console.group(cmp.getType() + '.h.handleSelection');
        cmp.set('v.changeFlag', true);
        var item = event.currentTarget;
        if(cmp.get('v.setup') == true){
            
            var event = $A.get("e.c:ProductCatalog3_SetupStoreMultiPicklistSelectEvent");
        }else{
            var event = $A.get("e.c:ProductCatalogMultiPicklistSelectEvent");
        }
       
        var items = cmp.get("v.localItems");
        
        var isMulti = cmp.get('v.multiSelect');
        if(!action){
            var hasStoreCode = (item.dataset.value.indexOf('-') >= 0 && cmp.get('v.title') == 'Stores');
        
            var value = (item.dataset.value !== 'SELECT ALL' && hasStoreCode) ?
                item.dataset.value.substr(0, item.dataset.value.length - 6) : item.dataset.value;
                
            var selected = item.dataset.selected;

        }
        //var selected = item.dataset.selected;

        if (isMulti) {

            if (value === 'SELECT ALL' || action == 'clear' || action == 'select all') {
                if(value === 'SELECT ALL' || action == 'select all'){
                    //var isAllSelected = helper.isStoreSelected(cmp, 'SELECT ALL');
                    items.forEach(function (element) {
                        //element.selected = !isAllSelected;
                        element.selected = true;
                    });
                }else{
                    items.forEach(function (element) {
                        element.selected = false;
                    });
                }
            } 
            else {
                var counter = 0;
                items.forEach(function (element) {
                    if (hasStoreCode && element.value.substr(0, element.value.length - 6) === value) {
                        element.selected = (selected === 'false');
                    }
                    else if (!hasStoreCode && element.value === value) {
                        element.selected = (selected === 'false');
                    }

                    if (element.selected && element.value != 'SELECT ALL') {
                        counter++;
                    }
                });
                if (items.length > 1 && items[0].value == 'SELECT ALL') {
                    items[0].selected = (counter === items.length - 1);
                }
            }
        }
        else {

            items.forEach(function (element) {
                if (hasStoreCode && element.value.substr(0, element.value.length - 6) === value) {
                    element.selected = (selected === 'false');
                }
                else if (hasStoreCode && element.value.substr(0, element.value.length - 6) !== value) {
                    element.selected = false;
                }
                else if (!hasStoreCode && element.value === value) {
                    element.selected = (selected === 'false');
                }
                else if (!hasStoreCode && element.value !== value) {
                    element.selected = false;
                }
            });
            //helper.handleMouseLeave(cmp, event, helper);
        }
        //console.log('items',items);
        cmp.set("v.localItems", items);
        var values = helper.getSelectedValues(cmp);

        helper.setInfoText(cmp, helper, values);

        //console.groupEnd();
    },

    getSelectedValues: function (cmp) {
        //console.group('helper multipicklist getSelectedValues');
        var items = cmp.get("v.localItems");
        //console.log('items ' , items);
        var values = [];
        items.forEach(function (element) {
            if (element.selected && element.value != 'SELECT ALL') {
                values.push(element.value);
            }
        });
        //console.groupEnd();
        return values;
    },

    isStoreSelected: function (cmp, itemToCompare) {
        var items = cmp.get("v.localItems");
        return items && (items.findIndex(function (item) {
            return ((item.value === itemToCompare) && item.selected);
        }) > -1);
    },

    prepareItems: function (cmp, helper, items) {
        //console.group('prepareItems--helper');
        var picklistItems = [];
        var isMulti = cmp.get('v.multiSelect');

        if (cmp.get('v.selectItem') && items != null) {
            //console.log('here changing...');
            var type = typeof items[0];
            //console.log('items', items);
            for (var i = 0; i < items.length; i++) {
                var currentItem;
                var isStore = (cmp.get('v.type') == 'store' || cmp.get('v.name') == 'physicalStores');

                switch (type) {
                    case 'object': {
                        //currentItem = {'value': items[i].name + ' - ' + items[i].retailStoreId, 'selected': (items[i].isDefault || cmp.get('v.selectItem') === items[i].retailStoreId) };
                        currentItem = {
                            'value': items[i].name + ' - ' + items[i].retailStoreId,
                            'selected': (items[i].isDefault || cmp.get('v.selectItem').includes(items[i].retailStoreId)),
                            'myList': (cmp.get('v.mySelectedList').includes(items[i].retailStoreId))
                        };
                        //console.log('current item', currentItem);
                        break;
                    }
                    case 'string': {
                        //currentItem = {'value': items[i], 'selected': isStore ? (cmp.get('v.selectItem') === items[i].substr(items[i].length - 3, items[i].length)) : (cmp.get('v.selectItem') === items[i])};
                        currentItem = {
                            'value': items[i],
                            'selected': isStore ? (cmp.get('v.selectItem').includes(items[i].substr(items[i].length - 3, items[i].length))) : (cmp.get('v.selectItem').includes(items[i])),
                            'myList': isStore ? (cmp.get('v.mySelectedList').includes(items[i].substr(items[i].length - 3, items[i].length))) : (cmp.get('v.mySelectedList').includes(items[i]))
                        };
                        //console.log('current item', currentItem);

                        break;
                    }
                }

                picklistItems.push(currentItem);
            }
        }

        //if(cmp.get('v.selectItem') && items != null && cmp.get('v.name') != 'digitalStores')
        if (cmp.get('v.selectItem') && items != null) {
            cmp.set('v.localItems', picklistItems);
        }
        var selectedValues = helper.getSelectedValues(cmp);

        /*if (items != null && items.length > 1 && isMulti && cmp.get('v.name') != 'ZoneLevel') {
            picklistItems.unshift({ 'value': 'SELECT ALL', 'selected': selectedValues.length == items.length });
        }*/
        if (cmp.get('v.selectItem') && items != null) {
            //console.log('picklistItems', picklistItems);
            cmp.set('v.localItems', picklistItems);
        }
       //console.log('picklistItems', picklistItems);

        //cmp.set('v.dropdownLength', (picklistItems.length > 10) ? 10 : 5);

        helper.setInfoText(cmp, helper, selectedValues);

        //return picklistItems;
        //console.groupEnd();
    },

    handleMouseLeave: function (cmp, event, helper) {
        //console.log('closing...');
        cmp.set('v.dropdownOver', false);
        cmp.set('v.dropdownOpen', false);
        var mainDiv = cmp.find('pc3-multi-picklist');
        //console.log('mainDiv', mainDiv);
        $A.util.removeClass(mainDiv, 'slds-is-open');
        if (cmp.get("v.changeFlag")) {
            var values = helper.getSelectedValues(cmp);
            if(cmp.get('v.setup')){
                var event = $A.get("e.c:ProductCatalog3_SetupStoreMultiPicklistSelectEvent");
            }else{
                var event = $A.get("e.c:ProductCatalogMultiPicklistSelectEvent");
            }
            
            event.setParams({ 'selectedItems': values, 'name': cmp.get('v.name') });
            event.fire();
            // helper.unselectProduct(cmp, event, helper); // TODO: Make it stop crashing
            cmp.set('v.changeFlag', false);
        }
    },

    unselectProduct: function (cmp, event, helper) {
        var myEvent = $A.get('e.c:ProductCatalogItemClickedEvent');
        myEvent.setParams({ 'product': '', 'productsStock': {} });
        myEvent.fire();

        var myEvent2 = $A.get('e.c:ProductCatalogGetSummaryEvent');
        myEvent2.setParams({ 'product': '', 'productClicked': false });
        myEvent2.fire();
    },

    addToMyList: function (cmp, event, helper) {
        //console.group(cmp.getType() + '.h.addToMyList');
        var action = cmp.get('c.AddStoreToMyList');
        var storeName = event.getSource().get('v.value');
        var stores = [];

        if (storeName == 'SELECT ALL') {
            var items = cmp.get('v.localItems');

            //get all stores without the first element that is "ALL"
            for (var i = 1; i < items.length; i++) {
                stores.push(items[i].value);
            }

        } else {
            stores.push(storeName);
            //console.log('storeName', storeName);
            /*action.setParams({
                'storeCode': storeName.substr(storeName.length - 3, storeName.length),
            });*/

        }
        action.setParams({
            'storesCode': stores,
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            //console.log('state',state);
            //helper.hideSpinner(cmp);
            if (state === 'SUCCESS') {
                var pageResult = result.getReturnValue();
                //console.log('pageResult ' , result.getReturnValue());
                cmp.set('v.mySelectedList', pageResult.split(';'));

                //cmp.set('v.productsPrices',pageResult2);

            }
            else if (state === 'ERROR') {
                helper.handleError(result);
            }
            else {
                console.error('Unknown error');
            }

        });
        $A.enqueueAction(action);
        //console.groupEnd();
    },

    handleError: function (response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.error("Error message: " + errors[0].message);
            }
        }
        else {
            console.error("Unknown error");
        }
    },
})