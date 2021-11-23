({
     closeModel : function(component, event, helper) {
        //Closing the Modal Window 
              
        //EDGE- 71384
        //var homeEvent = $A.get("e.force:navigateToObjectHome");
        //homeEvent.setParams({
           // "scope": "cscrm__Address__c"
      //  });
        //homeEvent.fire();        
        $A.get("e.force:closeQuickAction").fire();  
    },  
})