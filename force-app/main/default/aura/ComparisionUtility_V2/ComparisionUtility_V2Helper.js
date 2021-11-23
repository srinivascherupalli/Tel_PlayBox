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
    getServices_V2: function(component) {
        var action = component.get('c.getCustomerServices_New');
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
                console.log('v.sites_new-->>'+JSON.stringify(data));
                component.set('v.sites_new', data);
                this.getServicesMap_V2(component);
                
            }
            else
            {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
        
    },
    getServicesMap_V2: function(component) {
        var action = component.get('c.getCustomerServicesMap_New');
        var serviceDTO =component.get("v.sites");
        action.setParams({
            "serviceDTO": JSON.stringify(serviceDTO)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            component.set('v.sitesMap_V2', mapData);
            this.getISDNBRAProduct_V2(component);
        });
        $A.enqueueAction(action);
        this.storeJSONdata(component);
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
    getISDNBRAProduct_V2: function(component) {
        var action = component.get('c.getISDNBRAProduct_V2');
        var serviceDTO = component.get("v.sites_new");
        var basketId = component.get("v.basketId");
        action.setParams({
            "basketId": basketId,
            "serviceDTO_V2": JSON.stringify(serviceDTO)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            component.set('v.mapProdIds_V2', mapData);
            if(component.get("v.ProdBasket.csordtelcoa__Basket_Stage__c") == 'Commercial Configuration')
            {
                component.set("V.selectedProd_V2",component.get("v.mapProdIds_V2")['ISDNBRA']);
            }
            component.set("V.readOnlyProd_V2",component.get("v.mapProdIds_V2")['NonISDNBRA']);
            component.set("V.readOnlySelectedProd_V2",component.get("v.mapProdIds_V2")['TransISDNBRAProd']);
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
            this.getServices_V2(component);
            
            if(data.csordtelcoa__Basket_Stage__c == 'Commercial Configuration')
            {
                component.set("v.displayTransBtn",true);
            }
        });
        $A.enqueueAction(action);
        
    },
    createLegecyServices: function(component, event, helper) {
        var sites = component.get("v.selectedSite");
        var sites = component.get("v.selectedSite_V2");
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
                component.set('v.selectedSite', data);
                this.createLegecyServices(component, event, helper);
            }
        });
        $A.enqueueAction(action);             
    },
    selectedDTO_V2: function(component, event, helper) {
        var objDTO = component.get('v.sites_new');
        var selectedProd = component.get("v.selectedProdFinal");        
        var action = component.get('c.getSelectedSite_V2');
        action.setParams({
            "selectedProd": selectedProd,
            "legacyService": JSON.stringify(objDTO)
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();            
            if(response.getState()=='SUCCESS'){
                component.set('v.selectedSite_V2', data);
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
    storeJSONdata : function(component) {
        var action = component.get('c.attachTransitionJSONData');
        var siteDTO = component.get("v.sites_new");
        console.log('siteDTO->>'+JSON.stringify(siteDTO));
        var pbsdMap = component.get("v.siteDTOMap");
        console.log('pbsMap-->>'+JSON.stringify(pbsdMap));
        //alert('helper called');
        action.setParams({
            "pbsdMap": pbsdMap,
            "ServiceDTO" : siteDTO
        });
        console.log('PCR stored');
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(response.getState() == 'SUCCESS'){
                component.set("v.storedJSON", data);
                console.log('PCR stored');
            }
            
        });
        $A.enqueueAction(action); 
    }
})