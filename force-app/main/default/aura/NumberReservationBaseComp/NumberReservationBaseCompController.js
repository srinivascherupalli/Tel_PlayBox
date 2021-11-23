({
    
    doInit : function(component, event, helper) {
        helper.getCustomsettingValue(component, event);
        helper.initPC(component, event, helper); 
       // helper.fetchReservationPool(component, event, helper);
        
       
        //added for data table
		
        component.set('v.columns', [  
            {label: 'Mobile Plan', fieldName: 'PlanName', type: 'text'},
            {label: 'Model', fieldName: 'Model', type: 'text'},
            {label: 'Color', fieldName: 'Color', type: 'text'},
            {label: 'Number Assigned', fieldName: 'AssignedNumber', type: 'text'}
        ]);
		
        component.set('v.columnsNum',[
            {label: 'Available Number', fieldName: 'PhoneNumber', type: 'Integer', sortable:true ,initialWidth: 210},
            {label: 'Type', fieldName: 'Type', type: 'text',sortable:true, initialWidth: 65, },
            {label: 'Assignment Status', fieldName: 'ProdConfigName', cellAttributes:
                { iconName: { fieldName: 'statusIconName' }, iconPosition: 'right' }}
        ]);
    },
    setIcon: function (cmp, dataList) {
       // dataList you retrieved from server side callback or the data you want to display in the table
        dataList = dataList.map(function(rowData) {
            if (rowData.provenance === 'value') {
               rowData.provenanceIconName = 'utility:up';
               rowData.provenanceIconLabel = 'up';
            } else {
               rowData.provenanceIconName = 'utility:down';
               rowData.provenanceIconLabel = 'down';
           }
            return rowData;
        });
        cmp.set("v.dataList", dataList);
    },
    /*---------------------------------------------------------------------------------
     Story:EDGE-97392
     Author:Aishwarya
     Method:updateColumnSorting
     Description:Method to set field name to sort and direction
     -----------------------------------------------------------------------*/
    updateColumnSorting: function (component, event, helper) {
        console.log('In Column Sort');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    reserveSelected: function(component, event, helper){
        helper.SubmitReservationPool(component, event,helper, 'reserve');
    },
    removeSelected: function(component, event, helper){
        helper.SubmitReservationPool(component, event, helper,'unReserve');
    },
    
    addToReservationPoolAction: function(component, event, helper){
        helper.addToReservationPoolAction(component, event, 'unReserve');
    },
    
    //added for data table
    handleRowSelection: function (cmp, event) {
        console.log('in handler row');
        var selectedRows = event.getParam('selectedRows');
        var selectedPC=[];
        var selectedPCDetails=[];
        console.log('selectedRows',selectedRows);
        selectedRows.forEach(function(pc) {
            selectedPC.push(pc.configId);
            selectedPCDetails.push(pc);
        });
        //cmp.set('v.selectedRowsPC', selectedPC);
        cmp.set('v.selectedRowsPCDetails', selectedPCDetails);
        //EDGE-92546 - Added below line to set Quantity.
        if(selectedPCDetails !=[])
        cmp.set('v.quantity',selectedPCDetails[0].Quantity);
        
        
    },
    handleRowSelectionNum :function (cmp, event){
        console.log('in handleRowSelectionNum');
        var selectedRowsNum = event.getParam('selectedRows');
        var selectedNum=[];
        var selectedNumDetails=[];
        console.log(selectedRowsNum);
        selectedRowsNum.forEach(function(num) {
            selectedNum.push(num.numberId);
            selectedNumDetails.push(num);
        });
        console.log(selectedNum);
        //cmp.set('v.selectedRowsNum', selectedNum);
        cmp.set('v.selectedRowsNumDetails', selectedNumDetails);
    },   
    //EDGE-96503- Mahima 
    finishReservationComp: function (component, event,helper){
        helper.finishReservationhelper(component, event,helper);
    },
    //EDGE-96503- Mahima 
    removeAssignedNumber: function (component, event,helper){
        helper.removeAssignedNumber(component, event,helper);
    },
    
    handleRemoveEvent: function(component, event,helper){
        helper.handleRemoveEvent(component, event,helper);
    },
    /*tabSelected: function(component,event,helper) {
       
        var tabid=component.get("v.selTabId");
        component.set("v.selectedTabId",tabid)
       
    },*/
    
    //EDGE-89299,Finish button validation
	isFinished:function(component, event, helper){  
	 helper.isFinished(component, event,helper);
       
	},
    caValidation:function(component, event, helper){
	 helper.caValidation(component, event,helper);
	},
    
    //EDGE-59982,To display the data table info based on selected Tab
   handleChange: function(component,event,helper) {
        //Display content on tab
        var selected = component.get("v.tabId");
       console.log('selected: ',selected);
       //EDGE-92546 - Added below lines to set Selected subTab Name and set the CSS on ManageTab Selection
       var selectedSubTab = component.get("v.subTabId");
       console.log('selectedSubTab: ',selectedSubTab);
       if(selectedSubTab == 'manageTab'){
           component.set("v.classValue", 'slds-col slds-size_12-of-12');
       }else{
           component.set("v.classValue", 'slds-col slds-size_7-of-12');
       }
        component.find("tabs").set("v.selectedTabId", selected);
        helper.handleChange(component, event, helper);
       //added for data table
		if(selected=='Mobile'){
        component.set('v.columns', [  
            {label: 'Mobile Plan', fieldName: 'PlanName', type: 'text'},
            {label: 'Model', fieldName: 'Model', type: 'text'},
            {label: 'Color', fieldName: 'Color', type: 'text'},
            {label: 'Number Assigned', fieldName: 'AssignedNumber', type: 'text'}
        ]);
		}
		else if(selected=='Fixed'){
		component.set('v.columns', [  
            {label: 'Solution', fieldName: 'Solution', type: 'text'},
            {label: 'Name', fieldName: 'Model', type: 'text'},
            {label: 'Serial Number', fieldName: 'SerialNumber', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity', type: 'integer'}
        ]);
        }
       
    } ,
    
    //EDGE-117819 defect fix
    onTabActive:function(component,event,helper) {
        
        helper.fetchReservationPool(component,event,helper);
    },
    //EDGE-100662, popup validation
    cancelPopup:function(component,event,helper){
       component.set("v.isPopup",false);   
    },
    openPopup:function(component,event,helper){
        helper.openPopup(component,event,helper);
    },
    okPopup:function(component,event,helper){
        helper.okPopup(component,event,helper);
    },
     fixedPortInScreen:function(component,event,helper){
        /* var page="apex/FixedPortIn?BasketId="+component.get("v.basket_id")+"&NumberType="+component.get("v.tabId");
          console.log('page=='+page);     
         var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+page+""
        }); 
         homeEvt.fire(); */
         /*if(window.location.href.indexOf("partners") > -1) {
         window.open("/partners/apex/FixedPortIn?BasketId="+component.get("v.basket_id")+"&NumberType="+component.get("v.tabId"));
         }
        else{
            window.open("/apex/FixedPortIn?BasketId="+component.get("v.basket_id")+"&NumberType="+component.get("v.tabId"));
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
        	url = url + encodeURIComponent('/FixedPortIn?BasketId='+component.get("v.basket_id")+'&NumberType='+component.get("v.tabId"));
		 }else{
			 url = '/apex/FixedPortIn?BasketId='+component.get("v.basket_id")+'&NumberType='+component.get("v.tabId")
		 }
         window.open(url); 
        //return Promise.resolve(url);
         console.log('url>>>'+url);
     },

})