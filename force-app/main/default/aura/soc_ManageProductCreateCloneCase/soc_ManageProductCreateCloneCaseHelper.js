({
	navigateToClonedCase : function(component, event, helper) {
        var newClonedId = component.get('v.clonedCaseGeneratedRecordId');
        var navEvt = $A.get("e.force:navigateToSObject");
    			navEvt.setParams({
      			"recordId": newClonedId,
      			"slideDevName": "detail"
    			});
    			navEvt.fire();
        component.set("v.isOpen",false);
	},
    
     getProductItemIds : function(data) {
        var idList=[];
        for(var i=0;i<data.length;i++){
            idList.push(data[i].recordId);
        }
        return idList;
        
    }
})