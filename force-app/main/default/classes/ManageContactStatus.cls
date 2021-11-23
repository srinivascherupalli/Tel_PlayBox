@RestResource(urlMapping='/ManageContactStatus/*')
global with sharing class ManageContactStatus {
 
    @HttpPost
    global static ManageContactStatusResponse doPost(ManageContactStatusRequest request) {
        System.debug('!@#$% ManageContactStatusRequest received : ' + request);

        // Read request & persist exception received
        Exception__c exc = mapRequestToException(request);
        if(exc != null){
        	insert exc;    
        }
        
        // Send Response
        ManageContactStatusResponse response = new ManageContactStatusResponse();
        response.Data = '';
        response.Status = 'Success';
        response.StatusCode = 200;
        response.ErrorCode = null;
        response.Message = 'contact status received';
        
        return response;
    }
    
    private static Exception__c mapRequestToException(ManageContactStatusRequest req) {
     Set<string> check= new Set<string>{'BTC0016','BTC0019','BTC0018','BTC0017','BTC0036','BTC0119','BTC0120','BTC0121'};
        Exception__c e = new Exception__c();
        if(req != null) {
            if(req.data != null) {
                if(req.data.fault != null) {
                	e.Fault_Code__c = req.data.fault.faultCode;
                    e.Fault_String__c = req.data.fault.faultString;
                    e.Fault_Actor__c = req.data.fault.faultActor;
                    e.Server_Name__c = req.data.fault.serverName;
                    e.Process_Id__c = req.data.fault.processId;
                    e.Thread_Id__c = req.data.fault.threadId;
                    e.Program_Name__c = req.data.fault.programName;
                    e.Program_Location__c = req.data.fault.programLocation;
                    e.Time_Stamp__c = req.data.fault.timestamp;
                    e.Initiating_Entity_Id__c = req.data.fault.initiatingEntityId;
                    e.Program_Status_Code__c = req.data.fault.programStatusCode;
                    e.Program_Status_Description__c = req.data.fault.programStatusDescription;
                    e.Program_Fault_Id__c = req.data.fault.programFaultId;
                    e.Program_Fault_Description__c = req.data.fault.programFaultDescription;
                    e.Fault_Category__c = req.data.fault.faultCategory;
                    e.Entity_Name__c = req.data.fault.entityName;
                    e.Entity_Value__c = req.data.fault.entityValue;
                    e.Status__c = 'Unresolved';

                    Contact c = getContactById(req.data.fault.entityValue);
                    if(c != null){
                    	e.Contact_with_Exception__c = req.data.fault.entityValue; 	   
                    }
                    if(check.contains(req.data.fault.faultCode))
                    {
                        Case cs=new Case();
                        cs.Status= 'Open';
                        cs.Description=req.data.fault.faultString;
                        cs.Subject='Exception Occured:'+req.data.fault.faultCode;
                        cs.OwnerId= c.OwnerId;
                        insert cs;
                    }
                    return e;	    
                }
            }
        }    

        return null;

    }
	
    private static Contact getContactById(String contactId) {
        List<Contact> contList = [SELECT Id,OwnerId, Name FROM Contact WHERE Id = :contactId];
        if(!contList.isEmpty()){
            return contList.get(0);
        } else {
            return null;
        }
    }
}