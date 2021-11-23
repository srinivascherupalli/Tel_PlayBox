({
	checkUser : function(component, event, helper) {
     var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                		var uiTheme = result.uiTheme;
                        var isPilotUser = result.isPilotUser == true ? true : false;
                        var isPartner = result.userType == 'PowerPartner' ? true : false;
                        component.set("v.isInit", true);
                		//Paresh - Added this check to invoke flow for pilot user 
                		if(isPilotUser && isPartner){
                        	helper.openDetail(component, event, helper,uiTheme,isPilotUser, isPartner);
                        //if user is not pilot user it will navigate to 'Domestic_Support_Request'
                        }else if(!isPilotUser && isPartner){
                            helper.navigateToCase(component,event,helper);
                        }
            } 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
	},
    
    openDetail: function(component, event, helper,uiTheme,isPilotUser, isPartner) {
		var modalBody;
		$A.createComponents([
				["c:PRM_CreateCaseViaFlow", {
					uiTheme: uiTheme,
                    isPilotUser : isPilotUser,
                    isPartner : isPartner}]
			],
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: "slds-modal_small",
						closeCallback: function() {
							console.log('modal closed!');
						}
					});
				} else if (status === "ERROR") {
					console.log('ERROR: ', errorMessage);
				}
			}
		)
	},
    handleMenuSelect : function(component, event, helper) {
     	var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue === "New Opportunity"){
            var action = component.get("c.globalActionNavigateUrl");
            action.setCallback(this, function(response) {
            	var state = response.getState();
                if (state === "SUCCESS") {
                	var returnUrl = response.getReturnValue();
                    if(returnUrl != ''){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": returnUrl
                        });
                        urlEvent.fire();
                    }
                }
        	})
            $A.enqueueAction(action);
       	}
        if(selectedMenuItemValue === "New Case"){
            helper.checkUser(component, event, helper);
        }
    },
    
    navigateToCase : function(component, event, helper){
    	var caseUrl = component.get("c.getCaseUrl");
    		caseUrl.setCallback(this, function(responseURL) {
            var state = responseURL.getState();
            if (state === "SUCCESS") {
            	var returnUrl = responseURL.getReturnValue();
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": returnUrl
                        });
                        urlEvent.fire();
                    }
              
        	})
    	$A.enqueueAction(caseUrl);
	},
    handlePOR: function(component, event, helper) {
        var modalBody;
        console.log('handlePOR');
        var flowName='HandlePOR';
		$A.createComponents([
				["c:PRM_CreateCaseViaFlow", {
					flowName: flowName
                   }]
			],                
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: "slds-modal_small",
						closeCallback: function() {
							console.log('modal closed!');
						}
					});
				} else if (status === "ERROR") {
					console.log('ERROR: ', errorMessage);
				}
			}
		)
                		
	},
    //Added to invoke Contact role update flow EDGE-163361
     UpdateContactRole: function(component, event, helper) {
        var modalBody;
             console.log("Caseflow",component.get("v.opptyid"));
         var rowid=component.get("v.opptyid");
        var flowName='UpdateContactRole';
		$A.createComponents([
				["c:LC_NewContactRoleComp", {
					recordId: rowid
                   }]
			],                
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: "slds-modal_small",
						closeCallback: function() {
							console.log('modal closed!');
						}
					});
				} else if (status === "ERROR") {
					console.log('ERROR: ', errorMessage);
				}
			}
		)
                		
	}
})