/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-119565
* @Description  - This class will helps to create new "Credits and Adjustments" record whenever case status changes to "Obtaining Internal Approval" and associate all "Queried Line Items" respective case to newly created "Credits and Adjustments.
******************************************************************/ 
public with sharing class CreditAndAdjustmentApprovalProcess {
   
    /**
    *  The method will execute from the "Send Email to Agent" Process Builder and it will helps to create new "Credits and Adjustment" record,update and reference in the QLI.
    *  @name processCaseRecord
    *  @param CaseId     - List of CaseIds
    *  @return void      - void
    *  @throws exception - 
    *  @Jira Story Ref   - EDGE-119565
    **/
    @InvocableMethod
    public static void processCaseRecord(List<Id> CaseIds){
        if(!CaseIds.isEmpty()){
            List<Case> sourceCaseList = [SELECT ID,Type,Status,Total_Determination__c,Billing_Account__c,(SELECT ID,Determination_Amount__c FROM Queried_Line_Items__r) FROM Case 
            WHERE ID IN : CaseIds
            AND Status = :System.Label.Case_Status_Approval];
            if(!sourceCaseList.isEmpty()){
                getQueriedLineItems(sourceCaseList);
            }
            
        }
        
    } 
    /***   START of EDGE - 89741 
        OSAKA Team:EDGE-89741
        Sprint: 19.12
        Developer: Sasidhar Devarapalli 
        Create new CreditAndAdjustment record when the case status is changed to Initiate Adjustment and associate queried line items
        to newly created Credit and Adjustment record and calling this method from caseTrigger. 
    ***/
        public static void getQueriedLineItems(List<Case> sourceCase){
        Set<Id> queriedLineItemIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        List<Queried_Line_Item__c> updateQueriedLineItems = new List<Queried_Line_Item__c>();
        for(Case caseVar : sourceCase){
            if(caseVar.Queried_Line_Items__r != null){
            updateQueriedLineItems.addAll(caseVar.Queried_Line_Items__r);
            }
        }
        //List<Queried_Line_Item__c> updateQueriedLineItems = [SELECT id,Determination_Amount__c FROM Queried_Line_Item__c WHERE id = :queriedLineItemIds];
        List<Credits_and_Adjustments__c> createCredits = new List<Credits_and_Adjustments__c>(); 
        String recordTypeId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByName().get(System.Label.CreditAdjustmentRecType).getRecordTypeId();
        for(Case caseRec : sourceCase){
            if(caseRec.status == System.Label.Case_Status_Approval && caseRec.Type == System.Label.Case_Type && caseRec.Total_Determination__c != null && caseRec.Total_Determination__c > 0){
                Credits_and_Adjustments__c newCredits = new Credits_and_Adjustments__c();
                newCredits.Case_Number__c = caseRec.id;
                
                //Start of EDGE:112023
                newCredits.Total_Determination__c = caseRec.Total_Determination__c;
                newCredits.Billing_Account_Number_BAN__c = caseRec.Billing_Account__c;
                //End of EDGE: 112023
                caseIds.add(caseRec.id);
                newCredits.RecordTypeid = recordTypeId;
                createCredits.add(newCredits);
                //newCreditBan.Billing_Account__c = caseBan.Billing_Account__c;
                
                
            }
        }
        if(createCredits.size()>0 && !createCredits.isEmpty()){
            insert createCredits;
            queriedLineItemAssociation(createCredits,updateQueriedLineItems); 
        }
    }
    // Assocating the queried line items to Credit and Adjustment record and 
    // calling this method from getQueriedLineItems method
    public static void queriedLineItemAssociation(List<Credits_and_Adjustments__c> createCredits,List<Queried_Line_Item__c> updateQueriedLineItems){
        Map<Id,Queried_Line_Item__c> actualQueriedLineItems  = new  Map<Id,Queried_Line_Item__c>();
        for(Credits_and_Adjustments__c newCredit : createCredits){
            for(Queried_Line_Item__c queriedLineItems : updateQueriedLineItems){
                if(queriedLineItems.Determination_Amount__c > 0){
                    queriedLineItems.Credit_Adjustment__c = newCredit.id;
                    actualQueriedLineItems.put(queriedLineItems.id,queriedLineItems);
                }
            }
        }
        if(actualQueriedLineItems.size()>0 && !actualQueriedLineItems.isEmpty()){
            update actualQueriedLineItems.values();
        }
    }
     /** END of EDGE-89741  ***/
}