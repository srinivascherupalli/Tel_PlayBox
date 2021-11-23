/*
Created By : Team Hawaii
Date : 23/10/2020
Jira : P2OB-6450

Modified Date : 20/11/2020 - Open tesa in new tab

*/
({	
    //init event
	doInit : function(component, event, helper) {
        //set spinner flag true
        component.set("v.spinner",true);
        //call helper method to get boolean value of feature enabled or not
        helper.checkFeatureEnabled(component, event, helper);
    }
})