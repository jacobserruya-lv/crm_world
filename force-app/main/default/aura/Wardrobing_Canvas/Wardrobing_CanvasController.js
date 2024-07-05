({
    doInit : function(cmp, evt, helper) {
        
        
        //var param = "param1";
        //cmp.set("v.canvasParameters", JSON.stringify({
        //    p1: param
        //}));
        var toLog = cmp.get("v.canvasParameters");
        if(toLog){
         console.log('toLog', toLog);
        }
        
        var canvasParameters = cmp.get("v.canvasParameters");
        var output = '{"params": "' + canvasParameters + '"}';
        cmp.set("v.canvasParameters", output);
    }
})