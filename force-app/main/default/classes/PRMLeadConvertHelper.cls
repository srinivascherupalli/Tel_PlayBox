/*
 * Author : Team Hawaii: Megha Agrawal
 * Description : Helper class to  be invoked from Flow 'Convert Lead'
 * Jira : P2OB - 26 
 * Created Date : 6-April-2020
*/
public without sharing class PRMLeadConvertHelper {

    /**
    * Description : Method to convert a lead record to an opportunity, to be invoked from Flow 'Convert Lead'.
                    This method take accountId, contactId and OpporunityName as required parameter and convert the lead  
    * Jira        : P2OB - 26 - Lead Conversion for PRM 
    **/
    @InvocableMethod
    public static List<FlowOutputParameter> convertLeadFromFlow(List<FlowInputParameter> flowInputs){ 
        //P2OB - 26 - capturning input parameters with the help of a wrapper 
        List<FlowOutputParameter> flowOutputs = new List<FlowOutputParameter>();
        
        Logger2 logger = Logger2.getLogger('PRMLeadConvertHelper.invoke');
        try{
            if(flowInputs.size() > 0){
                  // P2OB - 26 : calling mass Lead Convert
                  flowOutputs = massLeadConvert(flowInputs);
            }
            
            for(FlowOutputParameter flowOutput: flowOutputs ){
                 //P2OB - 26 : Save the error occurred during lead-conversion, if any 
                 if(!(String.isBlank(flowOutput.errorMessage)))
                     logger.logMessages('PRMLeadConvertHelper:convertLeadFromFlow', 'Error occured in apex action', flowOutput.errorMessage, '', '', '', false, false);
            }
        }   
        catch(exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            system.debug('e.getMessage'+e.getMessage());
            //P2OB - 26 : Save the error occurred during lead-conversion, if any 
            FlowOutputParameter flowOutput = new FlowOutputParameter();   
            flowOutput.errorMessage = e.getMessage();
            flowOutputs.add(flowOutput);
            
        }
        finally{
            logger.exitLogger();            
        }
        
        return flowOutputs;
    }
    
    /**
    * Description : Mass Lead Convert - Bulk handling 
    * Jira : P2OB-26- PRM Lead Conversion 
    **/
    private static List<FlowOutputParameter> massLeadConvert(List<FlowInputParameter> flowInputs){
        List<FlowOutputParameter> flowOutputs = new List<FlowOutputParameter>();
        List<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        for(FlowInputParameter flowInput : flowInputs){
            if(flowInput.leadId != null){
                //P2OB-26 : preparing LeadConvert record 
                leadConverts.add(convertLead(flowInput));
            }
        }
    
        if(!leadConverts.isEmpty()){
            //P2OB-26 : converting the lead 
            List<Database.LeadConvertResult> lcrList = Database.convertLead(
                leadConverts, false);
            for(Database.LeadConvertResult lcr : lcrList){
                FlowOutputParameter flowOutput = new FlowOutputParameter();
                //P2OB-26 : checking convert lead result
                if (lcr.isSuccess()) {
                    flowOutput.convertedOpportunityId = lcr.getOpportunityId();
                }else {
                 flowOutput.errorMessage =  'Error :'+lcr.getErrors()[0].getMessage();
                 system.debug('Error'+lcr.getErrors()[0].getMessage());
                }
                flowOutputs.add(flowOutput);
            }
        }
        return flowOutputs;
    }
    
    
    /**    
     * Description : Convert Lead - prepare LeadConvert record
     * Jira : P2OB-26 - PRM Lead Conversion 
     */
    private static Database.LeadConvert convertLead(FlowInputParameter flowInput) {
         //P2OB-26 : Perform the lead conversion using standard salesforce API
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(flowInput.leadID);
        lc.setConvertedStatus(flowInput.convertedStatus);
        //P2OB-26 : set account Id
        if (flowInput.accountId != null && flowInput.accountId.length() > 0) 
            lc.setAccountId(flowInput.accountId);
        //P2OB-26 : set contact Id
        if (flowInput.contactId != null && flowInput.contactId.length() > 0) 
            lc.setContactId(flowInput.contactId);
        //P2OB-26 : set opportunity Name
        if (flowInput.opportunityName != null) {
            lc.setOpportunityName(flowInput.opportunityName);
        }
        //P2OB-26 : set Owner Id
        if(flowInput.ownerId != null && flowInput.ownerId.length() > 0){
            lc.setOwnerId(flowInput.ownerId);
        }
        //P2OB-26 : send notification to owner when successfully converted
        if(flowInput.isSendNotificationToOwner != null && flowInput.isSendNotificationToOwner == true){
            lc.setSendNotificationEmail(flowInput.isSendNotificationToOwner);
        }
        return lc;
    }
      
    
    /**    
     * Description : Wrapper class to hold input parameters received from flow 'Convert Lead'
     * Jira : P2OB-26 - PRM Lead Conversion 
     */
    public Class FlowInputParameter{
        @InvocableVariable
        public String leadId;
        @InvocableVariable
        public String accountId;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String opportunityName;
        @InvocableVariable
        public String convertedStatus;
        @InvocableVariable 
        public String ownerId;
        @InvocableVariable
        public Boolean isSendNotificationToOwner;
        @InvocableVariable 
        public String loggedInUser;
    }
    
    /**    
     * Description : Wrapper class to hold output parameters sent to flow 'Convert Lead'
     * Jira : P2OB-26 - PRM Lead Conversion 
     */
    public Class FlowOutputParameter{
        @InvocableVariable
        public String convertedOpportunityId;
        @InvocableVariable
        public String errorMessage = '';
        
    }
    
}