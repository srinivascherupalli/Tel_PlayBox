({
    
    doInit : function(component,event,helper){
		var recId = component.get('v.selectedRecordId');
       	console.log('*****Prepopulated record Id'+recId);
        //debugger;
       	if(recId != '' && recId !='undefined'){
            helper.searchRecord(component,event);
            //added by team Amstradam for EDGE-175758
            let objAPIName=component.get("v.objectAPIName");
            if(objAPIName=='OneFund__c'){
                helper.fetchOneFundType(component,event);
            }
        }
    },
    
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
       var accountSearch=component.get('v.isFetchAccount');
       console.log('accountSearch'+accountSearch);
       //debugger;
       if(!accountSearch){
           helper.searchHelper(component,event,getInputkeyWord);
       }
       else{
           helper.fetchAccountSearchHelper(component,event,getInputkeyWord);
       }
    },
    
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    keyPressController : function(component, event, helper) {
      //  debugger;
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            var accountSearch=component.get('v.isFetchAccount');
                   if(!accountSearch){
                     helper.searchHelper(component,event,getInputkeyWord);
                   }
                   else{
                       helper.fetchAccountSearchHelper(component,event,getInputkeyWord);
                   }
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
        //DIGI-27861 : Mofit Pathan Team Jaipur : Publish application event if selected billing account record is cleared
         console.log('Inside Clear function');
         console.log('v.objectAPIName='+component.get("v.objectAPIName"));
         let objAPIName=component.get("v.objectAPIName");
         let srcValue=component.get("v.Source");
         console.log('objAPIName='+objAPIName);
         console.log('srcValue='+srcValue); 
        
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );
         component.set("v.selectedRecordId", null );
			
        component.set("v.selectedOneFundType","");
        //component.set("v.Message","");
        
        if(objAPIName=='Billing_Account__c'){
            var appEvent = $A.get("e.c:salesup_CertitudeLookupAppEvent"); 
        	appEvent.setParams({
                "accountIdRecord":component.get("v.selectedRecordId"),
                "sourceValue":component.get("v.Source")
                });
        	appEvent.fire();
        	console.log('Application Event Fired for clear selection');
        }

    },
    
  /*  onChangeAmt:function(component,event,heplper){
        debugger;
        var CustomerAmount=component.get("v.customerRequestedTransferAmount");
        if (CustomerAmount!=undefined && CustomerAmount.toString().includes('.')) {
            var number =CustomerAmount.toString().split('.');
            if(number[1].length==2){
                component.set("v.customerRequestedTransferAmount",CustomerAmount);
                return;
            }else{
                var amt=number[0]+'.'+number[1].substring(0, 2);
                component.set("v.customerRequestedTransferAmount",amt);
                return;
            }
        } else {
            return;
        }
    },*/
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        //debugger;
    	// get the selected Account record from the COMPONETN event 	 
       	var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        
		console.log('selectedAccountGetFromEvent');
       	console.log(selectedAccountGetFromEvent);
	   	component.set("v.selectedRecord" , selectedAccountGetFromEvent);
       	component.set("v.selectedRecordId" , selectedAccountGetFromEvent.Id);
        component.set("v.selectedBillingRecordId" , selectedAccountGetFromEvent.Id);
        console.log('selectedAccountGetFromEvent=',selectedAccountGetFromEvent);
        console.log('selectedBillingRecordId=',selectedAccountGetFromEvent.Id);
        //EDGE-178650 added by Manish B
        let objAPIName=component.get("v.objectAPIName");
        let srcValue=component.get("v.Source");
        console.log('objAPIName='+objAPIName);
        console.log('srcValue='+srcValue);
        if(objAPIName=='OneFund__c'){
            component.set("v.selectedOneFundType" , selectedAccountGetFromEvent.OneFund_Type__c);
        }
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        
        //DIGI-27861 : Mofit Pathan Team Jaipur : Publish application event from selected billing account record
        if(objAPIName=='Billing_Account__c'){
            console.log('Inside if objAPIName='+objAPIName);
            console.log('Inside If Account Id :'+component.get("v.selectedBillingRecordId"));
            console.log('Inside If sourceValue :'+component.get("v.Source"));
            var appEvent = $A.get("e.c:salesup_CertitudeLookupAppEvent"); 
        	appEvent.setParams({
                "accountIdRecord":component.get("v.selectedBillingRecordId"),
                "sourceValue":component.get("v.Source")
                });
        	appEvent.fire();
        	console.log('Application Event Fired');
        } 
	},
    //DIGI-27861 : Mofit Pathan Team Jaipur : Subscribe application event from selected billing account record
    subEvt: function(component,event,helper){
        var acId = event.getParam("accountIdRecord");    
        var srcFromValue=event.getParam("sourceValue"); 
        var obName = component.get("v.objectAPIName");
        var srcToValue= component.get("v.Source");
        console.log("srcFromValue @@"+srcFromValue);
        console.log("srcToValue @@"+srcToValue);
        console.log("acId @@"+acId);
        console.log("obName @@"+obName);
        if(obName == "Invoice__c" && srcFromValue == srcToValue){
            if($A.util.isUndefinedOrNull(acId) || acId === ''){
                
                var pillTarget = component.find("lookup-pill");
         		var lookUpTarget = component.find("lookupField"); 
        
	            $A.util.addClass(pillTarget, 'slds-hide');
         		$A.util.removeClass(pillTarget, 'slds-show');
        
         		$A.util.addClass(lookUpTarget, 'slds-show');
         		$A.util.removeClass(lookUpTarget, 'slds-hide');
                
                component.set("v.accountId", null);
                component.set("v.SearchKeyWord",null);
       			component.set("v.listOfSearchRecords", null );
         		component.set("v.selectedRecord", {} );
         		component.set("v.selectedRecordId", null );
                console.log("v.accountId @@"+component.get("v.accountId"));
                console.log("v.selectedRecordId @@"+component.get("v.selectedRecordId"));
                console.log('handle application event-Null - Account Id & Selected Record Id');
            }
            else{
                component.set("v.accountId", acId);
                console.log('handle application event - Account Id :'+component.get("v.accountId"));
                
            }
        }
    },
})