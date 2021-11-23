({
    checkOpportunityClosedWon : function(component, event, helper){
        component.set('v.showSpinner',true);
        var recId=component.get('v.recordId');
        var action = component.get("c.checkOpportunityClosedWonForPartners");
        action.setParams({ oppId : recId});        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showSpinner',false);
                var data = response.getReturnValue();
                if(data.isOppClosedWonForPartners == 'true'){
                    component.set("v.isOpportunityClosed",true);
                    component.set("v.openSupportForm",false);
                } 
                else if(data.hasOppLineItemsNotPresent == 'true'){
                    component.set("v.hasOppLineItemsNotPresent",true);
                    component.set("v.openSupportForm",false);
                }
                //Start : P2OB-9558
                if(data.isCommunityDisabled == 'false'){
                    component.set("v.isCommunityDisabled",false);
                }
                else if(data.isCommunityDisabled == 'true'){
                    component.set("v.isCommunityDisabled",true);
                }
                //End
                var cpeProductDomainValue = ['CLOUD SERVICES', 'MDN', 'SECURITY', 'DIGITAL MEDIA', 'OTHER', 
                                             'UC VIDEO & COLLABORATION', 'UC CISCO WEBEX', 'CONTACT CENTRE', 'MOBILITY (PROJECT)'];
                
                if(data.oppDetails != null && data.oppDetails.Product_Domain__c != null && 
                   !cpeProductDomainValue.includes(data.oppDetails.Product_Domain__c )){
                    component.set('v.showProductDomain', true);
                }
                console.log('Oppdetails',data.oppDetails);
                if(data.oppDetails != null &&
                   data.oppDetails.Product_Type__c == 'Non Modular' &&
                   data.oppDetails.Product_Count_Status_Won__c > 0 &&
                   data.oppDetails.Probability > 29 &&
                   data.oppDetails.StageName != 'Closed Lost' && data.oppDetails.StageName != 'Closed Won'
                  ){
                    console.log('Inside Non Modular');
                    component.set('v.validForCBS', true);
                    console.log('True Valid for CBS');
                }
                //Start : P2OB-11749
                if(data.oppDetails != null &&
                   data.oppDetails.Product_Count_Status_Won__c > 0 &&
                   data.oppDetails.Product_Type__c == 'Non Modular' &&
                   data.oppDetails.StageName === 'Closed Won'
                  ){
                    console.log('Inside IF',data.oppDetails.StageName);
                    component.set('v.validForCBSContract', true); 
                }
                //END
            }
        });
        $A.enqueueAction(action);
    },
    
    showToastWithURL : function(component, event, helper, msg, RecordID, URLLabel) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: 'This is a required message',
            messageTemplate: msg,
            messageTemplateData: [{
                url: '/'+RecordID,
                label: URLLabel,
            }]
        });
        toastEvent.fire();
    },
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case Created",
            "type":'success',
            "message": "Case created successfully"
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(component, event, helper, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case Creation Failed",
            "type":'error',
            "message": msg,
            "mode":'sticky'
        });
        toastEvent.fire();
    },
    
    showInfoToast : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Work in Progress",
            "type":'info',
            "message": "Work is still in  Progress...................."
        });
        toastEvent.fire();
    },
    
    doSOCCreate : function(component, event, helper) {
        component.set('v.showSpinner',true); //P2OB-9178 : Turn-off Spinner 
        var recId=component.get('v.recordId');
        var action = component.get("c.createSOCRequest");        
        action.setParams({ oppId : recId});
        action.setCallback(this, function(response){            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showSpinner',false); //P2OB-9178 : Turn-off Spinner 
                var data=response.getReturnValue(); 
                console.log('doInit -- sfd_CreateSOCRequestController -- RESPONSE');
                console.log(data); 
                if(data.status == "fail"){                    
                    $A.get("e.force:closeQuickAction").fire();
                    var errorMsg=data.response;
                    var indexError=errorMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                    console.log(indexError);
                    errorMsg=errorMsg.substring(indexError+34);
                    errorMsg = errorMsg.substring(0, errorMsg.length - 4);
                    helper.showErrorToast(component, event, helper,errorMsg);
                }
                else {
                    $A.get("e.force:closeQuickAction").fire();
                    
                    $A.get('e.force:refreshView').fire();      
                    
                    helper.showSuccessToast(component, event, helper); 
                }    
            }    
        });        
        $A.enqueueAction(action);
    },
    validateAndCreateCBSCase : function(component, event, helper){
        component.set('v.showSpinner',true);
        var recId=component.get('v.recordId');
        var action = component.get("c.existingCBSCaseValidation");
        action.setParams({ oppId : recId});        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showSpinner',false);
                var data = response.getReturnValue();
                console.log(data);
                if(data.CaseAlreadyExist == 'yes'){
                    if(data.caseRec != null){
                        helper.showToastWithURL(component, event, helper,'You have already engaged the CBS team for designing your billing solution. Please click on {0} to view the status and update any additional information via chatter to the CBS team member.',data.caseRec.Id,data.caseRec.CaseNumber);
                    }
                } 
                else if(data.CaseAlreadyExist == 'no'){
                    component.set('v.ShowAllBeforeFlow',false);
                    var flow = component.find("flowData");
                    var inputVariables = [{name : "InputOppVar",
                                           type : "String",
                                           value : component.get('v.recordId')}];           
                    //start the flow
                    flow.startFlow("CBS_Billing_Design", inputVariables );
                }
            }
        });
        $A.enqueueAction(action);
    },
    validateAndCreateCBSContractCase : function(component, event, helper){
        component.set('v.isGetSupport',true);
        component.set('v.showSpinner',true);
        var recId=component.get('v.recordId');
        var action = component.get("c.existingCBSCaseContractValidation");
        action.setParams({ oppId : recId}); 
        console.log('recId',recId);
        action.setCallback(this, function(response){ 
            var state = response.getState();
            console.log('state is ',state);
            if (state === "SUCCESS") {
                component.set('v.showSpinner',false);
                var data = response.getReturnValue();
                console.log(data);
                console.log('Caselist is',data.caseRec);
                console.log('CaseAlreadyExist',data.CaseAlreadyExist);
                if(data.CaseAlreadyExist == 'yes'){
                    console.log('CaseRec',data.caseRec);
                    if(data.caseRec != null){
                        helper.showToastWithURL(component, event, helper,'You have already engaged the CBS team for contracting your billing solution. Please click on {0} to view the status and update any additional information via chatter to the CBS team member.',data.caseRec.Id,data.caseRec.CaseNumber);
                    }
                } 
                else if(data.CaseAlreadyExist == 'no'){
                    console.log('flowcall');
                    component.set('v.ShowAllBeforeFlow',false);
                    var flow = component.find("flowData");
                    var inputVariables = [{name : "varOpportunityId",
                                           type : "String",
                                           value : component.get('v.recordId')},
                                          {name : "isGetSupport",
                                           type : "Boolean",
                                           value : 'True'}
                                         ];           
                                          //start the flow
                                          console.log('Call the flow');
                                          debugger;
                                          flow.startFlow("CBS_Billing_Contract", inputVariables );
                                          console.log('FLow called successfully');
                                          }
                                          }
                                          });
                                          $A.enqueueAction(action);
                                          },
                                          handleStatusChangeTest : function(component, event, helper){
                                          
                                          component.set("v.showSpinner",false);
                                          if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
                                          
                                          var outputVariables = event.getParam("outputVariables");
                                          var varChildCaseUpdateList;
                                          var outputVar;
                                          for(var i = 0; i < outputVariables.length; i++) {
                                          outputVar = outputVariables[i];
                    if(outputVar.name === "varChildCaseUpdateList") {
                        varChildCaseUpdateList = outputVar.value;
                    }
                }
                
                component.set('v.showFlowScreen', true);
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:salesup_ThankYouScreen",
                    componentAttributes: {
                        varChildCaseList : varChildCaseUpdateList,
                        opportunityId: component.get('v.recordId'),
                        isCallFromCPEFlowComp: true
                    }
                });
                evt.fire();
            }
            else if(event.getParam("status") === "ERROR") {
                
            }
        } 
                           })