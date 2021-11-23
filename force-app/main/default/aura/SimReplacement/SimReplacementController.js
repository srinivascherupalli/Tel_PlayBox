({
	doInit : function(component, event, helper) {

		component.set("v.showSpinner", true);
        component.set('v.columns', helper.getColumnDefinitions(component));
		component.set('v.keyField', "SubscriptionID");
		var SimOptionsMap = ['SIM Card','eSIM']; //EDGE-165020
		component.set('v.picklistValues', SimOptionsMap); //EDGE-165020 
        var subsid=component.get("v.SelectedSubsID");
        //console.log('Inside sim replacement componenet do in it');
        //console.log(component.get("v.SelectReplacereason")); 
        //Selected subscription for sim replacement
        var action = component.get("c.getSimReplacementsubscription");
			action.setParams({
			"subscriptionIdList": subsid
            });
			action.setCallback(this, function (response) {
				var state = response.getState();
				component.set("v.showSpinner", false);
				if (state === "SUCCESS") {
					var records = response.getReturnValue();
					if (records.length == 0) {
						component.set("v.isListNotPresent", "true");
					} else {
						records.forEach(function (record) {
							record.subscriptionNameLink = '/' + record.SubscriptionID;
						});
						component.set("v.data", records);
						component.set("v.filteredData", records);
                        component.set("v.wrapList",records);
                        //console.log(component.get("v.wrapList")); 
                                           
					} 
				}else if (state === "ERROR") {
					var errors = response.getError();
                    alert(errors);
				}	
			});
        $A.enqueueAction(action);
	},
    showSpinner: function (component, event, helper) {
		// make Spinner attribute true for display loading spinner 
		component.set("v.Spinner", true);
	},
	hideSpinner: function (component, event, helper) {
		// make Spinner attribute to false for hide loading spinner    
		component.set("v.Spinner", false);
	},
    ModalOpen: function (component, event, helper) {
        component.set("v.isModalOpen",true);
    },
    onCancel: function (component, event, helper) {
        component.set("v.isModalOpen",false);
    },
    onLeave: function (component, event, helper) {
		// Navigate back to the record view
		//var accountId = component.get('v.accountId');
        //component.set("v.showSpinner", true);       
		/*var navigateEvent = $A.get("e.force:navigateToSObject");
		navigateEvent.setParams({
			"recordId": accountId,
			"slideDevName": "detail",
			"isredirect": "true"
		});*/
        component.set("v.IsBack",true);
        component.set("v.isModalOpen",false);
        //console.log('inside back');
        //console.log('--->'+component.get("v.IsBack"));
        //console.log('filteredData'+component.get("v.filteredData2"));
        //console.log('selectedRows'+component.get("v.selectedRows"));
         $A.createComponent(
            "c:ShowSubscriptionsOnMACButton", {
                "SelectedSubsID":component.get("v.SelectedSubsID"),
                "accountId":component.get("v.accountId"),
                "filteredData":component.get("v.filteredData2"),
                "selectedRows":component.get("v.selectedRows"),
                "acc":component.get("v.acc"),
                "selectedRowsCount":component.get("v.selectedRowsCount"),
                "actionTypeSelected":'Sim Replacement',
                "basketId":''
            }, function (newcomponent) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);             
                }
            }
        );
       // component.set("v.showSpinner", true);
		//navigateEvent.fire();
	},
    updateColumnSorting: function (component, event, helper) {
		component.set('v.isLoading', true);
		setTimeout(function () {
			var fieldName = event.getParam('fieldName');
			var sortDirection = event.getParam('sortDirection');
			component.set("v.sortedBy", fieldName);
			component.set("v.sortedDirection", sortDirection);
			helper.sortData(component, fieldName, sortDirection);
			component.set('v.isLoading', false);
		}, 0);
	},
	filter: function (component, event, helper) {
		var data = component.get("v.data"),
			term = component.get("v.filter"),
			results = data,
			regex;
		try {
			regex = new RegExp(term, "i");
			// filter checks each row, constructs new array where function returns true
			results = data.filter(row => regex.test(row.subscriptionName) 
                                  || regex.test(row.ServiceId) 
                                  || regex.test(row.subscriptionNumber) 
                                  || regex.test(row.DeliveryAddress) 
                                  || regex.test(row.DeliveryContact) 
                                  || regex.test(row.SimSerialNumber)
                                  || regex.test(row.createdDate));
		}
        catch (e) {
		}
		component.set("v.filteredData", results);
		var data1 = component.get("v.filteredData")
		if (data1.length == 0) {
			component.set('v.NoSearchRecord', true);
		}
		if (data1.length != 0) {
			component.set('v.NoSearchRecord', false);
		}
	},
    //handle row actions both lookup and action
    handleRowAction: function(cmp, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');       
        switch (action.name) {
            case 'delete':
                helper.deleteSubscriptions(cmp,event,helper,row);
                break;
            case 'DeliveryAddress':
                cmp.set("v.SelectedRow",row);  
                ////console.log(JSON.stringify(cmp.get("v.SelectedRow")));
                cmp.set("v.isOpen", true);
                cmp.set("v.isAddress", true);
                cmp.set("v.isContact", false);
				cmp.set("v.SimType", false);
                break;
            case 'DeliveryContact':
                cmp.set("v.SelectedRow",row); 
                cmp.set("v.isOpen", true);
                cmp.set("v.isContact", true);
                cmp.set("v.isAddress", false);
				cmp.set("v.SimType", false);
                break;
			 case 'SIMTYPEReplacement':
                cmp.set("v.SelectedRow",row); 
                cmp.set("v.isOpen", true);
                cmp.set("v.SimType", true);
                break;
        }
    },
    //handle inline edit save of table
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveEdition(cmp, draftValues,helper);
    },
    
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
           component.set("v.isAddress", false);
           component.set("v.isContact", false);
           component.set("v.isOpen", false);
   },
    //on change of value of inline edit
    onInlineEdit: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        var draftString=JSON.stringify(draftValues);
        var filteredData=component.get("v.filteredData");
        filteredData.forEach(function(filData){
			draftValues.forEach(function (draftValue) 
			{
				if(draftValue.SubscriptionID==filData.SubscriptionID){
                     //EDGE-169091 || start
                    var errors = component.get("v.errors");
                    if(errors==undefined || errors==null ){
                        errors = { rows: {}, table: {} }
                    } 
                     //EDGE-169091 || end
                    if(draftString.includes('SimDispatchedRequired') && draftValue.SimDispatchedRequired==true){
						filData.IsDeliveryDetailsDisabled=false;
                        draftValue.IsDeliveryDetailsDisabled=false; 
                        filData.IsSimSerialNumber=true;
                        draftValue.IsSimSerialNumber=true;
                  	}
                  	else if(draftString.includes('SimDispatchedRequired') && draftValue.SimDispatchedRequired==false){
                        filData.IsDeliveryDetailsDisabled=true;
                        draftValue.IsDeliveryDetailsDisabled=true;
                         filData.IsSimSerialNumber=false;
                        draftValue.IsSimSerialNumber=false;
                  	}                    
                     //EDGE-169091 || start
                   if(draftValue.SimSerialNumber!=null && draftValue.SimSerialNumber!=''){
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
                    component.set("v.errors", errors);
                   //EDGE-169091 || end
                }
            });
        });
        event.setParam('draftValues',draftValues);
        component.set("v.filteredData",filteredData);
    },
    // on save from modal popup for custom lookup
   onSaveSelect: function(component, event, helper) {
      var row= component.get("v.SelectedRow");
      var SubscriptionID=row.SubscriptionID;
      var records=component.get("v.wrapList"); 
      var slectedRecordJson=JSON.stringify(component.get("v.selectedLookUpRecord"));
       var selectedRecordJsonContact=JSON.stringify(component.get("v.selectedLookUpContactRecord"));
      ////console.log('selected lookup record-->'+slectedRecordJson);
      records.forEach(function (record) {
          if(record.SubscriptionID==SubscriptionID){              
              if(component.get("v.isAddress")==true){
                  var address=component.get("v.selectedLookUpRecord");  
                  if(address!=null && address!=undefined){
                    record.DeliveryAddress=address.Name; 
                  	record.DeliveryAddressID=address.Id;  
                  }       
              }
              if(component.get("v.isContact")==true){
                  var contact=component.get("v.selectedLookUpContactRecord");
                  if(contact!=null && contact!=undefined){
                      if(selectedRecordJsonContact.includes('Email') && (JSON.stringify(component.get("v.selectedLookUpContactRecord")).includes('MobilePhone') || JSON.stringify(component.get("v.selectedLookUpContactRecord")).includes('Phone'))){
                          record.DeliveryContact=contact.Contact_Name__c; 
                          record.DeliveryContactID=contact.ContactId; 
                      }
                      else{
                          helper.showCustomToast(component, $A.get("$Label.c.DelivetyContactsValidation"), 'Contact error', 'Warning'); 
                      }
                  }
              }
			 //EDGE-165020 added by ankit || start
			if(component.get("v.SimType")==true){
				var SimType=component.get("v.simTypeSelected");
				 if(SimType!=null && SimType!=undefined){
                    if(JSON.stringify(component.get("v.simTypeSelected")) && SimType=='eSIM'){
						if(record.ProductOffer=='Corporate Mobile Plus'){
                          helper.showCustomToast(component, $A.get("$Label.c.SIMCardErrorForCMP"), 'Creating SIM Type Error', 'Warning'); 
						}
						else{
                            record.SimAvailabilityType='New SIM';   //EDGE-169091
							record.RequestedSIMType=SimType; 
							record.IsSimSerialNumber=true;
							record.SimDispatchedRequired=true;
							record.IsDeliveryDetailsDisabled=false;
						}
                    }
					else{
						if(JSON.stringify(component.get("v.simTypeSelected")) && SimType=='SIM Card'){
							record.RequestedSIMType=SimType; 
							record.IsSimSerialNumber=true;
							record.SimDispatchedRequired=false;
							record.IsDeliveryDetailsDisabled=true;
                            record.SimAvailabilityType='Existing Blank SIM';   //EDGE-169091

						}	
					}
            
                }
            }
			//EDGE-165020 added by ankit || End
          }                    
      });
      component.set("v.data", records);
      component.set("v.filteredData", records);
      component.set("v.wrapList",records);
      component.set("v.isAddress", false);
      component.set("v.isContact", false);
      component.set("v.isOpen", false);  
      ////console.log('row-->'+JSON.stringify(component.get("v.wrapList")));
   },
    onAddNew:  function(component, event, helper) {
        if(component.get("v.isAddress")==true){
            window.open("/lightning/n/Address_Search_New");
        }
        if(component.get("v.isContact")==true){
            window.open("/lightning/o/Contact/new");
        }         
    },
    // on click of submit order button
    SubmitOrder:  function(component, event, helper) {
        //console.log('Inside submit order');
        component.set("v.disabledSubmitOrder",true);
        var filteredData=component.get("v.filteredData");
  		var isDataEntered=true;
        filteredData.forEach(function(filData)
        {
			//
			if(filData.RequestedSIMType==null ||filData.RequestedSIMType==''){
                isDataEntered=false;
                component.set("v.disabledSubmitOrder",false);
                helper.showCustomToast(component, $A.get("$Label.c.RequestedSimRequired"), '', ''); 
            	 return;
            } 
			//EDGE-165020 added by ankit ||start
            if((filData.SimSerialNumber==null ||filData.SimSerialNumber=='') && filData.SimDispatchedRequired==false){
                isDataEntered=false;
                component.set("v.disabledSubmitOrder",false);
                helper.showCustomToast(component, $A.get("$Label.c.SimReplacementRequired"), '', 'error'); 
            	 return;
            }
			if(filData.SimDispatchedRequired==true && (filData.DeliveryAddressID==null||filData.DeliveryAddressID==''||filData.DeliveryContactID==""||filData.DeliveryContactID==null)){
				isDataEntered=false;
                component.set("v.disabledSubmitOrder",false);
                helper.showCustomToast(component, $A.get("$Label.c.DeliveryDetailsRequired"), '', 'error'); 
            	 return;
			}
			//EDGE-165020 added by ankit ||end
			//EDGE-167254 added by ankit ||start
			if(filData.isValidSIM==false && filData.SimSerialNumber !=null && filData.SimSerialNumber!='' && filData.SimDispatchedRequired==false){
				isDataEntered=false;
                component.set("v.disabledSubmitOrder",false);
                helper.showCustomToast(component, $A.get("$Label.c.ValidateSimSerialNumber"), '', 'error'); 
            	 return;
			}
			//EDGE-167254 added by ankit ||end
        }); 
    	
        if(isDataEntered)
        {
            //Added by Vamsi for DIGI-17911 26OCT2021 starts
            var date1 = new Date();
            var timeMilSec = date1.getTime();
            component.set('v.dateTimeMilliseconds',timeMilSec);
            helper.simReplacementLogs(component, event, helper);
            //Added by Vamsi for DIGI-17911 26OCT2021 ends
            helper.createOrders(component, event, helper);
        }
                
	},
    //EDGE-167254 added by ankit ||start
	qualifySIMSerial:  function(component, event, helper) {	
		var filteredData=component.get("v.filteredData");
		var newItems=[];
        var callQualifysim=false;
        //EDGE-169091 added by ankit ||start
        var errors = component.get("v.errors");
        if(errors==undefined || errors==null ){
            errors = { rows: {}, table: {} }
        }
        //EDGE-169091 added by ankit ||start
	    filteredData.forEach(function(filData)
        {	
            //EDGE-169091 || start
            if(filData.SimSerialNumber!=null && filData.SimSerialNumber!=''){
                var reg = new RegExp("^[0-9]{13}$");
                if(!reg.test(filData.SimSerialNumber)){
                    callQualifysim=true;
                    errors.rows[filData.SubscriptionID] = {title: 'error in Sim Serial Number', 
                                                           messages: ['Please enter a valid 13 digit numeric SIM Serial Number'],
                                                           fieldNames: ['SimSerialNumber']};
                }
            }
          
            //EDGE-169091 || end
			if(filData.SimDispatchedRequired==false && filData.SimSerialNumber !=null && filData.SimSerialNumber !='' && !filData.isValidSIM && !callQualifysim){
                newItems.push(filData);
			}
        });
        component.set("v.errors", errors); //EDGE-169091
        if(!callQualifysim){
		if(newItems && newItems.length>0){
			component.set("v.simValidList",newItems);
			helper.verifySIMSerial(component, event, helper);
        }else{
             helper.showCustomToast(component, $A.get("$Label.c.AlreadyQulifiedSim"), '', 'sucess'); 
        }

        }
	}    
     //EDGE-167254 added by ankit ||end
})