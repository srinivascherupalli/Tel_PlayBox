({   
	//Function to check docusing restricted and patner status
 	 doinit : function(component, event, helper) { 
     var action =component.get("c.checkvalue");
     var accountId = component.get("v.recordId");
     debugger;
     action.setParams({
            "accountIds": accountId
        });
    //action.setParams({"sowId": recordId}); 
     action.setCallback(this, function(response) {
          var state = response.getState();
         console.log("state"+state);
          console.log("response"+response);
           // var stateval = response.getReturnValue();
          //console.log("stateval"+stateval);
         var data=response.getReturnValue(); 
         var myJSON = JSON.stringify(data);
         console.log("myJSON"+myJSON);
         console.log("data"+data);
          var APTPS_DocuSign_Restricted__c=data.Customer__r.APTPS_DocuSign_Restricted__c;
         var Status__c=data.Status__c;
         
          console.log("APTPS_DocuSign_Restricted__c"+APTPS_DocuSign_Restricted__c);
          console.log("Status__c"+Status__c);
          console.log("data"+data);
         //var error="This customer is not restricted, Partner of Record agreement will be sent to the customer via DocuSign";
         if(!APTPS_DocuSign_Restricted__c)
         {
             component.set('v.displaymsg',true);
             component.set('v.validstatus',false);
             component.set('v.invalidstatus',false);
        }
         
         if(Status__c !="Customer Review" )
         {
             component.set('v.invalidstatus',true);
             component.set('v.displaymsg',false);
             component.set('v.validstatus',false);
             
         }
        
     
	});           

		$A.enqueueAction(action); 		
	
	},
    
    	//function to change partner status to customerdecline
    	changestatus : function(component, event) {
            
        var save_action = component.get("c.customerdecline");
        var aId = component.get("v.recordId");
    			save_action.setParams({
            	"aIds": aId
            	});
        			save_action.setCallback(this, function(response) {
            	if(response.getState() === "SUCCESS") {
                	console.log("status change to decline");
            		}
        			});
            	$A.get('e.force:refreshView').fire();
        		$A.enqueueAction(save_action);
        		$A.get('e.force:refreshView').fire();
            	var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
        		$A.get('e.force:refreshView').fire();
            	window.location.reload();
				}
})