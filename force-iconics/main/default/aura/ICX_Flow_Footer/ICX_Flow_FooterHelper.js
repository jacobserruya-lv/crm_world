({
    buildCustomButtons : function(component, event) {
        var apiList = component.get("v.customButtonList");
        console.log("apiList footer", apiList);

        if (!$A.util.isEmpty(apiList)) {
            //var res = apiList.split(",");
            if (!$A.util.isEmpty(apiList)) {

                var apiListSplit = apiList.split(",");

                var jsonResult = [];
                //var labelList = component.get("v.labelList");
                //var labelListSplit = labelList.split(",");
                var customButtonIconList = component.get("v.customButtonIconList");
                var customButtonIconListSplit = (!$A.util.isEmpty(customButtonIconList) ? customButtonIconList.split(",") : null);

                var customButtonShowIconOnlyList = component.get("v.customButtonShowIconOnlyList");
                var customButtonShowIconOnlyListSplit = (!$A.util.isEmpty(customButtonShowIconOnlyList) ? customButtonShowIconOnlyList.split(",") : null);
                console.log("customButtonShowIconOnlyListSplit", customButtonShowIconOnlyListSplit);

                for (var i = 0; i < apiListSplit.length; i++) {
                    var apiItem = apiListSplit[i];
                    console.log('apiListSplit[i]', apiItem);
                    console.log("customButtonShowIconOnlyListSplit", $A.util.isEmpty(customButtonShowIconOnlyListSplit));
                    var item1 = [(!$A.util.isEmpty(customButtonShowIconOnlyListSplit) && customButtonShowIconOnlyListSplit[i] === 'true' ? "lightning:buttonIcon" : "lightning:button"), {
                        "label" : apiItem,
                        "onclick" : component.getReference("c.onButtonPressed"),
                        "aura:id" : apiItem,
                        "class" : "marginSpace"
                    }];
                    //console.log("customButtonShowIconOnlyListSplit",customButtonShowIconOnlyListSplit[i]);
                    //console.log("customButtonIconListSplit",customButtonIconListSplit[i]);
                    if (!$A.util.isEmpty(customButtonIconListSplit) && !$A.util.isEmpty(customButtonIconListSplit[i]) && customButtonIconListSplit[i] != 'null') {
                        item1[1].iconName = customButtonIconListSplit[i];
                        item1[1].alternativeText = apiItem;
                    }
                    console.log("item1", item1);
                    jsonResult.push(item1);
                }

                $A.createComponents(jsonResult,
                                    function(components, status, errorMessage) {
                                        if (status === "SUCCESS") {
                                            var customButtonDiv = component.find("customButtonDiv");
                                            //components.forEach(function(item) {
                                            //    body.push(item);
                                            //});
                                            customButtonDiv.set("v.body", components);
                                        }
                                    }
                                   );
                
            }
            //console.log("jsonResult", jsonResult);
            //component.set("v.valueList", jsonResult);
        }
	}

})