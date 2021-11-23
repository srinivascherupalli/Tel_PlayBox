/* 
 * Modifications : 
 * 1. 03-09-2020 : Team Hawaii : P2OB-7962 - Methods for handling partner-roles from Manage-User Component 
 * 2. 8-10-2020 : Team Hawaii : P2OB-9678 - Removed logic for 'Deactivate User'
*/

({
    createUserPIMSJs: function(component, event, helper) {
        console.log('********');
        helper.showSpinnerWindow(component, event);
        component.set("v.isSuccess", false);
        helper.showToast('SUCCESS', 'Success', 'Successfully Created User at PIMS!!');
    },
    showSpinnerWindow: function(component, event) {
        component.set("v.Spinner", true);
    },
    hideSpinner: function(component, event) {
        component.set("v.Spinner", false);
    },
    validateJS: function(component, event, helper) {
        component.set("v.spinner",true);
        window.setTimeout(
            $A.getCallback(function() {
                console.log($A.get("$Label.c.ENABLE_CONSOLE_LOGS"));
                //Disable console logs via customlabel/ GCP changes
                helper.loggerCheck($A.get("$Label.c.ENABLE_CONSOLE_LOGS"));
                var action = component.get("c.IsPIMSAccessible");
                action.setParams({
                    "pageObjectID": component.get("v.recordId"),
                });
                var p = helper.executeAction(component, action); 
                p.then($A.getCallback(function(result) {
                    result=JSON.parse(result); 
                    console.log(result);
                    console.log('result.ShowMessage'+result.ShowMessage);
                    
                    if(result.ShowMessage==true){
                        console.log('inside false');
                        component.set("v.severity", 'error');                	
                        console.log('result.ErrorMessage'+result.ErrorMessage);
                        component.set("v.message",result.ErrorMessage);
                        component.set("v.spinner", false);
                        component.set("v.showMessage", true);
                    }
                    else if(result.ShowMessage==false)
                    {						
                        var action1 = component.get("c.validate");				
                        action1.setParams({
                            "pageObjectID": component.get("v.recordId"),
                        });
                        //var p = helper.executeAction("callSalesforce", action);
                        var p1 = helper.executeAction(component, action1); 
                        p1.then($A.getCallback(function(result) {
                            console.log('***ValidateObject*****');
                            result=JSON.parse(result); 
                            console.log(result);
                            component.set("v.wrapperValidPIMSOperations", result);                            
                        })).catch($A.getCallback(function(error) {
                            console.log('An error occurred : ' + error.message);
                        }));
                    }
                    component.set("v.spinner",false);
                })).catch($A.getCallback(function(error) {
                    console.log('An error occurred : ' + error.message);
                }));
            }), 2000
        );
    },
    closeInterface: function(component, event, helper) {
        component.set("v.showIntefaceWarning", false);
        component.set("v.Spinner", false);
        $A.get("e.force:closeQuickAction").fire();
    },
    showInterface: function(component, event, helper) {
        component.set("v.showIntefaceWarning", true);
    },
    Showmessage: function(component, event, helper) {
        component.set("v.message", 'Sorry, we were unable to create the user in Telstra Partner Central.');
        component.set("v.instruction", 'Please update their contact details from the Contacts tab and try again.');
        component.set("v.showMessage", true);
        component.set("v.spinner", false);
        component.set("v.severity", 'error');
        component.set("v.showusertable",false ); 
    },
    
    manageUserJS:function(component, event, helper){
        component.set("v.spinner",true);
        var globalId = event.getSource().getLocalId();
        var pageParam= new Object();
        pageParam.pageObjectID=component.get("v.recordId");
        pageParam.pimsAPIType='MANAGEUSER';
        pageParam.pimsCallType=globalId;
        console.log('calling SF');
        console.log('globalId'+globalId);
        
        //P2OB-9678 : Removed 'deactivateUser' logic 
        //if (globalId == 'updateUser' || globalId == 'finduser' || globalId == 'deactivateUser') {
        if (globalId == 'updateUser' || globalId == 'finduser' ) {
            var action = component.get("c.validateContactDetails");
            action.setParams({
                "pageObjectID": component.get("v.recordId"),
                "callType": globalId,
            });
            
            var p = helper.executeAction(component, action); 
            p.then($A.getCallback(function(result) {               
                result=JSON.parse(result); 
                console.log(result);
                console.log('result.ShowMessage'+result.ShowMessage);
                
                if(result.ShowMessage==true){
                    console.log('result1'+result);
                    component.set("v.severity", 'error');
                    component.set("v.message",result.ErrorMessage);
                    component.set("v.isSuccess", false);
                    component.set("v.spinner", false);
                    component.set("v.showMessage", true);
                }
                else
                {
                    console.log('callPimsInterfaceJS');
                    var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
                }
                
            })).catch($A.getCallback(function(error) {
                console.log('An error occurred : ' + error.message);
            }));
        }else{
            var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
            //parse response;
        }
        
    },
    
    manageOrgJS:function(component, event, helper){
        component.set("v.spinner",true);
        var globalId = event.getSource().getLocalId();
        var pageParam= new Object();
        pageParam.pageObjectID=component.get("v.recordId");
        pageParam.pimsAPIType='MANAGEORG';
        pageParam.pimsCallType=globalId;
        console.log('calling SF');
        console.log('pageParam@@@'+pageParam);
        var response = helper.callPimsInterfaceJS(component, event, helper,pageParam);
        //parse response;
    },
    
    /*P2OB-7962 : Handler method for managing partner-role*/
    manageRole:function(component, event, helper){
        //P2OB-7962 : Reading existing-roles from record using force-recordData
        var roles = component.get("v.contactRecord.Partner_Role__c");
        //P2OB-7962 : Reading PPC-id from account-lookup on contact
        var ppc = component.get("v.contactRecord.Account.PartnerPrincipalContact__c");
        //P2OB-7962 : Setting existingPartnerRoles to display roles on UI layout
        if(roles != undefined && roles != null)
            component.set("v.existingPartnerRoles",roles.split(";"));        
        //P2OB-7962 : Setting isPPC when contact which is set as PPC on account
        var contactID = component.get("v.recordId");
        if(contactID == ppc){
            component.set("v.isPPC",true);        
         }    
        //P2OB-7962 : Call the helper to handle ManageRole
        helper.manageRoleHelper(component, event, helper);
    },
    
    /*P2OB-7962 : Handler method to pre-select roles and validate selection*/
    selectionUpdated:function(component, event, helper){
        //P2OB-7962 : Hiding validation message from screen
        $A.util.removeClass(component.find("ValidationMessage"), "slds-visible");
        $A.util.addClass(component.find("ValidationMessage"), "slds-hidden");
        //P2OB-7962 : Calling helper to validate combination of roles selected and display validation message
        helper.selectionUpdateHelper(component, event, helper);               
    },
    
    /*P2OB-7962 : Handler method to display result of Save*/
    finishFlow : function(component, event, helper) {
        var outputVar;
        var inputVariables = [];
		var user_record;        
        var flowResult; 
        var outputVariables = event.getParam("outputVariables");
        //P2OB-7962 : Retrieving flowname and message details from json in label
        var label_settings = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));
        console.log('***ManagePIMSController:finishFlow:outputVariables:',outputVariables,' flowResult:',event.getParam('status'),JSON.stringify(event.getParams()));
        //P2OB-7962 : Handling finish of flow after contact-update
        if(event.getParam('status').includes("FINISHED")) {
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                //P2OB-7962 : Saving flow output user-record 
                if(outputVar.name === "UserRecord_ToUpdate")
                 	user_record=outputVar.value;
                if(outputVar.name === "FlowResult")
                 	flowResult=outputVar.value;  
            }            
            console.log('***ManagePIMSController:finishFlow:Evaluated user_record:',user_record,' flowResult:',flowResult);
            if(flowResult==null || flowResult==undefined || flowResult ==""){
                //P2OB-10482 :Error handling
                helper.showError(component, event, helper);
            }else{                
            	var cid = component.get("v.recordId");
            	//P2OB-7962 : Input variables for flow to handle user-update
            	var inputVariables = [
           			{ name : "ContactID", type : "String", value: cid},
                	{ name : "UpdateObject", type : "String", value: "User"},
                	{ name : "UserRecord_ToUpdate", type : "SObject", value: user_record}
        		];
            	var flow = component.find("updateUserFlow");
        		var flowName = label_settings.manageUserFlow;
            	//P2OB-7962 : Call to begin flow
        		flow.startFlow(flowName,inputVariables);
            }
        }else if(event.getParam('status').includes("ERROR")){
            //P2OB-7962 : Handling error when flow fails while contact-update  
            helper.showError(component, event, helper);
        }
                        
    },
    
    finishUserFlow : function(component, event, helper) {
        //P2OB-7962 : Refresh the record after flow has updated contact-fields
        $A.get("e.force:refreshView").fire();
        //P2OB-7962 : Read flowname and message details from json in label
        var label_settings = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));            
        console.log('***ManagePIMSController:finishUserFlow:FlowResult:',event.getParam('status'));
        //P2OB-7962 : Flow has finished user-update without errors 
        if(event.getParam('status').includes("FINISHED")) {
            //P2OB-7962 : Display success message 
            component.set("v.severity", 'success');
            component.set("v.message",label_settings.RoleUpdateSuccess);
            component.set("v.isSuccess", true);
        }else if(event.getParam('status').includes("ERROR")){
            //P2OB-7962 : Display error message 
            component.set("v.severity", 'error');
            component.set("v.message",label_settings.ErrorMessage);
            component.set("v.isSuccess", false);        
        }
        //P2OB-7962 : Stop spinner and reset UI
         component.set("v.spinner", false);
         component.set("v.showRoles",false);
         component.set("v.showMessage", true); 
    },
    
    //P2OB-7962 : Method called from force-recordData on 'recordUpdated'
    reloadData:function(component, event, helper) {
        //P2OB-7962 : Helper method which updates components attributes for showing updated roles
        helper.reloadDataHelper(component, event, helper);
    },
    
    /*P2OB-7962 : Handler method to call flow on click of Save*/
    callFlow : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.flowHelper(component, event, helper);
    },
    
    /*P2OB-7962 : Capture Deactivate reason and comments via call from onChange property of lightning-select */
    captureReason: function(component, event, helper) {
        //P2OB-7962 : Updating component attributes with reason and comments 
        var reasonSelected = component.find("deactivateReason").get("v.value");
        component.set("v.DeactivatedReasonSelected",reasonSelected);    
        var commentsProvided = component.find("deactivateComments").get("v.value");     
        component.set("v.DeactivatedCommentsProvided",commentsProvided);
        var isPPC = component.get('v.isPPC');
        //P2OB-7962 : Disable Save-button till user enters required information
        if(reasonSelected!= "" && commentsProvided!="" && !isPPC )
            component.find("SaveRole").set("v.disabled",false);
        else 
            component.find("SaveRole").set("v.disabled",true);
    },
    handleCreateUser:function(component, event, helper) {
      component.set('v.showusertable',true);
      var findUserCMP = component.find('prmFindUserPIMS');  
      var eventId = event.getSource().getLocalId();
      findUserCMP.childmanageUserJS(eventId,null);
    }
})