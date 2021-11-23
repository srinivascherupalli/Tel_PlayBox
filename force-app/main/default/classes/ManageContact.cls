global class ManageContact {

    WebService static void send(String contactId, Boolean isCrossRef) {
        System.debug('!@#$% Invoking ManageContact');

        // Query for contact
        Contact c = TCMUtil.getContactBySalesforceContactId(contactId);

        if(!isCrossRef) {
            if(c.UUID__c == null) {
                sendCreate(c);    
            } else {
               sendUpdate(c);  
            }    
        } else {
            sendCrossRef(c);
        }
         
    }

    private static void sendCreate(Contact c) {
        System.debug('!@#$% Invoking ManageContact with create event');
		List<ManageContactDAO> manageContacts=new List<ManageContactDAO>();
        manageContacts.add(new ManageContactDAO(c,ManageContactHandler.EVENT_ACTION_CREATE));
        // Prepare and send request
        String manageContactSerializedObj = JSON.serialize(manageContacts); 
       
        ManageContactHandler.sendmanageContactList(manageContactSerializedObj);
             
        //ManageContactHandler.sendManageContact(ManageContactHandler.generateManageContactRequest(c, ManageContactHandler.EVENT_ACTION_CREATE), ManageContactHandler.EVENT_ACTION_CREATE, c.UUID__c);   

        System.debug('!@#$% ManageContact request sent to TCM | Contact ID : ' + c.Id);
    }

    public static void sendUpdate(Contact c) {
        
        
        // Prepare and send request
        System.debug('!@#$% Invoking ManageContact with update event');
		List<ManageContactDAO> manageContacts=new List<ManageContactDAO>();
        manageContacts.add(new ManageContactDAO(c,ManageContactHandler.EVENT_ACTION_UPDATE));
        // Prepare and send request
        String manageContactSerializedObj = JSON.serialize(manageContacts); 
       
        ManageContactHandler.sendmanageContactList(manageContactSerializedObj); 
        
        //ManageContactHandler.sendManageContact(ManageContactHandler.generateManageContactRequest(c, ManageContactHandler.EVENT_ACTION_UPDATE), ManageContactHandler.EVENT_ACTION_UPDATE, c.UUID__c);   

        System.debug('!@#$% ManageContact request sent to TCM | Contact ID : ' + c.Id);
    }

    public static void sendCrossRef(Contact c) {
        System.debug('!@#$% Invoking ManageContact with create event');
        
        
        System.debug('!@#$% Invoking ManageContact with update event');
		List<ManageContactDAO> manageContacts=new List<ManageContactDAO>();
        manageContacts.add(new ManageContactDAO(c,ManageContactHandler.EVENT_ACTION_CROSSREF));
        // Prepare and send request
        String manageContactSerializedObj = JSON.serialize(manageContacts); 
       
        ManageContactHandler.sendmanageContactList(manageContactSerializedObj);
        System.debug('!@#$% ManageContact request sent to TCM | Contact ID : ' + c.Id);
    }
        
}