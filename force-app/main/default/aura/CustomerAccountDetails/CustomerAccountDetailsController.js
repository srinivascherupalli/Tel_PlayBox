({
    handleComponentEvent : function(component, event, helper) {
    	// get the selected Account record from the COMPONETN event 	 
       	var selectedAccountGetFromEvent = event.getParam("recordByEvent");   
        var selectedfieldName = event.getParam("fieldName"); 
		console.log('selectedAccountGetFromEvent');
        if(selectedfieldName == "Customer Account"){
       	     component.set("v.CustomerAccountId" , selectedAccountGetFromEvent.Id);
             component.set("v.CustomerContactId" , '');
             var container = component.find("container");
            $A.createComponent("c:salesup_CertitudeLookupContainer",
                           {
                            isFetchAccount: false,
                            objectAPIName: "contact",
                            label:"Customer Contact",
                            accountId:selectedAccountGetFromEvent.Id,
                            selectedRecordId:"",
                            isLookUpMandatory:"true",
                            IconName:"standard:contact",
                            helpMessage:"Select Full Authority Contact",
                            SOQLFilter:"( Authority__c= \'Full Authority\') AND Contact_Status__c=\'Active\'"
                         },
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
          }
        if(selectedfieldName == "Customer Contact"){
       	     component.set("v.CustomerContactId" , selectedAccountGetFromEvent.Id);
        }
    }
        
      
})