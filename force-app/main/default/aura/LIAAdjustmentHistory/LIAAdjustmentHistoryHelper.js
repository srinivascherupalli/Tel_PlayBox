({
    fetchInvoiceLineItems : function (component, event, helper) {
        
        component.set('v.mycolumns', [
					{label: 'Adjustment Type', fieldName: 'Reason_Code__c', type: 'text', sortable: false},
					{label: 'Adjustment Date', fieldName: 'AdjustmentDate', type: 'date', sortable: false, typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'}},
					{label: 'Telstra Reference', fieldName: 'Case', type: 'url', sortable: false, typeAttributes: { 
																			label: { fieldName: 'caseNumber' }, 
                    														target: '_blank' }},	

            {label: 'Adjustment Applied', fieldName: 'Determination_Amount__c', type: 'String', sortable: false, cellAttributes: { alignment: 'right'}},
					{label: 'Residual Charge',fieldName: 'Max_Credit_Amount__c', type: 'String', sortable: false, cellAttributes: { alignment: 'right'}},
            ]);

        //fetch salesforce records for adjustment datatable
        var action = component.get("c.getQueryLineItems");
        var invoice = component.get("v.recordId");
        action.setParams({"invoiceId": invoice
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
           		var setMaxCredit = 0;

				var qliList = response.getReturnValue();
				for (var i = 0; i < qliList.length; i++) {
                    var qliListForMaxCredit = qliList[i];
        if(qliListForMaxCredit!== null){
                 component.set("v.chargeType",qliListForMaxCredit.Invoice_Line_Item__r.Charge_Type__c); 
                if(setMaxCredit == 0){

                        component.set("v.customerAccountNumber",qliListForMaxCredit.Invoice_Line_Item__r.Invoice__r.Billing_Account__r.Billing_Account_Number__c);

                        component.set("v.ariaInvoiceNumber",qliListForMaxCredit.Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c);
                        component.set("v.chargeIdentifier",qliListForMaxCredit.Invoice_Line_Item__r.Charge_Identifier__c);
                        component.set("v.invoiceLineNumber",qliListForMaxCredit.Invoice_Line_Item__r.Invoice_Line_Number__c);
                        setMaxCredit = 1;
					}
                }
    		}	

				helper.makecallout(component,event,qliList);

            }
        });
		$A.enqueueAction(action);
		},
            

        makecallout: function(component,event,qliList) {
        // Callout for maxCredit
		var action = component.get('c.getInvoiceDetails');
        var determinationInDollor = '$';

        var requestObject = new Object();
        var chargeObject  =  {};
        var chargeDetails = [];
		var skipCallOut = false;
		component.set("v.creditChargeType",$A.get("$Label.c.QLI_Charge_Type_Credit_Charge"));
        var creditCharge = component.get("v.creditChargeType");

        component.set("v.usageChargeType",$A.get("$Label.c.QLI_Charge_Type_Usage_Detail"));
        var usageDetails = component.get("v.usageChargeType");
		if(component.get("v.chargeType") == (creditCharge || usageDetails)){
			skipCallOut = true;
		}
        component.set("v.creditChargeType",$A.get("$Label.c.QLI_Charge_Type_Credit_Charge"));

        //fetching request params for maxCredit
        requestObject.customerAccountNumber=component.get("v.customerAccountNumber");
		requestObject.ariaInvoiceNumber=component.get("v.ariaInvoiceNumber");
		chargeObject.chargeIdentifier=component.get("v.chargeIdentifier");
		chargeObject.chargeType=component.get("v.chargeType");
		chargeObject.invoiceLineNumber=component.get("v.invoiceLineNumber");
        chargeDetails.push(chargeObject);
        console.log('chargeDetails', chargeDetails);
        requestObject.chargeDetails = chargeDetails;
        //console.log('requestObject ---!!!!', requestObject);
        var requestJSON=JSON.stringify(requestObject); 
        //console.log('requestJSON --->>>>', requestJSON);

        action.setParams({request:requestJSON,handlerName:'QLIAdjustmentHandler'});
        action.setCallback(this,function(response){
            var state=response.getState();
			
            if(state === 'SUCCESS' || skipCallOut == false)
            {

                //console.log('responseObject',JSON.stringify(responseObject));
                var responseObject=response.getReturnValue();

                var statusCode=Object.keys(responseObject);
                if(responseObject!= null && statusCode.length != 0)
                {
                    var responsebody=Object.values(responseObject);
                    var response=JSON.parse(responsebody[0]);

                    //console.log('response -->>' + response);
                    if(statusCode[0].startsWith(2))
                    {
                        for(var ili of response.creditAdjustmentEligibility){

							component.set("v.residualCharge",ili.maxCreditAmount);
                            }
							
							for (var i = 0; i < qliList.length; i++) {
							var qliListForMaxCredit = qliList[i];
								if(qliListForMaxCredit !== null){
                                    if(qliListForMaxCredit.Determination_Amount__c !== null){
										var determinationWithDollor = qliListForMaxCredit.Determination_Amount__c + '';
										if(determinationWithDollor.indexOf('$') === -1){
											qliListForMaxCredit.Determination_Amount__c = determinationInDollor + determinationWithDollor;
										}
									}
                          
									if(qliListForMaxCredit.Case__r.CaseNumber){
										qliListForMaxCredit.caseNumber = qliListForMaxCredit.Case__r.CaseNumber;
										qliListForMaxCredit.Case = '/' + qliListForMaxCredit.Case__c;
									}
									// formatting Adjustment Date date 
									qliListForMaxCredit.AdjustmentDate = $A.localizationService.formatDate(qliListForMaxCredit.Credit_Adjustment__r.Date_when_credit_was_given_to_customer__c, "DD MMM YYYY");
									if(i != qliList.length - 1){
										qliListForMaxCredit.Max_Credit_Amount__c = '';
									}else{
                                      var maxCreditInDollor = '$';
									  qliListForMaxCredit.Max_Credit_Amount__c = component.get("v.residualCharge");
                                      var newMaxCredit = maxCreditInDollor + qliListForMaxCredit.Max_Credit_Amount__c;
                                      qliListForMaxCredit.Max_Credit_Amount__c = newMaxCredit;

									}
								}
							}
                    }
                    else{

                        for (var i = 0; i < qliList.length; i++) {
						var qliListForMaxCredit = qliList[i];
						if(qliListForMaxCredit !== null)
						{

								qliListForMaxCredit.Max_Credit_Amount__c = '';
								component.set("v.errorMessage",$A.get("$Label.c.Invoice_Charge_Error"));
							}
						}
                        
                    }
                }
                else {

                    for (var i = 0; i < qliList.length; i++) {
						var qliListForMaxCredit = qliList[i];
						if(qliListForMaxCredit !== null)
						{

                                qliListForMaxCredit.Max_Credit_Amount__c = '';
                                component.set("v.errorMessage",$A.get("$Label.c.Invoice_Charge_Error"));
                            }
                        }
                     
                    }
					
					// setting formatted data to the datatable

					component.set("v.fetchRecord", qliList);
            }
			if(skipCallOut = true){
				for (var i = 0; i < qliList.length; i++) {
					var qliListForMaxCredit = qliList[i];
					if(qliListForMaxCredit !== null){
                        if(qliListForMaxCredit.Determination_Amount__c !== null){
                            var determinationWithDollor = qliListForMaxCredit.Determination_Amount__c + '';
                            if(determinationWithDollor.indexOf('$') === -1){
								qliListForMaxCredit.Determination_Amount__c = determinationInDollor + determinationWithDollor ;
								
							}
                            
                        }
						if(qliListForMaxCredit.Case__r.CaseNumber){
							qliListForMaxCredit.caseNumber = qliListForMaxCredit.Case__r.CaseNumber;
							qliListForMaxCredit.Case = '/' + qliListForMaxCredit.Case__c;
						}
						// formatting Adjustment Date date 
						qliListForMaxCredit.AdjustmentDate = $A.localizationService.formatDate(qliListForMaxCredit.Credit_Adjustment__r.Date_when_credit_was_given_to_customer__c, "DD MMM YYYY");
						if(component.get("v.chargeType") == creditCharge){
							if(i != qliList.length - 1){
								qliListForMaxCredit.Max_Credit_Amount__c = '';
							}else{
								var maxCreditInDollor = '$';
								qliListForMaxCredit.Max_Credit_Amount__c = '0';
								var newMaxCredit = maxCreditInDollor + qliListForMaxCredit.Max_Credit_Amount__c;
                                qliListForMaxCredit.Max_Credit_Amount__c = newMaxCredit;
							}
						}
						if(component.get("v.chargeType") == usageDetails){
							qliListForMaxCredit.Max_Credit_Amount__c = '';

						}
					}
				}
			}
			

            component.set("v.fetchRecord", qliList);

        });    
           $A.enqueueAction(action);
    },
    InvoiceLineItemSection : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
})