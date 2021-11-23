//EDGE-140792,EDGE-138086
({
    getSearchInitialdata: function(component, event, helper) {
        console.log('Inside getSearchInitialdata');
        component.set("v.selectedradio", 'New');
        var tabType = component.get("v.selectedTab");
        var action = component.get("c.SearchInitialdata");
        action.setParams({
            "tabType": tabType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                if(component.set("v.numberReserve") == undefined || component.set("v.numberReserve") == null)
                    component.set("v.numberReserve",data);
            }
        });
        $A.enqueueAction(action);
    },
    handlesearchSection : function(component, event, helper) {
        var selectedsearchoption = event.getParam("selectedsearchoption");
        console.log("selectedsearchoption>>>>" + selectedsearchoption);
        if(selectedsearchoption=='addnewnumber'){
            component.set("v.isShowSearch",true);
            component.set("v.isShowPortin",false);
            component.set("v.isShowTransition",false);
            component.set("v.isShowManage",false);
            component.set("v.showSearchTab",true); 
            component.set("v.isShowPortOutReversal",false);
            component.set("v.isShowReactiveServices",false);
            component.set("v.selectedradio", 'New');
        }
        else if(selectedsearchoption=='portin'){
            component.set("v.isShowPortin",true);
            component.set("v.isShowTransition",false);
            component.set("v.isShowManage",false);
            component.set("v.isShowSearch",false);
            component.set("v.isShowPortOutReversal",false);
            component.set("v.isShowReactiveServices",false);
            component.set("v.showSearchTab",false);//EDGE-144140. Kalashree.Do not Render search tab
            component.set("v.selectedradio", 'Port In');
        }
            else if(selectedsearchoption=='transitionnumber'){
                component.set("v.isShowPortin",false);
                component.set("v.isShowTransition",true);
                component.set("v.isShowManage",false);
                component.set("v.isShowSearch",false);
                component.set("v.showSearchTab",false);
                component.set("v.isShowPortOutReversal",false);
                component.set("v.isShowReactiveServices",false);
                component.set("v.selectedradio", 'Transition');
            }
        //EDGE-165481,171843. Kalashree Borgaonkar.
                else if(selectedsearchoption=='portOutReversal'){
                    component.set("v.isShowPortin",false);
                    component.set("v.isShowPortOutReversal",true);
                    component.set("v.isShowTransition",false);
                    component.set("v.isShowManage",false);
                    component.set("v.isShowSearch",false);
                    component.set("v.showSearchTab",false);
                    component.set("v.isShowReactiveServices",false);
                    component.set("v.selectedradio", 'portOutReversal');
                }
        //EDGE-185029. Kalashree Borgaonkar.
                    else if(selectedsearchoption=='reactiveServices'){
                        component.set("v.isShowPortin",false);
                        component.set("v.isShowPortOutReversal",false);
                        component.set("v.isShowReactiveServices",true);
                        component.set("v.isShowTransition",false);
                        component.set("v.isShowManage",false);
                        component.set("v.isShowSearch",false);
                        component.set("v.showSearchTab",false);
                        component.set("v.selectedradio", 'reactiveServices');
                    }
                        else if(selectedsearchoption=='managenumber'){
                            component.set("v.isShowPortin",false);
                            component.set("v.isShowTransition",false);
                            component.set("v.isShowManage",true);
                            component.set("v.isShowSearch",false);
                            component.set("v.showSearchTab",true);
                            component.set("v.selectedradio", 'Manage Number');
                        }
       helper.handlerefreshdataview(component, event, helper);
    },
    //EDGE-140792,EDGE-138086
    addAddress:function(component, event,helper){
        var action=component.get("c.checkForPartnerUser");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var IsPartner=response.getReturnValue();
                console.log('IsPartner=='+IsPartner);
                if(IsPartner) {
                    window.open("/partners/s/communityaddresssearch");
                }
                else{
                    window.open("/lightning/n/Address_Search_New");
                }
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE-140792,EDGE-138086
    handleSearchNumbers: function(component, event,helper) {
        var selectedTab =component.get("v.selectedTab");
        //Added as a part of production incident INC000093614716 - Timer Reset on 2nd search
        component.set("v.searchResult",[]); 
        component.set("v.loadingSpinner", true);
        
        var searchdata = event.getParam("searchresult");
        var searchType = event.getParam("searchType");
        //var searchdata = component.get("v.numberReserve");
        //var pat = new RegExp('(^[0-9]+[0-9]+[%])|(^[0-9]+[0-9]+[*]|^[0-9]+[0-9])');
        var regex = /^\d[0-9]+[%*]?$/;
        var pat = new RegExp(regex);
        var reqQuan = searchdata.quantity;
        var reqNumPattern = searchdata.reqPattern;
        console.log(JSON.stringify(searchdata));
        var reqSearchType = searchdata.selectedSearchType;
        var patternType = searchdata.selectedPatternType;
        //EDGE-151611. Kalashree Borgaonkar. Validations for quantity in 'Fixed' number search.
        //DIGI-23871 reserve limit increase to 1000
        var errorMsg = $A.get("$Label.c.Reserve_number_quantity_validation");
        if(selectedTab=='Fixed' && reqSearchType=='Contiguous' && reqQuan>1000){
            this.showCustomToast(
                component,
                errorMsg.replace("<limit>","1000"),
                "",
                "error"
            );
            component.set("v.loadingSpinner", false);
            return;
        }
        else if(selectedTab=='Fixed' && reqSearchType=='Non-Contiguous' && reqQuan>20){
            this.showCustomToast(
                component,
                errorMsg.replace("<limit>","20"),
                "",
                "error"
            );
            component.set("v.loadingSpinner", false);
            return;
        }
        
        if (reqQuan == null || reqQuan == "") {
            component.set("v.loadingSpinner", false);
            this.showCustomToast(
                component,
                $A.get("$Label.c.Reserve_number_quantity_required"),
                "",
                "error"
            );
            return;
        }
        
        else if(reqSearchType=='Contiguous' && (reqQuan % 100) != 0){
            component.set("v.loadingSpinner", false);//EDGE-145555
            this.showCustomToast(component, $A.get("$Label.c.ContiguousQuantityValidation"), "", "error");  
            return;
        } else if (reqQuan > 1000) {
            component.set("v.loadingSpinner", false);
            this.showCustomToast(
                component,
                $A.get("$Label.c.MaxQuantityRequired"),//EDGE-145555
                "",
                "error"
            );
            return;
        }        
            else if (reqQuan <= 0 || reqQuan > 1000 || reqQuan == 0) {
                component.set("v.loadingSpinner", false);
                this.showCustomToast(
                    component,
                    $A.get("$Label.c.Reserve_number_quantity_validation"),
                    "",
                    "error"
                );
                return;
            }
                else if (
                    patternType != "None" && patternType != '' &&
                    (reqNumPattern == null )
                ) {
                    this.showCustomToast(
                        component,
                        "Pattern to be mentioned on Pattern Field",
                        "",
                        "error"
                    );
                    component.set("v.loadingSpinner", false);            
                    return;
                }
        var action = component.get("c.searchNumbers");
        if(searchdata.reqPattern == undefined || searchdata.reqPattern == "")
            searchdata["reqPattern"] = null;   
        console.log(JSON.stringify(searchdata));
        action.setParams({
            searchString: JSON.stringify(searchdata),
            tabType: component.get("v.selectedTab")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loadingSpinner", false);
                var response = response.getReturnValue();
                console.log(response);
                component.set("v.searchmsg",response.responsemessage);
                console.log("response.responsemessage: ",response.responsemessage);
                if(response.lstsearchresult.length > 0){
                    component.set("v.searchResult",response.lstsearchresult);
                    
                    // this.startTimer(component, event,helper);
                    this.showCustomToast(
                        component,
                        response.responsemessage,
                        "",
                        "success"
                    );
                }else{
                    this.showCustomToast(
                        component,
                        response.responsemessage,
                        "",
                        "error"
                    );
                    return;
                }
                
            }else{
                this.showCustomToast(
                    component,
                    response.responsemessage,
                    "",
                    "error"
                );
                return;
            }
        });
        $A.enqueueAction(action);
    },
    /*------------------------------------------------------
    EDGE-93081 
    Description: LRM AutoReserve MSISDN Numbers called from component
    ------------------------------------------------------*/
    //Auto Reserve Numbers for LRM
    handleAutoReserve: function(component, event, helper) {
        //var searchdata = component.get("v.numberReserve");
        var searchdata = event.getParam("searchresult");
        var reqQuan = searchdata.autoReserverQuantity;
        var recordId = component.get("v.basket_id");
        console.log('recordId',recordId);
        //var selectedTabId = component.get("v.selectedTabId");
        if (reqQuan == null || reqQuan == "") {
            this.showCustomToast(
                component,
                $A.get("$Label.c.Reserve_number_quantity_required"),
                "",
                "error"
            );
            return;
        } else if (reqQuan <= 0 || reqQuan > 1000 || reqQuan == 0) {
            this.showCustomToast(
                component,
                $A.get("$Label.c.Reserve_number_quantity_validation"),
                "",
                "error"
            );
            return;
        } else {
            component.set("v.loadingSpinner", true);
            var action = component.get("c.autoReserveMSISDN");
            action.setParams({
                searchQuan: reqQuan,
                basketId: recordId   
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loadingSpinner", false);
                    var resp = response.getReturnValue();
                    if(resp == 'Success'){
                        helper.getreserverecords(component, event,helper);
                        component.set("v.loadingSpinner", false);
                        component.set("v.numberReserve.autoReserverQuantity", ""); 
                        var searchType="Auto Reserve";
                        var eventType="Number reservation completed";
                        helper.logTransaction(component, event,helper,searchType,eventType,reqQuan);//DIGI-3161 added by shubhi
                        this.showCustomToast(
                            component,
                            "Number(s) reserved successfully",
                            "",
                            "Success"
                        );
                    }else{
                        component.set("v.loadingSpinner", false);
                        this.showCustomToast(
                            component,
                            resp,
                            "",
                            "error"
                        );
                        return;
                    }
                    
                } else {
                    component.set("v.loadingSpinner", false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    //EDGE-140792,EDGE-138086
    getreserverecords:function(component, event,helper){
        var recordId = component.get("v.basket_id");
        var numbertype = component.get("v.selectedradio");
        if(component.get("v.selectedTab") == 'Fixed' && numbertype == 'New'){
            numbertype = 'FNN';
        }
        console.log('numbertype>>>'+numbertype + '>>>>>' + component.get("v.selectedTab"));
        component.set("v.loadingSpinner", true);
        var action = component.get("c.getreserveNumbers");
        action.setParams({
            basketId: recordId,
            numberType:numbertype             
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.reservedata", []);
                var resp = response.getReturnValue();
                console.log('Reserve Numbers');
                console.log(resp);
                component.set("v.reservedata", resp);
                component.set("v.loadingSpinner", false);      
                /*if(component.get("v.spinnerforassignnum") == false){
            component.set("v.loadingSpinner", false);
			}*/          
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },//EDGE-140792,EDGE-138086
    showCustomToast: function(cmp, message, title, type) {
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                message: message,
                title: title
            },
            function(customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");                    
                    body.set("v.body", customComp);
                }
            }
        );
    },//EDGE-140792,EDGE-138086
    fixedPortInScreen:function(component,event){
        var url= '';
        var redirectURI = '/apex/';
        url = window.location.href;
        var communitySiteId= false
        if (url.includes('partners.enterprise.telstra.com.au')){
            redirectURI = '/s/sfdcpage/%2Fapex';
            communitySiteId = true;
        }    
        else if(url.includes('partners')){
            communitySiteId = true;
            redirectURI = '/partners/s/sfdcpage/%2Fapex';
        }else{
            
        }
        console.log('redirectURI>>>'+redirectURI);
        url = redirectURI;
        console.log('redirectURI>>>'+redirectURI);
        if(communitySiteId){
            url = url + encodeURIComponent('/FixedPortIn?BasketId='+component.get("v.basket_id")+'&NumberType='+component.get("v.selectedTab"));
        }else{
            url = '/apex/FixedPortIn?BasketId='+component.get("v.basket_id")+'&NumberType='+component.get("v.selectedTab")
        }
        window.open(url); 
        //return Promise.resolve(url);
    },//EDGE-140792,EDGE-138086
    handleSelectedrecords : function(component, event, helper){
        console.log('Inside handleSelectedrecords');
        var tableName = event.getParam("tableName");
        var selrecords = event.getParam("selectedrecords");
        if(tableName == 'reservationpooltable'){
            //component.set("v.reserveselectedRows",selrecords);
        }
        if(tableName == 'searchresulttable'){
            component.set("v.reserveselectedRows",selrecords);
        }
    },//EDGE-140792,EDGE-138086
    removeAssignedPCNumbers: function(component, event, helper){
        console.log('Inside removeAssignedPCNumbers');
        var selrecords = event.getParam("selectedrecords");
        console.log(selrecords);
        component.set("v.loadingSpinner", true);
        var action2 = component.get("c.removeAssignedNumbers");
        
        action2.setParams({
            "selectedPCList": selrecords,
            "basketID": component.get("v.basket_id"),
            "selectedTab": component.get("v.selectedTab")
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loadingSpinner", false);
                var resp = response.getReturnValue();
                console.log(resp);
                this.showCustomToast(
                    component,
                    "Number unassigned successfully",
                    "",
                    "Success"
                );
                helper.handlerefreshdataview(component, event, helper);
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action2);
    },//EDGE-140792,EDGE-138086
    removeNumberFromPools : function(component, event, helper){
        var selrecords = event.getParam("selectedrecords");
        if(selrecords!= undefined && selrecords.length == 0){
            this.showCustomToast(
                component,
                'Please select at least one number to remove.',
                "",
                "error"
            );
            return;
        }
        component.set("v.loadingSpinner", true);
        var action2 = component.get("c.removeNumbersFromPool");
        action2.setParams({
            "numberList": selrecords,
            "basketId": component.get("v.basket_id"),
            "selectedTab": component.get("v.selectedTab")
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state removeNumberFromPools',state);
            if (state === "SUCCESS") {
                component.set("v.loadingSpinner", false);
                var resp = response.getReturnValue();
                console.log('**Resp***',resp);
                
                if(resp.status){//EDGE-145555
                    this.showCustomToast(
                        component,
                        "Number removed Successfully.",
                        "",
                        "Success");
                }else{
                    if(resp.errList!= undefined && resp.errList.length > 0){
                        this.showCustomToast(
                            component,
                            resp.errList[0].message, //EDGE-129218
                            "",
                            "error");
                    }
                }
                helper.handlerefreshdataview(component, event, helper);
            }  else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action2);
    },//EDGE-140792,EDGE-138086
    fetchAllProductConfig : function(component, event, helper){
        console.log('Inside fetchAllProductConfig');
        component.set("v.loadingSpinner", true);
        var selrecords = event.getParam("selectedrecords");
        var action = component.get("c.getAllProductConfig");
        console.log("selectedTab==P"+component.get("v.selectedTab"));
        console.log("selectedradio==P"+component.get("v.selectedradio"));
        action.setParams({
            "basketId": component.get("v.basket_id"),
            "selectedTab": component.get("v.selectedTab"),
            "selectedRadioOption": component.get("v.selectedradio") //EDGE-185029 Adding paramter for selected radio button
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state>>>>>'+state);
            if (state === "SUCCESS") {
                component.set("v.objproductconfig",[]);
                var resp = response.getReturnValue();
                console.log('length=='+resp.length);
                  // EDGE-203933. Kalashree Borgaonkar. Sort for Tranisiton/migration. Start
                var selectedRadio =component.get("v.selectedradio");
                if(selectedRadio=='Transition' || selectedRadio=='Migration'){
                    this.sortData(component,resp,'assignedNumber','dsc');
                }
                else{
                   component.set("v.objproductconfig",resp);  
                }
                  // EDGE-203933. Kalashree Borgaonkar. Sort for Tranisiton/migration. End
                console.log('prod config resp',JSON.stringify(resp));
                if(resp != undefined && resp.length > 0){
                    for(var i=0; i< resp.length; i++){
                        console.log('resp=='+resp[i].isngEMPresent);
                        if(resp[i].isngEMPresent){
                            component.set("v.isngEMPresent",true);
                        }
                    }                    
                }
                if(resp.length ==0 && component.get("v.selectedTab") == 'Fixed'){
                    this.showCustomToast(
                        component,
                        'No Products available for Fixed number reservation.',
                        "",
                        "info"
                    );
                }
                console.log("resp.length: ",resp.length);
                //console.log("resp.length: ",resp[0].isReactivateService);
                if((resp.length ==0 && component.get("v.selectedTab") == 'Mobile' && component.get("v.isReactiveServices")==false) ){
                    this.showCustomToast(
                        component,
                        $A.get("$Label.c.No_Product_For_Mobile"),
                        "",
                        "info"
                    );
                }
                
            } else {
                this.showCustomToast(
                    component,
                    "There is some issue in server side.",
                    "",
                    "error"
                );
            }
            component.set("v.loadingSpinner", false); 
            
            
        });
        $A.enqueueAction(action);
    },
    //EDGE-140792,EDGE-138086
    assignSelectedNumbers : function(component, event, helper){
        component.set("v.showErrorForTransition",false);
        var selectedreservationrec = event.getParam("selectedreservationrec");
        var selectedProductconfig = event.getParam("selectedProductconfig");
        var selectedSimTypeValue = event.getParam("selectedSimTypeValue");
        // var selectedrow = event.getParam("selectedrows"); //poc
        console.log('selectedreservationrec',selectedreservationrec);
        console.log('selectedProductconfig',selectedProductconfig);
        console.log('selectedSimTypeValue>>>',selectedSimTypeValue);
        console.log('selectedTab>>>>>'+component.get("v.selectedTab"));
        //console.log('assign number selected row = '+JSON.stringify(selectedrow));
        //component.set("v.loadingSpinner", true);
        //poc
        
        //  var callVFmethod =component.get("v.Value");
        //callVFmethod(selectedreservationrec,selectedProductconfig,selectedSimTypeValue,event.getParam("newWxistingSIM"), function(answer){
        //	alert(answer); 
        //  });
        //poc
        var action = component.get("c.assignNumbers");
        var selectedOption;
        if(component.get('v.isShowTransition') === true){
            selectedOption = 'Transition';
        }else{
            selectedOption = 'Others';
        }
        console.log('selectedSimTypeValue>>>>'+selectedSimTypeValue);
        console.log('selectedTab>>>>'+component.get("v.selectedTab"));
        console.log('newWxistingSIM>>>>'+event.getParam("newWxistingSIM"));
        console.log('selectedOption>>>>'+selectedOption);
        console.log(selectedProductconfig);
        console.log(+selectedreservationrec);
        action.setParams({
            "selectedPcWrapper": selectedProductconfig,
            "selectedNumbers": selectedreservationrec,
            "selectedTab": component.get("v.selectedTab"),
            "basketid": component.get("v.basket_id"),
            "selectedSimTypeValue":selectedSimTypeValue,
            "newWxistingSIM":event.getParam("newWxistingSIM"),
            "selectedOption":selectedOption       
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // component.set("v.loadingSpinner", false); for poc
                var resp = response.getReturnValue();
                helper.handlerefreshdataview(component, event, helper);
                if(resp==='Success'){
                    this.showCustomToast(
                        component,
                        "Number assigned successfully",
                        "",
                        "success"
                    );
                }
                if(resp==='Error'){
                    this.showCustomToast(
                        component,
                        "Number not assigned successfully",
                        "",
                        "Error"
                    );
                }
                if(resp.Status === 'Success'){
                this.showCustomToast(
                    component,
                    "Number assigned successfully",
                    "",
                    "success"
                );
                }
                if(resp.Status === 'Error'){
                    this.showCustomToast(
                        component,
                        "All Legacy Numbers were not mapped to digital services successfully",
                        "",
                        "Error"
                    );
                    //alert('Unassigned number '+resp.unassignedCount+' assigned number '+resp.assignedCount);
                    component.set("v.unassignedCountForTransition",resp.unassignedCount);
                    component.set("v.assignedCountForTransition",resp.assignedCount);
                    component.set("v.showErrorForTransition",true);
                }
               //alert('Spinner value  '+component.get("v.spinnerforassignnum"));                //component.set("v.loadingSpinner", true); //poc
                //poc calling vf method to update schema attribute
                console.log('calling vf method');
                component.set("v.callVF",true);
                //var callVFmethod =component.get("v.Value");
                //callVFmethod(component.get("v.objproductconfig"), function(){
                //handle callback            			
                //   });
                //poc
            } else {
                this.showCustomToast(
                    component,
                    "There is some issue in server side.",
                    "",
                    "error"
                );
            }
        });
        $A.enqueueAction(action);
    },//EDGE-140792,EDGE-138086
    handleresetNumbermgmt: function(component,event,helper){
        console.log('Inside handleresetNumbermgmt');
        component.set("v.searchResult",null);
    },//EDGE-140792,EDGE-138086
    handlerefreshdataview:function(component,event,helper){
       if(component.get("v.selectedradio") !='Transition'){
            helper.getreserverecords(component, event, helper);
        }
        helper.fetchAllProductConfig(component, event, helper);       
    },//EDGE-140792,EDGE-138086
    clearSearchScreen: function(component,event,helper){
        console.log('Inside clearSearchScreen');
        var data = component.get("v.numberReserve");
        component.set("v.searchResult", []);
        console.log(data);
        if(data != null){
            if(component.get("v.selectedTab") == 'Fixed'){
                data.sameExchange =false;
                data.selectedAreaCode="";
                data.selectedPatternType="";
            }
            data.selectedSearchType="Non-Contiguous";
            data.quantity="";
            data.reqPattern=""; 
            data.deliveryAddress=null;
            component.set("v.numberReserve",data);
        }
    },//EDGE-140792,EDGE-138086
    handleFinishbutton: function (component,event,helper){
        console.log('Selected Radio>>>'+ component.get("v.selectedradio"));
        console.log('Selected Tab >>>>   '+component.get("v.selectedTab"));
        if(component.get("v.selectedradio") == 'Manage Number'){
            this.closeMainPopup(component);
            return;
        }        
        console.log('Inside handleFinishbutton');
        component.set("v.loadingSpinner", true);
        var action = component.get("c.finishReservationbtn");
        action.setParams({
            "basketId": component.get("v.basket_id"),
            "selectedTab": component.get("v.selectedTab")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set("v.loadingSpinner", false);
                console.log('resp popup',resp);
                if(!resp.IsValid){
                    this.showCustomToast(
                        component,
                        resp.ErrorMessage,
                        "",
                        "error"
                    );
                    return;
                }
                else{
                    if(resp.IsValidForPopup){                    
                        component.set("v.isPopup",true);
                        console.log('component.set("v.isPopup")',component.get("v.isPopup"));
                    }
                }
                component.set("v.loadingSpinner", false);
                this.showCustomToast(
                    component,
                    resp.SuccessMessage,
                    "",
                    "success"
                );
                if(!resp.IsValidForPopup){
                    this.closeMainPopup(component);
                }
                return;
            } 
            else{
                console.log("error: ",response.getError());
            }
        });
        $A.enqueueAction(action);
    },//EDGE-140792,EDGE-138086
    okPopup: function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        var action = component.get("c.OKunReserveFNN");
        action.setParams({
            basketId: component.get("v.basket_id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isPopup", false);
                var resp = response.getReturnValue();
                this.closeMainPopup(component);
            }
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
    },
    closeMainPopup : function (component){
        window.setTimeout(
            $A.getCallback(function() {
                window.parent.postMessage("close", "*");
                sessionStorage.setItem("close", "close");
            }),
            1000
        );
        return;
    },
    getsimDetails : function(component){
        console.log('Inside getsimDetails>>');
        var action = component.get("c.getsimDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status>>>>'+state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                component.set("v.simDetails",data);
                component.set("v.isSearchresult",true);
            }
        });
        $A.enqueueAction(action);
    },
    UpdateConfigAttribute:function(component, event, helper,Callfrom){
        //this method is for updating inline pc from data table to schema attribute EDGE-174218 
        console.log('spinner value inside update config '+component.get("v.loadingSpinner"));
        var dataval = new Object();
        dataval = JSON.parse(event.getParam('updaterec'));
        console.log("event.getParam",event.getParam('updaterec'));
        var callVFmethod =component.get("v.Value");  
        callVFmethod(dataval,Callfrom,function(answer){
            console.log('callback received');
        });  	
        
        component.set("v.loadingSpinner", false);     
    },
    //EDGE-185029,EDGE-186482. Kalashree Borgaonkar. SIM detail assignment and validations for Reactivate services
    assignSIMforReactivation : function(component, event,helper){
        var selectedProductconfig = JSON.stringify(event.getParam("selectedProductconfig"));
        console.log("JSON.stringify(event.getParam",JSON.stringify(event.getParam("selectedProductconfig")));
        var selectedSimTypeValue = event.getParam("selectedSimTypeValue");
        var newWxistingSIM = event.getParam("newWxistingSIM");
        var action = component.get("c.assignSIM"); 
        action.setParams({
            "selectedPcWrapper": selectedProductconfig,
            "basketId": component.get("v.basket_id"),
            "selectedSimTypeValue":selectedSimTypeValue,
            "newWxistingSIM":newWxistingSIM           
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loadingSpinner", true); 
                var resp = response.getReturnValue();
                if(resp=='Success'){
                    helper.handlerefreshdataview(component, event, helper);
                    this.showCustomToast(
                        component,
                        "SIM details have been assigned successfully.",
                        "",
                        "success"
                    ); 
                    component.set("v.callVF",true); // akanksha added to call VF
                }
                else{
                    component.set("v.loadingSpinner", false); 
                    this.showCustomToast(
                        component,
                        resp,
                        "",
                        "error"
                    );
                }
                
            } else {
                component.set("v.loadingSpinner", false);
                this.showCustomToast(
                    component,
                    response.getError(),
                    "",
                    "error"
                );
            }
        });
        $A.enqueueAction(action);
    },
     checkForReactiveService : function(component){
      
        var action = component.get("c.checkReactivateServices");
         action.setParams({
            "basketId": component.get("v.basket_id")  
        });
        action.setCallback(this, function(response) {
             var state = response.getState();
            console.log('Status>>>>'+state);
            
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('Reactivaet data: ',data); 
                component.set("v.isReactiveServices",data);
            }
        });
        $A.enqueueAction(action);
    },
    UpdateConfigAttributeOnAssignNumber:function(component, event, helper){
        var dataval = new Object();
        dataval = event.getParam('pconfigList');
        var callVFmethod =component.get("v.Value");  
        callVFmethod(dataval,'Assign Button',function(answer){
            console.log('callback received');
        });  	
        
        component.set("v.loadingSpinner", false);     
    }, 
     // EDGE-203933. Kalashree Borgaonkar. sortData
     sortData : function(component,resp,fieldName,sortDirection){
        var data = resp;
        console.log('data dispList before',data);
        //function to return the value stored in the field
        var key = function(a) {
            console.log('a[fieldName]',a[fieldName]); 
            return a[fieldName]; 
        }
        console.log('key',key);
        var reverse = sortDirection == 'asc' ? 1: -1;
            data.sort(function(a,b){ 
                console.log('m there');
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
       
        //set sorted data to accountData attribute
        console.log('data dispList after',data);
        component.set("v.objproductconfig",data); 
        
    },
    //DIGI-3161 added by shubhi 
    logTransaction: function(component, event, helper,searchType,eventInfo,quantity){
        var action = component.get("c.logTransaction");
        action.setParams({
            "searchType": searchType,
            "basketId":component.get("v.basket_id"),
            "quantity":quantity,
            "event":eventInfo
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Transaction log inserted");
            }        
        });
        $A.enqueueAction(action);
    }
    
})