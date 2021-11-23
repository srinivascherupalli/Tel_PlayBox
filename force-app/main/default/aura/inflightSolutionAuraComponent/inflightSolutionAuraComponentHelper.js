({
	getOpportunityRecID : function(component,event,helper) {
		var recId = component.get("v.recordId");
        var action = component.get("c.getOpportunityIdForTheOrder");
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === 'SUCCESS'){
                var oppId = response.getReturnValue();
                component.set("v.opportuntiId",oppId);
            }
        });
        $A.enqueueAction(action);
	},
    
    getSelectedRecord : function(component,event,helper){
     var recId = component.get("v.recordId");
        var action = component.get("c.getOpportunityRoleRecord");
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('recordSelected ',component.get("v.recordSelected"));
                var ocr = response.getReturnValue();
                if(ocr!=='' && ocr!==null){
                    console.log('selected req -->',ocr);
                    component.set("v.selectedLookUpRecord",JSON.parse(JSON.stringify(ocr)));
                    component.set("v.recordSelected",true);
                   console.log('default requestor ',component.get("v.selectedLookUpRecord"));
                }
                
                console.log('ocr ',ocr);
            }
        });
        $A.enqueueAction(action);
    },

    getOrderNumber : function(component,event,helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getOrderNumber");
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var orderNumber = response.getReturnValue();
                component.set("v.orderNumber",orderNumber);
            }
        });
        $A.enqueueAction(action);
    },

    getAmendTypes : function(component, event, helper){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName':"cscfga__Product_Basket__c",
            'field_apiname': "Amend_Type__c",
            'nullRequired': true // includes --None--
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('pick list values ',response.getReturnValue());
                component.set("v.MACD_ActionTypes", response.getReturnValue());
            } else{
                console.log('error in getting pick list val');
            }
        });
        $A.enqueueAction(action);
    },

    checkCurrentUserProfile : function(component, event, helper){
        var action = component.get("c.checkLoggedInUserProfile");
        action.setCallback(this, function(response){
            var state = response.getState();
           // debugger;
            if(state === "SUCCESS"){
                var showTelstraCaseNumber = response.getReturnValue();
                component.set("v.showTelstraCaseNumber",showTelstraCaseNumber);
                console.log('show field to user '+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    checkForAbleToAmend : function(component, event, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.checkForPointOfNoContact");
        var pointofNoContact;
        var offerOnOrder;
        var inflightBasketExists;
       
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('point of no contact is ',response.getReturnValue());
              var result = response.getReturnValue();
                if(result['amend rejected']){
                    component.set("v.showError",false);
                    component.set("v.showComponent",true);
                    component.set("v.amendRejected",true);
                    this.defaultFieldsIfAmendRejected(component, event, helper);
                }
                else if(result['PONR reached'] && result['order status']){
                    component.set("v.showError",false);
                    component.set("v.showComponent",true);
                }else if(!result['PONR reached']){
                    component.set("v.showError",true);
                    component.set("v.showAmendRestrictionError",false);
                    component.set("v.showErrorForStatus",false);
                    let delay = 10000;
                    setTimeout(() =>{
                       // component.set("v.showError",false);
                    }, delay);
                }else if(!result['order status']){
                    component.set("v.showErrorForStatus",true);
                    component.set("v.showError",false);
                    component.set("v.showAmendRestrictionError",false);
                    let delay = 10000;
                    setTimeout(() =>{
                       // component.set("v.showError",false);
                    }, delay);
                }
            }
        });
        $A.enqueueAction(action);

       /* action = component.get("c.CheckOfferOnOrder");
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
            debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('CheckOfferOnOrder is ',response.getReturnValue());
                offerOnOrder = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);

        action = component.get("c.IsInflightBasketExists");
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
            debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('IsInflightBasketExists ',response.getReturnValue());
                inflightBasketExists = response.getReturnValue();
                if(pointofNoContact && offerOnOrder && inflightBasketExists){
                    component.set("v.enableAmend",true);
                 }else{
                     component.set("v.enableAmend",false);
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "title": "Order cannot be amended",
                         "message": "You are not able to amend",
                         "type": "error"
                     });
                     toastEvent.fire();
                     component.set("v.showError",true);
                     let delay = 10000;
                     setTimeout(() =>{
                         component.set("v.showError",false);
                     }, delay);
                 }
            }
        });
        $A.enqueueAction(action);
         */
       
    },
    checkAmendRestriction : function(component, event, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.checkAmendRestriction");
       
        action.setParams({
            "orderId" : recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('inside checkAmendRestriction ',response.getReturnValue());
                var result = response.getReturnValue();
                if(result['Amend Restricted']){
                    component.set("v.showAmendRestrictionError",true);
                    component.set("v.showErrorForStatus",false);
                    component.set("v.showError",false);
                    component.set("v.showComponent",false);
                }
                else {
                    component.set("v.showAmendRestrictionError",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    defaultFieldsIfAmendRejected : function(component, event, helper){
        
        var amendRej = component.get("v.amendRejected");
        console.log('amend rej ',amendRej);
        if(amendRej){
            var action = component.get("c.getDefaultValues");
            var recId = component.get("v.recordId");
            action.setParams({
                "amendRejected" : true,
                "orderId" : recId
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                  console.log('result is ',response.getReturnValue());
                  var result = response.getReturnValue();
                  component.set("v.amendTypeSelected",result['amed type']);
                  component.set("v.telstraCaseNumber",result['tesltra case number']);
                }else{
                  console.log('error in fethcing q default value');
                }
            });

            $A.enqueueAction(action);

        }
    }
})