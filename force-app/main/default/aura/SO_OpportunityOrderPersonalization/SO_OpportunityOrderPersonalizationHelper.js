({
    save : function(cmp) {
    	var opp = cmp.get("v.opp");
        console.log("save opp", opp);
        // console.log("save acc", cmp.get("v.account"));

        var action = cmp.get("c.updateOpp");
        action.setParams({
        	"opp" : opp
        });

        action.setCallback(this, function(response){
        	var state = response.getState();
        	if (state === 'SUCCESS'){
		        cmp.set("v.showAction", false);
		        cmp.set("v.mode", "Read");
		        cmp.set("v.showMenu", true);

        		$A.get('e.force:refreshView').fire();
        	} else {
        		console.log("error");
        	}
        });

        $A.enqueueAction(action);

        // //var opp = cmp.get("v.opp");
        // //opp.StageName = "Brief in progress";
        
        // // TODO find on existing app which date to set
        // //opp.CloseDate = new Date();
        
        // //if (!opp.SPO_DisplayOrder__c) {
        //     // TODO upsert account
        //     // then insert opp with accountId
        // //}

        // //console.log("opp to save", opp);
        // var briefFiles = cmp.get("v.briefFiles");
        // var dimensionsFiles = cmp.get("v.dimensionsFiles");
        // var listFiles = briefFiles.concat(dimensionsFiles);
        // var listFilesJSON = $A.util.json.encode(listFiles);
        // var buttonClicked = cmp.get("v.buttonClicked");
        // console.log("This is button Clicked +" + buttonClicked);
        // // for (f : listFiles){
        // //     listFilesJSON.push($A.util.json.encode(f));
        // // }
        // // console.log(listFilesJSON);
        // var action = cmp.get("c.saveOppWithFiles");
        // action.setParams({
        //     "opp" : cmp.get("v.opp"),
        //     "acc" : cmp.get("v.account"),
        //     "listFilesJSON": listFilesJSON,
        //     "buttonName":buttonClicked
        // });
        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     if (state === "SUCCESS") {
        //         var responseStore = response.getReturnValue();
        //         console.log("responseStore", responseStore);
        //         this.navigate(responseStore.Id);
        //     } else if (state === "INCOMPLETE") {
        //         // do something
        //     } else if (state === "ERROR") {
        //         var errors = response.getError();
        //         if (errors) {
        //             if (errors[0] && errors[0].message) {
        //                 console.log("Error message: " + 
        //                             errors[0].message);
        //             }
        //         } else {
        //             console.log("Unknown error");
        //         }
        //     }
        // });
        // $A.enqueueAction(action);        
    },

    // navigate : function (oppId) {
    //     console.log("oppIdto navigate", oppId);
    //     var navEvt = $A.get("e.force:navigateToSObject");
    //     navEvt.setParams({
    //         "recordId": oppId
    //         //"slideDevName": "related"
    //     });
    //     navEvt.fire();
    // },

    findOppById : function(component) {

        if ($A.util.isEmpty(component.get("v.recordId")) === false) {
            
            var action = component.get("c.findOppById");
            action.setParams({
                "oppId" : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseReturn = response.getReturnValue();
                    component.set("v.opp", responseReturn);
                    component.set("v.isMTO", responseReturn.SPO_OrderType__c == "MTO on Catalog (Hardsided)");
                    console.log("responseReturn", responseReturn);
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);        
        }
	},

	setUser : function (component){
		var action = component.get("c.getUserProfile");
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS'){
				var u = response.getReturnValue();
				component.set("v.user", u);
				console.log("init User -> " + u);
			} else {
				console.log("error init User");
			}
		});

		$A.enqueueAction(action);
	}
})