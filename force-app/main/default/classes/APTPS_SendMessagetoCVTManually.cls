/*************************************************************************************************************************
 @Name: APTPS_SendMessagetoCVTManually
 @Author: Shishir Bose
 @Created Date: 03/22/2017
 @Descripton: This controller is created for handling the update of Fund for sending to CVT
 @Used By: APTPS__Init_SendMessagetoCVT VF page
*********************************************************************************************************************/
public with sharing class APTPS_SendMessagetoCVTManually
{
     public Fund__c fundRecord{get;set;}
     public Id fundRecordId{get;set;}
     public APTPS_SendMessagetoCVTManually(ApexPages.StandardController  stdController)
   
    {
         fundRecordId = stdController.getId();
         if(!test.isRunningTest()){
         stdController.addFields(new List<string>{'APTPS_Send_Message_to_CVT_for_Edit_Fund__c'});
         }    
         fundRecord = (Fund__c)stdController.getRecord(); 
         
    }
    public PageReference updateFundForManualCVTNotification()
    {   
        PageReference pageRef = new PageReference('/home/home.jsp');
        pageRef = new PageReference('/'+fundRecordId);        
        pageRef.setredirect(true);
        try{
            fundRecord.APTPS_Send_Message_to_CVT_for_Edit_Fund__c = true;
            
            update fundRecord;
            return pageRef;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,e.getMessage()));   
            return null;
        }
        
       
    }
}