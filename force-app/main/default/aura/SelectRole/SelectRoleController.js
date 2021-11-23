/*****************************************************************************
@Name: SelectRolesController.js
@Author: Shaik Mahaboob Subani
@CreateDate: 20/09/2019
@Description: P2OB-1659. this componet used for quick action to select roles and upate
			  Selection Of Role
*******************************************************************************/
({
    //This Method will be called OnLoad to fetch Roles Data from ServerSide Controller
	init : function(component, event, helper) {
        component.set("v.spinner", true);
        helper.getRoleData(component);
   },
    // This method will get the Selected record details from the table
    onRadioSelection: function(component, evt, helper) {
		helper.selectedrecord(component,evt);
    },
    // This is triggred when Role is selected and Clicked on Save
    save: function(cmp, evt, helper) {
        helper.saveRoles(cmp,evt);
    },
    // This is Trigerred when input is provided in Search bar
    searchRoleName: function(component, event, helper) {
        helper.filteredRoles(component,event);
    },
	//This method deals with on click of cancel button.
    cancel: function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
    } 
})