({
	checkstatus : function(component, event,helper) {
        var accountId = component.get("v.recordId");
    	var action = component.get("c.checkstatus");
    				 action.setParams({
                         "accountIds": accountId
          							 });
        	 console.log(accountId);
        
			action.setCallback(this, function(response) {
                //alert("From server: " + response.getReturnValue());
                 var data=response.getReturnValue(); 
         		var myJSON = JSON.stringify(data);
         		console.log("myJSON"+myJSON);
         		console.log("data"+data);
                var state = response.getState();
                var Status__c=data.Status__c;
                if (Status__c == "Modification in progress"){
                    component.set('v.Modification',true);
					}
                    console.log("status "+Status__c);
                if (state === "SUCCESS") {  
                    //var status =response.getReturnValue();
                    //console.log("status "+status);
                    //console.log("state" +state);
                    
                   				if((Status__c !="Customer Review") && (Status__c !="Pending Approval") && (Status__c !="Partner Review") &&(Status__c !="Initiated") ){
                                    if(Status__c !="Modification in progress"){
                                        console.log("status "+Status__c);
                        			var toastEvent = $A.get("e.force:showToast");
                             		toastEvent.setParams({
    								title : 'Error Message',
                        			message:'Partner of Record withdrawal is only permitted when the agreement status is in “Initiated, Pending Approval, Partner Review, Customer Review',
                        			messageTemplate: 'Mode is error ,duration is 5sec and Message is overrriden',
                        			key: 'info_alt',
                        			type: 'error',
                           			mode: 'dismissible'
                                	});
                        		$A.get("e.force:closeQuickAction").fire();
    							toastEvent.fire();
                    		}
                    
                                }
                }
                else if (state === "ERROR") {
                 var errorMsg = action.getError()[0].message;
                    alert(errorMsg);
                	}
                	
            
                
    	})
        $A.enqueueAction(action);
		
	}
})