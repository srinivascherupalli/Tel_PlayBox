({ 
    // Fetch sites from replicator
	doInit : function(component, event, helper) {
        //get loading spinner before data gets loaded
        component.set("v.loadingSpinner", true);
        setTimeout(function(){
            component.set("v.loadingSpinner", false);
       }, 2000);
        helper.getSites(component);
	}, 

    // Get adbor_id of selected site
    onSelectSite: function(component, event, helper){
		helper.enableTransitionButton(component);
        var id_str = event.currentTarget.dataset.value;
        var index = event.currentTarget.dataset.record;
        var siteName = component.get("v.sites.Site")[index].concatenatedAddress;
        //passing single idborid to get services call
        component.set('v.selectedAdborId',id_str);
        component.set('v.siteName',siteName);
        //passing array of idborids to get services call
        var adborIds = component.get('v.selectedAdborIdArray');
        var siteNameArray = component.get('v.siteNameArray');
        
        if(adborIds.includes(id_str)){
            var index = adborIds.indexOf(id_str);
            if (index > -1) {
    			adborIds.splice(index, 1);
			}
        }else{
        adborIds.push(id_str);
        }
        
        var siteNameWithId = id_str+'#'+siteName;
        if(siteNameArray.includes(siteNameWithId)){
            var index = siteNameArray.indexOf(siteNameWithId);
            if (index > -1) {
    			siteNameArray.splice(index, 1);
			}  
        }else{
            siteNameArray.push(siteNameWithId);
        }
        component.set('v.siteName',siteName);
        component.set('v.siteNameArray',siteNameArray);
        component.set('v.selectedAdborIdArray',adborIds);
	},
    
    // Call helper method to save selected site, Check for inflight orders, taking to getservices page
    onProceed: function(component, event, helper){
        console.log("in controller");
       
        helper.getServices(component);
	},
    
    //closing the moreinfo modal which will open on button click
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "False"  
      component.set("v.isOpen", false);
   },
    //moreinfo of a site
    onMoreInfo: function(component, event, helper){
    	var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.record; // Get its value i.e. the index
        var selectedStore = component.get("v.sites.Site")[index];
        component.set('v.moreinfo',selectedStore);
        component.set('v.isOpen',true);
	}
})