({
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
        if(selectedCheckbox.get("v.value") == true){
            var readOnlySelectedProd = component.get("v.readOnlySelectedProd");
            var selectedProd = component.get("v.selectedProd");
            var readOnlyProd = component.get("v.readOnlyProd");
            //alert(selectedProd);
            if(readOnlySelectedProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
            {
                if(readOnlyProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
                {
                    if(selectedProd.indexOf(selectedCheckbox.get("v.text")) ==-1)
                    {   
                        selectedProd.push(selectedCheckbox.get("v.text"));
                        component.set("v.selectedProd",selectedProd);
                    }
                }
            }
            //this.enableTransitionButton(component);
        }
        else{
            var selectedProd = component.get("v.selectedProd");
            //alert(selectedProd);
            if(selectedProd.indexOf(selectedCheckbox.get("v.text"))>-1)
            {
                selectedProd.splice(selectedProd.indexOf(selectedCheckbox.get("v.text")),1);
                component.set("v.selectedProd",selectedProd);
            }
        }
    },
    
})