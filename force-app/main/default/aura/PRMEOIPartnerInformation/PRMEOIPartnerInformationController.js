({
    doInit : function(component, event, helper) {
        helper.getpicklistvalues(component,event,'Source_Info_Telstra_Channel_Partner_prog__c');
        helper.getpicklistvalues(component,event,'Partner_categories__c');
    },
    
    //Added by Ayush for story P2OB-7471
    handlePartnerSource : function(component, event, helper) {
    	helper.handleCheckBoxGroup(component);
 	}
 })