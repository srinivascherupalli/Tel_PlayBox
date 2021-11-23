({
    doInit: function (component, event, helper) {
        console.log('computilitygetservicesmobile:::'+component.get("v.isCidnHierarchy"));
        var toggleText = component.find("popoverDynamic");
        $A.util.toggleClass(toggleText, "toggle");
    },
    
 /*EDGE-154658 changes by Manuga from team Amsterdam to align search-box and help text start*/
    toggleHelper : function(component,event) {
    var toggleText = component.find("tooltip");
    $A.util.toggleClass(toggleText, "toggle");
   },
    /*EDGE-154658 changes by Manuga from team Amsterdam to align search-box and help text start*/
    
    getSelectedProdNames: function (component, event, helper) {
        let selectedAccRows = event.getParam("selectedRows");
        console.log('SelectAccRows::--17--'+JSON.stringify(selectedAccRows));
        /* EDGE-145811: changes by Aarathi/Honey from team Amsterdam --Start*/
        let selectedServiceIds=[];
         //   alert('********row>'+JSON.stringify(selectedAccRows));
        //--- filter non eligible record ----
        let finalSelectedAccRows = [];
        selectedAccRows.forEach(function (rowRecordAll) {
            if (rowRecordAll.eligibilityStatus == 'Eligible') {
                // alert('********row>'+JSON.stringify(rowRecordAll));
                //alert('********row>'+rowRecordAll);
                finalSelectedAccRows.push(rowRecordAll); 
                var serviceId=rowRecordAll.Product_Number;
                selectedServiceIds.push(serviceId);
            }    
        });
        
        
        /* EDGE-145811: changes by Aarathi/Honey from team Amsterdam --end*/
        //--- filter non eligible record ----
        //  component.set("v.selectedMobileRecrodTemp", selectedAccRows);
        component.set("v.selectedMobileRecrodTemp", finalSelectedAccRows);
        // alert('********selectedAccRows>'+JSON.stringify(finalSelectedAccRows));
        //EDGE-148736 changes by Manuga from team Amsterdam to dynamically calculate the count//  
        component.set("v.totalRecordsCount", finalSelectedAccRows.length);
        

        /* EDGE-145811: changes by Aarathi/Honey from team Amsterdam --Start*/
        let mobileResponseTable=component.get("v.mobileResponseTable"); 
        let tempmobileResponseTable=[];
         mobileResponseTable.forEach(function(objState){
                    var serviceId=objState.Product_Number;
                    if(selectedServiceIds.includes(serviceId)){
                        objState.checkValue = true;
                       tempmobileResponseTable.push(objState);
                     }else
                     {   objState.checkValue = false;
                         tempmobileResponseTable.push(objState);
                     }
                 });
         //component.set("v.mobileResponseTable",tempmobileResponseTable);
       /* EDGE-145811: changes by Aarathi/Honey from team Amsterdam --End*/
     
        /*--Disable function--*/
        let dTable = component.find("mobileDataTable");
        let allData = dTable.get("v.data");
        let slectedRows = dTable.get("v.selectedRows");
        let slectedRowsArray = dTable.getSelectedRows();
        // let expandedRows=dTable.getCurrentExpandedRows();
        //  alert('********selectedAccRows>'+JSON.stringify(slectedRows));
        //   alert('********slectedRowsArray>'+JSON.stringify(slectedRowsArray));
        if (slectedRowsArray.length > 0) {
            //console.log('slectedRowsJson'+slectedRowsJson);
            let selectedRows = [];
            slectedRowsArray.forEach(function (rowRecord) {
                // alert('********s.keyProduct>'+JSON.stringify(rowRecord.Id));
                if (rowRecord.eligibilityStatus == 'Not Eligible') {
                    //  alert('********row>'+JSON.stringify(rowRecord.Id));
                    //    Swal.fire('Not Eligible', 'This service is not eligible. Not available for tranistion', 'error');
                }
                else {
                    selectedRows.push(rowRecord.Id);
                }             
            });
            component.set("v.selectedRows", selectedRows);
            console.log('Selected Rows::--81--'+selectedRows);
        }
        else {
        }
        // alert('********s.mobilrclick>'+JSON.stringify(component.get("v.mobileResponseFmReplicator")));
        /*--Disable function*/
        // --- Fire event to individual  selection and pass variable to parent---
        let appEventMobility = $A.get("e.c:MobilityEventBus");
        appEventMobility.setParams({
            mobileTransitionData: component.get("v.mobileResponseFmReplicator"),
            //   SelectedMobileRecrod: selectedAccRows,
            SelectedMobileRecrod: finalSelectedAccRows,
            ngUcTransitionData: component.get("v.ngUcResponseFmReplicator"),
            SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
            callFrom: "Mobility",
            loadingSpinner: true
        });
        appEventMobility.fire();
        
    },
    
    getSelectedProdNamesNgUc: function (component, event, helper) {
        let selectedAccRows = event.getParam("selectedRows");
        // alert('********row>'+JSON.stringify(selectedAccRows));
        // alert('********row>'+JSON.stringify(component.get("v.ngUcResponseTable")));
        let finalSelectedAccRows = [];
        let finalSelectedAccRowsArray = [];
        
        /*  selectedAccRows.forEach(function (rowRecordAll) {
            if (rowRecordAll.Id.includes("_PFamily") == true) { */
        //  alert('********selectedParent>'+JSON.stringify(rowRecordAll.Id));
        
        component.get("v.ngUcResponseTable").forEach(function (rowRecordAllDetails) {
            selectedAccRows.forEach(function (rowRecordAll) {
                if (rowRecordAll.Id.indexOf("_PFamily") != -1 && rowRecordAll.eligibilityStatus != 'Not Eligible' && rowRecordAll.FNN_Number != null) { //EDGE-151827 Added Codition for Not Eligible and failed product  
                    //alert('********rowDetails>'+JSON.stringify(component.get("v.ngUcResponseTable")));  
                    //alert('********rowDetails>'+JSON.stringify(rowRecordAllDetails.Id));  
                    if (rowRecordAllDetails.Id.indexOf(rowRecordAll.Id.split("_PFamily")[0]) != -1) {
                        // alert(rowRecordAll.Id.split("_PFamily")[0]+'********all the child>'+JSON.stringify(rowRecordAllDetails.Id)); 
                        finalSelectedAccRows.push(rowRecordAllDetails.Id);
                        finalSelectedAccRowsArray.push(rowRecordAllDetails);
                    }
                }
                

                
            });
        });
        console.log(finalSelectedAccRows);
        // finalSelectedAccRows.push(rowRecordAll);
        //  alert('********rowDetails>'+JSON.stringify(finalSelectedAccRows)); 
        component.set("v.selectedRowsNgUC", finalSelectedAccRows);
         //EDGE-164031 changes by Rahul to dynamically calculate the count// 
		component.set("v.totalRecordsCountNguc", finalSelectedAccRowsArray.length);
        //    }
        //  });
        // --- Fire event to individual  selection and pass variable to parent---
        // alert('********mobileData>'+JSON.stringify(component.get("v.mobileResponseFmReplicator")));
        let appEventMobility = $A.get("e.c:MobilityEventBus");
        appEventMobility.setParams({
            ngUcTransitionData: component.get("v.ngUcResponseFmReplicator"),
            //  SelectedNgUCRecrod: finalSelectedAccRows,
            SelectedNgUCRecrod: finalSelectedAccRowsArray,
            mobileTransitionData: component.get("v.mobileResponseFmReplicator"),
            SelectedMobileRecrod: component.get("v.selectedMobileRecrodTemp"),
            callFrom: "NgUc",
            loadingSpinner: true
        });
        appEventMobility.fire();
    },
    mobileDisplayAction: function (component, event, helper) {
        //    alert('********mobileResponseFmReplicator>'+JSON.stringify(component.get('v.mobileResponseFmReplicator')));
        
        let params = event.getParam("arguments");
        console.log('---mobileDisplayAction---'+component.get("v.sioConfigMode"));
        component.set("v.selectedMobileRecrodState", params.selectedMobileRecrodFM);
        component.set("v.mobileResponseFmReplicatorState", params.mobileResponseFmReplicatorFM);
        component.set("v.ngUcResponseFmReplicatorState", params.ngUcResponseFmReplicatorFM);
        component.set("v.selectedNgUcRecrodTemp", params.selectedngUcRecrodFM);
        
        //   alert('********mobileResponseFmReplicatorFM>NGUC'+JSON.stringify(params.selectedngUcRecrodFM));
        if (params.CIDNString != null) {
            // component.set("v.mobileFlag", true);
            let actionResponse = component.get("c.getCustomerServicesMobile");
            var CIDNList = component.get("v.selectedCIDN");
            var isCIDNHierarchy = component.get("v.isCidnHierarchy");
            console.log('selectedCIDN ', CIDNList);
            console.log('isCidnHierarchy ', isCIDNHierarchy);
            //-- get response recieved from Replicator --
            //if(component.get("v.productFamily") == 'Enterprise Mobility'){
                actionResponse.setParams({
                finCIDN: params.CIDNString,
                basketId: params.basketId,
                callFrom: 'Mobile',
                callFor: 'Product_Family_for_Mobile',
                selectedCIDN: component.get("v.selectedCIDN"),
                isCidnHierarchy: component.get("v.isCidnHierarchy"),
                //Added as a part of EDGE-209885 by Abhishek(Osaka) to send selected product family to replicator
                prodFamilyList : component.get("v.productFamily"),
                sioConfigMode: component.get("v.sioConfigMode")//Added for DIGI-1681
                });
                //}
                /*else if(component.get("v.productFamily") == 'IOT'){
                actionResponse.setParams({
                finCIDN: params.CIDNString,
                basketId: params.basketId,
                callFrom: 'IoT',
                callFor: 'Product_Family_For_IoT',
                selectedCIDN: component.get("v.selectedCIDN"),
                isCidnHierarchy: component.get("v.isCidnHierarchy"),
                prodFamilyList : component.get("v.productFamily"),
                sioConfigMode: component.get("v.sioConfigMode")
                });
                }*/
            actionResponse.setCallback(this, function (response) {
                let mobileData = response.getReturnValue();
                //alert('********response>' + JSON.stringify(mobileData));
               /* EDGE-145811: changes by Manish/Honey from team Amsterdam --Start*/
                component.set("v.bskId", params.basketId);
                /*EDGE-145811 end*/
                if (mobileData) {
                    //    alert('********response>' + JSON.stringify(mobileData));
                    console.log('Inside MobileDisplayAction block if----');
                    component.set("v.mobileResponseFmReplicator", mobileData);
                    
                    //Start of Edge-21130 by Abhishek(Osaka) Added if-else for tree grid
                    if(component.get("v.isCidnHierarchy") == true){
                        this.tableMobileDataGrid(component, event, helper, mobileData, params.basketId);
                    }
                    //End of Edge-21130 by Abhishek(Osaka)
                    else{
                        this.tableMobileData(component, event, helper, mobileData, params.basketId);
                    }
                    //this.tableMobileData(component, event, helper, mobileData, params.basketId);
                    //   component.set("v.loadingSpinner", false);
                } else {
                    component.set("v.loadingSpinner", false);
                    //Start of Edge-21130 by Abhishek(Osaka) Added if-else for tree grid
                    if(component.get("v.isCidnHierarchy") == true){
                        this.tableMobileDataGrid(component, event, helper, mobileData, params.basketId);
                    }
                    //End of Edge-21130 by Abhishek(Osaka)
                    else{
                        this.tableMobileData(component, event, helper, mobileData, params.basketId);
                    }
                    //this.tableMobileData(component, event, helper, mobileData, params.basketId);
                }
            });
            $A.enqueueAction(actionResponse);
        }
    },
    
     /**
     * EDGE-145811: changes by Manish/Honey from team Amsterdam  Start
     * Provide an In line Search option for Sales user to filter services eligible and Ineligible services for Transition on Checkpoint UI for EM
	 * */
    tableMobileDataHelper: function (component, event, helper,tempMobileResponseTable) {
        let tableData =tempMobileResponseTable;
        let finalOnChangeRows=component.get("v.finalOnChangeRows"); 
         let mobileResponseFmReplicator=component.get("v.mobileResponseFmReplicator");
       console.log('tableData',tableData);
        if (tableData) {
                this.getBasket(component, event, helper,component.get("v.bskId"));
                component.set("v.mobilityColumns", [
                    //EDGE - 148583 Service ID label Changes done by Aarathi from Team Amsterdam 
                    /*-- Start of EDGE-198197 by Abhishek(Osaka) */
                    {
                        label: "CIDN", fieldName: "source_CIDN", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "ABN", fieldName: "ABN", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    /*-- End of EDGE-198197 by Abhishek(Osaka) */
                    {
                        label: "Service ID", fieldName: "Product_Number", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    
                    {
                        label: "Current Plan", fieldName: "plan_name", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "BAN", fieldName: "BAN", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "Plan Type", fieldName: "Plan_Type", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team Start
                   /* {
                        label: "Contract Term", fieldName: "contract_term", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },*/
                    {
                        label: "Remaining Term", fieldName: "contract_remaining_term", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team End
                    {
                        label: "Partner Dealer Code", fieldName: "Dealer_Code", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "Compatible", fieldName: "eligibilityStatus", type: "text",
                        cellAttributes: { class: { fieldName: "showClass" }, iconName: { fieldName: "displayIconName" } }
                    },
                    {
                        label: "Reason", fieldName: "eligibilityReason", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //Added as a part of EDGE-207157 by Abhishek(Osaka)
                    {
                        label: "Nickname", fieldName: "user_name", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                ]);
                component.set("v.checkService", true);
            	//component.set("v.checkService", false);
                let selectedRows = [];
                let selectedMobileRec = [];
             	 tableData.forEach(function (obj) {
                    if (obj.checkValue == true) {
						console.log('Line no 230 obj.checkValue ', obj.checkValue);
                        selectedRows.push(obj.Id);
                        selectedMobileRec.push(obj);
                    }
                     
                   if (obj.eligibilityStatus == "Not Eligible") {
					   console.log('Line no 235 obj.checkValue ', obj.checkValue);
                       obj.checkValue = false;
					   console.log('Line no 237 obj.checkValue ', obj.checkValue);
                        obj.showClass = obj.eligibilityStatus == "Not Eligible" ? "yellowcolor" : "whitecolor";
                        obj.displayIconName = "utility:warning";
                        obj.enableDisableCSS = obj.eligibilityStatus == "Not Eligible" ? "disableCSS" : "disableCSS1";
                    } 
                    else if (obj.eligibilityStatus == "Failed") {//EDGE-198376
					   console.log('Line no 235 obj.checkValue ', obj.checkValue);
                       obj.checkValue = false;
					   console.log('Line no 237 obj.checkValue ', obj.checkValue);
                        obj.showClass = obj.eligibilityStatus == "Failed" ? "yellowcolor" : "whitecolor";
                        obj.displayIconName = "utility:warning";
                        obj.enableDisableCSS = obj.eligibilityStatus == "Failed" ? "disableCSS" : "disableCSS1";
                    } 
                     else {
                        obj.showClass = obj.eligibilityStatus == "Eligible" ? "whitecolor" : "yellowcolor";
                        obj.displayIconName = "utility:success";
                    }
                });
                component.set("v.mobileResponseTable", tableData);
               if (component.get("v.selectedMobileRecrodState").length > 0 || component.get("v.mobileResponseFmReplicatorState") != null) {
                    component.set("v.selectedMobileRecrodTemp", component.get("v.selectedMobileRecrodState"));
                    let selectedRowsState = [];
                    component.get("v.selectedMobileRecrodState").forEach(function (objState) {
                        selectedRowsState.push(objState.Id);
                    });
                    component.set("v.selectedRows", selectedRowsState);
                } else {
                   component.set("v.selectedRows", selectedRows);
                    //EDGE-148736 changes by Manuga from team Amsterdam to dynamically calculate the count//                    
                    component.set("v.totalRecordsCount", selectedRows.length);
                     component.set("v.selectedMobileRecrodTemp", selectedMobileRec);
                    eval("$A.get('e.force:refreshView').fire();");
				 }
                // --- Fire event to pass variable to parent---
                let appEventMobility = $A.get("e.c:MobilityEventBus");
                appEventMobility.setParams({
                    ngUcTransitionData: component.get("v.ngUcResponseFmReplicatorState"),
                    SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                    mobileTransitionData: mobileResponseFmReplicator,
                    SelectedMobileRecrod: component.get("v.selectedMobileRecrodTemp"),
                    callFrom: "Mobility",
                    loadingSpinner: true
                });
                appEventMobility.fire();
                component.set("v.loadingSpinner", false);
            } else {
                // alert("An error has occured" + JSON.stringify(tableData));
                component.set("v.NoMobileData", true);
                component.set("v.loadingSpinner", false);
            }
    },
     /*EDGE-145811: changes by Manish/Honey from team Amsterdam  ..End*/
    tableMobileData: function (component, event, helper, mobileResponseFmReplicator, basketId) {
        component.set("v.loadingSpinner", true);
        let actionTable = component.get("c.getMobileServicesTablewrapper");
       
        actionTable.setParams({
            transitionMoblileData: mobileResponseFmReplicator,
            basketId: basketId
        });
        actionTable.setCallback(this, function (response) {
            let tableData = response.getReturnValue();
            console.log('---tableData--- 396', JSON.stringify(tableData));
            if (tableData) {
                console.log('---in if 400---');
                this.getBasket(component, event, helper, basketId);
                //if(component.get("v.productFamily") == 'Enterprise Mobility'){ //----- DIGI -16453 added By Arul(Osaka)
                    component.set("v.mobilityColumns", [
                    //EDGE-139071 Start
                    /*{
                    label: "PRODUCT", fieldName: "Product_Type", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },*/
                    //EDGE - 148583 Service ID label Changes done by Aarathi from Team Amsterdam
                    /*{
                    label: "CIDN/ABN", fieldName: "cidnValue", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }, */
                    /*-- Start of EDGE-198197 by Abhishek(Osaka) */
                    {
                    label: "CIDN", fieldName: "source_CIDN", type: "text",sortable: true,
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "ABN", fieldName: "ABN", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    
                    
                    
                    /*-- End of EDGE-198197 by Abhishek(Osaka) */
                    {
                    label: "Service ID", fieldName: "Product_Number", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "Current Plan", fieldName: "plan_name", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "BAN", fieldName: "BAN", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "Plan Type", fieldName: "Plan_Type", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    
                    
                    
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team Start
                    /* {
                    label: "Contract Term", fieldName: "contract_term", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },*/
                    {
                    label: "Remaining Term", fieldName: "contract_remaining_term", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team End
                    {
                    label: "Partner Dealer Code", fieldName: "Dealer_Code", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "Compatible", fieldName: "eligibilityStatus", type: "text",
                    cellAttributes: { class: { fieldName: "showClass" }, iconName: { fieldName: "displayIconName" } }
                    },
                    {
                    label: "Reason", fieldName: "eligibilityReason", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //EDGE-139071 End
                    //Added as a part of EDGE-207157 by Abhishek(Osaka)
                    {
                    label: "Nickname", fieldName: "user_name", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                    ]);
                    //}
                    // Start of DIGI -16453 added By Arul(Osaka)
                    /*else if(component.get("v.productFamily") == 'IOT'){
                    component.set("v.mobilityColumns", [
                    {
                    label: "CIDN", fieldName: "source_CIDN", type: "text",sortable: true,
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "ABN", fieldName: "ABN", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    
                    {
                    label: "Service ID", fieldName: "Product_Number", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "Current Plan", fieldName: "plan_name", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "BAN", fieldName: "BAN", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                    label: "Plan Type", fieldName: "Plan_Type", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    
                    {
                    label: "Plan Variant", fieldName: "data_plan_type", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    { label: "Offer Type", fieldName: "product_variant", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    { label: "Shared Plan", fieldName: "data_allowance", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    
                    {
                    label: "Compatible", fieldName: "eligibilityStatus", type: "text",
                    cellAttributes: { class: { fieldName: "showClass" }, iconName: { fieldName: "displayIconName" } }
                    },
                    {
                    label: "Reason", fieldName: "eligibilityReason", type: "text",
                    cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                    ]);
                    } */// -------End of DIGI -16453 added By Arul(Osaka)
                component.set("v.checkService", true);
                console.log("********tableData> 462" + JSON.stringify(tableData));
                
                let selectedRows = [];
                let selectedMobileRec = [];
                //    component.set("v.mobileResponseTable", tableData);
                tableData.forEach(function (obj) {
                    if (obj.checkValue == true) {
                        selectedRows.push(obj.Id);
                        selectedMobileRec.push(obj);
                    }
                    //  selectedRows.push(obj.Id);
                    if (obj.eligibilityStatus == "Not Eligible") {
                        obj.showClass = obj.eligibilityStatus == "Not Eligible" ? "yellowcolor" : "whitecolor";
                        obj.displayIconName = "utility:warning";
                        obj.enableDisableCSS = obj.eligibilityStatus == "Not Eligible" ? "disableCSS" : "disableCSS1";
                      
                    }
                    else if(obj.eligibilityStatus == "Failed") {//EDGE-198376
                        obj.showClass = obj.eligibilityStatus == "Failed" ? "yellowcolor" : "whitecolor";
                        obj.displayIconName = "utility:warning";
                        obj.enableDisableCSS = obj.eligibilityStatus == "Failed" ? "disableCSS" : "disableCSS1";
                      
                    }
                    else {
                        obj.checkValue = true;
                        obj.showClass = obj.eligibilityStatus == "Eligible" ? "whitecolor" : "yellowcolor";
                        obj.displayIconName = "utility:check";
                        
                    }
                });
                component.set("v.mobileResponseTable", tableData);
                 component.set("v.mobileResTableBeforeSearch",tableData);
                //    alert( "********selectedMobileRecrodState>" + JSON.stringify(component.get("v.selectedMobileRecrodState")));
                //    alert( "********mobileResponseFmReplicatorState>" + JSON.stringify(component.get("v.mobileResponseFmReplicatorState")));
                if (component.get("v.selectedMobileRecrodState").length > 0 || component.get("v.mobileResponseFmReplicatorState") != null) {
                    component.set("v.selectedMobileRecrodTemp", component.get("v.selectedMobileRecrodState"));
                    let selectedRowsState = [];
                    component.get("v.selectedMobileRecrodState").forEach(function (objState) {
                        selectedRowsState.push(objState.Id);
                    });
                    component.set("v.selectedRows", selectedRowsState);
                } else {
                    //  alert("********selectedRows>" + JSON.stringify(selectedRows));
                    //  alert("********tableData>" + JSON.stringify(tableData));
                    component.set("v.selectedRows", selectedRows);
                    //EDGE-148736 changes by Manuga from team Amsterdam to dynamically calculate the count//                    
                    component.set("v.totalRecordsCount", selectedRows.length);
                    console.log('Selected rec count:::' +component.get("v.selectedRows"));
                    console.log('Record count:::'+component.get("v.totalRecordsCount"));
                    //  component.set("v.selectedMobileRecrodTemp", tableData);
                    component.set("v.selectedMobileRecrodTemp", selectedMobileRec);
                  //  alert(JSON.stringify(component.get("v.selectedMobileRecrodTemp")));
                  eval("$A.get('e.force:refreshView').fire();");
                }
                // --- Fire event to pass variable to parent---
                let appEventMobility = $A.get("e.c:MobilityEventBus");
                appEventMobility.setParams({
                    ngUcTransitionData: component.get("v.ngUcResponseFmReplicatorState"),
                    SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                    mobileTransitionData: mobileResponseFmReplicator,
                    SelectedMobileRecrod: component.get("v.selectedMobileRecrodTemp"),
                    callFrom: "Mobility",
                    loadingSpinner: true
                });
                appEventMobility.fire();
                //EDGE-200766 START
                let requestSupportEvent = $A.get("e.c:RequestSupportEvent");
                requestSupportEvent.setParams({
                    ngUcTransitionData: component.get("v.ngUcResponseFmReplicatorState"),
                    SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                    mobileTransitionData: mobileResponseFmReplicator,
                    SelectedMobileRecrod: component.get("v.selectedMobileRecrodTemp"),
                    callFrom: "Mobility",
                    loadingSpinner: true
                });
                requestSupportEvent.fire();
                //EDGE-200766 END
                component.set("v.loadingSpinner", false);
            } else {
                // alert("An error has occured" + JSON.stringify(tableData));
                component.set("v.NoMobileData", true);
                component.set("v.loadingSpinner", false);
            }
            
        });
        $A.enqueueAction(actionTable);
    },
    getBasket: function (component, event, helper, basketId) {
        console.log('Inside Get Basket');
        var action = component.get("c.getBasket");
        action.setParams({
            basketId: basketId
        });
        action.setCallback(this, function (response) {
            var productBasket = response.getReturnValue();
            if (productBasket) {
                if (productBasket.Transition_basket_stage__c == "Check Eligibility Completed") {
                    component.set("v.hideCheckboxColumn", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    ngUcDisplayAction: function (component, event, helper) {
        //    alert('********mobileResponseFmReplicator>'+JSON.stringify(component.get('v.mobileResponseFmReplicator')));
        let params = event.getParam("arguments");
        component.set("v.selectedNgUcRecrodTemp", params.selectedngUcRecrodFM);
        component.set("v.ngUcResponseFmReplicatorState", params.ngUcResponseFmReplicatorFM);
        //  alert('********params.selectedngUcRecrodFM>'+JSON.stringify(params.selectedngUcRecrodFM));
        //  alert('********mobileIn NGUC>'+JSON.stringify(params.selectedMobileRecrodFM));
        if (params.CIDNString != null) {
            // component.set("v.mobileFlag", true);
            let actionResponse = component.get("c.getCustomerServicesMobile");
            //-- get response recieved from Replicator --
            actionResponse.setParams({
                finCIDN: params.CIDNString,
                basketId: params.basketId,
                callFrom: 'NgUc',
                callFor: 'Product_Family_for_ngUc',
                //Start of EDGE-209885 by Abhishek(Osaka) to enable CIDN Hierarchy for Nguc
                selectedCIDN: component.get("v.selectedCIDN"),
                isCidnHierarchy: component.get("v.isCidnHierarchy"),
                //Added as a part of EDGE-209885 by Abhishek(Osaka) to send selected product family to replicator
                prodFamilyList : component.get("v.productFamily"),
                sioConfigMode: component.get("v.sioConfigMode")//Added for DIGI-1681
            });
            actionResponse.setCallback(this, function (response) {
                let mobileDataNgUc = response.getReturnValue();
                //  alert('********response>' + JSON.stringify(mobileDataNgUc));
                if (mobileDataNgUc) {
                    //    alert('********response>' + JSON.stringify(mobileDataNgUc));
                    // console.log('********response>' + JSON.stringify(mobileDataNgUc));
                    component.set("v.ngUcResponseFmReplicator", mobileDataNgUc);
                    this.tableNgUcData(component, event, helper, mobileDataNgUc, params.basketId, params.selectedMobileRecrodFM, params.selectedMobileRecrodFM);
                    //   component.set("v.loadingSpinner", false);
                } else {
                    //alert('********response>error' + JSON.stringify(mobileDataNgUc));
                    component.set("v.loadingSpinner", false);
                    this.tableNgUcData(component, event, helper, mobileDataNgUc, params.basketId);
                }
            });
            $A.enqueueAction(actionResponse);
        }
    },
    tableNgUcData: function (component, event, helper, ngUcResponseFmReplicator, basketId, mobileDataSelected, mobileDataLoadedAll) {
        //alert('********response>' + JSON.stringify(ngUcResponseFmReplicator)); 
		
		component.set("v.OsakaDormant",$A.get("$Label.c.Is_Osaka_Dormant_21_09"));
        console.log('********response>' + JSON.stringify(ngUcResponseFmReplicator));
        component.set("v.loadingSpinner", true);
        component.set("v.readyForAssesment", false);
        //  let actionTable = component.get("c.getNgUCServicesTablewrapper");
        let actionTable = component.get("c.getNgUCServicesTablewrapperV1"); 
        actionTable.setParams({
            transitionMoblileData: ngUcResponseFmReplicator,
            basketId: basketId
        });
        actionTable.setCallback(this, function (response) {
            let tableData = response.getReturnValue();
            // alert('********response>' + JSON.stringify(tableData.length));
            console.log('********response>Table-->' + JSON.stringify(tableData));
            if (tableData && tableData.length > 0) {
                this.getBasket(component, event, helper, basketId);
                if(component.get("v.OsakaDormant") == true){
                component.set("v.mobilityColumns", [
                    {
                        label: "PRODUCT", fieldName: "Product_Type", type: "text",
                        cellAttributes: { class: "Boldcolor" }
                    },
                    {
                        label: "FNN", fieldName: "FNN_Number", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "TYPE", fieldName: "Association_Type", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "SITE/ADBOR ID", fieldName: "SITE_ADBORID", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    /*    {
                            label: "ADBOR ID", fieldName: "ADBORID_SITE", type: "text",
                            cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                        }, */
                    {
                        label: "CONTRACT TERM", fieldName: "contract_term", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //End of EDGE-218343
                    
                    /*    {
                            label: "ELIGIBILITY STATUS", fieldName: "eligibilityStatus", type: "text",
                            cellAttributes: { class: { fieldName: "showClass" }, iconName: { fieldName: "displayIconName" } }
                        },
                    /*{ 
                        label: "ELIGIBILITY", fieldName: 'eligibilityStatus', type: "url",
                        cellAttributes: { class:  "buttonCSS" },
                        typeAttributes: { label: { fieldName: 'eligibilityStatus' }, tooltip: component.get("v.tooltipError"), target :"_blank", value: "#"}
                    } */
                    
                    {
                        type: 'button-icon', label: "ELIGIBILITY",
                        cellAttributes: {  iconName: { fieldName: '' }, iconLabel: { fieldName: 'iconText' }, class:  { fieldName: 'iconCss' } , iconPosition: 'right' },
                        typeAttributes: {
                            iconName: { fieldName: "displayIconName" }, iconLabel: { fieldName: 'iconText' } , title: { fieldName: 'eligibilityReason' } ,variant: 'bare',
                            alternativeText: 'loading...', disabled: false, size : 'xx-large',iconClass : { fieldName: "iconCss" }, 
                        }
                    },
                    //Added by Mukta from Team Apple (EDGE-151827) for NGUC product family
                    {
                        label: "REASON", fieldName: "eligibilityReason", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                    
                    
                ])}
                
               else {
                component.set("v.mobilityColumns", [
                    {
                        label: "PRODUCT", fieldName: "Product_Type", type: "text",
                        cellAttributes: { class: "Boldcolor" }
                    },
                    {
                        label: "FNN", fieldName: "FNN_Number", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "TYPE", fieldName: "Association_Type", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "SITE/ADBOR ID", fieldName: "SITE_ADBORID", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    /*    {
                            label: "ADBOR ID", fieldName: "ADBORID_SITE", type: "text",
                            cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                        }, */
                    //Start of EDGE-218343 by Pradeep Mudenur(Osaka) to add CIDN, ABN and BAN Columns.
                    {
                        label: "CIDN", fieldName: "source_CIDN", type: "text",sortable: true,
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "ABN", fieldName: "ABN", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                     {
                        label: "BAN", fieldName: "BAN", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                   /* {
                        label: "CONTRACT TERM", fieldName: "contract_term", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },*/
                    //End of EDGE-218343
                    
                    /*    {
                            label: "ELIGIBILITY STATUS", fieldName: "eligibilityStatus", type: "text",
                            cellAttributes: { class: { fieldName: "showClass" }, iconName: { fieldName: "displayIconName" } }
                        },
                    /*{ 
                        label: "ELIGIBILITY", fieldName: 'eligibilityStatus', type: "url",
                        cellAttributes: { class:  "buttonCSS" },
                        typeAttributes: { label: { fieldName: 'eligibilityStatus' }, tooltip: component.get("v.tooltipError"), target :"_blank", value: "#"}
                    } */
                    
                    {
                        type: 'button-icon', label: "ELIGIBILITY",
                        cellAttributes: {  iconName: { fieldName: '' }, iconLabel: { fieldName: 'iconText' }, class:  { fieldName: 'iconCss' } , iconPosition: 'right' },
                        typeAttributes: {
                            iconName: { fieldName: "displayIconName" }, iconLabel: { fieldName: 'iconText' } , title: { fieldName: 'eligibilityReason' } ,variant: 'bare',
                            alternativeText: 'loading...', disabled: false, size : 'xx-large',iconClass : { fieldName: "iconCss" }, 
                        }
                    },
                    //Added by Mukta from Team Apple (EDGE-151827) for NGUC product family
                    {
                        label: "REASON", fieldName: "eligibilityReason", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                    
                    
                ])};
                tableData.forEach(function (obj) {
                    console.log('obj'+obj);


					//EDGE-217774:Added Null check to fix the defect
                    if (obj.eligibilityStatus != "Eligible" && obj.eligibilityStatus != null) {//EDGE-198376 Display status for other than eligible resource

                        obj.displayIconName = "utility:warning";
                        obj.iconCss = "iconCssError";
                        obj.iconText = obj.eligibilityStatus; 
                    }
                    /*else if (obj.eligibilityStatus == "Warning"){
                        obj.displayIconName = "utility:warning";
                        obj.iconCss = "iconCssWarning";
                        obj.iconText = "Warning"; 
                    }*/
                        else if (obj.eligibilityStatus == "Eligible"){
                            obj.displayIconName = "utility:success";
                            obj.iconCss = "iconCssSuccess";
                            obj.iconText = obj.eligibilityStatus; 
                        }
                            else {
                                if(obj.eligibilityStatus == "null" || obj.eligibilityStatus == undefined){
                                    component.set("v.readyForAssesment", true);
                                    obj.iconText = "Ready for assessment"; 
                                    component.set("v.justifycontent", "flex-end");
                                }
                                else {
                                }
                            }
                });
                component.set("v.checkService", true);
                component.set("v.ngUcResponseTable", tableData);
                //    alert("********tableData>" + JSON.stringify(tableData));
                let selectedRows = [];
                let selectedNgUCRec = [];
                //    component.set("v.mobileResponseTable", tableData);
                tableData.forEach(function (obj) {
                    if (obj.checkValue == true) {
                        selectedRows.push(obj.Id);
                        selectedNgUCRec.push(obj);
                    }
                });
                //    alert( "********selectedMobileRecrodState>" + JSON.stringify(component.get("v.selectedMobileRecrodState")));
                //    alert( "********selectedngUcRecrodFM>" + JSON.stringify(component.get("v.selectedNgUcRecrodTemp")));
                if (component.get("v.selectedNgUcRecrodTemp").length > 0 || component.get("v.ngUcResponseFmReplicatorState") != null) {
                    // component.set("v.selectedNgUcRecrodTemp", component.get("v.selectedMobileRecrodState"));
                    let selectedRowsState = [];
                    /* component.get("v.selectedMobileRecrodState").forEach(function (objState) {
                        selectedRowsState.push(objState.Id);
                    }); */
                    component.get("v.selectedNgUcRecrodTemp").forEach(function (objState) {
                        selectedRowsState.push(objState.Id);
                    });
                    //  component.set("v.selectedRowsNgUC", component.get("v.selectedNgUcRecrodTemp")); 
                    component.set("v.selectedRowsNgUC", selectedRowsState);
                } else {
                    //  alert("********selectedRows>" + JSON.stringify(selectedRows));
                    //  alert("********tableData>" + JSON.stringify(tableData));
                    component.set("v.selectedRowsNgUC", selectedRows);
                    component.set("v.selectedNgUcRecrodTemp", selectedNgUCRec);
                    //EDGE-164031 changes by Rahul to dynamically calculate the count// 
                    component.set("v.totalRecordsCountNguc", selectedRows.length);
                }
                // --- Fire event to pass variable to parent---
                //   alert('********mobileIn ngUcResponseFmReplicator>'+JSON.stringify(ngUcResponseFmReplicator));
                //	console.dir('********mobileIn selectedNgU>'+JSON.stringify(component.get("v.selectedNgUcRecrodTemp")));
                //	console.log("%j", component.get("v.selectedNgUcRecrodTemp"));
                component.set("v.selectedMobileRecrodTemp", mobileDataSelected);
                let appEventMobility = $A.get("e.c:MobilityEventBus");
                appEventMobility.setParams({
                    ngUcTransitionData: ngUcResponseFmReplicator,
                    SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                    callFrom: "NgUc",
                    mobileTransitionData: mobileDataLoadedAll,
                    SelectedMobileRecrod: mobileDataSelected,
                    loadingSpinner: true
                });
                appEventMobility.fire();
                //EDGE-200766 START
                let requestSupportEvent = $A.get("e.c:RequestSupportEvent");
                requestSupportEvent.setParams({
                    ngUcTransitionData: ngUcResponseFmReplicator,
                    SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                    mobileTransitionData: component.get("v.mobileResponseFmReplicator"),
                    SelectedMobileRecrod: component.get("v.selectedMobileRecrodTemp"),
                    callFrom: "NgUc",
                    loadingSpinner: true
                });
                requestSupportEvent.fire();
                //EDGE-200766 END
                component.set("v.loadingSpinner", false);
            } else {
                // alert("An error has occured" + JSON.stringify(tableData));
                component.set("v.NoNgUcData", true);
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(actionTable);
    },
    /* EDGE-168642 Changes by Abhishek from Osaka Team-------START--------- */
    convertLegacyDataToCSV: function(component, objectRecords){
        //console.log("Temp Mobile Data: "+tempmobileResponseTable);
        //console.log("Object Records: " +objectRecords);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variable for separate CSV values and 
        // for start next line use '\n' [new line] in lineDivider variable  
        columnDivider = ',';
        lineDivider =  '\n';
 
        
        // API names of the fields 
        //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team


        //Added user_name as a part of EDGE-207157 by Abhishek(Osaka)
        keys = ['source_CIDN','ABN','Product_Number','plan_name','BAN','Plan_Type','contract_remaining_term','Dealer_Code','eligibilityStatus','eligibilityReason','user_name'];
        
        //Column headers for CSV files
        //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team
        //Added Nick Name as a part of EDGE-207157 by Abhishek(Osaka)
        var columnHeaders = ['CIDN','ABN','Service ID','Current Plan','BAN','Plan Type','Remaining Term','Partner Dealer Code','Compatible','Reason','Nickname'];
        csvStringResult = '';
        csvStringResult += columnHeaders.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
             for(var tempKey in keys) {
                var finalKey = keys[tempKey] ;
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                 //console.log("Test++"+JSON.stringify(objectRecords[i]));
                 // Start of EDGE-181293 - Added null check to avoid undifined for Eligibility Reason
                 if(objectRecords[i][finalKey] != undefined){
                      csvStringResult += '"'+ objectRecords[i][finalKey]+'"';
                 }else{
                     csvStringResult += '"'+ '' +'"';
                 }
                 //End of EDGE-181293
               counter++;
                 //console.log("Data to download " +csvStringResult); 
            }  
             csvStringResult += lineDivider;
          } 
        //console.log("Data to download " +csvStringResult); 
        return csvStringResult; 
    },
    /* EDGE-168642 -------END--------- */
    /*-- Start of EDGE-198197 by Abhishek(Osaka) */
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.mobileResponseTable");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.mobileResponseTable", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    /*-- End of EDGE-198197 by Abhishek(Osaka) */   
    //Start of EDGE-211350 by Abhishek(Osaka) to display Mobile services in Grid format
    
    tableMobileDataGrid: function (component, event, helper,mobileResponseFmReplicator,basketId){
        let actionTable = component.get("c.getMobileServicesTablewrapper");
        actionTable.setParams({
            transitionMoblileData: mobileResponseFmReplicator,
            basketId: basketId
        });
        actionTable.setCallback(this, function (response) {
            let gridData = response.getReturnValue();
            if(gridData){
                var dataNew = gridData;
                this.treeGridMobile(component,event,helper,dataNew,mobileResponseFmReplicator);
                component.set("v.mobileResponseTable",dataNew);                
            }
            else {
                console.log('Inside No Mobile Data');
                // alert("An error has occured" + JSON.stringify(tableData));
                component.set("v.NoMobileData", true);
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(actionTable);
    }, 
    
    getSelectedProdNamesGrid: function (component, event, helper) {
        console.log('Inside');
        var tempList = [];
    	var selectedRows = component.find("gridDataTable").getSelectedRows();
        console.log('Selected Rows CUrrent::'+JSON.stringify(selectedRows));
    	var data = component.get("v.gridData");
    	var currentSelectedDispo = component.get("v.currentSelectedDispo");
    	this.keepSelectionPersistent(component, data, currentSelectedDispo, tempList);
		
    	if (selectedRows.length > 0) {
        	selectedRows.forEach(row => {
                //Disable checkbox for Not eligibile services
                //This condition will only allow eligibile services and parent selection.
                if(row.eligibilityStatus == 'Eligible' || row.Id.startsWith('CIDN')){
                	tempList.push(row.Id);
            	}
            	
        	})
                console.log('Temp List::'+tempList);
            //This function is used 2 compare arrays and returns if anyone of the element is present in target array 
            let checker = (arr, target) => target.some(v => arr.includes(v));

        // select and deselect child rows based on header row
        	data.forEach(row => {
            // if header was checked and remains checked, do not add sub-rows
            // if header was not checked but is now checked, add sub-rows
            if (!currentSelectedDispo.includes(row.Id) && tempList.includes(row.Id)) {
                if (row.hasOwnProperty('_children')) {
                    row._children.forEach(item => {
                        if (!tempList.includes(item.Id) && item.eligibilityStatus == "Eligible") {
                            tempList.push(item.Id);
                        }
                    })
                }
            }
            // De-select all children if parent is de-selected.
            if (currentSelectedDispo.includes(row.Id) && !tempList.includes(row.Id)) {
                if (row.hasOwnProperty('_children')) {
                    row._children.forEach(item => {
                if(item.eligibilityStatus == "Eligible"){
                const index = tempList.indexOf(item.Id);
                        if (index > -1) {
                            tempList.splice(index, 1);
                        	}
            			}
                    })
                }
            }
            //To de-select parent if all of its children are de-selected.
            let childRows = [];
            if(tempList.includes(row.Id)){
                console.log('Inside de-selecting parent');
                if (row.hasOwnProperty('_children')) {
                    console.log('Inside de-selecting parent1');
                    row._children.forEach(item => {
                        if (item.eligibilityStatus == "Eligible") {
                        	childRows.push(item.Id);
                        console.log('Inside child list'+childRows);
                        }
                    })
                    if(checker(tempList,childRows) ==  false){
                        console.log('Inside false')
                        const index = tempList.indexOf(row.Id);
                        console.log('Index'+index);
                        if (index > -1) {
                            tempList.splice(index, 1);
                        	}
                        console.log('TempLisy:'+tempList);
                    }
                }
            }
        })
    }
        component.set("v.selectedRowsGrid", tempList);
        component.set("v.currentSelectedDispo", tempList);
		//Temp List only consists of both child and parent row Id selections
                let finalSelectedAccRows = [];
                let finalSelectedList = [];
                for(var i = 0; i<tempList.length; i++){
                if(!tempList[i].startsWith('CIDN')){
                //this list only consists of on-Screen child row 'Id' selections    
                finalSelectedList.push(tempList[i]);
            }
            }
                
                for(var i = 0; i<finalSelectedList.length; i++){
                data.forEach(serviceRec => {
					serviceRec._children.forEach(item => {
                        if (finalSelectedList[i] == item.Id) {
                    		//This list consists of all attributes of selected child rows that needs to be passed to parent component(ComparisonUtility_v2)
                    		//through an event.
                            finalSelectedAccRows.push(item);
                        }
                    })
					})
            }
                component.set("v.totalRecordsCount", finalSelectedList.length);
                console.log('Final List:::'+JSON.stringify(finalSelectedAccRows));
        		console.log(component.get("v.currentSelectedDispo"));
                component.set("v.selectedMobileRecrodTemp", finalSelectedAccRows);
                // --- Fire event to individual  selection and pass variable to parent---
                let appEventMobility = $A.get("e.c:MobilityEventBus");
                appEventMobility.setParams({
                mobileTransitionData: component.get("v.mobileResponseFmReplicator"),
                //   SelectedMobileRecrod: selectedAccRows,
                SelectedMobileRecrod: finalSelectedAccRows,
                ngUcTransitionData: component.get("v.ngUcResponseFmReplicator"),
                SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                callFrom: "Mobility",
                loadingSpinner: true
            });
            appEventMobility.fire();
    },
    
    //This function keeps the selection of children persisted after parent is collapsed
    keepSelectionPersistent: function(component, data, currentSelectedDispo, tempList) {
    var toggledRows = component.get("v.listToggledId");
        console.log('Toggled Rows:'+toggledRows);
        console.log('Current Selected Persistence:'+currentSelectedDispo);
    toggledRows.forEach(row => {
        data.forEach(rowData => {
            if (rowData.Id === row) {
                rowData._children.forEach(item => {
                    currentSelectedDispo.forEach(current => {
                        if (current === item.Id) {
                            tempList.push(current);
                        }
                    })
                })
            }
        })
    })
},
    treeGridMobile : function(component,event,helper,mobileDataNew,mobileResponseFmReplicator){
        component.set("v.loadingSpinner", true);
        console.log('---treeGridMobile mobileDataNew--- 814'+JSON.stringify(mobileDataNew));
        let actionTableNew = component.get("c.gridDisplayData");
        actionTableNew.setParams({
            tableWrapperList: mobileDataNew
        });
        actionTableNew.setCallback(this, function (response) {
            var responseValue = response.getReturnValue();
            console.log('---responseValue---'+JSON.stringify(responseValue));
            var tempjson = JSON.parse(JSON.stringify(responseValue).split('tableWrapperList').join('_children'));
            console.log('---tempjson---'+JSON.stringify(tempjson));
            var tableData = JSON.parse(tempjson);
            if(tableData){
                this.getBasket(component, event, helper,component.get("v.bskId"));
                component.set("v.gridColumns", [
                    
                    {
                        label: "ABN/CIDN", fieldName: "source_CIDN", type: "text"
                    }, 
                    {
                        label: "Service ID", fieldName: "Product_Number", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "Current Plan", fieldName: "plan_name", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "BAN", fieldName: "BAN", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "Plan Type", fieldName: "Plan_Type", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team Start
                    /*  {
                        label: "Contract Term", fieldName: "contract_term", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },*/
                    {
                        label: "Remaining Term", fieldName: "contract_remaining_term", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team End
                    {
                        label: "Partner Dealer Code", fieldName: "Dealer_Code", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    },
                    {
                        label: "Compatible", fieldName: "eligibilityStatus", type: "text",
                        cellAttributes: { class: { fieldName: "showClass" }, iconName: { fieldName: "displayIconName" } }
                    },
                    {
                        label: "Reason", fieldName: "eligibilityReason", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }


                    },
                    //Added as a part of EDGE-207157 by Abhishek(Osaka)
                    {
                        label: "Nickname", fieldName: "user_name", type: "text",
                        cellAttributes: { class: { fieldName: "enableDisableCSS" } }
                    }
                ]);
                component.set("v.checkService", true);
                let selectedRows = [];
                let selectedRowsGrid = [];
                let selectedMobileRec = [];
                tableData.forEach(function (obj) {
                    selectedRowsGrid.push(obj.Id);
                    if(obj._children != null){
                        for(var i = 0; i<obj._children.length; i++){
                        var abnValue;
                        if (obj._children[i].checkValue == true) {
                            selectedRows.push(obj._children[i].Id);
                            selectedMobileRec.push(obj._children[i]);
                        }
                        if (obj._children[i].eligibilityStatus == "Not Eligible") {
                            obj._children[i].showClass = obj._children[i].eligibilityStatus == "Not Eligible" ? "yellowcolor" : "whitecolor";
                            obj._children[i].displayIconName = "utility:warning";
                            obj._children[i].enableDisableCSS = obj._children[i].eligibilityStatus == "Not Eligible" ? "disableCSS" : "disableCSS1";
                        }
                        else if(obj._children[i].eligibilityStatus == "Failed") {//EDGE-198376
                            obj._children[i].showClass = obj._children[i].eligibilityStatus == "Failed" ? "yellowcolor" : "whitecolor";
                            obj._children[i].displayIconName = "utility:warning";
                            obj._children[i].enableDisableCSS = obj._children[i].eligibilityStatus == "Failed" ? "disableCSS" : "disableCSS1";
                            
                            
                        }
                            else {
                                obj._children[i].checkValue = true;
                                obj._children[i].showClass = obj._children[i].eligibilityStatus == "Eligible" ? "whitecolor" : "yellowcolor";
                                obj._children[i].displayIconName = "utility:check";
                                
                            }
                        abnValue = obj._children[i].ABN;
                    }
                        if(abnValue != null){
                            obj.source_CIDN = abnValue+ '-'+obj.source_CIDN;
                        }
                    }
                    
                });
                
                console.log('Final Data'+JSON.stringify(tableData));
                component.set("v.gridData", tableData);
                console.log('selectedMobileRecrodState Value::'+component.get("v.selectedMobileRecrodState"));
                console.log('mobileResponseFmReplicatorState Value::'+component.get("v.mobileResponseFmReplicatorState")); 
                if (component.get("v.selectedMobileRecrodState").length > 0 || component.get("v.mobileResponseFmReplicatorState") != null) {
                    component.set("v.selectedMobileRecrodTemp", component.get("v.selectedMobileRecrodState"));
                    let selectedRowsState = [];
                    component.get("v.selectedMobileRecrodState").forEach(function (objState) {
                        selectedRowsState.push(objState.Id);
                    });
                    component.set("v.selectedRowsGrid", selectedRowsState);
                } 
                else {
                    
                    component.set("v.selectedRowsGrid", selectedRows);
                    component.set("v.currentSelectedDispo", selectedRows);
                    component.set('v.gridExpandedRows', selectedRowsGrid);
                    console.log('Expanded Rows:::'+JSON.stringify(selectedRowsGrid));
                    component.set("v.totalRecordsCount", selectedRows.length);
                    console.log('Selected rec count:::' +component.get("v.selectedRowsGrid"));
                    console.log('Record count:::'+selectedRows.length);
                    component.set("v.selectedMobileRecrodTemp", selectedMobileRec);
                    console.log('SelectedMObileRec test::'+component.get("v.selectedMobileRecrodTemp"));
                    eval("$A.get('e.force:refreshView').fire();");
                }
                let appEventMobility = $A.get("e.c:MobilityEventBus");
                appEventMobility.setParams({
                    ngUcTransitionData: component.get("v.ngUcResponseFmReplicatorState"),
                    SelectedNgUCRecrod: component.get("v.selectedNgUcRecrodTemp"),
                    mobileTransitionData: mobileResponseFmReplicator,
                    SelectedMobileRecrod: component.get("v.selectedMobileRecrodTemp"),
                    callFrom: "Mobility",
                    loadingSpinner: true
                });
                appEventMobility.fire();
                component.set("v.loadingSpinner", false);
            }
            
            else {
                console.log('Inside No Mobile Data');
                // alert("An error has occured" + JSON.stringify(tableData));
                component.set("v.NoMobileData", true);
                component.set("v.loadingSpinner", false);
            }
            
        });
        $A.enqueueAction(actionTableNew);
    },
    //End of EDGE-211350 by Abhishek(Osaka)

    //DIGI-1757 changes by Pradeep from Osaka Team START
    convertLegacyDataToCSVNGUC: function(component, objectRecords){
        //console.log("Temp NGUC Data: "+tempmobileResponseTable);
        //console.log("Object Records: " +objectRecords);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variable for separate CSV values and 
        // for start next line use '\n' [new line] in lineDivider variable  
        columnDivider = ',';
        lineDivider =  '\n';
 
        
        // API names of the fields.
        keys = ['Product_Type','FNN_Number','Association_Type','SITE_ADBORID','source_CIDN','ABN','BAN','eligibilityStatus','eligibilityReason'];
        
        //Column headers for CSV files
        var columnHeaders = ['PRODUCT','FNN','TYPE','SITE/ADBOR ID','CIDN','ABN','BAN','ELIGIBILITY','REASON'];
        csvStringResult = '';
        csvStringResult += columnHeaders.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
             for(var tempKey in keys) {
                var finalKey = keys[tempKey] ;
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                 //console.log("Test++"+JSON.stringify(objectRecords[i]));
                 // Start of EDGE-181293 - Added null check to avoid undifined for Eligibility Reason
                 if(objectRecords[i][finalKey] != undefined){
                      csvStringResult += '"'+ objectRecords[i][finalKey]+'"';
                 }else{
                     csvStringResult += '"'+ '' +'"';
                 }
                 //End of EDGE-181293
               counter++;
                 //console.log("Data to download " +csvStringResult); 
            }  
             csvStringResult += lineDivider;
          } 
        //console.log("Data to download " +csvStringResult); 
        return csvStringResult; 
    }
    //DIGI-1757 End
    
});