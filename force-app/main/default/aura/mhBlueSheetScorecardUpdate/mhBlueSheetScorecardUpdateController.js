({
    doInit: function(component, event, helper) {
        helper.getCriteria(component);
    },
    
    doSave: function(component, event, helper) {
        var optionList = component.find("optionList");
        var selectedResponses = [];
        
        for(var i=0; i < optionList.length; i++){
            selectedResponses.push(optionList[i].get("v.name") + ':' + optionList[i].get("v.value"));    
        }
        console.log('selectedResponses : '+selectedResponses);
        
        helper.saveCriteria(component, selectedResponses);
    },
   
   	doCancel: function(component, event, helper) {
        helper.closeModal(component);
    },
    
})