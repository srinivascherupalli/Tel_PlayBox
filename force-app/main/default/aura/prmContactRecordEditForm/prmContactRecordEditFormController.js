/*
	Jira No: P2OB-10028
    Created By: Hawaii
    Description : Create Partner User on click of New Partner User button
*/
({	
    //do init method call while rendering of component
	doInit : function(component, event, helper) {
        component.set('v.showMessage',false);
         component.set('v.showusertable',false);
        helper.getRecordTypeId(component,event,helper);
        helper.getFields(component, event, helper);
	},
    
    //this method will be called on submit action and error is generated while creating contact
    handleOnError : function(component, event, helper) {
        helper.handleOnError(component, event, helper);
	},
    
    //this method will be called on submit action and contact is successfully created
    handleSuccess : function(component, event, helper) {
        helper.handleSuccess(component, event, helper);
	},
    
    //this method will call on submit action 
    handleSubmit : function(component, event, helper) {
        component.set('v.spinner',true);
        helper.handleSubmit(component, event, helper);
	},
    
    //this method will be called on click of new partner user button
    handleClick : function(component, event, helper) {
        component.set('v.spinner',true);
		component.set('v.showNewButton',false);
        component.set('v.isModalOpen',true);
        component.set('v.isUserForm',true);
    },
    
    //this method will be called on click of cancel button
    cancelForm : function(component, event, helper) {
        component.set('v.spinner',false);
		component.set('v.showNewButton',true);
        component.set('v.isError',false);
        component.set('v.isModalOpen',false);
        
    },
    
    //this method will be called while closing the popup
    handleCloseModal: function(component, event, helper){
        component.set('v.showNewButton',true);
        component.set('v.spinner',false);
		component.set('v.isError',false);
        component.set('v.isModalOpen',false);
    },
    
    //this method will be called on load of record edit form
    handleOnLoad : function(component, event, helper) {
        component.set('v.spinner',false);
        component.set('v.isError',false);
    },
    
})