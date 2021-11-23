({
	initialize : function(component,event,helper) {
        
        component.set('v.showSpinner',true);
        var recId=component.get('v.recordId');
        var action = component.get("c.getProductList");
        action.setParams({ caseId : recId });   
        action.setCallback(this, function(response){            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showSpinner',false);
                console.log('MY LIST OUTPUT >>>>> initialize');
                console.log(response.getReturnValue());
                var data=response.getReturnValue();                
                var products=data['items'];
                var visible=data['visibility'];
                //var options=data['options'];
                component.set('v.products',products);  
                //component.set('v.options',options); 
                component.set('v.visibility',visible);
            }                     
        });
        $A.enqueueAction(action);
		
	},
    saveData : function(component,event,helper,caseArray) {
        component.set('v.showSpinner',true);
        var action = component.get("c.saveProductList");
        action.setParams({ sfdProducts : caseArray });   
        action.setCallback(this, function(response){            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data=response.getReturnValue();
                var status=data['status'];
                var responseData=data['response'];
                if(status=='pass'){
                    helper.showSuccessToast(component, event, helper);                    
                    helper.initialize(component,event,helper);
                }
                else{
                    helper.showErrorToast(component, event, helper,responseData);
                    component.set('v.showSpinner',false);
                }
                component.set('v.showSpinner',false);
               
            }                     
        });
        $A.enqueueAction(action);
		
	},
    
    
    validateSaveData:function(DependentMap, status, substatus) {
        var CheckVar = false;
        var keysArray = Object.keys(DependentMap);
        for (var i = 0; i < keysArray.length; i++) {
            if (keysArray[i] == status) {
                var ValuesArray = DependentMap[keysArray[i]];
                for (var j = 0; j < ValuesArray.length; j++) {
                    if (ValuesArray[j] == substatus) {
                       CheckVar = true;
                        return CheckVar;
                    }
                }
            }
        }
		return CheckVar;
    },
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "SFD Products Updated",
            "type":'success',
            "message": "SFD Products updated successfully"
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(component, event, helper, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": msg,
            "type":'error',
            "message": msg,
            "mode":'sticky'
        });
        toastEvent.fire();
    },
})