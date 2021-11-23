({
    showSpinner: function (component, event, helper) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
	},

	hideSpinner: function (component, event, helper) {
		var spinner = component.find("mySpinner");
		$A.util.addClass(spinner, "slds-hide");
	},
	closeModal: function (component, event) {
		$('.modal-header').find('.btn-wrapper').find('.btn').click();
	},

	//to show error box
	showToast: function (type, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": type,
			"key": "action:announcement",
			"message": message
		});
		toastEvent.fire();
	},
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
					body.set("v.body", customComp);
				}
			}
		);
	},
    //data table definition
    getColumnDefinitions: function (cmp) {
        
        var actions = [{
            'label': 'Remove',
            'iconName': 'utility:delete',
            'name': 'delete'
        }];
        //EGDGE-87725 UX Changes for changing order of showing fields
		var columns = [{
				label: 'SUBSCRIPTION NAME',
				fieldName: 'subscriptionNameLink',
				type: 'url',
				sortable: true,
				typeAttributes: {
					label: {
						fieldName: 'subscriptionName'
					},
					target: '_blank'
				}
            },
			
			/*Commented As part of EDGE-165020
			{
				label: 'Subscription Number',
				fieldName: 'subscriptionNumber',
				type: 'text',
				sortable: true
            },*/
			{
				label: 'Service ID',
				fieldName: 'ServiceId',
				type: 'text',
				sortable: true
			},
			//Added as part of EDGE-165020|| start
			{
				label: 'Existing SIM Type',
				fieldName: 'ExistingSIMType',
				type: 'text',
				disabled: { fieldName: 'IsExistingSIMTypValue'},
				sortable: true,
			},

            {
				label: 'Requested SIM Type',
				fieldName: 'RequestedSIMType',
				type: 'list',
				sortable: true
			},
				
			{type: "button",
                typeAttributes: 
             	{
                    name: 'SIMTYPEReplacement',
                    value: 'SIMTYPEReplacement',
                 	iconName: 'utility:search',
                    variant: 'base'
            	}
            },
			//Added as part of EDGE-165020 || end
			{
				label: 'SIM Dispatch Required ',
				fieldName: 'SimDispatchedRequired',
				type: 'boolean',
                iconName: 'utility:check',
                iconPosition: 'right',
                editable: { fieldName: 'IsSimSerialNumber'},
                cellAttributes:{
                    class:{
                        fieldName : "customClassName__c"
                    }
                }
			},
			{
				label: 'SIM Serial Number ',
				fieldName: 'SimSerialNumber',
				type: 'text',
				editable: true,
                iconName: 'utility:edit',
                iconPosition: 'right',
				sortable: true
			},           
            {
                label: 'Delivery Address',
                fieldName: 'DeliveryAddress',
                type: 'text',
                editable: false,
				sortable: true,
 				typeAttributes:
                {
                	 fieldName: 'DeliveryAddressID'
            	}
            },
           {type: "button",
                typeAttributes: 
             	{
                    name: 'DeliveryAddress',
                    disabled: { fieldName: 'IsDeliveryDetailsDisabled'},
                    value: 'DeliveryAddress',
                 	iconName: 'utility:search',
                    variant: 'base',		
            	}
            },
			{
                label: 'Delivery Contact', 
                fieldName: 'DeliveryContact',
                type: 'text',
                editable: false,
				sortable: true,
                 typeAttributes:
                {
                	 fieldName: 'DeliveryContactID'
            	}
            },
            {type: "button",
                typeAttributes: 
             	{
                    name: 'DeliveryContact',
                    disabled: { fieldName: 'IsDeliveryDetailsDisabled'},
                    value: 'DeliveryContact',
                 	iconName: 'utility:search',
                    variant: 'base'
            	}
            },
            { 	
	                type: 'action', typeAttributes: { rowActions: actions } 
            }
                       
		];
		return columns;
	},
	sortData: function (cmp, fieldName, sortDirection){
		var data = cmp.get("v.filteredData");
		var reverse = sortDirection !== 'asc';

		data = Object.assign([],
			data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
		);
		cmp.set("v.filteredData", data);
	},   
	sortBy: function (field, reverse, primer) {
		var key = primer ?
			function (x) {
				return primer(x[field])
			} :
			function (x) {
				return x[field]
			};

		return function (a, b) {
			var A = key(a);
			var B = key(b);
			return reverse * ((A > B) - (B > A));
		};
	},
    //inline editing of table
    saveEdition: function (cmp, draftValues,helper) {
       console.log(JSON.stringify(cmp.get("v.wrapList")));
       //console.log('editedRecords'+JSON.stringify(draftValues))	;
       var draftString=JSON.stringify(draftValues);
       var subslist=cmp.get("v.wrapList");
       var filteredData=cmp.get("v.filteredData");
        var isSimDispatchedRequired=false;
       var qualifySimButton=true; //EDGE-169091
	   filteredData.forEach(function(filData)
	   {
			draftValues.forEach(function (draftValue) 
			{
                 //EDGE-169091 || start
                if(((filData.SimSerialNumber !=''&& draftValue.SubscriptionID !=filData.SubscriptionID) || (draftString.includes('SimSerialNumber') && draftValue.SimSerialNumber !='' && draftValue.SubscriptionID==filData.SubscriptionID)) && qualifySimButton){
                    qualifySimButton=false;
                    cmp.set("v.disabledqualifySIM",'false');
                } 
 				else if(((filData.SimSerialNumber ==''&& draftValue.SubscriptionID !=filData.SubscriptionID) || (draftString.includes('SimSerialNumber') && filData.SimSerialNumber !='' && draftValue.SimSerialNumber =='' && draftValue.SubscriptionID==filData.SubscriptionID)) && qualifySimButton){                    
                    //qualifySimButton=false;
                    cmp.set("v.disabledqualifySIM",'true');
                }
                //EDGE-169091 || end
				if(draftValue.SubscriptionID==filData.SubscriptionID){
					if(draftString.includes('SimSerialNumber')){
						//EDGE-167254 added by ankit ||start
                        var errors = cmp.get("v.errors");
                        	if(errors==undefined || errors==null ){
                           	 	errors = { rows: {}, table: {} }
                       		 }
					    //EDGE-167254 added by ankit ||start
						if(filData.SimSerialNumber!=draftValue.SimSerialNumber)
						{
                             //EDGE-167254 added by ankit ||start
                            if(filData.SimSerialNumber !='' && draftValue.SimSerialNumber!='' && filData.SimSerialNumber != draftValue.SimSerialNumber){
                                  filData.isValidSIM =false;
                            }
                            //EDGE-167254 added by ankit ||end
							if(filData.SimSerialNumber!='' && draftValue.SimSerialNumber=='')
							{
								filData.IsSimSerialNumber=false;
								///filData.IsDeliveryDetailsDisabled=true;
								isSimDispatchedRequired=false;							
							}
							
							else if(filData.SimSerialNumber=='' && draftValue.SimSerialNumber!='')
							{
								filData.IsSimSerialNumber=true;
								//filData.IsSimDispatchRequired=true;
                                filData.isValidSIM =false;//EDGE-167254
								//isSimDispatchedRequired=true;
							}
                           
							filData.SimSerialNumber=draftValue.SimSerialNumber;
                           
                        }else{
                            isSimDispatchedRequired=false;   
                        }
                         //EDGE-169091 || start
                       if(filData.SimSerialNumber!=null && filData.SimSerialNumber!=''){
                             var reg = new RegExp("^[0-9]{13}$");
                             if(!reg.test(draftValue.SimSerialNumber)){
                                errors.rows[filData.SubscriptionID] = {title: 'error in Sim Serial Number', 
                                                     messages: ['Please enter a valid 13 digit numeric SIM Serial Number'],
                                                     fieldNames: ['SimSerialNumber']};
                             }else{
                                errors.rows[filData.SubscriptionID] ={};
                             }
                        }else{
                              errors.rows[filData.SubscriptionID] ={};
                         }
                        cmp.set("v.errors", errors);
                   //EDGE-169091 || end

					} 
					if(draftString.includes('SimDispatchedRequired')){
						if(filData.SimDispatchedRequired!=draftValue.SimDispatchedRequired){
							if(draftValue.SimDispatchedRequired==true){
								filData.IsSimSerialNumber=false;
								filData.IsDeliveryDetailsDisabled=false;
                                filData.SimAvailabilityType='New SIM';   //EDGE-169091
								if(filData.DeliveryAddress=='' || filData.DeliveryContact==''){
									isSimDispatchedRequired=true;
									helper.showCustomToast(cmp,  $A.get("$Label.c.DeliveryDetailsRequired"), '', 'warning'); 
								}else{
									isSimDispatchedRequired=false;
								}
							}else{
								isSimDispatchedRequired=true;
								filData.IsSimSerialNumber=false;
								filData.IsSimDispatchRequired=true;
                                filData.SimAvailabilityType='Existing Blank SIM';   //EDGE-169091
							}
							filData.SimDispatchedRequired=draftValue.SimDispatchedRequired;
						}	
					}
				}            
			});	
           //console.log(filData);
            if(filData.SimDispatchedRequired==true && (filData.SimSerialNumber!='' && filData.SimSerialNumber!=undefined)){
                //console.log('1...');
                isSimDispatchedRequired=true;
                helper.showCustomToast(cmp, $A.get("$Label.c.SimReplacmentDetailMandatory"), '', 'warning'); 
            }
           else if((filData.SimSerialNumber!='' && filData.SimSerialNumber!=undefined) && filData.SimDispatchedRequired==false){
                //console.log('2...');
               filData.DeliveryAddress='';
               filData.DeliveryContact='';  
               isSimDispatchedRequired=false;
           }
           if(filData.SimDispatchedRequired==true && (filData.DeliveryAddress=='' || filData.DeliveryContact=='') ){
                //console.log('3....');
           		isSimDispatchedRequired=true;
               	helper.showCustomToast(cmp,$A.get("$Label.c.DeliveryDetailsRequired"), '', 'warning'); 
       		}
           else if(filData.SimDispatchedRequired==false && (filData.DeliveryAddress!='' || filData.DeliveryContact!='') ){
                //console.log('4....');
				filData.DeliveryAddress='';
               	filData.DeliveryContact='';  
               	isSimDispatchedRequired=false;               
           }
           
       });  
		 if(isSimDispatchedRequired==false){
			cmp.find("subscriptionTable").set("v.draftValues", null);
            //console.log(cmp.find("subscriptionTable").get("v.draftValues"));
            cmp.set("v.filteredData",filteredData); 
		}
		
        //console.log('filldata-->');
        //console.log(filteredData);
        
    },
    //delete subscription from table on row action
    deleteSubscriptions: function(cmp,event,helper,row){
        cmp.set("v.showSpinner", true);
    	var subwrapperlist=cmp.get("v.wrapList");
        var Subscriptionid=row.SubscriptionID;
        //console.log('Subs id for delete='+Subscriptionid);
        var action=cmp.get("c.deleteSubscription");
        action.setParams({
			"subscriptionList": subwrapperlist,
            "subscriptionId":row.SubscriptionID   
            });
        action.setCallback(this,function(response)
       {
         //alert('Inside callback');
         cmp.set("v.showSpinner", false);  
         var state=response.getState();
           if(state='SUCCESS')
           {
              var records = response.getReturnValue();
               if(records.length != 0){
                   records.forEach(function (record) {
                  		record.subscriptionNameLink = '/' + record.SubscriptionID;						
                   });
               }              
               cmp.set("v.data", records);
               cmp.set("v.filteredData", records);
               cmp.set("v.wrapList",records);               
               //console.log(JSON.stringify(cmp.get("v.wrapList")));
               helper.showCustomToast(cmp, 'Successfully deleted', 'Success', 'success');            
           }
           else 
           {
               ////console.log(state);
           }     
       });
       $A.enqueueAction(action);
    },
    //create orders and orchestration
    createOrders: function(cmp,event,helper,row){
        //console.log('Inside create orders');
        //cmp.set("v.showSpinner", true);        
    	var subwrapperlist=cmp.get("v.wrapList");
        var accountId=cmp.get("v.accountId"); 
		var tNowCsRef=cmp.get("v.tNowCaseRef");//EDGE-132715
		var SelectReplacereason=cmp.get("v.SelectReplacereason");//EDGE-132715
		var action=cmp.get("c.createOrder");  
        action.setParams({
			"subwrapperList": subwrapperlist,
            "accountId":accountId,
			"tNowCaseRef":tNowCsRef,
			"SelectReplacereason":SelectReplacereason
            });
        action.setCallback(this,function(response)
       {
         //alert('Inside callback');
         cmp.set("v.showSpinner", false);  
         var state=response.getState();
         console.log('state '+state); 
         console.log('response '+response); 
           if(state='SUCCESS')
           {
              var result = response.getReturnValue(); 
              var orderDeatils = result.split(','); //Shweta Added : EDGE-185521 
              var orderNum = orderDeatils[0]; //Shweta Added : EDGE-185521 
              var orderId = orderDeatils[1]; //Shweta Added : EDGE-185521 
             console.log('result '+result); 
               if(result!=null){
                   if(result=='error'){
                       helper.showCustomToast(cmp, $A.get("$Label.c.OrderAlreadyPresent"), 'Creating Order Error', 'Warning'); 
                   }
                   else if(result!='error' && result!='Exception'){
                       //var successMsg=$A.get("$Label.c.SimReplacmentOrderSuccess")+' '+result;
                        var successMsg=$A.get("$Label.c.SimReplacmentOrderSuccess")+' '+orderNum; //Shweta Added : EDGE-185521 
                       helper.showCustomToast(cmp,successMsg, 'Success', 'success'); 
                       cmp.set("v.showSpinner", true);
                       var navigateEvent = $A.get("e.force:navigateToSObject");
                       navigateEvent.setParams({
                            //"recordId": cmp.get('v.accountId'),
                            "recordId": orderId,   //Shweta Added : EDGE-185521 
                            "slideDevName": "detail",
                            "isredirect": "true"
                        });
                        navigateEvent.fire();
                       //Added by Vamsi for DIGI-17911 26OCT2021 starts
                       helper.simReplacementLogs(cmp,event,helper,orderId);
                       //Added by Vamsi for DIGI-17911 26OCT2021 ends
                   }
                   else{
                       helper.showCustomToast(cmp,$A.get("$Label.c.SimReplacementOrderError"), "Creating Order Error", "error");   
                    	cmp.set("v.showSpinner", true);
                       	var navigateEvent = $A.get("e.force:navigateToSObject");
                       	navigateEvent.setParams({
                           "recordId": cmp.get('v.accountId'),
                           "slideDevName": "detail",
                           "isredirect": "true"
                       	});
                        navigateEvent.fire();
                   }
               }              
           }
           else 
           {
              helper.showCustomToast(cmp, 'Error occured during order generation.', "Creating Order Error", "error");   
              //cmp.set("v.showSpinner", true);
                       	var navigateEvent = $A.get("e.force:navigateToSObject");
                       	navigateEvent.setParams({
                           "recordId": cmp.get('v.accountId'),
                           "slideDevName": "detail",
                           "isredirect": "true"
                       	});
                        navigateEvent.fire();
           }     
       });
       $A.enqueueAction(action);   
        cmp.set("v.showSpinner", false);
    },
  //EDGE-167254 added by ankit ||start
    verifySIMSerial: function(cmp,event,helper){
       var verifySIMSerialList=cmp.get("v.simValidList");
	   var action=cmp.get("c.verifySIMSerial");
        action.setParams({
			"verifySIMSerialList": verifySIMSerialList,
            });
        action.setCallback(this,function(response)
       {  
         var state=response.getState();
           if(state='SUCCESS')
           {
              var records = response.getReturnValue();
               if(records.length != 0){
                   records.forEach(function (record) {
                        var errors = cmp.get("v.errors");
                        if(errors==undefined || errors==null ){
                            errors = { rows: {}, table: {} }
                        } 
                       if(record.responseStausMsg=='AVAILABLE'){
                           errors.rows[record.SubscriptionID] ={};
                       }else{
                        errors.rows[record.SubscriptionID] = { title: 'error in Sim Serial Number', 
                                                 messages: [record.responseStausMsg],
                                                 fieldNames: ['SimSerialNumber']};
                       // errors.table.title = "We found error(s). ...";
                       // errors.table.messages = [record.responseStausMsg];

                       }
                        cmp.set("v.errors", errors);
                        
                   });
                   cmp.set("v.simValidList",records);
                   helper.validateSimSerial(cmp,event,helper);
               }                         
           }   
       });
       $A.enqueueAction(action);
    },
    validateSimSerial: function(cmp,event,helper){
		var filteredData=cmp.get("v.filteredData");
		var verifySIMSerialList=cmp.get("v.simValidList");
        var allValidSim=true;
	    filteredData.forEach(function(filData)
        {
            if(!filData.isValidSIM){
			verifySIMSerialList.forEach(function(verifySim)
			{  
				if(filData.SubscriptionID==verifySim.SubscriptionID){
					filData.isValidSIM=verifySim.isValidSIM;
                    if(!verifySim.isValidSIM){
                       allValidSim=false; 
                    }

   				 }

			});
        }
			
        });
		cmp.set("v.filteredData",filteredData);
        if(allValidSim){
            helper.showCustomToast(cmp, $A.get("$Label.c.AlreadyQulifiedSim"), '', 'sucess'); 
        }
	},
    //EDGE-167254 added by ankit ||end
    //Added by Vamsi for DIGI-17911 26OCT2021 starts
    simReplacementLogs : function(cmp,event,helper,orderid)
    {
        var accountId = cmp.get("v.accountId");
        var datetimeinmillisec = cmp.get("v.dateTimeMilliseconds");
        var orderId = orderid;
        var action=cmp.get("c.simReplacementTransactionlogs");
        
        action.setParams({
            "accountId":accountId,
            "orderId":orderId,
            "datetimeinmillisec":datetimeinmillisec,
        });
        
        action.setCallback(this,function(response)
                           {
                               var state=response.getState();
                               console.log('state '+state); 
                               console.log('response '+response); 
                           });
        $A.enqueueAction(action);
    }
    //Added by Vamsi for DIGI-17911 26OCT2021 ends
})