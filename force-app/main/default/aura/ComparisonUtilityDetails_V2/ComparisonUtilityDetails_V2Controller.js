/*
===============================================================================================================================
Component Name : ComparisonUtilityDetails_v2
Developer Name : Ravi
COntroller Class : CompUtilityReplicatorManager
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
({
    doInit : function(component, event, helper) {
        console.log('comparisonDetails:::'+component.get("v.isCidnHierarchy"));
        //console.log('Inside response prdbasket');
        //helper.fireGetServicesEvent(component, event);
        
        //alert(document.getElementById('site0'));  
        /*var checkFirstRun = true; 
       setInterval(function(){ 
           if(checkFirstRun === true){
               var dom = document.getElementById('legacyDiv');
              
               dom.click();
               checkFirstRun = false;
           }
           
         },12000);*/
        
    },
    displayGetService : function(component, event, helper) {
        helper.removeClass(component, event, helper);
        helper.addClass(component, event, helper);
        var compEvent = component.getEvent("getTabName");
        compEvent.setParams({
            "tabName" : "GetService" 
        });
        compEvent.fire();
        if(component.get("v.adborid"))
        {
            var childCmpGetService = component.find("GetServiceComp");
            childCmpGetService.getGetLegacyServices(component.get("v.sites_new"));
            var childCmpExistSub = component.find("GetExistingSubscription");
            childCmpExistSub.displayNone();
        }
    },
    displayExistSub : function(component, event, helper) {
        helper.removeClass(component, event, helper);
        helper.addClass(component, event, helper);
        var compEvent = component.getEvent("getTabName");
        compEvent.setParams({
            "tabName" : "ExistingSubscription" 
        });
        compEvent.fire();
        if(component.get("v.adborid"))
        {
            var childCmpExistSub = component.find("GetExistingSubscription");
            childCmpExistSub.getExistSub();
            var childCmpGetService = component.find("GetServiceComp");
            childCmpGetService.displayNone();
        }
    },
    displayGetServiceMobileLegacy: function(component, event, helper) {
        var tab1 = component.find('legacyDiv');       
        var TabOnedata = component.find('tab-default-1');
        
        var tab2 = component.find('existingSubscription');
        var TabTwoData = component.find('tab-default-2');
        
        //show and Active Legacy tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');
    },
    displayGetServiceMobileExistingSub: function(component, event, helper) {
        var tab1 = component.find('legacyDiv');       
        var TabOnedata = component.find('tab-default-1');
        
        var tab2 = component.find('existingSubscription');
        var TabTwoData = component.find('tab-default-2');
        
        //show and Active Legacy tab
        $A.util.addClass(tab2, 'slds-active');
        $A.util.addClass(TabTwoData, 'slds-show');
        $A.util.removeClass(TabTwoData, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');
    },
    handleGetServicesEvent	: function(component,event,helper){
        // alert('********Evt>'+JSON.stringify(event.getParam("callFrom")));
        component.set("v.callFrom",event.getParam("callFrom"));       
        /*  component.set("v.oldConfigId", event.getParam("oldConfigId"));
        component.set("v.adborid", event.getParam("adborid"));
        component.set('v.siteName',event.getParam("siteName"));
        component.set("v.sitesMap_V2", event.getParam("sitesMap_V2"));
        component.set("v.sites_new",event.getParam("selectedSiteResponse")); */
        
        if(event.getParam("callFrom") == 'fixSheet'){
            component.set("v.oldConfigId", event.getParam("oldConfigId"));
            component.set("v.adborid", event.getParam("adborid"));
            component.set('v.siteName',event.getParam("siteName"));
            component.set("v.sitesMap_V2", event.getParam("sitesMap_V2"));
            component.set("v.sites_new",event.getParam("selectedSiteResponse"));
            
            let childCmpGetService = component.find("GetServiceComp");
            childCmpGetService.displayNone();
            let childCmpExistSub = component.find("GetExistingSubscription");
            childCmpExistSub.displayNone();   // temporary fix 
        }
        if(event.getParam("callFrom") == 'Mobile'){
            let childCmpGetServiceMobile = component.find("GetServiceCompMobile");
            childCmpGetServiceMobile.getSiteAgnosticService(event.getParam("CIDN_String"),event.getParam("basketId"),event.getParam("mobileTransitionDataEvt"),event.getParam("selectedMobileRecrodEvt"),event.getParam("ngUcTransitionDataEvt"), event.getParam("selectedNgUcRecrodEvt"), component.get("v.sioConfigMode"));//Added sioConfigMode for DIGI-1681
           // alert('********EvtMob>'+JSON.stringify(event.getParam("ngUcTransitionDataEvt")));
        }
        if(event.getParam("callFrom") == 'ngUC'){
            let childCmpGetServiceMobile = component.find("GetServiceCompMobilengUC");
            childCmpGetServiceMobile.getSiteAgnosticService(event.getParam("CIDN_String"),event.getParam("basketId"),event.getParam("mobileTransitionDataEvt"),event.getParam("selectedMobileRecrodEvt"), event.getParam("ngUcTransitionDataEvt"), event.getParam("selectedNgUcRecrodEvt"), component.get("v.sioConfigMode"));//Added sioConfigMode for DIGI-1681
           // alert('********EvtNgUc>'+JSON.stringify(event.getParam("mobileTransitionDataEvt")));
        }
        
    },
    
})