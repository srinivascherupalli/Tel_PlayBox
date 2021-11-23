({
    doInit: function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        setTimeout(function() {
            component.set("v.loadingSpinner", false);
        }, 2000);
        
        //component.set("v.selectedProd", component.get("v.mapProdIds")['ISDNBRA']);
        
    },      
    
    deSelectAllCheckboxes: function(component, event, helper) {
        helper.checkAllCheckboxes(component, event, helper,false);
        var msg = 'None of the Legacy Services recommended are currently selected for transition. You can continue to update your selections during the Commercial Configuration stage';
        helper.showCustomToast(component, msg, 'Finished', helper.SUCCESS); 
        component.set('v.showRecommneded',true);
        var checkIcon = component.find("iconChevron");
        
       
    },
    
    checkAllCheckBoxes: function(component, event, helper){
        helper.checkAllCheckboxes(component, event, helper,true); 
        component.set('v.showRecommneded',false);
    },      
    
    //This function will chk the association of products and select them accordingly.
    onCheckBoxClick: function(component, event, helper) {
        var selectedCheckbox = event.getSource();
        //console.log('selectedCheckbox-->>'+selectedCheckbox);
        helper.handleCheckTask(component, event, helper, selectedCheckbox);
    },
    
    getGetLegacyServices : function(component,event,helper){
        document.getElementById("GetServicesCmp").style.display = "block";
        var adborid = component.get('v.adborid');
        console.log('adborid-->>'+adborid);
        console.log('sitesMap_V2-->>'+JSON.stringify(component.get('v.sitesMap_V2')));
        if(adborid)
        { 
            var sitesMap_V2 = component.get('v.sitesMap_V2');
            var data = component.get('v.sites_new');
            if(sitesMap_V2 && sitesMap_V2[adborid])
            {
                
                var productList = component.get('v.sitesValue_V2.productList');
                component.set('v.noService',false);              
                component.set("v.sitesValue_V2",sitesMap_V2[adborid]);
                component.set('v.checkService',true);
                component.set("v.siteCount", data.serviceCount);
                
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
        console.log('basketStage-->'+basketStage);
        var getCheckBox = component.find("DependentCheckbox");
        if(basketStage != 'Commercial Configuration'){
            
            component.set("v.checkBasketStage", true);
            component.set("v.showPageButton", false);
        }
        else{
            component.set("v.checkBasketStage", false);
            component.set("v.showPageButton", true);
            
        } 
        
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
                        //entry.set("v.value",true);
                        entry.set("v.disabled",true);
                    }
                    else if(selectedProd.indexOf(entry.get("v.text")) > -1)
                    {
                        {
                            //entry.set("v.value",true);
                            //entry.set("v.disabled",true);
                        }
                        
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
                    ///getCheckBox.set("v.value",true);
                }
                if(basketStage != 'Commercial Configuration')
                {
                    getCheckBox.set("v.disabled",true);
                }
            }
        }
    },
    
    expandDetails: function(component, event, helper) {
        var selectedSection = event.currentTarget.name;
        console.log('selectedSection'+selectedSection);
        var checkIcon = component.find("iconChevron");
        checkIcon.forEach(function(entry){
            if(entry.get("v.alternativeText") == selectedSection)
            {
                
                if(entry.get("v.iconName")=="utility:chevrondown")
                {                  
                    if(document.getElementById(selectedSection)!=null){
                        document.getElementById(selectedSection).setAttribute("aria-expanded", false);
                        entry.set("v.iconName","utility:chevronright");
                    }
                }
                else
                {
                    if(document.getElementById(selectedSection)!=null){
                        document.getElementById(selectedSection).setAttribute("aria-expanded", true);
                        entry.set("v.iconName","utility:chevrondown");
                    }
                }
            }
        });
        event.preventDefault();
        
    },
    passSelectedProd : function(component, event, helper) {
        var siteMapv2 = component.get("v.sitesMap_V2");
        var adborId = component.get("v.adborid");
        var selectedProd = component.get("v.selectedProd");
        var getSelectedProd = $A.get("e.c:GetSelectedProduct");
        getSelectedProd.setParams({
            "selectedProduct"   : selectedProd,
            "sitesMap_V2" : siteMapv2
        });
        getSelectedProd.fire();
        
    },
    displayNone : function(component, event, helper) {
        document.getElementById("GetServicesCmp").style.display = "none";
    },
    transitionService : function(component, event, helper){
        helper.checkAllCheckboxes(component, event, helper,true);
        helper.transitionAllRecommended(component, event, helper);
        var msg = 'All '+ component.get("v.siteCount") +' Legacy Services recommended for transition are currently selected and will be saved. You can continue to update your selections during the Commercial Configuration stage.';
        helper.showCustomToast(component, msg, 'Finished', helper.SUCCESS); 
        
    }
    
})