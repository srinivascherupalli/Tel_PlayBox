({
    initialize : function(component,event,helper) {
        var recId=component.get('v.recordId');
        var action = component.get("c.getCaseLineItems");
        action.setParams({ id : recId });   
        action.setCallback(this, function(response){            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data=response.getReturnValue();
                var linearData=helper.normalizeData(data);
				component.set('v.data',linearData);                
            }                     
        });
        $A.enqueueAction(action);		
	},
    
    normalizeData : function(data) {
        var linearData=[];
        for(var i=0;i<data.length;i++){
            var linearRecord={'recordId':data[i].Id,
                              'OrderNumber':data[i].soc_order_number__c,
                             'productName':data[i].soc_ProductId__r.Name };
            linearData.push(linearRecord);
        }
        return linearData;        
    }
})