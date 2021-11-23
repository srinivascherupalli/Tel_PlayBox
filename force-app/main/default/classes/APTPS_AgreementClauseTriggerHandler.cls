/*****************************************************************
@Name: APTPS_AgreementClauseTriggerHandler
@Author: Ruchika Patil 
@CreateDate: 24/06/2016 
@Description: This is the handler for the trigger APTPS_AgreementClauseTrigger - on Agreement Clause object for the events: before insert
@UsedBy: Agreement 
******************************************************************/ 
public class APTPS_AgreementClauseTriggerHandler{
     /******************************************************************
    @Description:This method populates the Approval Guidance field from Template object to Approval Guidance field on Agreement Clause Object
    *******************************************************************/  
    public void populateApprovalGuidance(List<Apttus__Agreement_Clause__c> clauseList){
        try{
            Set<id> templateIdSet = new Set<Id>();
            
            for(Apttus__Agreement_Clause__c clause : clauseList){            
                templateIdSet.add(clause.Apttus__Template__c);
            }
            List<Apttus__APTS_Template__c> templateList = [SELECT id, APTPS_Approval_Guidence__c FROM Apttus__APTS_Template__c 
                                                                    WHERE id IN : templateIdSet]; 
            
            Map<Id,Apttus__APTS_Template__c> templateMap = new Map<Id,Apttus__APTS_Template__c>(templateList);      
            for(Apttus__Agreement_Clause__c clause : clauseList){
                
                if(templateMap != null && templateMap.get(clause.Apttus__Template__c) != null && 
                                templateMap.get(clause.Apttus__Template__c).APTPS_Approval_Guidence__c != null){
                    
                    clause.APTPS_Approval_Guidence__c = templateMap.get(clause.Apttus__Template__c).APTPS_Approval_Guidence__c; 
                }
            }
        }
        catch(Exception e)
        {
            //System.debug('CaLMs System exception caught: ' + e.getMessage());  
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occurred. Please contact the system administrator'));   
        }
    }
}