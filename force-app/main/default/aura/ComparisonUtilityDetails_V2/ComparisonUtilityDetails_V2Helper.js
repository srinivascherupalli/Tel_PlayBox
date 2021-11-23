/*
===============================================================================================================================
Component Name : ComparisonUtilityDetails_v2
Developer Name : Ravi
COntroller Class : CompUtilityReplicatorManager
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
({
	removeClass : function(component, event, helper) {
        var allTabs = document.querySelectorAll('.selected-tab-background-color');
        if(allTabs.length > 0)
        {
            allTabs[0].classList.remove('selected-tab-background-color','blue-text-tab');
            allTabs[0].classList.add('tab-background-color');
        }
	},
    addClass : function(component, event, helper) {
		event.currentTarget.classList.add('selected-tab-background-color','blue-text-tab');
        event.currentTarget.classList.remove('tab-background-color');
	},
    
})