({
    /*-------------------------------------------------------- 
EDGE		-144140
Method		-getQualifiedNumbers
Description	-Method to get qualifed Sq using baskeid irrespective of Numbers being in Reservation pool
Author		-Kalashree
--------------------------------------------------------*/
getQualifiedNumbers : function(component,event) {
    console.log('getQualifiedNumbers:');
    var basketid = component.get("v.basket_Id");
    console.log('basketid: ',basketid);
    var action = component.get("c.getAllQualifiedMsisdn");
    action.setParams({
        basketid : basketid
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var resp = response.getReturnValue();
            console.log('resp: ',resp);
            component.set("v.qualifiedNumberList",resp);
            var preselectList = [];
            //new start DIGI 868
            var showPreselect = true;
            for(var i=0; i< resp.length; i++){
                  if (resp[i].isIncluded=='Yes') {
                    showPreselect = false;
                    break;
                 
                } 
                else{
                    showPreselect = true; 
                }
            }
            
           resp.forEach(function(record) {
                if (showPreselect==true) {
                    record.isSelected = true;
                    preselectList.push(record.qualifiedMsisdn);
                } 
            });
            //new end DIGI 868
            /*resp.forEach(function(record) {
                if (record.isSelected) {
                    preselectList.push(record.qualifiedMsisdn);
                 
                } 
            });*/
            console.log('preselectList',preselectList);
            component.set("v.selectedRows",preselectList);
       
           
        }
        else{
            //show error
        }
        
    });
    $A.enqueueAction(action);
},
        /*-------------------------------------------------------- 
EDGE		-144140
Method		-getContactsForCAFInput
Description	-Method to get contacts for customer signatory
Author		-Kalashree
--------------------------------------------------------*/
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
             console.log('test');
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
/*-------------------------------------------------------- 
EDGE		-144140
Method		-searchCAFContact
Description	-Method to search contacts for ppv approver
Author		-Kalashree
--------------------------------------------------------*/
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
            component.set("v.listOfContact", data);//DIGI-23324--obervation Fix
        }
    });
    $A.enqueueAction(action);
},
/*-------------------------------------------------------- 
EDGE		-144140
Method		-getContactsForInput
Description	-Method to search contacts 
Author		-Kalashree
--------------------------------------------------------*/
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
/*-------------------------------------------------------- 
EDGE		-144140
Method		-getContactsForInput
Description	-Method to search contacts for approver
Author		-Kalashree
--------------------------------------------------------*/
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
/*-------------------------------------------------------- 
EDGE		-144140
Method		-getPortNumForInput
Description	-Method to get portin numbers from sq
Author		-Kalashree
--------------------------------------------------------*/
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
            var forclose = component.find("searchRes4");
            $A.util.addClass(forclose, "slds-is-close");
            $A.util.removeClass(forclose, "slds-is-open");
            var forclose2 = component.find("lookupContact");
            $A.util.addClass(forclose2, "slds-is-close");
            $A.util.removeClass(forclose2, "slds-is-open");
        }
    }
},
/*-------------------------------------------------------- 
EDGE		-144140
Method		-searchPort
Description	-Method to get portin numbers from sq
Author		-Kalashree
--------------------------------------------------------*/
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
/*-------------------------------------------------------- 
EDGE		-144140
Method		-handleContactEvent
Author		-Kalashree
--------------------------------------------------------*/
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
        var conactLst = component.get("v.listOfContactRecords");
        component.set("v.listOfContactRecords", null);
        var forclose = component.find("lookupContact");
        $A.util.addClass(forclose, "slds-is-close");
        $A.util.removeClass(forclose, "slds-is-open");
        $A.util.addClass(forclose, "slds-hide");
        
        console.log('conactLst: searchContactid',conactLst);
        for(var i=0;i<conactLst.length;i++){
            if(contactName==conactLst[i].Contact.Name){
                component.set("v.searchContactid", conactLst[i].ContactId);
                console.log('searchContactid: ',component.get("v.searchContactid"));
                break;
            }
        }
        //EDGE-172365:Call method to populate mobile number on selection of Customer PPV approver
        var contactId=component.get("v.searchContactid");
    this.displayMobileNumber(component, event,contactId);
    }
    
    //EDGE-138687 defect fix : Added signatory check
    if(getInputString != null &&  getInputString.length > 0 && signatory==true){
        component.set("v.searchCustContact", contactName);
        var conactLst = component.get("v.listOfCustContactRecords");
        console.log('conactLst: ',conactLst);
        component.set("v.listOfCustContactRecords", null);
        var forclose1 = component.find("cuslookupContact");
        $A.util.addClass(forclose1, "slds-is-close");
        $A.util.removeClass(forclose1, "slds-is-open");
        $A.util.addClass(forclose1, "slds-hide");
        for(var i=0;i<conactLst.length;i++){
            if(contactName==conactLst[i].Contact.Name){
                component.set("v.searchCustContactid", conactLst[i].ContactId);
                console.log('searchCustContactid: ',component.get("v.searchCustContactid"));
                break;
            }
        }
        
    }
},
/*-------------------------------------------------------- 
EDGE		-201557
Method		-handlePPAContactEvent
Author		-Nikhil
--------------------------------------------------------*/
handlePPAContactEvent: function(component, event) {
   
    var eventParam = event.getParam("contactPPAByEventDynamic");
    var contactName = eventParam.Name;   		 
    var signatory =  event.getParam("isPPASignatory");
    var getInputString = component.get("v.searchCustContact");
    var getcontactString = component.get("v.searchContact");
  
    if(getcontactString != null && getcontactString.length > 0 && signatory==false){
        component.set("v.searchContact", contactName);
        var conactLst = component.get("v.listOfContactRecords");
        component.set("v.listOfContactRecords", null);
        var forclose = component.find("lookupContact");
        $A.util.addClass(forclose, "slds-is-close");
        $A.util.removeClass(forclose, "slds-is-open");
        $A.util.addClass(forclose, "slds-hide");
        
        console.log('conactLst: searchContactid',conactLst);
        for(var i=0;i<conactLst.length;i++){
            if(contactName==conactLst[i].Name){
                component.set("v.searchContactid", conactLst[i].Id);
                console.log('searchContactid: ',component.get("v.searchContactid"));
                break;
            }
        }
        var contactId=component.get("v.searchContactid");
    this.displayMobileNumber(component, event,contactId);
    }
    
    if(getInputString != null &&  getInputString.length > 0 && signatory==true){
        component.set("v.searchCustContact", contactName);
        var conactLst = component.get("v.listOfCustContactRecords");
        console.log('conactLst: ',conactLst);
        component.set("v.listOfCustContactRecords", null);
        var forclose1 = component.find("cuslookupContact");
        $A.util.addClass(forclose1, "slds-is-close");
        $A.util.removeClass(forclose1, "slds-is-open");
        $A.util.addClass(forclose1, "slds-hide");
        for(var i=0;i<conactLst.length;i++){
            if(contactName==conactLst[i].Name){
                component.set("v.searchCustContactid", conactLst[i].Id);
                console.log('searchCustContactid: ',component.get("v.searchCustContactid"));
                break;
            }
        }
        
    }
    var searchCustContactid = component.get("v.searchCustContactid");//DIGI-Observation fix PPV status
    this.displayMobileNumber(component, event,searchCustContactid);//DIGI-Observation fix PPV status

},
/*-------------------------------------------------------- 
EDGE		-144140
Method		-handlePortEvent
Author		-Kalashree
--------------------------------------------------------*/
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
/*-------------------------------------------------------- 
EDGE		-144140
Method		-getDetails
Description	-Method to related deatils
Author		-Kalashree
--------------------------------------------------------*/
   getDetails: function(component, event) {
       console.log('getDetails:');
    var basketid = component.get("v.basket_Id");
    var action = component.get("c.getAllDetails");
       
    action.setParams({
        basketid: basketid
    });
    // set call back
    action.setCallback(this, function(response) {
        var state = response.getState();
    	if (state === "SUCCESS") {
            var resp = response.getReturnValue();
            console.log('detail resp',resp);
            console.log(resp);
            component.set("v.detailWrapper", resp);
              //DIGI-778:Handle logic to disable the send SMS and Verfify OTP button
                          console.log(component.get("v.detailWrapper.basketStatus" ));
             if(resp.basketStatus == 'Commercial Configuration' || resp.basketStatus == 'Draft'){
                 component.set("v.isdisableInitiateCA",true);}
            if(resp.caStatus.status=='Pending CA Approval' || resp.caStatus.status=='-'){
                 component.set("v.isVerifyOTPdisable",true);  
          		component.set("v.isDisableInitiatePPV",true);  
            }
            //DIGI-23319:Observation Fix
            if(resp.caStatus.status=='PPV Initiated'){
                component.set("v.isVerifyOTPdisable",true);  
          	    component.set("v.isDisableInitiatePPV",false);  
           }
           //DIGI-23319:Observation Fix
           if(resp.caStatus.status=='Pending OTP Verification'){
            component.set("v.isOTPDisbled",false);  
       }
           component.set("v.loadingSpinner", false);
        } 
    });
    // enqueue the server side action
    $A.enqueueAction(action);
    
},
/*-------------------------------------------------------- 
EDGE		-144140
Method		-saveDetails
Description	-Method to saveDetails in SQ
Author		-Kalashree
--------------------------------------------------------*/
    
    saveDetails:function(component, event) {
      var portNum = component.get("v.searchPortNum");
      
      console.log('portNum==>'+portNum);
      var contact = component.get("v.searchCustContact");
      console.log('contact==>'+contact);
      //var portcontact = component.get("v.searchContact");
      //console.log('portcontact==>'+portcontact);
      var accountid = component.get("v.detailWrapper.accountid");
      var qualifiedNumList=component.get("v.rowsSelected");
      var contactList=component.get("v.listOfContact");
      console.log('contactList**'+contactList);
      var basketid =  component.get("v.basket_Id");
      var signatorycontactid = component.get("v.searchCustContactid");
      var contactid = component.get("v.searchContactid");
      var flag=false;
      var lst = JSON.stringify(qualifiedNumList);
      for(var i=0;i<contactList.length;i++){
          console.log('contact',contact);
          if(contactList[i].Name == contact){
              flag=true;
              break;
          }
      }
     
      if(contact == null || contact == '' || contact == undefined ){
          this.toastMessage(component, $A.get("$Label.c.CAFinitiateCAMessage"), "Error", "error");
          
      }else if(flag == false){
          this.toastMessage(component, $A.get("$Label.c.CAFContactValidation"), "Error", "error");
          
      }
          else{


              //new start DIGI 868
                var preselected
              if(qualifiedNumList.length>0){
                    preselected= qualifiedNumList;
              }
              else{
                   preselected=component.get("v.qualifiedNumberList");
              }
             //new end DIGI 868
           
               console.log('preselected',preselected);
               var preselectList = [];
             
              preselected.forEach(function(record) {
                    if (record.isSelected) {
                        preselectList.push(record);
                       
                    } 
                });
                console.log('preselectList==>'+preselectList);
                console.log('preselectList==>'+preselectList.length);
                console.log('isTrue==>'+component.get("v.isRegenerateCAForm"));
              //EDGE-149259 Added isRegenerateCAForm check
              if (preselectList.length==0 && component.get("v.isRegenerateCAForm")!=true) {
                  this.toastMessage(component, $A.get("$Label.c.CAFSelectNumberValidation"), "Error", "error");
              }
              else{
                  component.set("v.loadingSpinner", true);
                  var inputObject  = {
                      basketId:basketid,
                      accountId: accountid,
                      portNumber: portNum,
                      qualifiedNumList:JSON.stringify(preselectList),
                      contactid: contactid,
                      signatoryContactid : signatorycontactid
                  };
                  console.log('inputObject: ',inputObject);
                  if(component.get("v.isRegenerateCAForm")!=true){
                  var action = component.get("c.saveCAF");
                  }
                  else{
                      var action=component.get("c.saveRengeneratedCAF");
                  }
                  action.setParams({
                      inputString : JSON.stringify(inputObject),
                      regenerateCA:component.get("v.isRegenerateCAForm"),
                      basketid : basketid //DIGI-864
                  });
                  action.setCallback(this, function(response) {
                      var state = response.getState();
                      console.log("state:", state);
                      if(state === "SUCCESS") {
                          var resp = response.getReturnValue();
                          console.log('resp',resp);
                          if(resp=='Success'){
                              this.updateURL(component,event);
                              component.set("v.searchPortNum",null);
                              component.set("v.searchCustContact",null);
                              component.set("v.searchContact",null);
                              this.getDetails(component,event);
                              this.getQualifiedNumbers(component,event);//new
                              this.toastMessage(component,$A.get("$Label.c.CAFsaved"),'Success','success');    
                          }
                          else{
                                                component.set("v.loadingSpinner", false);

                          this.toastMessage(component,resp,'Error','Error'); 
                      }   
                  }
                  else if (state==="ERROR") {
                                        component.set("v.loadingSpinner", false);

                      this.toastMessage(component,resp,'Error','Error'); 
                  }
                  
              });
              
              // enqueue the server side action
              $A.enqueueAction(action);
          }
      }
},

 /*-------------------------------------------------------- 
EDGE		-149395
Method		-resendPPV
Description	-Method to saveDetails in SQ
Author		-Kalashree
--------------------------------------------------------*/
resendPPV:function(component, event) {
    var portNum = component.get("v.searchPortNum");
    var contact = component.get("v.searchCustContact");
    var portcontact = component.get("v.searchContact");
    var accountid = component.get("v.detailWrapper.accountid");
    var contactList=component.get("v.listOfContact");
    var basketid =  component.get("v.basket_Id");
    var contactid = component.get("v.searchCustContactid");
    var flag=false;

    for(var i=0;i<contactList.length;i++){
        console.log('portcontact',contactList[i].Contact.Name);
        if(contactList[i].Contact.Name == portcontact && contactList[i].Contact.Name == contact){
            flag=true;
            break;
        }
    }
    //EDGE-154648. Kalashree Borgaonkar. Contact validation fix
    if(flag==false){
         this.toastMessage(component, $A.get("$Label.c.CAFContactValidation"), "Error", "error");  
        return;
    }
    if(portNum == null || contact == null 
     || portcontact == null || portNum == '' 
     || contact == '' || portcontact == '' 
     || portNum == undefined || contact == undefined || portcontact == undefined){
        this.toastMessage(component, $A.get("$Label.c.CAFmandatoryFieldsMessage"), "Error", "error");  
    }  
    else{
        component.set("v.loadingSpinner", true);
        var inputObject  = {
                    basketid:basketid,
                    contactid: contactid,
                    msisdn: portNum
                };
        console.log('JSON.stringify(inputObject): ',JSON.stringify(inputObject));
        var action = component.get("c.reInitiatePPV");
        action.setParams({
            inputString :JSON.stringify(inputObject)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:", state);
            if(state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('resp',resp); 
                this.getDetails(component,event);
                if($A.get("$Label.c.CAFAddedNum")==resp){
                    this.toastMessage(component,resp,'Error','error');
                }
                else{
                    this.toastMessage(component,resp,'Success','success');
                    component.set("v.searchPortNum",null);
                    component.set("v.searchCustContact",null);
                    component.set("v.searchContact",null);
                }
                component.set("v.loadingSpinner", false); 
            }
            else if (state==="ERROR") {
                component.set("v.loadingSpinner", false);  
            }  
        });
        // enqueue the server side action
        $A.enqueueAction(action);
    }
},
    /*-------------------------------------------------------- 
EDGE		-144140
Method		-handleSelectedrecords
Description	-Handle rows selected
Author		-Kalashree
--------------------------------------------------------*/
    handleSelectedrecords: function(component, event){
        
    	var selrecords = event.getParam("selectedrecords");
        //new
        selrecords.forEach(function(record) {
            record.isSelected=true;
        });
        component.set("v.rowsSelected",selrecords);
        console.log('selrecords: ',selrecords);
         console.log('selrecords: ',component.get("v.rowsSelected"));
	},
