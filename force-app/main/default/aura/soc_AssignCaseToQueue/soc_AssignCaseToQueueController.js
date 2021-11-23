({
	doInit : function(component, event, helper) {       
        var recId=component.get('v.recordId');
        var currentUser=$A.get("$SObjectType.CurrentUser.Id"); 
        var action = component.get("c.checkVisibile");        
        action.setParams({ caseId : recId});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {
                var data=response.getReturnValue(); 
                var caseData=data['case'];
                var profileName=data['profileName'];
                console.log(data);
                var currentUserId = currentUser.length == 18 ? currentUser.substring(0,15) : currentUser;
                
                if(caseData.OwnerId.startsWith("00G")){                    
                      component.set('v.visible',false);
                    console.log('Button Not visible : Case Owner is Group');
                }
                else if(currentUserId !=caseData.OwnerId.substring(0,15)){
                     component.set('v.visible',false);
                     console.log('Button Not visible : Logged in User is not Owner');
                }
                else if(currentUserId == caseData.OwnerId.substring(0,15) && profileName=='SFD Agent'){
                     component.set('v.visible',false);
                     console.log('Button Not visible : Logged in User is Concierge');
                }
                else if((caseData.RecordType.DeveloperName=='Order_request' || caseData.RecordType.DeveloperName=='soc_Support_Request') && (caseData.Status =='Closed' || caseData.Requestor__c!=caseData.OwnerId)){
                    component.set('v.visible',false);
                    console.log('Button Not visible : Either Stage is no Request Review Or Rqustor Owner Do not match');
                }
                else if((caseData.RecordType.DeveloperName=='soc_Support_Request' || caseData.RecordType.DeveloperName=='soc_Support_Request_without_SOC' ) &&  caseData.Requestor__c!=caseData.OwnerId){
                    component.set('v.visible',false);
                }
      
            }    
        });        
        $A.enqueueAction(action);
	},
        
    assignToQueue : function(component, event, helper) {
        component.set('v.showSpinner',true);
        console.log('DISPLAY RECORD ID :');
        console.log(component.get('v.recordId'));	
        var recId=component.get('v.recordId');
        var action = component.get("c.assignCase");
        action.setParams({ caseId : recId});
        action.setCallback(this, function(response) {
            component.set('v.showSpinner',false);
        	var state = response.getState();
            if (state === "SUCCESS") {
                console.log('MY OUTPUT >>>>> shmk');
                console.log(response.getReturnValue());
                var data=response.getReturnValue();
                var result=data['status'];
                if (data['status'] == 'pass'){
                   	window.location.reload( );
                   	 //$A.get('e.force:refreshView').fire();      

                	helper.showSuccessToast(component, event, helper);                    
                }
                else if (data['status'] == 'fail')  {                                  	                                	                	
                    helper.showErrorToast(component, event, helper,data['response'].join());
                }    
            }    
        });        
        $A.enqueueAction(action);
	}    
})