({
    //Enable/Disable Console Logs
    doInit:function(component, event, helper) {
    	helper.loggerCheck($A.get("$Label.c.ENABLE_CONSOLE_LOGS"));
    },
    //Method for displaying error and success messages
    childShowmessage: function(component, event, helper) {
    	 helper.Showmessage(component, event, helper);
    },
    //Method for findUser and createUser 
    childmanageUserJS: function(component, event, helper) {
    	 helper.manageUserJS(component, event, helper);
        
    },
    /*P2OB-7962 : Handler method for managing partner-role*/
    manageRole:function(component, event, helper){
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
    finishFlowChild : function(component, event, helper) {
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
            	var flow = component.find("updateUserFlowchild");
                
        		var flowName = label_settings.manageUserFlow;
                console.log('---flowname',flowName);
            	//P2OB-7962 : Call to begin flow
        		flow.startFlow(flowName,inputVariables);
            }
        }else if(event.getParam('status').includes("ERROR")){
            //P2OB-7962 : Handling error when flow fails while contact-update  
            helper.showError(component, event, helper);
        }
                        
    },
    
    finishUserFlowChild : function(component, event, helper) {
        //P2OB-7962 : Refresh the record after flow has updated contact-fields
        $A.get("e.force:refreshView").fire();
        //P2OB-7962 : Read flowname and message details from json in label
        var label_settings = JSON.parse($A.get("$Label.c.PRM_PIMS_RoleUpdate"));            
        console.log('***ManagePIMSController:finishUserFlow:FlowResult:',event.getParam('status'));
        //P2OB-7962 : Flow has finished user-update without errors 
        if(event.getParam('status').includes("FINISHED")) {
            //P2OB-7962 : Display success message 
            component.set("v.severity", 'success');
            component.set("v.message",'User created successfully and assigned selected roles.');
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
    /*P2OB-7962 : Handler method to call flow on click of Save*/
    callFlow : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.flowHelper(component, event, helper);
    },
    //P2OB-7962 : Method called from force-recordData on 'recordUpdated'
    reloadData:function(component, event, helper) {
        //P2OB-7962 : Helper method which updates components attributes for showing updated roles
        helper.reloadDataHelper(component, event, helper);
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
})