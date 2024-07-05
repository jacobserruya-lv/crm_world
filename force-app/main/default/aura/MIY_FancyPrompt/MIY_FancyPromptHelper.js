({
    formatLabel: function(string) {
        var outerArguments = arguments;
        return string.replace(/{(\d+)}/g, function() {
            return outerArguments[parseInt(arguments[1]) + 1];
        });
    },
    processErrors: function (component, helper, errors) {
        var errorList = [];
        errors.forEach(function(err) {
            if (err.message) {
                errorList.push({
                    title:  helper.formatLabel($A.get('$Label.c.MIY_OrderPage_Error'),''),
                    message: errors[0].message,
                });
                console.error(helper.formatLabel($A.get('$Label.c.MIY_OrderPage_Error'), errors[0].message));
            } else if (err.pageErrors) {
                err.pageErrors.forEach(function (pageError) {
                    errorList.push({title: pageError.statusCode, message: pageError.message});
                    console.error(pageError.statusCode + ': ' + pageError.message);
                });
            }
        });
        component.set('v.errors', errorList);
    },
})