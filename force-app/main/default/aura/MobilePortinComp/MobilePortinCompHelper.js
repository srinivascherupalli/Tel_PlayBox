({  doInit: function(component, event) {
    var basketId = component.get("v.basketid");
    var action = component.get("c.getDetails");
    action.setParams({
        basketid: basketId
    });
    // set call back
    action.setCallback(this, function(response) {
        var state = response.getState();
    	if (state === "SUCCESS") {
            var resp = response.getReturnValue();
            component.set("v.detailWrapper", resp);
           
        } else {
           
        }
    });
    // enqueue the server side action
    $A.enqueueAction(action);
    
},
  fetchQualifiedPortList: function (component, event) {
    var basketId = component.get("v.basketid");
     var action = component.get("c.getQualifiedMsisdn"); 
      action.setParams({
          "basketid": basketId
      });
      // set call back 
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var resp  = response.getReturnValue();
              var qualifiedNumList = response.getReturnValue();
              if(qualifiedNumList==null || qualifiedNumList.length==0){
                  component.set("v.areNumQualified",false);
              }
              else{
                  component.set("v.areNumQualified",true);
                  component.set("v.portSelectionList", qualifiedNumList);
                  component.set("v.dispList", qualifiedNumList);
                  component.set("v.columns", qualifiedNumList.length); 
                  //EDGE:88791  fires pagination event to set parameters
                  var appEvent = $A.get("e.c:paginationEvent");
                  appEvent.setParams({"PageData" : component.get('v.dispList'),
                                      "StartRecord" : 1,
                                      "EndRecord" : 1,
                                      "CurrentPage" : component.get('v.CurrentPage'),
                                      "TotalPages" : Math.ceil(qualifiedNumList.length /component.get('v.PageSize')),
                                      "PageSize" : component.get('v.PageSize'),
                                      "TotalRecords" :component.get('v.dispList').length}); 
                  appEvent.fire();
                 this.dispMethod(component);
              }
          }
          else{
              
          }  
      });
      // enqueue the server side action  
      $A.enqueueAction(action);
  },
  getContactsForInput: function(component, event) {
      var accountid = component.get("v.detailWrapper.accountid");
      var oppId = component.get("v.detailWrapper.oppId");
      var getInputString = component.get("v.searchContact");
      if (getInputString != null || getInputString != '') {
          if (getInputString.length > 0 || getInputString == "") {
             
              var forOpen = component.find("searchRes3");
              $A.util.addClass(forOpen, "slds-is-open");
              $A.util.removeClass(forOpen, "slds-is-close");
              var forclose2 = component.find("lookupContact");
              $A.util.addClass(forclose2, "slds-is-open");
              $A.util.removeClass(forclose2, "slds-hide");
              
              this.searchContact(component, event, getInputString, accountid, oppId);
              
              //helper.searchContact(component,event,getInputString);
          } else {
              var forclose = component.find("searchRes3");
              $A.util.addClass(forclose, "slds-is-close");
              $A.util.removeClass(forclose, "slds-is-open");
              var forclose2 = component.find("lookupContact");
              $A.util.addClass(forclose2, "slds-is-close");
              $A.util.removeClass(forclose2, "slds-is-open");
              component.set("v.searchContact",null);
          }
      }
  },
  searchContact: function(component, event, getInputString, accountid, oppid) {
      var action = component.get("c.getContactsForSearch");
      action.setParams({
          accountId: accountid,
          oppId: oppid,
          searchText: getInputString
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var data = response.getReturnValue();
              component.set("v.listOfContactRecords", data);
            
              component.set("v.listOfContact", data);
          }
      });
      $A.enqueueAction(action);
  },
  searchPort: function(component, event, getInputString, accountid, oppid) {
      var action = component.get("c.getPortInMsisdns");
      action.setParams({
          accountId: accountid,
          oppId: oppid,
          searchText: getInputString
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var data = response.getReturnValue();
              component.set("v.listOfPortNumbers", data);
          }
      });
      $A.enqueueAction(action);
  },
  getPortNumForInput: function(component, event) {
      var accountid = component.get("v.detailWrapper.accountid");
      var oppId = component.get("v.detailWrapper.oppId");
      var getInputString = component.get("v.searchPortNum");
      if (getInputString != null) {
          if (getInputString.length > 0 || getInputString == "") {
              var forOpen = component.find("searchRes4");
              $A.util.addClass(forOpen, "slds-is-open");
              $A.util.removeClass(forOpen, "slds-is-close");
              var forclose2 = component.find("lookupPort");
              $A.util.addClass(forclose2, "slds-is-open");
              $A.util.removeClass(forclose2, "slds-hide");
              this.searchPort(component, event, getInputString, accountid, oppId);
              
          } else {
              var forclose = component.find("searchRes3");
              $A.util.addClass(forclose, "slds-is-close");
              $A.util.removeClass(forclose, "slds-is-open");
              var forclose2 = component.find("lookupContact");
              $A.util.addClass(forclose2, "slds-is-close");
              $A.util.removeClass(forclose2, "slds-is-open");
          }
      }
  },
  handleOnblur: function(component, event) {
      var portNum = component.get("v.searchPortNum");
      var contact = component.get("v.searchContact");
      if (
          portNum != null &&
          portNum != "" &&
          (contact != null && contact != "")
      ) {
          component.set("v.isSaveDisabled", false);
      } else {
          component.set("v.isSaveDisabled", true);
      }
  },
  handleContactEvent: function(component, event) {
      var eventParam = event.getParam("contactByEventDynamic");
      var contactName = eventParam.Contact.Name;
      //EDGE-138687 defect fix
      var signatory =  event.getParam("isSignatory");
      var getInputString = component.get("v.searchCustContact");
      var getcontactString = component.get("v.searchContact");
     
      //EDGE-138687 defect fix : Added signatory check
      if(getcontactString != null && getcontactString.length > 0 && signatory==false){
        
          component.set("v.searchContact", contactName);
          component.set("v.listOfContactRecords", null);
          var forclose = component.find("lookupContact");
          $A.util.addClass(forclose, "slds-is-close");
          $A.util.removeClass(forclose, "slds-is-open");
          $A.util.addClass(forclose, "slds-hide");
      }
   //EDGE-138687 defect fix : Added signatory check
      if(getInputString != null &&  getInputString.length > 0 && signatory==true){
          component.set("v.searchCustContact", contactName);
          component.set("v.listOfCustContactRecords", null);
          var forclose1 = component.find("cuslookupContact");
          $A.util.addClass(forclose1, "slds-is-close");
          $A.util.removeClass(forclose1, "slds-is-open");
          $A.util.addClass(forclose1, "slds-hide");
      }
  },
  handlePortEvent: function(component, event) {
      var eventParam = event.getParam("portByEvent");
      var portMsisdn = eventParam.Service_Number__c;
      component.set("v.searchPortNum", portMsisdn);
      component.set("v.listOfPortNumbers", null);
      var forclose = component.find("lookupPort");
      $A.util.addClass(forclose, "slds-is-close");
      $A.util.removeClass(forclose, "slds-is-open");
      $A.util.addClass(forclose, "slds-hide");
      // this.handleOnblur(component, event);
  },
  saveDetails:function(component, event) {
      var portNum = component.get("v.searchPortNum");
      var contact = component.get("v.searchCustContact");
      var portcontact = component.get("v.searchContact");
      var accountid = component.get("v.detailWrapper.accountid");
      var qualifiedNumList=component.get("v.dispList");
      var contactList=component.get("v.listOfContact");
      
      var basketid = component.get("v.basketid");
      var flag=false;
      var lst = JSON.stringify(qualifiedNumList);
      for(var i=0;i<contactList.length;i++){
          console.log('portcontact',contactList[i].Contact.Name);
          if(contactList[i].Contact.Name == portcontact || contactList[i].Contact.Name == contact){
              flag=true;
              break;
          }
      }
     
      if(portNum == null || contact == null || portcontact == null){
          this.toastMessage(component, 'Mandatory fields must be completed', "Error", "error");
          
      }  
      else if(flag == false){
          this.toastMessage(component, 'Contact must be fully authorized or legal lessee ', "Error", "error");
          
      }
          else{
            
              flag=false;
              for(var i=0;i<qualifiedNumList.length;i++){
                  if(qualifiedNumList[i].isSelected==true){
                      flag=true;
                      break;
                  }  
              } 
              if (flag == false) {
                  this.toastMessage(component, 'At least one number is required to be selected', "Error", "error");
                  
                  
              }
              else{
                  component.set("v.loadingSpinner", true);
                  var action = component.get("c.saveCAF");
                  action.setParams({
                      basketId:basketid,
                      accountId: accountid,
                      portNumber: portNum,
                      qualifiedNumList:lst,
                      contactName: contact
                  });
                  action.setCallback(this, function(response) {
                      var state = response.getState();
                      console.log("state:", state);
                      if(state === "SUCCESS") {
                          var resp = response.getReturnValue();
                          console.log('resp',resp);
                          if(resp=='Success'){
                              this.updateURL(component,event);
                              this.toastMessage(component,resp,'Success','success');
                              window.location.reload();
                          }
                          else{
                              this.toastMessage(component,resp,'Error','Error'); 
                          }
                          
                      }
                      else if (state==="ERROR") {
                          this.toastMessage(component,resp,'Error','Error'); 
                      }
                      
                  });
                  
                  // enqueue the server side action
                  $A.enqueueAction(action);
              }
          }
  },
  toastMessage:function(component, title, message,type){
      $A.createComponent(
          "c:customToast",
          {
              type: type,
              duration: 45000,
              message: message,
              title: title
          },
          function(customComp, status, error) {
              if (status === "SUCCESS") {
                  var body = component.find("showToastMessage");
                  body.set("v.body", customComp);
              }
          }
      );
  },
  updateURL: function(component, event) {
      var basketId = component.get("v.basketid");
      var action = component.get("c.updateCongaURL");  
      action.setParams({
          "basketId": basketId
      });
      // set call back 
      action.setCallback(this, function(response) {
          var state = response.getState();
          console.log('state',state);
      });
      
      // enqueue the server side action
      $A.enqueueAction(action);
  },
  isActiveCAF: function(component, event) {
      var basketId = component.get("v.basketid");
   	  var action = component.get("c.checkCAF"); 
      
      action.setParams({
          "basketid": basketId
      });
      // set call back 
      action.setCallback(this, function(response) {
          var state = response.getState();
          
          if (state === "SUCCESS") {
              var objrec = response.getReturnValue();
              if(objrec.length != 0){
                  
                  component.set("v.caform", objrec);
                  component.set("v.recordId",objrec[0].Id);
                  component.set("v.isActive",objrec[0].Is_active__c);
              }
              
          }
          else{
              var errorMsg = action.getError()[0].message;
              
          }
      });
      
      // enqueue the server side action
      $A.enqueueAction(action);
  },
  /*---------------------------------------------------------------------------------------
    Name : changeData
    Description : Method to set pagination parameters
    Story: EDGE-88791
     -----------------------------------------------------------------------------------*/
  changeData: function(component, event) {
      component.set("v.CurrentPage", event.getParam("CurrentPage"));
      component.set("v.PageSize", event.getParam("PageSize"));
      component.set("v.TotalPages", event.getParam("TotalPages"));
      this.dispMethod(component);
  },
  /*---------------------------------------------------------------------------------------
    Name : dispMethod
    Description : Method to display data on page
    Story: EDGE-88791
     -----------------------------------------------------------------------------------*/
  dispMethod: function(component, event){
      var tempList = [];
      var pNo = component.get("v.CurrentPage");
      var size = component.get("v.PageSize");
      tempList = component.get("v.dispList");
      component.set("v.portSelectionList", tempList.slice((pNo-1)*size, Math.min(pNo*size, tempList.length))); 
  },
  getContactsForCAFInput: function(component, event) {
      var accountid = component.get("v.detailWrapper.accountid");
      var oppId = component.get("v.detailWrapper.oppId");      
      var getInputString = component.get("v.searchCustContact");
      if (getInputString != null || getInputString != '') {
          if (getInputString.length > 0 || getInputString == "") {
             
              var forOpen = component.find("searchRes2");
              $A.util.addClass(forOpen, "slds-is-open");
              $A.util.removeClass(forOpen, "slds-is-close");
              var forclose2 = component.find("cuslookupContact");
              $A.util.addClass(forclose2, "slds-is-open");
              $A.util.removeClass(forclose2, "slds-hide");
              
              this.searchCAFContact(component, event, getInputString, accountid, oppId);
                
              //helper.searchContact(component,event,getInputString);
          } else {
              var forclose = component.find("searchRes2");
              $A.util.addClass(forclose, "slds-is-close");
              $A.util.removeClass(forclose, "slds-is-open");
              var forclose2 = component.find("cuslookupContact");
              $A.util.addClass(forclose2, "slds-is-close");
              $A.util.removeClass(forclose2, "slds-is-open");
              component.set("v.searchCustContact",null);
          }
      }
  },
  searchCAFContact: function(component, event, getInputString, accountid, oppid) {
      var action = component.get("c.getContactsForSearch");
      action.setParams({
          accountId: accountid,
          oppId: oppid,
          searchText: getInputString
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var data = response.getReturnValue();
              console.log('data',data);
              
              component.set("v.listOfCustContactRecords", data);
          }
      });
      $A.enqueueAction(action);
  },
 })