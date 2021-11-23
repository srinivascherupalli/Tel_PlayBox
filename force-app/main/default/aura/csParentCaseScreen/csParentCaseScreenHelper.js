({
    validateAndCreateCBSCase : function(component, event, helper){
        var recId=component.get('v.recordId');
        var action = component.get("c.getCaseValidations");
        action.setParams({ oppId : recId,flowName : 'CBSBilling'});        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                
                if(data.CaseAlreadyExist === 'yes'){
                    if(data.caseRec != null){
                        helper.showToastWithURL(component, event, helper,'You have already engaged the CBS team for designing your billing solution. Please click on {0} to view the status and update any additional information via chatter to the CBS team member.',data.caseRec.Id,data.caseRec.CaseNumber);
                    }
                } 
                else if(data.CaseAlreadyExist === 'no'){
                    if(data.oppDetails != null &&
                       data.oppDetails.Product_Type__c == 'Non Modular' &&
                       data.oppDetails.Product_Count_Status_Won__c > 0 &&
                       data.oppDetails.Probability > 29 &&
                       data.oppDetails.StageName != 'Closed Lost' && data.oppDetails.StageName != 'Closed Won'
                      ){  var flow = component.find("flowData"); 
                        var inputVariables = [
                            {
                                name : "InputOppVar",
                                type : "String",
                                value : component.get('v.recordId')
                                
                            }
                        ];
                        //start the flow
                        flow.startFlow("CBS_Billing_Design", inputVariables);
                       } 
                    else {
                        helper.showErrorToast(component, event, helper,"Before engaging the CBS team for design requests, please ensure:\n1) Opportunity is at Develop or ahead.\n2) A valid product basket is synced with the opportunity."); 
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //Added by Sanjay Thakur as a part of P2OB-14486
    //Adding validation for Presales type as per the Opportunity stages
    validatePresalesOpportunityStage : function(component, event, helper,categoryLabel){
        
        var categoryVal = component.get('v.categoryLabel');
        var recId=component.get('v.recordId');
        console.log('RecordId==>',recId);
        var action = component.get("c.getCaseValidations");
        action.setParams({ oppId : recId,flowName : 'Get Solution Support'});        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                /*if(data.oppDetails != null && data.oppDetails.Product_Type__c == 'Modular'){
                    helper.showErrorToast(component, event, helper,"This option is not available for Digitised opportunities."); 
                }
                else if(data.oppDetails != null && (data.oppDetails.StageName == 'Closed' || data.oppDetails.StageName == 'Define' || data.oppDetails.StageName == 'Price')){
                    helper.showErrorToast(component, event, helper,"Presales Solution Request cannot be raised when the opportunity is in Define, Price or Closed. Please move the opportunity to another stage if applicable and select the appropriate request type."); 
                }else if(data.oppDetails != null && data.oppDetails.Opportunity_Record_Type__c == 'Enterprise - In Contract'
                        && (data.oppDetails.Contract_Type__c == null || data.oppDetails.Expected_TCV_Range__c == null || data.oppDetails.Will_this_require_integration__c == null || data.oppDetails.Number_of_Additional_Domains_if_any__c == null)){
                    helper.showErrorToast(component, event, helper,"One or some of the below fields are empty. Please ensure all of them are completed prior to engaging solution support:\n 1) Contract Type\n 2) Expected TCV Range\n 3) Number of Additional Domains (if any)\n 4) Will this require integration?"); 
                	
                }
                else if(data.oppDetails != null && categoryVal == 'Customer Meeting' &&
                   data.oppDetails.StageName != 'Qualify' && data.oppDetails.StageName != 'Develop' && data.oppDetails.StageName != 'Propose'
                  ){
                    helper.showErrorToast(component, event, helper,"This request type can only be raised when your Opportunity is in the Qualify, Develop, or Propose stage. Please progress your Opportunity to the appropriate stage in order to raise this request."); 
                }else if(data.oppDetails != null && categoryVal == 'Solution Development' &&
                   data.oppDetails.StageName != 'Develop'
                  ){
                    helper.showErrorToast(component, event, helper,"This request type can only be raised when your Opportunity is in the Develop stage. Please progress your Opportunity to the appropriate stage in order to raise this request."); 
                }else if(data.oppDetails != null && categoryVal == 'Qualification' &&
                   data.oppDetails.StageName != 'Qualify'
                  ){
                    helper.showErrorToast(component, event, helper,"This request type can only be raised when your Opportunity is in the Qualify stage. Please progress your Opportunity to the appropriate stage in order to raise this request."); 
                }else if(data.oppDetails != null && categoryVal == 'Workshop' &&
                   data.oppDetails.StageName != 'Qualify'
                  ){
                    helper.showErrorToast(component, event, helper,"This request type can only be raised when your Opportunity is in the Qualify stage. Please progress your Opportunity to the appropriate stage in order to raise this request."); 
                }else if(data.oppDetails != null && categoryVal == 'Indicative Pricing' &&
                   data.oppDetails.StageName != 'Qualify'
                  ){
                    helper.showErrorToast(component, event, helper,"This request type can only be raised when your Opportunity is in the Qualify stage. Please progress your Opportunity to the appropriate stage in order to raise this request."); 
                }*/
                
               // else{
                    var flow = component.find("flowData"); 
                        var inputVariables = [
                            {
                                name : "InputOppVar",
                                type : "String",
                                value : component.get('v.recordId')
                            },
                            {
                            	name : "RequestType",
                            	type : "String",
                            	value : component.get('v.categoryLabel')
                                
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
                    		},
                            {
                            	name : "FlowName",
                            	type : "String",
                            	value : component.get('v.flowInput')
                    		}
                        ];
                        //start the flow
                        flow.startFlow("Get_Solution_Support", inputVariables );
                
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    validateAndCreateCBSContractCase : function(component, event, helper){
        var recId=component.get('v.recordId');
        var action = component.get("c.getCaseValidations");
        action.setParams({ oppId : recId,flowName : 'CBSContract'}); 
        console.log('recId',recId);
        action.setCallback(this, function(response){ 
            var state = response.getState();
            console.log('state is ',state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                console.log('Caselist is',data.caseRec);
                
                if(data.CaseAlreadyExist == 'yes'){
                    console.log('CaseRec',data.caseRec);
                    if(data.caseRec != null){
                        helper.showToastWithURL(component, event, helper,'You have already engaged the CBS team for contracting your billing solution. Please click on {0} to view the status and update any additional information via chatter to the CBS team member.',data.caseRec.Id,data.caseRec.CaseNumber);
                    }
                } 
                else if(data.CaseAlreadyExist == 'no'){
                    console.log('CaseAlreadyExist',data.StageName);
                    console.log('CaseAlreadyExist',data.Product_Type__c);
                    console.log('CaseAlreadyExist',data.oppDetails.Product_Count_Status_Won__c);
                    if(data.oppDetails != null &&
                       data.oppDetails.Product_Count_Status_Won__c > 0 &&
                       data.oppDetails.Product_Type__c == 'Non Modular' &&
                       data.oppDetails.StageName === 'Closed Won'
                      ){
                        console.log('flowcall');
                        component.set('v.ShowAllBeforeFlow',false);
                        var flow = component.find("flowData");
                        var inputVariables = [
                            {
                                name : "varOpportunityId",
                                type : "String",
                                value : component.get('v.recordId')
                            },
                            {
                                name : "isGetSupport",
                                type : "Boolean",
                                value : true
                            }
                        ];
                        flow.startFlow("CBS_Billing_Contract", inputVariables);
                    }
                    else {           
                        helper.showErrorToast(component, event, helper,"Before engaging the CBS team for Contract requests, please ensure:\n1) Opportunity is Close/Won and have no open contract case for this opportunity.\n2) A valid product basket is synced with the opportunity."); 
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    createCPECase : function (component,helper,event){
        var action = component.get("c.getCaseValidations");
        action.setParams({ oppId : component.get('v.recordId'), flowName: 'CPE'});       
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                debugger;
                var cpeProductDomainValue = ['CLOUD SERVICES', 'MDN', 'SECURITY', 'DIGITAL MEDIA', 'OTHER',
                                             'UC VIDEO & COLLABORATION', 'UC CISCO WEBEX', 'CONTACT CENTRE', 'MOBILITY (PROJECT)'];
                console.log('@@@@@'+data.oppDetails.Product_Domain__c );
                if(data.oppDetails != null && data.oppDetails.Product_Domain__c != null &&
                   !cpeProductDomainValue.includes(data.oppDetails.Product_Domain__c )){
                    component.set('v.showProductDomain', true);
                    
                }
                var flow = component.find("flowData");
                var inputVariables = [
                    {
                        name : "varOpportunityId",
                        type : "String",
                        value : component.get('v.recordId')
                    },
                    {
                        name : "varIsCalledFromOpportunity",
                        type : "Boolean",
                        value : true
                    },{  
                        name : "varShowProductDomain",
                        type : "Boolean",
                        value : component.get('v.showProductDomain')
                    }
                ];
                flow.startFlow("Create_CPE_Request_Cases", inputVariables);
            }
        });
        $A.enqueueAction(action);
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
})