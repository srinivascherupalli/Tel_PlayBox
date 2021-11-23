/**************************************************************************
EDGE        -108332,92016,92018,124071,139436
component   -UsageSummaryHelper
Description -Helper for UsageSummary
Author      -Sasidhar Devarapalli
Modified by -Manjunath Ediga
Team        -Osaka
*********************************************************************************/
    ({
	getdoInit : function(component ,event) {
        component.set("v.IsError",false);
		var invoiceLineItemId= component.get("v.recordId");
        component.set("v.loadingSpinner", true);
        var isInvoiceLineItemVar = component.get("v.isInvoiceLineItem")
        var action= component.get("c.getUsageResponseDetails");
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        //Billing consultant Journey 
        if(isInvoiceLineItemVar){
            console.log('In Billing consultant Journey');
            action.setParams({"invoiceLineItemId": invoiceLineItemId,"invoiceMapStr":null , "isInvoiceLineItem":isInvoiceLineItemVar});
        }
        else{
            console.log('In Assurance Journey');
            component.set("v.BooleanVar",false);
            var isSelectAll = component.get("v.isSelectAll");
            var currentPage = component.get("v.currentPage");
            var mapKey = component.get("v.mapKey");
            var paginationMapReceived = component.get("v.childPaginationMap");
            console.log('paginationMapReceived',JSON.stringify(paginationMapReceived));
            var paginationMapCloned = JSON.parse(JSON.stringify(paginationMapReceived));
            component.set("v.paginationMap",paginationMapCloned);
            var paginationMapAfterClone = component.get("v.paginationMap");
            var paginationMap = paginationMapAfterClone[mapKey] ;
          
            if(paginationMap != null && isSelectAll == false){
                component.set("v.paginationMapInt",paginationMap);
                var paginationMapInt = component.get("v.paginationMapInt");
                console.log('paginationMapInt in usg helper',JSON.stringify(paginationMapInt));
                var ListFromMap =  paginationMapInt[currentPage];
                component.set("v.selReords",ListFromMap);
            }
            //Checking if isSelectAll(Primary checkbox from Parent) is selected if so hide checkboxes and remove previously selcted rows 
            else{
                var selectedRecords = component.get("v.selReords");
                console.log('selected rows before ',selectedRecords);
                if((isSelectAll && selectedRecords != undefined ) || selectedRecords != undefined ){                 
                    var newArray = selectedRecords;
                    selectedRecords.length = 0;
                }
                console.log('selected rows ',JSON.stringify(component.get("v.selReords")));
            }
            action.setParams({"invoiceLineItemId": null,"invoiceMapStr": component.get("v.invoiceMapping"), "isInvoiceLineItem":isInvoiceLineItemVar});
        }
        action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.loadingSpinner", false);
                if(state === "SUCCESS") {
                    //console.log('actual response'+response.getReturnValue());
                    var actualResponse = response.getReturnValue();
                    var resultmessage = String(actualResponse);
                    var errormessage = resultmessage.search("JDBCConnectionException");
                    var hasError = actualResponse.startsWith("<!");
                    var invoiceTransactionIdNum = component.get("v.invoiceTransactionId");
                    var filteredIli = [];
                    if(hasError == false && errormessage === -1 ){
                        var responseObj = JSON.parse(response.getReturnValue());
                        console.log('Callout--->',responseObj);
                        
                        //setting Usagetype from Usage response only for Billing consultant journey
                        //Start of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
                    var updatedUsageacc = [];
                            for(var  iliwithDolarPage of responseObj.usageDetails){
                                var str = '$';
                                iliwithDolarPage.amountExGST =  str.concat(iliwithDolarPage.amountExGST);
                                iliwithDolarPage.amountIncGST =  str.concat(iliwithDolarPage.amountIncGST);
                                updatedUsageacc.push(iliwithDolarPage);
                                
                            }    
                      component.set('v.usageCharges', updatedUsageacc);
                      console.log('updatedUsageacc----->',updatedUsageacc);
                    //End of EDGE-157957 : All financial amounts should be shown in all Salesforce screens as with currency (dollar) symbol and to 2 decimal places
                        if(isInvoiceLineItemVar == true){
                            

                            
                            //EDGE-157970 -<Usage Detail UI Layout>Ability to billing consultant to view usage line item charge detail
                            // To correct the issue: In the detail response, extending the solution to create QLI for all ILIs corresponding to the selected detail record. Changed value ie, transaction ID from string to List.         
                            // If ili transaction id and response transaction id is matching we are adding data to  filteredIli variable               
                                for(var ili of responseObj.usageDetails){
                                     for(var iliFilter of ili.invoiceLineAttributes){ 
                                       if(invoiceTransactionIdNum == iliFilter.invoiceTransactionId ){   
                                       	filteredIli.push(ili); 
                                 		}  
                                     }
                                  }
                            
                            
                         console.log('filteredIli---->',filteredIli);
                         //EDGE-157970 -<Usage Detail UI Layout>Ability to billing consultant to view usage line item charge detail
                           component.set("v.usageCharges",filteredIli);
                        }//Else Set the total response
                        else{
                            component.set("v.usageCharges",responseObj.usageDetails);
                        }
                            
                            component.set("v.usageType",responseObj.usageType);
                            var usgtype = component.get("v.usageType");
                            var responseUsageType = usgtype.split("(")[0];
                            var responseUsage = responseUsageType.trim();
                            component.set("v.usageType",responseUsage);
                        
                       //EDGE-133408 - Component start - Creating a map of chargeidentifier as key and transaction id as a value to match selected identifiers from usage.
                        var qliMap = new Map();
                        // EDGE-157970 - To correct the issue: In the detail response, extending the solution to create QLI for all ILIs corresponding to the selected detail record. Changed value ie, transaction ID from string to List.
                        var iliList = [];
                        for(var QLI of responseObj.usageDetails){  
                            iliList = [];
                            for(var ili of QLI.invoiceLineAttributes){
                                iliList.push(ili.invoiceTransactionId);
                                
                            } 
								qliMap[QLI.chargeIdentifier] = iliList;                            
                        } 
                        console.log('chargeidentifier qliMap===>',qliMap);
                        component.set("v.QLIMap",qliMap);
                      //EDGE-133408 - Component Ends

                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = component.get('v.usageCharges');
                    var totalLength = totalRecordsList.length
					//EDGE-157960---Ravi S---Start
					for(var i=0; i < totalLength; i++){
						var amountIncGSTUpd = parseFloat(totalRecordsList[i].amountIncGST.replace(/\$/g,''));
						var amountExGSTUpd = parseFloat(totalRecordsList[i].amountExGST.replace(/\$/g,''));
						totalRecordsList[i].amountIncGSTFmtd = amountIncGSTUpd < 0 && totalRecordsList[i].isTaxable === false ? '$'+String((amountIncGSTUpd * -1).toFixed(2))+' Cr †' : (amountIncGSTUpd < 0 ? '$'+String((amountIncGSTUpd * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (totalRecordsList[i].isTaxable === false ? '$'+String((amountIncGSTUpd).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((amountIncGSTUpd).toFixed(2))+Array(8).fill('\xa0').join(''))); 
						totalRecordsList[i].amountExGSTFmtd = amountExGSTUpd < 0 && totalRecordsList[i].isTaxable === false ? '$'+String((amountExGSTUpd * -1).toFixed(2))+' Cr †' : (amountExGSTUpd < 0 ? '$'+String((amountExGSTUpd * -1).toFixed(2))+' Cr'+Array(3).fill('\xa0').join('') : (totalRecordsList[i].isTaxable === false ? '$'+String((amountExGSTUpd).toFixed(2))+' †'+Array(5).fill('\xa0').join('') : '$'+String((amountExGSTUpd).toFixed(2))+Array(8).fill('\xa0').join('')));
					}
					//console.log("tttttttt::::"+JSON.stringify(totalRecordsList));
					//EDGE-157960---Ravi S---End					

                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.usageCharges").length > i){
                            PaginationLst.push(totalRecordsList[i]);    
                        } 
                    }

                        var TotalPages = Math.ceil(totalLength / component.get("v.pageSize"));
                           var appEvent = $A.get("e.c:paginationEvent");
                        component.set("v.columns", PaginationLst.length);
                        component.set("v.TotalPages",TotalPages);
                        component.set('v.deviceModel', totalRecordsList);
                    component.set('v.PaginationList', PaginationLst);
                        var appEvent = $A.get("e.c:paginationEvent");
        //Start of EDGE-148577 : Added componentName to Event to avoid overriding of the handlee events.
        
                    //console.log('PaginationLst',JSON.stringify(PaginationLst));
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));   
                    //EDGE-141682 - Component Start:Map of charge ID to type code
                    component.set("v.validUsage",true);
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
                    //EDGE-141682 - Component End
                    }else {
                   
                    component.set("v.errorMessage",$A.get("$Label.c.UsageError"));
                    component.set("v.IsError",true);
                }
                }
            else {
                    component.set("v.errorMessage",$A.get("$Label.c.UsageError"));
                    component.set("v.IsError",true);
            }
            });
            $A.enqueueAction(action);
    },
        
     /*---------------------------------------------------------------------------------------
    Name : getUsageLabels
    Description : Method to get Usage type Labels from custom meta data
    Story: EDGE-141682
    Author:Manjunath Ediga
     -----------------------------------------------------------------------------------*/   
        getUsageLabels : function(component ,event) {
            
            var invoiceLineItemId= component.get("v.recordId");
            console.log('invoiceLineItemId',invoiceLineItemId);
            var isSelectAll = component.get("v.isSelectAll");
            component.set("v.loadingSpinner", true);
            var isInvoiceLineItemVar = component.get("v.isInvoiceLineItem");
            var usageTypeCode = component.get("v.usageTypeCode");
            console.log('usageTypeCode',usageTypeCode);
            var action= component.get("c.getUsageTypeLabels");
            action.setParams({"usageTypeCode": usageTypeCode,"invoiceLineItemId": invoiceLineItemId,"isInvoiceLineItem":isInvoiceLineItemVar});
            action.setCallback(this, function(response) {
                var dataTableReturnVal = [];
                var state = response.getState();
                if(state === "SUCCESS") {
                    var usgResponse = response.getReturnValue();
                    console.log(' response for usage data'+JSON.stringify(response.getReturnValue()));
                    //get the field names and column labels from meta data query and add it to list to use it in lightning datatable
                    for(var usgRes of usgResponse){
                        var fieldname = usgRes.fields__c;
                        var datatype = usgRes.Data_Type__c;
                        console.log('fieldname',fieldname);
                        console.log('datatype',datatype);
						//EDGE-157960---Ravi S---Start
						if(fieldname != 'amountIncGST' && fieldname != 'amountExGST'){
                        dataTableReturnVal.push({
                            label: usgRes.Table_Column__c,
                            fieldName:  fieldname,
                            type:datatype,
                            typeAttributes: { minimumFractionDigits : '2' },
                            cellAttributes:{alignment:'left'}
                        });
                    }
						if(fieldname == 'amountIncGST'){
							dataTableReturnVal.push({
								label: usgRes.Table_Column__c,
								fieldName:  'amountIncGSTFmtd',
								type:'text',
								cellAttributes:{alignment:'right'}
							});
						}
						if(fieldname == 'amountExGST'){
							dataTableReturnVal.push({
								label: usgRes.Table_Column__c,
								fieldName:  'amountExGSTFmtd',
								type:'text',
								cellAttributes:{alignment:'right'}
							});
						}//EDGE-157960---Ravi S---End						
                    }
                    console.log('dataTableReturnVal in getusage',dataTableReturnVal);
                    component.set("v.usageColumns",dataTableReturnVal);
                    // set isInvoiceLineItem to true to hide checkbox when primary checbox in invoicecmp is selected
                    if(isSelectAll){
                         component.set("v.isInvoiceLineItem",true);
                    }
                }
                
            });
            $A.enqueueAction(action);
            
        },
 
    /*---------------------------------------------------------------------------------------
    Name : First
    Description : Method to set pagination parameters when previous Button is clicked
    Story: EDGE-
    Author:Mohammed Zeesan
     ----------------------------------------------------------------------------------- */ 
        first : function(component,event,sObjectList,end,start,pageSize,paginationMapInt,currentPage)
        
        {
            var paginationlist = [];
            var counter = 0;
            for(var i=0; i< pageSize; i++)
                
            {
                
                paginationlist.push(sObjectList[i]);
                counter++;
            }
            
            component.set('v.PaginationList', paginationlist);
            start = start + counter;
            end = end + counter;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set("v.BooleanVar",false);
            
        },
        
 /*---------------------------------------------------------------------------------------
    Name : Last
    Description : Method to set pagination parameters when previous Button is clicked
    Story: EDGE-
    Author:Mohammed Zeesan
     ----------------------------------------------------------------------------------- */         
        last : function(component,event,sObjectList,end,start,pageSize,paginationMapInt,currentPage)
        {
            
            var totalSize = component.get("v.totalRecordsCount");
            var totalPageSize =component.get("v.totalPagesCount"); 
            var paginationlist = [];
            var counter = 0;
            for(var i=totalSize - totalPageSize - 1; i< totalSize; i++)
                
            {
                
                paginationlist.push(sObjectList[i]);
                counter++;
            }
            console.log('paginationlist in Last',paginationlist);
            component.set('v.PaginationList', paginationlist);
            /*start = start + counter;
            end = end + counter;*/
            //component.set("v.startPage",start);
            //component.set("v.endPage",end);            
                    component.set("v.BooleanVar",false);

            console.log('currentPage --->',component.get("v.currentPage"));
            console.log('totalSize --->',totalSize);
            console.log('totalPageSize --->',totalPageSize);
            console.log('endPage---->',component.get("v.endPage"));
            console.log('startPage---->',component.get("v.startPage"));
        },
        

    /*---------------------------------------------------------------------------------------
    Name : next
    Description : Method to set pagination parameters when Next Button is clicked
    Story: EDGE-124071
    Author:Manjunath Ediga
    Modified: Manjunath Ediga(EDGE-126965)
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
        component.set('v.PaginationList', paginationlist);
        var listFromMap =  paginationMapInt[currentPage];
        component.set("v.selReords",listFromMap);
        component.set("v.BooleanVar",false);
        //End of EDGE-126965   
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
        console.log('paginationlist in previous',paginationlist);
        component.set('v.PaginationList', paginationlist);
        //Start of EDGE-126965
        //Update the selected Records in selReords attribute
        currentPage--;
        var listFromMap =  paginationMapInt[currentPage];
        component.set("v.selReords",listFromMap);
        component.set("v.BooleanVar",false);
		//End of EDGE-126965 
    },
        
/*---------------------------------------------------------------------------------------
    Name : InvoiceLineDownload
    Description : Method to download the data from Invoice page
    Story:EDGE-124068
    Author:Mohammed Zeeshan
     -----------------------------------------------------------------------------------*/  
 InvoiceLineDownload : function(component, event) {
         var invoiceLineItemId= component.get("v.recordId");
		 var action = component.get('c.invoiceLineItemList');
         action.setParams({"InvoiceLineNumber":invoiceLineItemId} );
        
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                //Fetching the data from APex class
                var wrapperResult = response.getReturnValue();
                /*var accountName = wrapperResult.accountName;
                var accountNumber = wrapperResult.accountNumber;
                var caseNumber = wrapperResult.caseNumber;*/
                component.set('v.ListofInvoiceLineItem', wrapperResult);
                console.log('wrapper result-->',component.get("v.ListofInvoiceLineItem"));
            }
        });
        $A.enqueueAction(action);
	},
    
    convertArrayOfObjectsToCSV : function(component,invoiceRecords,usageRecord){
        // variable declaration 
        var enquiryDetailsSection, counter,counter1, invoiceLineDetails,invoiceLineDetailsMap, columnDivider, lineDivider,usagedetailsList,usagedetailsMap,AdditionalDetailsSection,chargeDetails,chargeDetailsMap,chargeDetailsSection;
       console.log('invoiceRecords',invoiceRecords);
        // check if "invoiceRecords" parameter is null, then return from function
        if (invoiceRecords == null || !invoiceRecords.length) {
            return null;
         }
        
        
        // columnDivider variabel for sparate CSV values and 
        //  '\n'  for printing the data in next line
        columnDivider = ',';
        lineDivider =  '\n';
 
        // invoiceLineDetails in the keys valirable store fields API Names  
         
        invoiceLineDetails = ['caseNumber' ,'Line_Item_Identifier__c','Invoice__r.Billing_Account__r.Billing_Account_Number__c','accountName','Invoice__r.Name' ];
        // invoiceLineDetailsMap labels use in CSV file header 
        invoiceLineDetailsMap = ['Case Number','Line Item Identifier' ,'Account Number','Account Name','Invoice Number'];
        
        chargeDetails = ['Offer_Name__c' ,'Physical_Location_Name__c','Service_Type__c','Charge_Type__c','Quantity__c','Is_Taxable__c','Charge_Excluding_GST__c','Charge_Including_GST__c' ];
        // invoiceLineDetailsMap labels use in CSV file header 
        chargeDetailsMap = ['Offer Name','Physical Location Name' ,'Charge Description','Charge Type','Quantity','Is Taxable','Charge Excluding GST','Charge Including GST'];
        
        usagedetailsList =[ 'serviceNumber','date','time','quantityOfTopUps','duration','amountExGST', 'amountIncGST'];
        usagedetailsMap =[ 'Service Number','Date','Time','Quantity','Unit of Measure','Ex GST', 'Inc GST'];
        //Header value
        enquiryDetailsSection = 'Enquiry Details';
        enquiryDetailsSection += lineDivider;
        //Adding of columns Labeles
        enquiryDetailsSection += invoiceLineDetailsMap.join(columnDivider);
        enquiryDetailsSection += lineDivider;
        
        chargeDetailsSection = '';
        chargeDetailsSection += lineDivider;
        chargeDetailsSection += 'Charge Details';
        chargeDetailsSection += lineDivider;
        chargeDetailsSection += chargeDetailsMap.join(columnDivider);
        chargeDetailsSection += lineDivider;
        
        
        AdditionalDetailsSection = '';
        AdditionalDetailsSection += lineDivider;
        AdditionalDetailsSection += 'Additional Charges';
        AdditionalDetailsSection += lineDivider;
        AdditionalDetailsSection += usagedetailsMap.join(columnDivider);
        AdditionalDetailsSection += lineDivider;
        
        
 		   
           for(var i=0; i < invoiceRecords.length; i++){   
            counter = 0;
           	//Is used creating Enquiry Details section and displaying the data
             for(var iliDetails in invoiceLineDetails) {
                var iliDetail = invoiceLineDetails[iliDetails] ;
                 if(iliDetail == 'caseNumber' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                if(iliDetail == 'Line_Item_Identifier__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Line_Item_Identifier__c;
 				}
                 if(iliDetail == 'Line_Item_Identifier__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 /*if(iliDetail == 'Invoice__r.Billing_Account__r.Billing_Account_Number__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }*/
                 if(iliDetail == 'Invoice__r.Billing_Account__r.Billing_Account_Number__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Invoice__r.Billing_Account__r.Billing_Account_Number__c;
                }
                if(iliDetail == 'Invoice__r.Billing_Account__r.Billing_Account_Number__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'accountName' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                if(iliDetail == 'Invoice__r.Name'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Invoice__r.Name;
                }
                if(iliDetail == 'Invoice__r.Name' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
              // add , [comma] after every String value
                  if(counter > 0){ 
                      enquiryDetailsSection += columnDivider; 
                   }   
               
               enquiryDetailsSection += '"'+ invoiceRecords[i][iliDetail]+'"'; 
               
               counter++;
 
            } 
             enquiryDetailsSection += lineDivider;
          }
        
        //Is used creating 'Charge Details' section and displaying the data
        for(var i=0; i < invoiceRecords.length; i++){   
            counter = 0;
           
             for(var iliDetails in chargeDetails) {
                var iliDetail = chargeDetails[iliDetails] ; 
                 
                 if(iliDetail == 'Offer_Name__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Offer_Name__c;
 				}
                 if(iliDetail == 'Offer_Name__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Physical_Location_Name__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Physical_Location_Name__c;
 				}
                 if(iliDetail == 'Physical_Location_Name__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Service_Type__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Service_Type__c;
 				}
                 if(iliDetail == 'Service_Type__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Charge_Type__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Charge_Type__c;
 				}
                 if(iliDetail == 'Charge_Type__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Quantity__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Quantity__c;
 				}
                 if(iliDetail == 'Quantity__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Is_Taxable__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Is_Taxable__c;
 				}
                 if(iliDetail == 'Is_Taxable__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Charge_Excluding_GST__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Charge_Excluding_GST__c;
 				}
                 if(iliDetail == 'Charge_Excluding_GST__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
                 if(iliDetail == 'Charge_Including_GST__c'){
    				invoiceRecords[i][iliDetail] = invoiceRecords[i].invoiceLineItemRecDetails.Charge_Including_GST__c;
 				}
                 if(iliDetail == 'Charge_Including_GST__c' && typeof invoiceRecords[i][iliDetail] == 'undefined'){
                    invoiceRecords[i][iliDetail] = '';
                }
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      chargeDetailsSection += columnDivider; 
                   }   
               
               chargeDetailsSection += '"'+ invoiceRecords[i][iliDetail]+'"'; 
               
               counter++;
 
            } 
             chargeDetailsSection += lineDivider;
          }
        
        
        
       ////Is used creating 'Additional Charges' section and displaying the data
        if (usageRecord == null || !usageRecord.length) {
            return null;
         }
        for(var i=0; i < usageRecord.length; i++){   
            counter1 = 0;
           
             for(var usageDetail  in usagedetailsList) {
                var usagekey = usagedetailsList[usageDetail] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter1 > 0){ 
                      AdditionalDetailsSection += columnDivider; 
                   }   
               
               AdditionalDetailsSection += '"'+ usageRecord[i][usagekey]+'"'; 
               counter1++;
 
            } 
             AdditionalDetailsSection += lineDivider;
          }
        
       // return the CSV format String 
        return enquiryDetailsSection+chargeDetailsSection+AdditionalDetailsSection;    
    },  
/*---------------------------------------------------------------------------------------
    Name : getInvoiceTransactionId
    Description : Function to fetch the Invoice Transactio Id
    Story:EDGE-157970 -<Usage Detail UI Layout>Ability to billing consultant to view usage line item charge detail
    Author:Mohammed Zeeshan
     -----------------------------------------------------------------------------------*/  
getInvoiceTransactionId : function(component ,event) {
     		var invoiceLineItemId= component.get("v.recordId");
            var action= component.get("c.getinvoiceLineItem");
            action.setParams({"invoiceLineItemId": invoiceLineItemId});
            action.setCallback(this, function(response) {
                var dataTableReturnVal = [];
                var state = response.getState();
                if(state === "SUCCESS") {
                    var invoiceTrans1 = response.getReturnValue();
                    //console.log(' response for Invoicetransaction data ----->'+JSON.stringify(response.getReturnValue()));
                    var transactioId = invoiceTrans1.Invoice_Transaction_ID__c;
                    component.set("v.invoiceTransactionId",transactioId);
                    console.log('Test---->',component.get("v.invoiceTransactionId")); 
                }
                
            });
            $A.enqueueAction(action);
            
        },  
 
 /*---------------------------------------------------------------------------------------
    Name : helperSectionUsage
    Description : Usage acordian creation
    Story:EDGE-157970 -<Usage Detail UI Layout>Ability to billing consultant to view usage line item charge detail
    Author:Mohammed Zeeshan
  -----------------------------------------------------------------------------------*/         
    helperSectionUsage : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },

        changeData: function(component, event) {
     
    //Start of EDGE-148577 : validating if the event has fired from this component.
    var compName = event.getParam("componentName");
    if(compName == 'UsageSummary'){
    component.set("v.CurrentPage", event.getParam("CurrentPage"));
    component.set("v.PageSize", event.getParam("PageSize"));
        component.set("v.TotalPages", component.get("v.TotalPages"));
        //Start of EDGE-148577 : To hide header checkbox on next/previous Page.
         component.set("v.isSelectAll",false);
         component.set("v.isDeviceSelected", true);
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
      console.log('dispMethod of stockcheckbase');
    var tempList = [];
    var pNo = component.get("v.CurrentPage");
    console.log('current page in basket page');
    var size = component.get("v.pageSize");
    tempList = component.get("v.deviceModel");
      var paginationMapInt = component.get("v.paginationMapInt");
      var listFromMap =  paginationMapInt[pNo];
      if(listFromMap != undefined && listFromMap.length > 0 )
      {
          component.set("v.selReords",listFromMap);
      }
    component.set(
      "v.PaginationList",
      tempList.slice((pNo - 1) * size, Math.min(pNo * size, tempList.length))
    );
  },

        
        
})