({
    doInit : function(component, event, helper) {
        //Getting the Frame Agreement Id passed to this Component from the VF page.  
        var recordId = component.get("v.FrameId");
        console.log(recordId);
        component.set("v.FrameId",recordId);
        //Getting the Opportunity Id passed to this Component from the VF page.
        var oppId = component.get("v.OpportunityId");
        console.log(oppId);
        component.set("v.OpportunityId",oppId); 
        // Getting the Case RecordType Id.   
        helper.fetchRecordId(component,event,helper);       
        //EDGE : 200438 fetching queue details
        helper.fetchQueueDetails(component,event,helper);
        //End EDGE : 200438
        //for EDGE-212164
		helper.createdApprovalCase(component,event,helper);
    }, 
    
    onSubmit : function(component, event, helper) {
        
    },
    onCancel : function(component, event, helper) { 
        
    }, 
    handleSuccess : function(component, event, helper) { 
        console.log('inside handleSuccess');
        //Getting all the fields of the Frame Agreement(Optional)
        helper.insertDeal(component);
        if(component.get("v.Status") == true){
            console.log('Approval Case Created Successfully!!');
        }
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        const fields = event.getParam('fields');
        if(fields.Description || fields.Description == '' || fields.Description ==null){            
            if (event.getParam('fields') !== null ||  event.getParam('fields') !== ''){	
                //Putting a check for the length of the description field to be greater than 50 characters.
                if((fields.Description != '' && fields.Description !=null) && fields.Description.length > 50 ){
                    component.set("v.showSpinner",true);
                    console.log('inside handleSubmit');
                    fields.OpportunityId__c = component.get("v.OpportunityId");
                    fields.Product_ent_pricing__c = component.get("v.familyLevel");
                    if(component.get("v.queueId")!='' && component.get("v.queueId")!=null) {
                       fields.OwnerId = component.get("v.queueId"); 
                    }

                    //Added EDGE-200440, populate the case data inside related list of frame aggrement.
                    fields.FrameAgreement__c = component.get("v.FrameId");
                    //End EDGE-200440
                    console.log(fields.OpportunityId__c);
                    console.log(fields.Product_ent_pricing__c);
                    console.log(fields.OpportunityId__c);
                    fields.Subject='Frame Agreement Pricing Approval';
                    component.find('myRecordForm').submit(fields);
                }
                else {
                    var state = 'WARNING'
                    console.log('inside handleSubmit ELSE');
                    var message = {
                        'displayMsg':'Please ensure that the Description field has more than 50 characters',
                        'type' : state
                    }
                    var vfOrigin = helper.getVfOrigin(component);
                    window.postMessage(message, vfOrigin); 
                    
                } 
            }
        }
    }
})