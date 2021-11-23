/* 
 * Modifications : 
 * 1. 03-09-2020 : Team Hawaii : P2OB-7962 - Helper methods for handling partner-roles from Manage-User Component 
*/

({
    
    // really simple function that can be used in every component's helper file to make using promises easier.
    executeAction: function(cmp, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var retVal = response.getReturnValue();
                    resolve(retVal);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    } else {
                        reject(Error("Unknown error"));
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    callSalesforce: function(resolve, reject, salesforceCall) {
        salesforceCall.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === 'SUCCESS') {
                var response = JSON.parse(response.getReturnValue());
                console.log(resolve);
                if (resolve) {
                    console.log('Inside resolve.getReturnValue()');
                    console.log(response);
                    resolve(response);
                }
            } else {
                if (reject) {
                    console.log('rejecting appendViaApexPromise');
                    reject(Error(response.getError()[0].message));
                }
            }
        });
        $A.enqueueAction(salesforceCall);
        
    },
    helperFunctionAsPromise: function(helperFunction, salesforceCall) {
        return new Promise($A.getCallback(function(resolve, reject) {
            helperFunction(resolve, reject, salesforceCall);
        }));
    },
    showToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
    },
    showSpinnerWindow: function(component, event) {
        component.set("v.Spinner", true);
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function(component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    callPimsInterfaceJS: function(component, event, helper, pageParams) {
        console.log('Inside callPimsInterfaceJS!');
        component
        .find("proxy")
        .invoke('callPIMS',
                pageParams,
                // $A.getCallback(function(result) {
                function(result,error) {
                    console.log('Page params sent: ',pageParams);
                    console.log('serverResults : result : ',result );
                    console.log('Error message: ',error);
                    var serverResults;
                    if (result && pageParams.pimsCallType!= 'removePDUA' && pageParams.pimsCallType != 'elevateToPDUA' ) {                        
                        //serverResults = JSON.parse(result);
                        serverResults = result;                        
                        component.set("v.isSuccess", serverResults.isSuccess);
                        if (serverResults.isSuccess) {
                            component.set("v.severity", 'success');
                        } else {
                            component.set("v.severity", 'error');
                        }
                        //console.log('serverResults:messge:',message);
                        component.set("v.message", serverResults.message);
                        if(serverResults.wrapperValidOperations){
                            component.set("v.wrapperValidPIMSOperations", JSON.parse(serverResults.wrapperValidOperations));
                        }
                        if(serverResults.pimsuserdetails){
                            component.set("v.wrapperuserdetails", serverResults.pimsuserdetails);
                        }                        
                        if(serverResults.pimsuserdetails )
                        {                              
                            component.set("v.showusertable",true ); 
                            component.set("v.showMessage", false);
                        }
                        else{
                            component.set("v.showMessage", true); 
                            component.set("v.showusertable",false ); 
                            component.set("v.showRoles",false);
                        }
                        component.set("v.spinner", false);
                    } else if (!error.result.isSuccess) {
                        component.set("v.severity", 'error');
                        component.set("v.message", result.message);
                        component.set("v.spinner", false);
                        component.set("v.showMessage", true);
                    }else{ 
                    console.log('Server respnded here!!',result,error);
                    //TODO: processing based on the wrapper response from server
                    console.log(serverResults);
                    }
                    $A.get("e.force:refreshView").fire();
                });
        /*).catch($A.getCallback(function(error) {
                console.log('error.message');
                console.log(error.message);
        }));*/
    },
    
    loggerCheck: function(isLoggerEnabled) {
        console.log(isLoggerEnabled+'isLoggerEnabled');
        if (isLoggerEnabled=="true") {
            console.log('Logs Enabled!');
            window['console']['log'] = console.log;
        } else {
            console.log('Disabling Logs!');
            window['console']['log'] = function() {};
            console.log('Disabled Logs!');
        }
        return;
    },
    
    /* P2OB-7962 : Helper method to read the existing-roles and PPC status to display on UI */
    manageRoleHelper:function(component, event, helper){
        component.set("v.showMessage", false);
        //P2OB-7962 : Reading Partner Roles MDT records using auraEnabled apex-method 
        var partner_roles_mdt = component.get("v.partnerRoles");
        var actionGetCustomMdt = component.get("c.getPartnerRolesfromMDT");
        var isPPC = component.get("v.isPPC");
        var msgs = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));
        actionGetCustomMdt.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var mdt_records = response.getReturnValue();
                //P2OB-7962 : Reading existingRoles attribute
                var existingPartnerRoles = component.get("v.existingPartnerRoles");
                console.log('***Telstra:manageRoleHelper:existingPartnerRoles:',existingPartnerRoles);
                //P2OB-7962 : Pre-select a role if it is existing
                if(existingPartnerRoles != null){
                    for(var i=0; i<mdt_records.length ; i++){
                        if(existingPartnerRoles.includes(mdt_records[i].Partner_Role__c))
                            mdt_records[i].Mark_Selected__c = true;
                        if(mdt_records[i].ReadOnly__c && !isPPC)
                            mdt_records[i].Mark_Selected__c = false;
                        if(mdt_records[i].Partner_Role__c==='Principal Partner Contact' && isPPC){
                            mdt_records[i].Mark_Selected__c = true;
                            mdt_records[i].ReadOnly__c = true;
                            mdt_records[i].Informative_Message__c = msgs.PPCHelpText;
                        }
                    }
                }
                //P2OB-7962 : Update components attribute to render pre-selected roles on UI
                component.set("v.partnerRoles",mdt_records);
                component.set("v.showRoles",true);
            }
        });
        $A.enqueueAction(actionGetCustomMdt);
    },
    
    /* P2OB-7962 : Helper method for role selection, 
    			   display validation-messages,
                   handles auto-deselection of roles when 'No Access to TPC'/'Access Frozen' are selected
    */
    selectionUpdateHelper : function(component,event,helper){
        var msgs = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));
        var partnerRoles = component.get("v.partnerRoles");
        var saveButton = component.find("SaveRole");         
		var saveButton_disable = false;
        var validation_message;
        //P2OB-7962 : Identify if 'No Access To TPC' role is selected
        let noAccess_Option = partnerRoles.filter(function (e) {
            return ( e.Show_Deactivation_Fields__c === true && e.Mark_Selected__c === true);
        });
        //P2OB-7962 : Identify if 'Access Frozen' role is selected
        let freezeAccess_Option = partnerRoles.filter(function (e) {
            return ( e.Show_Deactivation_Fields__c === false && e.Mark_Selected__c === true && e.Deactivate_User__c);
        });
        //P2OB-7962 : Identify if contact is PPC on Account
        let ppc_Option = partnerRoles.filter(function (e) {
            return ( e.ReadOnly__c === true && e.Mark_Selected__c === true);
        });
		 
        //P2OB-7962 : If Access-Frozen is selected by user, auto-clear selection of other selectable-roles
        if(freezeAccess_Option.length > 0){
            var existingRoles = component.get("v.contactRecord.Partner_Role__c");
            var status = component.get("v.contactRecord.Onboarding_Status__c");
            if(existingRoles!=undefined && existingRoles.includes('No Access to TPC') && status!=undefined && status=='Inactive'){
                saveButton_disable = true;
                validation_message = msgs.FreezeUserMsg;                
            }
             partnerRoles.forEach(function(e) {
                if( e.Mark_Selected__c === true  && !(freezeAccess_Option.includes(e)) && e.ReadOnly__c === false)
                    e.Mark_Selected__c = false;
            });
             component.set("v.partnerRoles",partnerRoles);
        } 
        
        /*P2OB-7962 : Blocks the user when role selected is 'No Access To TPC'/'Access Frozen' and contact is PPC */
        if((freezeAccess_Option.length > 0 || noAccess_Option.length > 0) && ppc_Option.length > 0){
            saveButton_disable = true;  
            //P2OB-7962 : Displays a message to user to indicate that contact cannot be updated with given selection
            validation_message = msgs.UpdateNotAllowed;
        } 
        
        //P2OB-7962 : If No-Access-To-TPC is selected by user, auto-clear selection of other selectable-roles        
        if(noAccess_Option.length > 0){
            partnerRoles.forEach(function(e) {
                if( e.Mark_Selected__c === true  && !(noAccess_Option.includes(e)) && e.ReadOnly__c ===false)
                    e.Mark_Selected__c = false;
        		});
            //P2OB-7962 : Setting component attributes and display deactivation-fields when 'No Access To TPC' is selected
            component.set("v.partnerRoles",partnerRoles);
            //P2OB-7962 : Disable Save button to block until user enters required fields
            saveButton_disable = true;
            //P2OB-7962 : Call to apex-method for reading picklist values of 'Deactivation Reason' field of Contact
            var action = component.get("c.getDeactivateReasonPicklist");
            var opts=[];
            action.setCallback(this, function(a) {
                opts.push({
                    class: "optionClass",
                    label: "--- None ---",
                    value: ""
                });
                for(var i=0;i< a.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                component.set("v.DeactivateReasonOptions", opts);
            });
            $A.enqueueAction(action); 
        }
       
        //P2OB-7962 : Identify if selection has any secondary-role
        let secondary_roles = partnerRoles.filter(function (e) {
            return (e.Requires_basic_role__c === true && e.Mark_Selected__c === true);
        });
        //P2OB-7962 : Checks if a basic-role is also selected along with secondary roles
        if(secondary_roles.length > 0){
            let basic_roles = partnerRoles.filter(function (e) {
                return (e.Basic_Role__c === true && e.Mark_Selected__c === true);
            });
            //P2OB-7962 : Displays validation error on UI to indicate that a basic role must be selected and disables save-button
            if(basic_roles.length <= 0){            
                saveButton_disable = true;
                validation_message = msgs.RequiredRoleMissing;
            }
        }else{
            //P2OB-7962 : Blocks the user if no roles are selected ,disables save-button.
            let roles_selected = partnerRoles.filter(function (e) {
                return (e.Mark_Selected__c === true);
            });
            if(roles_selected.length == 0 && noAccess_Option.length == 0 && freezeAccess_Option.length == 0){
                saveButton_disable = true;
            }
        }
        //P2OB-7962 : Display of validation message and setting of save button
        if(validation_message!='' && validation_message!=undefined && validation_message!=null){
            component.set("v.roleValidationMessage",validation_message);
            $A.util.removeClass(component.find("ValidationMessage"), "slds-hidden");
            $A.util.addClass(component.find("ValidationMessage"), "slds-visible");
        }            
        saveButton.set("v.disabled",saveButton_disable);  
        //P2OB-7962 : Set Visibility of DeactivationFields, if the corresponding role is selected
        let require_DeactivationFields = partnerRoles.filter(function (e) {
            return ( e.Show_Deactivation_Fields__c === true && e.Mark_Selected__c === true);
        });
        if(require_DeactivationFields.length > 0)
            component.set("v.showDeactivationFields",true);
        else
            component.set("v.showDeactivationFields",false);
    },
    
    /* P2OB-7962 : Helper method for calling flow to update contact and user record*/
    flowHelper :function(component,event,helper){
        var label_settings = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));
        helper.updatePDUAHelper(component,event,helper);
        
        var partnerRoles = component.get("v.partnerRoles");
        var contactRecordOldRoles = component.get("v.contactRecord.Partner_Role__c");
        var reason = component.get("v.DeactivatedReasonSelected");
        var comments = component.get("v.DeactivatedCommentsProvided");       
        //P2OB-7962 : Filtering the MDT records which are selected from UI 
        let selected_roles = partnerRoles.filter(function (e) {
            return (e.Mark_Selected__c === true);
        });
        //P2OB-7962 : Arranging the roles in evaluation_order helps provide access to user from least-privileges to most-privileges
        selected_roles.sort((a, b) => (a.Evaluation_Order__c > b.Evaluation_Order__c) ? 1 : -1);
        console.log('***Telstra:ManagePIMSController:selected_roles',selected_roles);        
        
        var cid = component.get("v.recordId");
        //P2OB-7962 : List of input variables passed to flow
        var inputVariables = [
            { name : "ContactID", type : "String", value: cid},
            { name : "UpdateObject", type : "String", value: "Contact"},
            { name : "Input_OldRoles", type : "String", value: contactRecordOldRoles},
            { name : "Input_SelectedRoles", type : "SObject", value: selected_roles},
            { name : "Input_DeactivateReason", type : "String", value: reason},
            { name : "Input_DeactivateComments", type : "String", value: comments},
			            
        ];
        console.log('***Telstra:flowHelper:ContactUpdate:flowinputVariables:',inputVariables);
        
        //P2OB-7962 : Call to flow to update Contact-record     
        var flow = component.find("manageUserFlow");
        var flowName = label_settings.manageUserFlow;
        flow.startFlow(flowName,inputVariables);            
    },
            
     /* P2OB-7962 : Helper method for handling updates for PDUA/Partner-Admin Role*/    
     updatePDUAHelper:function(component,event,helper){
         var partner_admin_role = 'Partner Admin';
         var globalId;
            var existingRoles = component.get("v.existingPartnerRoles");
            var partnerRoles = component.get("v.partnerRoles");
            let admin_role = partnerRoles.filter(function (e) {
            	return (e.Mark_Selected__c === true && e.Partner_Role__c===partner_admin_role);
            });
            if(!existingRoles.includes(partner_admin_role) && admin_role.length > 0){
            	globalId = 'elevateToPDUA';
            	var pageParam= new Object();
            	pageParam.pageObjectID=component.get("v.recordId");
            	pageParam.pimsAPIType='MANAGEUSER';
            	pageParam.pimsCallType=globalId; 
            	//P2OB-7962 : Call to elevatetoPDUA pims/salesforce existing method            
            	var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
            }else if(existingRoles.includes(partner_admin_role) && admin_role.length == 0){
            	globalId = 'removePDUA';
            	var pageParam= new Object();
            	pageParam.pageObjectID=component.get("v.recordId");
           	    pageParam.pimsAPIType='MANAGEUSER';
            	pageParam.pimsCallType=globalId; 
            	//P2OB-7962 : Call to removePDUA pims/salesforce existing method
            	var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
            }
            
       }, 
     //P2OB-7962 :Helper method to get updated field-values from contact-record to component.            
     reloadDataHelper:function(component, event, helper) { 
   		var changeType = event.getParams().changeType; 
    	if (changeType === "CHANGED") { 
            console.log('***ManagePIMSController:contactRoleUpdated:Contact Updated');
            component.find("forceRecordContact").reloadRecord();
        }
    },
     showError:function(component, event, helper) {
        var label_settings = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));
        component.set("v.severity", 'error');
        component.set("v.message",label_settings.ErrorMessage);
        component.set("v.isSuccess", false);
        component.set("v.spinner", false);
        component.set("v.showRoles",false);
        component.set("v.showMessage", true); 
    },       
})