({
    //EDGE-165481,171843. Kalashree Borgaonkar. Conditionally retrieve Port out Reversal Radio Button
    retrievePortOutReversalBtn : function(component, event) {
        var basketId = component.get("v.basketId");
        var action = component.get("c.getPortOutReversalRadio");
        action.setParams({
            "basketID": basketId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data port out reversal',data); 
                if(data==true){
                    component.set('v.searchoptions', [
                        {'label': 'Add New Numbers', 'value': 'addnewnumber'},
                        {'label': 'Port In Numbers', 'value': 'portin'},
                        {'label': 'Transition Numbers', 'value': 'transitionnumber'},
                        {'label': 'Port Out Reversal', 'value': 'portOutReversal'}
                    ]);
                }
                else{
                    component.set('v.searchoptions', [
                        {'label': 'Add New Numbers', 'value': 'addnewnumber'},
                        {'label': 'Port In Numbers', 'value': 'portin'},
                        {'label': 'Transition Numbers', 'value': 'transitionnumber'}
                    ]);
                }
                this.setSearchOption(component, event);
            }
            else{
                var errorMsg = action.getError()[0].message;
                console.log("errorMsg: ",errorMsg);
                this.showCustomToast(component, errorMsg,"Error","error");
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE-203930
    setSearchOption: function(component, event){
        if(component.get("v.profileName") == 'Migration BOH user'){
            var colList = component.get('v.searchoptions');
            console.log('colName>>>');
            for(var i=0 ; i < colList.length;i++){
            console.log(colList[i]);
            if(colList[i].value == 'transitionnumber'){
                colList[i].label = 'Migration Numbers';
            }
         }
         component.set('v.searchoptions',colList);
        }
    },
    //EDGE-185029. Kalashree Borgaonkar. Conditionally retrieve Radio Buttons
    retrieveRadioBtnOptions : function(component, event) {
        var basketId = component.get("v.basketId");
        var action = component.get("c.getRadioOptions");
        action.setParams({
            "basketID": basketId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data getRadioOptions',data);
                var optionList = [
                        {'label': 'Add New Numbers', 'value': 'addnewnumber'},
                        {'label': 'Port In Numbers', 'value': 'portin'},
                        {'label': 'Transition Numbers', 'value': 'transitionnumber'}  
                    ];
                if(data!=null && data.showPortOutReversal==true){
                    optionList.push({'label': 'Port Out Reversal', 'value': 'portOutReversal'});
                }
                if(data!=null && data.showReactiveServices==true){
                        optionList.push({'label': 'Reactivate Services', 'value': 'reactiveServices'});
                }
                component.set('v.searchoptions',optionList);
                this.setSearchOption(component, event);
            }
            else{
                var errorMsg = action.getError()[0].message;
                console.log("errorMsg: ",errorMsg);
                this.showCustomToast(component, errorMsg,"Error","error");
            }
        });
        $A.enqueueAction(action);
    },
     getProfileId : function(component, event) {
        var action = component.get("c.getProfileInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state====='+state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.profileName",data);
                console.log('data>>>>>'+data);                
            }
            else{
                var errorMsg = action.getError()[0].message;
                console.log("errorMsg: ",errorMsg);
                this.showCustomToast(component, errorMsg,"Error","error");
            }
        });
        $A.enqueueAction(action);
    },
    
    showCustomToast: function(cmp, message, title, type) {
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                message: message,
                title: title
            },
            function(customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");                    
                    body.set("v.body", customComp);
                }
            }
        );
    },
    
})