({
    doInit: function(component, event, helper) {
        //alert('Basket Id -->'+component.get("v.basketId"));
        component.set("v.loadingSpinner", true);
        this.getMDMTenancyCIDN(component, event, helper);
        
    },    
    getMDMTenancyCIDN : function (component, event, helper) {
        // let action = component.get("c.getCustomerServicesMDMTenancies");
        let action = component.get("c.getCustomerServicesMDMTenancies");
        //-- get response recieved from Replicator --
        action.setParams({
            finCIDN: '',
            basketId: component.get("v.basketId"),
            callFrom: 'MDM Tenancy',
            callFor: 'Product_Family_for_MDM_Tenancy'
        });
        action.setCallback(this, function (response) {
            let MDMTenancy = response.getReturnValue();
            // alert('********response>' + JSON.stringify(MDMTenancy));
            if (MDMTenancy) {
                component.set("v.jsonResponse",JSON.stringify(MDMTenancy));
                this.tableMDMTenancy(component, event, helper, MDMTenancy);
                //   alert('********response>' + JSON.stringify(MDMTenancy));
                // component.set("v.mobileResponseFmReplicator", MDMTenancy);
                //   component.set("v.loadingSpinner", false);
            } else {
                component.set("v.loadingSpinner", false);
                this.tableMDMTenancy(component, event, helper, MDMTenancy);
            }
        });
        $A.enqueueAction(action);
    },
    
    tableMDMTenancy: function (component, event, helper, MDMTenancyData) {
        // component.set("v.loadingSpinner", false);
        
        let actionTable = component.get("c.getMobileServicesTablewrapper");
        actionTable.setParams({
            transitionMoblileData: MDMTenancyData,
            basketId: component.get("v.basketId")
        });
        
        actionTable.setCallback(this, function (response) {
            let tableData = response.getReturnValue();
            // alert('********response>' + JSON.stringify(tableData));
            if (tableData && tableData.length > 0) {
                component.set("v.TenancyColumns", [
                    {
                        label: "Tenancy Name", fieldName: "tenancy_name", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "Tenancy ID", fieldName: "Product_Number", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                    /* ,
                    {
                        label: "API Call", fieldName: "APICall", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    } */
                    
                ]);
                
                component.set("v.MDMTenancyResponseTable", tableData);                 
                component.set("v.loadingSpinner", false);
            } else {
                // alert("An error has occured" + JSON.stringify(tableData));
                component.set("v.noTenancyData", true);
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(actionTable);       
    },   
    selectedRowsMDMTenancy : function (component, event, helper) {
        
    },
    getSelectedTenancy : function (component, event, helper) {
        
    },
    handleAPICallCS : function (component, event, helper) {
       //  alert('********response>' + JSON.stringify(component.get("v.MDMTenancyResponseTable")));
        let dataSource = component.get("v.MDMTenancyResponseTable");
        let payloadMap = [];
        dataSource.forEach(function (obj) {
            var jsonData = {};
            jsonData['name'] = obj.tenancy_name;
            jsonData['id'] = obj.Product_Number; 
            //  jsonData[obj.Product_Number] = obj.tenancy_name;
            payloadMap.push(jsonData);
        });
        // alert('********response>' + JSON.stringify(payloadMap)); 
        let selectedTenancyIds = payloadMap;
        let myEvent = $A.get("e.c:CustomerExistingTenancyEvent");
        myEvent.setParams({
            "selectedTenancyIds":selectedTenancyIds
        });
        console.log('firing event from component controller'+myEvent);
        myEvent.fire();
    },
    
    handleClose : function (component, event, helper) {
        let myEvent = $A.get("e.c:CustomerExistingTenancyEvent");
        myEvent.setParams({
            "selectedTenancyIds":["closeWindow"]
        });
        myEvent.fire();
    }
    
})