({
    //EDGE-140792,EDGE-138086
    doInit : function(component, event, helper) {
        console.log("solutionname>>>>>"+ component.get("v.solutionname"));
        //helper.getSearchInitialdata(component, event, helper);
        helper.getsimDetails(component);
         
        
    },
    
    //EDGE-140792,EDGE-138086
    refreshdataTabChanged: function(component, event, helper){
        console.log('Inside refreshdataTabChanged');
        helper.checkForReactiveService(component);
        //helper.getreserverecords(component, event, helper);
        //helper.fetchAllProductConfig(component, event, helper);
    },
    
    handleActiveTab : function(component, event, helper) {
        var selectedTab = event.getParam("selectedTabId");
        var clickedAction = event.getParam("clickedAction");
        if(selectedTab !== undefined)
            component.set("v.selectedTab", selectedTab);
        console.log('activetab',selectedTab);
        component.set("v.isShowSearch",true);
        var data = component.get("v.numberReserve");
        console.log('data>>',data);
        if(component.get("v.selectedTab") == 'Fixed'){
           // helper.handleresetNumbermgmt(component, event, helper);
            if(data!==null && data!==undefined && data.searchTypeList.length==1){
                data.searchTypeList=[];//EDGE-145555,EDGE-148657
                data.searchTypeList.push({'label':'Non-Contiguous', 'value':'Non-Contiguous'});
                data.searchTypeList.push({'label':'Contiguous', 'value':'Contiguous'});
            }
            helper.clearSearchScreen(component,event,helper);
            //helper.getSearchInitialdata(component, event, helper);
            component.set("v.numberReserve",data);
            helper.getreserverecords(component, event, helper);
            helper.fetchAllProductConfig(component, event, helper); 
        	
           }
        else{
            if(data!==null && data.searchTypeList.length==2){
                console.log('data>>',data.searchTypeList.length);
                data.searchTypeList.splice(1,1); 
            }
            component.set("v.numberReserve",data);
        }
        if(component.get("v.selectedTab") == 'Mobile'){
            helper.clearSearchScreen(component,event,helper);//EDGE-145555
            helper.getSearchInitialdata(component, event, helper);
            helper.getreserverecords(component, event, helper);
            helper.fetchAllProductConfig(component, event, helper); 
        }
        if(clickedAction == 'addAddress'){
            helper.addAddress(component, event, helper);
        }
        component.set("v.isShowPortin",false);
        component.set("v.isShowTransition",false);
        component.set("v.isShowManage",false);
        component.set("v.selectedradio", 'New');
    },
    handleSearchOption : function(component, event, helper) {
        helper.handlesearchSection(component,event,helper);
    },
    handleSearchresult : function(component, event, helper) {
        //var searchresult = event.getParam("searchresult");
        var searchType = event.getParam("searchType");
        //component.set("v.numberReserve", searchresult);
        if(searchType == 'search'){
            helper.handleSearchNumbers(component, event, helper);
        }else if(searchType == 'Autoreserve'){
            helper.handleAutoReserve(component, event, helper);
        }
    },
    fixedPortInScreen:function(component,event,helper){
        helper.fixedPortInScreen(component, event);
    },
    handleSelectedrecords : function(component,event,helper){
        helper.handleSelectedrecords(component,event,helper);        
    },
    removeNumberFromPool : function(component,event,helper){
        var btnName = event.getParam("btnName");
        if(btnName == 'RemoveAssignedNumber'){
            helper.removeAssignedPCNumbers(component,event,helper);
        }
        if(btnName == 'RemoveFromPool'){            
            helper.removeNumberFromPools(component, event, helper);
        }
        
    },
    assigneNumbers: function(component,event,helper){
        //EDGE-185029,EDGE-186482. Kalashree Borgaonkar. SIM detail assignment and validations for Reactivate services
        if(component.get("v.selectedradio") == 'reactiveServices'){
            console.log("in assignSIM");     
            helper.assignSIMforReactivation(component,event,helper);       
        }
        else{   
            console.log('Inside assignSelectedNumbers event');
            helper.assignSelectedNumbers(component,event,helper);
        }
    },
    handleresetNumbermgmt:function(component,event,helper){
        helper.handleresetNumbermgmt(component,event,helper);
    },
    handlerefreshview:function(component,event,helper){
        component.set("v.searchResult",event.getParam("updatedsearchrasult"));
    },
    handleFinishbutton:function(component,event,helper){
        helper.handleFinishbutton(component,event,helper);
    },
    cancelPopup:function(component,event,helper){
        component.set("v.isPopup",false);   
    },
    okPopup:function(component,event,helper){
        helper.okPopup(component,event,helper);   
    },
    //EDGE-166185
    refreshProductConfig: function(component, event, helper){
        helper.fetchAllProductConfig(component, event, helper);
    },
    
    UpdateConfigAttdetail: function(component, event, helper){
        //this method is for updating inline pc from data table to schema attribute poc
       // alert('Inside UpdateConfigAtt>>>>');
        var Callfrom = 'Inline Table';
        helper.UpdateConfigAttribute(component, event, helper,Callfrom);
      
    },
    UpdatePortOutAttdetail: function(component, event, helper){
        //this method is for updating inline pc from data table to schema attribute in port out case EDGE-174219
        var Callfrom = 'Portout Tab';
        helper.UpdateConfigAttribute(component, event, helper,Callfrom);
    },
    setAttributeonParent : function(component, event, helper){
        helper.UpdateConfigAttributeOnAssignNumber(component, event, helper);
    }
    
})