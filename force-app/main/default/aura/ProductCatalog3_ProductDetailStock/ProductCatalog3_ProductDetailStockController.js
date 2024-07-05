({
    doInit : function(component, helper) {
        //setTimeout(function(){
            var mapObject= component.get('v.mapObject');
            var mapKey = component.get('v.mapKey');
            var outputText = component.find("outputTextId");
        	
        	if(mapObject[mapKey] != null){
            	var result = mapObject[mapKey].split(';')[1];
                if(result != null){
                	outputText.set("v.value",result);    
                } else {
                    outputText.set("v.value", 0);
                }
                
        	}
        
            debugger;
        //}, 3000);
    }
})