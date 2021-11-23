({
    /* aeHandlerController.js */
    doInit : function(component, event, helper) {
        console.log('SubmitToPartnerNew init called******');
        component.set("v.HideSpinner", false);
        component.set("v.spinner", true);
        //var action = component.get("c.findIncumbentPartners");
        var action = component.get("c.init");
        var status=component.get("v.recordId");
        var closedOpportunityErr;
        var sharedWithPartnerErr;
        var partnerCreatedErr;
        var opportunityOwnerInactiveErr; //v1.7
        
        var action1 = component.get("c.getDistributorModelSettings");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){ 
                closedOpportunityErr = response.getReturnValue().closedOpportunityError;
                sharedWithPartnerErr = response.getReturnValue().sharedWithPartnerError;
                partnerCreatedErr = response.getReturnValue().partnerCreatedError;
                opportunityOwnerInactiveErr = response.getReturnValue().opportunityOwnerInactiveError;//v1.7
            }
        });
        $A.enqueueAction(action1);

        action.setParams({ OpptyID : component.get("v.recordId") });
        //alert("From server1: ");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){              
                console.log('egtting findIncumbentPartners!!!!');
                console.log(response.getReturnValue());
                //alert("From server: " + response.getReturnValue());
                //component.set("v.PartnerResultsRec",response.getReturnValue());
                component.set("v.PartnerResultsRec",response.getReturnValue().PartnerResultsRec);
                component.set("v.PartnerResultsInc",response.getReturnValue().PartnerResultsInc);
                component.set("v.PartnerResultsPOR",response.getReturnValue().PartnerResultsPOR);
                component.set("v.StageNames",response.getReturnValue().GetOpptyStatus);
                component.set("v.recTypeId",response.getReturnValue().GetRecTypeId);// v1.5
                var submitToPartnerStatus = response.getReturnValue().GetSubmitToPartnerStatus; // v1.4
                var partnerName = response.getReturnValue().GetPartnerName; // v1.4
                var isCurrentOwnerActive = response.getReturnValue().GetOwnerActive;//v1.7
                var partnerOwnerId = response.getReturnValue().GetPartnerOwnerId; // v1.4
				// EDGE-96585                
              
                component.set('v.displayData',true);
                component.set("v.spinner", false);
                
                var PartnerResultsRecvalue = component.get("v.PartnerResultsRec");
                var PartnerResultsIncValue = component.get("v.PartnerResultsInc");
                var PartnerResultsPORValue = component.get("v.PartnerResultsPOR");
                // EDGE-96585
                // v1.4 If Opportunity is closed, submitted for approval or approved prevent reshare  
                var StageNames = component.get("v.StageNames");
				if(StageNames=="Closed Lost" || StageNames=="Closed Won"){
                    console.log('closedOpportunityErr*****1111'+closedOpportunityErr);
                    component.set("v.ShowMessageLC",true);
                    //component.set("v.ErrorMessage","You cannot make changes to this Opportunity as it is closed"); // v1.4
                    component.set("v.ErrorMessage",closedOpportunityErr); // v1.5
                }else if(isCurrentOwnerActive == false){
                    component.set("v.ShowMessageLC",true);//v1.7
                    component.set("v.ErrorMessage",opportunityOwnerInactiveErr);//v1.7
                }else if(partnerOwnerId != null){
                    component.set("v.ShowMessageLC",true);
                    console.log('partnerCreatedErr*****1111'+partnerCreatedErr);
                    var tempMsg = partnerCreatedErr.replace("{!partner}",partnerName);
                    component.set("v.ErrorMessage",tempMsg);
                }else if (partnerName != null && submitToPartnerStatus != "Rejected" && partnerOwnerId == null){//else if(submitToPartnerStatus =="Submitted" || submitToPartnerStatus =="Approved"){
                    component.set("v.ShowMessageLC",true);
                    console.log('sharedWithPartnerErr*****1111'+sharedWithPartnerErr);
                    var tempMsg = sharedWithPartnerErr.replace("{!partner}",partnerName);
                    component.set("v.ErrorMessage",tempMsg);
                }
                              
             
               if(PartnerResultsIncValue.length==0 && PartnerResultsPORValue.length==0){ 
            		component.set("v.IsNoIncumbent", true);
                   	//component.set("v.message", 'No Incumbent Partner found');
                   	component.set("v.showMessage", true);

                }
              
               if(PartnerResultsRecvalue.length==0) //&& PartnerResultsIncValue.length>0
                {
                    console.log('PartnerResultsRecvalue',PartnerResultsRecvalue);
                    component.set("v.IsNoRecommended", true);
                   	//component.set("v.message", 'No Recomended Partner found');
                   
                    component.set("v.OverideRecomm", true);
                    component.set("v.showMessage", true);
                }
                else if(PartnerResultsRecvalue.length==0 && PartnerResultsIncValue.length==0 && PartnerResultsPORValue.length==0 )
                {
                    component.set("v.showMessage", true);
                   	component.set("v.message", 'There are no incumbent,POR or recommended Partners');
                }  
                
                
                if(PartnerResultsRecvalue.length>0 && (PartnerResultsIncValue.length==0 && PartnerResultsPORValue.length==0)){ 
                    component.set("v.IsIncumbentSave", true);
                    console.log('IsIncumbentSave')
                }
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        //  $A.enqueueAction(action1);
        $A.enqueueAction(action);
    },

    handleApplicationEvent : function(cmp, event) {
        var IsContinue = event.getParam("IsContinue");
        //var Partnerjson=event.getParam("PartnerSelectedDetails");
        var ReconmondedId = event.getParam("ReconmondedId");
        //var Partnerjson=event.getParam("PartnerSelectedDetails");
        var IsIncumbentSave=event.getParam("IsIncumbentSave");
        var IsIncumbentBack=event.getParam("IsIncumbentBack");
        var IsOverideIncumbent=event.getParam("OverideIncumbent"); // v1.3
        var valPrimaryDistributor=event.getParam("valPrimaryDistributor");// v1.2
        var valPrimaryDistributorName=event.getParam("valPrimaryDistributorName");// v1.2
        console.log('***valPrimaryDistributor***'+valPrimaryDistributor+'***Name***'+valPrimaryDistributorName);
        
        // set the handler attributes based on event data
        cmp.set("v.IsCotinue", IsContinue);
        cmp.set("v.ReconmondedId", ReconmondedId);
        cmp.set("v.IsIncumbentSave", IsIncumbentSave);
        cmp.set("v.IsIncumbentBack", IsIncumbentBack);
        if(valPrimaryDistributor != undefined && valPrimaryDistributor != ''){// v1.2
            cmp.set("v.valPrimaryDistributor", valPrimaryDistributor);
            cmp.set("v.valPrimaryDistributorName", valPrimaryDistributorName);
        }
        
        // v1.3 update to fetch PRM Opportunity Partner Auto Tagging custom setting records
        var action = cmp.get("c.getHiearchySettings");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                // set the custom settings Active/Inactive flag to boolean parameter
                // P2OB-4957 - Custom setting issue fix
              	cmp.set("v.blnOpportunityOptimization", response.getReturnValue().isActive);
                console.log('OPTIMIZATION ENABLED PRM SUBMIT TO PARTNER NEW*****');
                if(ReconmondedId != undefined && ReconmondedId != ''){
                    // for non onboarded nominates replace {!} with actual distributor name in message
                    if(valPrimaryDistributorName != undefined){
                        var nomMsg = response.getReturnValue().nonOnboarderNominateMessage; // P2OB-4957 - replace custom setting field to wrapper class field
                        nomMsg = nomMsg.replace('{!distributorName}',valPrimaryDistributorName);
                        console.log('nomMsg PRMSubmitToPartnerNew*****'+nomMsg);
                        cmp.set("v.OpportunityOptimizationMsg",nomMsg);
                    }
                }
            }else if (state === 'ERROR'){
                console.log('Something went wrong. Error');
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
        
        //cmp.set("v.SelectedJson", Partnerjson);
        //location.reload();
        // var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        //cmp.set("v.numEvents", numEventsHandled);
    },
    closeToast : function(component, event, helper) {
        component.set('v.showMessage',false);
    }
    
})