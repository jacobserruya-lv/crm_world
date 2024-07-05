({
    selectAction: function (component, helper, actionType, actionData) {
        // console.group(component.getType() + '.h.selectAction');
        // console.log(actionType, actionData);
        switch (actionType) {
            case 'prompt':
                helper.openPrompt(actionData, component);
                break;
            case 'modal':
                helper.openModal(actionData, component);
                break;
            case 'modal-med':
                helper.openModal(actionData, component, null, 'medium');
                break;
            case 'modal-large':
                helper.openModal(actionData, component, null, 'large');
                break;
            case 'editBrief':
                helper.editBrief(component);
                break;
            case 'received':
                helper.openReceivedPrompt(component, true);
                break;
            case 'delivered':
                helper.openReceivedPrompt(component, false);
                break;
            case 'post':
                helper.openPostAction(component);
                break;
            case 'link':
                helper.openLink(actionData, component);
                break;
            case 'confirmQuote':
                helper.openModal('MIY_SPO_ConfirmQuotationModal', component, function () {
                    helper.openModal('MIY_SPO_AddDepositModal', component);
                });
                break;
        }
        // console.groupEnd();
    },

    openPrompt: function (cmpName, mainCmp) {
        $A.createComponent(('c:' + cmpName),
            {
                record: mainCmp.get('v.record'),
                workshopName: mainCmp.get('v.workshopName'),
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    mainCmp.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ('cMIY_FancyPrompt slds-modal_prompt c' + cmpName),
                    });
                }
            }
        );
    },
    openModal: function (cmpName, mainCmp, closeCallback, modalSize) {
        $A.createComponent(('c:' + cmpName), {record: mainCmp.get('v.record')},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    mainCmp.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: [
                            'cMIY_FancyModal',
                            modalCmp.getName(),
                            (modalSize ? (' slds-modal_' + modalSize) : ''),
                        ].join(' ').trim(),
                        closeCallback: closeCallback,
                    });
                }
            }
        );
    },
    editBrief: function (mainCmp) {
        var editRecordEvent = $A.get('e.force:editRecord');
        editRecordEvent.setParams({
            'recordId': mainCmp.get('v.record.Id'),
        });
        editRecordEvent.fire();
    },
    openReceivedPrompt: function (mainCmp, receivedMode) {
        $A.createComponent(('c:MIY_SPO_ReceivedModal'), {
                itemData: mainCmp.get('v.record.SpeOrder_Order_Following__r[0]'),
                receivedMode: receivedMode,
                order: mainCmp.get('v.record'),
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    mainCmp.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ('cMIY_FancyPrompt slds-modal_prompt cMIY_ReceivedModal'),
                    });
                }
            }
        );
    },

    warningMsg: function (component, helper) {
        //console.group(component.getType() + '.h.warningMsg');
        if (component.get('v.storeMode')) {
            var statusKey = component.get('v.status.key');
            var statusKeyIdx = component.get('v.status.idx');
            var currentStatusIdx = component.get('v.currentStatusIdx');
            var warningMsg = component.get('v.warningsMap');
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            if (dd < 10) {
                dd = '0' + dd;
            }
            if (mm < 10) {
                mm = '0' + mm;
            }
            today = today.getFullYear() + '-' + mm + '-' + dd;


            if (currentStatusIdx == statusKeyIdx) {
                var warningArr = [];
                var warningArrKeys = Object.keys(warningMsg);
                warningArrKeys.forEach(function (key) {
                    warningArr[key] = warningMsg[key];
                });

                var stageDate;
                var duration;
                var newDateCritical;
                var newDateWarning;
                switch (statusKey) {
                    case 'quotation-in-progress':
                        stageDate = component.get('v.record.SPO_Date_Quotation_in_progress__c');
                        duration = component.get('v.record.Duration_Quotation_in_progress__c');
                        newDateCritical = helper.addDaysToDate(stageDate, warningArr['Quatation In Progress Critical']);
                        if (newDateCritical < today) {
                            component.set('v.status.footerText', helper.formatLabel(
                                $A.get('$Label.c.MIY_OrderPage_Quatation_in_progress_critical_msg'),
                                duration,
                                component.get('v.workshopName')
                            ));
                            component.set('v.status.footerStyle', 'critical');
                        }
                        else {
                            newDateWarning = helper.addDaysToDate(stageDate, warningArr['Quatation In Progress Warning']);
                            if (newDateWarning < today) {
                                component.set('v.status.footerText', helper.formatLabel(
                                    $A.get('$Label.c.MIY_OrderPage_Quatation_in_progress_warning_msg'),
                                    duration,
                                    component.get('v.workshopName')
                                ));
                                component.set('v.status.footerStyle', 'warn');
                            }
                        }
                        break;
                    case 'quotation-submitted':
                        stageDate = component.get('v.record.SPO_Date_Quotation_submitted__c');
                        newDateCritical = helper.addDaysToDate(stageDate, warningArr['Quatation Available Critical']);
                        if (newDateCritical < today) {
                            component.set('v.status.footerText', $A.get('$Label.c.MIY_OrderPage_Quatation_available_critical_msg'));
                            component.set('v.status.footerStyle', 'critical');
                        }
                        else {
                            newDateWarning = helper.addDaysToDate(stageDate, warningArr['Quatation Available Warning']);
                            if (newDateWarning < today) {
                                component.set('v.status.footerText', $A.get('$Label.c.MIY_OrderPage_Quatation_available_warning_msg'));
                                component.set('v.status.footerStyle', 'warn');
                            }
                        }
                        break;
                    case 'creation-in-progress':
                        stageDate = component.get('v.record.SPO_Date_Creation_in_progress__c');
                        newDateCritical = helper.addDaysToDate(stageDate, warningArr['Production To Be Launched Critical']);
                        if (newDateCritical < today) {
                            component.set('v.status.footerText', $A.get('$Label.c.MIY_OrderPage_Production_to_be_launched_critical_msg'));
                            component.set('v.status.footerStyle', 'critical');
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        //console.groupEnd();
    },

    addDaysToDate: function (myDate, numWeeks) {
        var numDays = numWeeks * 7;
        var newDate = new Date(myDate);
        newDate.setDate(newDate.getDate() + numDays);
        var dd = newDate.getDate();
        var mm = newDate.getMonth() + 1;
        if (dd < 10) {
            dd = '0' + dd;
        }
        if (mm < 10) {
            mm = '0' + mm;
        }
        return newDate.getFullYear() + '-' + mm + '-' + dd;
    },

    openPostAction: function (component) {
        // console.group(component.getType() + '.h.openPostAction');
        // component.find('quickActionAPI').selectAction({actionName: 'FeedItem.TextPost'});
        var postEvent = $A.get('e.c:MIY_PostEvent');
        postEvent.fire();

        // console.groupEnd();
    },
    openLink: function (linkUrl, component) {
        // console.group(component.getType() + '.h.warningMsg');
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({'url': linkUrl});
        urlEvent.fire();
        // console.groupEnd();
    },

    formatLabel: function(string) {
        var outerArguments = arguments;
        return string.replace(/{(\d+)}/g, function() {
            return outerArguments[parseInt(arguments[1]) + 1];
        });
    },

});