({
    helperMethod : function() {
        
    },
    validateForm : function(component,event){
        var banNUM=component.find('banNumberField');
        var banNumValue=banNUM.get("v.value");
        var NMprod=component.find('NMprod');
        var NMprodValue=NMprod.get("v.value");
        var credAmount=component.find('creditAmount');
        var credAmountValue=banNUM.get("v.value");
        var creditDate=component.find('datefield');
        var creditDateValue=creditDate.get("v.value");
        var reasonCode=component.find('reasonCodeField');
        var reasonCodeValue=reasonCode.get("v.value");
        console.log(reasonCodeValue);
        var formCredit;
        if(component.get("v.isPredebt")){
            formCredit=$A.util.isEmpty(banNumValue)|| $A.util.isEmpty(NMprodValue) ||$A.util.isEmpty(credAmountValue)|| $A.util.isEmpty(creditDateValue);
        }
        else{
            formCredit=$A.util.isEmpty(banNumValue)|| $A.util.isEmpty(NMprodValue) ||$A.util.isEmpty(credAmountValue) || $A.util.isEmpty(reasonCodeValue)|| reasonCodeValue=='--None--'|| $A.util.isEmpty(creditDateValue);
        }
        
        if(formCredit)  
        {
            component.set('v.isformvalid',false);
        }else{
            
            component.set('v.isformvalid',true);
        }  
        var selectProduct=component.get("v.selectedList");
		 if(selectProduct.length>0)
		 {
			 component.set('v.isValid',true);
		 }
		 else{
            component.set('v.isValid',false);
        } 
		
    },
    
    
    handleSubmit: function(component,event)
    {      
        this.validateForm(component,event);
        var isValid=component.get('v.isValid');
        var val=component.get('v.isformvalid');
        if(!val)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please complete all the mandatory fields.",
                "type":"Error"
            });
            toastEvent.fire();
        }
        else if (!isValid)
		{
		 var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": $A.get("$Label.c.OnceOff_Error"),
                "type":"Error"
            });
            toastEvent.fire();	
		}
        else
        {  
          if(component.get("v.caseRecord.RecordType.DeveloperName") == $A.get("$Label.c.Insolvency_Management"))  
          {
          component.set('v.showConfirmDialog', true);
          }
          else
          {
           this.handleSubmitData(component,event,'');   
          }
        }
    },
    handleSubmitData:function(component,event,helper)
           {
            component.set("v.loadData",true);
            var eventFields = event.getParam("fields");   
            var cred=component.get("v.CreditObj");
            console.log('cred==>'+cred);
            var creditID= component.get("v.CredAdjId");
            var reasonCode=component.find('reasonCodeField');
            var reasonCodeValue=reasonCode.get("v.value");
            var credAdj={
                'Billing_Account_Number_BAN__c': component.get('v.CreditObj.Billing_Account_Number_BAN__c'),
                'Credit_Change_Amount__c': component.get('v.CreditObj.Credit_Change_Amount__c'),
                'Date_when_credit_was_given_to_customer__c':component.get('v.CreditObj.Date_when_credit_was_given_to_customer__c'),
                'Non_Marketable_Product__c': component.get('v.CreditObj.Non_Marketable_Product__c'),
                'Reason_Code__c':reasonCodeValue
            };
            
            console.log('credAdj==>'+credAdj);
            var caseIDdetail= component.get("v.recordId");
            console.log('caseIDdetail==>'+caseIDdetail);
            var action = component.get("c.SaveCreditAdjustmentRec");
            action.setParams({"credAdj" : credAdj,"caseIDdetail": caseIDdetail, "creditID":creditID});         
            action.setCallback(this, function(response) {
                var CredObj= response.getReturnValue();
                console.log(CredObj);
                //alert(CredObj);
                if(CredObj!=null && CredObj!='null')
                {
                    component.set("v.CredAdjId", CredObj["Id"]);
                    this.MakeCallout(component,event,CredObj );
                    
                }
                else
                {
                    component.set("v.loadData",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The Case is already closed.",
                        "type":"Error"
                    });
                    toastEvent.fire();
                }
                
});
            $A.enqueueAction(action);
},
			
    MakeCallout:function(component,event,credAdj) 
    {
        var action = component.get("c.makeCallout");
        action.setParams({"credAdj" : credAdj, "isPredebt":component.get("v.isPredebt"),"caseRecord":component.get("v.caseRecord.RecordType.DeveloperName"),"caseNumber":component.get("v.caseRecord.CaseNumber")}); 
        action.setCallback(this, function(response) {
            var mapValues= response.getReturnValue(); 
            var myJSON = JSON.stringify(mapValues);
            console.log(myJSON);
            var credID=component.get("v.CredAdjId");
            component.set("v.loadData",false);
            if(mapValues!= null)
            {
                if(myJSON.includes('Error') )
                {
                    var errormsg=mapValues['Error'];
                    this.handleError(component,event,credID,errormsg);
                }
                else{
                    this.handleSuccess(component,event,credID);
                }
            }else
            {
                this.handleError(component,event,credAdj.id,'Some error occured.');
            }
            
        });
        $A.enqueueAction(action);
    },
    
    handleSuccess:function(component, event, credAdjId){
        var toastEvent = $A.get("e.force:showToast");
        
        if(component.get("v.caseRecord.RecordType.DeveloperName") == $A.get("$Label.c.Insolvency_Management"))
        {
            toastEvent.setParams({
                "title": "Success!",
                "message": $A.get("$Label.c.Insolvency_Sucess"),
                "type":"Success"
            });
        }
        //DPG-3598 start.
        else if(component.get("v.nonMarketableProductName") == $A.get("$Label.c.ServiceEstablishmentProductId"))
        {
            toastEvent.setParams({
                "title": "Success!",
                "message": $A.get("$Label.c.Service_Establishment_Fee_Success"),
                "type":"Success"
            });
        }
        //DPG-3598 End.
        else
        { 
            toastEvent.setParams({
                "title": "Success!",
                "message": "Once-off Credit Adjustment has been sent to billing system, the case has been closed.",
                "type":"Success"
            });
        }
        toastEvent.fire();
        this.CallUpdateCase(component,credAdjId,'');
        /* */
    },
    handleError:function(component, event, credAdjId,errormsg){
        //alert("Error");
        var toastEvent = $A.get("e.force:showToast");
        if(component.get("v.caseRecord.RecordType.DeveloperName") == $A.get("$Label.c.Insolvency_Management"))
        {
            toastEvent.setParams({
                "title": "Error!",
                "message": $A.get("$Label.c.Insolvency_Error")+' '+errormsg,
                "type":"Error"
            });              
        }
        //DPG-3598 start.
        else if(component.get("v.nonMarketableProductName") == $A.get("$Label.c.ServiceEstablishmentProductId"))
        {
            toastEvent.setParams({
                "title": "Error!",
                "message": $A.get("$Label.c.Service_Establishment_Fee_Error")+' '+errormsg,
                "type":"Error"
            });              
        }
        //DPG-3598 End.
        else
        {
            toastEvent.setParams({
                "title": "Error!",
                "message": "Once-off Credit Adjustment submission failed, please re-submit for the case. "+errormsg,
                "type":"Error"
            });
        }
        toastEvent.fire();
        this.CallUpdateCase(component,credAdjId,errormsg);
    },
    CallUpdateCase:function(component, credAdjId, failureReason)
    {
        var CaseID= component.get("v.recordId");
        var action = component.get("c.updateCaseDetails");
        action.setParams({"CaseID" : CaseID,"credAdjId": credAdjId,"failureReason": failureReason,"caseRecord":component.get("v.caseRecord.RecordType.DeveloperName")}); 
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        if(failureReason=='')
        {           
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                //"slideDevName": "detail"
            });
            navEvt.fire();
        }
    },
    /*  EDGE-149630: Fetch Billing Account Predebt or not for a billing account*/
     checkPredebtBANHelper : function(component, event, helper) {
        var billingAccId= component.get("v.CreditObj.Billing_Account_Number_BAN__c");
        var action= component.get("c.checkPredebtAccount");
        action.setParams({"billingAccountId":billingAccId});
        
		action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
            component.set("v.preDebt",response.getReturnValue());
             }
             });
        $A.enqueueAction(action);
    },
    
    /*  EDGE-158381: Get selected product data from custom meta data*/
    checkSelectedProductHelper : function(component, event, helper) {
        var selectedProduct= component.get("v.CreditObj.Non_Marketable_Product__c");
        var recordType=component.get("v.caseRecord.RecordType.DeveloperName");
        var action= component.get("c.getSelectedProduct");
        action.setParams({"productName":selectedProduct,"caseRecordType":recordType});
        
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log(response.getState());
            if(state==='SUCCESS'){
                component.set("v.caseInputMap",response.getReturnValue());
                var mapValue=component.get("v.caseInputMap");
                component.set("v.selectedList",mapValue["selectedProduct"]);
                if(component.get("v.selectedList[0].Adjustment_Type__c") == "Credit")
                {
                   component.set("v.isPredebt",false); 
                }
                else if(component.get("v.selectedList[0].Adjustment_Type__c") == "Debit")
                    {
                        component.set("v.isPredebt",true);
                    } 
            }           
        });
        $A.enqueueAction(action);
        this.fetchSelectedProductName(component, 'Reason_Code__c', 'reasonCodeField');
    },
    fetchSelectedProductName: function(component, fieldName, elementId){
        var selectedProduct= component.get("v.CreditObj.Non_Marketable_Product__c");
        
        var action= component.get("c.getSelectedProductName");
        action.setParams({"productName":selectedProduct});
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log(response.getState());
            if(state==='SUCCESS'){
                
                var productName = response.getReturnValue();
                
                component.set("v.nonMarketableProductName",productName);
                this.fetchPickListVal(component, 'Reason_Code__c', 'reasonCodeField');
            }           
        });
        $A.enqueueAction(action);
       
    },
    /* EDGE-149471 : get Picklist values for reason code */
    fetchPickListVal: function(component, fieldName, elementId) {
        var selectedProduct= component.get("v.nonMarketableProductName");
        var action = component.get("c.getselectOptions");
        
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fieldName": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            console.log(response.getState());
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("values",allValues);
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--None--",
                        value: ""
                    });
                }
                
                
                var serviceEnablement;
                for (var i = 0; i < allValues.length; i++) {
                    if (component.get("v.caseRecord.RecordType.DeveloperName") == $A.get("$Label.c.Insolvency_Management") && allValues[i] == "Insolvent Credit" && component.get("v.isPredebt") == false){
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    else if (component.get("v.caseRecord.RecordType.DeveloperName") != $A.get("$Label.c.Insolvency_Management") && allValues[i] != "Insolvent Credit"){
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });    
                    }
                    if(selectedProduct == $A.get("$Label.c.ServiceEstablishmentProductId") && allValues[i] == "Service Establishment Fees"){
                        serviceEnablement = true;
                        console.log(selectedProduct);

                    }
                }
                //DPG-3598 start.
                if(serviceEnablement){
                   
                    opts = [];
                    opts.push({
                        class: "optionClass",
                        label: "Service Establishment Fees",
                        value: "Service Establishment Fees",
                        selected: "true"
                    });
                    component.set("v.disableReasonCode", true);
                }
                else{
                    component.set("v.disableReasonCode", false);
                }
                //DPG-3598 end.
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    
})