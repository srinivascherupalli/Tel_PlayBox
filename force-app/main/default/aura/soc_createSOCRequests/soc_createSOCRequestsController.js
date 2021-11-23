({
    doInit :function(component, event, helper){
        console.log('beforeinsideDOinit',component.get("v.validForCBS"));
        helper.checkOpportunityClosedWon(component, event, helper); 
    },
    
    next : function(component, event, helper) {
        
        var opts = document.querySelector('input[name="options"]:checked').value;
        console.log('NEXT>>>>>>>>>>');
        console.log(opts);
        console.log('CBS valid? : '+component.get("v.validForCBS"));
        console.log('CBS valid? : '+component.get("v.validForCBSContract"));
        
        if(opts=='soc'){
            /*component.set("v.openSupportForm",false);
            var oppLineItem = component.get("v.hasOppLineItemsNotPresent");
            if(oppLineItem == false)
                helper.doSOCCreate(component, event, helper);
            else{*/
            component.set("v.isNextClicked",true);
            var flow = component.find("flowData");
            var flowInputs =[{
                name : "varOpportunityId",
                type : "String",
                value : component.get('v.recordId')
            }];
		   flow.startFlow("SFD_Create_Case",flowInputs);
            
        }
        else if(opts=='socsupport'){
            component.set("v.openSupportForm",true);
        }
        else if(opts=='createCBSCase'){
            //Karan : 
            if(!component.get("v.validForCBS")){
                console.log('Inside False CBS');
                helper.showErrorToast(component, event, helper,"Before engaging the CBS team for design requests, please ensure:\n1) Opportunity is at Develop or ahead.\n2) A valid product basket is synced with the opportunity."); 
            }
                else{
            helper.validateAndCreateCBSCase(component, event, helper);
            //helper.showToastWithURL(component, event, helper,'Record created! See it {0}!','0065P000002G0BjQAK', 'Custom Demo Opportunity');
            //helper.showSuccessToast(component, event, helper);
            }
        }
        else if(opts=='createCBSContractCase'){
            //Smriti :
            console.log('valid cbs value is',!component.get("v.validForCBS"));
            if(!component.get("v.validForCBSContract")){
                console.log('valid for CBS false is called');
                helper.showErrorToast(component, event, helper,"Before engaging the CBS team for Contract requests, please ensure:\n1) Opportunity is Close/Won and have no open contract case for this opportunity.\n2) A valid product basket is synced with the opportunity."); 
            }
                else{
              helper.validateAndCreateCBSContractCase(component, event, helper);  
            }
        }
        else if( opts=='createCPECase'){
            component.set('v.ShowAllBeforeFlow', false);
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:cpeFlowScreen",
                componentAttributes: {
                    recordId : component.get("v.recordId"),
                    varShowProductDomain : component.get('v.showProductDomain')
                }
            });
            evt.fire();
                    /*var flow = component.find("flowData");
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
               }               
           ];           
           //start the flow
           flow.startFlow("Create_CPE_Request_Cases", inputVariables );*/
        }
        /*if(opts!='socsupport' ||opts!='soc' )
        {
            
        }*/
        //P2OB-7062 CAS case creation flow call START
        else if(opts=='CAS'){
            component.set('v.ShowAllBeforeFlow', false);
            var flow = component.find("flowData");
            var flowInputs =[{
                name : "varOpportunityID",
                type : "String",
                value : component.get('v.recordId')
            }];
		   flow.startFlow("CAS_Screen_Flow",flowInputs);

        }
        //P2OB-7062 END
    },
    enableNext : function(component, event, helper) {
        component.find("nextBtn").set('v.disabled',false); 		
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.openSupportForm",false);
        $A.get("e.force:closeQuickAction").fire();
    },
    
    //handle callback from flow
    handleStatusChange : function (component, event) {
        
        component.set("v.showSpinner",false);
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
            
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Success!",            
                "message": 'Done',
                "type": "Success",
                "duration":" 4000"
            });
            toastEvent.fire();
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