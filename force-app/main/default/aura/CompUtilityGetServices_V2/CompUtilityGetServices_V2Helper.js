({
    SUCCESS : 'success',
    ERROR : 'error',
    
    enableTransitionButton: function(component) {
        var checkboxes = component.find("DependentCheckbox");
        var chkflag = false;
        if (checkboxes.length == undefined) {
            if (checkboxes.get("v.value") == true) {
                chkflag = true;
            }
        } else {
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].get("v.value") == true) {
                    chkflag = true;
                }
            }
        }
        component.find("transitionbutton").set("v.disabled", !chkflag);
    },
    
    
   
    checkAllCheckboxes: function(component, event, helper, allCheckboxes) {
        var checkboxes = component.find("DependentCheckbox");
        var readOnlySelectedProd = component.get("v.readOnlySelectedProd");
        var readOnlyProd = component.get("v.readOnlyProd");
        if(checkboxes.length)
        {
            checkboxes.forEach(function(selectedCheckbox){
                if(readOnlySelectedProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
                {
                    if(readOnlyProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
                    {
                        selectedCheckbox.set("v.value",allCheckboxes);
                        helper.handleCheckTask(component, event, helper,selectedCheckbox);
                    }
                }
                
            });
        }
        else
        {
            checkboxes.set("v.value",allCheckboxes);
            this.handleCheckTask(component, event, helper,checkboxes);
        }
        
    },
    
    handleCheckTask : function(component, event, helper, selectedCheckbox) {
        var demoMap = component.get("v.sitesMap_V2");
            var adborId = component.get("v.adborid");
            var value = component.get("v.sitesValue_V2");
           
            demoMap[adborId] = value ;
            //alert(JSON.stringify(demoMap));
           
        if(selectedCheckbox.get("v.value") == true){
            
            var readOnlySelectedProd = component.get("v.readOnlySelectedProd");
            var selectedProd = component.get("v.selectedProd");
            var readOnlyProd = component.get("v.readOnlyProd");
            if(readOnlySelectedProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
            {
                if(readOnlyProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
                {
                    if(selectedProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
                    {   
                        selectedProd.push(selectedCheckbox.get("v.text"));
                        component.set("v.selectedProd",selectedProd);
                        //alert('Helper functioin selectedProd-->'+selectedProd);
                    }
                }
            }
            //this.enableTransitionButton(component);
        }
        else{
            var selectedProd = component.get("v.selectedProd");
            
            if(selectedProd.indexOf(selectedCheckbox.get("v.text"))>-1)
            {
                selectedProd.splice(selectedProd.indexOf(selectedCheckbox.get("v.text")),1);
                component.set("v.selectedProd",selectedProd);
            }
        }
    },
    
    transitionAllRecommended : function(component, event, helper){
       var action = component.get('c.transitionAllRecommended');
        var siteDTO = component.get("v.sites_new");
        var basketId = component.get('v.basketId');
        action.setParams({
            "serviceDTO_V2": JSON.stringify(siteDTO),
            "basketId": basketId
        });
        action.setCallback(this, function(response) {
            if(response.getStatus === 'SUCCESS'){
                console.log('Transistion all recommended done!!');
            }
            
        });
        $A.enqueueAction(action); 
    }, 
    
    navigateToRollCall: function(component, event, helper) {
        var urlToBasket = window.location.href;
        var occ = urlToBasket.indexOf('#');
        var actualURL = urlToBasket.substring(0, occ) + '#/sObject/' + component.get('v.basketId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": actualURL
        });
        urlEvent.fire();
        
    },
    showCustomToast : function(cmp, message, title, type){
        $A.createComponent(
            "c:customToast",
            {
                "type" : type,
                "message" : message,
                "title" : title
            },
            function(customComp, status, error){
                if(status === "SUCCESS"){
                    var body = cmp.find("container");
                    body.set("v.body", customComp);
                }
                else if(status === "INCOMPLETE"){
                    console.log("no resonse");
                }
                else if(status === "ERROR"){
                    console.log("error : " + error);
                }   
            }
        );
    },
    
})