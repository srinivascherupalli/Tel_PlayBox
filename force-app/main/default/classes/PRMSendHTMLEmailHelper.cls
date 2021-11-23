/*
 * EDGE-88556
 * Author: RaviTeja K
 * This Class referenced in flow "PRM_Send_Email_Share_Opportunity_Partner_Sales_Manager" to trigger emails to Sales Managers of the partner account on sharing opportunity to partner
 * History of modifications : 
 * 1. 3-April-2020    Ritika Jaiswal    P2OB-5611 : On Lead's share-with-partner, send email-notification to Sales Managers setup in Partner-Account 
 * 2. 27-April-2020   Ritika Jaiswal    P2OB-6151 : Defect fix for email content in Lead-Acceptance mails to SalesManagers    
**/


global without sharing class PRMSendHTMLEmailHelper implements process.Plugin {

    private static final String LEAD_OBJECT_NAME = 'Lead';
    private static final String CONTACT_OBJECT_NAME = 'Contact';
    private static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    private static final String VisualForce_EMAILTEMPLATE_TYPE = 'visualforce';
    
    global Process.PluginResult invoke(Process.PluginRequest request){ 
       
        //capturning input parameters
           
        Logger2 logger = Logger2.getLogger('sendHTMLEmailPlugin.invoke');
        
        Map<String,String> result = new Map<String,String>();        
        String targetObjId = (String) request.inputParameters.get('Target Object Id');
        String emailTemplateid= (String) request.inputParameters.get('Email Template');
        String subject = (String) request.inputParameters.get('Subject');
        String Emails = (String) request.inputParameters.get('Emails (comma-separated)');        
        String recordid= (String) request.inputParameters.get('Record Id');
        String orgWide= (String) request.inputParameters.get('Orgwide Email');

        try{
           String relatedObject = (Id.valueOf(recordid)).getSObjectType().getDescribe().getName(); // P2OB - 6151 : Primary object Name whose merge-fields are present in email-template
           String obj = (Id.valueOf(targetObjId)).getSObjectType().getDescribe().getName();  //P2OB - 6151 : Related to primary-object, used for filling merge-fields in email-template
          
           //P2OB-6151 : Update Constructor of SingleEmailMessage to support VF-Templates and HTML templates       
           Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplateid, targetObjId, recordid );
                         
              if(emailTemplateid!= null && targetObjId != null && Emails != null){     
                message.setTreatTargetObjectAsRecipient(false);
                
                //P2OB - 5611,P2OB-6151 : whatId is required to be set in SingleEmailMessage when target is Contact and record is of Opportunity ; this is to be skipped for lead
                if(obj.equalsIgnoreCase(CONTACT_OBJECT_NAME) && relatedObject.equalsIgnoreCase(OPPORTUNITY_OBJECT_NAME))
                    message.setWhatId(recordid);
                }
                 
                String[] otherEmailsArray = Emails.split(',');
                message.setToAddresses(otherEmailsArray);
                message.setSaveAsActivity(false);
               
                if(orgWide != null){
                    list<OrgWideEmailAddress> Orgemails=[SELECT Id FROM OrgWideEmailAddress WHERE Address =: orgWide];
                    if(Orgemails.size()>0)
                      message.SetorgWideEmailAddressId(Orgemails[0].Id);
              }
               if(!Test.isRunningTest()){
                      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                   }
            
            return new Process.PluginResult(result);
        }   
        catch(exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            system.debug('e.getMessage'+e.getMessage());
        }
        finally{
            logger.exitLogger();            
        }

    return new Process.PluginResult(result);       
    }
    
    global process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'HTML Email Plugin';
        result.Tag = 'HTML Email Plugin';
        
        // Set description
        result.Description ='This plugin allows for sending HTML emails.';

        // Set input parameters
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>();
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Target Object Id', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Email Template', Process.PluginDescribeResult.ParameterType.String, true));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Subject', Process.PluginDescribeResult.ParameterType.String, true));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Emails (comma-separated)', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Record Id', Process.PluginDescribeResult.ParameterType.String, true));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Orgwide Email', Process.PluginDescribeResult.ParameterType.String, true));

        
        return result;
        
    }
    
}