({
	initialize : function(component,event,helper) {
        console.log('in child component');
        var uiTheme = component.get("v.uiTheme");
        var isPilotUser = component.get("v.isPilotUser");
        var isPartner = component.get("v.isPartner");
        var flowName = component.get("v.flowName");
        console.log('flowName'+flowName);
        console.log('uiTheme'+uiTheme);
        
        if(flowName =='HandlePOR'){ // Adedd part of EDGE-150892
          		  var flow = component.find("flowData");
                 flow.startFlow("Create_POR_flow");
        }
        else
        {
                        console.log('::isPilotUser'+isPilotUser);
                        var inputVariables = [{name: "isPartner", type : "Boolean" , value : isPartner},
                                              {name: "isPartnerUser", type : "Boolean" , value : isPartner},
                                              {name : "varUITheme", type: "String", value :uiTheme},
                                             {name : "varSourceOfFlow", type: "String", value :"Custom"}];
                        console.log('inputVariables');  
                        console.log(inputVariables);  
                        var flow = component.find("flowData");
                        var flowLabel = $A.get("$Label.c.PRM_Channel_Care_Flow_Name");
                        flow.startFlow(flowLabel ,inputVariables);
                       
        }
                
   } 
    
})