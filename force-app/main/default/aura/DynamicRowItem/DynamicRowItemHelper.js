({
    //EDGE - 80749, AC5 Method to add row
    addNewRow : function(component, event) {
        // fire the AddNewRowEvt Lightning Event 
        component.getEvent("AddRowEvt").fire();    
    },
    //EDGE - 80749, AC6 Method to delete row
    removeRow : function(component, event) {
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
    
    //EDGE - 80749, AC3 Method to Invoke Qualify callout
    qualifyCallout :  function(component, event) {
        var msisdn = component.get("v.msisdnNumber.num");
        var basketId=component.get("v.basketId");
        var accountNumber = component.get("v.msisdnNumber.accountNumber");
        if(msisdn == null || msisdn =='' || msisdn.length<8 || /\D/.test(msisdn)){
           
             this.showCustomToast(component, $A.get("$Label.c.PortInValidationMessage"), "error", "error");
        }else if( /[^\w]|_/g.test(accountNumber)){
         
            this.showCustomToast(component, $A.get("$Label.c.PortInIncumbentAccNum"), "error", "error");

        }
		else{
             msisdn = '614'+msisdn;
        //showCustomToast
        component.set("v.loadingSpinner", true);
        var accountNumber = component.get("v.msisdnNumber.accountNumber");
        var action = component.get("c.getQualifyResponse");
        action.setParams({
            "msisdn": msisdn,
            "accountNumber" : accountNumber,
            "basketid":basketId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") { 
                var resp  = response.getReturnValue();
                component.set("v.loadingSpinner", false);
                if(resp!=null && resp.message!=null){
                    component.set("v.msisdnNumber.message",resp.message);
                    this.showCustomToast(component, resp.message, "error", "error");
                } 
                else if(resp==null){  
                   //var errors = response.getError();
                component.set("v.loadingSpinner", false);
                this.showCustomToast(component, 'Error', "Error", "Error");
            } 
                else{
                    component.set("v.msisdnNumber.num",resp.num);
                    component.set("v.msisdnNumber.accountNumber",resp.accountNumber);
                    component.set("v.msisdnNumber.reason",resp.reason);
                    component.set("v.msisdnNumber.code",resp.code);
                    component.set("v.msisdnNumber.indicator",resp.indicator);
                    component.set("v.msisdnNumber.uniqueBakset",resp.uniqueBakset);
                }
            }
           
        });
        $A.enqueueAction(action);	
        }    
    },  
    //EDGE - 80749 Method to display status reason
    display : function(component,event) {
        var toggleText = component.find("tooltip");
        //$A.util.toggleClass(toggleText, 'toggle');
        $A.util.removeClass(toggleText,'slds-hide');
        $A.util.addClass(toggleText,'slds-show');
    },
    //EDGE - 80749 Method to hide status reason
    displayout : function(component,event) {
        var toggleText = component.find("tooltip");
        //$A.util.toggleClass(toggleText, 'toggle');
        $A.util.removeClass(toggleText,'slds-show');
        $A.util.addClass(toggleText,'slds-hide');
    } ,
    //EDGE - 80749 to show error/success message
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
    handleSelectAllNumbers:function(component,event) {
    },
     /*------------------------------------------------------
     * EDGE-107149
     * Method:handleOnSelect
     * Description:Method to handle checkbox selection
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
    handleOnSelect:function(component,event) {
        var isSelected = component.get('v.msisdnNumber');
        var rowIndex = component.get('v.rowIndex');
        /*var selectedNum = component.get("v.selectedNumber");
        selectedNum = selectedNum+1;
        component.set("v.selectedNumber",selectedNum);
        if(selectedNum>=1){
            this.showCustomToast(component,$A.get("$Label.c.QualifyMsisdnMessage"), "Warning", "warning");
        }*/
        //EDGE-129897, Kalashree Borgaonkar. Send rowid
var compEvent = component.getEvent("SelectRow").setParams({"isSelectAll" : isSelected.isSelect,"rowIndex":rowIndex }).fire();         	
    },
        /*------------------------------------------------------
     * EDGE-89257
     * Method:showCustomToast
     * Description:Method to show toast
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
    showCustomToast: function (cmp, message, title, type) {
        $A.createComponent(
            "c:customToast", {
                "type": type,
                "message": message,
                "title": title,
                
            },
            function (customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");
                    body.set("v.body", customComp);
                }
            }
        );
    },
})