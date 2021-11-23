/********************************************************
Class Name : ManageBillingSubsNotificationUtil
Test Class : ManageBillingSubsNotificationUtilTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Gnana                  15/04/2021      created as part of EDGE-205529
2.            Gnana                  05/05/2021      Added Logic to Update PC Attribute
3.            Gnana                  07/05/2021      EDGE-218296 - Executing update PC Attribute only for Parent Service
***************************************************************/

public with sharing class ManageBillingSubsNotificationUtil {

    private static final String CONST_INTERFACENAME = 'ManageBillingSubsNotificationUtil';

    public static void updateSubscription(List<csord__Subscription__c> subsList,Map<String,Map<String,String>> subsIdToSubsDetailsMap,Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap){
        System.debug('inside updateSubscription method...'+subsList);
        List<csord__Subscription__c> subsListtoUpdate = new List<csord__Subscription__c>();
        try{
            for(csord__Subscription__c subs : subsList){
                subs.csord__Status__c = Label.Active;
                System.debug('Response Code = '+subsIdToSubsDetailsMap.get(subs.csordtelcoa__Subscription_Number__c)+'for the Subs= '+subs.csordtelcoa__Subscription_Number__c);
                if(subsIdToSubsDetailsMap.get(subs.csordtelcoa__Subscription_Number__c).get('responseCode') == '200' && subsNumberToAssocMap.get(subs.csordtelcoa__Subscription_Number__c)!=null){
                    //logic to update new Billing Account
                    subs.Billing_Account__c = subsNumberToAssocMap.get(subs.csordtelcoa__Subscription_Number__c).Billing_Account__c;
                }
                subsListtoUpdate.add(subs);
            }
            
            if(!subsListtoUpdate.isEmpty()){
                System.debug('subsListtoUpdate...'+subsListtoUpdate);
                UPDATE subsListtoUpdate;
            }
        }
        catch(Exception e){logException('updateSubscription', '', '', e.getMessage(), 'Exception occured while updating Subscription Records');}
    }

    public static void updateService(List<csord__Service__c> servList,Map<String,Map<String,String>> subsIdToSubsDetailsMap,Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap){
        System.debug('inside updateService method...'+servList);
        List<csord__Service__c> servListtoUpdate = new List<csord__Service__c>();
        try{
            for(csord__Service__c serv : servList){
                System.debug('Response Code = '+subsIdToSubsDetailsMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c)+'for the Subs= '+serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c);
                if(subsIdToSubsDetailsMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('responseCode') == '200' && subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c)!=null){
                    //logic to update new Billing Account
                    serv.Billing_Account__c = subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).Billing_Account__c;
                }
                servListtoUpdate.add(serv);
            }
    
            if(!servListtoUpdate.isEmpty()){
                System.debug('servListtoUpdate...'+servListtoUpdate);
                UPDATE servListtoUpdate;
            }
        }
        catch(Exception e){logException('updateService', '', '', e.getMessage(), 'Exception occured while updating Service Records');}
    }

    public static void updateNumber(List<Number__c> numbList,Map<String,Map<String,String>> subsIdToSubsDetailsMap,Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap){
        System.debug('inside updateNumber method...'+numbList);
        List<Number__c> numListtoUpdate = new List<Number__c>();
        try{
            for(Number__c num : numbList){
                System.debug('Response Code = '+subsIdToSubsDetailsMap.get(num.Subscription_number__c)+'for the Subs= '+num.Subscription_number__c);
                if(subsIdToSubsDetailsMap.get(num.Subscription_number__c).get('responseCode') == '200' && subsNumberToAssocMap.get(num.Subscription_number__c)!=null){
                    //logic to update new Billing Account
                    num.Billing_Accounts__c = subsNumberToAssocMap.get(num.Subscription_number__c).Billing_Account__c;
                }
                numListtoUpdate.add(num);
            }
    
            if(!numListtoUpdate.isEmpty()){
                System.debug('numListtoUpdate...'+numListtoUpdate);
                UPDATE numListtoUpdate;
            }
        }
        catch(Exception e){logException('updateNumber', '', '', e.getMessage(), 'Exception occured while updating Number Records');}
    }

    public static void updateSubsToCaseAssoc(List<Subscriptions_to_Case_Association__c> listOfSubsToCaseAssoc,Map<String,Map<String,String>> subsIdToSubsDetailsMap,Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap){
        System.debug('inside subscaseassoc method...'+listOfSubsToCaseAssoc);
        List<Subscriptions_to_Case_Association__c> assocListtoUpdate = new List<Subscriptions_to_Case_Association__c>();
        try{
            for(Subscriptions_to_Case_Association__c assoc : listOfSubsToCaseAssoc){
                System.debug('Response Code = '+subsIdToSubsDetailsMap.get(assoc.csord_Subscription__r.csordtelcoa__Subscription_Number__c)+'for the Subs= '+assoc.csord_Subscription__r.csordtelcoa__Subscription_Number__c);
                if(subsIdToSubsDetailsMap.get(assoc.csord_Subscription__r.csordtelcoa__Subscription_Number__c).get('responseCode') == '200' && subsNumberToAssocMap.get(assoc.csord_Subscription__r.csordtelcoa__Subscription_Number__c)!=null){
                    //logic to update new Billing Account
                    assoc.Status__c = Label.COMPLETED_STATUS; // Completed Status
                }
                else{
                    assoc.Status__c = Label.Failed_Status;
                }
                assocListtoUpdate.add(assoc);
            }
    
            if(!assocListtoUpdate.isEmpty()){
                System.debug('assocListtoUpdate...'+assocListtoUpdate);
                UPDATE assocListtoUpdate;
            }
        }
        catch(Exception e){logException('updateSubsToCaseAssoc', '', '', e.getMessage(), 'Exception occured while updating SubscriptionToCaseAssociation Records');}
    }

    public static void updateCase(Set<Id> caseIdList,List<String> listOfSubsNumbers){
        List<Subscriptions_to_Case_Association__c> SubsToCaseAssocList = [SELECT Id,csord_Subscription__c,csord_Subscription__r.csordtelcoa__Subscription_Number__c,Case__c,Status__c,Billing_Account__c FROM Subscriptions_to_Case_Association__c WHERE csord_Subscription__r.csordtelcoa__Subscription_Number__c IN:listOfSubsNumbers AND Status__c='In Progress']; 
        List<Case> caseListToUpdate = new List<Case>();
        try{
            if(SubsToCaseAssocList.isEmpty()){
                for(Id caseId : caseIdList){
                    Case updCase = new Case(Id=caseId,Status=Label.Case_Status_Closed);
                    caseListToUpdate.add(updCase);
                }
            }
            if(!caseListToUpdate.isEmpty()){
                UPDATE caseListToUpdate;
            }
        } 
        catch(Exception e){logException('updateCase', '', '', e.getMessage(), 'Exception occured while updating Case Records');}
    }

    /*public static void updatePCAttributes(List<csord__Service__c> servList,Map<String,Map<String,String>> subsIdToSubsDetailsMap,Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap){
        System.debug('inside updatePCAttributes method...'+servList);
        cssmgnt.API_1 api = new cssmgnt.API_1();
        String response = '';
        try{
            for(csord__Service__c serv : servList){
                System.debug('Response Code = '+subsIdToSubsDetailsMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c)+'for the Subs= '+serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c);
                if(subsIdToSubsDetailsMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('responseCode') == '200' && subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c)!=null){
                    //logic to update new Billing Account
                    response = api.updateConfigurations(serv.cssdm__solution_association__c, new Map<String, Map<String, String>>{ serv.csordtelcoa__Product_Configuration__r.configGUID__c => new Map<String, String>{ Label.BillingAccountAttName => subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).Billing_Account__c } });
                    System.debug('response...'+response);
                }
            }
        }
        catch(Exception e){
            logException('updateService', '', '', e.getMessage(), 'Exception occured while updating Service Records');
        }
    }*/

    public static void updatePCAttributes_Custom(List<csord__Service__c> servList,Map<String,Map<String,String>> subsIdToSubsDetailsMap,Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap){
        System.debug('inside updatePCAttributes method...'+servList);
        Set<Id> pcSet = new Set<Id>();
        Set<Id> servIds = new Set<Id>();
        Map<Id, Blob> serviceAttachmentMap = new Map<Id, Blob>();
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        Map<Id,List<cscfga__Attribute__c>> attrMap= new Map<Id,List<cscfga__Attribute__c>>();
        Map<String,String> AttrsMap = new Map<String,String>();
        List<cscfga__Attribute__c> updateAttrList = new List<cscfga__Attribute__c>();
        Map<String, Attachment> AttMapTobeUpdated = new Map<String, Attachment>();
        try{
            for(csord__Service__c serv :servList){
                if(serv.csord__Service__c==null){//EDGE-218296 - Added condition to check Parent Service
                    servIds.add(serv.Id);
                    pcSet.add(serv.csordtelcoa__Product_Configuration__c );
                }
            }

            for(cscfga__Attribute__c attr :[select id , name , cscfga__Product_Configuration__c , cscfga__Display_Value__c ,cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c IN: pcSet AND (Name=:Label.BillingAccountAttName)]){
                if(attrMap.containsKey(attr.cscfga__Product_Configuration__c))
                {
                    List<cscfga__Attribute__c> attList = attrMap.get(attr.cscfga__Product_Configuration__c);
                    attList.add(attr);
                    attrMap.put(attr.cscfga__Product_Configuration__c, attList);
                }
                else{
                    attrMap.put(attr.cscfga__Product_Configuration__c, new List<cscfga__Attribute__c>{attr});
                }
            }

            for(csord__Service__c serv :servList){
                if(serv.csord__Service__c==null){//EDGE-218296 - Added condition to check Parent Service
                    if(subsIdToSubsDetailsMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('responseCode') == '200' && subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c)!=null){
                        AttrsMap.put(Label.BillingAccountAttName,subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).Billing_Account__c);
                    }

                    for(cscfga__Attribute__c at :attrMap.get(serv.csordtelcoa__Product_Configuration__c)){
                        if(at.name.Contains(Label.BillingAccountAttName)){
                            at.cscfga__Value__c = subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).Billing_Account__c;
                            at.cscfga__Display_Value__c = subsNumberToAssocMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).Billing_Account_Number__c;
                        }
                        updateAttrList.add(at);
                    }
                }
            }

            if(!updateAttrList.isEmpty()){
                update updateAttrList;
            }
        }
        catch(Exception e){logException('updateService', '', '', e.getMessage(), 'Exception occured while updating Service Records');}
    }

    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME); eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}