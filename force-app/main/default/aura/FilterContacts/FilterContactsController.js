/****************************************************************************
@Name: FilterContactsController
@Author: Sravanthi(Team SFO)
@CreateDate: 12/3/2020
@Description: Sprint 20.04 , P2OB-5245 ,P2OB-4979 ,SFO 20.06 :P2OB-5883
============================================================================
ChangeSet   No    Name            Date                    Description
EDGE-151592 1     Purushottam     14-07-2020              View related list in PRM to the authorised Partners
*******************************************************************************/
({
    //This function calls helper fetchData Function to retrieve related Contacts
    doInit: function (cmp, event, helper) {
        // Added by Purushottam : EDGE-151592  Start 
        var resultMsg = JSON.parse( sessionStorage.getItem( 'pageTransfer' ));
        if(resultMsg != null  && cmp.get("v.recordId") == null){
            cmp.set("v.recordId", resultMsg.state.c__recordId);
            cmp.set("v.ViewAllRec", resultMsg.state.c__ViewAllRec);
            cmp.set("v.conIconName", resultMsg.state.c__conIconName);
        }
        // Added by Purushottam : EDGE-151592  End
        helper.fetchData(cmp, event, helper);
    },

    //This function calls helper contactSave Function to save inline edited contacts.
    handleSaveEdition: function (cmp, event, helper) {
        helper.contactSave(cmp, event, helper);

    },
    //This function is to redirect to view all records functionality ,recalls the same lightning component.
    navigateToMyComponent: function (cmp, event, helper) {
        // Added by Purushottam : EDGE-151592  Start - Navigate to filtercontacts page in Community
        var baseurl = window.location.href;
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) {  
            var navService = cmp.find("navService");
            var pageReference = {  
                "type": "comm__namedPage",
                "attributes": {
                    "pageName": "filtercontacts"    
                },    
                "state": {
                    "c__ViewAllRec": "false"  ,
                    "c__conIconName": "" ,
                    "c__recordId":cmp.get("v.recordId")
                }
            };
            sessionStorage.removeItem('pageTransfer');
            sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference));
            navService.navigate(pageReference);   
        }else
        // Added by Purushottam : EDGE-151592  End
        {
            var evt = $A.get("e.force:navigateToComponent");
        	evt.setParams({
            componentDef: "c:FilterContacts",
            componentAttributes: {
                ViewAllRec: "false",
                conIconName: "",
                recordId: cmp.get("v.recordId")

            }
        });
        evt.fire();
        }
    },
    //This function refreshes the lightning component data after change of lightning select option to get relevant data.
    refresh: function (cmp, event, helper) {
        //initialLoad is set to false to refrain from fetching the column data again
        cmp.set("v.initialLoad", false);
        helper.fetchData(cmp, event, helper);
    },
    //This function refreshes the lightning component after the e.force:refreshView event is triggered after contact save.
    isRefreshed: function (cmp, event, helper) {
        cmp.set("v.initialLoad", true);
        //SFO 20.09 :P2OB-6724 Setting the filter based on Browser
        if(cmp.get("v.isMobile")){
            cmp.set("v.Filter", cmp.find('selectMobile').get('v.value'));
        }
        else{
            cmp.set("v.Filter", cmp.find('select').get('v.value'));
        }
        helper.fetchData(cmp, event, helper);
    },
    //This function is used in mobile view of lightning component to redirect to the contact record.
    navigatetoContact: function (cmp, event, helper) {
        var evt = $A.get("e.force:navigateToSObject");
        var contactdatasetId = event.currentTarget.dataset.id;
        evt.setParams({
            "recordId": contactdatasetId,
            "slideDevName": "related"
        });
        evt.fire();
    },
    //This function is used to sort data in lightning datatable.
    handleSort: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortBy", fieldName);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    //P2OB-5883 This function fires standard createRecord event for contact object on click of new button 
    createContact: function (component, event, helper) {
        var windowHash = window.location.hash;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact",
            "recordTypeId":component.get("v.recordTypeId"),  //Added by Purushottam : EDGE-151592 
            "defaultFieldValues": {
                'AccountId': component.get("v.recordId"),
                'Contact_Status__c':'Active'				//Added by Purushottam : EDGE-151592
            },
            "panelOnDestroyCallback": function (event) {
                window.location.hash = windowHash;
            },
            "navigationLocation": "LOOKUP"
        });


        createRecordEvent.fire();
    },
    //P2OB:6724 : onclick of Breadcrumb redirect to recentlyviewed list view on view all screen
    navigateAccountrelated: function (component, event, helper) {
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
    //P2OB:6724 : onclick of Breadcrumb redirect to account record on view all screen
    navigateAccountRec: function (component, event, helper) {
        event.preventDefault();
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        evt.fire();
    }

});