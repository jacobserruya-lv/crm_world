({
    doInit: function(component, event, helper) {
        helper.apexActionPromise(component, 'c.isDebugMode')
            .then($A.getCallback(function (result) {
                component.set('v.isDebugMode', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));

        helper.getProductSettings(component);
        helper.getMaterialAndColorOptions(component);
        if (component.get('v.record') == null) {
            helper.getOrderData(component);
        }
        helper.getUserProfile(component);
        helper.getIsApprover(component);
    },
    editProductDetails: function (component) {
        // console.group(component.getType() + '.editProductDetails');
        component.set('v.editMode', true);
        // console.groupEnd();
    },
    cancelEditProductDetails: function (component) {
        // console.group(component.getType() + '.cancelEditProductDetails');
        component.set('v.editMode', false);
        // console.groupEnd();
    },
    saveProductDetails: function (component) {
        // console.group(component.getType() + '.saveProductDetails');
        component.set('v.isSaving', true);
        var productDetailsEditForm = component.find('productDetailsEditForm');
        productDetailsEditForm.submit();
        // console.groupEnd();
    },
    onSaveProductDetailsSuccess: function (component) {
        component.set('v.record', component.get('v.record'));
        component.set('v.editMode', false);
        component.set('v.isSaving', false);
    },
    colorChanged: function (component, event) {
        // console.groupCollapsed(component.getType() + '.colorChanged');
        var type = event.getParam('type');
        var color = event.getParam('color');
        var colorName = ($A.util.isEmpty(color) === false ? color.Name : '');
        var material = event.getParam('material');
        // console.log(component.get('v.record'));
        // console.log('type:', type);
        // console.log('material:', material);
        // console.log('colorName:', colorName);
        // console.log('color:', color);

        var matAndColOptsMap = component.get('v.materialAndColorOptions');
        var matComp = component.find(type + '-MAT');
        var colComp = component.find(type + '-COL');
        // console.log('matAndColOptsMap:', matAndColOptsMap);
        // console.log('matComp:', matComp);
        // console.log('colComp:', colComp);

        var actualMat = matAndColOptsMap[matComp.get('v.fieldName')].find(function (opt) {
            return opt.toLowerCase().startsWith(material.toLowerCase());
        });
        var actualCol = matAndColOptsMap[colComp.get('v.fieldName')].find(function (opt) {
            return opt.toLowerCase().startsWith(colorName.toLowerCase());
        });
        // console.log('actualMat:', actualMat);
        // console.log('actualCol:', actualCol);

        matComp.set('v.value', actualMat);
        colComp.set('v.value', actualCol);

        // console.groupEnd();
    },

    changeOtherComment: function(component, event) {
        // console.group(component.getType() + '.changeOtherComment');

        var type = event.getParam('type');
        var othComp = component.find(type + '-OTH');
        othComp.set('v.value', event.getParam('comment'));

        // console.groupEnd();
    },

  

    handleCheck: function (component, event) {
        // console.group(component.getType() + '.handleCheck');
        var source = event.getSource();
        var isChecked = source.get('v.checked');
        var yesNo = (isChecked ? 'Yes' : 'No');
        // console.log(source.get('v.name'), isChecked);
        component.set('v.' + source.get('v.name'), isChecked);
        component.set('v.record.' + source.get('v.name'), yesNo);
        // console.groupEnd();
    },
    handleFileUploadFinished: function (component) {
        var fileUploadEvent = $A.get('e.c:MIY_FileUpload');
        fileUploadEvent.setParams({'recordId': component.get('v.record.Id')});
        fileUploadEvent.fire();
    },
});