/*-------------------------------------------------------- 
EDGE		-144140
Method		-toastMessage
Description	-show toast Message
Author		-Kalashree
--------------------------------------------------------*/
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
/*-------------------------------------------------------- 
EDGE		-144140
Method		-toastMessage
Description	-show CAF url
Author		-Kalashree
--------------------------------------------------------*/
  updateURL: function(component, event) {
  var basketId = component.get("v.basket_Id");
      console.log("basketId::updateURL ",basketId);
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
//EDGE-154222 Defect fix
handleOnchange : function(component, event){
    var searchCustContact = component.find('searchContact1').get("v.value");
    var searchContact = component.find('searchContact').get("v.value");
    //var searchPortNum = component.find('searchPortNum').get("v.value"); 
    component.set("v.searchCustContact",searchCustContact);
    component.set("v.searchContact",searchContact);

    var cafid = component.get("v.detailWrapper.caStatus.cafRecordId");
    console.log('cafid'+cafid);
    
    //component.set("v.searchPortNum",searchPortNum);
    ////EDGE-172365 :Delete mobile number on deletion of contact
    if( searchContact.length==0){
        component.set("v.searchPortNum",null)
    }
    if((searchContact!=null || searchContact != undefined) && searchContact.length==0){
         var forclose = component.find("searchRes3");
            $A.util.addClass(forclose, "slds-is-close");
            $A.util.removeClass(forclose, "slds-is-open");
            var forclose2 = component.find("lookupContact");
            $A.util.addClass(forclose2, "slds-is-close");
            $A.util.removeClass(forclose2, "slds-is-open");
    }
     if( (searchCustContact!=null || searchCustContact != undefined) && searchCustContact.length==0 ){
         var forclose = component.find("searchRes2");
            $A.util.addClass(forclose, "slds-is-close");
            $A.util.removeClass(forclose, "slds-is-open");
            var forclose2 = component.find("cuslookupContact");
            $A.util.addClass(forclose2, "slds-is-close");
            $A.util.removeClass(forclose2, "slds-is-open");
    }
    //Commenting as part of EDGE-172365
   /* if((searchPortNum!=null || searchPortNum != undefined) && searchPortNum.length==0 ){
         var forclose = component.find("searchRes4");
            $A.util.addClass(forclose, "slds-is-close");
            $A.util.removeClass(forclose, "slds-is-open");
            var forclose2 = component.find("lookupPort");
            $A.util.addClass(forclose2, "slds-is-close");
            $A.util.removeClass(forclose2, "slds-is-open");
    }*/
},
 /*-------------------------------------------------------- 
EDGE		-172365
Method		-displayMobileNumber
Description	-Populate mobile number of selected Customer PPV approver contact
Author		-Aishwarya
--------------------------------------------------------*/
   displayMobileNumber : function(component,event,contactId) {
	  	var action = component.get("c.fetchMobileNumber");
        // set param to method 
        action.setParams({
          	'contactId' : contactId
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mobileNumber = response.getReturnValue();
                console.log('mobileNumber',mobileNumber);
                if (mobileNumber == null) {
                    this.toastMessage(component,'Error',$A.get("$Label.c.MobileNumberRequired"),'error');  
                } else {
                    component.set("v.searchPortNum",mobileNumber);
                }
            }
            
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},

    //DIGI-779:Handle logic for the send SMS button
    
    SendSMSButton : function(component,event) {
        console.log('inside method...');
        var portcontact = component.get("v.searchContact");
        console.log('portcontact'+portcontact);
        var basketid = component.get("v.basket_Id");
        console.log('basketId'+basketid);
        var contactNumber = component.get("v.searchPortNum");
        console.log('contactNumber'+contactNumber);
        
        //DIGI-781---moved validation from Initiate CA to send SMS Button
    
        if(contactNumber == null || portcontact == null || contactNumber == '' 
         || portcontact == '' || contactNumber == undefined || portcontact == undefined){
            this.toastMessage(component, $A.get("$Label.c.CAFsendSMS"), "Error", "error"); 
        }
        else{
            
            component.set("v.loadingSpinner", true);
            var action = component.get("c.sendSMS");
        
        // set param to method 
        action.setParams({
            conNumber : contactNumber,
          	basketId : basketid
          });

          action.setCallback(this, function(response) {
            var state = response.getState();
            var ret = response.getReturnValue();
            console.log('ret1sms****'+ret);
            
            
            console.log('ret2sms****'+ret);
            var valsendmsg = 'Unable to send SMS';
            //console.log('ret1messagesms****++++'+ret1[0].message);
            if (state === "SUCCESS") {
                if(ret!='Success'){
                    var ret1 = JSON.parse(ret);
                    if(ret1[0].message.includes(valsendmsg)){
                    component.set("v.isOTPDisbled",true);
                    component.set("v.isVerifyOTPdisable",true);//DIGI-23319:Observation Fix
                    this.toastMessage(component,'Error',ret1[0].message,'Error');
                    component.set("v.loadingSpinner", false);
                }
            }
                     
                else{

                    var count = component.get('v.sendsmsclickcount');
            
                    count = count+1;
                    component.set('v.sendsmsclickcount', count);

                    
                       
                        component.set("v.isOTPDisbled",false);
                        component.set("v.isVerifyOTPdisable",false);//DIGI-23319:Observation Fix
                        if(count>1){
                            this.toastMessage(component,'Success','OTP has been sent again to the selected Authorised Representative','Success'); 
                        }else{
                            this.toastMessage(component,'Success',$A.get("$Label.c.CAFsendSMSSuccess"),'Success');
                        }
                        
                        console.log('state...'+state);
                        this.getDetails(component,event);
                        component.set("v.loadingSpinner", false);
                   }
            }
            else{
                this.toastMessage(component,'Error','Unexpected Error Occured','error');
                component.set("v.loadingSpinner", false); 
            }
            console.log('test callback')
          });
          // enqueue the Action  
        $A.enqueueAction(action);
        }
        },
        //DIGI-779:Handle logic for the verify OTP button
    
        VerifyOTPButton : function(component,event) {
            var m = new Date();
            var dateString = m.getUTCDate() +"-"+ (m.getUTCMonth()+1) +"-"+ m.getUTCFullYear() + "_" + m.getUTCHours() + "-" + m.getUTCMinutes() + "_PPV_check";
            component.set("v.csvFileTitle",dateString);
            console.log('dateString****'+dateString);
            console.log('inside verifyotp method...');
            var portcontact = component.get("v.searchContact");
            console.log('portcontact'+portcontact);
            var basketid = component.get("v.basket_Id");
            console.log('basketId'+basketid);
            var opportunityid = component.get("v.opp_Id");
            console.log('opportunityid'+opportunityid);
            var portnumList = component.get("v.qualifiedNumberList");
            console.log('portnumList'+JSON.stringify(portnumList));
            var contactNumber = component.get("v.searchPortNum");
            console.log('contactNumber'+contactNumber);
            var otpNum = component.get("v.OTPNumber");
            console.log('otpNum'+otpNum);

            if(contactNumber == null || portcontact == null || otpNum == null|| contactNumber == '' 
            || portcontact == '' || otpNum == '' || contactNumber == undefined || portcontact == undefined || otpNum == undefined ){
               this.toastMessage(component, $A.get("$Label.c.CAFverifyOTP"), "Error", "error");  
           }else{
            var count = component.get('v.noOfAttempts');
           if(count>=3){
                this.toastMessage(component,'Error','OTP Verification limit exceeded. Please contact our Customer Care.','error');
            }else{

            var action = component.get("c.verifyOTP");
            component.set("v.loadingSpinner", true);
            // set param to method 
            action.setParams({
                conNumber : contactNumber,
                basketId : basketid,
                otpInput : otpNum,
                oppId : opportunityid
                //,numPort : portnumList

            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state...1'+state);
                var ret = response.getReturnValue();
               
                console.log('ret1****'+ret1);
                var valmsg = 'Verification failed';
                var valmsg1 = 'Mandatory attribute';//DIGI-23319:Observation Fix
                if (state === "SUCCESS") {
                    if(ret!='Success'){
                        
                    //DIGI-25279:Observation Fix--Start
                    count = count+1;
                    if(count<=3){
                        component.set('v.noOfAttempts', count);
                        component.set("v.isOTPDisbled",true);
                    }

                    //DIGI-25279:Observation Fix--End
            
                        var ret1 = JSON.parse(ret);
                        if(ret1[0].message.includes(valmsg)){
                        component.set("v.isOTPDisbled",false);
                        this.toastMessage(component,'Error',ret1[0].message,'Error');
                        this.getDetails(component,event);
                        this.getQualifiedNumbers(component,event);
                        component.set("v.loadingSpinner", false);
                    }
                    //DIGI-23319:Observation Fix
                    else if(ret1[0].message.includes(valmsg1)){
                        component.set("v.isOTPDisbled",false);
                        this.toastMessage(component,'Error','Please Enter 6 digit OTP received from customer care.','Error');
                        this.getDetails(component,event);
                        this.getQualifiedNumbers(component,event);
                        component.set("v.loadingSpinner", false);
                    }
                }else{
                    component.set("v.isOTPDisbled",false);
                    this.toastMessage(component,'Success','OTP Verified Successfully.','Success'); 
                    console.log('state...success'+state);
                    component.set("v.isModalOpen", true);
                    this.getDetails(component,event);
                    this.getQualifiedNumbers(component,event);
                    component.set("v.loadingSpinner", false);
                   }
                    
                    
                    
                }
                else{
                    this.toastMessage(component,'Error','Unexpected Error Occured','error');  
                    component.set("v.loadingSpinner", false);
                }
                console.log('test callback')
            });
            
            $A.enqueueAction(action);
        }

           }
            
    
    },

     //DIGI-779:Handle logic to disable the Verfify OTP button
    /* VerifyOTPButtonLogic : function(component,event) {
        if(params)
        {
            if(params.isCafActive || component.get("v.isCAExpired") || component.get("v.isRegenerateCAForm") ){
            component.set("v.isVerifyOTPdisable",true);  
            }
        }
          //this.getDetails(component,event);
     }*/
})