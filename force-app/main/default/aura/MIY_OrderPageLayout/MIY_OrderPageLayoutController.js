({
    onRender: function (component, event, helper) {
        var left = component.find('left').getElement();
        var right = component.find('right').getElement();
        var sizes = localStorage.getItem('miy-layout__split-sizes');

        if (sizes) {
            sizes = JSON.parse(sizes);
        } else {
            sizes = [50, 50]; // default sizes
        }
        helper.doSplit([left, right], {
            gutterSize: 13,
            sizes: sizes,
            onDragEnd: function(sizes) {
                localStorage.setItem('miy-layout__split-sizes', JSON.stringify(sizes));
            },
        });
    },
    findEvent: function (component, event, helper) {
      console.group(component.getType() + '.findEvent', component, event, helper);
      console.groupEnd();
    },
})