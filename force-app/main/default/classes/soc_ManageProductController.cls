/*****************************************************************************
@Author: Pravin Sonawane
@CreateDate: 22/01/2019
@ModifiedByandDate: 19/03/2019
@Description: This class is for manually create clone case and related case line items
*******************************************************************************/
public without sharing class soc_ManageProductController {
    
    /**
    * This method returns the case Line Items records for the provided child record Id.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    @AuraEnabled
    public static List<soc_Case_Line_Item__c> getCaseLineItems(String id){        
        List<soc_Case_Line_Item__c> listOutput=[select id,Name,soc_order_number__c,soc_ProductId__c,
                                                soc_CaseId__c,soc_ProductId__r.Name,soc_CaseId__r.caseNumber
                                                from soc_Case_Line_Item__c where soc_CaseId__c=:id ];
        
        system.debug('listOutput');
        system.debug(listOutput);
        return listOutput;        
    }
    
    /**
    * This method create the replica of Child case record and checks the case Line Items record count.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    @AuraEnabled
    public static Map<String,Object> fetchClonedCase(String Id){
        Map<String,Object> results = new Map<String,Object>();
        system.debug('ParentId='+Id);
        Case parentCase = [SELECT Id,caseNumber,opportunityId__c,Subject,Status,
                           RecordTypeId,Stage__c,Primary_Domain__c,OwnerId,CIDN__c,soc_Domain__c,
                           srvsup_Parent_CIDN__c,srvsup_Ultimate_CIDN__c,Requestor__c,
                           AccountId,ContactId,Description,RecordType.Name,ParentId,
                           soc_Billing_Account_Number__c,MDN_Network_FNN__c,Network_FNN__c,
                           soc_FNNs__c,soc_Number_of_Sites__c,soc_SFD_Offshore_Restricted__c,Child_Case_Count__c,
                           soc_Product__c,soc_Additional_Technical_Contact__c,soc_Additional_Technical_Contact_Email__c,
                           soc_Additional_Technical_Contact_Phone__c
                           FROM Case where id = :Id];
        
        Case clonedCase= parentCase.clone(false, false, false, false);
        clonedCase.Subject = 'Clone Of - '+ parentCase.Subject;
        
        system.debug('subject='+clonedCase.Subject);
        
        List<soc_Case_Line_Item__c> lstCaseLineItems = getCaseLineItems(Id);
        if(lstCaseLineItems.size() == 1)
            results.put('cliSizeOne',true);
        else
            results.put('cliSizeOne',false);        
        
        results.put('case',clonedCase);
        system.debug('results='+results);
        return results;        
    } 
    
    
    
    
    
    /**
    * This method create the new cloned record for with provided caseLineItem
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    @AuraEnabled
    public static Case cloneCase(Case newCase, List<Object> selectedCaseLineItem, Boolean cliSizeOne, Id parentCaseId){
        List<Entitlement> socEntitlement = [Select Id From Entitlement where Name = 'SOC Order Capture Entitlement' limit 1] ;
        List<String> caseLineItemIds=new List<String>(); 
        
        system.debug('selectedCaseLineItem>>'+selectedCaseLineItem);
        
        for(Object cc:selectedCaseLineItem){
            caseLineItemIds.add(String.valueOf(cc));
        }
        
        Map<Id,soc_Case_Line_item__c> mapAllCaseLineItems = new Map<Id,soc_Case_Line_item__c>([Select id,name,soc_CaseId__c,soc_ProductId__c,soc_order_number__c From soc_Case_Line_item__c Where soc_CaseId__c = :parentCaseId]);
        
        if(socEntitlement != null && socEntitlement.size()>0){
        newCase.EntitlementId = socEntitlement[0].Id;
        }
        
        	insert newCase;      
        
        updateCountOnParent(newCase);
        system.debug('mapAllCaseLineItems>>'+mapAllCaseLineItems);                                                                                       
        List<soc_Case_Line_item__c> caseItemsList=new List<soc_Case_Line_item__c>();
        List<String> itemIds=new List<String>();
        //Pravin S :: EDGE-68187 :: 19-MAR-201,4-APR-2019
        if(cliSizeOne){
            // When only 1 CaseLineItem is present and selected from Product DataTable
            if(mapAllCaseLineItems != null && caseLineItemIds.size() == 1){
                system.debug('caseLineItemIds[0]==>'+caseLineItemIds[0]);
                soc_Case_Line_item__c existingLineItem = mapAllCaseLineItems.get(caseLineItemIds[0]);
                soc_Case_Line_item__c newLineItem = existingLineItem.clone(false, true);
                system.debug('clonedCli==>'+newLineItem);
                newLineItem.soc_CaseId__c = newCase.id;
                caseItemsList.add(newLineItem);
            }
        }
        else{
            // When all the CaseLineItems are selected from Product DataTable
            if(mapAllCaseLineItems != null && mapAllCaseLineItems.size() == caseLineItemIds.size()){
                for(soc_Case_Line_item__c caselineItem : mapAllCaseLineItems.values()){
                    soc_Case_Line_item__c newLineItem = caselineItem.clone(false,true);
                    newLineItem.soc_CaseId__c = newCase.id;
                    caseItemsList.add(newLineItem);
        }
        }
            else{ // When some of the caseLineItems are selected from Product DataTable
                system.debug('caseLineItemIds====>'+caseLineItemIds);
                system.debug('mapAllCaseLineItems====>'+mapAllCaseLineItems);
                if(mapAllCaseLineItems != null && mapAllCaseLineItems.size() != caseLineItemIds.size()){
                    for(soc_Case_Line_item__c caselineItem : mapAllCaseLineItems.values()){
                        for(String selectedCaseLineItemId : caseLineItemIds){
                            if(selectedCaseLineItemId == caselineItem.Id && mapAllCaseLineItems.containsKey(selectedCaseLineItemId)){
                                soc_Case_Line_item__c existingLineItem =  mapAllCaseLineItems.get(selectedCaseLineItemId);  
                                existingLineItem.soc_CaseId__c=newCase.id;                
                                caseItemsList.add(existingLineItem);
                            }
                        }
                    }
                }
            }                  
        }
        system.debug('caseItemsList=='+caseItemsList);
        
        if(caseItemsList.size() > 0)
            upsert caseItemsList; 
        return newCase;        
    }
    
    
    
    
    public static void updateCountOnParent(Case newCase){
        Case parentCase = [Select Id, Child_Case_Count__c  from Case where id =:newCase.parentId];
        parentCase.Child_Case_Count__c = parentCase.Child_Case_Count__c + 1;
        update parentCase;
            
    } 
        
}