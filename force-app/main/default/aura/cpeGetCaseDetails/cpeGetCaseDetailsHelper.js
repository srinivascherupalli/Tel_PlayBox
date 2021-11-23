({
    handleFlowScreen : function(component, event, helper, requestType){
        component.set('v.isOpen', true)
        var flow = component.find("flowData");
        
        var inputVar =[
            {
                name : "varRequestType",
                type : "String",
                value : requestType
            },
            {
                name : "varRecordId",
                type : "String",
                value : component.get('v.recordId')
            }
        ];
        //Call Flow and set the input variables
        flow.startFlow("CPE_Order_Details", inputVar);
    }
})