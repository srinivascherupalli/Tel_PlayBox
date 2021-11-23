({
	insertselectedContact : function(component, event, importedId) {
		
      var action = component.get('c.importContact');
    
      action.setParams({
       "lstRecordId": importedId
      });
      action.setCallback(this, function(response) {
       //store state of response
       var state = response.getState();
       if (state === "SUCCESS") {
        console.log(state);
        if (response.getReturnValue() != '') {
         // if getting any error while delete the records , then display a alert msg/
         //alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
         console.log(response.getReturnValue());
        } else {
         console.log('check it--> delete successful');
        }
        // call the onLoad function for refresh the List view    
        //this.onLoad(component, event);
       }
      });
      $A.enqueueAction(action);
	}
})