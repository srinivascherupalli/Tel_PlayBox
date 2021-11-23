({
    getColumnDefinitions: function (comp) {
        //var columnsWidths = this.getColumnWidths();
        //EGDGE-87725 UX Changes for changing order of showing fields
        
        var columns = [{
            label: 'SUBSCRIPTION NAME',
            fieldName: 'subscriptionNameLink',
            type: 'url',
            sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'subscriptionName'
                },
                target: '_blank'
            }
        },{
            label: 'Status',
            fieldName: 'status',
            type: 'text',
            sortable: true
        },
        {
            label: 'Service Id',
            fieldName: 'ServiceId',
            type: 'text',
            sortable: true
        },
        {
            label: 'Subscription Number',
            fieldName: 'subscriptionNumber',
            type: 'text',
            sortable: true
        },
        
        
        
        
    ];
    
    
    return columns;
},
redirectToAccountPage: function (component, accountId) {
    console.log('Before Redirect');
    var url=JSON.stringify(window.location.href);
    //Added chanegs for EDGE-181461: Orders Suspend and Resume ,to handle prm url
    if(url.includes('partners.enterprise.telstra.com.au'))
    {  //PRM PROD URL
        
        window.open( location.protocol + '//' + location.host + '/' + accountId, '_self');
        console.log('Inside PRM PROD');
    }
    ////Added chanegs for EDGE-181461: Orders Suspend and Resume	
    else if (url.includes('/partners/'))
    {//PRM Sandbox URL
        window.open( location.protocol + '//' + location.host + '/partners/' + accountId, '_self');
        console.log('Inside PRM ');
    }
    else
    {
        window.location.href = '/' + accountId;
    }
    
    
},

// Shweta added this method : EDGE:185521
redirectToOrderPage: function (component, orderId) {
    console.log('Before Redirect');
    var url=JSON.stringify(window.location.href);
    //Added chanegs for EDGE-181461: Orders Suspend and Resume ,to handle prm url
    if(url.includes('partners.enterprise.telstra.com.au'))
    {  //PRM PROD URL
        
        window.open( location.protocol + '//' + location.host + '/' + orderId, '_self');
        console.log('Inside PRM PROD');
    }
    ////Added chanegs for EDGE-181461: Orders Suspend and Resume	
    else if (url.includes('/partners/'))
    {//PRM Sandbox URL
        window.open( location.protocol + '//' + location.host + '/partners/' + orderId, '_self');
        console.log('Inside PRM ');
    }
    else
    {
        window.location.href = '/' + orderId;
    }
    
    
},

//Start of DIGI-17910 added by Gautam Kumar
insertTransactionLogs_HelperEntry: function(component, accountId, orderType){
    
    let insertLogAction = component.get("c.insertTransactionLogs");
    
    insertLogAction.setParams({
        accountId : accountId,
        orderType : orderType,
        orderId : '',
        correlationId : '' 
    });
    insertLogAction.setCallback(this, function(response) {
        let state = response.getState();
        let res = response.getReturnValue();
        
        if(state === 'SUCCESS'){
            console.log('res value G*G ', res);
            component.set("v.correlationId", res);
        }
        else {
            
        }
        
    });
    $A.enqueueAction(insertLogAction); 
    
},

insertTransactionLogs_HelperExit: function(component, accountId, orderType, orderId, correlationId){
    
    let insertLogAction = component.get("c.insertTransactionLogs");
    
    insertLogAction.setParams({
        accountId : accountId,
        orderType : orderType,
        orderId : orderId,
        correlationId : correlationId 
    });
    insertLogAction.setCallback(this, function(response) {
        let state = response.getState();
        let res = response.getReturnValue();
        
        if(state === 'SUCCESS'){
            console.log('res value G*G after exit ', res);
            //component.set("v.correlationId", res);
        }
        else {
            
        }
        
    });
    $A.enqueueAction(insertLogAction); 
    
}
//End of DIGI-17910 added by Gautam Kumar



})