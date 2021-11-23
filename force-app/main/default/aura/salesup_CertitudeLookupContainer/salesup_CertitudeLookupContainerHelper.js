({
    fetchAccountSearchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
      // P2OB-5524 check if Partner account search use case
        var partnerSearch = component.get('v.isPartnerAccountSearch');
        console.log('partnerSearch*****'+partnerSearch+'*******'+component.get("v.accountId"));
        var action;
        if(partnerSearch){
            // P2OB-5524 if partner account search call the new partner search method and pass distributor id
        	action = component.get("c.fetchPartnerAccount");
            action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'primaryDistributorId' : component.get("v.accountId")
          });
        }else{
            // P2OB-5524 for non partners call normal search method
            action = component.get("c.fetchAccountLookUpValues");
            action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'AdditionalSOQL': component.get("v.SOQLFilter")   // added part of EDGE-150892 to manage additional filetes for SOQL
          });
        }
      // set param to method   fetchLookUpValuesForInit
        
        action.setCallback(this, function(response) {
          //  debugger;
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('Lookup results');
                console.log(storeResponse);
                
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
                
            }
 
        });
        $A.enqueueAction(action);
    
	},
    
	searchHelper : function(component,event,getInputkeyWord) {
      //  debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method   fetchLookUpValuesForInit
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'accountId':component.get("v.accountId"),
            'AdditionalSOQL': component.get("v.SOQLFilter")   //added part of EDGE-150892 to manage additional filetes for SOQL
          });
        console.log('Account Id :'+component.get("v.accountId"));
      // set a callBack    
        action.setCallback(this, function(response) {
         //   debugger;
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('Lookup results');
                console.log(storeResponse);
                let objAPIName=component.get("v.objectAPIName");
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    if(objAPIName=='ContractJunction__c'){
                         var conJunctionMessage = $A.get("$Label.c.Contract_Junction_No_Result_Found_error_message");
                         component.set("v.Message",conJunctionMessage);


                    }else if(objAPIName=='OneFund__c'){
                        var oneFundMessage = $A.get("$Label.c.OneFund_No_Result_Found_Message");
                        component.set("v.Message",oneFundMessage);
                    }else if(objAPIName=='Billing_Account__c'){
                        var billingAccountMessage = $A.get("$Label.c.Billing_Account_No_Result_Found_Message");
                        component.set("v.Message",billingAccountMessage);


                    }else{
                         component.set("v.Message", 'No Result Found...');
                    }
                   
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
                
            }
 
        });
        $A.enqueueAction(action);
    
	},
    searchRecord : function(component,event) {
       // debugger;
    	// call the apex class method 
     	console.log('HELPER called**********8'+component.get("v.objectAPIName"));
        var recId = component.get("v.selectedRecordId");
        console.log('recId in HELPER*****'+recId);
        var action = component.get("c.fetchSelectedRecord");
        // set param to method   fetchLookUpValuesForInit
        action.setParams({
            'recordId': recId,
            'ObjectName' : component.get("v.objectAPIName")
          });
        action.setCallback(this, function(response){
            //debugger;
            console.log('*****response*****'+response);
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('STRINGIFY*********'+JSON.stringify(response.getReturnValue()));
                component.set("v.selectedRecord",response.getReturnValue());

                if(response.getReturnValue() != null && response.getReturnValue() != ''){
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
          
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show'); 
            }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchOneFundType : function(component,event){
        var recId = component.get("v.selectedRecordId");
        console.log('recId in @@@@@'+recId);
        var action = component.get("c.getOneFundType");
        action.setParams({
            'recordId': recId
          });
        action.setCallback(this, function(response){
            console.log('*****response*****'+response);
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('STRINGIFY*********'+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() != null && response.getReturnValue() != ''){
                component.set("v.selectedOneFundType",response.getReturnValue());
               }
            }
        });
        $A.enqueueAction(action);
    },
})