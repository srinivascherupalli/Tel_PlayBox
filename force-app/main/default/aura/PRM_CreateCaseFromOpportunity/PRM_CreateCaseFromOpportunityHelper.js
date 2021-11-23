({
	initialize : function(component,event,helper) {
     console.log('get User Details');
     var recordId = component.get("v.recordId");
     var action = component.get("c.getValidOpportunity");
        action.setParams({"oppId":recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('::result'+result);
                //component.set("v.userType", userDetails.userType);
                //component.set("v.isPilotUser", userDetails.isPilotUser);
                if(result != null && result.status == 'error'){
                    component.set('v.showError', true);
                    component.set('v.newCaseError', result.message);
                    console.log('Error: '+v.newCaseError);
                }else if(result != null){
                    component.set('v.showError', false);
                    component.set('v.newCaseError', '');
                    component.set('v.isInit',true);
                    if(result.isPilotUser == "true"){
                        console.log(': in flow');
                        component.set('v.isPilotUser',true);
                        
                        var uiTheme = result.uiTheme;
                        var isPilotUser = result.isPilotUser == "true" ? true : false;
                        var isPartner = result.userType == 'PowerPartner' ? true : false;
                        console.log('isPilotUser:::'+ isPilotUser);
                        console.log('::opptyId'+component.get("v.recordId"));
                        var inputVariables = [{name: "isPartner", type : "Boolean" , value : isPartner},
                                              {name: "isPartnerUser", type : "Boolean" , value : isPartner},
                                              {name : "opportunityId", type: "String", value :recordId},
                                              {name : "varUITheme", type: "String", value :uiTheme}];
                        console.log('inputVariables');  
                        console.log(inputVariables);  
                        var flow = component.find("flowData");
                        console.log('::flow'+flow);
                        var flowLabel = $A.get("$Label.c.PRM_Channel_Care_Flow_Name");
                        flow.startFlow(flowLabel,inputVariables);
                        //flow.startFlow("salesup_Create_Sales_Service_Certitude_support_request_Dup",inputVariables);
                    }else{
                        console.log(': in not');
                        component.set("isPilotUser","false");
                    }
                }
            } 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
 
})