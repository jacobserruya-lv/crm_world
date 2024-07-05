({
    fireEvent : function(component, event) {
        var select = component.get("v.selection");
        var selectionLabel = component.get("v.selectionLabel");

        const searchEvent = component.getEvent('onPickerSelected');
        if (!$A.util.isEmpty(searchEvent)) {
            searchEvent.setParams({
                "value": select,
                "label": selectionLabel
            });
            searchEvent.fire();
        }
    }
})