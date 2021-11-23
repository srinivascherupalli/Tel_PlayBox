//EDGE-140792,EDGE-138086
({
    getColumnAndAction : function(component) {
        console.log('Inside getColumnAndAction');
        component.set('v.columns', [
            {label: 'Available Numbers', fieldName: 'numberList', type: 'text'} 
        ]);
        //EDGE-168704: New Column Plan Type based on selected redio button
        if (component.get("v.selectedradio") == 'Transition')
        {
            
            
            component.set('v.resrvecolumns', [
                {label: 'Available Numbers', fieldName: 'availablenumber', type: 'text',},
                {label: 'Plan Type', fieldName: 'planType', type: 'text',},
                {label: 'Type', fieldName: 'type', type: 'text'},
                {label: 'Status', fieldName: 'status', type: 'text',cellAttributes: { class: { fieldName: 'addcss' }}},
                {label: 'Assigned To', fieldName: 'assignedto', type: 'text', wrapText: true}
            ]);
        }
        
        else
        { 
            component.set('v.resrvecolumns', [
                {label: 'Available Numbers', fieldName: 'availablenumber', type: 'text',},
                {label: 'Type', fieldName: 'type', type: 'text'},
                {label: 'Status', fieldName: 'status', type: 'text',cellAttributes: { class: { fieldName: 'addcss' }}},
                {label: 'Assigned To', fieldName: 'assignedto', type: 'text', wrapText: true}
            ]);   
        }
        
        var tabId = component.get("v.selectedtab");
        /*  if(tabId =='Fixed'){
            component.set('v.productconfcolumns', [
                {label: 'Solution Name', fieldName: 'solution', type: 'text'},
                {label: 'Name', fieldName: 'model', type: 'text'},
                {label: 'SIM Type', fieldName: 'simType', type: 'text'},
                {label: 'Serial Number', fieldName: 'serialNumber', type: 'text'}]);
            //component.set("v.configtablename", 'Product_Configuration_Fixed');
        } */
        if(tabId =='Mobile'){
            component.set('v.productconfcolumns', [
                {label: 'Mobile Plan', fieldName: 'planName', type: 'text',hideDefaultActions: true},
                {label: 'Add-On', fieldName: 'Name', type: 'text',hideDefaultActions: true},
                {label: 'Add-On Details', fieldName: 'AddOnName__c', type: 'text',hideDefaultActions: true},
                {label: 'SIM Serial', fieldName: 'simSerialNumber', type: 'text',hideDefaultActions: true},
                {label: 'Number Assigned', fieldName: 'assignedNumber', type: 'text',hideDefaultActions: true}
            ]);
            
            //component.set("v.configtablename", 'Product_Configuration_Mobile');
        } 
       /*  if(component.get("v.isngEMPresent") && component.get("v.selectedradio") == 'Transition'){
            component.set("v.configtablename", 'PC_Adaptive_Mobility_Transition');
        }
       else if(component.get("v.isngEMPresent") == undefined && component.get("v.selectedradio") == 'Transition'){
            component.set("v.configtablename", 'PC_CMP_Transition');
        } */
        if((component.get("v.isngEMPresent") == undefined ||  component.get("v.isngEMPresent") == false)  && tabId =='Fixed'){
            component.set("v.configtablename", 'Product_Configuration_Fixed');
        }
        else if(component.get("v.isngEMPresent")){
            component.set("v.configtablename", 'Product_Configuration_Adaptive_Mobility');
        }
            else{
                component.set("v.configtablename", 'Product_Configuration_Mobile');
            }

        if(component.get("v.selectedradio") == 'Transition'){
            component.set("v.reservetablename", 'Number_Reservation_Transition');
            
        }
        else{
            component.set("v.reservetablename", 'Number_Reservation');
        }
        
        
        console.log('Selected Table>>>'+ component.get("v.selectedradio") + '=====' + 'configtablename>>>>>' + component.get("v.configtablename") + '====' + component.get("v.isngEMPresent")); 
    },
    //Toast to display Error
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
    handleReserve : function(component,event,helper){ 
        var tabselected = component.get("v.selectedtab");
        var respNumList = component.get("v.reserveselectedRows");
        var len = respNumList.length;
        var flag = false;
        if (len > 0) {
            flag = true;
        }
        if (flag == true) {
            var updatednumList=[];
            var numList=[];
            respNumList.forEach(function(num) {
                numList.push(num.numberList);
            });
            var numListString = JSON.stringify(numList);
            var recordId = component.get("v.basket_id");
            //console.log("productconflist: ",component.get("v.productconflist"));
            component.set("v.loadingSpinner", true);
            var action = component.get("c.reserveNumbers");
            action.setParams({
                fnnListToReserve: numListString,
                basketId: recordId,
                selectedTab: tabselected
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loadingSpinner", false);
                    var resp = response.getReturnValue();
                    if(resp == "Success"){
                        component.set("v.loadingSpinner", false);
                        //DIGI-3161 added by shubhi start-----------
                        var searchType="Pattern Search";
                        var eventType="Number reservation completed";
                        helper.logTransaction(component, event,helper,searchType,eventType);
                        //DIGI-3161 added by shubhi end--------------
                        this.showCustomToast(
                            component,
                            "Number(s) reserved successfully",
                            "",
                            "Success"
                        );
                        var serachrasult= component.get("v.searchResult");
                        for(var i=0; i < serachrasult.length; i++){
                            if(!numList.includes(serachrasult[i].numberList)){
                                updatednumList.push(serachrasult[i]);
                            }
                        }
                        //console.log(updatednumList);
                        var cmpEvent = component.getEvent("refreshviewEvent");
                        cmpEvent.setParams({
                            "updatedsearchrasult" : updatednumList,
                        });
                        cmpEvent.fire();
                    }else{
                        component.set("v.loadingSpinner", false);
                        console.log('resp::',resp);
                        if(resp==null || resp=="" || resp==undefined){
                            resp = 'Error in reserving numbers';
                        }
                        this.showCustomToast(
                            component,
                            resp,
                            "",
                            "error"
                        );
                    }
                } else {
                    component.set("v.loadingSpinner", false);
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.loadingSpinner", false);
            this.showCustomToast(
                component,
                "Please select at least one number to add.",
                "",
                "error"
            );
        }
    },//EDGE-140792,EDGE-138086
    handleSelectedrecordslwc : function(component, event, helper){
        var selectedRow = JSON.parse(event.getParam('selectedRow'));
        //console.log(selectedRow);
        var srelecpcrec =[];
        if(selectedRow.length > 0){  
            for (var i = 0; i < selectedRow.length; i++) {
                //console.log(selectedRow[i]);
                srelecpcrec.push(selectedRow[i].configId);
            }
            component.set("v.selectedProductconfig",srelecpcrec);
            component.set("v.selectedrecords",selectedRow);
        }else{
            component.set("v.selectedProductconfig",srelecpcrec);
            component.set("v.selectedrecords",selectedRow)
        }        
        //console.log(srelecpcrec); 
        console.log(component.get("v.selectedrecords")); 
    },
    //EDGE-140792,EDGE-138086
    handleSelectedrecords : function(component, event, helper){
        console.log('Inside handleSelectedrecords');
        var tableName = event.getParam("tableName");
        var selrecords = event.getParam("selectedrecords");
        console.log('tableName>>>'+tableName);
        component.set("v.selectedrecords",selrecords);
        //EDGE-142086 - Added or condition be below "if" to show ProductTable for Manage tab
        if(tableName == 'productconfigurationtable' || tableName == 'productconfigurationtableforManage' ){
            var srelecpcrec =[];
            if(selrecords.length > 0){                
                for (var i = 0; i < selrecords.length; i++) {
                    srelecpcrec.push(selrecords[i].configId);
                }                
                component.set("v.selectedProductconfig",srelecpcrec);
            }else{
                component.set("v.selectedProductconfig",srelecpcrec);
            }
            //console.log(component.get("v.selectedProductconfig"));
        }
        if(tableName == 'reservationpooltable'){
            var srelecpoolrec =[];
            if(selrecords.length > 0){                
                for (var i = 0; i < selrecords.length; i++) {
                    srelecpoolrec.push(selrecords[i].availablenumber);
                }                
                component.set("v.selectedreservationrec",srelecpoolrec);
            }
            else{
                component.set("v.selectedreservationrec",srelecpoolrec);
            }
            //console.log('>>>'+component.get("v.selectedreservationrec"));
        }
        if(tableName == 'searchresulttable'){
            if(selrecords.length > 0){
                component.set("v.isShowreservebtn",false);
            }else{
                component.set("v.isShowreservebtn",true);
            }
            component.set("v.reserveselectedRows",selrecords);
        }
    },//EDGE-140792,EDGE-138086
    /*removeassignednumber : function(component, event, helper){
        console.log('Inside removeassignednumber....');
        var selectedrec = component.get("v.selectedrecords");
        if(selectedrec == null){
            this.showCustomToast(
                component,
                'Please select at least one number to remove.',
                "",
                "error"
            );
            return;
        }
        //EDGE-175687. Kalashree Borgaonkar. 
        var checkAssignment=false;
        for (var i = 0; i < selectedrec.length; i++) {
            console.log("selectedtab:",component.get("v.selectedtab"));
            if( selectedrec[i].assignedNumber!='' && selectedrec[i].assignedNumber!=undefined && selectedrec[i].assignedNumber!='Un-Assigned'){
                checkAssignment=true;
                break;
            }
        }
        if(checkAssignment==false && component.get("v.selectedtab")=='Mobile'){
            this.showCustomToast(
                component,
                'No number has been assigned to the product configuration(s)',
                "",
                "error"
            );
            return;
        }
        console.log(selectedrec);
        var removerecords =[];
        for (var i = 0; i < selectedrec.length; i++) {
            removerecords.push(selectedrec[i].configId);
        }
        var cmpEvent = component.getEvent("removeassignedNumber");
        cmpEvent.setParams({
            "selectedrecords" : removerecords,
            "btnName" : 'RemoveAssignedNumber'
        });
        cmpEvent.fire();
    },*///EDGE-140792,EDGE-138086
    removeassignednumber : function(component, event, helper){
        var selectedrec = component.get("v.selectedrecords");
        if(selectedrec == null || selectedrec.length == 0){
            this.showCustomToast(
                component,
                'Please select at least one product configuration  to remove assign number.',
                "",
                "error"
            );
            return;
        }
        //EDGE-175687. Kalashree Borgaonkar. 
        var checkAssignment=false;
        for (var i = 0; i < selectedrec.length; i++) {
           if( selectedrec[i].assignedNumber!='' && selectedrec[i].assignedNumber!=undefined && selectedrec[i].assignedNumber!='Un-Assigned'){
                checkAssignment=true;
                break;
            }
        }
        //console.log('checkAssignment>>>'+checkAssignment);
        if(checkAssignment==false && component.get("v.selectedtab")=='Mobile'){
            this.showCustomToast(
                component,
                'No number has been assigned to the product configuration(s)',
                "",
                "error"
            );
            return;
        }
        console.log(selectedrec);
        var removerecords =[];
        for (var i = 0; i < selectedrec.length; i++) {
            removerecords.push(selectedrec[i].configId);
        }
        var clickedBtn = event.getSource().getLocalId();
        console.log(clickedBtn);
        
        if(clickedBtn == 'removeassignednumber'){
            helper.removeAssignedPCNumbers(component,event,helper);
        }
        if(clickedBtn == 'RemoveFromPool'){            
            helper.removeNumberFromPools(component, event, helper);
        }
        /* var cmpEvent = component.getEvent("removeassignedNumber");
        cmpEvent.setParams({
            "selectedrecords" : removerecords,
            "btnName" : 'RemoveAssignedNumber'
        });
        cmpEvent.fire();*/
    },
    removeAssignedPCNumbers: function(component, event, helper){
        var selrecords = component.get("v.selectedProductconfig");
        component.set("v.loadingSpinner", true);
        component.set("v.showErrorForTransition",false);
        var action2 = component.get("c.removeAssignedNumbers");
        
        action2.setParams({
            "selectedPCList": selrecords,
            "basketID": component.get("v.basket_id"),
            "selectedTab": component.get("v.selectedtab")
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loadingSpinner", false);
                var resp = response.getReturnValue();
                var msg = 'Number unassigned successfully';
                helper.handlerefreshdataview(component, event, helper,msg,'Success');
                if(component.get("v.selectedradio") == 'Transition'){
                    this.refreshLegacyTransitionTable(component, event, helper);
                }
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action2);
    },
    removeNumberFromPools : function(component, event, helper){
        var selrecords = component.get("v.selectedReserverec");
        //console.log(selrecords);
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
            "selectedTab": component.get("v.selectedtab")
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state removeNumberFromPools',state);
            if (state === "SUCCESS") {
                component.set("v.loadingSpinner", false);
                var resp = response.getReturnValue();
                //console.log('**Resp***',resp);
                var msg = 'Number removed Successfully.';
                if(resp.status){//EDGE-145555
                    helper.handlerefreshdataview(component, event, helper,msg,'Success');
                    /*this.showCustomToast(
                        component,
                        "Number removed Successfully.",
                        "",
                        "Success");*/
                }else{
                    if(resp.errList!= undefined && resp.errList.length > 0){
                        this.showCustomToast(
                            component,
                            resp.errList[0].message, //EDGE-129218
                            "",
                            "error");
                    }
                }
                
            }  else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action2);
    },
   
    assignSelectedNumber : function(component, event, helper){
        //edge -208737 starts
        var selectedProductConfig=component.get("v.selectedrecords");
        console.log('selectedProductConfig'+JSON.stringify(selectedProductConfig));
        if(selectedProductConfig.length > 0){
            var productConfig= selectedProductConfig[0].productConfig;
        }
        //edge -208737 ends
        component.set("v.loadingSpinner", true);
        component.set("v.showErrorForTransition",false);
        component.set("v.callVF",false);
        var selectedreservationrec = component.get("v.selectedReserverec");
        var selectedProductconfig = component.get("v.selectedProductconfig");
        if(selectedreservationrec.length == 0 || 
           selectedProductconfig.length == 0){
            console.log('component.get("v.selectedreservationrec").length',component.get("v.selectedreservationrec").length);
            this.showCustomToast(
                component,
                'Please select at least one product configuration and one number for assignment.',
                "",
                "error"
            );
            component.set("v.loadingSpinner", false);
            return;
        }
        if(component.get("v.selectedtab")=='Mobile' && 
           selectedreservationrec.length != selectedProductconfig.length){
            this.showCustomToast(
                component,
                $A.get("$Label.c.NumberReservation_QuantityCheck"),
                "",
                "error"
            );
            component.set("v.loadingSpinner", false);
            return;
        }
        //edge -208737 starts
        var pcName = $A.get("$Label.c.Product_configuration_name");
        if(productConfig.includes(pcName) &&
           selectedProductconfig.length > 1){
            
            this.showCustomToast(
                component,
                'Please select only one product configuration for assignment.',
                "",
                "error"
            );
            component.set("v.loadingSpinner", false);
            return;
        }
        //edge -208737 Ends
        //var selectedSimTypeValue = 'SIM card';
        
        var action = component.get("c.assignNumbers");
        var selectedOption;
        if(component.get('v.isShowTransition') === true){
            selectedOption = 'Transition';
        }else{
            selectedOption = 'Others';
        }
        action.setParams({
            "selectedPcWrapper": selectedProductconfig,
            "selectedNumbers": selectedreservationrec,
            "selectedTab": component.get("v.selectedtab"),
            "basketid": component.get("v.basket_id"),
            "selectedSimTypeValue":component.get("v.selectedSimTypeValue"),
            "newWxistingSIM":component.get("v.newWxistingSIM"),
            "selectedOption":selectedOption, 
            "transitionWrapper":JSON.stringify(component.get("v.selectedTransitionList"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set("v.callVF",true);
                if(resp.Status === 'Success' || resp==='Success'){
                    var toastMessage = 'Number  assigned successfully';
                    helper.handlerefreshdataview(component, event, helper,toastMessage,'success');
                    
                }
                if((resp.Status==='Error' || resp==='Error' ) && (component.get("v.selectedradio") != 'Transition' && !component.get("v.isngEMPresent") )){
                    var toastMessage = 'Number not assigned successfully';
                    helper.handlerefreshdataview(component, event, helper,toastMessage,'Error');
                }
                if(resp.Status === 'Error' && component.get("v.selectedradio") == 'Transition' && component.get("v.isngEMPresent")){
                    component.set("v.unassignedCountForTransition",resp.unassignedCount);
                    component.set("v.assignedCountForTransition",resp.assignedCount);
                    component.set("v.showErrorForTransition",true);
                     var toastMessage='One or more services have failed plan assignment due to invalid mapping of plan type/plan of legacy service with configured plan in the basket.';
                     helper.handlerefreshdataview(component, event, helper,toastMessage,'Error');
                    
                }
                if(component.get("v.selectedradio") == 'Transition'){
                    this.refreshLegacyTransitionTable(component, event, helper);
                }
                console.log('calling vf method');
               /* var cmpEvent = component.getEvent("setAttribute");
                cmpEvent.fire(); */
            } 
            else {
                component.set("v.loadingSpinner", false);
                this.showCustomToast(
                    component,
                    "There is some issue in server side.",
                    "",
                    "error"
                );
            }
        });
        $A.enqueueAction(action);
    },
    handlerefreshdataview: function (component, event, helper,toastMessage,toastType){
        helper.fetchAllProductConfig(component, event, helper,toastMessage,toastType);
        if(component.get("v.selectedradio") != 'Transition' && component.get("v.selectedTabId") != 'searchresulttab'){
            helper.getreserverecords(component, event, helper); 
            console.log('Fetch transition number for non transition tab' );
        }       
    },
    fetchAllProductConfig : function(component, event, helper,toastMessage,toastType){
        component.set("v.selectedrecords",'')
        var radioVal = component.get("v.selectedradio");
        var action = component.get("c.getAllProductConfig");
        action.setParams({
            "basketId": component.get("v.basket_id"),
            "selectedTab": component.get("v.selectedtab"),
            "selectedRadioOption": component.get("v.selectedradio") //EDGE-185029 Adding paramter for selected radio button
            //EDGE-208742 - Instead of parameter passing selected radio button value
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                var configdata = component.get("v.productconflist");
                if(resp != undefined && resp.length > 0){
                    component.set("v.productconflist", '');
                   // component.set("v.productconflist", resp);
                   // EDGE-203933. Kalashree Borgaonkar. Sort for Tranisiton/migration. Start
                   var selectedRadio= component.get("v.selectedradio");
                     if(selectedRadio=='Transition' || selectedRadio=='Migration'){
                    this.sortData(component,resp,'assignedNumber','dsc');
                }
                else{
                  component.set("v.productconflist", resp);
                }
                    // EDGE-203933. Kalashree Borgaonkar. Sort for Tranisiton/migration. End
                    if(component.get("v.callVF")){
                         console.log('before callVF');
                         var setAttribute = $A.get("e.c:setAttributesonParentNMCMP");
                        setAttribute.setParams({  
                            "pconfigList" : component.get("v.productconflist") 
                        });
                        setAttribute.fire();
                    }
                }
                if(toastMessage != ''){
                    this.showCustomToast(
                        component,
                        toastMessage,
                        "",
                        toastType
                    );
                }
            }   
            component.set("v.loadingSpinner", false); 
        });
        $A.enqueueAction(action);
    },
    getreserverecords:function(component, event,helper){
        console.log('Inside getreserverecords>>>');
        var recordId = component.get("v.basket_id");
        var numbertype = component.get("v.selectedradio");
        component.set("v.reservedata", '');
        console.log('Before numbertype>>>'+numbertype + '>>>>>' + component.get("v.selectedtab"));
        if(component.get("v.selectedtab") == 'Fixed' && numbertype == 'New'){
            numbertype = 'FNN';
        }
        component.set("v.loadingSpinner", true);
        var action = component.get("c.getreserveNumbers");
        console.log('numbertype>>>'+numbertype + '>>>>>' + component.get("v.selectedtab"));
        action.setParams({
            basketId: recordId,
            numberType:numbertype             
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp);
                console.log('refresh grid>>');
                component.set("v.totalReservedrecord",resp.length);
                var reservedata = component.get("v.reservedata");
                if(reservedata != undefined && reservedata.length > 0){
                    console.log('Inside if>>>>');
                    component.set("v.reservedata", resp);
                    var inlineEdit=component.find("inlineeditnumberresv");
                    if(Array.isArray(inlineEdit)){
                        inlineEdit[0].setData(resp);
                    }
                    else{
                        inlineEdit.setData(resp);
                    } 
                    /*if(resrec != undefined){
                        if(resrec.length > 0){
                            console.log('Inside if');
                          	 resrec[0].setData(resp);
                        }else{
                            console.log('Inside else');
                           resrec.setData(resp);
                        }                       
                    }*/
                    component.set("v.loadingSpinner", false); 
                }else{
                    console.log('Inside else>>>>');
                    component.set("v.reservedata", resp);
                }
                //component.set("v.reservedata", resp);
                console.log('Reserve Numbers');
                //console.log(resp);
            } else {
                
                console.log('Inside error>>>>');
            }
        });
        $A.enqueueAction(action);
    },
    removefromreservationPool : function(component, event, helper){
        if(component.get("v.selectedreservationrec").length == 0 ){
            this.showCustomToast(
                component,
                'Please select at least one number for remove.',
                "",
                "error"
            );
            return;
        }
        var cmpEvent = component.getEvent("removeassignedNumber");
        cmpEvent.setParams({
            "selectedrecords" : component.get("v.selectedreservationrec"),
            "btnName" : 'RemoveFromPool'
        });
        cmpEvent.fire();
    },
    //EDGE-173151 Assigning of SIM option to a mobility plan and updating of SIM option post
    
    
    updateNumberRecs : function(component, event, helper){
        //component.set("v.loadingSpinner", true);
        let isngEMPresent = component.get("v.isngEMPresent");
        let data = JSON.parse(event.getParam('recordsString'));
        var selectedtab = component.get("v.selectedradio");
        console.log(data);
        if(data != undefined){
            console.log(component.find("inlineEditDataTable"));
            var showMsg = component.find("inlineEditDataTable");
            if(data[0].assignedNumber == 'Un-Assigned'){
                showMsg[0].showToastMessage('Info','Please assign number before changing the SIM Type or SIM Option.','error');
                return;
            }
            //EDGE-172362. Kalashree Borgaonkar. Validations for picklist value change. start
            else if( data[0].newExistingSim == 'New SIM' && (selectedtab=='Transition' || selectedtab=='Port In')){
                showMsg[0].showToastMessage('Info',$A.get("$Label.c.NewSIMnotSupported"),'error');
                var cmpEvent = component.getEvent("refreshProductConfigEvent");
                cmpEvent.fire();
            }
                else if( data[0].newExistingSim == 'Existing Active SIM' && (selectedtab=='New' || selectedtab=='Port In')){
                    showMsg[0].showToastMessage('Info',$A.get("$Label.c.ExistingActiveSIMValidation"),'error');
                    var cmpEvent = component.getEvent("refreshProductConfigEvent");
                    cmpEvent.fire();
                }
                    else if( data[0].newExistingSim == 'New SIM' && (selectedtab=='New' || selectedtab=='reactiveServices' ) && (data[0].simSerialNumber.length>0)){
                        showMsg[0].showToastMessage('Info',$A.get("$Label.c.SIMserialNumberNotAllowed"),'error');
                        if(selectedtab!='reactiveServices' ){
                            var cmpEvent = component.getEvent("refreshProductConfigEvent");
                            cmpEvent.fire();
                        } 
                    }
                        else if( data[0].newExistingSim == 'Existing Blank SIM' && selectedtab=='Transition' ){
                            showMsg[0].showToastMessage('Info','Existing Blank SIM is not allowed for transition.','error');
                            var cmpEvent = component.getEvent("refreshProductConfigEvent");
                            cmpEvent.fire();
                        }
            
            //EDGE-172362. Kalashree Borgaonkar. Validations for picklist value change. end
            //EDGE-214802: Existing Deactivated SIM
                            else if(isngEMPresent && (data[0].newExistingSim == 'Existing Active SIM' || data[0].newExistingSim == 'Existing SIM') && data[0].simType =='eSIM'){
                                if(showMsg.length > 0) {
                                    showMsg[0].showToastMessage('Info','eSIMs not supported for existing active SIMs.','error');
                                    
                                }
                                else{
                                    showMsg.showToastMessage('Info','eSIMs not supported for existing active SIMs.','error');
                                }
                            }
                                else{
                                    var action = component.get("c.updateNumberRecs"); 
                                    action.setParams({
                                        "basketId": component.get("v.basket_id"),
                                        "data" : event.getParam('recordsString'),
                                        "radioOption" : component.get("v.selectedradio")
                                    });
                                    action.setCallback(this, function(response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            
                                            var data = response.getReturnValue();
                                            if(data=='Success'){
                                                console.log('inside updateNumberRecs');
                                                var cmpEvent = component.getEvent("refreshProductConfigEvent");
                                                cmpEvent.fire();
                                                //component.set("v.loadingSpinner", false);
                                                var cmpEvent1 =  $A.get("e.c:UpdateConfigurationAtt");
                                                cmpEvent1.setParams({
                                                    "updaterec" : event.getParam('recordsString')
                                                });
                                                cmpEvent1.fire();
                                                //alert('comp is fired '+cmpEvent1);
                                                //poc
                                            }
                                            else{
                                                var cmpEvent = component.getEvent("refreshProductConfigEvent");
                                                cmpEvent.fire();   
                                                this.showCustomToast(
                                                    component,
                                                    data,
                                                    "",
                                                    "error"
                                                ); 
                                            }
                                            
                                        }
                                    });
                                    $A.enqueueAction(action);
                                }   
        }   
    },
    //EDGE-168641 : get SIM Configurration data from custom meta data
    getSIMConfig : function(component, event, helper){
        var metaData=component.get("v.SIMConfig");
        if (!metaData.length > 0){
            var action = component.get("c.getSIMConfiguration");
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('Status>>>>'+state);
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    component.set("v.SIMConfig",data); 
                    console.log('values',component.get("v.SIMConfig"));
                }
            });
            $A.enqueueAction(action);
        }       
        this.getSIMConfiguration(component, event, '');  
    },
    //EDGE-168641 : Set SIM Configurration data
    getSIMConfiguration : function(component, event, helper)
    {
        console.log('getSIMType');
        component.set("v.SIMOptions",'');
        component.set("v.SIMType",'');
        component.set("v.SIMEditable",false);
        var configData= component.get("v.SIMConfig");
        var simOption = [];
        var simType = [];
        var SIMOnly;
        if (configData != null && configData != undefined){
            console.log('configData=='+configData.length);
            for (var i = 0; i < configData.length ; i++)
            {
                
                if(component.get("v.selectedradio") == configData[i].Selected_Tab__c && configData[i].Order__c == 1)
                {
                    var opt=configData[i].SIM_Options__c;
                    simOption.push(opt);
                    SIMOnly =configData[i].SIM_Mode__c;
                    var type = configData[i].Type__c;
                    console.log("type: ",type);
                    simType =  type.split(",");
                }
                if(component.get("v.selectedradio") == configData[i].Selected_Tab__c && configData[i].Order__c > 1)
                {
                    var opts=configData[i].SIM_Options__c;
                    simOption.push(opts);
                }
            }  
            console.log('simType',simType);
            console.log('simOption',simOption);
            component.set("v.SIMOptions",simOption);
            ///EDGE-170885:set default sim option 
            //EDGE-214802: Existing Deactivated SIM
            if(component.get("v.selectedradio")=='Transition'){
                component.set("v.newWxistingSIM",'Existing Active SIM'); }
            else if(component.get("v.selectedradio")=='reactiveServices'){
                component.set("v.newWxistingSIM",'Existing SIM'); }
            else if(component.get("v.selectedradio")=='New'){
                component.set("v.newWxistingSIM",'New SIM'); }
                else{
                    component.set("v.newWxistingSIM",'Existing Blank SIM');    
                }
            //if(component.get("v.isngEMPresent")) {
            component.set("v.SIMType",simType);  //}
            if (SIMOnly == 'Read only'){
                component.set("v.SIMReadOnly",true);
            }
            else     {
                component.set("v.SIMReadOnly",false);
            }
        }
    },
    ///EDGE-21833 : Enhance SIM validation to include Active/Previously used check
    validateSimSerNum : function(component, event){
        var ssRecList = [];
        var selectedRecords = component.get("v.selectedrecords");
        console.log('selectedRecords>>>>in21833'+selectedRecords);
        console.log('selectedRecordsjson::',JSON.stringify(selectedRecords));

        if(selectedRecords==null || selectedRecords.length==0){
            this.showCustomToast(
                component,
                'Please select at least one Product configuration.',
                "",
                "error"
            );
        }
        else{
            var isexistingSIMPresent=false;
            var isNewSimPresent=false;
            var isBlankSimPresent=false;
            for(var i=0;i<selectedRecords.length;i++){
                if(selectedRecords[i].newExistingSim=='Existing Blank SIM'){
                    isBlankSimPresent=true;
                    break;
                }
            }

            if(isBlankSimPresent==false){
                
                this.showCustomToast(
                    component,
                    $A.get("$Label.c.SIMserialQualifcationValidation"),
                    "",
                    "error"
                );
            }
            else{
                console.log('@V@ inside Else ');
                var simSerialList = [];
                for(var i=0;i<selectedRecords.length;i++){
                    if(selectedRecords[i].newExistingSim=='Existing Blank SIM'){

                        if((selectedRecords[i].simSerialNumber==null || selectedRecords[i].simSerialNumber==undefined || selectedRecords[i].simSerialNumber=='' ) ){
                            this.showCustomToast(
                                component,
                                $A.get("$Label.c.SIMserialNumbertobeEntered"),
                                "",
                                "error"
                            );
                            console.log('@V@ inside Else 1st block ');
                            return;
                        }
                        else if((/\D/.test(selectedRecords[i].simSerialNumber)) || selectedRecords[i].simSerialNumber.length!=13 ){
                            this.showCustomToast(
                                component,
                                $A.get("$Label.c.InvalidSIMFound"),
                                "",
                                "error"
                            );
                            console.log('@V@ inside Else 2st block ');
                            return;
                        }
                        else{
                            for(var i=0;i<selectedRecords.length;i++){
                                    console.log('@V@ insider another else ');
                                    simSerialList.push(selectedRecords[i].simSerialNumber);
                                    
                                    
                                }
                                var simSerialSet = new Set(simSerialList);
                                if(simSerialList.length!=simSerialSet.size){
                                    this.showCustomToast(
                                        component,
                                        $A.get("$Label.c.DuplicateSIMfound"),
                                        "",
                                        "error"
                                    );
                                    console.log('@V@ inside Else 3rd block ');
                                    return;
                                }
                        }

                    }

                }
            }
        }

            

        for(var i=0;i<selectedRecords.length;i++){
            console.log('@V@ insider another else ');
            ssRecList.push(selectedRecords[i].simSerialNumber);
        }
        console.log('ssRecList::',ssRecList);
        var action = component.get("c.validateSimSerNumberCtrl");
        action.setParams({
            "simSerNumberList" : ssRecList
        })

        action.setCallback(this, function(response) {
        var state = response.getState();
            console.log('StatusIrfan>>>>'+state);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set("v.simSerialNumber",resp);
                var getSimSerNum = component.get("v.simSerialNumber");
                if(getSimSerNum.length > selectedRecords.length){
                    this.showCustomToast(
                        component,
                        $A.get("$Label.c.InvalidSimSerialFound"),
                        "",
                        "error"
                    );
                }else{
                    this.handleQualifySim(component, event);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE-21833---END
    //EDGE-170884. Kalashree Borgaonkar. ValidateSIMinterface callout
    handleQualifySim : function(component, event){
        var selectedRecords = component.get("v.selectedrecords");
        var prodConfigList = component.get("v.productconflist");
        var basketid= component.get("v.basket_id");
        console.log("selectedRecords: ",selectedRecords);
        console.log("productconflist: ",prodConfigList);
                                
                                //callout
                                console.log('json::',JSON.stringify(selectedRecords));
                                component.set("v.loadingSpinner", true);
                                var action = component.get("c.validatSimSerialCallout");
                                action.setParams({
                                    "validSimList": JSON.stringify(selectedRecords),
                                    "prodConfigList":JSON.stringify(prodConfigList),
                                    "basketid" : basketid
                                });
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    console.log('Status>>>>'+state);
                                    if (state === "SUCCESS") {
                                        var data = response.getReturnValue();
                                        if(data == null){
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                message: "One or more SIMs have been previously used",
                                                duration:' 5000',
                                                key: 'info_alt',
                                                type: 'error',
                                                mode: 'pester'
                                            });
                                            toastEvent.fire();
                                        }
										console.log('@V@ Data',data);
                                        component.set("v.productconflist",data);
                                        console.log('data on validate',data);
                                        var inlineEdit=component.find("inlineEditDataTable");
                                        if(Array.isArray(inlineEdit)){
                                            inlineEdit[0].setupTable();
                                        }
                                        else{
                                            inlineEdit.setupTable();
                                        } 
                                        component.set("v.loadingSpinner", false);
                                    }
                                    else{
                                        console.log("error: ",state.getError());
                                        this.showCustomToast(
                                            component,
                                            state.gettError(),
                                            "",
                                            "error"
                                        );
                                    }
                                    component.set("v.loadingSpinner", false);
                                });
                                component.set("v.selectedrecords",null);
                                $A.enqueueAction(action);
                            
                    
                
            
        
    },
    
    //EDGE-185029,EDGE-186482. Kalashree Borgaonkar. SIM detail assignment and validations for Reactivate services
    assignSIMforReactivation : function(component, event, helper){
        console.log("selectedrecords",component.get("v.selectedrecords"));
        if(component.get("v.selectedrecords")==null || component.get("v.selectedrecords").length == 0){ 
            this.showCustomToast(
                component,
                'Please select at least one product configuration.',
                "",
                "error"
            );
            return;
        }
        var simDetails = component.get("v.simDetails");
        var cmpEvent = component.getEvent("assignedNumber");
        cmpEvent.setParams({
            "selectedProductconfig" : component.get("v.selectedrecords"),
            "selectedSimTypeValue": component.get("v.selectedSimTypeValue"),
            "newWxistingSIM": component.get("v.newWxistingSIM")
        });
        cmpEvent.fire();
        component.set("v.selectedrecords",[]);
    },
    handlereserveRowSelected:function(component, event, helper){
        var selectedRowdata = JSON.parse(event.getParam('selectedRow'));
        console.log(selectedRowdata);
        var srelecpcrec =[];
        if(selectedRowdata.length > 0){  
            for (var i = 0; i < selectedRowdata.length; i++) {
                //console.log(selectedRow[i]);
                srelecpcrec.push(selectedRowdata[i].availablenumber);
            }
            component.set("v.selectedReserverec",srelecpcrec);
            component.set("v.selectedresrecords",selectedRowdata);
        }else{
            component.set("v.selectedReserverec",srelecpcrec);
            component.set("v.selectedresrecords",selectedRowdata)
        }        
        console.log(srelecpcrec);        
    },
    //EDGE-203929-Dheeraj Bhatt-Enhancements to "Assign Numbers To" table to display add-ons in a Tree view for each plan config record
    onRowSelection:function(component, event, helper){
        var selectedRowdata = JSON.parse(event.getParam('selectedRow'));
        var resultData = component.get("v.productconflist");
        var selectedChildRowsId= [];
        var selectedParentRowsId= [];
        var totalSelectedRow=[];
        var selectedProdConfig=[];
        var selectedRecords=[];
        var noParentRowSelected=true;
        if(selectedRowdata.length > 0){
            for(var i=0; i<selectedRowdata.length;i++){
                if(selectedRowdata[i].level == 1) {
                    selectedParentRowsId.push(selectedRowdata[i]);
                }
            }
            
            for(var j=0; j < selectedParentRowsId.length; j++){
                selectedRecords.push(selectedParentRowsId[j]); 
                selectedProdConfig.push(selectedParentRowsId[j].configId);
            }
            var lwcTreeGrid=component.find("lwcTreeGrid");
            if(Array.isArray(lwcTreeGrid)){
                lwcTreeGrid[0].refreshSelectedRowData(selectedProdConfig);
            }
            else{
                lwcTreeGrid.refreshSelectedRowData(selectedProdConfig);
            } 
            component.set("v.selectedProductconfig",selectedProdConfig);
            component.set("v.selectedrecords",selectedRecords);
        }
        else{
            component.set("v.selectedProductconfig",selectedProdConfig);
            component.set("v.selectedrecords",selectedRecords)
            
        } 
    },
    //203932-Dheeraj Bhatt-Number Assignment for Transition without reservation Pool
    handleSelectTransitionNumberEvt:function(component, event, helper){
        component.set("v.showAssignButton",event.getParam("showAssignButton"));
        component.set("v.selectedTransitionList",event.getParam("selectedTransitionList"));
        component.set("v.selectedReserverec",event.getParam("selectedTransitionNumberList"));
        
    },
     //203932-Dheeraj Bhatt-Refresh Transition Screen on Assignment or un-Assignment of number from PC
    refreshLegacyTransitionTable:function(component, event, helper){
        var refreshTransitionTable = $A.get("e.c:refreshLegacyTransitionTableEvt");
        refreshTransitionTable.setParams({ });
        refreshTransitionTable.fire();
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
        component.set("v.productconflist",data); 
        
    },
    //DIGI-3161 added by shubhi 
    logTransaction: function(component, event, helper,searchType,eventInfo){
		var respNumList = component.get("v.reserveselectedRows");
        var reqQuan = respNumList.length;
        if (reqQuan > 0) {
            var action = component.get("c.logTransaction");
            action.setParams({
                "searchType": searchType,
                "basketId":component.get("v.basket_id"),
                "quantity":reqQuan,
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
    },
})