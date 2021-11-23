/**************************************************************************
EDGE        -108332,92016,124071
component   -UsageSummaryController
Description -Controller for UsageSummary
Author      -Sasidhar Devarapalli
Modified    -Manjunath Ediga
Team        -Osaka
*********************************************************************************/
({
    doInit : function(component, event, helper) {
        var isInvoiceLineItemVar = component.get("v.isInvoiceLineItem");
        if(isInvoiceLineItemVar ){
          helper.getInvoiceTransactionId(component, event);  
        }
        //helper.getInvoiceTransactionId(component, event);
        console.log('Invoice Transaction Id----->',component.get("v.invoiceTransactionId"));
        helper.getUsageLabels(component, event);
        helper.getdoInit(component, event);
        helper.InvoiceLineDownload(component, event);

    },
    changeData:function(component, event, helper){
        helper.changeData(component, event);

    },
     /*---------------------------------------------------------------------------------------
    Name : doSelectRecord
    Description : Method to capture selected/deselected rows when check or uncheck action is happened
    Story: EDGE-92016
     -----------------------------------------------------------------------------------*/  
    doSelectRecord : function(component, event, helper){
        var selectR = event.getParam('selectedRows');
        console.log('selectedRows in doselect',selectR);
        component.set("v.selectedRows",selectR);
        component.set("v.BooleanVar",true);
        //EDGE-157955 changes - Start
        var paginationMap = component.get("v.paginationMapInt");
        var selectedRowArray = new Array();    
        var currentPage = component.get("v.CurrentPage");
        if(selectR != undefined && selectR.length >0){
            for(var i=0;i<selectR.length;i++){
                var data = selectR[i]; 
                if(data.chargeIdentifier != null){
                    selectedRowArray.push(data.chargeIdentifier);
                }
            }
        }
        paginationMap[currentPage] = selectedRowArray;
        component.set("v.paginationMapInt",paginationMap);
        //EDGE-157955 changes - End
      //  }

     },
        /*---------------------------------------------------------------------------------------
    Name : makeSelection
    Description : Method to capture selected rows when Save and return to Invoice Button is clicked
    Story: EDGE-92016,126965
    Author:Sasidhar Devarapalli
    Modified: Manjunath Ediga(EDGE-126965)
     -----------------------------------------------------------------------------------*/    
    makeSelection : function (component, event, helper) {
        var selectedRows = component.get("v.selectedRows");
        var RowsSelected = component.get("v.BooleanVar");
        //Start of EDGE-126965
        //var currentPage = component.get("v.currentPage");
         var currentPage = component.get("v.CurrentPage"); //Fix for INC000094609098
        var mapKey = component.get("v.mapKey");
        var uniqueKey = mapKey +currentPage;
        var paginationMap = component.get("v.paginationMapInt");
        //Check if any of the rows selected or unselected and process the charge identifier to add to paginationMapInt
        if(RowsSelected){
            var chargeIdentifierArray = new Array();        
            if(selectedRows != undefined && selectedRows.length >0){
                for(var i=0;i<selectedRows.length;i++){
                    var data = selectedRows[i]; 
                    if(data.chargeIdentifier != null){
                    chargeIdentifierArray.push(data.chargeIdentifier);
                }
                }
                component.set("v.selectedReords",chargeIdentifierArray);
            }
            paginationMap[currentPage] = chargeIdentifierArray;
        }
         //component.set("v.paginationMapInt",paginationMap);
        //adding the id and selected charge identifiers
        var ChargeMap = component.get("v.ChargeIdMap");
        var mapkey = component.get("v.mapKey");
        ChargeMap[mapkey] = chargeIdentifierArray;
        component.set("v.ChargeIdMap",ChargeMap);
        //End of EDGE-126965
        var cmpEvent = component.getEvent("UsageInvoice");
        var SelRows = component.get("v.selectedReords");
        var usgRows = component.get("v.usageCharges");
        var ChargeMap = component.get("v.ChargeIdMap");
        //var mapKey = component.get("v.mapKey");
        var paginationMapInt = component.get("v.paginationMapInt");
        var paginationMapToParent = component.get("v.childPaginationMap");
        paginationMapToParent[mapkey] = paginationMapInt;        
        component.set("v.childPaginationMap",paginationMapToParent);
        var paginationMapToSend = component.get("v.childPaginationMap");
        var QLIMapToSend = component.get("v.QLIMap");
        console.log('paginationMapToSend',JSON.stringify(paginationMapToSend));
        cmpEvent.setParams({
            'Alldata' : SelRows,
            'UsageList':usgRows,
            'ChargeIdMap':ChargeMap,
            'mapKey':mapKey,
            'selectedRows':selectedRows,
            //Start of EDGE-126965
            'paginationMap':paginationMapToSend,
            //End of EDGE-126965
            //Start of EDGE-133408  Component 
            'QLIMapToParent':QLIMapToSend
            //End of EDGE-133408 component
			});
        cmpEvent.fire();
    },
        /*---------------------------------------------------------------------------------------
    Name : navigation
    Description : Method to set pagination parameters when Navigation Buttons are clicked
    Story: EDGE-124071,126965
    Author:Manjunath Ediga
    Modified: Manjunath Ediga(EDGE-126965)
     -----------------------------------------------------------------------------------*/
        navigation: function(component, event, helper) {
        var sObjectList = component.get("v.usageCharges");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get('v.name');
        var currentPage = component.get("v.currentPage");   
       //Start of EDGE-126965
        var paginationMapInt = component.get("v.paginationMapInt");
        var mapKey = component.get("v.mapKey");
        var uniqueKey = mapKey +currentPage;
        var rowsSelected = component.get("v.BooleanVar");
        //Check if any of the rows selected or unselected and process the charge identifier to add to paginationMapInt
        if(rowsSelected){
        var selectedRows = component.get("v.selectedRows");
		var chargeIdentifierArray = new Array();        
            if(selectedRows != undefined && selectedRows.length >0){
                for(var i=0;i<selectedRows.length;i++){
                    var data = selectedRows[i]; 
                    chargeIdentifierArray.push(data.chargeIdentifier);
                }
            }
        paginationMapInt[currentPage] = chargeIdentifierArray;
        }
       //End of EDGE-126965
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
            else if (whichBtn == 'last') {
                component.set("v.currentPage", component.get("v.totalPagesCount"));
                helper.last(component, event, sObjectList, end, start, pageSize,paginationMapInt,currentPage);
            } 
        else if (whichBtn == 'first') {
            component.set("v.currentPage","1");
            helper.first(component, event, sObjectList, end, start, pageSize,paginationMapInt,currentPage);
        } 
    },
/*---------------------------------------------------------------------------------------
    Name : sectionUsageDetails
    Description : Method to download the data from Invoice page
    Story: EDGE-124068
    Author:Mohammed Zeeshan
-----------------------------------------------------------------------------------*/     
     sectionUsageDetails : function(component, event, helper) {
       helper.helperSectionUsage(component,event,'section');
    },
/*---------------------------------------------------------------------------------------
    Name : sectionUsageDetails
    Description : Method to download the data from Invoice page
    Story: EDGE-124068
    Author:Mohammed Zeeshan
-----------------------------------------------------------------------------------*/     
     sectionUsageDetails : function(component, event, helper) {
       helper.helperSectionUsage(component,event,'section');
    },
/*---------------------------------------------------------------------------------------
    Name : downloadCsv
    Description : Method to download the data from Invoice page
    Story: EDGE-124068
    Author:Mohammed Zeeshan
     -----------------------------------------------------------------------------------*/ 
    downloadCsv : function(component,event,helper){
        // Fetch Invoice data
        var invoiceLineItemRec = component.get("v.ListofInvoiceLineItem");
        // Fetch Usage List
        var usagelist = component.get("v.usageCharges"); 
        console.log('complete usagelist ',usagelist);  
        var csv = helper.convertArrayOfObjectsToCSV(component,invoiceLineItemRec,usagelist);
        //console.log('csv',csv);                                           
        if (csv == null){return;} 
        var hiddenElement = document.createElement('a');
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD hh:mm:ss");
        component.set('v.today', today);
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; 
        hiddenElement.download = 'Salesforce-Downloaded Usage Line Item details-'+today+'.csv';  
        document.body.appendChild(hiddenElement);
        hiddenElement.click(); 
    },
        /*---------------------------------------------------------------------------------------
    Name : First
    Description : Method to set pagination parameters when previous Button is clicked
    Story: EDGE-
    Author:Mohammed Zeesan
     -----------------------------------------------------------------------------------  
        first : function(component,event,sObjectList,end,start,pageSize,paginationMapInt,currentPage)
        {
            var paginationlist = [];
            for(var i=0; i< pageSize; i++)
            {
                paginationList.push(oppList[i]);
            }
            component.set('v.PaginationList', paginationlist);
        },*/
})