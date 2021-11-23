({
	searchNumbers: function(component, event, helper)
    {
        component.set('v.columnsNumNew',[
            {initialWidth: 100},
            {label: 'Available Number', fieldName: 'numberList', type: 'Integer', initialWidth: 300}
           
        ])
        helper.searchNumbers(component, event);
    },
    reserveNumbers: function(component, event, helper){
        helper.reserveNumbers(component, event);
    },
    handleEvent:function()
    {
        
    },
    autoReserve:function(component, event, helper){
        helper.autoReserve(component, event,helper);
    },
     doInit : function(component, event, helper) {
         //var tabId=component.get('V.selectedTabId');
         helper.doInit(component, event);
         //alert(tabId);
        
    },
    handleRowSelectionNew: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');       
        var selectedNUMDetails=[];
        //console.log(selectedRows);
        selectedRows.forEach(function(pc) {
            
            selectedNUMDetails.push(pc);
        });
        //console.log(selectedNUMDetails);
        
        component.set('v.SelectedNumNew', selectedNUMDetails);
    },
    ResetForm: function(component, event, helper) {
        helper.clearForm(component, event);
    },
   searchNumbersFNN: function(component, event, helper)
    {
         
        component.set('v.columnsNumNew',[
            {initialWidth: 100},
            {label: 'Available Number', fieldName: 'numberList', type: 'Integer', initialWidth: 300}
           
        ])
        helper.searchNumbersFNN(component, event);
    },
    /* EDGE-100661 -start*/
    addAddress:  function(component, event, helper) {
       helper.addAddress(component, event, helper);

        },
    /*EDGE-100661-END*/
    reserveFNNNumbers: function(component, event, helper){
        helper.reserveFNNNumbers(component, event);
    },
    /* EDGE-100661 -start*/
    changeAddrRadio : function(component, event, helper) {
        let id = event.getSource().getLocalId();
        if(id == 'area'){
            component.set("v.enableAreaCode", true);
            let addrComp = component.find("addrComp");
 			addrComp.clearSelection();
        }else{
            component.set("v.enableAreaCode", false);
            component.find("AreaCode").set("v.value", '');
        }
    },
    /*EDGE-100661-END*/
     /*------------------------------------------------------
     * EDGE-126317
     * Method: renderPatternTypeOptions
     * Description: Method to validate number reservation for NgUc
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
     renderPatternTypeOptions: function(component, event, helper){
        helper.renderPatternTypeOptions(component, event);
    },
})