({
	doInit : function(component, event, helper) {
    var main = component.find('main');
    var recID = component.get("v.recordId");
    $A.util.removeClass(main, 'small');
    $A.util.removeClass(main, component.get("v.designHeight"));
    $A.util.addClass(main, 'autoHeight');
    var scrollableArea = component.find('scrollableArea');
    $A.util.removeClass(scrollableArea, 'scroll-container');
    $A.util.removeClass(scrollableArea, 'slds-scrollable--y');
    //var spinner = component.find('spinner');
    //$A.util.removeClass(spinner, "slds-hide");
 },
	updateSearch: function (component, event, helper) {
    	helper.getServices(component);
 },
    showDetails: function (component, event, helper) {
        var closeItem = component.get('v.openItem');
        if (closeItem) {
            closeItem = closeItem.querySelector('[data-details]');
            $A.util.addClass(closeItem, 'slds-hide');
        }
        var selectedItem = event.currentTarget;
        component.set('v.openItem', selectedItem);
        var itemDetails = selectedItem.querySelector('[data-details]')
        $A.util.removeClass(itemDetails, 'slds-hide');
    }
})