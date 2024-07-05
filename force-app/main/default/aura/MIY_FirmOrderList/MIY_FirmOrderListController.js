({
    doInit: function (component, event, helper) {
        // console.group('MIY_FirmOrderList.doInit');
        var firmOrders = component.get('v.listData');
        if (firmOrders != null && firmOrders.length > 0) {
            helper.getHistories(component, firmOrders.map(function (fo) {return fo.Id}));
        }
        // console.groupEnd();
    },
    onItemCheck: function (component, event) {
        // console.group('MIY_FirmOrderList.onItemCheck');
        var id = event.getSource().get('v.recordId');
        var checkedItems = component.get('v.checkedItems');
        var idx = checkedItems.indexOf(id);
        var wasChecked = (idx > -1);

        if (wasChecked) {
            checkedItems.splice(idx, 1);
        } else {
            checkedItems.push(id);
        }

        component.set('v.checkedItems', checkedItems);
        // console.groupEnd();
    },

    toggleSelectAll: function (component) {
        // console.group('MIY_FirmOrderList.toggleSelectAll');

        var listItemCmps = component.find('listItem');
        if (!$A.util.isArray(listItemCmps)) {
            // because .find() sometimes returns a single component
            listItemCmps = [listItemCmps];
        }
        var checkedItems = component.get('v.checkedItems');
        var uncheckableItems = component.get('v.uncheckableItems');
        var wasUnchecked = ((checkedItems.length + uncheckableItems.length) < component.get('v.listData').length);

        listItemCmps.forEach(function(itemCmp) {
            if(itemCmp.get('v.checkable')) {
                itemCmp.set('v.checked', wasUnchecked);
            }
        });

        // console.groupEnd();
    },

    handleShowModal: function (component, evt, helper) {
        var checkedIds = component.get('v.checkedItems');
        var listData = component.get('v.listData');
        var checkedItems = [];
        var isUserInPermissionSetGroup = component.get("v.isUserInPermissionSetGroup"); // MIY-2224

        listData.forEach(function(item) {
            if(checkedIds.indexOf(item.Id) > -1) {
                checkedItems.push(item);
            }
        });


        $A.createComponent("c:MIY_CancelModal",
            {
                onSuccess: component.getReference('c.handleCancelOrders'),
                listData: checkedItems,
                userProfile: component.get('v.userProfile'),
                'isUserInPermissionSetGroup': isUserInPermissionSetGroup // MIY-2224
            },
            function (modalCmp, status) {
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.headerText'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: "cMIY_CancelModal cancel-modal",
                    })
                }
            }
        );
    },

    handleCancelOrders: function (component, evt, helper) {
        var checkedItems = component.get('v.checkedItems');
        var listItemCmps = component.find('listItem');
        if (!$A.util.isArray(listItemCmps)) {
            // because .find() sometimes returns a single component
            listItemCmps = [listItemCmps];
        }

        listItemCmps.forEach(function (itemCmp) {
            if (checkedItems.includes(itemCmp.get('v.recordId'))) {
                itemCmp.set('v.checked', false);
            }
        });
    },

    onItemCancelChange: function (component, event) {
        // console.group('MIY_FirmOrderList.onItemCancelChange');
        var id = event.getSource().get('v.recordId');
        var cancelledItems = component.get('v.cancelledItems');
        var idx = cancelledItems.indexOf(id);
        var wasCancelled = (idx > -1);

        if (wasCancelled) {
            cancelledItems.splice(idx, 1);
        } else {
            cancelledItems.push(id);
        }

        component.set('v.cancelledItems', cancelledItems);
        // console.groupEnd();
    },

    onItemSetUncheckable: function (component, event) {
        // console.group('MIY_FirmOrderList.onItemStatusSet');
        var id = event.getSource().get('v.recordId');
        var uncheckableItems = component.get('v.uncheckableItems');

        if (uncheckableItems.indexOf(id) === -1) {
            uncheckableItems.push(id);
        }
        component.set('v.uncheckableItems', uncheckableItems);
        // console.groupEnd();
    },
})