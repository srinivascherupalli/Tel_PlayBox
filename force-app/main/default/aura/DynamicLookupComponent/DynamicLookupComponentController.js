({
    //to fetch logged in userprofile 
    doInit: function (component, event,helper){
        component.set("v.loadingSpinner", true);
		let source = component.get("v.source");//Added part of EDGE-167053  
        var action = component.get("c.getUserInformation");
        action.setCallback(this, function(response) {
        var state = response.getState();
        if(state == "SUCCESS" && component.isValid()){
        component.set("v.loadingSpinner", false);
        var result = response.getReturnValue();
        console.log('result profile',result);
        var disableicon  = component.find("icon-disable");
        var borderColor  = component.find("greyBorder");
        if(result == true  && source!= 'InvoiceCmp' ){
        component.set("v.userProfile", true);
        $A.util.addClass(disableicon, 'icon-disable');
        $A.util.addClass(borderColor, 'greyBorder');
        $A.util.addClass(borderColor, 'noouterbox');
          }
        else{
          $A.util.removeClass(disableicon, 'icon-disable');
          $A.util.removeClass(borderColor, 'greyBorder');
          $A.util.removeClass(borderColor, 'noouterbox');
            }
        }else{
            console.error("fail:" + response.getError()[0].message); 
            }
        });
        $A.enqueueAction(action);
        
    },
    
        onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        console.log('getInputkeyWord&&' ,getInputkeyWord);
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    // function for clear the Record Selection 
    clear :function(component,event,heplper){
        var getSelectRecord = component.get("v.selectedRecord");
        // call the  clearEvent and Fire
        var compEvent = component.getEvent("SelectedRecordEvent");
        compEvent.setParams({"clearEvent" : getSelectRecord });  
        compEvent.fire();
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedRecordGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedRecordGetFromEvent); 
        var field = component.get('v.primaryField');
        var key = 'v.selectedRecord.'+field;
        var primaryresult = component.get(key);
        component.set('v.fieldName', primaryresult);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');   
    },
    //Added for EDGE-207867 by Aman Soni || Start
    GetSelectedCase : function(component, event, helper){
        // get the selected Account record from the COMPONETN event
        var cas = event.getParam("caseByEvent");
        component.set("v.selectedRecord" , cas);

        component.set('v.fieldName', 'Case Number - ' +cas.CaseNumber);

        
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
    //Added for EDGE-207867 by Aman Soni || End
})