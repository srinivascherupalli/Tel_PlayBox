/********************************************************************
    EDGE        : 114351
    Component   : DelegatedPricingLightningHomeController
    Description : New custom screen to initiate DPR home Page
    Author      : Deepak Kumar
    *********************************************************************/ 

({
    doInit : function(component, event, helper) {
        //Fetch Record Id
        var recordId = component.get("v.recordId");
        component.set("v.DPRId",recordId);
        if(recordId == null || recordId == '' || recordId == 'undefined'){ 
            //Fetch Opportunity Id 
            document.title = component.get("v.title");
            var value = helper.getParameterByName(component , event, 'inContextOfRef');
            var context = '';
            context = JSON.parse(window.atob(value));
            component.set("v.OpportunityId",context.attributes.recordId);
        }
        // EDGE : 114351 | Get Opportunity details.
        var oppId = component.get("v.OpportunityId");
        if(component.get("v.OpportunityId") !=null) {
            helper.fetchOpportunityDetails(component);
        }
        
        // EDGE : 114351 | Get Delegated Pricing details.
        if(component.get("v.DPRId") !=null) { 
            helper.getDelegatedPricingRequest(component); 
        }
        
        // EDGE : 114351 | Get Delegated Pricing details.
        if(component.get("v.DPRId")==null || component.get("v.DPRId")==''){
            component.set("v.DprName.Deal_Status__c","Draft");
        }      
        //logged-in user & control Esclate
        helper.getLoggedInUserInfo(component,event,helper);
        helper.fetchRecordId(component,event,helper);
        
        helper.fetchContractSupportRecordType(component,event,helper);
       
    }, 
    
    // EDGE : 114351 --> added to enable/disbale buttons..
    enableSaveButton: function(component,event,helper){
        component.set("v.disableOthers",true);
        component.set("v.disableclone",true); //EDGE: 117700 cancel disable functionality
        component.set("v.disableEnableSave",false);
        component.set("v.disableCancel",false);
    },
    
    //EDGE : 114351 | Save DPR Landing screen details.
    saveDelegatedPricing: function(component,event,helper){
        var inputCmp = component.find("DPRrequest");
        var value = inputCmp.get("v.value");
        component.set("v.toReload",true);
        component.set("v.disableEnableSave",true);
        component.set("v.SpinnerCheck",true);
        if(component.get("v.DprName.Mark_as_Variation__c")){
            if (value === "" || value == null) {
                inputCmp.setCustomValidity("Parent Delegated Pricing request field is mandatory."); //EDGE: 114333 mandatory field message functionality
            } 
            else {
                inputCmp.setCustomValidity("");
                helper.insertDPR(component,event,helper);
                component.set("v.disableCancel", false);
            }
            inputCmp.reportValidity();
        }
        else {
            helper.insertDPR(component,event,helper);
            component.set("v.disableCancel", false);
        }
    },
    
    //EDGE:114351 | Add Product and naviate to DPR Detail Screen.
    SelectProductComponent : function (component,evt,helper){ 
        component.set("v.disableOthers",true);
        component.set("v.disableEnableSave",false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams
        (
            {
                componentDef: "c:DelegatedPricingSelectProduct",
                componentAttributes:
                { 
                    DPRId: component.get("v.DPRId"),
                    OpportunityId: component.get("v.OpportunityId"),
                    MarketableOffer: component.get("v.MarketableOffer")
                }
            }
        );
        evt.fire(); 
    },
    
    doOnLoad : function(component, event, helper){
        helper.loadDPR(component, event);
    },
    
    //EDGE:114351 | Related Offers.
    viewProductComponent : function (component,event,helper){ 
        //debugger;
        var offer = event.currentTarget.getAttribute("data-recId");
        var product = offer.split("|");
        var offerId = product[0];
        var offerName = product[1];
        // var offerId = event.getSource().get("v.name");     
        var View=true;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({componentDef: "c:DelegatedPricingSelectProduct",
                       componentAttributes: {DPRId: component.get("v.DPRId"),
                                             DPROffer: offerId,
                                             View:View,
                                             SelectedProduct:offerName
                                            }});
        evt.fire(); 
    },    
    
    //EDGE:114351 | Edit Products.
    editProductComponent : function (component,event,helper){ 
        debugger;
        var offer = event.getSource().get("v.name"); 
        var product = offer.split("|");
        var offerId = product[0];
        var offerName = product[1];
        var Mode=true;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({componentDef: "c:DelegatedPricingSelectProduct",
                       componentAttributes: {DPRId: component.get("v.DPRId"),
                                             DPROffer: offerId,
                                             Mode:Mode,
                                             SelectedProduct:offerName
                                            }});
        evt.fire(); 
    },    
    
    //added by badri
    handleReturn : function(component,event,helper){
        var result = event.getParam("showHomePage");
    },
    
    // EDGE:114333: Marking the deal (DPR) variation to the existing deal. 
    onClickCheckBox : function(component,event,helper) {
        component.set("v.ContractVariationConfirmation",component.get("v.DprName.Mark_as_Variation__c"));
        if(component.get("v.ContractVariationConfirmation")){
            component.set("v.CheckBoxValue",true);
        }
        else{
            component.set("v.CheckBoxValue",false);
        }
    },
    
    // EDGE:114333: Marking the deal (DPR) variation to the existing deal.
    ContractConfirmationSelected: function(component,event,helper) {
        component.set("v.ContractVariationConfirmation", false);
        component.set("v.CheckBoxValue",true);
    },
    
    // EDGE:114333: Marking the deal (DPR) variation to the existing deal. 
    closeContractConfirmation: function(component,event,helper){    
        component.set("v.ContractVariationConfirmation", false);
        component.set("v.DprName.Mark_as_Variation__c",false);
        component.set("v.CheckBoxValue",false);  
    },
    
    // EDGE:117700: Cancel function on DPR screen.
    buttonActionCancel: function(component, event, helper){
        component.set("v.cancel", true);
    },
    
    
    // EDGE:117700: Cancel function on DPR screen.
    closeCancel: function(component, event, helper){
        component.set("v.cancel", false);
    },
    
    // EDGE:117700: Cancel function on DPR screen.
    submitDetails: function(component, event, helper) {
        component.set("v.DprName.Deal_Status__c","Cancelled");
        if(component.get("v.DPRId") != null || component.get("v.DPRId") != '') {	
            debugger;
            helper.cancelDPR(component,event,helper);
        }
    },
    
    //EDGE:116099 : Delete function.
    buttonActiondelete: function(component, event, helper) {
        component.set("v.delete", true);
    },
    
    //EDGE:116099 : Delete function.
    closedelete: function(component, event, helper)  {
        component.set("v.delete", false); 
    },
    
    save : function(component, event, helper)  {
        try {
            component.find("edit").get("e.recordSave").fire();
        }
        catch (e) {
            console.log(e);
        }
        location.reload();// This will refresh the app to get the latest updated data.        
    },
    
    //EDGE:116099 : Delete function.
    delete : function(component, event, helper) {        
    if(confirm('Are you sure you want to Delete?')){
    helper.deleteDPR(component, event); 
}
 },
 
 //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals
 //EDGE:118631 | Escalate the deal to the next approving authority.
 pickEscalateApprover: function(component, event, helper){
    if(component.get("v.openEscalateModal") === true) {
        helper.getLoggedInUserInfoValue(component);
    }
    else 
        if (component.get("v.openCaseModal") === true) {
            helper.getOpportunityDetails_CaseCreation(component);
        }
},
    
    
    //EDGE:118631 | Escalate the deal to the next approving authority.
    EnableEsclateAssign : function(component, event, helper){
        if(component.get("v.DprName.Deal_Approver__c") != null || component.get("v.DprName.Deal_Approver__c") != ''){
            component.set("v.disableAssign", false);
        }
        
        if(component.get("v.DprName.Deal_Approver__c") === '' || component.get("v.DprName.Deal_Approver__c") === null ){
            component.set("v.disableAssign", true);
        }
    },
        
        
        
        
        //EDGE:118631 | Escalate the deal to the next approving authority.
        DealApprovalRequest: function(component, event, helper) {
            component.set("v.esclate", false);
            component.set("v.enableEscalate",false);
        },
            
            //EDGE:118631 | Escalate the deal to the next approving authority.     
            esclateAssign: function(component, event, helper) {
                var descriptionLength = component.get("v.DprName.Description__c");
                if((descriptionLength.length) > 50){
                    component.set("v.disableAssign",true);
                    component.set("v.DprName.is_Deal_Escalated__c",true); // correct
                    helper.insertDPR(component,event,helper);
                }
            },
                
                //EDGE-117736: I want Opportunity field on DPR screen tab hyperlink and Read only.
                //EDGE-114462: Pricing Method and Product Type Validation.
                backToOpportunity : function(component, event, helper) {
                    //Find the text value of the component with aura:id set to "address"
                    var Opportunity = component.get("v.OpportunityId");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams
                    ({
                        "url": 'https://'+window.location.host+'/lightning/r/Opportunity/'+Opportunity+'/view'
                    });
                    urlEvent.fire();
                },
                    
                    //Validation: Customer Contact associated with this opportunity.    
                    OpportunitycontactRoleNoValue: function(component, event, helper){
                        component.set("v.OpportunityContactRolesStatusModal",false);
                        window.history.back();
                    },
                        
                        closeCaseModalVal: function(component, event, helper) {
                            component.set("v.caseCheck",false);
                        },
                            
                            //Case Creation 
                            //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals.       
                            handleSubmit : function(component, event, helper) {
                                event.preventDefault();
                                const fields = event.getParam('fields');
                                if(fields.Description){            
                                    if (event.getParam('fields') !== null ||  event.getParam('fields') !== ''){	
                                        
                                        if(fields.Description.length > 50){
                                            component.set("v.SpinnerCheck",true);
                                            var record = event.getParam('record');
                                            fields.OpportunityId__c = component.get("v.CaseOpportunityId");
                                            fields.Product_ent_pricing__c = $A.get("$Label.c.DPR_Product");
                                            fields.Subject='Delegated Pricing Approval';
                                            component.find('myRecordForm').submit(fields);
                                        }
                                        else {
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title : 'Please populate deal context and customer profile information in the Description field to ensure Pricing have enough information.',
                                                message: ' ',
                                                messageTemplate: ' ',
                                                duration:' 1000',
                                                key: 'info_alt',
                                                type: 'error',
                                            });
                                            toastEvent.fire();
                                        } 
                                    }
                                    else {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Please populate deal context and customer profile information in the Description field to ensure Pricing have enough information.',
                                            message: ' ',
                                            messageTemplate: ' ',
                                            duration:'1000',
                                            key: 'info_alt',
                                            type: 'error',
                                        });
                                        toastEvent.fire();
                                    }
                                }
                            },
                                
                                //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals.    
                                handleSuccess : function(component, event, helper) { 
                                    component.set("v.DprName.is_Deal_Escalated__c",true); //Correct
                                    helper.insertDeal(component);
                                },
                                    
                                    //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals.     
                                    handleError: function (component, event, helper) {
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
                                    },
                                        
                                        //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals.    
                                        onCancel :function (component, event, helper) {
                                            component.set("v.SpinnerCheck",false);
                                            component.set("v.caseCheck",false);
                                        },
                                            
                                            // EDGE : 123727 | Get Accept Contract.       
                                            getAcceptContract :function (component, event, helper) {
                                                component.set("v.SpinnerCheck",true);
                                                helper.getAcceptContractHelper(component, event);
                                            },
                                            // EDGE : 136226 | Get Reject Contract.       
                                            getRejectContract :function (component, event, helper) {
                                                component.set("v.SpinnerCheck",true);
                                                helper.getRejectContractHelper(component, event);
                                            },
                                                
                                                // EDGE        : 117699
                                                // Description : As Sales Enterprise B2B user, I want to perform Clone function on DPR screen.     
                                                openCloneDelegatedPricing :function (component, event, helper) {
                                                    //helper.getAcceptContractHelper(component, event);
                                                    component.set("v.CloneDelegatedPricingRequest",true);
                                                },
                                                    // EDGE        : 117699
                                                    // Description : As Sales Enterprise B2B user, I want to perform Clone function on DPR screen. 
                                                    cloneDelegatedPricing :function (component, event, helper) {
                                                        component.set("v.SpinnerCheck",false);
                                                        component.set("v.CloneDelegatedPricingRequest",false);
                                                        component.set("v.CloneDelegatedPricingRequestInProgress", true);
                                                        component.set("v.CloneDelegatedPricingRequestStart", true);
                                                        helper.cloneDPRHelper(component, event);
                                                    },
                                                        // EDGE        : 117699
                                                        // Description : As Sales Enterprise B2B user, I want to perform Clone function on DPR screen. 
                                                        CancelDelegatedPricingClone:function (component, event, helper) {
                                                            component.set("v.CloneDelegatedPricingRequest", false);
                                                            component.set("v.disableCloneButton",false);
                                                            component.set("v.SpinnerCheck",false);
                                                        },
                                                            
                                                            closePopup: function(component, event, helper) {
                                                                var Opportunity = component.get("v.OpportunityId");
                                                                var urlEvent = $A.get("e.force:navigateToURL");
                                                                urlEvent.setParams
                                                                ({
                                                                    "url": 'https://'+window.location.host+'/lightning/r/Opportunity/'+Opportunity+'/view'
                                                                });
                                                                urlEvent.fire();
                                                            },
                                                            closeICPopup: function(component, event, helper) {
                                                                component.set("v.dontAllowInitiateContract",false);
                                                            },

                                                                    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
                                                                    pickInitiateContract: function(component, event, helper){
                                                                            component.set("v.SpinnerCheck",true);
                                                                            helper.checkInitiateContract(component);
                                                                                                                                                                                     
                                                                    },
                                                                          //Create contract Support Case
                                                                         //EDGE:123784 | Generate the pricing contract after the deal has been approved.
                                                                        initiateContractHandleSubmit : function(component, event, helper) {
                                                                                var count = component.get("v.Counter");
                                                                                count = count + 1;
                                                                                component.set("v.Counter",count);
                                                                                if(count==1){
                                                                            event.preventDefault();
                                                                            const ICfields=event.getParam('fields');
                                                                            
                                                                            var record=event.getParam('record');
                                                                            ICfields.Status='New';
                                                                            ICfields.OpportunityId__c =component.get("v.OpportunityId");
                                                                            ICfields.Subject='Pricing Contract';
                                                                            ICfields.soc_Request_Type__c='Contract Support';
                                                                            ICfields.Deal__c = component.get("v.DPRId");//EDGE:136226
                                                                                ICfields.ContractJunction__c = component.get("v.ContractJunctionID");//EDGE:136226
                                                                            var MarkasVariation =component.get("v.DprName.Mark_as_Variation__c");
                                                                            if(MarkasVariation == true){
                                                                               ICfields.Reason='Contract Variation';
                                                                            }
                                                                            else{
                                                                                ICfields.Reason='New Contract';
                                                                            }
                                                                            
                                                                            component.find('casemyRecordForm').submit(ICfields);
                                                                                }
                                                                            
                                                                        },
                                                                            
                                                                             //EDGE:123784 | Generate the pricing contract after the deal has been approved..    
                                                                            initiateContractHandleSuccess : function(component, event, helper) {
                                           
                                                                                    const ICfields=event.getParam('fields');
                                                                                    //helper.insertContractJunction(component);
                                                                                    component.set("v.caseCheck",false);
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
                                                                                    component.set("v.InitiateContractCase",false);
                                                                                    component.set("v.SpinnerCheck",false);
                                                                                    location.reload();
                                                                            },
                                                                                
                                                                                 //EDGE:123784 | Generate the pricing contract after the deal has been approved.    
                                                                                initiateContractonCancel : function(component, event, helper) { 
                                                                                    component.set("v.InitiateContractCase",false);
                                                                                },
                                                                                    
                                                                                    //EDGE:123784 | Generate the pricing contract after the deal has been approved.                                initiateContractHandleSuccess : function(component, event, helper) { 
                                                                                    initiateContracthandleError : function(component, event, helper) { 
                                                                                         
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

})