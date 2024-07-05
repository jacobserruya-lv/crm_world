({
    getFiche: function (cmp, event, helper) {
        var product = cmp.get('v.product');
        var Difference_In_Days;
        if (product.pdfUrlDate) {
            var pdfDate = new Date(product.pdfUrlDate);
            var currentdate = new Date();
            var today = new Date(currentdate.getFullYear() + '-'
                + (currentdate.getMonth() + 1) + "-"
                + currentdate.getDate());
            var Difference_In_Time = today.getTime() - pdfDate.getTime();
            Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        }

        if ((product.pdfUrl || product.pdfUrlDate) && Difference_In_Days < 30) {
            cmp.set('v.pdfLink', product.pdfUrl);
        }
        else {
            var action = cmp.get('c.getPDF');

            action.setParams({
                'sku': product.sku,
            });
            action.setCallback(this, function (result) {
                var state = result.getState();
                if (state === 'SUCCESS') {
                    var Link = result.getReturnValue();
                    //cmp.set('v.isStoreFilterExpanded', resultSettings.isOpen__c);
                    if (Link != '') {
                        cmp.set('v.pdfLink', Link);
                    }
                }
                else if (state === 'ERROR') {
                    console.error('requestStatus : ', result.getState());
                }
                else {
                    console.error('Unknown error');
                }
            });
            $A.enqueueAction(action);
        }

    },

    environmentalSectionCountryFilter: function (cmp, event, helper) {

        var selectedStores = cmp.get('v.selectedStores');
        var action = cmp.get('c.environmentalSectionCountryFilter');
        action.setParams({
            'lstStoreCodes': selectedStores,
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === 'SUCCESS') {
                cmp.set('v.isShowEnvironmentalSection', result.getReturnValue());
            }
            else if (state === 'ERROR') {
                console.error('requestStatus : ', result.getState());
            }
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);


        const product = cmp.get('v.product');
        let plasticContain;
        if (product != null && product.Synth > 50) {
            var synthInt = parseInt(product.Synth);
            if (synthInt) {
                plasticContain = "Produit rejetant des microfibres plastiques dans l'environnement lors du lavage";
            }
        }
        cmp.set('v.plasticContain', plasticContain);

    }

})