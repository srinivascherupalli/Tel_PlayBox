({
	init : function(componet ,event,helper ) {
      var action =component.get("c.checkvalue");
     var accountId = component.get("v.recordId");
     action.setParams({
            accountIds: accountId
        });
    
     action.setCallback(this, function(response) {
            var state = response.getReturnValue();
         var error="This customer is not restricted, Partner of Record agreement will be sent to the customer via DocuSign";
         if(state)
         {
              component.set('v.ErrorMsg',error);
             
             
         }
     
});           

$A.enqueueAction(action);  
		
	}
})