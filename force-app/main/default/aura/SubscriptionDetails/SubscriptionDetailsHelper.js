({
    getColumnDefinitions: function (comp) {
            var columns = [{
            label: 'SUBSCRIPTION NAME',
            fieldName: 'subscriptionNameLink',
            type: 'url',
            //initialWidth: 150,
            typeAttributes: {
                label: {
                    fieldName: 'subscriptionName'
                },
                target: '_blank'
           			 }
        			},
                       {
                           label: 'Subscription Number',
                           fieldName: 'subscriptionNumber',
                           type: 'text',
                          // initialWidth: 150
                       },
                           {
                           label: 'Status',
                           fieldName: 'status',
                           type: 'text',
                          // initialWidth: 100
                       },
                             {
                           label: 'CreatedDate',
                           fieldName: 'createdDate',
                           type: 'text',
                          // initialWidth: 100
                             },{
                           label: 'Site Address',
                           fieldName: 'siteAddress',
                           type: 'text',
                          // initialWidth: 100
                       },
                         {
                         label: 'Service Id',
                           fieldName: 'ServiceId',
                           type: 'text',
                           //initialWidth: 100
                       },
                           {
                           label: 'Access Type',
                           fieldName: 'accessType',
                           type: 'text',
                          // initialWidth: 100
                       }, {
                           label: 'Total Recurring Charge',
                           fieldName: 'totalRC',
                           type: 'text',
                          // initialWidth: 100
                       },{
                           label: 'Billing Account',
                           fieldName: 'billingAccount',
                           type: 'text',
                           //initialWidth: 100
                       },
                          {
                           label: 'Created By',
                           fieldName: 'createdBy',
                           type: 'text',
                           //initialWidth: 100
                       },];
                       return columns;
                       }
                        })