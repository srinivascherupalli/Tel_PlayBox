({
    getChildCaseDetails : function(component) {
        var childCaseList = component.get("v.varChildCaseList");
        alert('childCaseList:'+childCaseList);
        var action = component.get("c.getCaseDetails"); 
        action.setParams({"caseId" : childCaseList });
        alert('action'+action);
        action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {
               var listCase = response.getReturnValue();
               component.set('v.childCaseList', response.getReturnValue()); 
            } 
            else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    }
    /*,
    getParentCaseDetails : function(component) {
        var varParentIdList = component.get("v.varParentIdList");
        alert('varParentIdList'+varParentIdList);
        var action = component.get("c.getCaseDetails(varParentIdList)"); 
        
        var self = this;
        action.setCallback(this, function(actionResult) {
            
            component.set('v.parentCaseList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }*/
})