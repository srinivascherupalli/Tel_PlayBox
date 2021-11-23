({
     doInit : function(cmp, event, helper) {
         debugger;
          var isPartner = false; 
         var actions = [
            {label: 'View', name: 'view'}
        ];
          cmp.set('v.columns', [
            {label: 'ProductBasket Name', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'Description', fieldName: 'Description__c', type: 'text' },
            {label: 'Created By', fieldName: 'Created_By__c', type: 'text' },
			{label: 'Basket Stage', fieldName: 'csordtelcoa__Basket_Stage__c', type: 'text' },
			//{label: 'Basket Type', fieldName: 'BasketType__c', type: 'string' },
			{label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'Date' },
            //{type: 'action', typeAttributes: { rowActions: actions } } 
            ]);
            
            var resultMsg = JSON.parse( sessionStorage.getItem( 'pageTransfer' ));
            //alert('resultMsg'+resultMsg.state.c__viewAllBool);
            if(resultMsg != null ){
              cmp.set("v.viewAllBool", resultMsg.state.c__viewAllBool);
              cmp.set("v.recordId", resultMsg.state.c__recordId);

            }
            console.log('inside init...');
            var action = cmp.get("c.getRelatedList");
            action.setParams({ accountId : cmp.get("v.recordId")});
              
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                var baseurl = window.location.href;
				if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) {  
                  isPartner = true;
                 }
                            
                console.log('Inside Success...'+response.getReturnValue());
                if(response.getReturnValue()){
                      var records =response.getReturnValue();
                      var count =  JSON.parse( sessionStorage.getItem( 'count' ));
                      //alert('count'+records.length);;
                    

                      if(records.length > 0)

                     {
                       cmp.set("v.viewAllBool",true);
                       
                     }
             

                      /* if(count !=null && count > 0)
                      {
                        cmp.set("v.viewAllBool",false);
                      }*/

              //alert('Count'+ count);
              //alert('viewall'+ cmp.get("v.viewAllBool"));
               
                        records.forEach(function(record){
                         if(isPartner){
                        var navService = cmp.find("navService");
                        var pageReference = {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: record.Id,
                                objectApiName :'cscfga__Product_Basket__c',
                                actionName: 'view'
                            }
                        };
                        
                        navService.generateUrl(pageReference)
                        .then($A.getCallback(function(url) {
                         console.log('url'+url);
                         //console.log('defaultUrl'+defaultUrl);
                            record.linkName = url ;
                        }));
                    }else
                            record.linkName = '/'+record.Id;
                        });

              if(count>0){
              console.log('Inside if');
              cmp.set("v.viewAllBool", false);
              cmp.set("v.headerviewBool", false);
              
              }else{
              cmp.set("v.headerviewBool", true);
              }

                     sessionStorage.removeItem('count');
              console.log('basketList'+response.getReturnValue());
              if(isPartner){
                    setTimeout( $A.getCallback(function(){
                       cmp.set("v.basketList", response.getReturnValue());
                    }),3000);
                }else
                   
                    cmp.set("v.basketList", response.getReturnValue());
              //alert('In if');
                 
                }
                else{
                  //alert('In else');
                    console.log('display error...');
                    cmp.set("v.displayError", true);
                    
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "mode": "dismissible",
                        "duration":'15000',
                        "type": "error",
                        "message": "No records found."
                    });
                    resultsToast.fire();

                    
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
        
	loadAll : function(component, event, helper) {
        
        component.set("v.viewAllBool", false);
        //helper.getBaskets(component, helper,100);
        
    },
    
        navHome : function (component, event, helper) {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "cscfga__Product_Basket__c"
            });
            homeEvent.fire();
        },
    gotoRelatedList : function (component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Product_Baskets",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
    },
    
    //This function is used redirect to the  record.
    navigatetoBasket: function (cmp, event, helper) {
        var evt = $A.get("e.force:navigateToSObject");
        var pbdatasetId = event.currentTarget.dataset.id;
        evt.setParams({
            "recordId": pbdatasetId,
            "slideDevName": "related"
        });
        evt.fire();
    },
    
   
 
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'view':
                helper.viewRecord(component, event);
                break;
        }
    },
     navigateToMyComponent: function (cmp, event, helper) {
        var baseurl = window.location.href;
       //cmp.set("v.count",2);
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) {  
            sessionStorage.setItem('count', 1);
             var navService = cmp.find("navService");
           
            var pageReference = {  
                "type": "comm__namedPage",
                "attributes": {
                    "pageName": "noncommbasket"    
                },    
                "state": {

                                        "c__viewAllBool": "true",
                                        "c__headerviewBool":"true",

                    "c__conIconName": "" ,
                    "c__recordId":cmp.get("v.recordId")
                }
            };
            sessionStorage.removeItem('pageTransfer');
            sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference));
          navService.navigate(pageReference);      
        }else
        {
            sessionStorage.setItem('count', 1);
            var evt = $A.get("e.force:navigateToComponent");
        	evt.setParams({
            componentDef: "c:FilterNonCommBasket",
            componentAttributes: {
                viewAllBool: "false",
                conIconName: "",
                recordId: cmp.get("v.recordId")

            }
        });
        evt.fire();
            /*var pageReference = {  
                "type": "standard__component",
                "attributes": {
                    "pageName": "c__CustomRelatedlist_ViewAll"    
                },    
                "state": {
                    "c__ViewAllRec": "false"  ,
                    "c__conIconName": "" ,
                    "c__recordId":cmp.get("v.recordId")
                }
            };*/
        }
       
    },
         navigateAccountrelated: function (component, event, helper) {
             debugger;
        event.preventDefault();
        var acclistviewLabel = $A.get("$Label.c.AccountListViewRelatedContacts");

        var action = component.get("c.getListViews");
        action.setParams({
            sobjectTypeName: "Account",
            listviewDeveloperName: acclistviewLabel
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Account"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
       navigateAccountRec: function (component, event, helper) {
        event.preventDefault();
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        evt.fire();
    }
    
})