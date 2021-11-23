({
    //EDGE -66472/84934/66471, Initialise component
    initOrder: function(component, event, helper){
    var action = component.get("c.getOrder");
		action.setParams({"orderId": component.get("v.recordId")});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.order", response.getReturnValue());
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE -66472/84934/66471, fetch subscriptions w.r.t. order
    fetchSubs : function(component, event, helper) {
        var action = component.get("c.getSubsList");
        action.setParams({"orderId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var wrapperList = response.getReturnValue();
                component.set("v.wrapperList",wrapperList);
                //console.log(wrapperList);
            }
            else {
            }
        });
        $A.enqueueAction(action);
        },
    //EDGE -66472/84934/66471, fetch required appointments
    fetchReqApp: function(component, event, helper){
        var action = component.get("c.getReqAppList");
         action.setParams({"orderId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var reqWrapList = response.getReturnValue();
                component.set("v.reqWrapList",reqWrapList);
                 component.set("v.totalAppt",reqWrapList.length);
                 console.log('wrapperList',reqWrapList);
            }
            else {
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE -66472/84934/66471, Action on schedule
       handleSchedule:function(component, event)
    {
        var Idval=event.target.id;  
        var subsDetails=Idval.split('_');
        var nameval= event.target.name;
        var nameArr=nameval.split('_');
        var appEvent = $A.get("e.c:searchAppointment");
        appEvent.setParams({"OperationName" : 'Schedule' });
        appEvent.setParams({"SubID" : subsDetails[0] });
        appEvent.setParams({"SiteName" : subsDetails[1] });
        appEvent.setParams({"SiteAddress" : subsDetails[2] });
        appEvent.setParams({"Category" : nameArr[0]});
        appEvent.setParams({"startDate" : nameArr[1]});
        appEvent.fire();         
       
    },
    //EDGE -66472/84934/66471, Action on Reschedule, Rebook
    handleReScheduleRebook:function(component, event)
    {
        
		var Idval=event.target.id; 
        var buttonClicked= Idval.split('_');
        var nameval= event.target.name;
        var nameArr=nameval.split('_');
        var appEvent = $A.get("e.c:searchAppointment");
        if(buttonClicked[1]=='Reschedule')
        appEvent.setParams({"OperationName" : 'Reschedule' });
        else if(buttonClicked[1]=='Rebook')
        appEvent.setParams({"OperationName" : 'Rebook' });
        appEvent.setParams({"AppID" : buttonClicked[0] });
        appEvent.setParams({"SubID" : buttonClicked[2] });
        appEvent.setParams({"SiteName" : buttonClicked[3] });
        appEvent.setParams({"SiteAddress" : buttonClicked[4] });
        appEvent.setParams({"Category" : nameArr[0]});
        appEvent.setParams({"startDate" : nameArr[1]});
        appEvent.fire();          
    },   
    //EDGE -66472/84934/66471, Event after search
    searchedCompletedAction: function(component, event){
        var params = event.getParams();
        component.set("v.OperationName",params.OperationName);
        component.set("v.SiteName",params.SiteName);
        component.set("v.SiteAddress",params.SiteAddress);
       
        if(params.OperationName=='Schedule')
        {
             this.toggleScreen(component, event);
            //EDGE-89857
             component.set("v.OperationNameLabel",params.OperationName +' an');
             component.set("v.SubID",params.SubID);
             component.set("v.Category",params.Category);  
            component.set("v.startDate",params.startDate); 
            component.set("v.startDateMin",params.startDate); 
            //added for fix of- EDGE-103647-->
            this.getStartDateMax(params.startDate,component);
        }
        else if (params.OperationName=='Reschedule' || params.OperationName=='Rebook')
        {
            component.set("v.OperationNameLabel",params.OperationName );
            component.set("v.SubID",params.SubID);             
            component.set("v.AppID",params.AppID);
            component.set("v.Category",params.Category); 
            component.set("v.startDate",params.startDate); 
            component.set("v.startDateMin",params.startDate);
            //added for fix of- EDGE-103647-->
            this.getStartDateMax(params.startDate,component);
            this.toggleScreen(component, event);
        }
        else if(params.OperationName=='Back')
        {
            this.initOrder(component, event, helper);
        	this.fetchSubs(component, event, helper);
        	this.fetchReqApp(component, event, helper);
            this.helperShowSaveProgressButton(component, event, helper);
            var toggleCmp = component.find("searchSection");               
            $A.util.addClass(toggleCmp,'slds-hide');
            var toggleCmp = component.find("listApptSection");               
            $A.util.removeClass(toggleCmp,'slds-hide');
        }
        
    },
    //EDGE -66472/84934/66471, Action for toggling between screens
    toggleScreen: function(component, event){
     	var toggleCmp = component.find("searchSection");               
        $A.util.removeClass(toggleCmp,'slds-hide');
        var toggleCmp = component.find("listApptSection");               
        $A.util.addClass(toggleCmp,'slds-hide');
},
     //EDGE -66472/84934/66471, Action to close popup
     closePop : function(component, event, helper) {
        var Idval=event.currentTarget.id;
        var cmpTarget= document.getElementsByClassName(Idval);
        cmpTarget[0].classList.add("slds-hide");
        cmpTarget[0].classList.remove("slds-show");

},
    //EDGE -66472/84934/66471, Action to open popup
     openPop : function(component, event, helper) {
        var Idval=event.target.id; 
        var cmpTarget= document.getElementsByClassName(Idval);
        cmpTarget[0].classList.add("slds-show");
        cmpTarget[0].classList.remove("slds-hide");

},
    //added for fix of- EDGE-103647-->
    getStartDateMax: function(startDate,component)
    {
       //var d=startDate;
       // alert('startdate ='+startDate);
        var d =  new Date(startDate);       
        d.setDate(d.getDate()+ 180);    
        var dd = d.getDate();
        var mm = d.getMonth() + 1; //January is 0!
        var yyyy = d.getFullYear();
        if (dd < 10) {
          dd = '0' + dd;
        } 
        if (mm < 10) {
          mm = '0' + mm;
        } 
		var sdatemax = yyyy + '-' + mm + '-' + dd; 
        //alert(sdatemax);
        component.set('v.startDatemax',sdatemax);  
    },
    helperShowSaveProgressButton:function(component, event, helper){
      var action = component.get("c.showSaveProgressButton");
      action.setParams({"orderId": component.get("v.recordId")});
       action.setCallback(this, function(response) {
        var state = response.getState();
        if(state === "SUCCESS") {
        component.set("v.showProgressButton", response.getReturnValue());
    } 
           else if (state==="ERROR") {
               var errorMsg = action.getError()[0].message;
               console.log(errorMsg);
           }
     });
    $A.enqueueAction(action);
    },
    helperSaveProgress:function(component,helper){
        var action1 = component.get("c.changeOrderStatus");
        action1.setParams({"orderId": component.get("v.recordId")});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.showProgressButton",false)
                component.set("v.showMessage",true);
                setTimeout(function(){
                    $A.get("e.force:closeQuickAction").fire();
                }, 2000);
                $A.get('e.force:refreshView').fire();
            } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        }); 
    $A.enqueueAction(action1); 
    }
})