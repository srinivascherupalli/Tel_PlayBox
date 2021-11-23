({
     
    recordSaved: function(component, event, helper) {
                console.log('saved!!');
    },
    doInit: function(component, event, helper) {
       var action = component.get("c.caseRecordId");
       //console.log('echo!!');   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
				component.set("v.recordtypeId",response.getReturnValue()); 
            }
            
        });
        $A.enqueueAction(action);
        
        var opptyId = component.get("v.recordId"); // Opportunity Id
        var errormap = component.get("c.getValidOpportunity");
        console.log('errormap!!'+errormap);
        var service = component.find("UtilityService");
		service.callServer(component, 
            "c.getValidOpportunity", {
                "oppId": opptyId 
        	}
        ).
        then($A.getCallback(function(result) {
            console.log('fetched data');
            console.log(result);
            console.log('result: ' + JSON.stringify(result));
            console.log(result);
            if (result.status == 'error') {
                component.set('v.showError', true);
                component.set('v.newCaseError', result.message);
                //alert(result['message']);
                console.log('ErrorMap: '+v.newCaseError);
                return '0';
            }else{
                //alert(result.recordtypeId);
                return result;
            }
        })).
         then($A.getCallback(function(result) {
             if(result!='0'){
               // component.set("v.recordtypeId",result.recordtypeId.substring(0,15)); 
                 return result;
             }
        })).then($A.getCallback(function(result) {
             if(result!='0'){
                 component.set('v.showError', false);
                  component.find("caseRecordCreator").getNewRecord(
            "Case", // sObject type (objectApiName)
            "v.recordtypeId", // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newCase");
                var error = component.get("v.newCaseError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                console.log("Record template initialized: " + rec.sobjectType);
            })
        );
             }
           

        })).catch(function(errors) {
            console.log('error');
            console.log(errors.message);
        });
    },

    handleSaveCase: function(component, event, helper) {
        console.log('inside');
        try{
           component.find('caseFieldComponent').submit();
            
             var showToast = $A.get("e.force:showToast"); 
        showToast.setParams({
            title : 'Success!',
            message: 'Case Submitted Successfully.',
            duration:' 4000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        showToast.fire(); 
            
             var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire(); 
           // recordSaved();
        }catch(error){
             var showToast = $A.get("e.force:showToast"); 
        showToast.setParams({
            title : 'Error!',
            message:'Case submittion failed.',
            messageTemplate: 'Mode is pester ,duration is 4sec and Message is overrriden',
            duration:' 4000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        showToast.fire();
        }
    },  
   recordSavedF: function(component, event, helper) {
        console.log('recordSavedF');
       
   },
   recordSaved: function(component, event, helper) {
        console.log('recordSavedF');
       var showToast = $A.get("e.force:showToast"); 
        showToast.setParams({ 
        'title' : 'Success!', 
        'message' : 'The record submitted sucessfully.' 
        }); 
        showToast.fire(); 
       
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire(); 
   },
     // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})