({
    fetchAllDevices : function(component, event) {   
        component.set("v.loadData", true);
        component.set("v.SpinnerLoading", true);
        //Start of EDGE-148577: Setting current Page to 1 always when a new stock search is performed and reload to true
        component.set("v.CurrentPage",1);
        component.set("v.reLoadData", true);
        //End of EDGE-148577
        var action = component.get("c.setProductDetails");
        action.setParams({ resultLookUpMap: component.get("v.resultSearchMap")});                  
        action.setCallback(this,function(response){
            var state=response.getState();    
            if(state==='SUCCESS'){
                var wrapperList = response.getReturnValue();
                component.set("v.deviceModel", wrapperList);
                component.set("v.columns", wrapperList.length);
                var TotalPages = Math.ceil(wrapperList.length / component.get("v.PageSize"));
                component.set("v.TotalPages",TotalPages);
                var appEvent = $A.get("e.c:paginationEvent");
                //Start of EDGE-148577 : Added componentName to Event to avoid overriding of the handlee events.
                appEvent.setParams({
                    PageData: component.get("v.deviceModel"),
                    StartRecord: 1,
                    EndRecord: 1,
                    CurrentPage: component.get("v.CurrentPage"),
                    TotalPages: TotalPages,
                    PageSize: component.get("v.PageSize"),
                    TotalRecords: component.get("v.deviceModel").length,
                    componentName:component.get("v.componentName")
                });
                appEvent.fire();
                this.dispMethod(component);
               
                component.set("v.SpinnerLoading", false);
            } 
        });
        $A.enqueueAction(action);
    },
    
    dispMethod: function(component, event) {
        var tempList = [];
        var pNo = component.get("v.CurrentPage");
        var size = component.get("v.PageSize");
        tempList = component.get("v.deviceModel");
        component.set(
            "v.dispList",
            tempList.slice((pNo - 1) * size, Math.min(pNo * size, tempList.length))
        );
        
        //Start of EDGE-148587 : to handle logic to display record count per page on UI
        var pNumber = component.get("v.CurrentPage");
        var pSize = component.get("v.PageSize");
        var offset = (pNumber - 1) * pSize;
        var currentRecordEnd = pSize * pNumber;
        var recordStart = offset + 1;
        var recordEnd = tempList.length >= currentRecordEnd ? currentRecordEnd : tempList.length;
        component.set("v.RecordStart",recordStart);
        component.set("v.RecordEnd",recordEnd);
        //End of EDGE-148587
    },
    changeData: function(component, event) {
        //Start of EDGE-148577 : Boolean to check if new search is being made
         var reload = component.get("v.reLoadData");
         var compName = event.getParam("componentName");
         if(compName == 'AdvancedStockCheck'){
            if(reload == true){
                 component.set("v.CurrentPage",1);
             }else{
                 component.set("v.CurrentPage", event.getParam("CurrentPage"));
            }
            component.set("v.PageSize", event.getParam("PageSize"));
            component.set("v.TotalPages", event.getParam("TotalPages"));
            //End of EDGE-148577
            
            this.dispMethod(component);
            this.handleSelectedProducts(component);
   
}
    

    },
    //EDGE-148561 : Stock Check API call for each page
    handleSelectedProducts: function(component, event) {
        component.set("v.reLoadData", false);
        var selectedProducts = [];
        var checkvalue = component.find("checkQuantity");
        console.log('checkvalue1-->'+checkvalue);
        if(checkvalue){
            console.log('checkvalue2-->'+checkvalue);
       for (var i = 0; i < checkvalue.length ; i++) 
        {
        selectedProducts.push(checkvalue[i].get("v.text"));
        } 
       var displayList = component.get("v.dispList");
        var action = component.get("c.checkAdvStockQuantity");
        action.setParams({
            skuidList: selectedProducts,
            displayWrapper: displayList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                console.log("options: ", options);
                component.set("v.dispList", options);
            }
        });
        $A.enqueueAction(action);
            }
    },
    
    
    clearResults : function(component, event, helper){
        var resultMap = component.get("v.resultSearchMap");
        delete resultMap["Type__c"];
        delete resultMap["Manufacturer__c"];
        delete resultMap["Model__c"];
        delete resultMap["Colour__c"];
        component.set("v.resultSearchMap",resultMap) ;    
    }
})