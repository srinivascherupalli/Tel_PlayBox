/*
Name : CustomlookupResult Controller
Description : Lightning Helper functions for Post verificatio of numbers 
Author: Kalashree Borgaonkar
Story: EDGE-90327
*/
({
	 selectAccount : function(component, event, helper){      
    // get the selected Account from list  
      var getSelectAccount = component.get("v.oAccount");
 
    // call the event   
      var compEvent = component.getEvent("oSelectedAccountEvent");
    // set the Selected Account to the event attribute.  
         compEvent.setParams({"accountByEvent" : getSelectAccount });  
    // fire the event  
         compEvent.fire();
    },
    selectContact : function(component, event, helper){  
         // get the selected contact from list 
              
      var getSelectContact = component.get("v.oContact");
       var compEvent = component.getEvent("oSelectedContactEvent");      
       
        //EDGE-138687 defect fix 
        var signatoryCheck = component.get("v.isSignatory");
      
        if(component.get("v.isSecondComponentCall")){
           
         compEvent.setParams({"contactByEvent" : getSelectContact });  
           
         }else{
          
             //EDGE-138687 defect fix :Passed isSignatory attribute value in the event
         compEvent.setParams({"contactByEventDynamic" : getSelectContact,"isSignatory": signatoryCheck});  
            
       }
         compEvent.fire();
    
    },
    
     // EDGE-201557 START
    selectPPAContact : function(component, event, helper){  
       
         // get the selected contact from list               
       var getSelectContact = component.get("v.oPPAContact");
       var compEvent = component.getEvent("oSelectedPPAContactEvent");      
       
        //EDGE-138687 defect fix 
        var signatoryCheck = component.get("v.isPPASignatory");
       
        if(component.get("v.isSecondComponentCall")){
         	compEvent.setParams({"contactPPAByEvent" : getSelectContact });
         }else{
            compEvent.setParams({"contactPPAByEventDynamic" : getSelectContact,"isPPASignatory": signatoryCheck});  
         }
         compEvent.fire();
    },
     // EDGE-201557 END
     
    //Kala
    selectPort : function(component, event, helper){  
        // get the selected contact from list 
        console.log('selectPort');
        var getSelectPort = component.get("v.oPort");
        console.log('portByEvent::',component.get("v.oPort.Service_Number__c"));
        var compEvent = component.getEvent("oSelectedPortEvent");       
        compEvent.setParams({"portByEvent" : getSelectPort });  
        
        compEvent.fire();
        
    },
    
    
    
    selectAddress : function(component, event, helper){      
        // get the selected address from list  
        var getSelectAddresss = component.get("v.oAddress");
        // call the event   
        var compEvent = component.getEvent("oSelectedAddressEvent");
        // set the Selected address to the event attribute.  
        compEvent.setParams({"addressByEvent" : getSelectAddresss });  
        // fire the event  
        compEvent.fire();
    },
     selectAutoAddress : function(component, event, helper){      
    // get the selected address from list  
      var getSelectAddresss = component.get("v.oRecord");
    // call the event   
      var compEvent = component.getEvent("oSelectedAutoAddressEvent");
    // set the Selected address to the event attribute.  
         compEvent.setParams({"addressAutoEvent" : getSelectAddresss });  
    // fire the event  
         compEvent.fire();
    },
    handleNewRecordClick: function(component, event, helper) {
        console.log('Inside handleNewRecordClick');
        event.preventDefault();
        event.stopPropagation();
        helper.addNewRecord(component, event, helper);
    },
   
})