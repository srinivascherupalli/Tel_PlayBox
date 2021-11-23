/*EDGE-92010
Name: InvoiceCmpHelper.js
Description: Js helper for InvoiceCmp
Author:Manjunath Ediga
Change Mgmt: Added includingGSTcostFmtd and excludingGSTcostFmtd for EDGE-157960 on 9-9-2020
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207869         07/06/2021
***************************************************************************************************
*/
({  
    getInvoice: function(component ,event,invoiceNum) {  
        component.set("v.IsError",false);
        var invoiceId = invoiceNum;
        var billingAccId= component.get("v.billingAccountId");
        var invoiceLineItemId= component.get("v.recordId");
        
        component.set("v.loadingSpinner", true);
        //calling controller method getInvoiceDetailsList 
        var action= component.get("c.getInvoiceDetailsList");
        action.setParams({"custom_AccNumber" :billingAccId , "Invoice_num":invoiceId} );
        action.setCallback(this, function(response) {
            var state = response.getState();
           // console.log('state is',state);
            component.set("v.loadingSpinner", false);
            if(state === "SUCCESS") {
                console.log('actual response'+response.getReturnValue());
                var responseObj1 = response.getReturnValue();
                var resultmessage = String(responseObj1);
                var errormessage = resultmessage.search("JDBCConnectionException");
                var errormessage1 = resultmessage.search("Invoice data not found");
                var serverError = resultmessage.search("invoice.server.error");
                //console.log('serverError value',serverError);
                var hasError = responseObj1.startsWith("<!");
                 //console.log('errormessage1 '+errormessage1);
                
                if(hasError == false && errormessage === -1 && errormessage1 === -1 && serverError === -1 ){
                    var responseObj = JSON.parse(response.getReturnValue());
                    // Forming the invoice details object with the required data
                    var invDataTable = [];
                    invDataTable.push({
                        invoiceNum: responseObj.invoiceDetails.invoiceNumber,
                        balCarryFwd: String(responseObj.paymentSummary.balanceCarriedForward),
                        totDue: String(responseObj.paymentSummary.totalDue),
                        adjustments: String(responseObj.paymentSummary.paymentsAndAdjustments),
                        newCharge: String(responseObj.paymentSummary.newCharges),
                        dueDate: responseObj.paymentSummary.dueDate
                    });
                    //EDGE-157957-Start:  All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbole
                    
                    //console.log('invDataTable--->',invDataTable);
                    var invDataTableDollar =[];
                    // Taking values from invDataTable ,iterating and adding $ symbol and  pusing it via invDataTableDollar 
                    for(var iDT of invDataTable){
                        var str = '$';
                        iDT.adjustments = str.concat(iDT.adjustments);
                        iDT.balCarryFwd = str.concat(iDT.balCarryFwd);
                        iDT.newCharge = str.concat(iDT.newCharge);
                        iDT.totDue = str.concat(iDT.totDue);
                        invDataTableDollar.push(iDT);
                    }
                    //console.log('invDataTableDollar----->',invDataTableDollar);
                    
                    //EDGE-157957-End:  All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbole
                    var ServiceSummary = { 
                        offerName: responseObj.serviceSummary.listOfOffers[0].offerName
                    };
                    // Forming the invoice LineItem details with the required data
                    //component.set("v.invoiceDetails",invDataTable);
                    component.set("v.prevInvoiceDetails",invDataTableDollar);//Added for EDGE-207869 by Aman Soni
                    component.set("v.invoiceDetails",invDataTableDollar);
                    component.set("v.ServiceSummary",ServiceSummary);
                    component.set("v.listOfOffers",responseObj.serviceSummary.listOfOffers);
                    component.set("v.responseInvObj", JSON.stringify(responseObj));
                    
                    var listOfOffers = responseObj.serviceSummary.listOfOffers;
                    //console.log('listOfOffers is',listOfOffers);
                    var enableDrilldown = component.get("v.enableDrilldown");
                    var dataTableReturnVal = [];
                    var rowIdToRowMap = new Map();
                    var mapTemp = new Map();
                    //EDGE-141682 - Component Start:Map fo chargeID to usageType Code
                    var usageTypecodeMap = new Map();
                    //EDGE-141682 - Component End
                    
                    for(var k=0; k<listOfOffers.length; k++ ) {
                        var offer = listOfOffers[k];
                        //console.log('offer',offer);
                        if(offer.invoiceDef == 1){
                            //console.log('invoicedef',offer.invoiceDef)
                            for(var prds of offer.listOfProducts) {
                                if(prds.listOfChargesAndCredits.planCharges){
                                for(var pc of prds.listOfChargesAndCredits.planCharges) {
                                    dataTableReturnVal.push({
                                        dis: (pc.drillDownEndpoint !== undefined && enableDrilldown === true)?false:true,//EDGE-215753
                                        badgeClass:"",//EDGE-215753
                                        buttonLabel:"",//EDGE-215753
                                        labelVariant:"",
                                        offerName: offer.offerName,
                                        physicalLocationName: prds.physicalLocationName,
                                        //Start of EDGE-130452
                                        quantity:String(pc.quantityWithUnit),
                                        //End of EDGE-130452
                                        chargedescription:pc.serviceType,
                                        includingGSTcost:String(pc.includingGstCost),
                                        excludingGSTcost:String(pc.excludingGstCost),
                                        chargeType:pc.chargeType,
                                        startDate:pc.startDate,
                                        endDate:pc.endDate,
                                        Chargeid:String(pc.chargeIdentifier),
                                        drillDownEndPoint: pc.drillDownEndpoint,
                                        includingGSTcostFmtd: pc.includingGstCost < 0 && pc.isTaxable === false ? '$'+String((pc.includingGstCost * -1).toFixed(2))+' Cr †' : (pc.includingGstCost < 0 ? '$'+String((pc.includingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (pc.isTaxable === false ? '$'+String((pc.includingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((pc.includingGstCost).toFixed(2))+Array(8).fill('\xa0').join(''))),
                                        excludingGSTcostFmtd: pc.excludingGstCost < 0 && pc.isTaxable === false ? '$'+String((pc.excludingGstCost * -1).toFixed(2))+' Cr †' : (pc.excludingGstCost < 0 ? '$'+String((pc.excludingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (pc.isTaxable === false ? '$'+String((pc.excludingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((pc.excludingGstCost).toFixed(2))+Array(8).fill('\xa0').join('')))
                                    });
                                }
                             }
                                if(prds.listOfChargesAndCredits.onceOffChargesAndCredits) {
                                    for(var ooc of prds.listOfChargesAndCredits.onceOffChargesAndCredits) {
                                        dataTableReturnVal.push({
                                            dis:  (ooc.drillDownEndpoint !== undefined && enableDrilldown === true)?false:true, //EDGE-215753
                                            badgeClass:"",//EDGE-215753
                                        	buttonLabel:"",//EDGE-215753
                                            labelVariant:"",
                                            offerName: offer.offerName,
                                            physicalLocationName: prds.physicalLocationName,
                                            //Start of EDGE-130452
                                            quantity:String(ooc.quantityWithUnit),
                                            //End of EDGE-130452
                                            chargedescription:ooc.serviceType,
                                            includingGSTcost:String(ooc.includingGstCost),
                                            excludingGSTcost:String(ooc.excludingGstCost),
                                            chargeType:ooc.chargeType,
                                            startDate:'',
                                            endDate:'',
                                            Chargeid:String(pc.chargeIdentifier),
                                            drillDownEndPoint: ooc.drillDownEndpoint,
                                            includingGSTcostFmtd: ooc.includingGstCost < 0 && ooc.isTaxable === false ? '$'+String((ooc.includingGstCost * -1).toFixed(2))+' Cr †' : (ooc.includingGstCost < 0 ? '$'+String((ooc.includingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (ooc.isTaxable === false ? '$'+String((ooc.includingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((ooc.includingGstCost).toFixed(2))+Array(8).fill('\xa0').join(''))),
                                            excludingGSTcostFmtd: ooc.excludingGstCost < 0 && ooc.isTaxable === false ? '$'+String((ooc.excludingGstCost * -1).toFixed(2))+' Cr †' : (ooc.excludingGstCost < 0 ? '$'+String((ooc.excludingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (ooc.isTaxable === false ? '$'+String((ooc.excludingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((ooc.excludingGstCost).toFixed(2))+Array(8).fill('\xa0').join('')))
                                        });
                                    }
                                }
                                if(prds.listOfChargesAndCredits.usageSummaryCharges) {
                                    for(var usg of prds.listOfChargesAndCredits.usageSummaryCharges) {
                                        dataTableReturnVal.push({
                                            offerName: offer.offerName,
                                            dis: false,
                                            badgeClass:"",//EDGE-215753
                                            buttonLabel:"",//EDGE-215753
                                            labelVariant:"",
                                            physicalLocationName: prds.physicalLocationName,
                                            quantity:usg.units,
                                            chargedescription:usg.usageTypeName,
                                            includingGSTcost:String(usg.includingGstCost),
                                            excludingGSTcost:String(usg.excludingGstCost),
                                            chargeType:usg.chargeType ,
                                            startDate:'',
                                            endDate:'',
                                            Chargeid: usg.drillDownInputAttribute.chargeId != '' ? String(usg.drillDownInputAttribute.chargeId) : null,
                                            includingGSTcostFmtd: usg.includingGstCost < 0 && usg.isTaxable === false ? '$'+String((usg.includingGstCost * -1).toFixed(2))+' Cr †' : (usg.includingGstCost < 0 ? '$'+String((usg.includingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (usg.isTaxable === false ? '$'+String((usg.includingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((usg.includingGstCost).toFixed(2))+Array(8).fill('\xa0').join(''))),
                                            excludingGSTcostFmtd: usg.excludingGstCost < 0 && usg.isTaxable === false ? '$'+String((usg.excludingGstCost * -1).toFixed(2))+' Cr †' : (usg.excludingGstCost < 0 ? '$'+String((usg.excludingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (usg.isTaxable === false ? '$'+String((usg.excludingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((usg.excludingGstCost).toFixed(2))+Array(8).fill('\xa0').join('')))
                                        });
                                        mapTemp[usg.drillDownInputAttribute.chargeId] = usg.drillDownInputAttribute;
                                        //Start of EDGE-141682 to get the map of UsageType code with each chargeID
                                        usageTypecodeMap[usg.drillDownInputAttribute.chargeId] = usg.drillDownInputAttribute.usageTypeCode;
                                        //End of EDGE-141682 
                                    }   
                                    component.set('v.rowIdToRowMap', mapTemp);
                                   //EDGE-141682 - Component Start
                                    component.set('v.usageTypecodeMap', usageTypecodeMap);
                                    //EDGE-141682 - Component End
                                }
                            }
                        }
                        
                        if(offer.invoiceDef == 2 || offer.invoiceDef == 3 ){
                            if(offer.listOfChargesAndCredits.planCharges) {
                                for(var pc of offer.listOfChargesAndCredits.planCharges) {
                                    //console.log("Chargeid:"+pc.chargeIdentifier);
                                    dataTableReturnVal.push({
                                        dis:(pc.drillDownEndpoint != undefined && enableDrilldown === true)?false:true, //EDGE-215753
                                        badgeClass:"",//EDGE-215753
                                        buttonLabel:"",//EDGE-215753
                                        labelVariant:"",
                                        offerName: offer.offerName,
                                        physicalLocationName: '',
                                        //Start of EDGE-130452
                                        quantity:String(pc.quantityWithUnit),
                                        //End of EDGE-130452
                                        chargedescription:pc.serviceType,
                                        includingGSTcost:String(pc.includingGstCost),
                                        excludingGSTcost:String(pc.excludingGstCost),
                                        chargeType:pc.chargeType,
                                        startDate:pc.startDate,
                                        endDate:pc.endDate,
                                        Chargeid:String(pc.chargeIdentifier),
                                        drillDownEndPoint: pc.drillDownEndpoint,
                                        includingGSTcostFmtd: pc.includingGstCost < 0 && pc.isTaxable === false ? '$'+String((pc.includingGstCost * -1).toFixed(2))+' Cr †' : (pc.includingGstCost < 0 ? '$'+String((pc.includingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (pc.isTaxable === false ? '$'+String((pc.includingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((pc.includingGstCost).toFixed(2))+Array(8).fill('\xa0').join(''))),
                                        excludingGSTcostFmtd: pc.excludingGstCost < 0 && pc.isTaxable === false ? '$'+String((pc.excludingGstCost * -1).toFixed(2))+' Cr †' : (pc.excludingGstCost < 0 ? '$'+String((pc.excludingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (pc.isTaxable === false ? '$'+String((pc.excludingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((pc.excludingGstCost).toFixed(2))+Array(8).fill('\xa0').join('')))
                                    });
                                }
                            }
                            if(offer.listOfChargesAndCredits.onceOffChargesAndCredits) {
                                for(var ooc of offer.listOfChargesAndCredits.onceOffChargesAndCredits) {
                                    dataTableReturnVal.push({
                                        dis: (ooc.drillDownEndpoint != undefined && enableDrilldown === true)?false:true, //EDGE-215753
                                        badgeClass:"",//EDGE-215753
                                        buttonLabel:"",//EDGE-215753
                                        labelVariant:"",
                                        offerName: offer.offerName,
                                        physicalLocationName: '',
                                        //Start of EDGE-130452
                                        quantity:String(ooc.quantityWithUnit),
                                        //End of EDGE-130452
                                        chargedescription:ooc.serviceType,
                                        includingGSTcost:String(ooc.includingGstCost),
                                        excludingGSTcost:String(ooc.excludingGstCost),
                                        chargeType:ooc.chargeType,
                                        startDate:'',
                                        endDate:'',
                                        Chargeid:String(ooc.chargeIdentifier),
                                        drillDownEndPoint: ooc.drillDownEndpoint,
                                        includingGSTcostFmtd: ooc.includingGstCost < 0 && ooc.isTaxable === false ? '$'+String((ooc.includingGstCost * -1).toFixed(2))+' Cr †' : (ooc.includingGstCost < 0 ? '$'+String((ooc.includingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (ooc.isTaxable === false ? '$'+String((ooc.includingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((ooc.includingGstCost).toFixed(2))+Array(8).fill('\xa0').join(''))),
                                        excludingGSTcostFmtd: ooc.excludingGstCost < 0 && ooc.isTaxable === false ? '$'+String((ooc.excludingGstCost * -1).toFixed(2))+' Cr †' : (ooc.excludingGstCost < 0 ? '$'+String((ooc.excludingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (ooc.isTaxable === false ? '$'+String((ooc.excludingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((ooc.excludingGstCost).toFixed(2))+Array(8).fill('\xa0').join('')))
                                    });
                                }
                            }
                            if(offer.listOfChargesAndCredits.usageSummaryCharges) {
                                for(var usg of offer.listOfChargesAndCredits.usageSummaryCharges) {
                                    dataTableReturnVal.push({
                                        offerName: offer.offerName,
                                        dis: false,
                                        badgeClass:"",//EDGE-215753
                                        buttonLabel:"",//EDGE-215753
                                        labelVariant:"",
                                        physicalLocationName: '',
                                        quantity:usg.units,
                                        chargedescription:usg.usageTypeName,
                                        includingGSTcost:String(usg.includingGstCost),
                                        excludingGSTcost:String(usg.excludingGstCost),
                                        chargeType:usg.chargeType ,
                                        startDate:'',
                                        endDate:'',
                                        Chargeid: String(usg.drillDownInputAttribute.chargeId),
                                        includingGSTcostFmtd: usg.includingGstCost < 0 && usg.isTaxable === false ? '$'+String((usg.includingGstCost * -1).toFixed(2))+' Cr †' : (usg.includingGstCost < 0 ? '$'+String((usg.includingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (usg.isTaxable === false ? '$'+String((usg.includingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((usg.includingGstCost).toFixed(2))+Array(8).fill('\xa0').join(''))),
                                        excludingGSTcostFmtd: usg.excludingGstCost < 0 && usg.isTaxable === false ? '$'+String((usg.excludingGstCost * -1).toFixed(2))+' Cr †' : (usg.excludingGstCost < 0 ? '$'+String((usg.excludingGstCost * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (usg.isTaxable === false ? '$'+String((usg.excludingGstCost).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((usg.excludingGstCost).toFixed(2))+Array(8).fill('\xa0').join('')))
                                    });
                                    mapTemp[usg.drillDownInputAttribute.chargeId] = usg.drillDownInputAttribute;
                                    //Start of EDGE-141682 to get the map of UsageType code with each chargeID
                                    usageTypecodeMap[usg.drillDownInputAttribute.chargeId] = usg.drillDownInputAttribute.usageTypeCode;
                                     //End of EDGE-141682 
                                    
                                }   
                                component.set('v.rowIdToRowMap', mapTemp);
                                //EDGE-141682 - Component Start
                                component.set('v.usageTypecodeMap', usageTypecodeMap);
                                //EDGE-141682 - Component End
                            }
                        }
                    }
                    component.set("v.dataTableReturnVal", dataTableReturnVal);
                    var objUncovered2 = JSON.stringify(component.get('v.rowIdToRowMap'));
					//Pagination impl-->Start EDGE-126965
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = component.get('v.dataTableReturnVal');
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var paginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get('v.dataTableReturnVal').length > i){
                            paginationLst.push(totalRecordsList[i]);    
                        } 
                    }
                    //Start of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
                    var paginationLstDollar =[];
                    for(var ili of paginationLst){
                        var str1 = '$'; 
                        ili.excludingGSTcost= str1.concat(ili.excludingGSTcost);
                        ili.includingGSTcost= str1.concat(ili.includingGSTcost);
                        paginationLstDollar.push(ili);                            
                    }
                   //component.set('v.paginationList', paginationLst);
                    component.set('v.paginationList', paginationLstDollar);
                    //End of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
                    var paglisttest = component.get("v.paginationLst");                    
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
               //End of EDGE-126965
               //Pagination impl-->End
               
                    var TotalPages = Math.ceil(totalLength / component.get("v.pageSize"));	
                           var appEvent = $A.get("e.c:paginationEvent");	
                        component.set("v.columns", paginationLst.length);	
                        component.set("v.TotalPages",TotalPages);	
                        component.set('v.deviceModel', totalRecordsList);	
                        component.set('v.PaginationList', paginationLst);	
                        var appEvent = $A.get("e.c:paginationEvent");
                    appEvent.setParams({	
                        PageData: component.get("v.deviceModel"),	
                        StartRecord: 1,	
                        EndRecord: 1,	
                        CurrentPage: component.get("v.CurrentPage"),	
                        TotalPages: TotalPages,	
                        PageSize: component.get("v.pageSize"),	
                        TotalRecords: component.get("v.deviceModel").length,	
                        componentName:component.get("v.componentName")	
                    });	
        appEvent.fire();	
        this.dispMethod(component);
                    
                }  else if(errormessage1 > 0){
                    console.log(response.getError());
                    component.set("v.errorMessage",$A.get("$Label.c.Invalid_Invoice_Number"));
                    component.set("v.IsError",true);
                    component.set("v.IsPageLoad", false);
                    
                } 
                    else {
                        console.log(response.getError());
                        component.set("v.errorMessage",$A.get("$Label.c.UsageError"));
                        component.set("v.IsError",true);
                   	    component.set("v.IsPageLoad", false);
                    }
                
            } else {
                console.log(response.getError());
                component.set("v.errorMessage",$A.get("$Label.c.Invalid_Invoice_Number"));
                component.set("v.IsError",true);  
                component.set("v.IsPageLoad", false);
            }
        });
        $A.enqueueAction(action);
        
    },
     
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
     getBillingAddress : function (component, event, helper) {	
        var customerAddress = component.get("v.customerAddress");	
        var billingAccId= component.get("v.billingAccountId");	
        var action= component.get("c.fetchBillingAddress");	
        action.setParams({"billingAccId" :billingAccId} );	
        action.setCallback(this, function(response) {	
            var state = response.getState();	
            console.log('state is',state);	
            if(state === "SUCCESS") {	
                console.log('actual response'+response.getReturnValue());	
                var responseObj1 = response.getReturnValue();	
                component.set("v.customerAddress",responseObj1);	
            }	
        })	
    $A.enqueueAction(action);	  	
    },
    //Show Error or success toast messages || Added/Modified by Aman Soni for EDGE-207869
    showCustomToast: function (cmp, message, title, type) {		
        $A.createComponent(
            "c:customToast", {
                "type": type,
                "message": message,
                "title": title
            },
            function (customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");
                    console.log("customComp body",customComp.get("v.body"));
                    body.set("v.body", customComp);
                } else if (status === "INCOMPLETE") {
                    console.log("no resonse");
                } else if (status === "ERROR") {
                    console.log("error : " + error);
                }
            }
        );
    },
/*---------------------------------------------------------------------------------------
    Name : next
    Description : Method to set pagination parameters when Next Button is clicked
    Story: EDGE-126965
    Author:Manjunath Ediga
     -----------------------------------------------------------------------------------*/
        next : function(component,event,sObjectList,end,start,pageSize,paginationMapInt,currentPage){
        var paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId")){
                    paginationlist.push(sObjectList[i]);
                }else{
                    paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
            start = start + counter;
            end = end + counter;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            //Start of EDGE-126965    
            currentPage++;        
        //Start of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
        var paginationLstDollar1 =[];
        //console.log('paginationlist--> Component.get',component.get("v.paginationList"));
        for(var ili1 of paginationlist){
            var str2 = '$';
            //var paglist = component.get("v.paginationList");
            if( ili1.excludingGSTcost.startsWith("$")){
                paginationLstDollar1.push(ili1);
            }else{
                ili1.excludingGSTcost= str2.concat(ili1.excludingGSTcost);
                ili1.includingGSTcost= str2.concat(ili1.includingGSTcost);
                paginationLstDollar1.push(ili1);
            }
        }
        //component.set('v.paginationList', paginationLst);
        component.set('v.paginationList', paginationLstDollar1);
        //End of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
        //component.set('v.paginationList', paginationlist);
        //console.log('paginationLst 329----->',component.get("v.paginationLst"));
            var listFromMap =  paginationMapInt[currentPage];
            if(listFromMap != undefined && listFromMap.length > 0 ){
               component.set("v.checkedRows",listFromMap);
            }
            console.log('ListFromMap in next'+listFromMap+'in next'+currentPage);
            //component.set("v.checkedRows",listFromMap);
            component.set("v.noRowsSelected",false);
            component.set("v.isPagination",false);
        
        
        },
    /*---------------------------------------------------------------------------------------
    Name : previous
    Description : Method to set pagination parameters when previous Button is clicked
    Story: EDGE-124071
    Author:Manjunath Ediga
    Modified: Manjunath Ediga(EDGE-126965)
     -----------------------------------------------------------------------------------*/  
    previous : function(component,event,sObjectList,end,start,pageSize,paginationMapInt,currentPage){
        var paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId")){
                    paginationlist.push(sObjectList[i]);
                }else{
                    paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        //Start of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
        var paginationLstDollar1 =[];
        for(var ili1 of paginationlist){
            var str2 = '$'; 
            if(ili1.excludingGSTcost.startsWith("$")){
                paginationLstDollar1.push(ili1);  
            }else{
                ili1.excludingGSTcost= str2.concat(ili1.excludingGSTcost);
                ili1.includingGSTcost= str2.concat(ili1.includingGSTcost);
                paginationLstDollar1.push(ili1);
            }  
        }
      //  component.set('v.paginationList', paginationLst);
        component.set('v.paginationList', paginationLstDollar1);
        //End of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
        //component.set('v.paginationList', paginationlist);
        console.log('paginationLst 366----->',component.get("v.paginationLst"));
        //Start of EDGE-126965
        //Update the selected Records in 
        currentPage--;
        var listFromMap =  paginationMapInt[currentPage];
        if(listFromMap != undefined && listFromMap.length > 0){
                component.set("v.checkedRows",listFromMap);
            }
        console.log('ListFromMap in previous'+listFromMap+'in previous'+currentPage);
        
       // component.set("v.checkedRows",listFromMap);
        component.set("v.noRowsSelected",false);
        component.set("v.isPagination",false);
        
    },
   /* //Start of EDGE-125609
    getConEmail: function(component ,event, helper) {  
        var billingAccId= component.get("v.billingAccountId");
        var action= component.get("c.getContactEmail");
        action.setParams({"billingAccNumber" :billingAccId} );
        action.setCallback(this, function(responseCon) {
            var state = responseCon.getState();
            console.log('state ',state);
            if(state === "SUCCESS") {
                var emailVal = responseCon.getReturnValue();
                component.set('v.ContactEmailId', responseCon.getReturnValue());
                var contactEmailRes = component.get("v.ContactEmailId");
            }
        });
        $A.enqueueAction(action);
    },*/
    //End of EDGE-125609
    
        
/*--------------------------------------------------------------------------------------------------
Name : getAllInvoices - EDGE-124070
Description : Method to invoke apex controller and get last 13 invoices for Selected Billing Account
----------------------------------------------------------------------------------------------------*/
   
    getAllInvoices : function(component, event, helper) {
        var billingAccId= component.get("v.billingAccId");
        var action= component.get("c.fetchInvoiceNumbers");
        action.setParams({"custBillingId":billingAccId});
        
		action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
            component.set('v.invoiceMap',response.getReturnValue());
            var mapUsage = component.get("v.invoiceMap");
            for (let key of Object.keys(mapUsage)) {     
            var responseInvoice = JSON.parse(mapUsage[key]);
            var invoiceNumber=responseInvoice.allInvoices;
                //console.log('invoiceNumber',invoiceNumber);
             if(key.startsWith("2")) {             
                       var invTable = [];
                       for (var i=0;i<invoiceNumber.length;i++)
                       {
                        var invRecord = invoiceNumber[i];
                        var invLine =invRecord.invoiceDetails.invoiceNumber;
                        invLine=invLine.concat(' - Issued ');
                        invLine=invLine.concat(invRecord.paymentSummary.issueDate);
                        invTable.push(invLine);
                       }
                    component.set("v.invoiceList",invTable);
                  }
		 	  
            else if (responseInvoice.errorKey == $A.get("$Label.c.No_Invoice_Data"))
                    {
                    component.set("v.errorMessage",$A.get("$Label.c.No_Invoice_Number"));
                    component.set("v.IsError",true);  
                    component.set("v.IsPageLoad", false);
                                        }

           else if ((key.startsWith("4")) || (key.startsWith("5"))) 
		   {
			   component.set("v.errorMessage",$A.get("$Label.c.Invoice_Tech_Error"));
                component.set("v.IsError",true);                   
                component.set("v.IsPageLoad", false);
		   }			   
           }
			}
			 else if (state==='ERROR' || state==='INCOMPLETE')
             {
                component.set("v.errorMessage",$A.get("$Label.c.Invoice_Tech_Error"));
                component.set("v.IsError",true);                   
                component.set("v.IsPageLoad", false);
             }
		   });
        $A.enqueueAction(action);
    },
    setPartner : function(component,event) {
	  	var action = component.get("c.isPartner");
        //console.log('setPartner');
		action.setCallback(this, function(response) {
            var state = response.getState();
             //console.log('state');
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isPartner", response.getReturnValue());
                //console.log('setPartner'+response.getReturnValue());
            }
            else{
                //console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    changeData: function(component, event) {
        //Start of EDGE-148577 : validating if the event has fired from this component.
        var compName = event.getParam("componentName");
        var sObjectList = component.get("v.dataTableReturnVal");    
        if(compName == 'InvoiceCmp'){
            component.set("v.CurrentPage", event.getParam("CurrentPage"));
            component.set("v.pageSize", event.getParam("PageSize"));
            component.set("v.TotalPages", component.get("v.TotalPages"));
            //Start of EDGE-148577 : To hide header checkbox on next/previous Page.
         component.set("v.isSelectAll",false);
      //   component.set("v.isDeviceSelected", true);
        //End of EDGE-148577
    this.dispMethod(component);
    }//End of EDGE-148577
    
  },
  /*---------------------------------------------------------------------------------------
    Name : dispMethod
    Description : Method to display data on page
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
    dispMethod: function(component, event) {
    //console.log('dispMethod of stockcheckbase');
    var tempList = [];
    var pNo = component.get("v.CurrentPage");
    //console.log('current page in basket page');
    var size = component.get("v.pageSize");
    tempList = component.get("v.deviceModel");
      var paginationMapInt = component.get("v.paginationMapInt");
      var listFromMap =  paginationMapInt[pNo];
      if(listFromMap != undefined && listFromMap.length > 0 )
      {
          component.set("v.checkedRows",listFromMap);
      }
    component.set(
      "v.paginationList",
      tempList.slice((pNo - 1) * size, Math.min(pNo * size, tempList.length))
    ); 
  },

    //Added for EDGE-207869 by Aman Soni || Start
    GetExistQlIAgainstCaseAndInvoiceHlpr : function(component, event, exisCaseId, invoiceNum){	
        var action = component.get("c.GetExistQlIAgainstCaseAndInvoiceCls");
        var invDataTab = [];
        invDataTab = component.get("v.invoiceDetails");               
        action.setParams({"exisCaseId" :exisCaseId, "invoiceNum" :invoiceNum});	
        action.setCallback(this, function(response){	
            var state = response.getState();	
            if(state === "SUCCESS"){
                var resObj = response.getReturnValue();
                var invDataTableDol =[];
                for(var iDT of invDataTab){
                    var str = '$';
                    iDT.queriedCharge = str.concat(resObj);
                    invDataTableDol.push(iDT);
                }
                component.set("v.invoiceDetails",invDataTableDol);	
            }	
        })	
        $A.enqueueAction(action);
    },
    //Added for EDGE-207869 by Aman Soni || End
    
    //Added for EDGE-207869 by Aman Soni || Start
    getSharedDisplayMessageCS : function(component, event){
        var getSettingsAction = component.get("c.getSharedDisplayMessageCS");
        getSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.SharedDisplayMessageCS", response.getReturnValue());
                //console.log("Company Setting loaded-->",component.get("v.SharedDisplayMessageCS"));
            } else {
                //console.log("Failed to load Company Setting.");
            }
        });
        $A.enqueueAction(getSettingsAction);
    },
    //Added for EDGE-207869 by Aman Soni || End //queryCSForDrilldown
   //Added for EDGE-215753 by Akanksha || Start
    queryCSForDrilldown : function(component, event){
        var enableDrilldown = component.get("c.enableDrilldown");
        
        enableDrilldown.setCallback(this, function(response) {
            if (response !== null && response.getState() == 'SUCCESS') {
                 //console.log("enableDrilldown--",response.getReturnValue());
                component.set("v.enableDrilldown", response.getReturnValue());
            }
        });
        $A.enqueueAction(enableDrilldown);
    },
    //Added for EDGE-215753 by Akanksha || End
   
})