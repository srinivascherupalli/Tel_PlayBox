/*****************************************************************************************************************************
 * Story: DIGI-24543
 * Team : Osaka
 * Developer : Pradeep Mudenur
 * Description: <Enhancement for TED-127> Trigger Chatter notification/Mail with CASE ID after Basket configuration failure update.
 * ************************************************************************************************************************************/
public with sharing class TransitionControllerHelper {
    public static string cASESUBJECT = '- Auto Basket Configuration has Failed';
    public static string dIGITIZEDORDERING = 'Digitised Ordering Issue';
    public static string cHECKPOINTTRANSITION ='Checkpoint/ Transition';
    public static string cASEPRIORITY ='High';
    public static string cASESTATUS ='New';
    public static string cASESEVERITY ='Medium'; 
    public static string cASEORIGIN ='Feedback';
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');
    
    @AuraEnabled 
    public static case createFeedbackCase(List<id> basketId){
        
        try{
            String feedbackCaseRTId  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;  
            Id feedbackQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'Modular_Order' LIMIT 1].Id;
            
            system.debug('createFeedbackCase@@@');
            string basketName ='';
            if(basketId != null){   
                List<cscfga__Product_Basket__c> prdBasketList = [select id,Name,csbb__Account__c from cscfga__Product_Basket__c where id IN:basketId limit 1];
                if(!prdBasketList.isEmpty()){
                    basketName = prdBasketList[0].Name;
                }
            }   
            
            Case newCase = new Case( Subject = basketName +' '+ CASESUBJECT,
                                    OwnerId = userinfo.getUserid(),
                                    Priority = CASEPRIORITY,
                                    Status = CASESTATUS,
                                    Severity__c = CASESEVERITY,
                                    Description = String.valueOf(customMetadataNameValueMap.get('CaseDescription').get('value__c')).replace('{Basket Id}','{record:'+basketName+'}'),
                                    Feedback_Related_to__c = DIGITIZEDORDERING,
                                    Origin = CASEORIGIN,
                                    RecordTypeId = feedbackCaseRTId,
                                    Feedback_Category__c = CHECKPOINTTRANSITION
                                   );
            Insert newCase;
            case caseRec = [select id,caseNumber from case where id=: newCase.id limit 1];
            system.debug('caseRec@@@ ' + caseRec);
            return caseRec;
        }catch(Exception ex){
             System.debug('Exception in checkReplicatorResponse' + ex);
        }
            return null;
        }               
    }