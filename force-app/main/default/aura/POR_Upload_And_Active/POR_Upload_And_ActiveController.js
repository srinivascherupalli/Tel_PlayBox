({   

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
          var APTPS_DocuSign_Restricted__c= data.Customer__r.APTPS_DocuSign_Restricted__c;
          var APTPS_Off_Shore_Restricted__c = data.Customer__r.APTPS_Off_Shore_Restricted__c;
         var Status__c=data.Status__c;
         
         console.log("APTPS_Off_Shore_Restricted__c"+APTPS_Off_Shore_Restricted__c);
          console.log("APTPS_DocuSign_Restricted__c"+APTPS_DocuSign_Restricted__c);
          console.log("Status__c"+Status__c);
          console.log("data"+data);
         //var error="This customer is not restricted, Partner of Record agreement will be sent to the customer via DocuSign";
        
         
         if(Status__c !="Customer Review" )
         {
             component.set('v.invalidstatus',false);
             component.set('v.displaymsg',true);
             component.set('v.displayupload',false);
         }
         if(!(APTPS_DocuSign_Restricted__c || APTPS_Off_Shore_Restricted__c)  )
         {
               component.set('v.displaymsg',false);
             component.set('v.displayupload',false);
             component.set('v.invalidstatus',true);
        }
     
	});           

		$A.enqueueAction(action);  		
	
	},
    
	
    	handleUploadFinished: function (component, event) {
          //Get the list of uploaded files
        
        var uploadedFiles = event.getParam("files");
        //Show success message – with no of files uploaded
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": uploadedFiles.length+" files has been uploaded successfully!"
        });
        toastEvent.fire();
          $A.get('e.force:refreshView').fire();
         //component.set('v.displaybutton',true); 
      //   component.set('v.displayupload',false);
          var button = component.find('disablebuttonid');
    		button.set('v.disabled',false);
        //component.set('v.displaybutton',true);
         
        //$A.get('e.force:refreshView').fire();
         
         
        //Close the action panel
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
        // Get the list of uploaded files
        //var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        

        // Get the file name
        //uploadedFiles.forEach(file => console.log(file.name));
            
            //$A.get('e.force:refreshView').fire();
    },
    
    
        handleActivate: function(component, event, helper) {
        //alert("Changing the  status to Active");
        debugger;
		var save_action = component.get("c.changestatus");
        var PId = component.get("v.recordId");
        debugger;
    	save_action.setParams({
            "PatnerId": PId
            
            });
        debugger;
        save_action.setCallback(this, function(response) {
            var status = response.getState();
            console.log("state"+state);
            if(response.getState() === "SUCCESS") {
                console.log("status change to Active");
            	}
        	});
     
        //$A.get("e.force:refreshView").fire();
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
           $A.enqueueAction(save_action);
               window.location.reload();
	}
    
    
})