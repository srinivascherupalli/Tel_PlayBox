({
    // Method to get builded draft values from the Edit of the cell and for entering the Redemption Amount
    //EDGE-124045,EDGE-124896, EDGE-135560  
    getBuildedDraftValues: function (atomicChanges, lastChange) {
        var draftValues = [];
        var mergeChange = function (change, draft) {
            for (var j = 0; j < change.length; j++) {
                var row = false;
                draft.some(function (searchRow) {
                    if (searchRow['Id'] === change[j].Id) {
                        row = searchRow;
                        return true;
                    };
                    return false;
                });
                
                if (row) {
                    Object.assign(row, change[j]);
                } else {
                    draft.push(change[j]);
                }
            }
        }
        for (var i = 0; i < lastChange; i++) {
            mergeChange(atomicChanges[i], draftValues)
        }
        
        return draftValues;
    },
    
    callcase: function(cmp, event, helper){
        var r1Id = cmp.get("v.recordId");
            var action2 = cmp.get("c.getcaseDetatils");
            action2.setParams({
                "caseRecord":r1Id
            }); 
            action2.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ',+state);
            if(state === 'SUCCESS'){
                console.log('Inside success');
                
                cmp.set("v.insideattachmentdata",response.getReturnValue().Attachment_Count__c);
                //var resp = cmp.get("v.insideattachmentdata");
                console.log('resp in helper::',+cmp.get("v.insideattachmentdata"));
            }
            });
            $A.enqueueAction(action2);
        
    },
     savedQueriedLIneItems: function(component, event, helper){
        var action = component.get('c.displaySavedQueriedLineItems');
        var rId = component.get("v.recordId");
        action.setParams({ "caseRecord":rId });  
        action.setCallback(this,function(response){            
            var state = response.getState();
            if(state === "SUCCESS"){
                var caseDetails=component.get("v.caseDetails")
                if(caseDetails.Status === 'Initiate Redemption'){
                 component.set('v.columns', [
                {label: 'Invoice line item', fieldName: 'invoiceLineNumber', type: 'number', cellAttributes: { alignment: 'left' }},
                {label: 'Offer name', fieldName: 'offername', type: 'text' },
                {label: 'Service type', fieldName: 'servicetype', type: 'text'},
                {label: 'Charge (Including GST)', fieldName: 'chargeIncludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                //Gokul
                {label: 'Charge (Excluding GST)', fieldName: 'chargeExcludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                {label: 'Charge Type', fieldName: 'chargeType', type: 'text'},
                {label: 'Eligible Redemption Amount(Excluding GST)', fieldName: 'EligibleRedemptionAmount', type: 'currency', cellAttributes: { alignment: 'left' }},
                {label: 'Redemption Amount', fieldName: 'nullredemptionamt', type: 'currency',editable:false}
                 ]);
                }else{
                 component.set('v.columns', [                
                {label: 'Invoice line item', fieldName: 'invoiceLineNumber', type: 'number', cellAttributes: { alignment: 'left' }},
                {label: 'Offer name', fieldName: 'offername', type: 'text' },
                {label: 'Service type', fieldName: 'servicetype', type: 'text'},
                {label: 'Charge (Including GST)', fieldName: 'chargeIncludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                //Gokul
                {label: 'Charge (Excluding GST)', fieldName: 'chargeExcludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                {label: 'Charge Type', fieldName: 'chargeType', type: 'text'},
                {label: 'Eligible Redemption Amount(Excluding GST)', fieldName: 'EligibleRedemptionAmount', type: 'currency', cellAttributes: { alignment: 'left' }},
                {label: 'Redemption Amount', fieldName: 'nullredemptionamt', type: 'currency',editable:true}
                 ]); 
                    
                }
                console.log('QueryLineItemResponse : ' +JSON.stringify(response.getReturnValue()));
                 component.set('v.data', response.getReturnValue());
            }
        });       
        $A.enqueueAction(action);
    }
});