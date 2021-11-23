({
    onTabClosed: function(component, event, helper) {
        
        var channel = component.get('v.transcriptRecord.Button_Name__c');
        console.log('channel::'+ channel);
        
        var ClassificationChannel = $A.get("$Label.c.Chat_Channel_ccd");
        console.log('ClassificationChannel:::'+ ClassificationChannel);
        
        var isFound = false;
        var ClassificationArr = []; 
        var ButtonName = 'Chat_Telstra Connect Faults Onshore';
        ClassificationArr= ClassificationChannel.split(',');
        for(var classChannel in ClassificationArr) {
        
            if(channel == ClassificationArr[classChannel]) {
                
                isFound = true;
            }
        }
        if(isFound) {
           	
            var action = component.get("c.shareTranscriptToQueue");
            action.setParams({
                'transcriptId': component.get('v.transcriptRecord.Id'),
				'ButtonName': channel
            });
            action.setCallback(this, function(a){
                var state = a.getState(); // get the response state
                console.log('state::', state);
                
                if(state == 'SUCCESS') {
                    //component.set('v.sObjList', a.getReturnValue());
                } else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                this.showToast(errors[0].message);
                            }
                        } else {
                            this.showToast('Unknown Error');
                        }
                    }
            });
            $A.enqueueAction(action);
      
            var chatCategory = component.get('v.transcriptRecord.Chat_Category__c');
            console.log('chatCategory ::', chatCategory);
            if(chatCategory == undefined) {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: $A.get("$Label.c.ccd_chat_classification"),
                    duration: '5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
            }
        }
        
    },
})