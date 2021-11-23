({
    init: function (component, event, helper) {
        //component.set("v.isCidnHierarchy", true);
        helper.doInit(component, event, helper);
        document.onclick = function(e){
            if (e.pageX != undefined) {
                component.set("v.testPageX", e.pageX);
                component.set("v.testPageY", e.pageY - 282);
            }
        }
    },
    /*EDGE-154658 changes by Manuga from team Amsterdam to align search-box and help text start*/
    display : function(component, event, helper) {
        helper.toggleHelper(component, event);
    },
    
    displayOut : function(component, event, helper) {
        helper.toggleHelper(component, event);
    },
    
    /*EDGE-154658 changes by Manuga from team Amsterdam to align search-box and help text end*/
    
    /**
     * EDGE-145811: changes by Manish/Honey from team Amsterdam  Start
     * Provide an In line Search option for Sales user to filter services eligible and Ineligible services for Transition on Checkpoint UI for EM
	 * */
      searchTableMobile : function(cmp,event,helper) {
       
        var serachId = cmp.find("SearchBox");
        var SearchValue = serachId.get("v.value");
        var mobRestTbl=cmp.get("v.mobileResTableBeforeSearch");
        var searchServiceID = event.getSource().get("v.value").toUpperCase().trim();
        var isValidSearch=false;
         var tempMobileResponseTable = [];
        if(searchServiceID.length >= 3){
            var letters =/^[0-9]+$/;
            if(!searchServiceID.toString().match(letters)){
              serachId.setCustomValidity("INVALID search parameter");
                 isValidSearch=false;
                return;
            }else{
               serachId.setCustomValidity("");
                 isValidSearch=true;
            }
            if(isValidSearch){
                 mobRestTbl.forEach(function(objState){
                    var serviceId=objState.Product_Number;
                    if(serviceId.includes(searchServiceID)){
                       tempMobileResponseTable.push(objState);
                     }
                 });
               helper.tableMobileDataHelper(cmp, event, helper,tempMobileResponseTable);                
		 }
        }else if(searchServiceID==""){
             helper.tableMobileDataHelper(cmp, event, helper,mobRestTbl);    
       }else{
             helper.tableMobileDataHelper(cmp, event, helper,mobRestTbl);    
        }	
    },
    /*EDGE-145811: changes by Manish/Honey from team Amsterdam  ..End*/
    getSelectedProdNames: function (component, event, helper) {
       
       helper.getSelectedProdNames(component, event, helper);
    },
    getSelectedProdNamesNgUc: function (component, event, helper) {
     
        helper.getSelectedProdNamesNgUc(component, event, helper);
    },
    mobileDisplayAction: function (component, event, helper) {
        if (component.get("v.callFor") == 'mobile')
            helper.mobileDisplayAction(component, event, helper);
        else
            helper.ngUcDisplayAction(component, event, helper);
    },
    handleRowAction: function (component, event, helper) {
        if(component.get('v.readyForAssesment') == true)
            return;
        document.onclick = function(e){
            if (e.pageX != undefined) {
                component.set("v.testPageX", e.pageX);
                component.set("v.testPageY", e.pageY - 278);
            }
        }
        //  helper.handleRowAction(component, event, helper);
        var action = event.getParam('action');
        var row = event.getParam('row');          
        var rows = component.get('v.ngUcResponseTable');
        var rowIndex = rows.indexOf(row);
        if(row.eligibilityStatus == "Eligible"){
            return;
        }
        // alert(component.get("v.testPageX") + '**********>>>' + component.get("v.testPageY"));
        var postionTop = 0;
        if(rowIndex == 0)
            postionTop = -3;
        else
            postionTop = rowIndex * 3;
        //   postionTop =  component.get("v.testPageY") - 280; 
        component.set("v.topPosition", postionTop);
        var bodyMsg ='';
        var toggleText = component.find("popoverDynamic");
        $A.util.removeClass(toggleText, 'toggle');
        $A.util.addClass(toggleText, "showPopover");
        if (row.eligibilityStatus == "Not Eligible") {
            bodyMsg = '<div>This line is not eligible for transition due to : <ul style="list-style-type:circle;padding-left: 6%"><li>'+ row.eligibilityReason +'</li></ul></div>';          
            $A.util.removeClass(toggleText, 'slds-popover_warning');
            $A.util.addClass(toggleText, "slds-popover_error");
            component.set("v.popoverTitle", "Not Eligible");
            component.set("v.popoverBody", bodyMsg);
            component.set("v.IconStyle", "utility:error");
        } 
        else if(row.eligibilityStatus == "Eligible"){
            bodyMsg = '<div>This line is eligible for transition: <ul style="list-style-type:circle;padding-left: 6%"><li>'+ row.eligibilityReason +'</li></ul></div>';
            $A.util.removeClass(toggleText, 'slds-popover_error');
            $A.util.addClass(toggleText, 'slds-popover_warning');
            component.set("v.popoverTitle", "Eligible");
            component.set("v.popoverBody", bodyMsg);
            component.set("v.IconStyle", "utility:success");
            component.set("v.colorCode", "green");
        }
            else if(row.eligibilityStatus == "Warning"){
                bodyMsg = '<div>This line is eligible for transition but following should be considered: <ul style="list-style-type:circle;padding-left: 6%"><li>'+ row.eligibilityReason +'</li></ul></div>';
                $A.util.removeClass(toggleText, 'slds-popover_error');
                $A.util.addClass(toggleText, 'slds-popover_warning');
                component.set("v.popoverTitle", "Eligible with Warning");
                component.set("v.popoverBody", bodyMsg);
                component.set("v.IconStyle", "utility:warning");
                component.set("v.colorCode", "#ffb75d");
            }
                else {
                }
        //  alert(JSON.stringify(action) + '**********>>>' + JSON.stringify(row));
    },
    closePopover: function (component, event, helper) {
        var toggleText = component.find("popoverDynamic");
        $A.util.removeClass(toggleText, 'showPopover');
        $A.util.addClass(toggleText, "toggle");
    },
    /* EDGE-168642 changes by Abhishek from Osaka Team-------START--------- */
    downloadCSV : function (component, event, helper){
        var legacyData = component.get("v.mobileResponseTable");

        console.log('Table Data' +JSON.stringify(legacyData));
        var legacyDataConverted = helper.convertLegacyDataToCSV(component, legacyData);
        if(legacyDataConverted ==  null){
            return;
        }
        //Get current date in ddmmyyyy format
        var currentdate = new Date(); 
        var fileDate =  String(currentdate.getDate()).padStart(2,'0') + String((currentdate.getMonth()+1)).padStart(2,'0') + String(currentdate.getFullYear());
        
        var elementLink=document.createElement('a');
        elementLink.href='data:text/csv;charset=utf-8,'+encodeURI(legacyDataConverted);
        elementLink.target='_self';
        elementLink.download=$A.get("$Label.c.csvFileLabel")+fileDate+'.csv';
        document.body.appendChild(elementLink);
        elementLink.click();
        
    },
    /* EDGE-168642 -------END--------- */
    /*-- Start of EDGE-198197 by Abhishek(Osaka) */
    updateColumnSorting: function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);

    },
    /*-- End of EDGE-198197 by Abhishek(Osaka) */
    
    //Start of EDGE-211350 by Abhishek(Osaka)
	getSelectedProdNamesGrid: function (component, event, helper) {
       
       helper.getSelectedProdNamesGrid(component, event, helper);
    },
    onToggleDispo: function(component, event, helper) {
        console.log(" Inside Toggle");
        var toggledId = event.getParam("name");
        console.log('toggledId::'+toggledId);
        var listToggledId = component.get("v.listToggledId");
        console.log('listToggledId::'+listToggledId);
        if (event.getParam("isExpanded") === false) {
            listToggledId.push(toggledId);
        } else {
            const index = listToggledId.indexOf(toggledId);
            if (index > -1) {
                listToggledId.splice(index, 1);
            }
        }
        component.set("v.listToggledId", listToggledId);
        var currentSelectedDispo = component.get("v.currentSelectedDispo");
        if (currentSelectedDispo.length > 0) {
            component.set("v.selectedRowsGrid", currentSelectedDispo);
        }
        console.log('currentSelectedDispo inside onToggleDispo:::'+currentSelectedDispo);
    },
     //End of EDGE-211350 by Abhishek(Osaka)

     //DIGI-1757 changes by Pradeep from Osaka Team START
    downloadCSVNGUC : function (component, event, helper){
        var legacyData = component.get("v.ngUcResponseTable");
        console.log('NGUC Table Data' +JSON.stringify(legacyData));
        var legacyDataConverted = helper.convertLegacyDataToCSVNGUC(component, legacyData);
        if(legacyDataConverted ==  null){
            return;
        }
        //Get current date in ddmmyyyy format
        var currentdate = new Date(); 
        var fileDate =  String(currentdate.getDate()).padStart(2,'0') + String((currentdate.getMonth()+1)).padStart(2,'0') + String(currentdate.getFullYear());
        
        var elementLink=document.createElement('a');
        elementLink.href='data:text/csv;charset=utf-8,'+encodeURI(legacyDataConverted);
        elementLink.target='_self';
        elementLink.download=$A.get("$Label.c.csvFileLabel")+fileDate+'.csv';
        document.body.appendChild(elementLink);
        elementLink.click();
        
    }
    //DIGI-1757 End

})