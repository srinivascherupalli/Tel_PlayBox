({
  doInit: function(component, event, helper) {
    console.log('in controller');
    component.set("v.columns", helper.getColumnDefinitions());
    // component.set("v.isFailure",false);
    component.set("v.theBtnLabel", "Submit Order");
    //EDGE-89984
    const empApi = component.find('empApi');
    empApi.onError($A.getCallback(error => {
      console.error('EMP API error for ChangeOfMobileNumber : ', error);}));
      //till here
    },
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
      
    },
    
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
      component.set("v.isOpen", false);
    },
    
    likenClose: function(component, event, helper) {
      
      console.log('G*G liken close called');
      //Start of DIGI-17910 by Gautam Kumar
      helper.insertTransactionLogs_HelperEntry(component, component.get("v.accountId"), component.get("v.actionTypeSelected"));
      //End of DIGI-17910 by Gautam Kumar
      component.set("v.showSpinner", true);
      var filteredData = component.get("v.selectedRowsList");
      var actType = component.get("v.actionTypeSelected");
      var tNowCsRef =  component.get("v.tNowCaseRef");
      //var reason =  component.get("v.reason");//DPG-4542
      var allSelectedSubId = [];
      var subscriptionToReasonMap = {};//DPG-4542
      filteredData.forEach(function(filData) {
        allSelectedSubId.push(filData.SubscriptionID);
        //DPG-4542 START
        if(actType=="Suspend"){
          subscriptionToReasonMap[filData.SubscriptionID] = filData.suspensionReasonCode;
        }
        else if(actType=="Resume"){
          subscriptionToReasonMap[filData.SubscriptionID] = filData.resumeReasonCode;
        }
        //DPG- 4542 END 
        
      });
      
      
      //DPG-4542(Extra parameter needs to be sent and retrieved)(this will be a map)(ila work todo)
      var action = component.get("c.submitOrderForSuspend");
      //scenarioType //EDGE-132715 Added tNowCaseRef
      action.setParams({
        subId : allSelectedSubId,
        scenarioType : actType,
        //reason : reason,//DPG-4543 || Ila(Commented reason, instead passing subscriptionToReasonMap )
        tNowCaseRef : tNowCsRef,
        subsToReasonMap :subscriptionToReasonMap //DPG:4543 , Ila
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        var res = response.getReturnValue();
        //console.log('Inside Submit Order Button');
        var accId =  component.get("v.accountId"); 
        // alert(state);
        if(state === 'SUCCESS'){
          //if (res == 'Success'){ //Shweta commented this  EDGE:185521
          component.set("v.showSpinner", false);
          component.set("v.disabled",true);
          //Toast
          
          component.set("v.isSuccess",true); 
          //Start of DIGI-17910 by Gautam Kumar
          console.log('G*G insertTransactionLogs_HelperExit called');
          helper.insertTransactionLogs_HelperExit(component, component.get("v.accountId"), component.get("v.actionTypeSelected"), res, component.get("v.correlationId"));
          //End of DIGI-17910 by Gautam Kumar

          //helper.redirectToAccountPage(component,accId); //Shweta commented this  EDGE:185521
          helper.redirectToOrderPage(component,res); //Shweta added this  EDGE:185521
          //}
        }
        else {
          component.set("v.isFailure",true);
          helper.redirectToAccountPage(component,accId); 
          
        }
        
        //} 
        //EDGE-89984::start
        const empApi = component.find('empApi');
        const SubmitStatus = component.find('nextbtn').get('v.value');
        const replayId = -1;
        // Subscribe to the event
        empApi.subscribe(SubmitStatus, replayId, $A.getCallback(eventReceived => {
          console.log('Received event ', JSON.stringify(eventReceived));
        }))
        .then(subscription => {
          console.log('Event Recieved!');
        });
        //EDGE-89984::End
      });
      $A.enqueueAction(action); 
      
      
    },
    
    NavigateComponent: function(component, event, helper) {
      component.set("v.isOpen", true);
      var message = event.getParam("filteredData");
      
      var accID = event.getParam("accountId");
      var actType = event.getParam("actTypeSelected");
      // var reason = event.getParam("reason"); //DPG-4542
      var tNowRef = event.getParam("tNowCaseRef");//EDGE-132715
      //component.set("v.reason", reason);//DPG-4542
      component.set("v.tNowCaseRef", tNowRef);
      
      component.set("v.actionTypeSelected", actType);
      let selectedRecordSub = event.getParam("selectedRecordSub");
      let selectedRows = [];
      var cols=component.get("v.columns");
      if(component.get("v.actionTypeSelected")=='Resume')
      {
        //DPG-4252(Resume reason will be shown while resuming) start
        /*cols.push({label: 'Suspension Reason',
        fieldName: 'suspensionReason',
        type: 'text',
        sortable: true});*/
        var resumeReasonBlock = {label: 'Resume Reason', 
        fieldName: 'resumeReason',
        type: 'text',
        sortable: true};
        if(cols[cols.length - 1].fieldName =='suspensionReason'){
          cols.splice(-1,1,resumeReasonBlock);
        }
        else if(cols[cols.length - 1].fieldName !='resumeReason'){
          cols.push(resumeReasonBlock);
        }
        
        //DPG-4542 End
      }else{
        component.set("v.columns", helper.getColumnDefinitions());
        cols = component.get("v.columns");
        //DPG-4252(Suspend reason will be shown while suspending) start
        cols.push({
          label: 'Suspension Reason', 
          fieldName: 'suspensionReason',
          type: 'text',
          sortable: true
        });
        //DPG-4542 End
      }
      
      component.set("v.columns", cols);
      message.forEach(function(obj) {
        //alert(JSON.stringify(obj.SubscriptionID));
        if(selectedRecordSub.includes(obj.SubscriptionID)){ 
          selectedRows.push(obj);
        }
        //  alert(JSON.stringify(obj));
        // selectedRows.push(obj.Id); 
      });
      //Set the handler attributes based on event data
      // component.set("v.filteredData", message);
      component.set("v.filteredData", selectedRows);
      component.set("v.data", message);
      component.set("v.accountId", accID);
      
    },
    
    updateSelectedText: function(component, event, helper) {
      component.set("v.selectedRowsList", event.getParam("selectedRows"));
      component.set("v.btnStatus", false);
      //alert(component.get("v.selectedRowsList"));
    },
    updateColumnSorting: function(component, event, helper) {
      component.set("v.isLoading", true);
      setTimeout(function() {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
        component.set("v.isLoading", false);
      }, 0);
    },
    filter: function(component, event, helper) {
      var data = component.get("v.data"),
      term = component.get("v.filter"),
      results = data,
      regex;
      try {
        regex = new RegExp(term, "i");
        // filter checks each row, constructs new array where function returns true
        results = data.filter(
          row =>
          regex.test(row.subscriptionName) ||
          regex.test(row.ServiceId) ||
          regex.test(row.subscriptionNumber)
          );
        } catch (e) {}
        component.set("v.filteredData", results);
        var data1 = component.get("v.filteredData");
        if (data1.length == 0) {
          component.set("v.NoSearchRecord", true);
        }
        if (data1.length != 0) {
          component.set("v.NoSearchRecord", false);
        }
      },
      SubmitOrder: function(component, event, helper) {}
    });