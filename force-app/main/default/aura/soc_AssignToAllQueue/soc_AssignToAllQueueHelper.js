({
    initialize : function(component, event, helper) {
      component.set('v.spinner',true);
        var recId=component.get('v.recordId');
        var action = component.get("c.initialize");        
        action.setParams({ caseId : recId});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner',false);
                var data=response.getReturnValue(); 
                var caseData=data['case'];
                var profileName=data['profileName'];
                console.log('######soc_AssignToAllQueue##########');
                console.log(data);
                component.set('v.recordTypeDevName',caseData.RecordType.DeveloperName);
                component.set('v.profileName',profileName);
                component.set('v.offshoreRestricted',caseData.soc_SFD_Offshore_Restricted__c);
                // Modified P2OB-12557 added isButtonVisible, isQueueOne properties and moved condition into seprate helper method
                component.set('v.isButtonVisible', helper.showButtons(profileName));
                component.set('v.isQueueOne', helper.showQueueOne(caseData.RecordType.DeveloperName));
            }    
        });        
        $A.enqueueAction(action);
    },
    
    
	showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case Assigned",
            "type":'success',
            "message": "Owner has been updated successfully."
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event, helper,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',            
            message: 'Mandatory Fields: '+msg,
            type: 'error',
            mode:'sticky'
        });
        toastEvent.fire();
    },
    
    fetchClonedCaseRecord : function(component, event, helper) {        
        var recordId = component.get('v.recordId');        
        var action = component.get("c.fetchClonedCase");
        action.setParams({ Id : recordId}); 
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") { 
                console.log('Cloned Case >>>>>>>>>>>');
                console.log(response.getReturnValue());
                var data=response.getReturnValue();
                component.set('v.parentRecord',data['case']);
                var cliSizeOne = data['cliSizeOne'];
                //Pravin S :: EDGE-68187 :: 19-MAR-2018
                console.log('cliSizeOne==>'+cliSizeOne);
                component.set("v.isOpen", true);                
                component.set('v.cliSizeOne',cliSizeOne);
                if(!cliSizeOne){
                	component.set('v.pageType','datatable');
                }
                else{
                    component.set('v.pageType','caseEditForm');
                    var caseLineItems = data['caseLineItems'];
                    var linearData= helper.normalizeData(caseLineItems);
                    console.log(linearData);
                    component.set('v.selectedData',linearData);
                }
            }                     
        });
        $A.enqueueAction(action);		
	},
    
    normalizeData : function(data) {
        var linearData=[];
        for(var i=0;i<data.length;i++){
            var linearRecord={'recordId':data[i].Id,
                              'OrderNumber':data[i].soc_order_number__c,
                             'productName':data[i].soc_ProductId__r.Name };
            linearData.push(linearRecord);
        }
        return linearData;        
    },

    showButtons: function(profileName) {
        return profileName === 'System Administrator' || 
               profileName === 'Service Enterprise – B2B' ||
               profileName === 'SFD Agent';
    },

    showQueueOne: function(developerName) {
        return developerName === 'Order_request' || 
               developerName === 'soc_SFD_Product' ||
               developerName === 'SFD_Request';
    }
})