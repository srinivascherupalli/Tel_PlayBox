/* ceHandlerController.js */
({
    handleComponentEvent : function(component, event) {
        var param =event.getParam("arguments");
        var message = event.getParam('firedComponent');
		console.log(event.getParam('appDetails'));
        // set the handler attributes based on event data
        component.set("v.componentnumber", message);
        component.set("v.applicationDetail",event.getParam('appDetails'));
        
    },
    handleRecordEvent :  function(component, event) {
        var message = event.getParam("recordId");

        // set the handler attributes based on event data
        component.set("v.recordId", message);
        
    },
    doInit: function(component,event,helper) {
    	 
         if(component.get("v.recordId")==null || component.get("v.recordId")=='undefined'){
         	/*component.find("ApplicantDetails").getNewRecord(
            "Application__c", // sObject type (objectApiName)
            "0122N0000004KRSQA2",      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.appDetailsSimple");
                var error = component.get("v.recordError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
               console.log("Record template initialized: " + rec.sobjectType);
            })
        );*/
             
          var action =component.get("c.getApplicationRecord");
             action.setCallback(this,function(response){
                 console.log('rec id-->'+response.getReturnValue());
                 component.set("v.recId",response.getReturnValue());
             });
             $A.enqueueAction(action);
       }
    },
    gotoURL : function (component, event, helper) {
        var urlval='/application/'+component.get("v.recId");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": urlval
    });
    urlEvent.fire();
	}
})