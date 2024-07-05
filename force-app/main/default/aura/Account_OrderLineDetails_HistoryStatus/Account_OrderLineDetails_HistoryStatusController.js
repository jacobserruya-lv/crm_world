({
    handleSectionToggle: function (cmp, event) {
        var iconName = cmp.find("icon").get("v.iconName");
        var div = cmp.find("History");
        if(iconName == 'utility:chevrondown'){
            cmp.find("icon").set("v.iconName",'utility:chevronright');
            $A.util.addClass(div, 'hideDiv');
            $A.util.removeClass(div, 'showDiv');
        }
        else{
            cmp.find("icon").set("v.iconName",'utility:chevrondown');
            $A.util.addClass(div, 'showDiv');
            $A.util.removeClass(div, 'hideDiv');
        }
      }
})