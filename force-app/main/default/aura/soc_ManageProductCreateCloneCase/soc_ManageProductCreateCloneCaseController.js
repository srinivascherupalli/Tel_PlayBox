({
    back: function(component, evt, helper) {
        component.set('v.pageType','datatable');        
    },
   
    handleSubmit : function(component, event, helper,selectedProducts) {
        console.log('recordId==>'+component.get('v.recordId'));
        var parentCaseId = component.get('v.recordId');
        var selectedProducts = component.get('v.selectedRows');
        //Pravin S :: EDGE-68187 :: 19-MAR-2018
        var cliSizeOne = component.get('v.cliSizeOne');
        console.log('>>>>>>On Final Save>>>>>>>');
        console.log('>>>>>>selectedProducts>>>>>>>');
        console.log(selectedProducts);
        var newCase = component.get('v.clonedCase');
        var idList= helper.getProductItemIds(selectedProducts);
        console.log(idList);
        var action = component.get("c.cloneCase");
        action.setParams({ newCase : newCase,selectedCaseLineItem:idList,cliSizeOne, parentCaseId : parentCaseId});   
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") {   
                console.log('Cloned Case >>>>>>>>>>>');
                console.log(response.getReturnValue());
                var data=response.getReturnValue();
                component.set('v.clonedCaseGeneratedRecordId',data.Id);
                console.log(data.Subject);
                helper.navigateToClonedCase(component, event, helper);                  
            }                     
        });
        $A.enqueueAction(action);
	},
    
    closeModel :function(component, event, helper) {
        component.set("v.isCloneOpen", false);
        component.set("v.isOpen", false);
    }  
   
})