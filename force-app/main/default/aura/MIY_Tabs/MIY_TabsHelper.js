({
    //MIY-1808 disable posting on collaboration based on user profile and order type (CA and Perso =>hide posting)
getUserProfile: function(component) {
    var action = component.get('c.getUserProfileName');
    action.setStorable();
    action.setCallback(this, function (response) {
         console.groupCollapsed(component.getType() + '.c.getUserProfileName');

        var state = response.getState();
        if (state === 'SUCCESS') {
            var profileName = response.getReturnValue();
            console.log(profileName);
            component.set('v.userProfile', profileName);
        }
        else if (state === 'ERROR') {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.error($A.get('$Label.c.MIY_OrderPage_Error').replace('{0}', errors[0].message));
                }
            } else {
                console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
            }
        }
        // console.groupEnd();
    });
    $A.enqueueAction(action);

},
});