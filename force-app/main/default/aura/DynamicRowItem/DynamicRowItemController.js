({
    addNewRow : function(component, event, helper){
       helper.addNewRow(component, event); 
    },
    
    removeRow : function(component, event, helper){
        
      helper.removeRow(component, event);
    }, 
     qualifyCallout : function(component, event, helper) {
        helper.qualifyCallout(component, event); 
//      helper.testShow(component, event);        
    }, 
    display : function(component, event, helper) {
    helper.display(component, event);
  },
    displayOut : function(component, event, helper) {
   helper.displayout(component, event);
  },
    handleSelectAllNumbers: function(component, event, helper) {
   helper.handleSelectAllNumbers(component, event);
  },
    handleOnSelect: function(component, event, helper) {
   helper.handleOnSelect(component, event);
  },
   
})