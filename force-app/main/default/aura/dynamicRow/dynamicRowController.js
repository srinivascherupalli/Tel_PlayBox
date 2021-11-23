({
 
    
    // function call on component Load
    dynamicdoInit: function(component, event, helper) {
          //Toggle
         var action = component.get("c.featureToggle");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
            	//alert(storeResponse);
                component.set("v.toggle", storeResponse);
            }
 
        });
      // enqueue the Action  
      //Toggle
        
        component.set("v.storeselectedcon",component.get("v.selectedContact"));
        var url='';
        url=JSON.stringify(window.location.href);
        if(url.includes('Accountid=')){
            var res = url.indexOf('Accountid=');
            var accountId=url.substring(res+10,res+25);
            component.set("v.AccountId",accountId);
        }
    },
        keyPressController : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        var getInputkeyWord1 = component.get("v.AccountId");
        var isAllCon = component.get("v.isAllCon");
        if(getInputkeyWord!=null){
            if( getInputkeyWord.length > 0 || getInputkeyWord==''){
                 //var lookUpTarget = component.find("Test");
                  $A.util.addClass(lookUpTarget, 'slds-lookup__menu');
                  var forOpen = component.find("searchRes");
                  $A.util.addClass(forOpen, 'slds-is-open');
                  $A.util.removeClass(forOpen, 'slds-is-close');
                
                helper.searchHelper(component,event,getInputkeyWord,getInputkeyWord1,isAllCon);
            }else{
                //to remove lookup dialog 
                  var lookUpTarget = component.find("Test");
                  $A.util.removeClass(lookUpTarget, 'slds-lookup__menu');
                  component.set("v.listOfSearchRecords", null);
                  component.set("v.Message", null);
                
            }
         }
        else{  
            component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
         var getAccountValue = component.get("v.selectedRecordContactInstance");
        
	},
    
    handleApplicationEvent : function(component,event,helper){
        var primaryContact = event.getParam("primaryContactbyEvent");
        var isAllCon = event.getParam("isAllCon");
       
       // alert(primaryContact);
        component.set("v.selectedContact",primaryContact);
        component.set("v.storeselectedcon",primaryContact);
        component.set("v.isAllCon",isAllCon);
        
    },
    
    handleApplicationContactListEvent : function(component,event,helper){
        var secondaryContactList = event.getParam("selectedContactlistbyEvent");
        var isAllCon = event.getParam("isAllCon");
        component.set("v.secondaryContactList",secondaryContactList);
        component.set("v.isAllCon",isAllCon);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecordscon", null );
        var forclose = component.find("searchRes2");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
	keyPressControllerBilling : function(component, event, helper) {
        component.set("v.secondaryContactList","[]");
        var appEventCallParent= component.getEvent("appEventCallParentEvent");
        
            appEventCallParent.fire();
        var isAllCon = component.get("v.isAllCon");
      
		component.set("v.storeselectedcon",component.get("v.selectedContact"));
		var selectedContactGetFromEvent = event.getParam("contactByEvent");
       var forclosemore = component.find("lookuptest");
        		 $A.util.addClass(forclosemore, 'slds-is-open');
                 $A.util.removeClass(forclosemore, 'slds-hide');
       var forclose1 = component.find("lookup-348");
        		 $A.util.addClass(forclose1, 'slds-is-open');
                 $A.util.removeClass(forclose1, 'slds-hide');
        var forshow = component.find("lookuptest1");
                  $A.util.addClass(forshow, 'slds-show');
                   $A.util.removeClass(forshow, 'slds-hide');
              var getInputkeyWord = component.get("v.AccountId");    
        
       
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            
               var forOpen = component.find("searchRes2");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
               helper.searchHelperBilling(component,event,getInputkeyWord,isAllCon);
           	   
         }  
          else{  
                 component.set("v.listOfSearchRecordscon", null ); 
                 var forclose = component.find("searchRes2");
                 $A.util.addClass(forclose, 'slds-is-close');
                 $A.util.removeClass(forclose, 'slds-is-open');
             }
         var getAccountValue = component.get("v.selectedRecord");
       if(getAccountValue == null || getAccountValue == ''){
           var forhide = component.find("icon");
           $A.util.addClass(forhide, 'slds-hide');
           $A.util.removeClass(forhide, 'slds-show');
       }
       
    },
    clearBilling :function(component,event,heplper){
        
        var container = component.find("lookup-pill2");

         var pillTarget2 = component.find("lookup-pill2");
         var lookUpTarget2 = component.find("lookupField2");
         $A.util.addClass(pillTarget2, 'slds-hide');
         $A.util.removeClass(pillTarget2, 'slds-show');
        var forhide = component.find("icon");
           $A.util.addClass(forhide, 'slds-show');
           $A.util.removeClass(forhide, 'slds-hide');
         component.set("v.SearchKeyWord", "");
        
       	 $A.util.addClass(lookUpTarget2, 'slds-show');
         $A.util.removeClass(lookUpTarget2, 'slds-hide');
        
        component.set("v.selectedRecordContactInstance",null);
		component.set("v.selectedContact",component.get("v.storeselectedcon"));
        
        component.set("v.testShowHide" , false);
          },
      
   
     AddNewRow : function(component, event, helper){
       // fire the AddNewRowEvt Lightning Event 
        component.set("v.rowCount",component.get("v.rowCount")+1);
        component.getEvent("AddRowEvt").setParams({"selectedContactAddbyEvent" : component.get("v.selectedRecordContactInstance") }).fire();     
    },
    
    removeRow : function(component, event, helper){
     // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
       component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    
    handleComponentEventBilling : function(component, event, helper) { 

       var selectedContactGetFromEvent = event.getParam("contactByEventDynamic");
      
       if(selectedContactGetFromEvent != null){
           
           /* if(selectedContactGetFromEvent.Contact.Email == null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                title : 'Error Message',
                message:'Email Address is Required for Billing Contact',
                messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                key: 'info_alt',
                type: 'info',
                mode: 'dismissible'});
        		toastEvent.fire();
                
				var forclose = component.find("lookup-pill2");
				$A.util.addClass(forclose, 'slds-hide');
				$A.util.removeClass(forclose, 'slds-show');
                
           		var forclose = component.find("searchRes2");
           		$A.util.addClass(forclose, 'slds-is-close');
           		$A.util.removeClass(forclose, 'slds-is-open');
                
           		var lookUpTarget = component.find("lookupField2");
           		$A.util.addClass(lookUpTarget, 'slds-show');
           		$A.util.removeClass(lookUpTarget, 'slds-hide');  
           }
           
           else{*/
               component.set("v.selectedRecordContactInstance" , selectedContactGetFromEvent); 
               component.set("v.testShowHide" , true);
               var forclose = component.find("lookup-pill2");
				$A.util.addClass(forclose, 'slds-show');
           		$A.util.removeClass(forclose, 'slds-hide');
      
               var forclose = component.find("searchRes2");
           		$A.util.addClass(forclose, 'slds-is-close');
           		$A.util.removeClass(forclose, 'slds-is-open');
				
               var lookUpTarget = component.find("lookupField2");
            	$A.util.addClass(lookUpTarget, 'slds-hide');
            	$A.util.removeClass(lookUpTarget, 'slds-show'); 
              
        }

        
	}
})