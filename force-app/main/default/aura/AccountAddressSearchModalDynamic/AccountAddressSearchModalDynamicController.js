({
    doInit : function(component, event, helper) {   
        console.log('AccountAddressSearchModalDynamic   Controller');
    	helper.doInit(component, event, helper); 
    },
   
    doCloseOperation : function(component, event, helper) {
        helper.doCloseOperation(component, event, helper);          
    },
    searchAddressResultOpen : function (component, event, helper) {
        helper.searchAddressResultOpen(component, event, helper); 
    },
	
    searchCriteria : function (component, event, helper) {
        helper.searchCriteria(component, event, helper);  
    },
	 saveAddress : function(component, event, helper) {
        helper.saveAddress(component, event, helper);
    },
    validateAdborIDInput : function (component, event, helper) {
        helper.validateAdborIDInput(component, event, helper);  
    },
	validateUnstructuredInput : function (component, event, helper) {
		helper.validateUnstructuredInput(component, event, helper);
	},
	

    getAddresOnclick:function(component, event, helper){
        //alert('inside getAddresOnclick');
         helper.getAddresOnclick(component, event, helper);
    },
 
  
  /*showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.IsSpinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.IsSpinner", false);
    },*/
	
    toggle : function(component, event, helper) {
        helper.toggle(component, event, helper); 
    },
    onStateChange : function(component, event, helper) {
        helper.onStateChange(component, event, helper); 
        component.set("v.loadingSpinner", true);
        setTimeout(function(){
            	component.set("v.loadingSpinner", false);
       			}, 1700);
    }
    ,
    onPostCodeChange : function(component, event, helper) {
        helper.onPostCodeChange(component, event, helper);  
        component.set("v.loadingSpinner", true);
       setTimeout(function(){
            	component.set("v.loadingSpinner", false);
       			}, 1700);
    }
    ,
    closeModel : function(component, event, helper) {
        helper.closeModel(component, event, helper);
    },
    //mahima.g
    handleBubbling : function (component, event, helper) {       
        helper.handleBubbling(component, event, helper); 
    },
    searchedCompletedAction : function (component, event, helper) {       
        helper.searchedCompletedAction(component, event, helper); 
    },
})