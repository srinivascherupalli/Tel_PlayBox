({
   openModel: function(component, event, helper) {
      component.set("v.isOpen", true);
      component.set('v.pageType','datatable'); 
      helper.fetchClonedCaseRecord(component, event, helper);
   },
 
   closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   }
})