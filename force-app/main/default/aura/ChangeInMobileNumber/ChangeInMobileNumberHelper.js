({
    getColumnDefinitions: function () {
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
        },
                       {
                           label: 'Site Address',
                           fieldName: 'siteAddressLink',
                           type: 'url',
                           sortable: true,
                           typeAttributes: {
                               label: {
                                   fieldName: 'siteAddress'
                               },
                               target: '_blank'
                           }
                       },
                       {
                           label: 'ACCESS TYPE',
                           fieldName: 'accessType',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Subscription Number',
                           fieldName: 'subscriptionNumber',
                           type: 'text',
                           sortable: true
                       },
                       
                       {
                           label: 'Created Date',
                           fieldName: 'createdDate',
                           type: 'text',
                           sortable: true
                       },
                       {
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
                           label: 'Auto Reserve MSISDN',
                           fieldName: 'isBillStopped',
                           type: 'boolean'
                           
                       },
                       {
                           label: 'Created By',
                           fieldName: 'createdBy',
                           type: 'text',
                           sortable: true
                       },
                      ];
                       
                       return columns;
                       },
                       
                       redirectToAccountPage: function (component, accountId) {
						console.log('Redirect to account page');
                        //window.location.href = window.location.href;
                        //Added for EDGE-127942 by Shreya
                        var navigateEvent = $A.get("e.force:navigateToSObject");
                       	navigateEvent.setParams({
                           "recordId": accountId,
                           "slideDevName": "detail",
                       	});
                        navigateEvent.fire();
                        },
                        
                        //Shweta added EDGE:185521 Navigate to order page
                        redirectToOrderPage: function(comonent, orderId){
                            console.log('Redirect to order page');
                            var navigateEvent = $A.get("e.force:navigateToSObject");
                            navigateEvent.setParams({
                                "recordId": orderId,
                                "slideDevName": "detail",
                            });
                            navigateEvent.fire();
                        },
                       //added by Vamsi for DIGI-17914 04NOV2021 starts
    changeMobileNumberLogs : function(cmp,event,helper,orderid)
    {
        var accountId = cmp.get("v.accountId");
        var datetimeinmillisec = cmp.get("v.dateTimeMilliseconds");
        var orderId = orderid;
        var action=cmp.get("c.changeMobileNumberTransactionlogs");
        
        action.setParams({
            "accountId":accountId,
            "orderId":orderId,
            "datetimeinmillisec":datetimeinmillisec,
        });
        
        action.setCallback(this,function(response)
                           {
                               var state=response.getState();
                               console.log('state '+state); 
                               console.log('response '+response); 
                           });
        $A.enqueueAction(action);
    }
    //added by Vamsi for DIGI-17914 04NOV2021 starts
                        
                       })