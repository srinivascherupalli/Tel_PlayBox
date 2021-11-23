({
    doInit : function(component, event, helper) {
       
        //Defect EDGE-105769, logic to avoid future date selection        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
     // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
    // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
    	var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        component.set("v.todayDate",todayFormattedDate);
		helper.doInit(component, event);
	},
    doUpload : function(component, event, helper) {
		helper.doUpload (component, event);
	},
    handleUploadFinished: function (component, event,helper) {
        helper.handleUploadFinished(component, event); 
        
    },
    handleEvent: function (component, event,helper) {
        helper.handleEvent(component, event); 
        
    },
    handleClose: function (component, event,helper) {
        helper.handleClose(component, event); 
        
    },
    doSave: function (component, event,helper) {
        helper.doSave(component, event); 
        
    },
    handlePPVEvent :function (component, event,helper) {
        helper.handlePPVEvent(component, event); 
        
    },
});