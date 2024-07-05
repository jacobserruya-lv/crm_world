({
	// Sets surveys attribute with related surveys
	getSurveys : function(component) {
		var action = component.get("c.getSurveys");
		action.setParams({
			"accountId" : component.get("v.recordId")
		});
		action.setCallback (this, function(response){
			var state = response.getState();
			if(component.isValid() && state === 'SUCCESS'){
				component.set("v.surveys", response.getReturnValue());
				this.updateNb(component);
			}
		});

		$A.enqueueAction(action);
	},

	// updates number of surveys
	updateNb : function(component){
		var surveys = component.get("v.surveys");

		component.set("v.nbSurveys", surveys.length);
	}
})