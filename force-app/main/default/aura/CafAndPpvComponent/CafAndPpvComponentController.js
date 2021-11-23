({
    
  getContactsForCAFInput : function(component, event, helper) {
  helper.getContactsForCAFInput(component, event);
},
  getContactsForInput : function(component, event, helper) {
  helper.getContactsForInput(component, event);
},
  handleContactEvent: function(component, event, helper) {
  helper.handleContactEvent(component, event);
},
  //EDGE-201557 START  
  handlePPAContactEvent: function(component, event, helper) {
  helper.handlePPAContactEvent(component, event);
},
  //EDGE-201557 END
  handlePortEvent: function(component, event, helper) {
  helper.handlePortEvent(component, event);
},
  getPortNumForInput: function(component, event, helper) {
  helper.getPortNumForInput(component, event);
},
  
  saveDetails: function(component, event, helper) {
      helper.saveDetails(component, event);
  },
  
  handleCAFRefresh: function(component, event, helper){
    console.log('in handleCAFRefresh');
       helper.getQualifiedNumbers(component, event);
},
    //DIGI-778:Handle logic to disable the send SMS button
  handleSendSMSButtonLogic: function(component, event, helper){
    console.log('in handleSendSMSButtonLogic');
    //helper.handleSendSMSButtonLogic(component, event);
},
 //DIGI-779:Handle logic to disable the send SMS button
  SendSMSButton: function(component, event, helper){
  console.log('in SendSMSButton');
  helper.SendSMSButton(component, event);
},
//DIGI-779:Handle logic to disable the send SMS button
  VerifyOTPButton: function(component, event, helper){
  console.log('in VerifyOTPButton');
  helper.VerifyOTPButton(component, event);
},
 /*//DIGI-779:Handle logic to disable the Verfify OTP button
 handleVerifyOTPButtonLogic: function(component, event, helper){
  console.log('in handleVerifyOTPButtonLogic');
  helper.handleVerifyOTPButtonLogic(component, event);
},*/
  handleSelectedrecords: function(component, event, helper){
      helper.handleSelectedrecords(component, event);
      console.log("handleSelectedrecords");
},
  resendPPV : function(component, event, helper){
       helper.resendPPV(component, event) ;
  },
  handleOnchange : function(component, event, helper){//EDGE-154222
     helper.handleOnchange(component, event) ;
  },
  doInit: function (component, event, helper) {
      component.set("v.showFirstLast",true);
      console.log( ' showFirstLast ',component.get("v.showFirstLast"));
       component.set('v.columns', [
          {label: 'Qualified Numbers', fieldName: 'qualifiedMsisdn', type: 'text'},
          {label: 'Included in CA', fieldName: 'isIncluded', type: 'text' ,hideDefaultActions: true},
           {label: 'PPV Status', fieldName: 'ppvStatus', type: 'text'},//DIGI-778: Added PPV status Column
      ]);
           helper.getQualifiedNumbers(component, event);
           helper.getDetails(component, event);
           
  },
  openModel: function(component, event, helper) {
    // Set isModalOpen attribute to true
    component.set("v.isModalOpen", true);
 },

 closeModel: function(component, event, helper) {
    // Set isModalOpen attribute to false  
    component.set("v.isModalOpen", false);
 },

 submitDetails: function(component, event, helper) {
    // Set isModalOpen attribute to false
    //Add your code to call apex method or do some processing
    component.set("v.isModalOpen", false);
 }   
      
})