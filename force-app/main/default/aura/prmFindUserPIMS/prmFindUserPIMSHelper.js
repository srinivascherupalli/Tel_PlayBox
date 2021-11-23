({
	//Method to handle call to PIMSService for findUser and logic for CreateUser in Phoenix
    manageUserJS:function(component, event, helper){
        var eventId ;
        var recordDetails;
        component.set("v.spinner",true);
        var globalId = event.getSource().getLocalId();
        var params = event.getParam('arguments');
        if(params!=null && params!=undefined){
            console.log('***params:',params.contactRecord);
            eventId = params.eventId;
            recordDetails = params.contactRecord;
            console.log('***manageUserJS:Params:',params.contactRecord,params.eventId);
            var contactObj = JSON.parse(params.contactRecord);
        	console.log('contactObj:',contactObj);
        	component.set('v.contactRecord',contactObj);
        }        
        
        var pageParam= new Object();
        pageParam.pageObjectID=component.get("v.recordId");
        pageParam.pimsAPIType='MANAGEUSER';
        if(globalId != undefined && globalId != null)
        	pageParam.pimsCallType=globalId;
        else
        	pageParam.pimsCallType=eventId;
        console.log('***manageUserJS:pageParam.pimsCallType:',pageParam.pimsCallType);
        console.log('***manageUserJS:globalId and eventId:'+globalId+' ,'+eventId);
        if (pageParam.pimsCallType == 'updateUser' || pageParam.pimsCallType == 'finduser') {
            var action = component.get("c.validateContactDetails");
            action.setParams({
                "pageObjectID": component.get("v.recordId"),
                "callType": pageParam.pimsCallType,
            });
          
            var p = helper.executeAction(component, action); 
            p.then($A.getCallback(function(result) {               
                result=JSON.parse(result); 
                console.log('***manageUserJS:result:',result);
                console.log('***manageUserJS:result.ShowMessage:'+result.ShowMessage);               
                if(result.ShowMessage==true){
                    component.set("v.severity", 'error');
                    component.set("v.message",result.ErrorMessage);
                    component.set("v.isSuccess", false);
                    component.set("v.spinner", false);
                    component.set("v.showMessage", true);
                }
                else
                {
                    console.log('***manageUserJS:callPimsInterfaceJS');
                    var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
                }
                
            })).catch($A.getCallback(function(error) {
                console.log('***manageUserJS:An error occurred : ' + error.message);
            }));
        }else{
            var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
        }        
    },
    //Helper method for callout via continuation-proxy
    callPimsInterfaceJS: function(component, event, helper, pageParams) {
        console.log('Inside callPimsInterfaceJS');
        component.set("v.spinner", true);
        component
        .find("proxy")
        .invoke('callPIMS',
                pageParams,
                function(result,error) {
                    console.log('***callPimsInterfaceJS:Page params sent: ',pageParams);
                    console.log('***callPimsInterfaceJS:serverResults : result : ',result );
                    console.log('***callPimsInterfaceJS:Error message: ',error);
                    var serverResults;
                    if (result && pageParams.pimsCallType!= 'removePDUA' && pageParams.pimsCallType != 'elevateToPDUA' ) {                        
                        serverResults = result;                        
                        component.set("v.isSuccess", serverResults.isSuccess);
                        if (serverResults.isSuccess) {
                            component.set("v.severity", 'success');
                        } else {
                            component.set("v.severity", 'error');
                        }
                        component.set("v.message", serverResults.message);
                        component.set("v.instruction", "");
                        if(serverResults.wrapperValidOperations){
                            component.set("v.wrapperValidPIMSOperations", JSON.parse(serverResults.wrapperValidOperations));
                        }
                        if(serverResults.pimsuserdetails){
                            console.log('***callPimsInterfaceJS:User Found:',serverResults.pimsuserdetails);
                            component.set("v.wrapperuserdetails", serverResults.pimsuserdetails);
                            component.set("v.showusertable",true ); 
                            component.set("v.showMessage", false);
                        }
                        else{
                            //component.set("v.showMessage", true); 
                            var a = component.get('c.manageRole');
        					$A.enqueueAction(a);
                            component.set("v.showusertable",false ); 
                            //component.set("v.showRoles",true);
                        }
                        component.set("v.spinner", false);
                    } else if (!error.result.isSuccess) {
                        console.log('***callPimsInterfaceJS:Error Occurred',result);
                        component.set("v.severity", 'error');
                        component.set("v.message", result.message);
                        component.set("v.spinner", false);
                        component.set("v.showMessage", true);
                        component.set("v.instruction", "");
                    }else{ 
                        console.log('***callPimsInterfaceJS:ServerResponse:',result,error);
                        console.log('***callPimsInterfaceJS:serverResults:',serverResults);
                    }
                    $A.get("e.force:refreshView").fire();
                });
    },
    //Execute apex-server-side logic using Promise
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
    //Method for displaying success and error-messages
    Showmessage: function(component, event, helper) {
        var source = component.get("v.source");
        var msgs = JSON.parse($A.get("$Label.c.prmFindUser_Messages"));
        console.log('***prmFindUserPIMS:Showmessage:source:',source);
        if(source == 'prmNewUser'){
            var recordlink;
            var userType = component.get('v.userRecord.UserType');
        	var contactObj = component.get('v.contactRecord');
            console.log('***Showmessage:',userType,contactObj.fields.FirstName.value,contactObj.fields.LastName.value);
        	if(userType == 'PowerPartner')
            	recordlink = ($A.get("$Label.c.PRM_ENV_URL"))+'/'+ component.get("v.recordId");
            else
                recordlink = ($A.get("$Label.c.PRM_Record_Base_URL"))+'/'+ component.get("v.recordId");
        	console.log('***Showmessage:recordlink:',recordlink);
            var msg_text = msgs.NU_UserCancellation_Msg;
			msg_text=msg_text.replace("$$URL_LINK$$", recordlink);
            msg_text=msg_text.replace("$$USERNAME$$", contactObj.fields.FirstName.value + ' '+contactObj.fields.LastName.value);
            component.set("v.message", msg_text);
        	component.set("v.instruction", msgs.NU_UserCancellation_INS);
        }
        else{
        	component.set("v.message", msgs.MU_UserCancellation_Msg);
        	component.set("v.instruction", msgs.MU_UserCancellation_INS);
        }
        
        component.set("v.showMessage", true);
        component.set("v.spinner", false);
        component.set("v.severity", 'warning');
        component.set("v.showusertable",false ); 
    },
    //Enabling/disabling logs based on label-value
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
                        if(existingPartnerRoles.includes(mdt_records[i].Partner_Role__c) || mdt_records[i].Default_Role__c === true)
                            mdt_records[i].Mark_Selected__c = true;
                        if(mdt_records[i].ReadOnly__c && !isPPC)
                            mdt_records[i].Mark_Selected__c = false;
                         if(mdt_records[i].Partner_Role__c==='Principal Partner Contact' && isPPC){
                            mdt_records[i].Mark_Selected__c = true;
                            mdt_records[i].ReadOnly__c = true;
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
        console.log('partnerRoles',partnerRoles);
        var contactRecordOldRoles = component.get("v.contactRecord.Partner_Role__c");
        console.log('contactRecordOldRoles',contactRecordOldRoles);
        var reason = component.get("v.DeactivatedReasonSelected");
        console.log('reason',reason);
        var comments = component.get("v.DeactivatedCommentsProvided");       
        console.log('comments',comments);
        //P2OB-7962 : Filtering the MDT records which are selected from UI 
        let selected_roles = partnerRoles.filter(function (e) {
            return (e.Mark_Selected__c === true);
        });
        
        //P2OB-7962 : Arranging the roles in evaluation_order helps provide access to user from least-privileges to most-privileges
        selected_roles.sort((a, b) => (a.Evaluation_Order__c > b.Evaluation_Order__c) ? 1 : -1);
        console.log('***Telstra:ManagePIMSController:selected_roles',selected_roles);        
        
        var cid = component.get("v.recordId");
        console.log('cid',cid);
        //P2OB-7962 : List of input variables passed to flow
        var inputVariables = [
            { name : "ContactID", type : "String", value: cid},
            { name : "UpdateObject", type : "String", value: "Contact"},
            { name : "Input_OldRoles", type : "String", value: "Partner Sales User"},
            { name : "Input_SelectedRoles", type : "SObject", value: selected_roles},
            { name : "Input_DeactivateReason", type : "String", value: reason},
            { name : "Input_DeactivateComments", type : "String", value: comments},            
        ];
        console.log('***Telstra:flowHelper:ContactUpdate:flowinputVariables:',inputVariables);
        
        //P2OB-7962 : Call to flow to update Contact-record     
        var flow = component.find("manageUserFlowchild");
            
        var flowName = label_settings.manageUserFlow;
            console.log('---flowname',flowName);
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