({	
	
	doInit: function (component, event, helper) {
        console.log('Inside doInit');
		//$A.util.addClass(component.find("mySpinner"), "slds-hide");
		component.set("v.showSpinner1", true);
		var basketId = component.get('v.basketId');
		var accountId = component.get('v.accountId');
		var selectedrecord = component.get("v.selectedLookUpRecord");
        console.log(selectedrecord);
		var action = component.get("c.getOpportunityId");
		action.setParams({
			"basketId": basketId
		});
		

		action.setCallback(this, function (response) {

			var oppId = response.getReturnValue();
			component.set("v.opportunityId", oppId);
			component.set("v.showSpinner1", false);
            
		});
		
		$A.enqueueAction(action);

		var action = component.get("c.getAccountDetails");
		action.setParams({
			"basketId": basketId,
			"accountId": accountId
		});
		action.setCallback(this, function (response) {
			var acc = response.getReturnValue();
			component.set("v.acc1", acc);
			component.set("v.accountId", acc.Id);

		});
		$A.enqueueAction(action);
        
        var action = component.get("c.getACRId");
		action.setParams({
			"basketId": basketId
		});

		action.setCallback(this, function (response) {

			var selectedrecord = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS"){
                if (selectedrecord != null || selectedrecord != '')
			component.set("v.selectedLookUpRecord", selectedrecord);
            console.log('selectedLookUpRecord---->'+selectedrecord);
            component.set("v.loaded", true);
            }
            else {
                component.set("v.selectedLookUpRecord", null);
                component.set("v.loaded", true);
                
            }
		});

		$A.enqueueAction(action);
        
        //EDGE-151654 navigationfix start added by shubhi
         /*---- PRM URL Redirection -----*/
        var actionOrgDetails = component.get("c.organizationInfo");
        actionOrgDetails.setCallback(this, function(response) {
            var state = response.getState();  
            //  alert(JSON.stringify(response.getReturnValue()) +'______'+response.getState());
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.OrgDetails", response.getReturnValue());
                }
            }
            else if(state === "ERROR"){
                //component.set("v.errorMsg", 'Something went wrong.');
                //helper.showError(component, event, helper);
            }
        });
        $A.enqueueAction(actionOrgDetails);
		/*-------------getprm user info--------*/
        var actionUserInfo = component.get("c.GetSiteId");
        actionUserInfo.setCallback(this, function(response) {
            var state = response.getState();  
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.site", response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(actionUserInfo);
        //EDGE-151654 navigationfix end 
		
	},
	onCancel: function (component, event, helper) {
        console.log('on cancel...');
		helper.closeModalWindow(component);
	},
	
	//<!--test helptext workaround #2 starts here-->
	showToolTip : function(component , event, helper) {
        component.set("v.showToolTipBoolean" , true);
    },
    HideToolTip : function(component , event, helper){
        component.set("v.showToolTipBoolean" , false);
    },

	showToolTip1 : function(component , event, helper) {
        component.set("v.showToolTipBoolean1" , true);
    },
    HideToolTip1 : function(component , event, helper){
        component.set("v.showToolTipBoolean1" , false);
    },
	showToolTip2 : function(component , event, helper) {
        component.set("v.showToolTipBoolean2" , true);
    },
    HideToolTip2 : function(component , event, helper){
        component.set("v.showToolTipBoolean2" , false);
    },
	showToolTip3 : function(component , event, helper) {
        component.set("v.showToolTipBoolean3" , true);
    },
    HideToolTip3 : function(component , event, helper){
        component.set("v.showToolTipBoolean3" , false);
    },
	
	
	onSave: function (component, event, helper) {
        console.log('onsave..');
		component.set("v.showSpinner1", true);
		var isValid = true;
		component.set("v.isError", false);
		component.set("v.roleError", false);
		/* This Logic is added as Part of EDGE-> 63041 to Create Contact Role on Opportunity */
		var conObj = component.get("v.selectedLookUpRecord");
        /* EDGE-74980 - Making Cancellation Reason Field Mandatory*/
        component.set("v.isEmpty_CancelReason", false);
        component.set("v.isEmpty_Competitor", false); //Added as part of EDGE-175721
        const cancelReason = component.find("Input_Cancellation_Reason__c").get('v.value');
        const competitor = component.find("Input_Competitor__c").get('v.value');
		//set the default accountId is null 
		// check if selectedLookupRecord is not equal to undefined then set the accountId from 
		// selected Lookup Object to Contact Object before passing this to Server side method
		if (conObj != null || conObj != undefined) {
			if (((conObj.Roles == undefined) || (conObj.Roles == '')) && !component.get("v.opp.isInsolvencyCancel__c")) {
				component.set("v.showSpinner1", false);
				component.set("v.isError", true);
				isValid = false;
			} else if ((conObj.Roles != "Full Authority") && (conObj.Roles != "Legal Lessee")) {
				component.set("v.showSpinner1", false);
				component.set("v.roleError", true);
				conObj = null;
				isValid = false;
			}
            if(cancelReason == '' || cancelReason == null){
                component.set("v.isEmpty_CancelReason", true);
                isValid = false;
            }
            //Added as part of EDGE-175721
            if(cancelReason == 'Lost to Competitor' && (competitor == '' || competitor == null)){
                component.set("v.isEmpty_Competitor", true);
                isValid = false;
            }
		} else {
  			if(!component.get("v.opp.isInsolvencyCancel__c")) {
			component.set("v.showSpinner1", false);
			component.set("v.isError", true);
			isValid = false;
			}

		}
		console.log('isValid..'+isValid);
		if (isValid) {
          if(!component.get("v.opp.isInsolvencyCancel__c"))
          {
			//call apex class method
			var conId = conObj.ContactId;
			//call apex class method
			var action = component.get('c.createContactInOpportunity');

			var OppId = component.get("v.opportunityId");
			action.setParams({
				'OppId': OppId,
				'conId': conId

			})
			action.setCallback(this, function (response) {
				//store state of response
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set("v.showSpinner1", false);
				}
			});
			$A.enqueueAction(action);
           }
            
            console.log('Before updateOpportunityTypeDisconnect---->');
            var action1 = component.get('c.updateOpportunityTypeDisconnect');

			var OppId = component.get("v.opportunityId");
            var basketId1 = component.get("v.basketId");
            console.log('Before updateOpportunityTypeDisconnect OppId---->'+OppId);
            console.log('Before updateOpportunityTypeDisconnect---->basketId'+basketId1);

			action1.setParams({
				'OppId': OppId,
				'basketId': basketId1

			})
			action1.setCallback(this, function (response) {
				//store state of response
				var state = response.getState();
				if (state === "SUCCESS") {
                    console.log('Inside Success updateOpportunityTypeDisconnect---->');
					component.set("v.showSpinner1", false);
                    let redirectToBasket = component.get('v.redirectToBasket');
					var createEvent = component.getEvent("cancelReasonUpdated");
					createEvent.setParams({
						"redirect": redirectToBasket
							});
					createEvent.fire();
                    console.log('Event Fired');
                    helper.redirectToBasket(component,OppId); // INC000094617257 Fix
				}
			});
			$A.enqueueAction(action1);
            
            
            
            

			let basketId = component.get('v.basketId');

			component.find("editForm").submit();

		}
        //Added as part of EDGE-175721
        else{
            component.set("v.showSpinner1", false);
        }

	},
	onSuccess: function (component, event, helper) {
		//event.preventDefault();

		let redirectToBasket = component.get('v.redirectToBasket');
		var createEvent = component.getEvent("cancelReasonUpdated");
		createEvent.setParams({
			"redirect": redirectToBasket
		});
		createEvent.fire();
	},
	onError: function (component, event, helper) {
		//event.preventDefault();
	},
    showRequiredFields: function(component, event, helper){
        $A.util.removeClass(component.find("Input_Cancellation_Reason__c"), "none");
    }
})