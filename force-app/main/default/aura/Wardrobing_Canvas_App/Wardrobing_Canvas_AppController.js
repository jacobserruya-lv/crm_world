({
    doInit : function(cmp, evt, helper) {        
       
        
        var masterSku = cmp.get("v.masterSku") ? cmp.get("v.masterSku") : "";
        var dreamId = cmp.get("v.dreamId") ? cmp.get("v.dreamId") : "";
        var gender = cmp.get("v.gender") ? cmp.get("v.gender") : "";
        var is10k = cmp.get("v.is10k") ? cmp.get("v.is10k") : "";
        var allParams = '' + "masterSku=" + masterSku + "&dreamId=" + dreamId + "&gender=" + gender + "&is10k=" + is10k + '';
        console.log(allParams);        
        var output = '{"masterSku": "' + masterSku + '", "dreamId": "' + dreamId + '", "gender": "' + gender + '", "is10k": "' + is10k + '"}';
        cmp.set("v.wrdbParams", output);
    }
})