({
    getStatuses: function (component) {
        // console.group('MIY_FirmOrderListItem.getStatuses');
        var items = [
            {key: 'order-placed', label: $A.get('$Label.c.MIY_OrderPage_List_Item_Status_Order_Placed'), icon: 'basket'},
            {key: 'in-production', label: $A.get('$Label.c.MIY_OrderPage_List_Item_Status_In_Production'), icon: 'tools'},
            {key: 'in-delivery', label: $A.get('$Label.c.MIY_OrderPage_List_Item_Status_In_Delivery'),icon: 'box-cart'},
            {key: 'in-store', label: $A.get('$Label.c.MIY_OrderPage_List_Item_Status_In_Store'), icon: 'store'},
        ];
        if (!component.get('v.isDisplayOrder')) {
            items.push({
                key: 'dlvd-to-client',
                label: $A.get('$Label.c.MIY_OrderPage_List_Item_Status_Delivered_to_Client'),
            });
        }
        items = items.map(function(obj, i) {obj.idx = i; return obj;});
        // console.table(items);
        component.set('v.statuses', items);
        // console.groupEnd();
    },
    getProductSettings: function(component) { //MIY-1969
        var action = component.get('c.getProductSettings');
        action.setCallback(this, function(result) {component.set('v.productSettings', result.getReturnValue());});
        action.setStorable();
        $A.enqueueAction(action);
    },
    setStatus: function (component) {
        this.apexActionPromise(component, 'c.getFOStatusOptions')
            .then($A.getCallback(function (statusOptions) {
                var status = component.get('v.itemData.SPO_FirmOrderStatus__c');
                var isSentToMyPR = false;
                var statusIdx;
                switch (status) {
                    case statusOptions['Cancelled by production']:
                    case statusOptions['Cancelled by store']:
                    case statusOptions['Cancelled - Migrated in Xstore']:
                        component.set('v.cancelled', true);
                        component.set('v.checkable', false);
                    // Fallthrough is intended - equivalent statuses re: path
                    // eslint-disable-next-line no-fallthrough
                    case statusOptions['Creation in progress']:
                        statusIdx = 0;
                        break;
                    case statusOptions['Sent to MyPR']:
                        isSentToMyPR = true;
                    // eslint-disable-next-line no-fallthrough
                    case statusOptions['Production in progress']:
                        statusIdx = 1;
                        break;
                    case statusOptions['Distribution in progress']:
                        statusIdx = 2;
                        break;
                    case statusOptions['Received in store']:
                        statusIdx = 3;
                        break;
                    case statusOptions['Product delivered to client']:
                        statusIdx = 4;
                        break;
                }

                if (statusIdx != undefined) {
                    var statuses = component.get('v.statuses');
                    var currentStatus = statuses[statusIdx];
                    currentStatus.isSentToMyPR = isSentToMyPR;
                    if (statusIdx > 1) {
                        component.set('v.checkable', false);
                    }
                    component.set('v.currentStatus', currentStatus);
                } else {
                    console.error("SPO_FirmOrderStatus__c '" + status + "' " +
                        $A.get('$Label.c.MIY_OrderPage_List_Item_Error_Invalid_Status')
                    );
                }
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
    },
    setImgs: function (component) {
        var item = component.get('v.itemData');
        var productSettings = component.get('v.productSettings'); //MIY-1969
        if (item) {
            var slideSize = (((window.innerWidth - 180) / component.get('v.slideCount')) - 26);
            slideSize = (Math.ceil(slideSize / 100) * 100);
            var slides = [];
            var modalImgs = [];
            var mainImgUrl = item.Product_Image_URL__c;

            if (item.ProductCatalogue__r) {
                if (item.FluidRecipeId__c) {
                    var baseUrl = 'https://configure-imagecomposer.fluidretail.net/recipe/' + item.FluidRecipeId__c + '/image/';

                    // main
                    var mainView;
                    if (item.ProductCatalogue__r.FluidViewImage__c) {
                        mainView = item.ProductCatalogue__r.FluidViewImage__c;
                    } else if (item.ProductCatalogue__r.Category__r) {
                        mainView = item.ProductCatalogue__r.Category__r.FluidViewImage__c;
                    }
                    if (mainView) {
                        mainImgUrl = baseUrl + mainView + '.jpg?width=' + slideSize;
                        modalImgs.push(baseUrl + mainView + '.jpg?width=' + 640);
                    }

                    // slides
                    var slideViews = [];
                    if (item.ProductCatalogue__r.Website_Views__c) {
                        slideViews = item.ProductCatalogue__r.Website_Views__c.split(';');
                    } else if (item.ProductCatalogue__r.Category__r &&
                        item.ProductCatalogue__r.Category__r.Website_Views__c
                    ) {
                        slideViews = item.ProductCatalogue__r.Category__r.Website_Views__c.split(';');
                    }
                    slides = slideViews.map(function (view) {
                        modalImgs.push(baseUrl + view + '.jpg?width=' + 640);
                        return (baseUrl + view + '.jpg?width=' + slideSize);
                    });
                } else if (item.Threekit_Short_Id__c) { //MIY-1969 displaying the images on the salesforce orders for threekit
                    var baseUrl = 'https://admin-fts.threekit.com/api/configurations/' + item.Threekit_Short_Id__c + '/files/';

                    // main
                    var mainView;
                    if (item.ProductCatalogue__r.FluidViewImage__c) {
                        mainView = item.ProductCatalogue__r.FluidViewImage__c;
                    } else if (item.ProductCatalogue__r.Category__r) {
                        mainView = item.ProductCatalogue__r.Category__r.FluidViewImage__c;
                    }
                    if (mainView) {
                        mainImgUrl = baseUrl + mainView + '?orgId=' + productSettings.Threekit_Org_Id__c;
                        modalImgs.push(baseUrl + mainView + '?orgId=' + productSettings.Threekit_Org_Id__c);
                    }

                    // slides
                    var slideViews = [];
                    if (item.ProductCatalogue__r.Website_Views__c) {
                        slideViews = item.ProductCatalogue__r.Website_Views__c.split(';');
                    } else if (item.ProductCatalogue__r.Category__r &&
                        item.ProductCatalogue__r.Category__r.Website_Views__c
                    ) {
                        slideViews = item.ProductCatalogue__r.Category__r.Website_Views__c.split(';');
                    }
                    slides = slideViews.map(function (view) {
                        modalImgs.push(baseUrl + view + '?orgId=' + productSettings.Threekit_Org_Id__c);
                        return (baseUrl + view + '?orgId=' + productSettings.Threekit_Org_Id__c);
                    });
                } else {
                    var imgUrls = [
                        item.ProductCatalogue__r.Image1Url__c,
                        item.ProductCatalogue__r.Image2Url__c,
                        item.ProductCatalogue__r.Image3Url__c,
                        item.ProductCatalogue__r.Image4Url__c,
                        item.ProductCatalogue__r.Image5Url__c,
                    ];
                    imgUrls.forEach(function (url, i) {
                        if (url != null) {
                            modalImgs.push(url + '?width=' + 640);
                            if (i === 0) {
                                mainImgUrl = (url + '?width=' + slideSize);
                            }
                            slides.push(url + '?width=' + slideSize);
                        }
                    });
                }
            }

            component.set('v.mainImg', mainImgUrl);
            component.set('v.itemSlides', slides);
            component.set('v.modalImgs', modalImgs);
        }
    },
    setImgsUpdated: function (component) { // MIY-2207
        var item = component.get('v.itemData');
        var productSettings = component.get('v.productSettings'); //MIY-1969
        console.log('productSettings :>> ', productSettings);
        if (item) {
            var slideSize = (((window.innerWidth - 180) / component.get('v.slideCount')) - 26);
            slideSize = (Math.ceil(slideSize / 100) * 100);
            var slides = [];
            var modalImgs = [];
            var mainImgUrl = item.Product_Image_URL__c;
            console.log('item.Product_Image_URL__c :>> ', item.Product_Image_URL__c);

            if (item.ProductCatalogue__r) {
                console.log('item.FluidRecipeId__c :>> ', item.FluidRecipeId__c);
                if (item.FluidRecipeId__c && /^\d+$/.test(item.FluidRecipeId__c) && item.FluidRecipeId__c.length === 8) {
                    var baseUrl = 'https://configure-imagecomposer.fluidretail.net/recipe/' + item.FluidRecipeId__c + '/image/';

                    // main
                    var mainView;
                    if (item.ProductCatalogue__r.FluidViewImage__c) {
                        mainView = item.ProductCatalogue__r.FluidViewImage__c;
                    } else if (item.ProductCatalogue__r.Category__r) {
                        mainView = item.ProductCatalogue__r.Category__r.FluidViewImage__c;
                    }
                    if (mainView) {
                        mainImgUrl = baseUrl + mainView + '.jpg?width=' + slideSize;
                        modalImgs.push(baseUrl + mainView + '.jpg?width=' + 640);
                    }

                    // slides
                    var slideViews = [];
                    if (item.ProductCatalogue__r.Website_Views__c) {
                        slideViews = item.ProductCatalogue__r.Website_Views__c.split(';');
                    } else if (item.ProductCatalogue__r.Category__r &&
                        item.ProductCatalogue__r.Category__r.Website_Views__c
                    ) {
                        slideViews = item.ProductCatalogue__r.Category__r.Website_Views__c.split(';');
                    }
                    slides = slideViews.map(function (view) {
                        modalImgs.push(baseUrl + view + '.jpg?width=' + 640);
                        return (baseUrl + view + '.jpg?width=' + slideSize);
                    });
                    // MIY-2207 Threekit Ids 
                } else if (item.FluidRecipeId__c &&  (/^[tT][a-z0-9]+$/i.test(item.FluidRecipeId__c) && item.FluidRecipeId__c.length === 8))  { //MIY-1969 displaying the images on the salesforce orders for threekit
                    var baseUrl = productSettings.Threekit_Alpha__c + item.FluidRecipeId__c + '/image/';

                    // main
                    var mainView;
                    if (item.ProductCatalogue__r.FluidViewImage__c) {
                        mainView = item.ProductCatalogue__r.FluidViewImage__c;
                    } else if (item.ProductCatalogue__r.Category__r) {
                        mainView = item.ProductCatalogue__r.Category__r.FluidViewImage__c;
                    }
                    if (mainView) {
                        mainImgUrl = baseUrl + mainView;
                        modalImgs.push(baseUrl + 'Open');
                        modalImgs.push(baseUrl + 'Front');
                        modalImgs.push(baseUrl + 'Side');
                    }

                    // slides
                    var slideViews = ['Open', 'Front', 'Side'];
                    // if (item.ProductCatalogue__r.Website_Views__c) {
                    //     slideViews = item.ProductCatalogue__r.Website_Views__c.split(';');
                    // } else if (item.ProductCatalogue__r.Category__r &&
                    //     item.ProductCatalogue__r.Category__r.Website_Views__c
                    // ) {
                    //     slideViews = item.ProductCatalogue__r.Category__r.Website_Views__c.split(';');
                    // }
                    console.log('slideViews :>> ', slideViews);
                    slides = slideViews.map(function (view) {
                        modalImgs.push(baseUrl + view);
                        return (baseUrl + view);
                    });
                    console.log('slides :>> ', slides);
                } else if (item.Threekit_Short_Id__c)  { //MIY-1969 displaying the images on the salesforce orders for threekit
                    var baseUrl = 'https://admin-fts.threekit.com/api/configurations/' + item.Threekit_Short_Id__c + '/files/';

                    // main
                    var mainView;
                    if (item.ProductCatalogue__r.FluidViewImage__c) {
                        mainView = item.ProductCatalogue__r.FluidViewImage__c;
                    } else if (item.ProductCatalogue__r.Category__r) {
                        mainView = item.ProductCatalogue__r.Category__r.FluidViewImage__c;
                    }
                    if (mainView) {
                        mainImgUrl = baseUrl + mainView + '?orgId=' + productSettings.Threekit_Org_Id__c;
                        modalImgs.push(baseUrl + mainView + '?orgId=' + productSettings.Threekit_Org_Id__c);
                    }

                    // slides
                    var slideViews = [];
                    if (item.ProductCatalogue__r.Website_Views__c) {
                        slideViews = item.ProductCatalogue__r.Website_Views__c.split(';');
                    } else if (item.ProductCatalogue__r.Category__r &&
                        item.ProductCatalogue__r.Category__r.Website_Views__c
                    ) {
                        slideViews = item.ProductCatalogue__r.Category__r.Website_Views__c.split(';');
                    }
                    slides = slideViews.map(function (view) {
                        modalImgs.push(baseUrl + view + '?orgId=' + productSettings.Threekit_Org_Id__c);
                        return (baseUrl + view + '?orgId=' + productSettings.Threekit_Org_Id__c);
                    });
                } else {
                    var imgUrls = [
                        item.ProductCatalogue__r.Image1Url__c,
                        item.ProductCatalogue__r.Image2Url__c,
                        item.ProductCatalogue__r.Image3Url__c,
                        item.ProductCatalogue__r.Image4Url__c,
                        item.ProductCatalogue__r.Image5Url__c,
                    ];
                    imgUrls.forEach(function (url, i) {
                        if (url != null) {
                            modalImgs.push(url + '?width=' + 640);
                            if (i === 0) {
                                mainImgUrl = (url + '?width=' + slideSize);
                            }
                            slides.push(url + '?width=' + slideSize);
                        }
                    });
                }
            }

            component.set('v.mainImg', mainImgUrl);
            component.set('v.itemSlides', slides);
            component.set('v.modalImgs', modalImgs);
        }
    },
    getIsAdmin: function (component) {
        this.apexActionPromise(component,'c.getUserProfileName')
            .then($A.getCallback(function (result) {
                 //added SPO_NomadeMgnt for MIY-1855
                component.set('v.isUserAdmin', 
                (result === 'System Administrator' || result === 'MIY_Admin'|| result==='SPO_NomadeMgnt'));
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
    },
    apexActionPromise: function (component, actionName, params, ignoreExisting, isDebug) {
        return new Promise($A.getCallback(function (resolve, reject) {
            if (typeof isDebug === 'undefined') {isDebug = component.get('v.isDebugMode');}
            var action = component.get(actionName);
            if (params) {
                action.setParams(params);
            }
            if (ignoreExisting) {
                action.setStorable({ignoreExisting: ignoreExisting});
            }
            action.setCallback(this, function (response) {
                if (isDebug) {
                    console.groupCollapsed(component.getType() + '.c.' + action.getName(), Object.assign({}, action.getParams()));
                }
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var returnValue = response.getReturnValue();
                    if (isDebug) {
                        console.log(returnValue);
                    }
                    resolve(returnValue);
                }
                else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            $A.reportError('Error message:', errors[0].message);
                            reject(new Error(errors[0].message));
                        }
                    } else {
                        $A.reportError('Unknown error');
                        reject(new Error('Unknown error'));
                    }
                }
                if (isDebug) {
                    console.groupEnd();
                }
            });
            $A.enqueueAction(action);
        }));
    },

    setOrderLineItemUncheckable: function(component){       
        var userProfile = component.get('v.userProfile');
        var isInferiorVmaxDate__c = component.get('v.itemData.IsInferiorVmaxDate__c');
        var firmOrderStatus = component.get('v.itemData.SPO_FirmOrderStatus__c');
        var productionStatus = component.get('v.itemData.MIY_ProductionStatus__c');
        var check = component.get('v.checkable');
        var erp = component.get('v.itemData.ERP__c');
        var permission = component.get('v.hasPermissionSet'); // MIY-2224
        if(
            !(
                firmOrderStatus == 'Creation in progress'
                &&
                (
                       userProfile == 'System Administrator'
                    || permission 
                    || userProfile == 'MIY_Admin'
                    || userProfile == 'SPO_Other'
                    || userProfile == 'SPO_ExoProduction'
                    || userProfile == 'SPO_Production'
                    || userProfile == 'MIY_Reporting'
                    //MIY-1855
                    || userProfile =='SPO_NomadeMgnt'
                    || ( 
                            ( (new RegExp('ICON_')).test(userProfile) || (new RegExp('ICONiCS_')).test(userProfile) ) 
                            && 
                            (isInferiorVmaxDate__c == true) 
                        )    
                )
            )
            &&
            !(
                firmOrderStatus == 'Production in progress'  && 
                /*(
                    (
                        (
                            userProfile == 'MIY_Admin'
                            || userProfile == 'SPO_Other'
                            || userProfile == 'SPO_ExoProduction'
                            || userProfile == 'SPO_Production'
                            || userProfile == 'MIY_Reporting'
                             //MIY_1855
                            || userProfile =='SPO_NomadeMgnt'
                        )
                        &&
                        productionStatus == '001'   
                    )
                    ||*/
                    (
                        (userProfile == 'System Administrator'
                        ||permission )
                        
                        &&
                        productionStatus != null && typeof productionStatus !== 'undefined'
                        &&
                        productionStatus != '000' && productionStatus != '004' && productionStatus != '005' && productionStatus != '777' && productionStatus != '888' && productionStatus != '999' && productionStatus != '1002'
                        &&
                        (erp == 'JDE' || erp == 'FMS')
                    )                     
               // )
            )
          )
        {  
            component.set('v.checkable', false);
        }
    },
    getUserProfile: function(component) {
        var vari =this;
        this.apexActionPromise(component,'c.getUserProfileName')
            .then($A.getCallback(function (result) {
                console.log(result);
                component.set('v.userProfile',result);
                vari.setOrderLineItemUncheckable(component);
                
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
    },


});