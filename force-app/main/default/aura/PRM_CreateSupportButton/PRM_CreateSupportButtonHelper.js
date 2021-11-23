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
    
    //openDetail: function(component, event, helper,uiTheme,isPilotUser, isPartner) {
		openDetail: function(component, event, helper) {
		var modalBody;
		$A.createComponents([
				["c:csGrandParent", {
					userType : 'PowerPartner'
                }]
			],
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayElement').showCustomModal({
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
			});
	},

    handleMenuSelect : function(component, event, helper) {
     	var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue === "New Opportunity"){
          component.set('v.isOpen', true);
           var flow = component.find('flow');
           flow.startFlow('Create_New_Opportunity');
       	}
        if(selectedMenuItemValue === "New Case"){
            //helper.checkUser(component, event, helper);
			helper.openDetail(component, event, helper);
        }
        if(selectedMenuItemValue === "Customer incident"){//EDGE-164004
            var url = component.get("v.csmURL");
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": url
            });
            urlEvent.fire();
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
				//["c:PRM_CreateCaseViaFlow", {
                ["c:prmMACDPOR", {
					flowName: flowName
                   }]
			],                
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayElement').showCustomModal({
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
    
    //P2OB:13078
    createnewopportunity: function(component, event, helper){
     component.set('v.isOpen', true);
      var flow = component.find("flow");
        flow.startFlow("Create_New_Opportunity");
    },
    
	/***********************************************************************************
	 Method     -getCSMDetails
	 Description- EDGE-164004
	 Author     -Ravi Shankar
	**********************************************************************************/
    getCSMDetails : function (component, event, subsId) {    
       var action=component.get("c.getCSMPortalDetails");
	      
       action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();                
				if(result != null && result != '' && result != undefined){
					component.set("v.csmURL", result);
				}
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
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
					component.find('overlayElement').showCustomModal({
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