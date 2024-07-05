({
    next : function(component, showDiv, hideDiv, showTab, hideTab) {
        var productLC = component.find(showDiv);
        if (productLC) {
            $A.util.removeClass(productLC, 'toggle');
        }

        var accountLC = component.find(hideDiv);
        $A.util.addClass(accountLC, 'toggle');
        
        var toggleIndicatorCurrent = component.find(hideTab);
        /*$A.util.removeClass(toggleIndicatorCurrent,'slds-tabs--path__item slds-is-current');
        $A.util.addClass(toggleIndicatorCurrent,'slds-tabs--path__item slds-is-complete');
        
        var toggleIndicatorNext = component.find(showTab);
        $A.util.removeClass(toggleIndicatorNext,'slds-tabs--path__item slds-is-incomplete');
        $A.util.addClass(toggleIndicatorNext,'slds-tabs--path__item slds-is-current');*/
        if (toggleIndicatorCurrent) {
            $A.util.removeClass(toggleIndicatorCurrent,'slds-is-current');
            $A.util.addClass(toggleIndicatorCurrent,'slds-is-complete');
        }
        
        var toggleIndicatorNext = component.find(showTab);
        if (toggleIndicatorNext) {
            $A.util.removeClass(toggleIndicatorNext,'slds-is-incomplete');
            $A.util.addClass(toggleIndicatorNext,'slds-is-current');
        }

    },
    
    back : function(component, showDiv, hideDiv, showTab, hideTab) {
        var startLC = component.find(showDiv);
        if (startLC) {
            $A.util.removeClass(startLC, 'toggle');
        }
        
        var accountSearchLC = component.find(hideDiv);
        if (accountSearchLC) {
            $A.util.addClass(accountSearchLC, 'toggle');
        }
        
        var toggleIndicatorCurrent = component.find(hideTab);
        /*$A.util.removeClass(toggleIndicatorCurrent,'slds-tabs--path__item slds-is-current');
        $A.util.addClass(toggleIndicatorCurrent,'slds-tabs--path__item slds-is-incomplete');
        
        var toggleIndicatorPrevious = component.find(showTab);
        $A.util.removeClass(toggleIndicatorPrevious,'slds-tabs--path__item slds-is-complete');
        $A.util.addClass(toggleIndicatorPrevious,'slds-tabs--path__item slds-is-current');*/
        if (toggleIndicatorCurrent) {
            $A.util.removeClass(toggleIndicatorCurrent,'slds-is-current');
            $A.util.addClass(toggleIndicatorCurrent,'slds-is-incomplete');            
        }
        
        var toggleIndicatorPrevious = component.find(showTab);
        if (toggleIndicatorPrevious) {
            $A.util.removeClass(toggleIndicatorPrevious,'slds-is-complete');
            $A.util.addClass(toggleIndicatorPrevious,'slds-is-current');            
        }
    },
    
    incomplete : function(component, hideDiv, hideTab) {
        var componentHide = component.find(hideDiv);
        //console.log("componentHide", componentHide);
        if (componentHide) {
            $A.util.addClass(componentHide, 'toggle');
        }

        var toggleIndicatorCurrent = component.find(hideTab);
        //console.log("toggleIndicatorCurrent", toggleIndicatorCurrent);
        if (toggleIndicatorCurrent) {
            if ($A.util.hasClass(toggleIndicatorCurrent, 'slds-is-current')) {
                $A.util.removeClass(toggleIndicatorCurrent,'slds-is-current');
            }
            if ($A.util.hasClass(toggleIndicatorCurrent, 'slds-is-complete')) {
          		$A.util.removeClass(toggleIndicatorCurrent, 'slds-is-complete');
            }
            $A.util.addClass(toggleIndicatorCurrent,'slds-is-incomplete');            
        }
    },

    complete : function(component, hideDiv, hideTab) {
        var componentHide = component.find(hideDiv);
        //console.log("componentHide", componentHide);
        if (componentHide) {
            $A.util.addClass(componentHide, 'toggle');
        }

        var toggleIndicatorCurrent = component.find(hideTab);
        //console.log("toggleIndicatorCurrent", toggleIndicatorCurrent);
        if (toggleIndicatorCurrent) {
            if ($A.util.hasClass(toggleIndicatorCurrent, 'slds-is-current')) {
                $A.util.removeClass(toggleIndicatorCurrent,'slds-is-current');
            }
            if ($A.util.hasClass(toggleIndicatorCurrent, 'slds-is-incomplete')) {
          		$A.util.removeClass(toggleIndicatorCurrent, 'slds-is-incomplete');
            }
            $A.util.addClass(toggleIndicatorCurrent,'slds-is-complete');            
        }
    },

})