({
    handleSliderDirClick : function(component, event, helper) {
        component.set('v.sliderPosition',event.getSource().get('v.value'));
    },
})