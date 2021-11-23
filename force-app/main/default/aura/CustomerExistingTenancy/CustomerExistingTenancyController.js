({
	doInit: function (component, event, helper) {
        //helper.showExampleModal(component);
		//$A.util.addClass(component.find("mySpinner"), "slds-hide");
		//component.set("v.showSpinner1", true);
		component.set("v.showSpinner", true);
		var url = window.location.host;
		var accountId = component.get('v.accountId');
		var basketId = component.get('v.basketId');
        var filterByTenancyType = component.get('v.filterByTenancyType');
		var tenancyTypeProdIdList = component.get('v.tenancyTypeProdIdList');
        var selectedTenancyIds= component.get('v.selectedTenancyIds');

        component.set("v.vfHost",url);
		var action = component.get("c.getSubscriptions");
		action.setParams({
			"accountId": accountId,
            "basketId": basketId,
            "filterByTenancyType" : filterByTenancyType,
            "tenancyTypeProdIdList" : tenancyTypeProdIdList
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
            if (state === "SUCCESS") {
				var res = response.getReturnValue();

				component.set("v.subscriptionRecords", res);
				var subscriptionRecords = component.get('v.subscriptionRecords');
                    if(subscriptionRecords.length<0){
                    component.set("v.showSpinner", false);
                }
            }
            if(selectedTenancyIds.length>0){
                var checkFirstRun = true;
            	setInterval(function() {
             	 if (checkFirstRun === true) {
                    var subscriptionRecords = component.get('v.subscriptionRecords');
                    for(var i=0;i<subscriptionRecords.length;i++){
                        var selectedTenancyIds=component.get('v.selectedTenancyIds');
                        var subscriptionTenancty;
                        if (  component.get("v.isTenancySelectionAfterApproval") == "true" ) { 
                            subscriptionTenancty = subscriptionRecords[i].NetworkServiceId__c;  // EDGE-223950 
                        }else{
                            subscriptionTenancty = subscriptionRecords[i].TenancyID__c;
                        }

                        if(selectedTenancyIds.includes(subscriptionTenancty)){
                            var dom=document.getElementById(subscriptionTenancty);
                            if(dom!=null){
                                document.getElementById(subscriptionTenancty).checked=true;
                                component.set("v.showSpinner", false);
                            }
                        }
                    }
                    checkFirstRun = false;
                  }
            	}, 500); 
            }else{
                component.set("v.showSpinner", false);
            }
            component.set("v.showSpinner", false);
            //component.set("v.showSpinner", false);
		});

		$A.enqueueAction(action);
        
        // vivek : start
        if (  component.get("v.isTenancySelectionAfterApproval") == "true" ) {
            component.set("v.callerName", 'Business Calling');
        }else{
            component.set("v.callerName", 'Managed Services');
        }
        // vivek : end
		
	},
    
    //Updated for Edge-117563
    onClick : function(component, event, helper) {
        
        //var selectedId = event.getSource().get("v.value");
          var selectedId = event.target.getAttribute('id');
          var selectedName = event.target.getAttribute('name');
          var selectedSubscription = event.currentTarget.dataset.sub;
        //selectedId = event.target.getAttribute('id');
        var tenancyIds=component.get('v.selectedTenancyIds');
        var selectedTenancyIds=[];
        var selectedTenancyName = component.get('v.selectedTenancyName');
        var selectedTenancySubscription = component.get('v.selectedTenancySubscription');
        //Updated for Edge-117563
        if(tenancyIds.length>0){
            var typeofTenacyIds=typeof tenancyIds;
            if(typeofTenacyIds=='string'){
                selectedTenancyIds=tenancyIds.split(',');
            }           	
            else{
                selectedTenancyIds=tenancyIds
            }
        } 
       var index1 = selectedTenancyIds.indexOf(selectedId);
        if (selectedId != null){
            if(document.getElementById(selectedId).checked && component.get("v.selectedTenancyIds").indexOf(selectedId) < 0){
                selectedTenancyIds.push(selectedId);
                if ( selectedName != null ){
                    selectedTenancyName.push( selectedName );
                }
                if( selectedSubscription != null ) {
                    selectedTenancySubscription.push( selectedSubscription );
                }
                component.set('v.selectedTenancyIds',selectedTenancyIds);
                component.set('v.selectedTenancyName',selectedTenancyName);
                component.set('v.selectedTenancySubscription',selectedTenancySubscription);
            }     
            else{
                var index = selectedTenancyIds.indexOf(selectedId);
                if (index > -1) {
                    selectedTenancyIds.splice(index, 1); 
                    selectedTenancyName.splice(index, 1);
                    selectedTenancySubscription.splice(index, 1);
                    component.set('v.selectedTenancyIds',selectedTenancyIds);
                    component.set('v.selectedTenancyName',selectedTenancyName);
                    component.set('v.selectedTenancySubscription',selectedTenancySubscription);
                }
            }
    	}
       
    },
    
    onSave: function (component, event, helper) {


        var selectedTenancyIds = component.get("v.selectedTenancyIds");
        

         // vivek 206232 : START
         if (  component.get("v.isTenancySelectionAfterApproval") == "true" &&   component.get("v.selectedTenancyIds").length == 0 ){
            helper.showCustomToast(component, 'Please select one tenancy before saving', 'Error', 'error');
            return;
         }
         var subscriptionId;

        if ( component.get("v.isTenancySelectionAfterApproval") == "true" ){
            if ( component.get("v.selectedTenancyIds").length > 1) {
                helper.showCustomToast(component, 'Please select only 1 tenancy', 'Error', 'error');
                return;
            }else if ( component.get("v.selectedTenancyIds").length == 1 ){
                subscriptionId = component.get('v.selectedTenancyName')[0];
            }
        }
       
        if ( component.get("v.isTenancySelectionAfterApproval") == "true" ) {
            var action = component.get("c.getActualGUID");
            action.setParams({
                "subscriptionId" : subscriptionId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var guId = response.getReturnValue();
                if (state === "SUCCESS") {
                    helper.fireTenancyEvent( component, event, helper , guId );
                }
                else {
                    console.log("Failed with state: " , state);
                }
            });
            $A.enqueueAction(action);
        }
        
        // vivek edge-206232 : END

        // DPG-5929 : @vm 23rd june
        if ( component.get("v.isTenancySelectionAfterApproval") != "true"  ) {  // added it in a condition 206232 vivek
            var myEvent = $A.get("e.c:CustomerExistingTenancyEvent");
            myEvent.setParams({
                "selectedTenancyIds":selectedTenancyIds,
                "callerName" : component.get('v.callerName')
            });
            myEvent.fire();
        }
        //Added by Purushottam as a part of EDGE -145320 || Start
        component.set("v.showSpinner", true);
            setTimeout( $A.getCallback(function(){
              component.set("v.showSpinner", false);
                 helper.showCustomToast(component, 'Tenancy IDs are selected sucessfully', 'Success', 'success');
                
            }), 2000);
        //Added by Purushottam as a part of EDGE -145320 || End
        //helper.showCustomToast(component, 'Tenancy Ids are selected sucessfully', 'Success', 'success');  
        //helper.hideExampleModal(component);
	}, 
    //Added by Purushottam as a part of EDGE -145320 || Start
    onCancel: function (component, event, helper) {
        var myEvent = $A.get("e.c:CustomerExistingTenancyEvent");
        myEvent.setParams({
                "close":"true"
            });
         myEvent.fire();
    },
     //Added by Purushottam as a part of EDGE -145320 || End

   
})