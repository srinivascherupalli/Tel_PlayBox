({
    
    //EDGE-89299,Method to upload the customer authority form
    MAX_FILE_SIZE: 750000,
    handleUploadFinished : function(component, event) {
        // This will contain the List of File uploaded data and status
        //var uploadedFiles = event.getParam("files");
        
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        
        
    },
    
    //EDGE-89299,Method to handle event
    handleEvent : function(component, event) {
        var name =event.getParam("basketID");// getting the value of event attribute
        var toggleMobile = component.find("parentContainer");
        $A.util.removeClass(toggleMobile,'slds-hide');
        $A.util.addClass(toggleMobile,'slds-show');
        
        component.set("v.basketid",name);
        this.getbasketId(component, event);
        this.fetchQualifiedPortList(component, event);
    },
    
    //EDGE-89299,Method to get basket Name
    getbasketId : function(component, event) {
        var basketId =component.get("v.basketid");
        console.log('basketId:',basketId);
        var action = component.get("c.getBasketId"); 
        
        action.setParams({
            "basketid": basketId
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state:',state);
            if (state === "SUCCESS") {
                var resp  = response.getReturnValue();
                //console.log('resp',resp);
                component.set("v.portBasketid",resp);
                
            }
            else{
                //console.log('error');
                
            } 
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
        
    },
    
    //EDGE-89299,Method to hide warning message when user click "YES" 
    doUpload : function(component, event, helper) {
        
        //Enable the file upload button
        component.set("v.isUpload",false);
        
        var toggleFixed = component.find("ConfirmpopUp");
        $A.util.removeClass(toggleFixed,'slds-show');
        $A.util.addClass(toggleFixed,'slds-hide');
        
    },
    
    //EDGE-89299, Method to close customer authority form popup
    handleClose : function(component) {
        console.log('handle close');
        var toggleMobile = component.find("parentContainer");
        $A.util.addClass(toggleMobile,'slds-hide');
        var compEvent = component.getEvent("sampleComponentEvent"); 
        compEvent.fire();
        /*var toggleFixed = component.find("ConfirmpopUp");
            $A.util.removeClass(toggleFixed,'slds-show');
            $A.util.addClass(toggleFixed,'slds-hide');*/
    },
    
    //EDGE-89299, Method to check associated active CAF with basket
    doInit : function(component,event) {
        //EDGE-117585. Autopopulate today's date
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.toDate', today); 
        var basketId =component.get("v.basketName");
        //console.log('init basketName::',basketId);
        
        var action = component.get("c.checkCAF"); 
        
        action.setParams({
            "basketid": basketId
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state:',state);
            if (state === "SUCCESS") {
                var resp  = response.getReturnValue();
                //console.log('resp',resp);
                component.set("v.isCafActive",resp);
                
            }
            else{
                // console.log('error');
                
            } 
            
            //Defect EDGE-105772,if Active CAF is there ,show warning message
            if(resp)
            {
                // var togglecomp = component.find("parentContainer");
                //$A.util.addClass(togglecomp,'slds-hide');
                var togglecomp1 = component.find("ConfirmpopUp");
                $A.util.removeClass(togglecomp1,'slds-hide');
                $A.util.addClass(togglecomp1,'slds-show');
                component.set("v.isUpload",true);
            }
            else{
                component.set("v.isUpload",false);
                var togglecomp1 = component.find("ConfirmpopUp");
                $A.util.removeClass(togglecomp1,'slds-show');
                $A.util.addClass(togglecomp1,'slds-hide');
            }
            
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
        
    },
    
    //EDGE-89299, Method to save uploaded CAF on CAF object
    doSave : function(component,event) {
        
      
         var qualifiedNumList = component.get("v.portSelectionList");
        var flag=false;
        for(var i=0;i<qualifiedNumList.length;i++){
            if(qualifiedNumList[i].isSelected==true){
                flag=true;
                break;
            }  
        }
        var cafDate =component.get("v.toDate");
        
        var isDateError = component.get("v.dateValidationError");
        var fileName=  component.get("v.fileName");
        
        /*var msisdnSelected= component.get("v.isnumSelected");
        console.log('msisdnSelected',msisdnSelected);*/
        if(cafDate == null)
        {
            
            this.showCustomToast(component, "Please enter the date", "Error", "error");
            
        }
        //EDGE-89299,New AC7 Error message
        else if(fileName == 'No File Selected..'){
            
            this.showCustomToast(component, $A.get("$Label.c.CAFnotUploaded"), "Error", "error");
            
        }
        // EDGE-130044 Throw error message if number not selected
        else if (flag == false) {
            console.log('No num Selected');
        this.showCustomToast(component, $A.get("$Label.c.PortinNumNotSelected"), "Error", "error");

            
        }
        // EDGE-130044 Throw error message if number not selected
            /*else if(msisdnSelected == false){
                this.showCustomToast(component, $A.get("$Label.c.PortinNumNotSelected"), "Error", "error");
                
                
            }*/
        
                else{
                    // EDGE-130044 call method to update SQ record
                    this.saveSQChanges(component,event);
                    component.set("v.loadingSpinner", true);
                    
                    var fileInput = component.find("fileId").get("v.files");
                    // get the first file using array index[0]  
                    var file = fileInput[0];
                    
                    
                    
                    if (file.size > this.MAX_FILE_SIZE) {
                        // alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                        //  'Selected file size: ' + file.size);
                        return;
                    }
                    
                    var fr = new FileReader();
                    
                    var self = this;
                    fr.onload = function() {
                        var fileContents = fr.result;
                        var base64Mark = 'base64,';
                        var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                        
                        fileContents = fileContents.substring(dataStart);
                        
                        self.upload(component, file, fileContents);
                    };
                    
                    fr.readAsDataURL(file);
                }    
    },
    
    //EDGE-89299, Method to get content document link id
    upload: function(component, file, fileContents) {
        var action = component.get("c.createLink"); 
        
        action.setParams({
            basketid: component.get("v.basketName"),
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type,
            cafDate:component.get("v.toDate")
        });
        
        action.setCallback(this, function(a) {
            var attachId = a.getReturnValue();
            //console.log(attachId);
            component.set("v.loadingSpinner", false);
            if(attachId !=null){
                this.showCustomToast(component, $A.get("$Label.c.CAFsaved"), "Success", "success");
                component.set("v.toDate",null);
                component.set("v.fileName",null);
                //EDGE-117585. Redirect to Portin page
                this.handleClose(component);
                
            }
            
        });
        
        
        $A.enqueueAction(action); 
        
    },
    showCustomToast: function (cmp, message, title, type) {
        $A.createComponent(
            "c:customToast", {
                "type": type,
                "message": message,
                "title": title
            },
            function (customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("maincontainer");
                    //console.log(body);
                    body.set("v.body", customComp);
                }
            }
        );
    },
    
    
    handlePPVEvent :  function(component, event) {
    },
    /*------------------------------------------------------
     * EDGE-130044
     * Method:fetchQualifiedPortList
     * Description:Method to get qualified MSISDN
     * Author: Aishwarya
     ------------------------------------------------------*/
    fetchQualifiedPortList: function (component, event) {
        console.log('fetchQualifiedPortList');
        var basketId = component.get("v.basketid");
        console.log('basketId',basketId);
        var action = component.get("c.getQualifiedMsisdn"); 
        action.setParams({
            "basketid": basketId
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp  = response.getReturnValue();
                console.log('resp',resp);
                var qualifiedNumList = response.getReturnValue();
                if(qualifiedNumList==null || qualifiedNumList.length==0){
                    component.set("v.areNumQualified",false);
                }
                else{
                    component.set("v.areNumQualified",true);
                    component.set("v.portSelectionList", qualifiedNumList);
                }
            }
            else{
                
            }  
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    /*------------------------------------------------------
     * EDGE-130044
     * Method:saveSQChanges
     * Description:Method to update SQ records
     * Author: Aishwarya
     ------------------------------------------------------*/
    saveSQChanges : function(component,event) {
        
        var qualifiedNumList = component.get("v.portSelectionList");
        
        console.log('qualifiedNumList',qualifiedNumList);
        var basketId = component.get("v.basketid");
        var lst = JSON.stringify(qualifiedNumList);
        var flag=false;
        for(var i=0;i<qualifiedNumList.length;i++){
            if(qualifiedNumList[i].isSelected==true){
                flag=true;
                break;
            }  
        }
        if(flag==true){
            console.log('In true');
            var action = component.get("c.updateServiceQualification"); 
            action.setParams({
                "basketid": basketId,
                "msisdnList":lst
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                  console.log('State',state);
                if (state === "SUCCESS") {
                    console.log('In state');
                   var resp  = response.getReturnValue();
                    //component.set("v.isnumSelected", true);
                    //this.fetchQualifiedPortList(component,event);
                }
                
            });      // enqueue the server side action  
            $A.enqueueAction(action); 
        }
        
        else{
            component.set("v.loadingSpinner", false);
           // component.set("v.isnumSelected", false);

            
        }
    }
})