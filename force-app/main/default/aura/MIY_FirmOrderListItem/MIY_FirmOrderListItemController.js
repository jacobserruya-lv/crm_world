({
    doInit: function (component, event, helper) {
        // console.group('MIY_FirmOrderListItem.doInit');
        helper.apexActionPromise(component, 'c.isDebugMode')
            .then($A.getCallback(function (result) {
                component.set('v.isDebugMode', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));

        helper.getStatuses(component);
        helper.setStatus(component, event, helper);
        helper.getProductSettings(component); //MIY-1969
        helper.setImgs(component, event, helper);
        helper.setImgsUpdated(component); //MIY-2207
        helper.getIsAdmin(component);
        
        if (component.get('v.isSingle')) {
            component.set('v.expanded', true);
        }

        if (component.get('v.itemData.Undefined_Material__c')) {
            var productSku = component.get('v.itemData.ProductSKU__c');
            helper.apexActionPromise(component, 'c.getExoLeatherOptions', {genericSku: productSku})
                .then($A.getCallback(function (result) {
                    var niloticusElem = result.find(function (element) {
                        return element.apiName.includes('Niloticus');
                    });
                    if (niloticusElem && niloticusElem.sku != null) {
                        component.set('v.productSku', productSku + ' / ' + niloticusElem.sku);
                    }
                }))
                .catch($A.getCallback(function (e) {
                    console.error(e);
                }));
        }

        helper.setOrderLineItemUncheckable(component);
    },

    toggleExpand: function (component) {
        // console.group('MIY_FirmOrderListItem.toggleExpand');
        var expanded = component.get('v.expanded');
        component.set('v.expanded', !expanded);
        // console.groupEnd();
    },

    changeSlide: function (component, event) {
        // console.group('MIY_FirmOrderListItem.changeSlide');
        event.stopPropagation();
        var dirValue = event.getSource().get('v.value');
        var currentSlideIdx = component.get('v.currentSlideIdx');
        var slides = component.get('v.itemSlides');
        var newSlide = currentSlideIdx;

        if (dirValue === 'next' && currentSlideIdx < (slides.length - 1)) {
            newSlide = (currentSlideIdx + 1);
        } else if (dirValue === 'prev' && currentSlideIdx > 0) {
            newSlide = (currentSlideIdx - 1);
        } else if (dirValue >= 0 && dirValue <= (slides.length - 1)) {
            newSlide = dirValue;
        }

        if (newSlide !== currentSlideIdx) {
            component.set('v.currentSlideIdx', newSlide);
        }
        // console.groupEnd();
    },

    reactivate: function (component) {
        component.set('v.cancelled', false);
    },

    handleUpdateEvent: function (component, event, helper) {
        var cmpData = component.get('v.itemData');
        // console.group(component.getType() + '.handleUpdateEvent', cmpData);
        if (cmpData.Id == event.getParam('objectId')) {
            event.stopPropagation();

            var evtOldData = event.getParam('oldData');
            var evtNewData = event.getParam('newData');
            component.set('v.itemData', evtNewData);
            if (evtNewData.SPO_FirmOrderStatus__c) {
                helper.setStatus(component);
            }
            if (evtOldData.ProductCatalogue__c != evtNewData.ProductCatalogue__c) {
                // helper.setImgs(component);
                helper.setImgsUpdated(component);
            }

        }
        // console.groupEnd();
    },

    imgClick: function (component, event) {
        // console.group('MIY_FirmOrderListItem.imgClick');
        var imgSrc = event.getSource().get('v.value');
        if (imgSrc.indexOf('?') > -1 && !imgSrc.includes('threekit')) { //MIY-1969 added the threekit check
            imgSrc = imgSrc.substring(0, imgSrc.indexOf('?')) + '?width=640';
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

    addHistory: function (component) {
        // console.groupCollapsed(component.getType() + '.addHistory');
        var statuses = component.get('v.statuses');
        var itemId = component.get('v.recordId');
        var foHistory = null;
        var historyMap = component.get('v.historyMap');

        if (historyMap) {
        //  console.log('here with 5555', historyMap);
            foHistory = historyMap[itemId];
        }
        // console.log(itemId);
        // console.table(foHistory);
        if (foHistory != null) {
            statuses = statuses.map(function (obj) {
                var dateEntry = foHistory.find(function (historyEntry) {
                    switch (obj.key) {
                        case 'order-placed':
                            return historyEntry.NewValue == 'Creation in progress';
                        case 'in-production':
                            return (historyEntry.NewValue == 'Production in progress'
                                || historyEntry.NewValue == 'Sent to MyPR');
                        case 'in-delivery':
                            return historyEntry.NewValue == 'Distribution in progress';
                        case 'in-store':
                            return historyEntry.NewValue == 'Received in store';
                        case 'dlvd-to-client':
                            return historyEntry.NewValue == 'Product delivered to client';
                    }
                });
                if (dateEntry) { obj.date = new Date(dateEntry.CreatedDate); }
                return obj;
            });
            statuses = statuses.map(function (obj, i, array) {
                if ((i + 1) < array.length) {
                    var nextDate = array[i + 1].date || new Date();
                    if (nextDate != null && obj.date != null) {
                        obj.daysInStatus = Math.floor((nextDate - obj.date) / (1000 * 60 * 60 * 24));
                    }
                }
                return obj;
            });
        }
        // console.table(statuses);
        component.set('v.statuses', statuses);
        // console.groupEnd();
    },
    selectFunctionToUse: function(component, helper) {
        var isUpdatedFunctionEnabled = component.get("v.isUpdatedFunctionEnabled");
        if (isUpdatedFunctionEnabled) {
            helper.setImgsUpdated(component);
        } else {
            helper.setImgs(component);
        }
    }
});