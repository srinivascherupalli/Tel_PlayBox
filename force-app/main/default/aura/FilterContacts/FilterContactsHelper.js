/****************************************************************************
@Name: FilterContactsHelper
@Author: Sravanthi(Team SFO)
@CreateDate: 12/3/2020
@Description: Sprint 20.04 , P2OB-5245,P2OB-4979,P2OB-5904
============================================================================
ChangeSet   No    Name            Date                    Description
EDGE-151592 1     Purushottam     14-07-2020              View related list in PRM to the authorised Partners
*******************************************************************************/
({
    //This helper function calls the FilterContactsController.getDataAndColumns method to get related Contact data
    fetchData: function (cmp, event, helper) {
        helper.browserData(cmp, event, helper);
        
        cmp.set("v.Spinner", true);
        
        var action = cmp.get("c.getDataAndColumns");
        console.log(cmp.get("v.initialLoad"));
        //SFO 20.09 :P2OB-6724 Setting the filter based on Browser
        if(cmp.get("v.isMobile")){
            var select = cmp.find('selectMobile').get('v.value');
        }
        else {
            var select = cmp.find('select').get('v.value');
        }

        action.setParams({
            recordId: cmp.get("v.recordId"),
            filter: select,
            viewAll: cmp.get("v.ViewAllRec"),
            initialLoad: cmp.get("v.initialLoad"),
            listFieldsToQuery: cmp.get("v.fieldstoQuery")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				//Added by Purushottam - EDGE-151592 Start - Check for Partner users
                var isPartner = false; 
                var baseurl = window.location.href;
				if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) {  
                 var isPartner = true;
                 }
                 //Added by Purushottam - EDGE-151592 End
                var records = response.getReturnValue().lstTableData;
                records.forEach(function (record) {
                    //Added by Purushottam - EDGE-151592 Start - NavService was added for partner functionality 
                    if(isPartner){
                        var navService = cmp.find("navService");
                        var pageReference = {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: record.Id,
                                actionName: 'view'
                            }
                        };
                        navService.generateUrl(pageReference)
                        .then($A.getCallback(function(url) {
                            record.linkName = url ? url : defaultUrl;
                        }));
                    }
                    else
                        record.linkName = '/' + record.Id;
                    //Added by Purushottam - EDGE-151592 End
                    record.accountName = record.Account.Name;
                    record.linkAccountName = '/' + record.AccountId;
                    //P2OB-4979 , Setting Active Flag column based on Contact Status
                    if(record.Contact_Status__c == 'Active'){
                        record.Active = true;
                    }
                    else{
                        record.Active = false;
                    }
                });
                console.log(records+'SUCESS');
                //Added by Purushottam - EDGE-151592 Start - For Partners delayed 2 secs to set the records
                if(isPartner){
                    setTimeout( $A.getCallback(function(){
                        cmp.set("v.contactList", records);
                    }),2000);
                }else
                    //Added by Purushottam - EDGE-151592 End
                    cmp.set("v.contactList", records);
                
                if (cmp.get("v.initialLoad")) {
                    helper.setColumnData(cmp, event, helper,response);
                    cmp.set("v.fieldstoQuery", response.getReturnValue().listFieldsToQuery);
                }
                cmp.set("v.createConaccess",response.getReturnValue().createConaccess);
                cmp.set("v.isPOR",response.getReturnValue().isPOR); //Added by Purushottam - EDGE-151592
                cmp.set("v.recordTypeId",response.getReturnValue().recordTypeId);
            }
            else if (state === 'ERROR') {
                console.log('ERROR');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);

                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin');
            }
            cmp.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    //This helper function calls the FilterContactsController.updateContacts method to save related Contact data and set datatable errors.
    contactSave: function (cmp, event, helper) {

        cmp.set("v.Spinner", true);

        var draftValues = event.getParam('draftValues');
        var action = cmp.get("c.updateContacts");
        //P2OB-4979 , Updating Contact Status based on Active Flag column 
        draftValues.forEach(function(record){
            if(record.Active == true){
                record.Contact_Status__c ='Active';
            }
            else if(record.Active == false){
                record.Contact_Status__c ='Inactive';
            }
        });

        action.setParams({ "contactList": draftValues });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }

            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {


                    var errorsfin = { rows: {}, table: {} };
                    let errorData = JSON.parse(errors[0].message);

                    for (var index = 0; index < errorData.length; index++) {



                        if (errorData[index].name == 'FIELD_CUSTOM_VALIDATION_EXCEPTION' || errorData[index].name == 'INSUFFICIENT_ACCESS_OR_READONLY') {
                            errorsfin.rows[errorData[index].code] = {
                                title: "We hit a snag.",
                                messages: errorData[index].message,
                                fieldNames: ['Name']
                            };
                        }
                        else {
                            console.error(errorData[index].message + errorData[index].name);
                            errorsfin.rows[errorData[index].code] = {
                                title: "System Error:",
                                messages: 'Your request has failed.Please try again later and log feedback case if the problem persists.',
                                fieldNames: ['Name']
                            };
                        }
                    }


                    cmp.set("v.errors", errorsfin);
                }
            }
            cmp.set("v.Spinner", false);
        });

        $A.enqueueAction(action);

    },
    //This function is used to sort data in lightning datatable.
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.contactList");
        var reverse = sortDirection !== 'asc';
        if(fieldName=='linkName') fieldName='Name';//SFO 20.06, P2OB-5904
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.contactList", data);
    },
    //This function is used to sort data in lightning datatable.
    sortBy: function (field, reverse, primer) {
        console.log(primer);
        var key = primer ?
    //SFO 20.06, P2OB-5904 for case insensitive sorting
        function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
        function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {            
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    } ,
    //This helper function sets view all attribute to false for mobile device 
    //to retrieve all records and desktop limited to 5 records if view all is not clicked.
    browserData :function(cmp, event, helper){
        if (cmp.get("v.ViewAllRec") == null && $A.get('$Browser.formFactor') == 'DESKTOP') {
            cmp.set("v.ViewAllRec", "true")
        }
        else if ($A.get('$Browser.formFactor') == 'PHONE') {
            cmp.set("v.ViewAllRec", "false")
        }
        cmp.set('v.isMobile', $A.get('$Browser.formFactor') == 'DESKTOP' ? false : true);
    },

    //This helper function is used set to column data on initial load.P2OB-4979 , Adding Active column to lignhtning datatable columns,P2OB-5905 Bug Fix 
    setColumnData :function(cmp, event, helper,response){
        var nameattr = [{ label: 'Name', fieldName: 'linkName', type: 'url',sortable: 'true', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' } }];
        if(cmp.get('v.isMobile')){
            var statusCheck = [{ label: 'Active', fieldName: 'Active' ,type: 'checkbox'}];
            var colattr = response.getReturnValue().ColumnProperties.concat(statusCheck);
        }
        else{
            var statusCheck = [{ label: 'Active', fieldName: 'Active' ,type: 'boolean' , sortable: 'true', editable: 'true'}];
            var colattr = nameattr.concat(response.getReturnValue().ColumnProperties,statusCheck);
        }
        cmp.set("v.columns", colattr);
    }

});