({
    onInit : function(component, event, helper) {
        var currentScreen = component.get("v.currentScreen");
        var screens = component.get("v.body");

        component.set('v.highDots', screens[currentScreen].get('v.highDots'));
    },

    changeScreens: function (component, event, helper) {
        var dirValue = event.getSource().get("v.value");
        var currentScreen = component.get("v.currentScreen");
        var screens = component.get("v.body");
        var newScreen = currentScreen;

        if (dirValue === 'next' && currentScreen < (screens.length - 1)) {
            newScreen = (currentScreen + 1);
        } else if (dirValue === 'prev' && currentScreen > 0) {
            newScreen = (currentScreen - 1);
        } else if (dirValue >= 0 && dirValue <= (screens.length - 1)) {
            newScreen = dirValue;
        }

        if (newScreen !== currentScreen) {
            component.set('v.highDots', screens[newScreen].get('v.highDots'));
            component.set('v.currentScreen', newScreen);
        }
    }
})