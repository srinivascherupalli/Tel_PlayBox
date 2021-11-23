({
    //EDGE -66472/84934/66471, initialise component
    doInit: function(component, event){
        var d = new Date();       
        d.setDate(d.getDate() + 180);    
        var dd = d.getDate();
        var mm = d.getMonth() + 1; //January is 0!
        var yyyy = d.getFullYear();
        if (dd < 10) {
          dd = '0' + dd;
        } 
        if (mm < 10) {
          mm = '0' + mm;
        } 
		var todatemax = yyyy + '-' + mm + '-' + dd;  
        //alert('todatemax==>'+todatemax);
        component.set('v.toDatemax',todatemax);
        
        var action = component.get("c.getRescheduleInitiator");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var testdata=['--None--'];
                var options = response.getReturnValue();
                component.set("v.options",options);
                component.set("v.optionsReason",testdata);
            }
        });
        $A.enqueueAction(action);        
        
    },
    //EDGE -66472/84934/66471, Action on reason change
    onReasonChange:function(component, event){
        var reason = event.getSource().get("v.value");
        component.set("v.RescheduleReason",reason);            	
    },
    //EDGE -66472/84934/66471, Action on select
    onSelection: function(component, event){
        var myval = event.getSource().get("v.value");
        component.set("v.RescheduleInitiator",myval);	
        var action = component.get("c.getRescheduleReason");
        action.setParams({"initiatedBY" : myval});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var options = response.getReturnValue();
                component.set("v.optionsReason",options);
            }
        });
        $A.enqueueAction(action);  
        
        
    },
    //EDGE -66472/84934/66471, Display slots
    handleShowSlots: function(component, event){
        var Isvalidform= true;
        var errorMsg='';
        var appid=component.get("v.AppID");
        var startDateStr= component.get("v.startDateSelected");
        var endDateStr= component.get("v.toDate");       
        var action = component.get("c.SearchAppointmentSlots");
        var subId=component.get("v.SubID");
        var initiator= component.get("v.RescheduleInitiator");
        var reason=component.get("v.RescheduleReason");
        
        var operation=component.get("v.OperationName");
        if(operation=='Reschedule')
        {
            if(initiator== '--None--' || reason== '--None--' )
            {
                Isvalidform= false;
                errorMsg='Initiated By and Reason for Rescheduling are mandatory for search.';
            }
            else if( startDateStr==null)
            {
                Isvalidform= false;
                errorMsg='Start date is mandatory for search.';
            }
        }
        else
        {
            if( startDateStr== null)
            {
                Isvalidform= false;
                errorMsg='Start date is mandatory for search.';
            }
        }
        if(Isvalidform)
        {
            
            component.set("v.loadingSpinner", true);
            var searchObj={
                'subsID': subId,
                'operation': component.get("v.OperationName"),
                'startDate': startDateStr,
                'endDate':  endDateStr ,
                'parentApptId':appid,
                'selectedRescheduleInitiator':initiator,
                'selectedRescheduleReason':reason,
                'Category':  component.get("v.Category") 
            };
            console.log('searchObj',searchObj);
            action.setParams({"searchObj" : searchObj});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    var slotWrapList = response.getReturnValue();
                    if(slotWrapList.length==0)
                    {
                        component.set("v.loadingSpinner", false);
                        this.showToast(component, 'Error !','No slots available for selected date range.')
                        
                    }
                    else
                    { 
                         this.startTimer(component);
                       //  var tCmp1 = component.find("expiredMsg");               
        				//$A.util.removeClass(tCmp1,'slds-hide');
                        component.set("v.slotWrapList",slotWrapList);
                        var toggleCmp = component.find("detailsSection");                
                        $A.util.removeClass(toggleCmp,'slds-hide'); 
                       
                        
                        //this.startTimer(component);
                        component.set("v.loadingSpinner", false);
                        
                    }
                } else {
                    var errors = response.getError();  
                    
                }
            });
            $A.enqueueAction(action);   
        }
        else
        {
            component.set("v.loadingSpinner", false);
            this.showToast(component, 'Error !',errorMsg);
        }
    },
    //EDGE -66472/84934/66471, Display messages
    showToast : function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            //mode: 'sticky',
            duration : 5000,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    //EDGE -66472/84934/66471, Action on close operation
    doCloseOperation: function(component, event, helper){
        
        var toggleCmp = component.find("successPopupSection");               
        $A.util.addClass(toggleCmp,'slds-hide');
        var toggleCmp1 = component.find("detailsSection");                
        $A.util.addClass(toggleCmp1,'slds-hide');
        var toggleShow = component.find("showAvailability");                
        $A.util.removeClass(toggleShow,'slds-hide');
        var appEvent = $A.get("e.c:searchAppointment");
        appEvent.setParams({"OperationName" : 'Back' });
        component.set("v.toDate","");
        appEvent.fire();
        
    },
    //EDGE -66472/84934/66471, Event on confirm button click
    onConfirmComplete:function(component, event, helper){
        var params = event.getParams();
        component.set("v.SelectedSlot",params.slotKey);       
        var dateVal=params.startDateSlot;        
        component.set("v.dateidentifier",dateVal);         
        component.set("v.slottime",params.slotTime);       
        var confirmBtn=document.getElementsByClassName('btn_'+dateVal);
        confirmBtn[0].removeAttribute("disabled");            
    },
    //EDGE -66472/84934/66471, Confirm appointment
    handleConfirmAppt: function(component, event){
        var subId=component.get("v.SubID");
        var SlotStr=component.get("v.slottime");
        var timebreak=SlotStr.split('to');
        var identifier=component.get("v.dateidentifier");
        var dateValue=component.get("v.dateidentifier").split(','); 
        var startDateStr= dateValue[0].trim()+' '+timebreak[0].trim() ;
        var endDateStr=dateValue[0].trim() +' '+timebreak[1].trim();
        var appid=component.get("v.AppID");
        var operation=component.get("v.OperationName");
        var slotid = component.get("v.SelectedSlot");
        var category = component.get("v.Category") ;
        var notes =document.getElementsByClassName('notes_'+identifier);
        
        var searchObj={
            'subsID': subId,
            'operation': operation,
            'startDate': startDateStr,
            'endDate':  endDateStr ,
            'slotId':slotid,
            'parentApptId':appid,
            'notes':notes[0].value,
            'Category':  component.get("v.Category") 
        }; 
        console.log('searchObj:',searchObj);
        component.set("v.loadingSpinner", true);
        var action = component.get("c.confirmAppointment");     
        
        action.setParams({"searchObj" : searchObj});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.code==null)
                {
                    component.set('v.responseWrapper',result); 
                    
                    var toggleCmp = component.find("successPopupSection");               
                    $A.util.removeClass(toggleCmp,'slds-hide');
                    var toggleCmp1 = component.find("detailsSection");                
                    $A.util.addClass(toggleCmp1,'slds-hide');
                    var toggleShow = component.find("showAvailability");                
                    $A.util.addClass(toggleShow,'slds-hide');
                    component.set("v.loadingSpinner", false);
                }
                else
                {
                    component.set("v.loadingSpinner", false);
                    this.showToast(component, 'Error !',result.code)
                }
                
            }            
            else {
                component.set("v.loadingSpinner", false);
                var errors = response.getError();
                this.showToast(component, 'Error !',errors)
                
            }
        });
        $A.enqueueAction(action);   
        
    },
    //EDGE -66472/84934/66471, handle event
    handleEvent : function(component, event, helper) {
        var name =event.getParam("OperationName");// getting the value of event attribute
        component.set("v.OperationName",name);  
    },
    //EDGE -66472/84934/66471, Timer to hide slots after 5 mins 
    startTimer : function(component) {
        var minutes = 0;
        var duration = 60 * 5;
        var seconds = 0;
        var timer = duration, minutes, seconds;
        setInterval(function () {
            minutes = parseInt(timer / 60, 10);
            seconds = parseInt(timer % 60, 10);
            
            minutes = minutes < 10 ? "0" + minutes : minutes;
            seconds = seconds < 10 ? "0" + seconds : seconds;
            var timeLeft = minutes + ":" + seconds;
          
             var toggleCmp = component.find("timerBlock");               
        		$A.util.addClass(toggleCmp,'slds-show');
            if (--timer < 0) {
                for(var i=0; i<10000; i++)
                {
                    window.clearInterval(i);
                }
                // switchOffTimer();
              
            }
            var notify = 'Please select a slot within '+timeLeft+' minutes!';
              window.clearInterval(timer);
            //component.set("v.timeLeft", timeLeft);
            component.set("v.timeLeft", timeLeft);
            component.set("v.timerPretext", 'Please select a slot within ');
            component.set("v.timerPosttext", ' minutes!');
            if(timer<0){
              // var toggleCmp = component.find("timerBlock");               
        		//$A.util.addClass(toggleCmp,'slds-hide'); 
        		 var tCmp1 = component.find("expiredMsg");               
        		$A.util.removeClass(tCmp1,'slds-hide');
                 var toggleCmp = component.find("detailsSection");               
        		$A.util.addClass(toggleCmp,'slds-hide');
                // this.showToast(component, 'Error !','No slots available for selected date range.');
            }
             
        }, 1000);
    },
    //EDGE -66472/84934/66471, date picker
    scriptsLoaded: function(component, event, helper) {
        $(document).ready(function(){ 
          //Restrict past date selection in date picker  
           $( "#datepickerId" ).datepicker({                   
                   dateFormat:"dd/mm/yy",
                    minDate: startDate,
                    maxDate: '+180D',   
                    onSelect: function () {
                           $('#toDatemax').val(this.value);
                            //alert($('#toDate').val());
                       }                    
                });
			});
		}
    
})