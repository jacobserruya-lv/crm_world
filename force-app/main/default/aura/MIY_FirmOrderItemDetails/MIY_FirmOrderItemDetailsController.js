({
    doInit: function (component, event, helper) {
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
        monthDigit = '0' + monthDigit;
        }
        var dayDigit = today.getDate();
        if(dayDigit <= 9){
        dayDigit = '0' + dayDigit;
        }
       var myDate = today.getFullYear() + "-" + monthDigit + "-" + dayDigit;
       component.set('v.today',myDate );

       // "Adjust Mfg Date" button visibility
       var firmOrderStatus = component.get('v.itemData.SPO_FirmOrderStatus__c');
       var etlStatus = component.get('v.itemData.SPO_TechETLStatus__c');
       var productCategory = component.get('v.itemData.ProductCategory__c');
       if(
            firmOrderStatus == 'Creation in progress'
            &&
            (
                etlStatus == 'V' // Perso order validated
                ||
                etlStatus == null || typeof etlStatus === 'undefined' // is empty
                ||
                productCategory == null || typeof productCategory === 'undefined' // is empty 
                ||
                (productCategory != null && typeof productCategory !== 'undefined' && productCategory.toLowerCase() != 'leather goods') // case insensitive check
            )
         ) 
       {
           component.set('v.showAdjustMfgDateButton', true);
       }
    },

    checkboxClick: function (component) {
        // console.group('MIY_FirmOrderListItem.checkboxClick');
        var checked = component.get('v.checked');
        component.set('v.checked', !checked);
        // console.groupEnd();
    },

    
    adjustDateClick: function (component, event) {
        // console.group('MIY_FirmOrderListItem.receivedClick');
        var itemData = component.get('v.itemData');
        var button = event.getSource().getLocalId();
        $A.createComponent('c:MIY_AdjustMfgDateModal', {record: itemData, adjustDate: button},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: 'cMIY_FancyModal miy-fancy-modal cMIY_AdjustMfgDateModal',
                    });
                }
            }
        );
        // console.groupEnd();
    },
    receivedClick: function (component) {
        // console.group('MIY_FirmOrderListItem.receivedClick');
        var itemData = component.get('v.itemData');
        var currentStatus = component.get('v.currentStatus');
        var confirmInStock = (currentStatus.idx < 2 || itemData.DistributionStatus__c != 'Sent from regional WH');
        $A.createComponent('c:MIY_ReceivedModal', {
                itemData: itemData,
                confirmInStock: confirmInStock,
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: 'cMIY_FancyPrompt miy-fancy-prompt cMIY_ReceivedModal received-modal slds-modal_prompt',
                    });
                }
            }
        );
        // console.groupEnd();
    },
    deliveredClick: function (component) {
        // console.group('MIY_FirmOrderListItem.deliveredClick');
        var itemData = component.get('v.itemData');
        $A.createComponent('c:MIY_ReceivedModal', {
                itemData: itemData,
                receivedMode: false,
                headerText: $A.get('$Label.c.MIY_OrderPage_List_Item_Delivered_to_Client_Btn'),
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: 'cMIY_FancyPrompt miy-fancy-prompt cMIY_ReceivedModal received-modal slds-modal_prompt',
                    });
                }
            }
        );
        // console.groupEnd();
    },

    //when clicking on the image on the left side of the line items list
    imgClick: function (component, event) {
        // console.group('MIY_FirmOrderListItem.imgClick');
        var imgSrc = event.getSource().get('v.value');
        if (imgSrc.indexOf('?') > -1 && !imgSrc.includes('threekit')) { //MIY-1969 added the threekit check
            imgSrc = imgSrc.substring(0,imgSrc.indexOf('?') + '?width=6400');
        }
        // console.log(event.getSource().get("v.value"), imgSrc);

        $A.createComponent('img', {src: imgSrc},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        body: modalCmp,
                        showCloseButton: true,
                        cssClass: 'slds-text-align_center',
                    });
                }
            }
        );
        // console.groupEnd();
    },

    handleEditClick: function (component, event) {
        var itemId = event.getSource().get('v.value');
        var editRecordEvent = $A.get('e.force:editRecord');
        editRecordEvent.setParams({'recordId': itemId});
        editRecordEvent.fire();
    },

});