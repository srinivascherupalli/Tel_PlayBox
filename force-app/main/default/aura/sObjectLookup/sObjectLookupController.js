({
    handleSearchRecords : function (component, event, helper) {
        var searchText = component.find("searchinput").get("v.value");
        if(searchText){
            helper.searchRecord(component,searchText);
        }else{
            helper.searchRecord(component, '');
            component.set("v.selectedRecordId", '');
        }
    },
     
    handleLookupSelectEvent : function (component, event, helper) {
        var selectedRecordId = event.getParam("recordId");
        var selectedrecordName = event.getParam("recordName");
       // alert('---->'+selectedRecordId +'!!!!!!--> '+selectedrecordName);
        if(selectedrecordName == '--$$NotValidEmailId$$--'){
            // Dont nothing. Dont select anything
        }
        else{
            $A.util.removeClass(document.getElementById('CustomerContactSignatory'),'slds-has-error');
            $A.util.removeClass(document.getElementById('TelstraCountersignatory'),'slds-has-error'); 
            $A.util.addClass(document.getElementById('error-message-unique-id_CustomerContactSignatory'),'toggleClass');
            $A.util.addClass(document.getElementById('error-message-unique-id_TelstraCountersignatory'),'toggleClass');
            component.set("v.selectedRecordId", selectedRecordId);
            component.set("v.selectedRecordName", selectedrecordName);
            helper.toggleLookupList(component, false, 'slds-combobox-lookup', 'slds-is-open');
        }
    },
     
    hideList :function (component,event,helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    helper.toggleLookupList(component, false, 'slds-combobox-lookup','slds-is-open');
                }
            }), 200
        );
    },
    
    handleshowErrorContract:function (component,event,helper) {        
        var selectedFieldId = event.getParam("fieldId");
        var ErrorMsg = event.getParam("ErrorMsg");
        var showError = event.getParam("showError");
        
        var toggleField = document.getElementById(selectedFieldId);
        var toggleText = document.getElementById('error-message-unique-id_'+selectedFieldId);
        
        $A.util.removeClass(document.getElementById('CustomerContactSignatory'),'slds-has-error');
         $A.util.removeClass(document.getElementById('TelstraCountersignatory'),'slds-has-error');
        $A.util.addClass(document.getElementById('error-message-unique-id_CustomerContactSignatory'),'toggleClass');
        $A.util.addClass(document.getElementById('error-message-unique-id_TelstraCountersignatory'),'toggleClass');
        
        component.set("v.errorMsgText", ErrorMsg);
        $A.util.addClass(toggleField,'slds-has-error');
        $A.util.removeClass(toggleText,'toggleClass');
        
    }
})