/*EDGE -92010
Name: InvoiceCmpController.js
Description: Js controller for InvoiceCmp
Author:Manjunath Ediga
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207867         18/05/2021
2                   Aman Soni            EDGE-207869         07/06/2021
3					Akanksha			 EDGE-215753		 14/06/2021	
***************************************************************************************************
*/
({
    doInit: function(component, event, helper) {
        // Set the attribute value. 
        component.set("v.IsPageLoad", false);
        var url = window.location.href;
        var updatedurl = url.split('/');
        var banId = updatedurl[6];
          if (url.includes('partners.enterprise.telstra.com.au')){
			banId = updatedurl[5];
          }
        component.set("v.newCaseObject.Billing_Account__c", banId);
        component.set("v.billingAccId", banId);
        //helper.getConEmail(component, event, helper);
        var contactEmailRes = component.get("v.ContactEmailId");
        helper.getAllInvoices(component, event, helper);
        helper.setPartner(component, event);
        helper.getSharedDisplayMessageCS(component, event);//Added for EDGE-207869 by Aman Soni
        helper.queryCSForDrilldown(component, event);//EDGE-215753
      
    },
    changeData:function(component, event, helper){
        helper.changeData(component, event);
    },
    /*---------------------------------------------------------------------------------------
    Name : getUsageSummary
    Description : Method to get all the parameters which are fired from Usagesummary component through Application Event UsageSummary 
    Story: EDGE-92010,126965
    Author:Manjunath Ediga
    Modified : Manjunath Ediga (Edge-126965)
    **childPaginationMap is map of parent(InvoiceCmp) chargeID as Key and Map of current page and list of Charge Identifiers selcted
     -----------------------------------------------------------------------------------*/
    getUsageSummary: function(component, event, helper) {
        var usg = event.getParam('Alldata');
        var usgList = event.getParam('UsageList');
        var chargeMap = event.getParam('ChargeIdMap');
        var mapKey  = event.getParam('mapKey');
        //Edge-157962 Starts here
        var selectedRows  = event.getParam('selectedRows');
                var summarytablekeys = [];	
                var summarytablekeys1 = [];	
                var removeDup = [];	
        //Edge-157962 Ends here
        console.log('selectedRows in doselect1',selectedRows);
        //EDGE-133408 - Component start
        var qliMap  = event.getParam('QLIMapToParent');
        component.set("v.QLIMap",qliMap);
        //EDGE-133408 - component End
        var usagelst = component.get("v.UsagesummaryList");
        var updatedList = usagelst.concat(usg);
        component.set("v.UsageList",usgList);
        component.set("v.UsagesummaryList",updatedList);
        component.set("v.ChargeIdMap",chargeMap);
        component.set("v.isOpen", false);
        //Start of EDGE-126965 - Setting of child pagination map from usage component
        var paginationMap = event.getParam('paginationMap');
        console.log('paginationMap::',paginationMap);
        component.set("v.childPaginationMap",paginationMap);
        component.set("v.UsageList",usgList);
        console.log('incoming paginationMap ',JSON.stringify(component.get("v.childPaginationMap")));
        component.set("v.UsagesummaryList",updatedList);
        component.set("v.ChargeIdMap",chargeMap);
        component.set("v.isOpen", false);
        //End of EDGE-126965
        var mapUsage = component.get("v.childPaginationMap");           		
        let strMap = new Map();
        var checkedChargeKeys = [];	
        for (let parentKey of Object.values(mapUsage)) {	
            for(let childKey of Object.values(parentKey)){
                console.log('child key',childKey);
                if(childKey != ''){    
                    strMap= childKey;
                    for(var i = 0;i<=childKey.length;i++){	
                        if(childKey[i] != undefined){	
                            checkedChargeKeys.push(childKey[i]);	
                        }	
                    }	
                }	
            }	
        }	
        var selectedRows = [];	
        var oldData = [];	
        var identifySeleted = [];	
        oldData = component.get("v.childTableData");	
        usgList = usgList.concat(oldData);
        for(var j = 0; j < usgList.length; j++){	
            for(var k = 0; k <checkedChargeKeys.length; k++){	
                if(usgList[j].chargeIdentifier == checkedChargeKeys[k]){	
                    selectedRows.push(usgList[j]);	
                }
            }
        }        
        for (let i = 0; i < selectedRows.length; ++i){
            for (let j = 0; j < selectedRows.length; ++j){
                if (i !== j && selectedRows[i].chargeIdentifier === selectedRows[j].chargeIdentifier)
                    selectedRows.splice(j, 1);            
                console.log(selectedRows);
            }
        }

        //Added by Aman Soni for EDGE-207869 || Start
        var totQueriedExc = component.get("v.totalQueriedUsgExc");
        var totQueriedInc = component.get("v.totalQueriedUsgInc");
        totQueriedExc = 0.00;
        totQueriedInc = 0.00;
        
        if(selectedRows != null || selectedRows != '' || selectedRows != undefined){
            for(var sel of selectedRows){
                var exGSTStr = '';
                exGSTStr = sel.amountExGST.replace('$',"");
                var exGSTInt = parseFloat(exGSTStr);
    
                var incGSTStr = '';
                incGSTStr = sel.amountIncGST.replace('$',"");
                var incGSTInt = parseFloat(incGSTStr);
    
                totQueriedExc += exGSTInt;
                totQueriedInc += incGSTInt;
            }
        }
        
        var strDollar = '$';
        var finaltotQueriedExc = strDollar.concat(totQueriedExc.toString());
        var finaltotQueriedInc = strDollar.concat(totQueriedInc.toString());
        component.set("v.isUsage",true);
        component.set("v.totalQueriedUsgExc",finaltotQueriedExc);
        component.set("v.totalQueriedUsgInc",finaltotQueriedInc);
        //Added by Aman Soni for EDGE-207869 || End

        component.set("v.childTableData",selectedRows);
        console.log('strMap',strMap);
        if (strMap.length > 0 )        {
            component.set("v.hideButton",false); 
        } 
        else{
            component.set("v.hideButton",true);
        }
    },
    /*---------------------------------------------------------------------------------------
    Name : viewRecord
    Description : Method to set required parameters to call  Usagesummary API and load model window. 
    Story: EDGE-92010,126965,139436
    Author:Manjunath Ediga
    Modified : Manjunath Ediga (Edge-126965,EDGE-139436)
    **invoiceMapDetails is map of parent chargeID as Key and list of request Parameters required for UsageSummary API callout
    **summaryKey  is a map of Current Page and selected rows's chargeid.
    **paginationMapInt is a map of current Page to the selected chargeid across pages
     -----------------------------------------------------------------------------------*/
    viewRecord: function(component, event, helper) {
        var row = event.getParam('row');
        var charid = row.Chargeid;
        //console.log('row===> ',row);
        //console.log('Is charge present ', charid);
        //EDGE-141682 - Component Start: Using charge Description from Invoice response instead of Usage response
        var usageType = row.chargedescription;
        component.set("v.usageType",usageType);
        component.set("v.offerName",row.offerName);//EDGE-215753
        component.set("v.drillDownEndPoint",row.drillDownEndPoint);//EDGE-215753
        component.set("v.chargeId",row.Chargeid);//EDGE-215753
         component.set("v.chargeType",row.chargeType);//EDGE-215753
        //component.set("v.checkedRows",row);//EDGE-215753
        //EDGE-141682 - Component End
        component.set("v.mapKey",charid);
        //console.log('mapkey is  ', JSON.stringify(component.get("v.mapKey")));
        var ChargeIdMap = new Map();
        var ChargeMap = component.get("v.ChargeIdMap");
        var ListFromMap =  ChargeMap[charid];
        component.set("v.selectedRowss",ListFromMap);
        var rowIdToRowMap = new Map();
        var mapData = component.get("v.rowIdToRowMap");
        rowIdToRowMap[charid] = mapData[charid];
        component.set("v.invoiceMapDetails", rowIdToRowMap);        
        var convertedMap = component.get("v.invoiceMapDetails");
        //EDGE-141682 - Component Start:Map of charge ID to type code
        var usageCode = component.get("v.usageTypecodeMap");
        var usageTypeCode = usageCode[charid];
        component.set("v.usageTypeCode",usageTypeCode);
        //console.log('usageTypeCode is ',component.get("v.usageTypeCode"));
        //EDGE-141682 - Component End
        var currentPage = component.get("v.CurrentPage");   
        //Start of EDGE-139436 - removing previously selected contents of child pagination map for selected primary from usage component
        var paginationMapInt = component.get("v.paginationMapInt");
        var summaryKey = component.get("v.summaryKey");
        var rowsSelected = component.get("v.noRowsSelected");
        
        //Edge-157962 starts
            //console.log(row);	
            if(row){	
                var selectList = component.get("v.selectedRecInvoice");
                console.log('row-->',row);	
                var listconcat = selectList.concat(row);
                console.log('listconcat-->',listconcat);	
                component.set("v.selectedRecInvoice",listconcat);	
            }
        
        //Edge-157962 Ends
        
        //console.log('summaryKey',Object.entries(summaryKey).length);   
        //console.log('paginationMapInt length',Object.entries(paginationMapInt).length);
        //Checking if any primary checkbox selected either in summary key or through paginationMapInt(selected  in other pages)
        if(Object.entries(summaryKey).length > 0 ){
            var selectedList = summaryKey[currentPage];
            console.log('selectedList in view record',selectedList);
            if(selectedList != undefined){
            var isSelectedInSummary = selectedList.includes(charid);
            //console.log('isSelected value',isSelectedInSummary);
            var childPaginationMap = component.get("v.childPaginationMap");
            //console.log('childPaginationMap before',JSON.stringify(childPaginationMap));
            //Checking if Primary checkbox selected in current Page
            if (isSelectedInSummary) {
                delete childPaginationMap[charid];
                component.set("v.isSelectAll", true);
                //console.log('childPaginationMap inside',JSON.stringify(component.get("v.childPaginationMap")));
            }
        }
            //Checking if Primary checkbox selected from through paginationMapInt(selected  in other pages)
            else if(Object.entries(paginationMapInt).length > 0 && rowsSelected == false){
                var selectedListInPagination = paginationMapInt[currentPage];  
                //console.log('selectedListInPagination in view record',selectedListInPagination);
                if(selectedListInPagination != undefined){
                    var isSelectedInPagination = selectedListInPagination.includes(charid);
                    //console.log('isSelectedInPagination value',isSelectedInPagination);
                    if(isSelectedInPagination){
                        component.set("v.isSelectAll", true);
                    }
                    //console.log('childPaginationMap inside pagination',JSON.stringify(component.get("v.childPaginationMap")));
                }
            }
        }
        //console.log('child pagination going from parent', JSON.stringify(component.get("v.childPaginationMap")));
        //End of EDGE-139436 
        //
        component.set("v.isOpen", true);
    },
    getInvoiceNum: function(component, event, helper){
        var selectedValue=  component.find("InvoiceId").get("v.value");
        component.set("v.selectedInvoicerecord",selectedValue);	
        var splitInvoice = selectedValue.split('-');
        var selectedInvoice=splitInvoice[0];      
        var invoiceNumber = selectedInvoice.trim();
        if (invoiceNumber == '')
        {
            component.set("v.errorMessage",$A.get("$Label.c.Select_Invoice_Number"));
            component.set("v.IsError",true);  
            component.set("v.IsPageLoad", false);    
        }
        if (invoiceNumber == undefined || invoiceNumber == '') {
            $A.util.addClass(component.find("noInvoice"), "show");
            component.set("v.IsPageLoad", false);
            return;
        } else {
            $A.util.removeClass(component.find("noInvoice"), "show");
            component.set("v.IsPageLoad", true);
        }
        component.set("v.invoiceNumber",invoiceNumber);//EDGE-215753
        
        helper.getInvoice(component, event, invoiceNumber);
        //Setting columns for lightning data table
            component.set('v.invoiceColumn', [
                {
                    label: 'Invoice Number',
                    fieldName: 'invoiceNum',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Payments And Adjustments',
                    fieldName: 'adjustments',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Balance Carried Forward',
                    fieldName: 'balCarryFwd',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'New Charges',
                    fieldName: 'newCharge',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Total Due',
                    fieldName: 'totDue',
                    type: 'string',
                    sortable: false
                },
                {
                    label: 'Due Date',
                    fieldName: 'dueDate',
                    type: 'text',
                    sortable: false
                }
            ]);     
       
        component.set('v.invLineItemColoumn', [
            {
                label: 'Itemised Details',
                fieldName: 'displayicon1',
                type: 'button',
                typeAttributes: {
                    disabled: {
                        fieldName: 'dis'
                    },
                    iconName:'utility:add',
                    actions: "{!c.getUsageDetails}",
                    borderColor:'#ff9800',
                    //class:{ fieldName: 'customBadgeClass' },
                    variant: { fieldName: 'labelVariant' },
                   /* label: {
                        fieldName: 'buttonLabel',
                        variant:'border-filled',
                        border: '5px solid',
                        color: '#333',
                        class:{fieldName:'badgeClass'}
                        }*/
                },
                
                cellAttributes:
                {
                    iconName: { fieldName: 'badgeClass' },
                    iconLabel: { fieldName: 'buttonLabel' },
                    iconPosition: 'right',
                    class: 'slds-text-color_success'            
                 }
            },
            {
                label: 'Offer Name',
                fieldName: 'offerName',
                type: 'text',
                sortable: false,
                cellAttributes: {
                    fieldName: "displayIconName",
                    type: 'button'
                }
            }, 
            {
                label: 'Physical Location Name',
                fieldName: 'physicalLocationName',
                type: 'string',
                sortable: false
            },
            //Added by Aman Soni for EDGE-207869 || Start
            {
                label: 'Unique ID',
                fieldName: 'uniqueId',
                type: 'text',
                sortable: false
            },
            //Added by Aman Soni for EDGE-207869 || End
            {
                label: 'Charge Type',
                fieldName: 'chargeType',
                type: 'text',
                sortable: false
            },
            {
                label: 'Charge Description',
                fieldName: 'chargedescription',
                type: 'text',
                sortable: false
            },
            {
                label: 'Excluding GST',
                fieldName: 'excludingGSTcostFmtd',//EDGE-157960
                type: 'text',
                sortable: false,
                cellAttributes: { alignment: 'right' }//EDGE-157960
            }, 
            {
                label: 'Including GST',
                fieldName: 'includingGSTcostFmtd',//EDGE-157960
                type: 'text',
                sortable: false,
                cellAttributes: { alignment: 'right' }//EDGE-157960
            },
            {
                label: 'Quantity',
                fieldName: 'quantity',
                type: 'text',
                sortable: false
            },                                                
            {
                label: 'Start Date',
                fieldName: 'startDate',
                type: 'text',
                sortable: false
            },
            {
                label: 'End Date',
                fieldName: 'endDate',
                type: 'text',
                sortable: false
            }
        ]);                                                                                    
    },
    getUsageDetails: function(component, event, helper) {
        helper.getUsageDetails(component, event);
    },
    changeData: function(component, event, helper) {
        helper.changeData(component, event);
    },

    
    //EDGE-157962 Starts here
     showReview : function(component, event, helper){   	
        //Added var and if/else condition for EDGE-207867 by Aman Soni || Start
        var strDollar = '$';
        var existingCase = component.get("v.caseValues");
        if(existingCase == 'Add to Existing Case'){
            var enteredEmail = component.get("v.selectedLookUpRecord.Contact.Name");
            var enteredDescription = component.get("v.selectedLookUpRecord.Description");	
            var enteredSubject = component.get("v.selectedLookUpRecord.Subject");
        }else if(existingCase == 'Create New Case'){
        var enteredEmail = component.get("v.selectedLookUpRecord.Email");        	
        var enteredDescription = component.get("v.newCaseObject.Description");	
        var enteredSubject = component.get("v.newCaseObject.Subject");	
        }
        //Added var and if/else condition for EDGE-207867 by Aman Soni || End 		
        var result = enteredDescription != null && enteredEmail != null && enteredSubject != null;	
        if(result) {	
            component.set("v.CheckFields",false);	
        }	
        else        {	
            component.set("v.CheckFields",true); 	
        }	
        if ((enteredEmail == undefined || enteredEmail == '') && (enteredDescription == undefined || enteredDescription == '') && (enteredSubject == undefined || enteredSubject == '')) {	
            $A.util.addClass(component.find("noDescription"), "disp");	
            $A.util.addClass(component.find("noSubject"), "sub");	
            $A.util.addClass(component.find("noemailTest"), "emailErr");	
            window.scrollTo(300, 650);	
            return;	
        }	
        
        if ((enteredEmail == undefined || enteredEmail == '') && (enteredDescription == undefined || enteredDescription == '') && (enteredSubject != undefined || enteredSubject != '')) {            	
            $A.util.addClass(component.find("noemailTest"), "emailErr");	
            $A.util.addClass(component.find("noDescription"), "disp");	
            $A.util.removeClass(component.find("noSubject"), "sub");	
            window.scrollTo(300, 650);	
            return;	
        }	
        
        if ((enteredEmail != undefined || enteredEmail != '') && (enteredDescription == undefined || enteredDescription == '') && (enteredSubject == undefined || enteredSubject == '')) {	
            $A.util.addClass(component.find("noDescription"), "disp");	
            $A.util.addClass(component.find("noSubject"), "sub");	
            $A.util.removeClass(component.find("noemailTest"), "emailErr");	
            window.scrollTo(300, 650);	
            return;	
        }	
        
        if ((enteredEmail == undefined || enteredEmail == '') && (enteredDescription != undefined || enteredDescription != '') && (enteredSubject == undefined || enteredSubject == '')) {	
            $A.util.addClass(component.find("noSubject"), "sub");	
            $A.util.addClass(component.find("noemailTest"), "emailErr");	
            $A.util.removeClass(component.find("noDescription"), "disp");	
            window.scrollTo(300, 650);	
            return;	
        }	
        
        if ((enteredEmail == undefined || enteredEmail == '') && (enteredDescription != undefined || enteredDescription != '') && (enteredSubject != undefined || enteredSubject != '')) {	
            $A.util.addClass(component.find("noemailTest"), "emailErr");	
            $A.util.removeClass(component.find("noDescription"), "disp");	
            $A.util.removeClass(component.find("noSubject"), "sub");	
            window.scrollTo(300, 650);	
            return;	
        }	
        
        if ((enteredEmail != undefined || enteredEmail != '') && (enteredDescription == undefined || enteredDescription == '') && (enteredSubject != undefined || enteredSubject != '')) {	
            $A.util.addClass(component.find("noDescription"), "disp");	
            $A.util.removeClass(component.find("noSubject"), "sub");	
            $A.util.removeClass(component.find("noemailTest"), "emailErr");	
            window.scrollTo(300, 650);	
            return;	
        }	
        
        if ((enteredEmail != undefined || enteredEmail != '') && (enteredDescription != undefined || enteredDescription != '') && (enteredSubject == undefined || enteredSubject == '')) {	
            $A.util.addClass(component.find("noSubject"), "sub");	
            $A.util.removeClass(component.find("noDescription"), "disp");	
            $A.util.removeClass(component.find("noemailTest"), "emailErr");	
            window.scrollTo(300, 650);	
            return;	
        }	 
        //Added if condition for EDGE-207867 by Aman Soni || Start
        if ((enteredEmail != undefined || enteredEmail != '') && (enteredDescription != undefined || enteredDescription != '') && (enteredSubject != undefined || enteredSubject != '')) {	
            $A.util.removeClass(component.find("noSubject"), "sub");	
            $A.util.removeClass(component.find("noDescription"), "disp");	
            $A.util.removeClass(component.find("noemailTest"), "emailErr");	
            window.scrollTo(300, 650);	
        }
        //Added if condition for EDGE-207867 by Aman Soni || Start

        helper.getBillingAddress(component, event,helper);	
        var listSelected = [];	
        var finalList = [];	
        var removedfromList = [];	
        var selectallKeys = [];	
        var AllChecked = [];	
        var popupChecked = [];	
        popupChecked = component.get("v.innertableSel");	
        listSelected = component.get("v.selectedRecInvoice");	
        AllChecked = component.get("v.selectAllCheckRow");	
        listSelected = listSelected.concat(AllChecked);	
        selectallKeys = component.get("v.selectAllCheckboxKey");	
        var childPaginationMap = component.get("v.childPaginationMap");	
        var uniqueArray = [];	
        for(var i=0; i < listSelected.length; i++){	
            if(uniqueArray.indexOf(listSelected[i]) === -1) {	
                uniqueArray.push(listSelected[i]);	
            }	
        }	
        var keys =[];	
        var removeDupKeys = [];	
        /*for (let key of Object.keys(childPaginationMap)) {	
                keys.push(key);   	
        }*/	
        keys = keys.concat(selectallKeys);	
        removeDupKeys = keys.concat(popupChecked);	
        for(var i=0; i < removeDupKeys.length; i++){	
            if(keys.indexOf(removeDupKeys[i]) === -1) {	
                keys.push(removeDupKeys[i]);	
            }	
        }	
        for(var j=0; j < keys.length; j++){	
          for (var k=0; k < uniqueArray.length; k++) {	
                 if(uniqueArray[k].Chargeid == keys[j]){	
                     finalList.push(uniqueArray[k]);	
                 }     	
             }  	
        }
         if(component.get("v.reviewTableData")!= undefined && component.get("v.reviewTableData")!= ''){
            var rowFromLWC = component.get("v.reviewTableData");
            var lstToDisplay =[];
            //var chargeIdentifierLWC =[];
            for(var i =0;i<rowFromLWC.length;i++)
            {
                lstToDisplay.push(rowFromLWC[i]);  
            }
            finalList=finalList.concat(lstToDisplay);
            
        }

        //Added by Aman Soni for EDGE-207869 || Start
        var totQueriedUsgExc = '';
        var totQueriedUsgInc='';
        totQueriedUsgExc = component.get("v.totalQueriedUsgExc");
        totQueriedUsgInc = component.get("v.totalQueriedUsgInc");
        var totQueriedExc = component.get("v.totalQueriedExc");
        var totQueriedInc = component.get("v.totalQueriedInc");
        var isUsage = component.get("v.isUsage");
        totQueriedExc = 0.00;
        totQueriedInc = 0.00;

        if(finalList != null || finalList != '' || finalList != undefined){
            for(var fin of finalList){
                var exGSTStr = '';
                exGSTStr = fin.excludingGSTcostFmtd.replace('$',"");
                var exGSTInt = parseFloat(exGSTStr);
    
                var incGSTStr = '';
                incGSTStr = fin.includingGSTcostFmtd.replace('$',"");
                var incGSTInt = parseFloat(incGSTStr);
    
                totQueriedExc += exGSTInt;
                totQueriedInc += incGSTInt;
            }
        }
        
        var totQueusgExcInt=0.00;
        var totQueusgIncInt=0.00;

        if(isUsage){
            var totQueusgExcStr = '';
            if(totQueriedUsgExc != undefined || totQueriedUsgExc != ''){
                totQueusgExcStr = totQueriedUsgExc.replace('$',"");
                totQueusgExcInt = parseFloat(totQueusgExcStr);
            }
    
            var totQueusgIncStr = '';
            if(totQueriedUsgInc != undefined || totQueriedUsgInc != ''){
                totQueusgIncStr = totQueriedUsgInc.replace('$',"");
                totQueusgIncInt = parseFloat(totQueusgIncStr);
            }
        }
        
        totQueriedExc += totQueusgExcInt;
        totQueriedInc += totQueusgIncInt;
        totQueriedExc = totQueriedExc.toFixed(2);
        totQueriedInc = totQueriedInc.toFixed(2);

        var finaltotQueriedExc = strDollar.concat(totQueriedExc);
        var finaltotQueriedInc = strDollar.concat(totQueriedInc);

        component.set("v.totalQueriedExc",finaltotQueriedExc);
        component.set("v.totalQueriedInc",finaltotQueriedInc);
        //Added by Aman Soni for EDGE-207869 || End

        component.set("v.finalListtoDispaly",finalList);  
        component.set("v.isOpenreview",true);	
    },	
    closeModelRev : function(component, event, helper){	
        component.set("v.isOpenreview", false);	
    },
    closeModelnew :function(component, event, helper) {	
        // for Display Model,set the "isOpen" attribute to "true"	
        component.set("v.isOpenreview", false);	
    },
    //EDGE-157962 Ends here
    

    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        component.set("v.isSelectAll",false);
        component.set("v.isInvoiceLineItem",false);
        //Start of EDGE-142645 checking if the user selected primary checkbox and resetting hidbutton based on the values in ChildPaginationMap
        var mapUsage = component.get("v.childPaginationMap");           		
        let strMap = new Map();
        for (let parentKey of Object.values(mapUsage)) {
            for(let childKey of Object.values(parentKey)){
                console.log('child key',childKey);
                if(childKey != ''){    
                    strMap= childKey;
                }
            }
        }        
        console.log('strMap in close window',strMap);
        if (strMap.length > 0 )        {
            component.set("v.hideButton",false); 
        } 
        else{
            component.set("v.hideButton",true);
        }
        //End of EDGE-142645
        component.set("v.isOpen", false);
    },
    //Setting sorting field and direction for lightning data table
    updateColumnSorting: function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    /*---------------------------------------------------------------------------------------
    Name : navigation
    Description : Method to set pagination parameters when Navigation Buttons are clicked
    Story: EDGE-126965
    Author:Manjunath Ediga
    **paginationMapInt is internal map in invoice component to handle selected rows as value and current page as Key
    **checkRows is an attribute to hold slected records out of which retriving corresponding Chargeid selected
    **noRowsSelected attribute to check if any rows selected on the current Page.
     -----------------------------------------------------------------------------------*/
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.dataTableReturnVal");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get('v.name');
        var currentPage = component.get("v.currentPage");   
        var paginationMapInt = component.get("v.paginationMapInt");
        var rowsSelected = component.get("v.noRowsSelected");
		let strMap = new Array();       
        var selectedListInPagination = paginationMapInt[currentPage]; 
        var selectedRows = component.get("v.checkRows");
        component.set("v.isPagination",true);
        //Check if any of the rows selected or unselected and process the charge identifier to add to paginationMapInt
       if(rowsSelected){
            var chargeidArray = new Array();        
            if(selectedRows != undefined && selectedRows.length >0){
                for(var i=0;i<selectedRows.length;i++){
                    var data = selectedRows[i]; 
                    chargeidArray.push(data.Chargeid);
                }
            }
            paginationMapInt[currentPage] = chargeidArray;
       }
        console.log('paginationMapInt innavigation',JSON.stringify(paginationMapInt)); 
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize,paginationMapInt,currentPage);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize,paginationMapInt,currentPage);
        }
       
    },
        /*---------------------------------------------------------------------------------------
    Name : handleRowAction
    Description : Method to handle row actions i.e when checkbox are selected or deselected
    story: EDGE-126965
    Author:Pradeep
    Modified: Manjunath Ediga(EDGE-139436)
    **paginationMapInt is internal map in invoice component to handle selected rows as value and current page as Key
     -----------------------------------------------------------------------------------*/
    handleRowAction: function(component, event, helper) {
        var selectR = event.getParam('selectedRows');
        component.set("v.checkRows",selectR);
        //Start of EDGE-126965 - Capturing the boolean value whether checkboxes are selected or not in current page
        component.set("v.noRowsSelected",true);
        //Start of EDGE-139436
        var summaryKey = component.get("v.summaryKey");
        var currentPage = component.get("v.CurrentPage");
        var currentPage1 = component.get("v.currentPage");
        var paginationMapInt = component.get("v.paginationMapInt");
        var childPaginationMap = component.get("v.childPaginationMap");
        var previousSelected = component.get("v.isPagination");
        console.log('previousSelected',JSON.stringify(paginationMapInt));
        var listFromMap =  paginationMapInt[currentPage];
        
        var rowsSelected = component.get("v.noRowsSelected");
        
        console.log('previousSelected in handle',previousSelected);
        //previousSelected boolean to avoid unnecessary callout of this functionality to persist selected values 
        if(previousSelected == false ){
            var chargeidArray = new Array(); 
            var checkedRow = [];         	
            var selectAllKey = [];	
            var selectList;
            if(selectR != undefined && selectR.length >0){
                var uniqueArray = [];	
               checkedRow = component.get("v.selectAllCheckRow");
                for(var i=0;i<selectR.length;i++){
                    checkedRow.push(selectR[i]);
                    var data = selectR[i]; 
                    chargeidArray.push(data.Chargeid);
                    //checkedRow = selectList.concat(selectR[i]);	
                    selectAllKey.push(data.Chargeid);
                    component.set("v.disableCaseButton",false);
                }
                for(var i=0; i < checkedRow.length; i++){	
                    if(uniqueArray.indexOf(checkedRow[i]) === -1) {	
                        uniqueArray.push(checkedRow[i]);	
                    }	
                }	
                //component.set("v.selectAllCheckRow",uniqueArray);
            }
            summaryKey[currentPage] = chargeidArray;
            paginationMapInt[currentPage] = chargeidArray;
            //delete map key if value of the key is null when checkbox is uncheked
            var keysAll = component.get("v.selectAllCheckboxKey");	
            var selecRows = [];
            for(let key of Object.keys(paginationMapInt)){
                selecRows.push(key);
                if(paginationMapInt[key] == ''){
                    delete paginationMapInt[key];
                }
            }
            //verify if the selected values are present across the pages if so disablecase button to false
            if(Object.entries(paginationMapInt).length > 0){
                 var selcCheckbox = [];	
                var selcCheckboxnoRow = [];
                for(var selValue of Object.values(paginationMapInt)){
                    console.log('selValue is',selValue);
                    for(var i=0; i<selValue.length;i++){	
                        selcCheckbox.push(selValue[i]);	
                        component.set("v.selectAllCheckboxKey",selcCheckbox);	
                    }
                    if(selValue != '' ){ 
                        component.set("v.disableCaseButton",false);
                        delete childPaginationMap[selValue];
                    }
                }
            }
            else {
                component.set("v.disableCaseButton",true);
                component.set("v.selectAllCheckboxKey",selcCheckboxnoRow);	
            }
			console.log('child pagination in handle', JSON.stringify(component.get("v.childPaginationMap")));
            //Logic to delete previously selected drilldown records in Usage as soon as primary is selected
            let strMap = new Map();
            for (let parentKey of Object.values(childPaginationMap)) {
                for(let childKey of Object.values(parentKey)){
                    console.log('child key',childKey);
                    if(childKey != ''){    
                        strMap= childKey;
                    }
                }
            }        
            console.log('strMap',strMap);
            if (strMap.length > 0 )        {
                component.set("v.hideButton",false); 
            } 
            else{
                component.set("v.hideButton",true);
            }
        }
        //End of Defect EDGE-142645
        //End of EDGE-139436
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
        //End of EDGE-126965
    },
    /*EDGE-121428
    Name: InvoiceCmpController.js
    Description: Js controller for Case Creation
    Author:Pradeep Bhumi*/
    handleCaseCreation : function(component, event, helper) {
        //EDGE-133408 - Component start - Getting all selected usage identifiers from which recieved from usage summary
        var childPaginationMap = component.get("v.childPaginationMap");
        console.log('childPaginationMap::: '+JSON.stringify(childPaginationMap));
        console.log('childPaginationKey::: '+Object.keys(childPaginationMap));
        let parentToChildIdMap = new Map();
        let finalChargeList = new Array();
        let chargeIDList = new Array();
        var qliTransactionId =component.get("v.QLIMap");
        console.log('qliTransactionId:::',qliTransactionId);
        let transactionid = new Array();
        for (let key of Object.keys(childPaginationMap)) {
            finalChargeList.length = 0;
            chargeIDList.length = 0;
            if(childPaginationMap[key] != ''){
                parentToChildIdMap = childPaginationMap[key];
                console.log('key' + ' = ' +JSON.stringify(parentToChildIdMap));
            }
            for(let childKey of Object.keys(parentToChildIdMap)){
                finalChargeList.push(parentToChildIdMap[childKey]);
            }
            chargeIDList=[].concat.apply([],finalChargeList); 
            console.log('chargeIDList=====>',chargeIDList);
            for(let transactionKey of chargeIDList){
                transactionid.push(qliTransactionId[transactionKey]);
                console.log('transactionKey:',transactionKey);
                console.log('Transaction id :', transactionid);
            }
        }

        var enteredEmail = component.get("v.selectedLookUpRecord.Email");
        var enteredDescription = component.get("v.newCaseObject.Description");
        var enteredSubject = component.get("v.newCaseObject.Subject");
            var selectedRcRecords = [];
            var mapUsage = component.get("v.paginationMapInt");           		
            for (let chargeid of Object.values(mapUsage)) {
                if(chargeid != ''){    
                    selectedRcRecords.push(chargeid);
                }
            }    
			var chargeIdentifierList = component.get("v.invoiceTransactionIdLWC"); 
            for (var i=0;i<chargeIdentifierList.length;i++) {
                  
                    transactionid.push(chargeIdentifierList[i]);
            }
            //Added for EDGE-207867 by Aman Soni || Start
            var caseType = component.get("v.caseValues");
            var existingCaseMapData=component.get("v.caseInputMap");
            existingCaseMapData["caseId"]= JSON.stringify(component.get("v.selectedLookUpRecord.Id"));
            existingCaseMapData["invLineItemData"]=component.get("v.responseInvObj");
            existingCaseMapData["chargeIdList"]=component.get("v.selectedRowss");
            existingCaseMapData["rcChargeIds"]=selectedRcRecords;
            existingCaseMapData["transactionIdList"]=transactionid;
            existingCaseMapData["childIdList"]=chargeIDList;
            //Added for EDGE-207867 by Aman Soni || End

            var caseMapData=component.get("v.caseInputMap");
            //add  params      
            caseMapData["caseData"]= JSON.stringify(component.get("v.newCaseObject"));
            caseMapData["invLineItemData"]=component.get("v.responseInvObj");
        //START of EDGE-127943: For passing the contact email selected to the case
            caseMapData["contacteMail"]=enteredEmail;
        //END of EDGE-127943: For passing the contact email selected to the case
            caseMapData["chargeIdList"]=component.get("v.selectedRowss");
            caseMapData["rcChargeIds"]=selectedRcRecords;
            //EDGE-133408 - Component start 
            caseMapData["transactionIdList"]=transactionid;
            caseMapData["childIdList"]=chargeIDList;   
            //EDGE-133408 - component End

            //Added if/else condition for EDGE-207867 by Aman Soni || Start
            var action;
            if(caseType == 'Add to Existing Case'){
                action=  component.get("c.existCaseRecord");
                action.setParams({
                    "caseMap" : existingCaseMapData
                });
            }else{
                action=  component.get("c.CreateCaseRecord");
            action.setParams({
                "caseMap" : caseMapData
            });
            }
            //Added if/else condition for EDGE-207867 by Aman Soni || End

            //Added for EDGE-207869 by Aman Soni || Start
            var caseTypeCheck = '';
            var infomessage = '';
            var infotitle = '';
            var infotype = '';

            var cusSetList =[];
            cusSetList = component.get("v.SharedDisplayMessageCS");
            var msgForExistingCase = '';
            var msgForNewCase = '';
            for(var csRec of cusSetList){
                if(csRec.Name === "MsgForExistingCase"){
                    msgForExistingCase = csRec.Value__c;   
                }else if(csRec.Name === "MsgForNewCase"){
                    msgForNewCase = csRec.Value__c;  
                }
            }
            if(caseType == 'Add to Existing Case'){
                caseTypeCheck = caseType;
                infomessage = msgForExistingCase;
                infotitle = "Info";
                infotype = "info";
            }else{
                caseTypeCheck = caseType;
                infomessage = msgForNewCase;
                infotitle = "Info";
                infotype = "info";
            }
            if(caseTypeCheck != ''){
                helper.showCustomToast(component,infomessage,infotitle,infotype);
            }
            //Added for EDGE-207869 by Aman Soni || End

            helper.showSpinner(component);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.hideSpinner(component);
                    var caseResult = response.getReturnValue();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": caseResult,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();     
                }
                else if (status === "ERROR") {
                    console.log("Error: " + response.getReturnValue());
                }
            });
            $A.enqueueAction(action);   
        //}       
    },
    //Added for EDGE-207867 by Aman Soni || Start
    clearOnRadioButtonChange :function(component,event,heplper){
        var caseType = component.get("v.caseValues");
        if(caseType == 'Add to Existing Case'){
            component.set("v.newCaseObject.Subject",'');
            component.set("v.newCaseObject.Description", '');
            //Added for EDGE-207869 by Aman Soni || Start
            component.set('v.invoiceColumn', [
                {
                    label: 'Invoice Number',
                    fieldName: 'invoiceNum',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Payments And Adjustments',
                    fieldName: 'adjustments',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Balance Carried Forward',
                    fieldName: 'balCarryFwd',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'New Charges',
                    fieldName: 'newCharge',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Queried Charge',
                    fieldName: 'queriedCharge',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Total Due',
                    fieldName: 'totDue',
                    type: 'string',
                    sortable: false
                },
                {
                    label: 'Due Date',
                    fieldName: 'dueDate',
                    type: 'text',
                    sortable: false
                }
            ]);
        }else{         
            component.set("v.selectedLookUpRecord.Subject",'');
            component.set("v.selectedLookUpRecord.Contact.Name", null);
            component.set("v.selectedLookUpRecord.Description", '');
            component.set('v.invoiceColumn', [
                {
                    label: 'Invoice Number',
                    fieldName: 'invoiceNum',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Payments And Adjustments',
                    fieldName: 'adjustments',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Balance Carried Forward',
                    fieldName: 'balCarryFwd',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'New Charges',
                    fieldName: 'newCharge',
                    type: 'text',
                    sortable: false
                },
                {
                    label: 'Total Due',
                    fieldName: 'totDue',
                    type: 'string',
                    sortable: false
                },
                {
                    label: 'Due Date',
                    fieldName: 'dueDate',
                    type: 'text',
                    sortable: false
                }
            ]);
            var initInvoiceDetails = [];
            var prevInvoiceDetails = component.get("v.prevInvoiceDetails");
            for(var delQli of prevInvoiceDetails){
                delete delQli['queriedCharge'];
                initInvoiceDetails.push(delQli);
            }
            component.set("v.invoiceDetails",initInvoiceDetails);
            console.log('invoiceDetails-->',initInvoiceDetails);
            //Added for EDGE-207869 by Aman Soni || End  
        }          
    },
    //Added for EDGE-207867 by Aman Soni || End

    //Added for EDGE-207869 by Aman Soni || Start
    GetExistQlIAgainstCaseAndInvoiceCntrl : function(component, event, helper){
        var cas = event.getParam("caseByEvent");
        component.set("v.existCaseId" , cas.Id);
        var exisCaseId = component.get("v.existCaseId");
        var selValue = component.get("v.selectedInvoicerecord");	
        var splitInvo = selValue.split('-');
        var selInvoice=splitInvo[0];      
        var invoiceNum = selInvoice.trim();
        if(exisCaseId != '' && invoiceNum != ''){
            helper.GetExistQlIAgainstCaseAndInvoiceHlpr(component, event, exisCaseId, invoiceNum); 
        } 
    },
    //Added for EDGE-207869 by Aman Soni || End
    
    //Added for EDGE-215753 by Akanksha|| Start
    setValueForReviewTable : function(component, event, helper){
        var selectedRows = event.getParam("reviewTableData");
        var chargeType = event.getParam("chargeType");
        let dataMap = event.getParam("selectedRowMap");
        let rowData = event.getParam("rowData");
        let mapRowToChargeId = new Map(event.getParam("mapOfRowsForReview"));
        component.set("v.childPageMapData", rowData);
        component.set("v.childPageMapDataRows", dataMap);
        component.set("v.badgeCount",selectedRows.length);
        component.set("v.mapOfRowsToChargeId",mapRowToChargeId);
        var selRowData = component.get("v.paginationList");
        component.set("v.isOpen",false);
        var finalRows =[];
        var invoiceTransactionId =[];
        if(mapRowToChargeId.size>0)
        {
            mapRowToChargeId.forEach((values,keys)=>{
              finalRows = finalRows.concat(values); 
    		})   
        } 
        for(var i=0;i<finalRows.length;i++)
        {
            invoiceTransactionId.push(finalRows[i].invoiceTransactionId);
        }
   console.log('chargeIdentifier',invoiceTransactionId);
   component.set("v.invoiceTransactionIdLWC",invoiceTransactionId);
       component.set("v.reviewTableData",finalRows);  
       component.set("v.disableCaseButton",false);
       component.set("v.hideButton",false);
       component.set("v.showBadge", true);
    },
    //Added for EDGE-215753 by Akanksha || End
})