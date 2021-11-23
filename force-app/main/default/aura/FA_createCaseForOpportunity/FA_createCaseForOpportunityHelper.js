({
    insertDeal : function(component,event,helper){
        var action = component.get("c.fetchFAPricingRequest");
        action.setParams({ FAId : component.get("v.FrameId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {	 
             	console.log("SUCCESS");	
            	component.set("v.DealStatus",response.getReturnValue().csconta__Status__c);
            	if(component.get("v.DealStatus")=='Sent for Approval'){
                	this.disableFieldonEscalatePricingTeam(component,event,helper);
            	}
             	component.set("v.showSpinner",false);
                console.log("SUCCESS2");
             	if(component.get("v.Status") == false){  
                 	var message = {
                     	'displayMsg':'Case is created Successfully!!',
                     	'type' : state
                 	}
                 	component.set("v.Status",true);
                 	var vfOrigin = $A.get("$Label.c.FAPostURL");
					var profiles = "PRM Admin - Australia,PRM Community User - Australia";
                    var profileList = profiles.split(",");
                    profileList.forEach(function(item,index){
                        if(component.get('v.CurrentUser')['Profile'].Name == item){
                            vfOrigin = $A.get("$Label.c.FAPartnerPostURL");
                        }
                    });
                 	window.postMessage(message, vfOrigin);
             	}else{
                 	var message = {
                    	'displayMsg':'Case is Updated Successfully!!',
                    	'type' : state
                 	}
                 	component.set("v.Status",true);
                 	var vfOrigin = helper.getVfOrigin(component);
                 	window.postMessage(message, vfOrigin);
             	}
            }
            else if (state === "INCOMPLETE") { 
                component.set("v.showSpinner",false);
                component.set("v.caseCheck",false);
                var message = {
                    'displayMsg':'Case is Incomplete',
                    'type' : state
                }
                var vfOrigin = helper.getVfOrigin(component);
                window.postMessage(message, vfOrigin);
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.showSpinner",false);
                    component.set("v.caseCheck",false);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    component.set("v.SpinnerCheck",false);
                    component.set("v.caseCheck",false);
                    var message = {
                        'displayMsg':'Case has Errors!!',
                        'type' : state
                    }
                    var vfOrigin = helper.getVfOrigin(component);
                    window.postMessage(message, vfOrigin);
                    
                }
        });
        $A.enqueueAction(action);
        
        component.set("v.SpinnerCheck",false);
    },
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
    fetchRecordId : function(component,event,helper){
        var action = component.get("c.getRecordTypeIdbyName");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.caseRecordId",response.getReturnValue());
                var v = component.get("v.caseRecordId");
                console.log(v);
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
    
    /*
     * @Created By : Kamlesh Kumar
     * @Created Date : 17/3/2021
     * @Breif : EDGE -200438, The method gives a server call and based on the group type and group name fetches the details
     */
    fetchQueueDetails : function(component,event,helper){
        var action = component.get("c.fetchGroupDetails");
        action.setParams({ name : 'Enterprise_Pricing_User_1',groupType : 'Queue'});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {  
                var queuedetails = response.getReturnValue();
                component.set("v.queueId",queuedetails[0].Id);
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
	createdApprovalCase : function(component,event,helper){
        var action = component.get("c.getDPROfferRecords");
        action.setParams({ FA_Id : component.get("v.FrameId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {  
				var selValues = [];
				var dprOffers = response.getReturnValue();
				for(var i=0;i<dprOffers.length;i++){
					var familyLevel = dprOffers[i].Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c;
					if(!selValues.includes(familyLevel)){
						selValues.push(familyLevel);
					}
				}
				component.set('v.familyLevel',selValues.join(';'));
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
	getVfOrigin : function(component){
        var vfOrigin = $A.get("$Label.c.FAPostURL");
        var profiles = "PRM Admin - Australia,PRM Community User - Australia";
        var profileList = profiles.split(",");
        profileList.forEach(function(item,index){
            if(component.get('v.CurrentUser')['Profile'].Name == item){
                vfOrigin = $A.get("$Label.c.FAPartnerPostURL");
            }
        });
        return vfOrigin;
    }
    
})