({
	doInit : function(component, event, helper) { 
        component.set('v.flowInput', '');  
        var recordId = component.get('v.recordId');
        if(recordId.startsWith("006")){ 
            var action = component.get("c.getGetOpportunity");
            action.setParams({ strOpportunity : recordId});        
            action.setCallback(this, function(response){ 
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    component.set("v.AccountId", data.AccountId);
                }                
            });
            $A.enqueueAction(action);
        } 
	},
    
	//to handle application event
    subEvt: function(component,event,helper){
        var linkCaseIds = component.get( "v.linkCaseIds" );
        var msg = event.getParam("isPrevious"); 
        if(msg == "true"){
            component.set('v.showFlowScreen',false);
            component.set('v.flowInput', '');  
        }        
        var origin = event.getParam("Origin"); 
        if(origin == "last"){
            var caseId = event.getParam("CaseId"); 
            var parentCaseId = component.get("v.parentCaseId");
            if($A.util.isUndefinedOrNull(parentCaseId) || parentCaseId === ''){
                component.set("v.parentCaseId", caseId);
                component.set("v.linkCaseIds", caseId);
            }else{                
                component.set("v.linkCaseIds", caseId);
            }
            
            component.set('v.showFlowScreen',false);
            component.set('v.flowInput', '');
        }
        component.set('v.isSearched', false);  
    },
    
    //To close the modal
    closeModel : function(component, event, helper){    
        console.log('::recordId'+component.get('v.recordId'));
        var recId = component.get('v.recordId');
        if(recId != undefined && recId != ''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get('v.recordId'),
              "slideDevName": "detail"
            });
            navEvt.fire();
    	}else{
            window.location.assign(window.location.href);
        }
	},
    
    //This method will launch the appropriate flow as per the inputs
    nextClick : function(component, event, helper) {
        var flowInput = component.get('v.flowInput');
        console.log('***flowInput***'+flowInput);
        if(flowInput != '') {
            console.log('***flowInput NOT BLANK***');
            var isSearched = component.get('v.isSearched'); 
            if(isSearched){ 
                var categoryLabel = component.get('v.categoryLabel');
                var action = component.get("c.setSearchHistory");
                action.setParams({ searchKeyword : categoryLabel});        
                action.setCallback(this, function(response){ 
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                    }                
                });
                $A.enqueueAction(action);
            }
            component.set('v.showFlowScreen', true);
            var mapSubTypeFlowName = component.get('v.mapSubTypeFlowName');
            var flow = component.find("flowData");
			console.log('flow*****'+flow);
            if(component.get('v.flowInput') === "RequestSupport"){
                console.log('RequestSupport*****');
                var inputVariables = [
                    {
                        name : "recordId",
                        type : "String",
                        value : component.get('v.recordId')
                    }
                ];
                flow.startFlow("salesup_Create_Sales_Service_Certitude_support_request_Dup", inputVariables);
            }
                //Shreyansh Sharma, Team Jaipur
            //P2OB-13643 Move Existing Opportunity Get Support to new UI/UX Opportunity Get Support
           
                    else if(component.get('v.flowInput') === "CPE_Request"){
                        helper.createCPECase(component, event, helper);
                    }
                        else if(component.get('v.flowInput') === "CBS_Design"){
                            helper.validateAndCreateCBSCase(component, event, helper);
                    }
                        else if(component.get('v.flowInput') === "CBS_Contract"){
                            helper.validateAndCreateCBSContractCase(component, event, helper);
                        }
            			//Sanjay Thakur, Team Hawai
            			//P2OB-14486 Adding validation for Presales type as per the Opportunity stages
            			else if(component.get('v.flowInput') === "Get Solution Support"){
                            console.log('pre validation*****');
                            helper.validatePresalesOpportunityStage(component, event, helper,categoryLabel);
                        }
                       
                       
            //Shreyansh Sharma, Team Jaipur
            //P2OB-13643,Changes to accommodate CAS flow changes for SFO Team
                            else if(component.get('v.flowInput') === "CAS_Screen"){
                                debugger;
                                var inputVariables = [
                                    {
                                        name : "varOpportunityID",
                                        type : "String",
                                        value : component.get('v.recordId')
                                        
                                    }
                                ];
                                flow.startFlow("CAS_Screen_Flow", inputVariables);
                            }
            else {
                var recordId = component.get('v.recordId');
                console.log('recordId*****'+recordId);
                var opportunityId = '';
                var accountId = '';
                if(recordId.startsWith("001")){
                    accountId = component.get('v.recordId');
                }else if(recordId.startsWith("006")){
                    opportunityId = component.get('v.recordId');
                }
				console.log('before Inputvars');
                var inputVariables = [
                    {
                            name : "RequestType",
                            type : "String",
                            value : component.get('v.flowInput')
                    },                   
                    {
                            name : "linkCaseIds",
                            type : "String",
                            value : component.get('v.linkCaseIds')
                    },
                    {
                            name : "linkParentCaseId",
                            type : "String",
                            value : component.get('v.parentCaseId')
                    }
                ]; 
                var mapTypetoSubTypesConst = component.get('v.mapTypetoSubTypesConst');
                var mapTypeKey = mapTypetoSubTypesConst['Move, Add, Change or Cancel'];
                var categoryLabel =component.get('v.categoryLabel');
                /*if(mapTypeKey.includes(categoryLabel) && recordId.startsWith("006")){*/
                    var opportunityDetails = {name : "OpportunityId",
                                              type : "String",
                                              value : opportunityId }
                    inputVariables.push(opportunityDetails);
                    /* start Hawaii added 05 May 2021 */
                    var accId = component.get("v.AccountId");
                    if (accId == undefined || accId == ''){
                        accId = accountId;
                    }
                    var accountIdDetails = {name : "AccountId",
                                              type : "String",
                                              value : accId }
                    inputVariables.push(accountIdDetails);
                    /* end Hawaii added 05 May 2021 */     
                /*
                } else{
                    console.log('*****OTHER USE CASE*****');
                    var accountIdDetails = {name : "AccountId",
                                            type : "String",
                                            value : accountId }
                    inputVariables.push(accountIdDetails);
                }
                */
            	console.log('before flow start');
                console.log('inputVariable====>'+inputVariables);
                flow.startFlow(mapSubTypeFlowName[component.get('v.flowInput')], inputVariables );
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Error!",            
                "message": $A.get("$Label.c.csSelectCategoryError"),
                "type": "error",
                "duration":" 2000"
            });
            toastEvent.fire();
        }  
    },
    
    //To get the selected flow input from child LWC
    getFlowInputFromLwc: function(component, event, helper) {
        console.log('flowInput :::',event.getParam('flowInputParam'));
        console.log('flowInput Label :::',event.getParam('categoryLabel'));
        component.set('v.flowInput',event.getParam('flowInputParam') );
        component.set('v.categoryLabel',event.getParam('categoryLabel') );
	},
    
    //To get the selected flow name from child LWC
    getFlowNames: function(component, event, helper) {
        component.set('v.mapSubTypeFlowName',event.getParam('mapSubTypeFlowName') );
        component.set('v.mapTypetoSubTypesConst',event.getParam('mapTypetoSubTypesConst') );
	},
    
    typeChanged : function(component, event, helper){
    	var tmp = event.getParam('typeVal');
        component.set('v.isSearched', false);
        component.set('v.typeValue',event.getParam('typeVal'));
    },
    
    markIsSearched : function(component, event, helper){
        component.set('v.isSearched', true);   
    },
    
    //this will handle the flow status change
    handleStatusChange : function (component, event) {
      if(event.getParam("currentStage") != undefined)  {
       
          component.set('v.showProgressBar', true);  
          component.set("v.currentStage", event.getParam("currentStage"));
          component.set("v.activeStages", event.getParam("activeStages"));
          
          var progressIndicator = component.find("progressIndicator");
          var body = [];
          var labelName;  
          
          for(let stage of component.get("v.activeStages")) {
             // For each stage in activeStages...
             labelName = stage.label;
            if(stage.label == 'Finish'){
                 //labelName = 'Request Submitted';
                 labelName = $A.get("$Label.c.ss_request_submitted");
            }
            else if(stage.label == 'Step 1'){
                //labelName = 'Step 1';
                labelName = $A.get("$Label.c.ss_progressBarStep1");
            }
            else if(stage.label == 'Step 2'){
                //labelName = 'Step 2';
                labelName = $A.get("$Label.c.ss_progressBarStep2");
            }
            else if(stage.label == 'Step 3'){
                //labelName = 'Step 3';
                labelName = $A.get("$Label.c.ss_progressBarStep3");
            }
            else if(stage.label == 'Step 4'){
                //labelName = 'Step 4';
                labelName = $A.get("$Label.c.ss_progressBarStep4");
            }
             $A.createComponent(
                "lightning:progressStep",
                {
                   // Create a progress step where label is the 
                   // stage label and value is the stage name
                   "aura:id": "step_" + stage.name,
                   "label": labelName,
                   "value": stage.name
                },
                function(newProgressStep, status, errorMessage) {
                   //Add the new step to the progress array
                   if (status === "SUCCESS") {
                   body.push(newProgressStep);
                   }
                   else if (status === "INCOMPLETE") {
                      // Show offline error
                      console.log("No response from server or client is offline.")
                   }
                   else if (status === "ERROR") {
                      // Show error message
                      console.log("Error: " + errorMessage);
                   }
                }
             ); 
          }
            progressIndicator.set("v.body", body);

    	}  
        
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
            
          console.log('Test');        
        }
        else if(event.getParam("status") === "ERROR") {
           
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Error!",            
                "message": "Please review and try again",
                "type": "error",
                "duration":" 4000"
            });
            toastEvent.fire();
        }
    }, 

})