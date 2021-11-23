/*
===============================================================================================================================
Component Name : CompUtilityProdBasket
Developer Name : Ravi
COntroller Class : CompUtilityReplicatorManager
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
({
    helperMethod : function() {
        
    },
    fireGetServicesEvent_1 : function(component, event) {
        var preSelectedSite = document.querySelectorAll('.blue-bg');
        if(preSelectedSite.length > 0)
        {
            preSelectedSite[0].classList.remove('blue-bg');
            preSelectedSite[0].childNodes[1].classList.add('display-none');
        }
        var selectedDiv = event.target.getAttribute("data-id");
        var iconChevron = component.find("iconChevron");
        if(iconChevron)
        {
            if(iconChevron.length)
            {
                iconChevron.forEach(function(entry){
                    if(entry.get("v.alternativeText") == selectedDiv)
                    {
                        entry.set("v.iconName","utility:chevrondown");
                    }
                    else{
                        entry.set("v.iconName","utility:chevronright");
                    }
                })
            }
            else
            {
                if(iconChevron.get("v.alternativeText") == selectedDiv)
                {
                    iconChevron.set("v.iconName","utility:chevrondown");
                }
                else{
                    iconChevron.set("v.iconName","utility:chevronright");
                }
            }
        }
        //for(var i =0; i<preSelectedSite.length; i++)
        //{
        //   preSelectedSite[i].classList.remove('blue-bg');
        // }
        event.currentTarget.classList.add('blue-bg');
        event.currentTarget.childNodes[1].classList.remove('display-none');
        //$A.util.addClass(event.currentTarget, 'blue-bg');
        var siteDTOMap = component.get("v.siteDTOMap");
        var siteDetail = event.currentTarget.getAttribute("data-id");
        var adborid = siteDetail.split("-");
        var siteName = siteDetail.replace(adborid[0]+"-", "");
        var oldConfigId = siteDTOMap[adborid[0]].oldConfigId;
        var getSerEvt = $A.get("e.c:GetServicesEvent");
        getSerEvt.setParams({
            "adborid" : adborid[0],
            "siteName" : siteName,
            "oldConfigId" : oldConfigId
        });
        getSerEvt.fire();
    },
    fireGetServicesEvent : function(component, event) {
        var preSelectedSite = document.querySelectorAll('.theClass');
        if(preSelectedSite.length > 0)
        {
            preSelectedSite[0].classList.remove('blue-bg');
            preSelectedSite[0].childNodes[1].classList.add('display-none');
        }
        //var selectedDiv = event.target.getAttribute("data-id");
        var iconChevron = component.find("iconChevron");
        if(iconChevron)
        {
            if(iconChevron.length)
            {
                iconChevron.forEach(function(entry){
                    if(entry.get("v.alternativeText") == selectedDiv)
                    {
                        entry.set("v.iconName","utility:chevrondown");
                    }
                    else{
                        entry.set("v.iconName","utility:chevronright");
                    }
                })
            }
            else
            {
                if(iconChevron.get("v.alternativeText") == selectedDiv)
                {
                    iconChevron.set("v.iconName","utility:chevrondown");
                }
                else{
                    iconChevron.set("v.iconName","utility:chevronright");
                }
            }
        }
        //for(var i =0; i<preSelectedSite.length; i++)
        //{
        //   preSelectedSite[i].classList.remove('blue-bg');
        // }
        alert(preSelectedSite[0]);
        preSelectedSite[0].classList.add('blue-bg');
        event.currentTarget.childNodes[1].classList.remove('display-none');
        //$A.util.addClass(event.currentTarget, 'blue-bg');
        var siteDTOMap = component.get("v.siteDTOMap");
        var siteDetail = event.currentTarget.getAttribute("data-id");
        var adborid = siteDetail.split("-");
        var siteName = siteDetail.replace(adborid[0]+"-", "");
        var oldConfigId = siteDTOMap[adborid[0]].oldConfigId;
        var getSerEvt = $A.get("e.c:GetServicesEvent");
        getSerEvt.setParams({
            "adborid" : adborid[0],
            "siteName" : siteName,
            "oldConfigId" : oldConfigId,
            "callFrom" : "fixSheet"
        });
        getSerEvt.fire();
    },
    //-- Convert list to map --
    getServicesMap_V2: function(component,event, data, adborid) {
        var sitesMap_V2Temp = component.get('v.sitesMap_V2'); 
       // alert('*****>>Helper_>'+JSON.stringify(sitesMap_V2Temp));
        var action = component.get('c.getCustomerServicesMap_New');
        var serviceDTO = data;
        action.setParams({
            "serviceDTO_V2": JSON.stringify(serviceDTO),
            "sitesMap_v2Custom" : sitesMap_V2Temp
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            if(sitesMap_V2Temp!= null && sitesMap_V2Temp && sitesMap_V2Temp[adborid] && sitesMap_V2Temp[adborid]!='undefined')
                //  if(mapData!= null && mapData && mapData[adborid] && mapData[adborid]!='undefined')
            {
                //  component.set('v.sitesMap_V2', mapData); 
                //  alert('*****>>Helper_IF>'+JSON.stringify(mapData));
            }
            else{
                component.set('v.sitesMap_V2', mapData);  
                // alert('*****>>Helper_ELSE>'+JSON.stringify(mapData));
            }
            
        });
        $A.enqueueAction(action);
        
    },
})