({
    init : function (component) {
        
        console.log('contact ::', component.get('v.recordId'));
        
        var action = component.get('c.isOrphanTranscript'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "recordId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var returnResult = a.getReturnValue();
                var transcript = returnResult.chatTranscript;
                var domainName = returnResult.domainName != null ? returnResult.domainName : '';
                var recordTypeId = returnResult.recordTypeId != null ? returnResult.recordTypeId : '';
                if(transcript.LeadId != null){
                	
                    component.set('v.isLeadAssigned', true);
                } if(transcript.ContactId != null) {
                    
                    component.set('v.isOrphan', false);
                    var flow = component.find("flowData");
                    
                    if(flow) {
                        
                        var transcriptId = transcript.Id != null ? transcript.Id : '';
                        var accountName = transcript.Contact.AccountId != null ? transcript.Contact.Account.Name : '';
                        var accountId = transcript.Contact.AccountId != null ? transcript.Contact.AccountId : '';
                        var Seniority = transcript.Contact.Seniority_Level__c != null ? transcript.Contact.Seniority_Level__c : '';
                        var FirstName = transcript.Contact.FirstName != null ? transcript.Contact.FirstName : '';
                        var LastName = transcript.Contact.LastName != null ? transcript.Contact.LastName : '';
                        var Email = transcript.Contact.Email != null ? transcript.Contact.Email : '';
                        console.log('transcript :::', transcript);
                        var inputVariables = [
                            { name : "AccountName", type : "String", value: accountName}, 
                            { name : "ContactEmail", type : "String", value: Email},
                            { name : "ContactFirstName", type : "String", value: FirstName},
                            { name : "ContactLastName", type : "String", value: LastName},
                            { name : "LeadSource", type : "String", value: 'TCOM'},
                            { name : "Seniority", type : "String", value: Seniority},
                            { name : "transcriptId", type : "String", value: transcriptId},
                            { name : "LeadRecordType", type : "String", value: recordTypeId},
                            { name : "AccountId", type : "String", value: accountId},
                            { name : "Domain", type : "String", value: domainName}
                        ];
                        console.log('inputVariables ::', inputVariables);
                        flow.startFlow("BCS_Lead_Gen", inputVariables);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    statusChange : function (cmp, event) {
        if (event.getParam('status') === "FINISHED") {
        	
            $A.get('e.force:refreshView').fire();
        }
    }
})