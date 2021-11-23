({
  init : function (component,event,helper) {
    helper.initialize(component,event,helper);  
  },
  closeFlow : function(component, event, helper){
    //v1.1 P2OB-4178 autoclose parent popup on thank you screen closure
    console.log('closing quck action*****');
    $A.get("e.force:closeQuickAction").fire();
    window.location.reload();
    $A.get("e.force:refreshView").fire();
  }
})