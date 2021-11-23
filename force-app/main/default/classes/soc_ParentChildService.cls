/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 8-Jan-2019
@ModifiedByandDate: 
@Description: This class contains   initialization logic for child case and Case Line Items. 
@References
Epic :EDGE-40183 P2O: Sales Order Parent Child Division of SFD Cases
Story:EDGE-57334 Automated Child Case Creation, Submission and Acceptance by SFD concierge

*******************************************************************************/

public without sharing class soc_ParentChildService {
    
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    
    public static void createChildCasesPerUniqueDomain(List<Case> newList){
         /* Added by Kritika Bhati for EDGE-57886 : 20/2/2019
         /Description: Querying Entitlement so as to add milestone on a Case*/ 
         List<Entitlement> socEntitlement = [Select Id FROM Entitlement WHERE Name = 'SOC Order Capture Entitlement' limit 1] ;
        System.debug('1. createChildCasesPerUniqueDomain>>>>>IN');        
        List<Case> childCaseInserts=new List<Case>();
        List<Case> socRequests=new List<Case>();
        Map<Id,Id> caseOppIdMap=new Map<Id,Id>();
        Map<Id,Id> OppIdAccIdMap=new Map<Id,Id>();
        List<Id> parentCaseUpdateCount = new List<Id>();//kb
        
        try{
            for(case cs : newList){
                if(cs.RecordTypeid == recId_OrderRequest){
                    socRequests.add(cs); 
                    caseOppIdMap.put(cs.OpportunityId__c,cs.Id);
                }
            }
            Map<ID, Case> parentCaseMap = new Map<ID, Case>([SELECT Id,caseNumber,OwnerId,Subject,Status,Stage__c,soc_SFD_Withdraw_Reason__c,
                                                             Requestor__c,soc_ITAM_Number__c,Description,AccountId,CIDN__c,
                                                             ContactId,srvsup_Parent_CIDN__c,ContactPhone,srvsup_Ultimate_CIDN__c,ContactEmail,
                                                             soc_SFD_Offshore_Restricted__c,Primary_Domain__c,soc_Customer_Required_Date_CRD__c,
                                                             soc_Additional_Technical_Contact__c,soc_Customer_Acceptance_Evidence__c,
                                                             soc_Additional_Technical_Contact_Phone__c,soc_Feasibility_ID__c,
                                                             soc_Additional_Technical_Contact_Email__c,soc_FNNs__c,soc_Existing_Project_ID__c,
                                                             Network_FNN__c,soc_Request_Type__c,MDN_Network_FNN__c,soc_Number_of_Sites__c,
                                                             soc_Project_Manager_Required__c,soc_Contract_Not_Aligned__c,soc_Project_Manager_Name__c,
                                                             soc_LOC_ID__c,soc_ADBOR_ID__c,soc_Billing_Account_Number__c,soc_MICA_Account_No__c,
                                                             soc_Asset_Availability_Outcome__c,soc_Pending_Order_Reason__c,soc_Contract_Alignement_Outcome__c,
                                                             soc_Outcomes_for_Simplex__c,CreatedDate,ClosedDate,Priority,SuppliedEmail,RecordTypeId,
                                                             soc_Product__c, EntitlementId 
                                                             FROM Case where id in :caseOppIdMap.values()]);            
            List<OpportunityLineItem> items=[select id,opportunityId,Domain__c,
                                             Product2Id,Product2.Name,Product_Name__c,
                                             Opportunity.AccountId from 
                                             OpportunityLineItem where 
                                             opportunityId in :caseOppIdMap.keyset()];
            
            Set<string> domainSet=new Set<string>();
            Case parentCase=null;
            for(OpportunityLineItem oli:items){               
                if(!domainSet.contains(oli.Domain__c)){                   
                    parentCase=parentCaseMap.get(caseOppIdMap.get(oli.OpportunityId));
                    Case clonedCase=parentCase.clone(false, false, false, false);
                    clonedCase.RecordTypeId=recId_SFD_ProductType;
                    clonedCase.parentId=caseOppIdMap.get(oli.OpportunityId);
                    clonedCase.subject='Child SFD Request - '+oli.Domain__c+' Domain for '+parentCase.CaseNumber;
                    clonedCase.soc_Domain__c=oli.Domain__c;
                    clonedCase.Status='In Progress';
                    clonedCase.ownerId=parentCase.OwnerId;
                    /* Added by Kritika Bhati for EDGE-57886 : 20/2/2019
                    /Description: Adding case for a particular entitlement for milestone */ 
                    if(socEntitlement != null && socEntitlement.size()>0){
                    	clonedCase.EntitlementId = socEntitlement[0].Id;
                    }
                    //END EDGE-57886
                     //added by sandeep for populating offshorerestricted checkbox on child case also.
                    clonedCase.soc_SFD_Offshore_Restricted__c = parentCase.soc_SFD_Offshore_Restricted__c;
                    parentCase.status='In Progress';                    
                    domainSet.add(oli.Domain__c);
                    childCaseInserts.add(clonedCase);
                    parentCaseUpdateCount.add(caseOppIdMap.get(oli.OpportunityId));
                }               
            }
            
            if(childCaseInserts.size()>0){
                System.debug('>>>>>Child Cases>>>>>>>');
                System.debug(childCaseInserts);
                if(Schema.sObjectType.Case.isCreateable()){           
                    insert childCaseInserts; 
                }else{
                    Trigger.new[0].addError(String.format(Label.Soc_Access_Error_Msg,new List<String>{'Case'}));
                } 
                
                System.debug('>>>>>Child Cases After>>>>>>>');
                System.debug(childCaseInserts);
                createCaseLineItems(caseOppIdMap,childCaseInserts,items);  
                //createEntitlements(childCaseInserts);
            }
            if(parentCaseUpdateCount.size() > 0){
                soc_ParentCaseOwnerService.updateChildCountOnParent(parentCaseUpdateCount);
		    }
            if(parentCase!=null){
                if(Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.isUpdateable()){           
                    upsert parentCase;
                }else{
                    Trigger.new[0].addError(String.format(Label.Soc_Access_Error_Msg,new List<String>{'Case'}));
                }                 
            }
        }   
        catch(Exception e){
            System.debug('Exception >>>>>>>>'+e);
            System.debug('Exception >>>>>>>>'+e.getLineNumber());
        }
    }
    
    
    public static void  createCaseLineItems(Map<Id,Id> caseOppIdMap,List<Case> childCases,List<OpportunityLineItem> items){
        System.debug('createCaseLineItems>>>>>>>>');
        List<soc_Case_Line_item__c> caseItemsList=new List<soc_Case_Line_item__c>();
        Map<String,Case> domainChildCaseMap=new Map<String,Case>();
        
        
        for(Case cs:childCases){
            domainChildCaseMap.put(cs.soc_Domain__c, cs);
        }
        for(OpportunityLineItem oli:items){ 
            
            Case domainCase=domainChildCaseMap.get(oli.Domain__c);
            soc_Case_Line_item__c case_itm=new soc_Case_Line_item__c();
            case_itm.soc_ProductId__c=oli.Product2Id;
            case_itm.soc_CaseId__c=domainCase.Id;
            caseItemsList.add(case_itm);
            
        }
        
        if(caseItemsList.size()>0){
            system.debug('caseItemsList');
            system.debug(caseItemsList);
            insert caseItemsList;
        }
    }
   
}