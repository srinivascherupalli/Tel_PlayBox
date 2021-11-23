/**
 EDGE-88556
 Author: RaviTeja K
 This Class referenced in flow "PRM_Send_Email_Share_Opportunity_Partner_Sales_Manager" to trigger emails to Sales Managers of the partner account on sharing opportunity to partner
**/


global without sharing class sendHTMLEmailPlugin implements process.Plugin {

   
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

          Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                  
            
           if(emailTemplateid!= null && targetObjId != null && Emails != null){     
                message.setTemplateId(emailTemplateid);
                message.setTargetObjectId(targetObjId);
                message.setTreatTargetObjectAsRecipient(false);
                message.setWhatId(recordid);
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
            }
            
            return new Process.PluginResult(result);
        }   
        catch(exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();            
        }

    return null;        
       
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