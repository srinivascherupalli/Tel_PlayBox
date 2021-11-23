({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);
	},
    handleNext: function(component, event, helper) {
        console.log('handleNext');
        //Start of EDGE-198190 and EDGE-198196: Added by Abhishek from Osaka Team
        component.set("v.selectedCIDN",event.getParam('selectedHierarchialCIDN'));
        component.set("v.isCIDNHierarchy", event.getParam('isHierarchy'));
         //End of EDGE-198190 and EDGE-198196: Added by Abhishek from Osaka Team.
         
        //Start of EDGE-209885 and EDGE-209886 by Abhishek(Osaka)
        component.set("v.productFamily", event.getParam('productFamily'));
        //End of EDGE-209885 and EDGE-209886 by Abhishek(Osaka)
        console.log('CIDN Hierarchy Value: '+component.get("v.isCIDNHierarchy"));
        console.log('Select CIDN::'+component.get("v.selectedCIDN"));
        console.log('Selected Prod Family::'+component.get("v.productFamily"));
        component.set("v.isOnScreenRetrieval",true);   
        component.set("v.sioConfigMode", event.getParam('sioConfigMode'));
        console.log('Selected Add On Option::'+component.get("v.sioConfigMode")); 
    }      
})