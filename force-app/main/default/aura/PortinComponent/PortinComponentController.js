({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);
	},
/*-------------------------------------------------------- 
EDGE		-144140
Method		-sort
Description	-sort by Port in ready
Author		-Kalashree
--------------------------------------------------------*/
    sort:function(component, event, helper) {
        var order = component.get("v.isSortAsc");
        var sortOrder ;
        if(order==false){
            sortOrder = 'asc'
        }
        else{
            sortOrder = 'dsc'
        }
        helper.sortData(component,'indicator',sortOrder);
        component.set("v.isSortAsc",!order);    
    },
    closeInfo : function(component, event, helper) {
		helper.closeInfo(component, event);
	},
    handleSampleEvent : function(component, event, helper) {
		helper.handleSampleEvent(component, event);
	},
    handleDisplay : function(component, event, helper) {
		helper.handleDisplay(component, event);
	},
	AddNewRow : function(component, event, helper) {
        var updatecount = component.get("v.showtotalRecords")+1;
        component.set("v.showtotalRecords",updatecount);
		helper.AddNewRow(component, event);
	},
    addNewRow : function(component, event, helper) {
		helper.addNewRow(component, event);
	},
     removeDeletedRow: function(component, event, helper) {
        helper.removeDeletedRow(component, event);
    },
    Save: function(component, event, helper) {
        helper.Save(component, event);        
    },
    deleteAllRows : function(component, event, helper) {
        var updatecount = component.get("v.showtotalRecords")-component.get("v.numberList").length;
        component.set("v.showtotalRecords",updatecount);
        console.log("deleteAllRows");
        helper.deleteAllRows(component, event);        
    }, 
    /*addToreservationPool : function(component, event, helper) {
        helper.addToreservationPool(component, event);        
    }, */
    
    buttonFunction:function(component,event,helper){
         component.set("v.isShowMobileport",true);
        //helper.buttonFunction(component, event);  
    },
    NavigateComponent:function(component,event,helper){
        helper.NavigateComponent(component, event);  
    },
    handleEvent:function(component,event,helper)
    {
    },
    handleCAFRefresh: function(component, event, helper){
    	console.log('in handleCAFRefresh portin');
	},
    /*EDGE-105438
	Author: Ila */
    removeReservationPool: function(component, event,helper){
        helper.getPortSelectionList(component,event,helper);
    },
    buttonFunctionPpv : function(component,event,helper){
        helper.buttonFunctionPpv(component, event);  
    },
      handlePPVEvent :function (component, event,helper) {
        helper.handlePPVEvent(component, event); 
        
    },
     handleSelectAllNumbers: function(component, event, helper) {
        helper.handleSelectAllNumbers(component, event);  
    },
     handleSelectAllNumbers1: function(component, event, helper) {
        helper.handleSelectAllNumbers1(component, event);  
    },
    changeData:function(component, event, helper){
        helper.changeData(component, event);
    },
     qualifyCallout : function(component, event, helper) {
        helper.qualifyCallout(component, event); 
    }, 
    handleCheckboxEvent : function(component, event, helper) {
        
        helper.handleCheckboxEvent(component, event); 
    },
    fixedPortInScreen:function(component, event, helper) {
        console.log('Inside fixedPortInScreen');
    	/*if(window.location.href.indexOf("partners") > -1) {
         	window.open("/partners/apex/FixedPortIn?BasketId="+component.get("v.basketId")+"&NumberType="+component.get("v.radioValue"));
         }
        else{
            window.open("/apex/FixedPortIn?BasketId="+component.get("v.basketId")+"&NumberType="+component.get("v.radioValue"));
        }*/
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
        	url = url + encodeURIComponent('/FixedPortIn?BasketId='+component.get("v.basketId")+'&NumberType='+component.get("v.radioValue"));
		 }else{
			 url = '/apex/FixedPortIn?BasketId='+component.get("v.basketId")+'&NumberType='+component.get("v.radioValue")
		 }
         window.open(url);
    	console.log('url>>>'+url);
    },
     handlecloseModal:function (component, event, helper){
        console.log('Inside handlecloseModal');
        var modalvalue = event.getParam("modalvalue");
        if(modalvalue == 'close'){
            helper.closeModal(component, event, helper);
        }
        
    },
    handleBulkUploadChange:function(component, event,helper) {
        helper.handleBulkUploadChange(component, event, helper);       
    }  
})