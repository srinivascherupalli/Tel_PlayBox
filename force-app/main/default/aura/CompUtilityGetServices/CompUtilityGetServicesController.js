({
    doInit: function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        setTimeout(function() {
            component.set("v.loadingSpinner", false);
        }, 2000);
        //component.set("v.selectedProd", component.get("v.mapProdIds")['ISDNBRA']);
        
    },
    
    selectAllCheckboxes: function(component, event, helper) {
        helper.checkAllCheckboxes(component, event, helper,true);
    },
    deSelectAllCheckboxes: function(component, event, helper) {
        helper.checkAllCheckboxes(component, event, helper,false);
    },
    
    
    
    //This function will chk the association of products and select them accordingly.
    onCheckBoxClick: function(component, event, helper) {
        var selectedCheckbox = event.getSource();
        helper.handleCheckTask(component, event, helper,selectedCheckbox);
    },
    
    getGetLegacyServices : function(component,event,helper){
        document.getElementById("GetServicesCmp").style.display = "block";
        var adborid = component.get('v.adborid');
        if(adborid)
        {
            var siteMap = component.get('v.sitesMap');
            if(siteMap && siteMap[adborid])
            {
                component.set('v.noService',false);
                component.set("v.sitesValue",siteMap[adborid]);
                component.set('v.checkService',true);
            }
            else
            {
                component.set('v.noService',true);
                component.set('v.checkService',false);
            }
        }
    },
    
    onRender : function(component,event,helper)
    {
        var basketStage = component.get("v.ProdBasket.csordtelcoa__Basket_Stage__c");
        var getCheckBox = component.find("DependentCheckbox");
        if(getCheckBox)
        {
            var readOnlySelectedProd = component.get("v.readOnlySelectedProd");
            var selectedProd = component.get("v.selectedProd");
            var readOnlyProd = component.get("v.readOnlyProd");
            if(getCheckBox.length)
            {
                getCheckBox.forEach(function(entry) {
                    if(readOnlySelectedProd.indexOf(entry.get("v.text")) > -1)
                    {
                        entry.set("v.value",true);
                        entry.set("v.disabled",true);
                    }
                    else if(selectedProd.indexOf(entry.get("v.text")) > -1)
                    {
                        entry.set("v.value",true);
                    }
                        else if(readOnlyProd.indexOf(entry.get("v.text")) > -1)
                        {
                            entry.set("v.disabled",true);
                        }
                    if(basketStage != 'Commercial Configuration')
                    {
                        entry.set("v.disabled",true);
                    }
                });
            }
            else{
                if(selectedProd.indexOf(getCheckBox.get("v.text")) > -1)
                {
                    getCheckBox.set("v.value",true);
                }
                if(basketStage != 'Commercial Configuration')
                {
                    getCheckBox.set("v.disabled",true);
                }
            }
        }
        var checkIcon = component.find("iconChevron");
        if(checkIcon)
        {
            if(checkIcon.length)
            {
                checkIcon.forEach(function(entry){
                    if(entry.get("v.alternativeText").includes("ISDN-BRA") || entry.get("v.alternativeText").includes("Products"))
                    {
                        document.getElementById(entry.get("v.alternativeText")).setAttribute("aria-expanded", true);
                        entry.set("v.iconName","utility:chevrondown");
                    }
                    else if(entry.get("v.alternativeText").includes("PSTN"))
                    {
                        document.getElementById(entry.get("v.alternativeText")).setAttribute("aria-expanded", false);
                        entry.set("v.iconName","utility:chevronright");
                    }
                    
                })
            }
        }
    },
    
    expandDetails: function(component, event, helper) {
        var selectedSection = event.currentTarget.name;
        //var selectedSection = event.getSource().get("v.name");
        var checkIcon = component.find("iconChevron");
        checkIcon.forEach(function(entry){
            if(entry.get("v.alternativeText") == selectedSection)
            {
                if(entry.get("v.iconName")=="utility:chevrondown")
                {
                    document.getElementById(selectedSection).setAttribute("aria-expanded", false);
                    entry.set("v.iconName","utility:chevronright");
                }
                else
                {
                    document.getElementById(selectedSection).setAttribute("aria-expanded", true);
                    entry.set("v.iconName","utility:chevrondown");
                }
            }
        })
        
    },
    passSelectedProd : function(component, event, helper) {
        var selectedProd = component.get("v.selectedProd");
        var getSelectedProd = $A.get("e.c:GetSelectedProduct");
        getSelectedProd.setParams({
            "selectedProduct" :selectedProd });
        getSelectedProd.fire();
        
    },
    displayNone : function(component, event, helper) {
		document.getElementById("GetServicesCmp").style.display = "none";
	},
    
})