({
   validate : function(cmp, event) {
        cmp.set('v.validate', function() {
        if($A.util.isEmpty(cmp.get("v.shippingGroup"))){
            return { isValid: false, errorMessage: $A.get("$Label.c.ICX_ValueIsRequired")};
        }else{
        	return { isValid: true };
     	}})
   }
    
})