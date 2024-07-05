({
    getOpportunity : function(component) {
        
        var recId =  component.get('v.recordId');
        
        if (recId) {
            var action = component.get('c.findById');
            action.setParams({
                'oppId': recId,
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                
                if (state === 'SUCCESS') {
                    var result = a.getReturnValue();
                    component.set('v.opp', result);
                    this.getColorMap(component);
                    //this.createTab(component, result);
                }
            });
            $A.enqueueAction(action);
            
        } else {
            this.getColorMap(component);
        }
    },

    // get picto from SPO_Colors__c object
    getColorMap: function(component) {
        // console.groupCollapsed(component.getType() + '.h.getColorMap');
        var opp = component.get('v.opp');
		console.log('opp', opp);
        
        // TODO find a better way to create a list
        var colorListString = opp.SPO_ExteriorMaterialColor1__c + ';' + opp.SPO_ExteriorMaterialColor2__c + ';'
        + opp.SPO_ExteriorMaterialColor3__c + ';' + opp.SPO_LiningInteriorColor1__c + ';' + opp.SPO_LiningInteriorColor2__c;
        colorListString = colorListString.toUpperCase();

        var colorList = colorListString.split(';');
        // console.log('colorList', colorList);
        
        /*var colorList = [];
        colorList.push({
            value: opp.SPO_ExteriorMaterialColor1__c
        });
        colorList.push({
            value: opp.SPO_ExteriorMaterialColor2__c
        });
        colorList.push({
            value: opp.SPO_ExteriorMaterialColor3__c
        });*/
                
        var action = component.get('c.getPictoColorMap');
        action.setParams({
            'colorListNames': colorList,
        });
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var colorResult = response.getReturnValue();
                //console.log('colorResult=' + JSON.stringify(colorResult));

                // workaround to create a map
                //console.log('opp.SPO_ExteriorMaterialColor1__c',opp.SPO_ExteriorMaterialColor1__c);
                var map = {
                    'EXT1': (opp.SPO_ExteriorMaterialColor1__c != undefined ? colorResult[opp.SPO_ExteriorMaterialColor1__c] : ''),
                    'EXT2': (opp.SPO_ExteriorMaterialColor2__c != undefined ? colorResult[opp.SPO_ExteriorMaterialColor2__c] : ''),
                    'EXT3': (opp.SPO_ExteriorMaterialColor3__c != undefined ? colorResult[opp.SPO_ExteriorMaterialColor3__c] : ''),
                    'INT1': (opp.SPO_LiningInteriorColor1__c != undefined ? colorResult[opp.SPO_LiningInteriorColor1__c] : ''),
                    'INT2': (opp.SPO_LiningInteriorColor2__c != undefined ? colorResult[opp.SPO_LiningInteriorColor2__c] : ''),
                };
                //console.log('map', map);

                component.set('v.colorMap', map);
            } else {
                // console.log('result KO');
            }
        });
        action.setStorable();
        $A.enqueueAction(action);
        // console.groupEnd();
    },
    
    setUser : function (component){
        // console.groupCollapsed(component.getType() + '.h.setUser');
		var action = component.get('c.getUserProfile');
        // var menu = component.get('v.showMenu');
        // console.log('showMenu >> ' + JSON.stringify(menu));
        //var opp = component.get("v.opp");
        //console.log("Opp >> " + JSON.stringify(opp));
		action.setCallback(this, function(response){
            // console.groupCollapsed(component.getType() + '.c.getUserProfile');

            var state = response.getState();
			if (state === 'SUCCESS'){
				var u = response.getReturnValue();
				component.set('v.user', u);
				// console.log("init User -> " + JSON.stringify(u));
			} else {
				// console.log("error init User");
			}
            // console.groupEnd();
		});

		$A.enqueueAction(action);
		// console.groupEnd();
	},

    getJSONList : function(component){
        var action = component.get('c.getSPAPersonalizationJson');

        action.setCallback(this,function(response){
            // console.groupCollapsed(component.getType() + '.c.getSPAPersonalizationJson');

            var state = response.getState();

            if (state === 'SUCCESS'){
                var record = response.getReturnValue();
                component.set('v.creationTypeList',  JSON.parse(record.CREATIONTYPE));
                component.set('v.colorMetalicList', JSON.parse(record.COLORMETALIC));
                // console.log("init User -> " + JSON.stringify(record));
            } else {
                // console.log("error init User");
            }
            // console.groupEnd();
        });

        $A.enqueueAction(action);
    },

});