/**
* Description : Apex Action to be invoked from flows. This apex class will create and send a list of emailMessages using flow-inputs.                   
* Jira        : P2OB - 8405
* Author      : Team Hawaii : Ritika Jaiswal
* Date        : 13-July-2020 
**/

public without sharing class PRMMassEmailPlugin {
    
    @InvocableMethod
    public static List<FlowOutputParameter> sendMassEmail(List<FlowInputParameter> flowInputs){
        List<FlowOutputParameter> flowOutputs = new List<FlowOutputParameter>();
        Logger2 logger = Logger2.getLogger('PRMMassEmailPlugin');                  
        System.debug('***Telstra:PRMMassEmailPlugin.sendMassEmail: Inputs recieved :'+ flowInputs);
        
        //P2OB - 8405 : Collect TemplateName and OrgWideAddress from list of inputs
        Map<String,String> map_flow_vs_emailTemplate = new Map<String,String>();
        Map<String,String> map_flow_vs_orgWideEmail = new Map<String,String>();
        for(FlowInputParameter input:flowInputs){
            map_flow_vs_emailTemplate.put(input.invokedby_FlowInterviewGuid,input.EmailTemplateAPIName);
            map_flow_vs_orgWideEmail.put(input.invokedby_FlowInterviewGuid,input.orgWidEmailAddress);
        }
        
        //P2OB - 8405 : Query to get EmailTemplates
        List<EmailTemplate> listResults = [ SELECT Name,DeveloperName,NamespacePrefix,OwnerId,FolderId,BrandTemplateId,TemplateStyle,IsActive,TemplateType FROM EmailTemplate WHERE DeveloperName in :map_flow_vs_emailTemplate.values()];
        System.debug('***Telstra:PRMMassEmailPlugin.sendMassEmail: listResults: '+listResults+ ' and map:'+ map_flow_vs_emailTemplate);        
        //P2OB - 8405 : Query to get orgWideEmailAddress
        list<OrgWideEmailAddress> listOrgEmails=[SELECT Id,Address FROM OrgWideEmailAddress WHERE Address in: map_flow_vs_orgWideEmail.values()];                
        System.debug('***Telstra:PRMMassEmailPlugin.sendMassEmail: '+listOrgEmails+ ' and map:'+ map_flow_vs_orgWideEmail);        
        
        Map<String,OrgWideEmailAddress> map_name_vs_orgWideEmailId = new Map<String,OrgWideEmailAddress>();
        Map<String,EmailTemplate> map_name_vs_emailTemplateId = new Map<String,EmailTemplate>();
        for(OrgWideEmailAddress temp: listOrgEmails ){
            map_name_vs_orgWideEmailId.put(temp.Address, temp);
        }
        for(EmailTemplate template: listResults ){
            map_name_vs_emailTemplateId.put(template.DeveloperName, template);
        }
        try{
            Messaging.SendEmailResult[] results;
            //P2OB - 8405 : Loop over flow-inputs and create a list of emailMessages 
            for(FlowInputParameter flowInput : flowInputs){
                List<Sobject> sobjectList = flowInput.sobjectList;
                Messaging.SingleEmailMessage mail;
                List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                for(Sobject sobj : sobjectList){
                    //P2OB - 8405 : List of SObjects(Ex. Users) to whom emails are to be sent
                    Id uId = (Id)sobj.get('Id');
                    //String contactId = (String)sobj.get('ContactId');
                    if(!String.isBlank(map_flow_vs_emailTemplate.get(flowInput.invokedby_FlowInterviewGuid))){               
                        mail = new Messaging.SingleEmailMessage();
                        //P2OB - 8405 : Commented below method as it counts againt 1 SOQL Query in Governor Limit
                        //mail = Messaging.renderStoredEmailTemplate(map_name_vs_emailTemplateId.get(map_flow_vs_emailTemplate.get(flowInput.invokedby_FlowInterviewGuid)).id, uId, uId);
                        mail.setTargetObjectId(uId);
                        mail.setTreatTargetObjectAsRecipient(true); //Added for fix 
                        //P2OB - 8405 : Setting templateId associated to this flow-interview
                        mail.setTemplateId(map_name_vs_emailTemplateId.get(map_flow_vs_emailTemplate.get(flowInput.invokedby_FlowInterviewGuid)).id);
                        mail.setSaveAsActivity(false);
                        //P2OB - 8405 : Setting orgWideEmail associated to this flow-interview
                            if(!String.isBlank(map_flow_vs_orgWideEmail.get(flowInput.invokedby_FlowInterviewGuid)))
                            mail.SetorgWideEmailAddressId(map_name_vs_orgWideEmailId.get(map_flow_vs_orgWideEmail.get(flowInput.invokedby_FlowInterviewGuid)).Id); 
                       messages.add(mail); 
                    }
                }
                if(!messages.isEmpty()){
                    results = Messaging.sendEmail(messages);
                    System.debug('***Telstra:PRMMassEmailPlugin:sendMassEmail:SendEmailResults: '+results);
                    FlowOutputParameter flowOutput  = new FlowOutputParameter(); 
                    flowOutput.isResultSuccess = true;
                    flowOutputs.add(flowOutput);
                }
                
                
            }
        }
        catch(Exception e){
            FlowOutputParameter flowOutput  = new FlowOutputParameter(); 
            flowOutput.errorMessage = e.getMessage();
            flowOutput.isResultSuccess = false;
            flowOutputs.add(flowOutput);
            logger.logMessages('PRMMassEmailPlugin.sendMassEmail', 'Error occured in apex action'+e.getMessage(), e.getMessage(), '', '', '', false, false);
        }
        finally{
            logger.exitLogger();            
        }   
        return flowOutputs;
    }
    
    /**    
* Description : Wrapper class to hold input parameters received from flow 
* Jira : P2OB - 8405
*/
    public Class FlowInputParameter{
        @InvocableVariable
        public List<Sobject> sobjectList;
        @InvocableVariable
        public String EmailTemplateAPIName;
        @InvocableVariable
        public String orgWidEmailAddress;
        @InvocableVariable
        public String invokedby_FlowInterviewGuid;
    }
    
    /**    
* Description : Wrapper class to hold output parameters sent to flow 
* Jira : P2OB - 8405
*/
    public Class FlowOutputParameter{
        @InvocableVariable
        public String errorMessage = '';
        @InvocableVariable
        public Boolean isResultSuccess ; 
    }
}