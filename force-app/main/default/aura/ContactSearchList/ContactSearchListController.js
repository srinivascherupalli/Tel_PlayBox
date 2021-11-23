({
	checkboxSelect : function(component, event, helper) {
		 var selectedRec = event.getSource().get("v.value");
	},
    
  
 importContact: function(component, event, helper) {
      var impid = [] 
      var getAllId = component.find("boxPack");
      for (var i = 0; i < getAllId.length; i++) {
       if (getAllId[i].get("v.value") == true) {
        impid.push(getAllId[i].get("v.text"));
       }
      }
     
     //helper.insertselectedContact(component, event, impid);
     var action = component.get('c.importContact');
    
      action.setParams({
       "lstRecordId": impid
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
 },
})