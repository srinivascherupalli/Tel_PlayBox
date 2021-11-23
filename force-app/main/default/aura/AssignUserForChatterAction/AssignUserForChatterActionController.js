({
    doinit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Comment History',fieldname:'Internal_Case_Comments__c', type: 'text'}])
    },
    handleOnSuccess : function(component, event, helper) {
        component.find('assgndname').set("v.value",null);
        component.find('cmmtname').set("v.value",'');
        $A.get('e.force:refreshView').fire()
    },
    showAllComments : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        var action = component.get("c.getComments");
        action.setParams({recordIdjs : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            component.set("v.IsSpinner",false);
            var state = response.getState();
            console.log('dats1**',response.getReturnValue());
            component.set("v.data",response.getReturnValue());
            console.log('data**'+component.get("v.data"));
            
            if (state === "SUCCESS") {
                component.set("v.isModalOpen", true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("There are No comments yet");
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
            
        });
        $A.enqueueAction(action);
        
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault(); 
        var eventFields = event.getParam("fields"); 
        const assgndUserId = event.getParam('fields').AssignedUser__c;
        console.log('assgndUserId--'+assgndUserId);
        if(assgndUserId == null || assgndUserId == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                //"title": "Success!",
                "message": "Please provide the assigned user name.",
                "duration":"10000",
                "key": "info_alt",
                "type": "error",
                "mode": "pester"
            });
            toastEvent.fire();
            
        }else{
            component.set("v.IsSpinner",true);
            var action = component.get("c.sendMail");
            action.setParams({ userId : assgndUserId,
                              recordIdjs : component.get("v.recordId")});
            
            action.setCallback(this, function(response) {
                component.set("v.IsSpinner",false);
                var state = response.getState();
                component.set("v.myMap",response.getReturnValue());
                console.log(component.get("v.myMap"));
                
                if (state === "SUCCESS") {
                    //eventFields["Comments"] ='@'+ response.getReturnValue()+' - '+event.getParam('fields').Comments;
                    //console.log(event.getParam('fields').Comments);
                    component.set("v.cmmtField",true);
                    var result = new Date();
                    var finalDate = $A.localizationService.formatDate(result, "MMMM dd yyyy");
                    console.log('prv cmmnt inside if--'+finalDate+'**'+component.get("v.myMap").name+' ** ' +component.get("v.myMap").comment);
                    var prvCoomt = component.get("v.myMap").comment;
                    var senderNameJs = component.get("v.myMap").senderName;
                    var receiverNameJs = component.get("v.myMap").name;
                    
                    if(prvCoomt == undefined){
                        prvCoomt = '';
                    }
                    var captureCommt = event.getParam('fields').Internal_Comments_Capture__c;
                    if(captureCommt == null){
                        captureCommt='';
                    }
                    //eventFields["Internal_Case_Comments__c"] =prvCoomt+'\n Logged on - '+finalDate +' - @'+ component.get("v.myMap").name +' - '+captureCommt;
                    eventFields["Internal_Case_Comments__c"] =prvCoomt+'\n Loogeed! @'+senderNameJs+ ' to @' + receiverNameJs + ' on '+ finalDate +' : '+captureCommt;
                    eventFields["AssignedUser__c"]=null;
                    eventFields["Internal_Comments_Capture__c"]='';
                    
                    component.find('accForm').submit(eventFields);
                    component.set("v.cmmtField",false);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Case Comment updated and the person is notified successfully',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                } else if (state === "ERROR") {
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
            $A.enqueueAction(action);
        }
    }
})