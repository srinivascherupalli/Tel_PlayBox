({
    
    getServices: function(component) {
        var action = component.get('c.getCustomerServices');
        var cidn = component.get("v.ProdBasket.csbb__Account__r.CIDN__c");
        var prodBasSites = component.get('v.siteDTOMap');
        action.setParams({
            "finCIDN": cidn,
            "prodBasSites": JSON.stringify(prodBasSites)
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data)
            {
                component.set('v.sites', data);
                this.getServicesMap(component);
            }
            else
            {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
        
    },
    getServicesMap: function(component) {
        var action = component.get('c.getCustomerServicesMap');
        var serviceDTO = component.get("v.sites");
        action.setParams({
            "serviceDTO": JSON.stringify(serviceDTO)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            component.set('v.sitesMap', mapData);
            this.getISDNBRAProduct(component);
        });
        $A.enqueueAction(action);
    },
    getISDNBRAProduct: function(component) {
        var action = component.get('c.getISDNBRAProduct');
        var serviceDTO = component.get("v.sites");
        var basketId = component.get("v.basketId");
        action.setParams({
            "basketId": basketId,
            "serviceDTO": JSON.stringify(serviceDTO)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            component.set('v.mapProdIds', mapData);
            if(component.get("v.ProdBasket.csordtelcoa__Basket_Stage__c") == 'Commercial Configuration')
            {
                component.set("V.selectedProd",component.get("v.mapProdIds")['ISDNBRA']);
            }
            component.set("V.readOnlyProd",component.get("v.mapProdIds")['NonISDNBRA']);
            component.set("V.readOnlySelectedProd",component.get("v.mapProdIds")['TransISDNBRAProd']);
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
        
    },
    getBasket : function(component) {
        var action = component.get('c.getBasket');
        var basketId = component.get("v.basketId");
        action.setParams({
            "basketId": basketId
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set('v.ProdBasket', data);
            this.getServices(component);
            if(data.csordtelcoa__Basket_Stage__c == 'Commercial Configuration')
            {
                component.set("v.displayTransBtn",true);
            }
        });
        $A.enqueueAction(action);
        
    },
    /*getCIDN : function(component) {
        var action = component.get('c.getCIDN');
        var basketId = component.get("v.basketId");
        action.setParams({
            "basketId": basketId
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set('v.cidn', data);
        });
        $A.enqueueAction(action);
        
    },
    getBasketStage : function(component) {
        var action = component.get('c.getBasketStage');
        var basketId = component.get("v.basketId");
        action.setParams({
            "basketId": basketId
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set('v.basketStage', data);
            if(data == 'Commercial Configuration')
            {
                component.set("v.displayTransBtn",true);
            }
        });
        $A.enqueueAction(action);
        
    },*/
    createLegecyServices: function(component, event, helper) {
        var sites = component.get("v.selectedSite");
        var action = component.get('c.redirectToBasket');
        action.setParams({
            "legacyProd": JSON.stringify(sites),
            "basketID": component.get('v.basketId')
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            // this data will be string url to which we have to navigate
            if (data != null && response.getState()) {
                var urlToBasket = window.location.href;
                var occ = urlToBasket.indexOf('#');
                var actualURL = urlToBasket.substring(0, occ) + '#/sObject' + data;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": actualURL
                });
                urlEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    selectedDTO: function(component, event, helper) {
        var objDTO = component.get('v.sites');
        var selectedProd = component.get("v.selectedProdFinal");        
        var action = component.get('c.getSelectedSite');
        action.setParams({
            "selectedProd": selectedProd,
            "legacyService": JSON.stringify(objDTO)
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();            
            if(response.getState()=='SUCCESS'){
                console.log('data:'+JSON.stringify(data));
                component.set('v.selectedSite', data);
                this.createLegecyServices(component, event, helper);
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
})