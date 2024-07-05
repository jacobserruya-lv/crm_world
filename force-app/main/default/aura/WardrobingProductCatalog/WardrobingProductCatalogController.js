({
	doInit : function(component, event, helper) {

		//console.log(component.get("v.pageReference").state.c__sku);
		var sku=component.get("v.pageReference").state.c__sku;
		//console.log('sku', sku);
		if(sku != null){
			console.log("I have to create a cmp");

			var topPage=[];
			$A.createComponent("c:ProductCatalogFilter", {				
			},

            function(catalogPageFilter, status) {
                if (status === "SUCCESS") {
					//console.log('success');
					topPage.push(catalogPageFilter);
					component.set("v.topPage", topPage);
                }

			});
			var leftPage=[];
			$A.createComponent("c:ProductCatalogList", {
			},
				
				function(catalogPageList, status) {
					if (status === "SUCCESS") {
						//console.log('success');
						leftPage.push(catalogPageList);
						component.set("v.leftPage", leftPage);	
					}
				});
			
			var rightPage=[];
			$A.createComponents([["c:ProductCatalogSummary", {
				}],
				[
					"c:ProductCatalogAvailability", {}
				]],
				function(catalogRightPage, status) {
					if (status === "SUCCESS") {
						//console.log('success summary');
						rightPage.push(catalogRightPage[0]);
						rightPage.push(catalogRightPage[1]);
						component.set("v.right", rightPage);
					}
				});

			var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
		
			myEvent.setParams({ 'searchKey':sku });
			var timer = component.get("v.timer");
			clearTimeout(timer);
			timer = setTimeout(function () {
				
					myEvent.fire();		
				
				component.set('v.timer', null);
			}, 2000);
			component.set("v.timer", timer);
							
           
		}
	},
	
	
	onFilterChange: function (component, event) {
        component.set('v.cleanSearch', event.getParam('searchKey') == '');
    },
})