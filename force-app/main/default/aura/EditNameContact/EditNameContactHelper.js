({
   // really simple function that can be used in every component's helper file to make using promises easier.
    executeAction: function(cmp, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var retVal=response.getReturnValue();
                    resolve(retVal);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    }
                    else {
                        reject(Error("Unknown error"));
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    showToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
    },
    showHide : function(component) {
        var recordId = component.get("v.recordId");
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObjectEvent.fire(); 
        
    },
	//To Enable and disable Input fields based on Change of Name Change Reason field
    handleDisable: function(component,NTitle,NLastName,NFirstName,NMidName,CMidName)
    {
        component.find("NewTitle").set("v.disabled", NTitle);
        component.find("NewLastName").set("v.disabled", NLastName);
        component.find("NewFirstName").set("v.disabled", NFirstName);
        component.find("NewMiddleName").set("v.disabled", NMidName);
        component.find("ClearMiddleName").set("v.disabled", CMidName);
    },
	//Clearing Values in Input fields on Change of Name Change Reason field
    clearValues: function(component,NTitle,NLastName,NFirstName,NMidName,CMidName)
    {
     	component.find("NewTitle").set("v.value", NTitle);
        component.find("NewLastName").set("v.value", NLastName);
        component.find("NewFirstName").set("v.value", NFirstName);
        component.find("NewMiddleName").set("v.value", NMidName);
        component.find("ClearMiddleName").set("v.value", CMidName);
    },
    submitRecord: function(component,event,helper){
        var isPartner = component.get("v.isPartner");
        // EDGE-176104 Added for Active POR flag check
     var recordTypeId=component.get("v.recordTypeId");
        console.log('submitRecord:isPartner'+isPartner);
        console.log('submitRecord:Changereason'+recordTypeId);
        if(isPartner==true)
        {
          	//  Update_Personal_Details__c personaldetails=new Update_Personal_Details__c();
           	// system.debug(''+personaldetails);
            var Changereason=component.find("mySelect").get("v.value");
            var NewFirstName=component.find("NewFirstName").get("v.value");
            var NewLastName=component.find("NewLastName").get("v.value");
            var NewMiddleName=component.find("NewMiddleName").get("v.value");
           var ClearMiddleName=true;
             var NewTitle=component.find("NewTitle").get("v.value");
            var FirstName=component.find("FirstName").get("v.value");
            var MiddleName=component.find("MiddleName").get("v.value");
            var LastName=component.find("LastName").get("v.value");
            var Title=component.find("Title").get("v.value");
            var recordTypeId=component.get("v.recordTypeId");
            var recordId=component.get("v.recordId");
             if(LastName != "")
            {
                var ClearMiddleName=false;
            }
            console.log('Changereason'+Changereason);
            console.log('NewFirstName'+NewFirstName);
            console.log('NewLastName'+NewLastName);
            console.log('ClearMiddleName'+ClearMiddleName);
            console.log('recordTypeId'+recordTypeId);
            
            var action = component.get("c.prmUpdateContactdetails");
            action.setParams({"Changereason":Changereason,
                             "NewFirstName":NewFirstName,
                              "NewLastName":NewLastName,
                              "NewMiddleName":NewMiddleName,
                              "ClearMiddleName":ClearMiddleName,
                               "NewTitle":NewTitle,
                               "FirstName":FirstName,
                              "MiddleName":MiddleName,
                              "LastName":LastName,
                              "Title":Title,
                              "recordTypeId":recordTypeId,
                              "recordId":recordId
                            });
            var p = helper.executeAction(component, action);
            // use the promise to do something 	
            p.then($A.getCallback(function(result){
                            console.log('--- Update Person Details '+JSON.stringify(result));
                          $A.get("e.force:closeQuickAction").fire();
                		 $A.get("e.force:refreshView").fire();  
                		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Contact Name has been updated Successfully',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
        });
        toastEvent.fire();
               
                     })).catch($A.getCallback(function(error){
                // Something went wrong
               //alert('An error occurred : ' + error.message);
            }));
         
        }
        
      else{
       
        var fields = event.getParam("fields");
    	fields["Change_reason__c"] = component.find("mySelect").get("v.value");
		fields["New_First_Name__c"] = component.find("NewFirstName").get("v.value");
		fields["New_Last_Name__c"] = component.find("NewLastName").get("v.value");
		fields["New_Middle_Name__c"] = component.find("NewMiddleName").get("v.value");
		fields["Clear_Middle_Name__c"] = component.find("ClearMiddleName").get("v.checked");
		fields["New_Title__c"] = component.find("NewTitle").get("v.value");
        fields["First_Name__c"] = component.find("FirstName").get("v.value");
        fields["Middle_Name__c"] = component.find("MiddleName").get("v.value");
        fields["Last_Name__c"] = component.find("LastName").get("v.value");
        fields["Title__c"] = component.find("Title").get("v.value");
		component.find("editForm").submit(fields);
        }
        
    }
})