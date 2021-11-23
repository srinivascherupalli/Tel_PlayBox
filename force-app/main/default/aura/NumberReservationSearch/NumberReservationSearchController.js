({
	addAddress : function(component, event, helper) {
		helper.handleEvent(component, event, helper);
	},
    /*------------------------------------------------------
     * EDGE-126317
     * Method: renderPatternTypeOptions
     * Description: Method to validate number reservation for NgUc
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
     renderPatternTypeOptions: function(component, event, helper){
        helper.renderPatternTypeOptions(component, event);
    },
    handleSearchNumbers :  function(component, event, helper){
        helper.handleSearchNumbers(component, event);
    },
    handleAutoReserve : function(component, event, helper){
        //DIGI-3161 added by shubhi start----
        var searchType="Auto Reserve";
        var eventType="Number reservation initiated";
        helper.logTransaction(component, event,helper,searchType,eventType);
        //DIGI-3161 added by shubhi end--- 
        helper.handleAutoReserve(component, event);
    },
    handletest :function(component, event, helper){
        console.log('v.numberReserve.sameExchange,',component.find("sameExchange").get("v.checked") );
    },
    handlebuttonClick : function(component, event, helper){
        console.log('Inside handlebuttonClick');
        var data = component.get("v.numberReserve");
        console.log(data);
        data.sameExchange =false;
        data.selectedAreaCode="";
        data.selectedPatternType="";
        data.selectedSearchType="Non-Contiguous";
        data.quantity="";
        data.reqPattern="";  
        data.deliveryAddress=null;
        if(component.find("sameExchange") != undefined)
        	component.find("sameExchange").set("v.checked", false);
        console.log(data);
        component.set("v.numberReserve",data);
        console.log(data);
    }
})