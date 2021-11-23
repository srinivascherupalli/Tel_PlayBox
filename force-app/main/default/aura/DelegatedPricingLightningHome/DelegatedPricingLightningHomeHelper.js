/********************************************************************
    EDGE        : 114351
    Component   : DelegatedPricingLightningHomeHelper
    Description : New custom screen to initiate DPR home Page
    Author      : Deepak Kumar
    
    * Histry of Update:-
    * Vishal Arbune: 26/05/2020 EDGE-143011 To enable Reject Contract button on DPR when Deal status is Contract Generated.
    *********************************************************************/ 
({
    //EDGE: 114351 | Get Opportunity details.
    fetchOpportunityDetails : function(component,event,helper) {
        // Create a one-time use instance of the getOpportunityDetails action in the server-side controller
        var action = component.get("c.getOpportunityDetails");
        action.setParams({ oppId : component.get("v.OpportunityId") });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.opportunityDetails",response.getReturnValue());
                component.set("v.DprName.Opportunity__c",response.getReturnValue().Id);
                component.set("v.OpportunityContactRolesStatus",response.getReturnValue().OpportunityContactRoles);
                var stage = component.get("v.opportunityDetails.StageName");
                if(stage == 'Closed Won' || stage == 'Closed Lost'){
                    component.set("v.dontAllowDPROnClosedOpportunity",true);
                    return;
                }
                if( response.getReturnValue().Product_Type__c !=='Modular' ){
                    var toggleText1 = component.find("DelegatedIncompatableNonMolular");
                    $A.util.toggleClass(toggleText1, "slds-hide");
                } else if (response.getReturnValue().Pricing_Method__c !== 'Delegated Pricing'){
                    var toggleText = component.find("DelegatedIncompatable");
                    $A.util.toggleClass(toggleText, "slds-hide");
                } else { 
                    if(!component.get("v.navigateToHome") )
                    {
                        if(component.get("v.DPRId") ==null || component.get("v.DPRId")=='')
                        {
                            //EDGE:134133 | not allow new DPR if a DPR already in 'Sent for Approval'
                            var action1 = component.get("c.getSentForApprovalDPR");
                            action1.setParams({ oppId : component.get("v.OpportunityId") });
                            action1.setCallback(this, function(response) {
                                //debugger;
                                var state = response.getState();
                                if (state === "SUCCESS") 
                                {
                                    var sentFOrApproval = response.getReturnValue();
                                    if(sentFOrApproval == true){
                                        component.set("v.dontAllowDPROnSentForApproval",true);
                    					return;
                                    }
                                    
                                    if(component.get("v.OpportunityContactRolesStatus") != null && component.get("v.OpportunityContactRolesStatus") != '' && component.get("v.OpportunityContactRolesStatus") != undefined ){ 
                                        
                                        this.insertDPR(component,event,helper);
                                       
                                    } else {
                                        component.set("v.OpportunityContactRolesStatusModal",true);
                                        //window.history.back();
                                    }
                                    
                                }
                                else if (state === "INCOMPLETE") { 
                                }
                                    else if (state === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                console.log("Error message: " + errors[0].message);
                                            }
                                        } else {
                                            console.log("Unknown error");
                                        }
                                    }
                            });
                            $A.enqueueAction(action1);
                            
                        }
                    }
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        var markitableAction = component.get("c.getMarketableofferDetailes");
        markitableAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.MarketableOffer",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(markitableAction);
    },
    
    //EDGE : 114351 | Save DPR Landing screen details.
    //EDGE:118631 | Escalate the deal to the next approving authority.
    insertDPR : function(component,event,helper){
        debugger;
        var action = component.get("c.insertDelegatedPricingRequest");
        action.setParams({ dpRequest : component.get("v.DprName") });
        //c
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.DprName",response.getReturnValue());
                component.set("v.DprName.Id",response.getReturnValue().Id);
                component.set("v.disableEnableSave",true);
                component.set("v.enableEscalate",true);
                component.set("v.esclate", false);
                if(component.get("v.DprName.Deal_Status__c")=='Sent for Approval'){
                    if(component.get("v.openEscalateModal")== true){
                        this.disableFieldonEscalateSalesDelegation(component,event,helper);
                        this.fetchDealApprover(component,event,helper);
                    }
                    else if (component.get("v.openCaseModal") == true)
                    {
                        this.disableFieldonEscalatePricingTeam(component,event,helper);  
                    }
                    
                }
                
                if(component.get("v.DPRId") !=null || component.get("v.DPRId")!=''){
                    this.getDelegatedPricingRequest(component,event,helper); 
                }
                if(component.get("v.DPRId") ==null || component.get("v.DPRId")=='')
                {
                    window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+response.getReturnValue().Id+'/view','_self');
                }
                if(component.get("v.toReload") == true)
                {
                    location.reload();
                    component.set("v.toReload",false);
                    component.set("v.SpinnerCheck",false);
                }
            }
            else if (state === "INCOMPLETE") { 
                component.set("v.disableAssign",fasle);
                component.set("v.disableEnableSave",false);
                component.set("v.SpinnerCheck",false);
            }
                else if (state === "ERROR") {
                    component.set("v.disableAssign",false);
                    component.set("v.disableEnableSave",false);
                    component.set("v.SpinnerCheck",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // EDGE:117700: Cancel function on DPR screen.
    cancelDPR : function(component,event,helper){
        var action = component.get("c.insertDelegatedPricingRequest");
        action.setParams({ dpRequest : component.get("v.DprName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.disableEnableSave",true);
                component.set("v.DprName",response.getReturnValue());
                component.set("v.disableOthers",true);
                component.set("v.cancel", false);
                component.set("v.disable",true);
                component.set("v.disableclone",false);
                component.set("v.disableCancel", true);
                component.set("v.enableEscalate",true);
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // EDGE : 114351 | Get Delegated Pricing details.
    getDelegatedPricingRequest : function(component,event,helper) 
    {
        var action = component.get("c.fetchDelPricingRequest");
        action.setParams({ DPRId : component.get("v.DPRId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {	
                component.set("v.MarkasVariation",response.getReturnValue().Mark_as_Variation__c);
                component.set("v.OpportunityStage",response.getReturnValue().Opportunity__r.StageName);
                if(response.getReturnValue().Deal_Status__c == 'Cancelled'){
                    component.set("v.disableCancel",true);
                    component.set("v.disableclone",false);
                    component.set("v.disable", true);
                }
                //added by badri
                if((response.getReturnValue().Deal_Status__c == 'Cancelled' || response.getReturnValue().Deal_Status__c == 'Active') && (response.getReturnValue().Opportunity__r.StageName == 'Closed Lost' || response.getReturnValue().Opportunity__r.StageName == 'Closed Won')){
                component.set("v.CloneDisable",true);
                }
                //Added by Hari/Vamshi start // Badri : added opportunity condition
                if(response.getReturnValue().Deal_Status__c == 'Approved' && (response.getReturnValue().Opportunity__r.StageName != 'Closed Won' || response.getReturnValue().Opportunity__r.StageName != 'Closed Lost')){
                    component.set("v.enableInitiateContract",false);
                }
                //Added by Hari/Vamshi end
                
                //Added by Rishabh start
                if(response.getReturnValue().Deal_Status__c == 'Contract Generated'){
                    component.set("v.disableEnableAcceptContract",false);
                    //EDGE-143011	<Deal contract flow> Creation of service terms, general service terms records in CALMS for document generation.
                    //To enable Reject Contract button on DPR when Deal status is Contract Generated.
                    component.set("v.disableEnableRejectContract",false);
                }
                if(response.getReturnValue().Deal_Status__c == 'Contract Initiated'){
                    component.set("v.disable",true);
                    component.set("v.disableEnableRejectContract",false);
                }
                if(response.getReturnValue().Deal_Status__c == 'Contract Rejected'){
                    component.set("v.disable",true);
                    component.set("v.disableEnableRejectContract",true);
                    component.set("v.disableCancel",true);
                }
                
                if(response.getReturnValue().Deal_Status__c == 'Active' && (response.getReturnValue().Opportunity__r.StageName != 'Closed Won' || response.getReturnValue().Opportunity__r.StageName != 'Closed Lost')){
                    component.set("v.disable",true);
                    component.set("v.disableCancel",true);
                }
               if(response.getReturnValue().Opportunity__r.StageName == 'Closed Won' || response.getReturnValue().Opportunity__r.StageName == 'Closed Lost'){
                    component.set("v.CloneDisable",true);
                    component.set("v.disableEnableSave",true);
                    component.set("v.disable",true);
                    component.set("v.enableEscalate",true);
                    component.set("v.enableInitiateContract",true);
                    component.set("v.disableEnableAcceptContract",true);
                    component.set("v.disableCancel",true);
                }
                //Added by Rishabh end
                component.set("v.DprName",response.getReturnValue());
                component.set("v.OpportunityId",response.getReturnValue().Opportunity__c);
                if(response.getReturnValue().Mark_as_Variation__c)
                {
                    component.set("v.CheckBoxValue",true);
                }
                component.set("v.IsPrimary", response.getReturnValue().isPrimary__c);
                if(component.get("v.DprName.Deal_Status__c")=='Sent for Approval'){
                    if(component.get("v.CheckBoxValue") == false && response.getReturnValue().Final_Delegation_Outcome__c !== 'Customized Pricing')
                    {
                        this.disableFieldonEscalateSalesDelegation(component,event,helper);
                    }
                    else if (component.get("v.CheckBoxValue") == true || response.getReturnValue().Final_Delegation_Outcome__c == 'Customized Pricing')
                    {
                        this.disableFieldonEscalatePricingTeam(component,event,helper);
                    }
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:114351 | Get Delegated Pricing details.
    getLoggedInUserInfo : function(component,event,helper) 
    {
        var action = component.get("c.fetchDelegatedPricingCurrentLoggedUser");
        action.setParams({ DPRId : component.get("v.DPRId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var oppStage = response.getReturnValue().delPriceReq.Opportunity__r.StageName;
				component.set("v.IsPrimary",response.getReturnValue().delPriceReq.isPrimary__c);
                component.set("v.currentDelegation",response.getReturnValue().retVal[0]);
                component.set("v.FinalDelOutcome",response.getReturnValue().retVal[1]);
                component.set("v.DealStatus",response.getReturnValue().delPriceReq.Deal_Status__c);
                component.set("v.currentLoggedInUser",response.getReturnValue().currentDelUser.Name);
                
                if(response.getReturnValue().retVal.length == 2){
                    
                    if((component.get("v.IsPrimary") === true) && 
                       (component.get("v.DealStatus") === 'Scored') && 
                       ((component.get("v.currentDelegation")) < (component.get("v.FinalDelOutcome"))) && 
                       ((response.getReturnValue().delPriceReq.Mark_as_Variation__c) !== true) &&
                       (response.getReturnValue().delPriceReq.Final_Delegation_Outcome__c !== 'Customized Pricing') &&
                      (oppStage !== 'Closed Won' || oppStage !== 'Closed Lost') )
                    {
                        component.set("v.enableEscalate",false);
                        component.set("v.openEscalateModal",true);
                    }
                    if((response.getReturnValue().delPriceReq.Mark_as_Variation__c == true && response.getReturnValue().delPriceReq.Deal_Status__c =='Scored' && (oppStage !== 'Closed Won' || oppStage !== 'Closed Lost')) || 
                       (response.getReturnValue().delPriceReq.Deal_Status__c =='Scored' && response.getReturnValue().delPriceReq.Final_Delegation_Outcome__c =='Customized Pricing' && (oppStage !== 'Closed Won' || oppStage !== 'Closed Lost'))) 
                    {
                        component.set("v.openCaseModal",true);
                        component.set("v.enableEscalate",false);
                    }
                    
                    if(response.getReturnValue().delPriceReq.is_Deal_Escalated__c === true ||
                       response.getReturnValue().delPriceReq.Final_Delegation_Outcome__c ==='Not Offerable' ||
                       response.getReturnValue().delPriceReq.Final_Delegation_Outcome__c ==='Account Executive'
                      )
                    {
                        component.set("v.enableEscalate",true);
                    }
                    //Added by Rishabh
                    if(oppStage == 'Closed Won' || oppStage == 'Closed Lost')
                    {
                        component.set("v.enableEscalate",true);
                    }
                    
                } 
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:118631 | Escalate the deal to the next approving authority.
    getLoggedInUserInfoValue : function(component,event,helper) 
    {
        var action = component.get("c.getDelegationUser");
        action.setParams({ DPRId : component.get("v.DPRId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {   
                component.set("v.DelOutcomeUser",response.getReturnValue());
                component.set("v.esclate", true);
                component.set("v.enableEscalate", true);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.enableEscalate",false);
            }
                else if (state === "ERROR") {
                    component.set("v.enableEscalate",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // Get Opportinity ID
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    loadDPR : function(component, event) {
        var action = component.get("c.getDPROfferlist");
        action.setParams({dprId:component.get("v.DPRId")});
        action.setCallback(this, function(response) {
            component.set("v.DPROfferid",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:116099 : Delete function.	
    deleteDPR : function(component, event) {
        var action = component.get("c.deleteDPROfferById");
        var dprId = component.get("v.DPRId");
        action.setParams({dprId:component.get("v.DPRId")});
        action.setCallback(this, function(response) 
                           {
                               component.set("v.DPROfferid",response.getReturnValue());
                               window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+dprId+'/view','_self');
                           });
        $A.enqueueAction(action);
    },
    
    //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals
    getOpportunityDetails_CaseCreation : function(component,event,helper) 
    {
        
        var action = component.get("c.getOpportunityDetails");
        action.setParams({ oppId : component.get("v.OpportunityId")});
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.CaseOpportunityId",response.getReturnValue().Id);
                component.set("v.attachmentCount",response.getReturnValue().Contract_Attachment_Count__c);
                if(response.getReturnValue().StageName === 'Closed Won' || response.getReturnValue().StageName === 'Closed Lost')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Pricing Support Case cannot be created for a closed opportunity.',
                        duration:'1000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                else
                {
                    if(response.getReturnValue().StageName === 'Cancelled')
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Pricing Support Case cannot be created for a cancelled opportunity.',
                            duration:'1000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else
                    {
                        component.set("v.caseCheck", true);
                    }
                }
            }
            else if (state === "INCOMPLETE") {
                component.set("v.enableEscalate",false);
            }
                else if (state === "ERROR") {
                    component.set("v.enableEscalate",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals.
    insertDeal : function(component,event,helper){
        var action = component.get("c.insertDelegatedPricingRequest");
        action.setParams({ dpRequest : component.get("v.DprName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {	 	
                component.set("v.caseCheck",false);
                if(component.get("v.DprName.Deal_Status__c")=='Sent for Approval'){
                    this.disableFieldonEscalatePricingTeam(component,event,helper);
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Case Created Successfully.',
                    message: ' ',
                    messageTemplate: ' ',
                    duration:' 1000',
                    key: 'info_alt',
                    type: 'success',
                });
                toastEvent.fire();
                component.set("v.SpinnerCheck",false);
                location.reload();
            }
            else if (state === "INCOMPLETE") { 
                component.set("v.SpinnerCheck",false);
                component.set("v.caseCheck",false);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.SpinnerCheck",false);
                    component.set("v.caseCheck",false);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        component.set("v.SpinnerCheck",false);
    },
    
    //EDGE:114351 | Get Delegated Pricing details.
    fetchRecordId : function(component,event,helper){
        // debugger;
        var action = component.get("c.getRecordTypeIdbyName");
        action.setCallback(this, function(response) {
            //debugger;
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.caseRecordId",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:118631 | Escalate the deal to the next approving authority.
    disableFieldonEscalatePricingTeam : function(component,event,helper){  
        var action = component.get("c.fetchGroupMember");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("Message: "+state);
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue())
                {
                    component.set("v.disable", true);
                }
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:118631 | Escalate the deal to the next approving authority.
    disableFieldonEscalateSalesDelegation : function(component,event,helper){
        var action = component.get("c.fetchDelPricingRequest");
        action.setParams({ DPRId : component.get("v.DPRId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.DealApprover",response.getReturnValue().Deal_Approver__c);
                if(component.get("v.currentLoggedInUser") !== response.getReturnValue().Deal_Approver__r.Name)
                {
                    component.set("v.disable", true);
                } 
                else
                {
                    component.set("v.disable", false);
                }
                
                if(response.getReturnValue().Deal_Status__c === 'Cancelled')
                {
                    component.set("v.disable", true);
                }
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError(); 
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:118631 | Escalate the deal to the next approving authority
    FieldonEscalateAssignTeamMember : function(component,event,helper){
        var action = component.get("c.insertOpportunityTeamMember");
        action.setParams({ OpportunityId : component.get("v.OpportunityId"),
                          DealApprover :component.get("v.DealApprover") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("Message: "+state);
            if (state === "SUCCESS") 
            {
                //alert(JSON.stringify(response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    //EDGE:118631 | Escalate the deal to the next approving authority
    fetchDealApprover : function(component,event,helper){
        var action = component.get("c.fetchDelPricingRequest");
        action.setParams({ DPRId : component.get("v.DPRId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.DealApprover",response.getReturnValue().Deal_Approver__c);
                this.FieldonEscalateAssignTeamMember(component,event,helper);
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // EDGE:123727  | To persist agreed discount records in database once contract is accepted.
    getAcceptContractHelper:function(component,event){
        var dprId = component.get("v.DPRId");
        var action = component.get("c.acceptContract");
        action.setParams({dprId: dprId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.disableEnableAcceptContract",true);
                component.set("v.SpinnerCheck",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Contract has been Accepted.",
                    "type": "success"    
                });
                toastEvent.fire();
                window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+dprId+'/view','_self');
            }
            else if (state === "INCOMPLETE") {}
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            component.set("v.SpinnerCheck",false);
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.SpinnerCheck",false);
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // EDGE:136226  |  update the status of Deal as Contract Rejected and Related Contract junction status to Cancelled.
    getRejectContractHelper:function(component,event){
        var dprId = component.get("v.DPRId");
        var action = component.get("c.rejectContract");
        action.setParams({dprId: dprId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.disableEnableRejectContract",true);
                component.set("v.SpinnerCheck",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Contract has been Rejected.",
                    "type": "success"    
                });
                toastEvent.fire();
                window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+dprId+'/view','_self');
            }
            else if (state === "INCOMPLETE") {}
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            component.set("v.SpinnerCheck",false);
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.SpinnerCheck",false);
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // EDGE:117699  | To clone the DPR.
    cloneDPRHelper:function(component,event){
        var dprId = component.get("v.DPRId");
        var action = component.get("c.dprClone");
        action.setParams({dprId: dprId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var newDPRId = response.getReturnValue();
                component.set("v.CloneDelegatedPricingRequestStart", false);
                component.set("v.CloneDelegatedPricingRequestFinish", true);
                window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+newDPRId+'/view','_self');
            }
            else if (state === "INCOMPLETE") {}
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
     
      //To create Contract Junction Record
     //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    insertContractJunction : function(component,event,helper){
        var action = component.get("c.insertContJunc");
        action.setParams({ dpRequest : component.get("v.DprName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {	
                component.set("v.ContractJunctionID",response.getReturnValue());
                component.set("v.SpinnerCheck",false);
                component.set("v.InitiateContractCase",true);
                
            }
            
            else {
                component.set("v.SpinnerCheck",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Something has gone wrong.',
                    message: ' ',
                    messageTemplate: ' ',
                    duration:'1000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire()
            }
        
        });
        $A.enqueueAction(action);
        
    },
      //To get ContractSupport case RecordType
     //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    fetchContractSupportRecordType : function(component,event,helper){
        // debugger;
        var action = component.get("c.getContractSupportCaseRecordType");
        action.setCallback(this, function(response) {
            //debugger;
            var state = response.getState();
            if (state === "SUCCESS") 
            {

                component.set("v.caseContractSupportRecordType",response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") { 
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    // EDGE:136226 | To chech if already one dpr is in contract initiated status.
    checkInitiateContract:function(component,event){
        var dprId = component.get("v.DPRId");
        var action = component.get("c.checkInitCont");
        action.setParams({dprId: dprId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == true){
                    component.set("v.dontAllowInitiateContract",true);
                }else{
                    this.insertContractJunction(component);
                }
                
            }
            else {
                component.set("v.SpinnerCheck",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Something has gone wrong.',
                    message: ' ',
                    messageTemplate: ' ',
                    duration:'1000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire()
            }
                
        });
        $A.enqueueAction(action);
    },
})