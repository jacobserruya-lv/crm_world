({
	
	productClicked : function(cmp) {
		var product = cmp.get('v.product');
        var productsStock = cmp.get('v.productsStock');
        var myEvent = $A.get('e.c:ProductCatalogItemClickedEvent');
        myEvent.setParams({ 'product': product , 'productsStock': productsStock });
        myEvent.fire();
        
    },

	productSelected : function(cmp, evt) {
        // console.group('--ProductCatalogListItemController.productSelected--');
        var product = cmp.get('v.product');
        // console.log(cmp.get('v.isSelected'), product.sku, product.id);
        if (cmp.get('v.isSelected')) {
            var viewedEvent = $A.get('e.c:ProductCatalogSelected');
            viewedEvent.setParams({ 'product': product});
            viewedEvent.fire();
        }
        // console.groupEnd();
    },

    doInit: function(cmp, event, helper) {
        //console.group('--ProductCatalogListItemController.doInit--');
        //console.log('selectedZone' , cmp.get('v.selectedZone'));

        var product = cmp.get('v.product');
        var slides = [];

        for (var i = 1; i <= 5; i++) {
            if (product['image' + i + 'Url']) {
                slides.push(product['image' + i + 'Url'].split(' ').join('%20'));
            }
        }
        cmp.set("v.slides", slides);
        cmp.set('v.product', product);

        cmp.get('v.isSelected'); // if this is removed, it breaks recently viewed 🤷‍

        if (((product.status == 30 || product.status == 50 || product.status == 55 || product.status == 60) && !product.persoProduct) || (product.status == 60 && product.persoProduct)){
            var statusText = $A.getReference('$Label.c.Product_Referantial_Status_' + product.status + '_Short');
            cmp.set('v.statusText', statusText);
        }

        /*if(cmp.get('v.productsStock') != null){
            helper.addDigitalLabel(cmp,event,helper);
        }*/
        helper.isInFavorites(cmp,event,helper);
        helper.getFiche(cmp, event, helper);

        //console.groupEnd();
    },

    handleMouseEnter : function(cmp, event, helper) {
        var popover = cmp.find('title');
        if ($A.util.isUndefined(popover) === false) {
        	$A.util.removeClass(popover,'slds-hide');
        }
    },
    
    handleMouseLeave : function(cmp, event, helper) {
        var popover = cmp.find('title');
        if ($A.util.isUndefined(popover) === false) {
	        $A.util.addClass(popover,'slds-hide');
        }
    },

	fullScreen : function(component, event, helper) {
        var modalBody;
        $A.createComponent("c:ProductCatalogFullScreenPicCarousel", {
                "slides": component.get('v.slides'),
                "details": component.get('v.product.detailedDescription'),
                "productData": component.get('v.selectedProductData'),
                "slideIndex": component.get('v.currentSlideIdx'),
                "product": component.get('v.product'),
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        body: modalBody,
                        showCloseButton: false,
                        cssClass: "slds-modal_medium"
                    })

                }

            });

    },

	closeDialog : function(cmp) {
        cmp.set("v.fullScreen", false);
	},
    
    /*addDigitalLabel: function(cmp, event, helper) {
	    helper.addDigitalLabel(cmp,event,helper);
	},

    addPrices: function(cmp, event, helper) {
       // console.log('change price');
        helper.addPrices(cmp,event,helper);
    },*/

    favorite: function(cmp, event, helper) {
	    //console.log('in favorite');
	    event.stopPropagation();
	    helper.manageFavorites(cmp, event,helper);
    },
    
    isFavorite: function(cmp, event, helper) {
    	helper.isInFavorites(cmp,event,helper);
    },
    
    createLook: function(cmp, event) {
        event.stopPropagation();
        var url = $A.get("{!$Label.c.ProductCatalogCreateLookLink}");
        var product = cmp.get('v.product');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url + product.sku
        });
        urlEvent.fire();
    },

    getFiche: function(cmp, event, helper) {
        event.stopPropagation();
        //helper.getFiche(cmp, event, helper);
        var cookie = $A.get("$Label.c.ProductCatalogPdfCookie");
        var Link = cmp.get('v.pdfLink');
        Link = Link+'?'+cookie;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": Link,
        });
        urlEvent.fire();
    }, 

    nowyours: function(cmp, event,helper) {
        event.stopPropagation();
        var url = $A.get("{!$Label.c.ProductCatalogNYLink}");
        var product = cmp.get('v.product');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url + product.id
        });
        urlEvent.fire();
    }
    
})