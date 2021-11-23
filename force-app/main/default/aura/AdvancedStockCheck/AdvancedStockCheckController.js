({
    //Function to fetch logged in userProfile on Page Load
    doInit: function (component, event,helper){
        
        var isSc = component.get("v.isSC");
        console.log('isSc',isSc);
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
        var state = response.getState();
        if(state == "SUCCESS"){
        console.log("success in userinfo") ;
        var result = response.getReturnValue();
        console.log('result profile',result);
      if(result == true && isSc == false){
              component.set("v.userProfile", true);
      }else{
          component.set("v.userProfile", false);
      }
        }else{
            console.error("fail:" + response.getError()[0].message); 
            }
        });
        $A.enqueueAction(action);
        //DPG-3510 Start
        var type=component.get("v.type");
        if(type){
            component.set("v.filterCriteria","AND cspmb__Product_Definition_Name__c="+"\'"+type+"\'");
        }
        //DPG-3510 End
    },
    getDeviceStockDetails: function(component, event, helper) {
        helper.fetchAllDevices(component, event, helper);
    },
    
    handleComponentEvent : function(component, event, helper) {
        var selctedrecd = component.get("v.selectedDeviceRecord");
        var resultMap=component.get("v.resultSearchMap");
        //var accessoriesSet = new Set(["IP Handsets Device", "IADs", "Camera", "Power Supply"]);
        if (component.get("v.selectedDeviceRecord.Type__c") != undefined ){
            resultMap["Type__c"]=component.get("v.selectedDeviceRecord.Type__c");
            component.set("v.clearManufacturer","false");
            component.set("v.clearModel","false");
            component.set("v.clearColor", "false");
        }
        
        if (component.get("v.selectedManufacturer.Manufacturer__c") != undefined ){
            resultMap["Manufacturer__c"]=component.get("v.selectedManufacturer.Manufacturer__c");
            component.set("v.clearModel","false");
            component.set("v.clearColor","false");
        }
        if (component.get("v.selectedModel.Model__c") != undefined ) {      
            resultMap["Model__c"]=component.get("v.selectedModel.Model__c");
            component.set("v.clearColor","false");
        }
        
        if (component.get("v.selectedColor.Colour__c") != undefined ) {
            resultMap["Colour__c"]=component.get("v.selectedColor.Colour__c");
        }
        //component.set("v.resultSearchMap",resultMap); 
       //Osaka Start of EDGE-155450:Stock Check_Greying Out Manufacture and Colour fields for accessories 
		var metaDataResult = [] ;
		var action = component.get("c.getMetaProdVal");
        console.log("deviceType+", component.get("v.selectedDeviceRecord.Type__c"));
        //EDGE-174905 - Changes made to address Duplicate values for Device Type,Manufacturer
        //ProductSpecId is replaced with deviceType selected
        action.setParams({ deviceType: component.get("v.selectedDeviceRecord.Type__c")}); 
        
        action.setCallback(this, function(response) {
        var state = response.getState();
        if(state == "SUCCESS"){
        metaDataResult = response.getReturnValue();
        console.log("success in result",metaDataResult) ;
        	}
            
       console.log('metaDataResult',metaDataResult[0].Manufacturer__c);
       //Added new condition to enable or disable the Fields based on Metadata checkbox
        if (metaDataResult != undefined && metaDataResult[0].Manufacturer__c == false ){
                component.set("v.disableManufacturer","true");
            }
            else {
                component.set("v.disableManufacturer","false");         
            }
         if (metaDataResult != undefined && metaDataResult[0].Model__c == false ){
                component.set("v.disableModel","true");
            }
            else {
                component.set("v.disableModel","false");         
            }  
        if (metaDataResult != undefined && metaDataResult[0].Colour__c == false ){
                component.set("v.disableColour","true");
            }
            else {
                component.set("v.disableColour","false");         
            } 
         //End of Added new condition to enable or disable the Fields based on Metadata checkbox
        });
        $A.enqueueAction(action);    
		//Osaka Start of EDGE-155450:Stock Check_Greying Out Manufacture and Colour fields for accessories 
		component.set("v.resultSearchMap",resultMap);    
    },
    
    handleClearEvent : function(component, event, helper) {
        var clearedValue = event.getParam("clearEvent");
        component.set("v.clearedSearchRecord",clearedValue);
        if (component.get("v.clearedSearchRecord.Type__c") != undefined) {
            console.log('cleared value is', JSON.stringify(component.get("v.clearedSearchRecord")));
            component.set("v.clearManufacturer","true");
            component.set("v.clearModel","true");
            component.set("v.clearColor","true");
            component.set("v.disableManufacturer","false");
        	component.set("v.disableColour","false");
            component.set("v.disableModel", "false");
            component.set("v.greyOut", "false");            
            helper.clearResults(component, event, helper);
        }
        
        if (component.get("v.clearedSearchRecord.Manufacturer__c") != undefined) {
            component.set("v.clearModel","true");
            component.set("v.clearColor","true");
            component.set("v.clearedSearchRecord.Manufacturer__c","");
            component.set("v.clearedSearchRecord.Model__c","");
            var resultMap = component.get("v.resultSearchMap");
            delete resultMap["Manufacturer__c"];
            delete resultMap["Model__c"];
            delete resultMap["Colour__c"];
            component.set("v.resultSearchMap",resultMap) ;
        }
        if (component.get("v.clearedSearchRecord.Model__c") != undefined) {
            component.set("v.clearColor","true");
            component.set("v.clearedSearchRecord.Model__c","");
            component.set("v.clearedSearchRecord.Colour__c","");
            var resultMap = component.get("v.resultSearchMap");
            delete resultMap["Model__c"];
            delete resultMap["Colour__c"];
            component.set("v.resultSearchMap",resultMap) ;
        } 
        if (component.get("v.clearedSearchRecord.Colour__c") != undefined) {
            var resultMap = component.get("v.resultSearchMap");
            delete resultMap["Colour__c"];
            component.set("v.resultSearchMap",resultMap) ;
        }
        console.log(JSON. stringify(component.get("v.resultSearchMap")));
    },
    
    clearSelection: function (component, event, helper) {
        component.set("v.clearDevice","false");
        component.set("v.clearManufacturer","false");
        component.set("v.clearModel","false");
        component.set("v.clearColor","false");
        component.set("v.clearDevice","true");
        component.set("v.clearManufacturer","true");
        component.set("v.clearModel","true");
        component.set("v.clearColor","true");
        component.set("v.greyOut","false");
        component.set("v.disableManufacturer","false");
        component.set("v.disableColour","false");
        component.set("v.disableModel","false");
        helper.clearResults(component, event, helper);
        
    },
    
    changeData:function(component, event, helper){
        helper.changeData(component, event);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
      handleSelectAllProduct: function(component, event, helper) {
         },
    
})