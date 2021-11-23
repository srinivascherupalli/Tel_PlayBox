global class ManageCustomer {
   
    // Triggered from button
    WebService static void send(String accountId, Boolean isCrossRef) {
        System.debug('!@#$% Invoking ManageCustomer');

        // Query for account
        Account a = TCMUtil.getAccountByAccountId(accountId);
        
        if(!isCrossRef) {
            if(a.TCM_MasterID__c == null) {
                sendCreate(a);    
            } else {
               sendUpdate(a);  
            }    
        } else {
            sendCrossRef(a);
        }     
    }
    
    // Create Event
    private static void sendCreate(Account a) {
        System.debug('!@#$% Invoking ManageCustomer with create event');
        
        // Prepare and send request
        ManageCustomerHandler.sendManageCustomer(ManageCustomerHandler.generateManageCustomerRequest(a, ManageCustomerHandler.EVENT_ACTION_CREATE), ManageCustomerHandler.EVENT_ACTION_CREATE, a.Customer_ID__c);

        System.debug('!@#$% ManageCustomer request sent to TCM | Account ID : ' + a.Id);
    }

    // Update Event
    private static void sendUpdate(Account a) {
        System.debug('!@#$% Invoking ManageCustomer with update event');

        // Prepare and send request
        ManageCustomerHandler.sendManageCustomer(ManageCustomerHandler.generateManageCustomerRequest(a, ManageCustomerHandler.EVENT_ACTION_UPDATE), ManageCustomerHandler.EVENT_ACTION_UPDATE, a.Customer_ID__c);

        System.debug('!@#$% ManageCustomer request sent to TCM | Account ID : ' + a.Id);
    }

    // Cross Reference Event
    private static void sendCrossRef(Account a) {
        System.debug('!@#$% Invoking ManageCustomer with cross reference event');

        // Prepare and send request
        ManageCustomerHandler.sendManageCustomer(ManageCustomerHandler.generateManageCustomerRequest(a, ManageCustomerHandler.EVENT_ACTION_CROSSREF), ManageCustomerHandler.EVENT_ACTION_CROSSREF, a.Customer_ID__c);

        System.debug('!@#$% ManageCustomer request sent to TCM | Account ID : ' + a.Id);
    }

}