/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             13-05-2021    EDGE-212404
2.         Shubhi             02-06-2021    EDGE-216407
3.         Shubhi             16/08/2021    DIGI-13377
******************************************************************/ 
public without sharing class QLIBillingLineItemAdjustment {
    /**
    *  The method will execute from the "Send Email to Agent" Process Builder and it will helps to calculate the QLI Billing Line Item Adjustment from BDS.
    *  @name processCaseRecord
    *  @param CaseId     - Case Ids
    *  @return void      - 
    *  @throws exception - 
    *  @Jira Story Ref   - EDGE-111167
    */
    
    @InvocableMethod
    public static void processCaseRecord(List<Id> caseIds){
        system.debug('caseIds---------->'+caseIds);
        id loggedInUser = userinfo.getProfileId();
        List <Profile> profileName= [select Name from Profile where id = :loggedInUser LIMIT 1];
        system.debug('Assurance Service Agent Before');
        Map<string,EnvironmentVariable__c> featureToggleMap=EnvironmentVariable__c.getAll();
        if ( profileName[0].Name !='Assurance Service Agent') {
            system.debug('Callout---->');
            if(featureToggleMap!=null && featureToggleMap.containsKey('enableBillingEnquiry1663') && featureToggleMap.get('enableBillingEnquiry1663').value__c=='true'){
                getMaxCreditAndQLIEnrich_bulk(caseIds); // added by subhi for Edge-216407
            }else{
                getMaxCreditAmount(caseIds); //commented by shubhi for Edge-216407
            }
        }
        system.debug('Assurance Service Agent After');
    }
    //Overriding the future method for invoking from lightning component.
     @future(callout = true)
    public static void getMaxCreditAmount(List<Id> caseIds){
        //if(user profile != Service Assurance Agent
        getMaxCredit(caseIds);
    }
    /**
    * The method helps to fetch the required fields for the BDS payload.
    *  @name getMaxCreditAmount
    *  @param CaseId     - Case Ids
    *  @return void      - 
    *  @throws exception - 
    *  @Jira Story Ref   - EDGE-111167
    */

    public static void getMaxCredit(List<Id> caseIds){   
        list<String> chargeTypeList = new List<String>{System.Label.QLI_Charge_Type_Credit_Charge,System.Label.QLI_Charge_Type_Usage_Detail};
        list<Queried_Line_Item__c> qli_List = [SELECT Id,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Line_Number__c 
            FROM Queried_Line_Item__c 
            WHERE Case__c <> NULL 
            AND Case__r.Billing_Account__r.Billing_Account_Number__c <> NULL 
            AND Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c <> NULL 
            AND Invoice_Line_Item__r.Charge_Identifier__c <> NULL 
            AND Invoice_Line_Item__r.Charge_Type__c <> NULL
            /**  Start of EDGE:113051
            @Modified/updatedBy: Sasidhar Devarapalli
            @team              : Osaka
            @Description:Updating the invoice line number from Invoice Line Item object instead of queried line item object
            **/
            AND Invoice_Line_Item__r.Invoice_Line_Number__c <> NULL
            //End of EDGE:113051
            AND Invoice_Line_Item__r.Charge_Type__c NOT IN : chargeTypeList
            AND Case__c IN : caseIds];
         if(!qli_List.isEmpty() && qli_List.size() > 0){
             QLIAdjustmentHandler.calculateEligibleCreditAmount(qli_List);
             System.debug('qli_List result-->'+qli_List);
         }     
    }
    /**
    * The method helps to fetch the required fields for the BDS payload and also send callout to invoice MS
    *  @name getMaxCreditAndEnrichQLI
    *  @param CaseId , invoiceNumber
    *  @return void      - 
    *  @Jira Story Ref   - EDGE-212404(added by shubhi)
    */
    public static void getMaxCreditAndEnrichQLI(String caseId, String invoiceNumber){
        if(String.isNotBlank(caseId) && String.isNotBlank(invoiceNumber)){
            List<Id> caseCreated = new List<Id> {caseId};
            getMaxCredit(caseCreated);
            if(!Test.isRunningTest())
                ID jobID = System.enqueueJob(new QLIEnrichQueueable(caseId,InvoiceNumber));          
          }
    }
     /**
    * The method helps to fetch the required fields for the BDS payload and also send callout to invoice MS for non assisted flow
    *  @name getMaxCreditAndEnrichQLI
    *  @param CaseId , invoiceNumber
    *  @return void      - 
    *  @Jira Story Ref   - EDGE-216407(added by shubhi)
    */
    public static void getMaxCreditAndQLIEnrich_bulk(List<Id> caseIds){   
        Map<String,Set<String>> caseToInvoicenumListMap=new Map<String,Set<String>>();
        if(caseIds!=null && !caseIds.isEmpty()){
            getMaxCreditNew(caseIds);
        }
        ////DIGI-13377  start 
        for(Queried_Line_Item__c qli:Model_QueriedLineItems.getQLIforGetMax(caseIds)){
            if(qli.processedByMS__c!=1){
                Set<String> invoiceNumSet=new Set<String>();
                if(caseToInvoicenumListMap!=null && caseToInvoicenumListMap.containskey(qli.Case__c)){
                    invoiceNumSet.addAll(caseToInvoicenumListMap.get(qli.Case__c));
                }
                invoiceNumSet.add(qli.Invoice_Line_Item__r.Invoice__r.name);
                caseToInvoicenumListMap.put(qli.Case__c,invoiceNumSet);
            }
        }
        ////DIGI-13377 end
        if(caseToInvoicenumListMap!=null && !caseToInvoicenumListMap.isEmpty()){
            EnrichQLI(caseToInvoicenumListMap);
        }

    }
      /**
    * The method helps to fetch the required fields for the BDS payload and also send callout to invoice MS for non assisted flow
    *  @name getMaxCreditAndEnrichQLI
    *  @param CaseId , invoiceNumber
    *  @return void      - 
    *  @Jira Story Ref   - EDGE-216407(added by shubhi)
    */
    @future(callout = true)
    //changed method to future //DIGI-13377 
    private static void getMaxCreditNew (List<Id> caseIds){ 
        List<Queried_Line_Item__c> qli_List=new  list<Queried_Line_Item__c> ();
        qli_List=Model_QueriedLineItems.getQLIforGetMax(caseIds);
        if(!qli_List.isEmpty() && qli_List.size() > 0){
            QLIAdjustmentHandler.calculateEligibleCreditAmount(qli_List);
        } 
        
    }
    /**
    * The method helps to fetch the required fields for the BDS payload and also send callout to invoice MS for non assisted flow
    *  @name getMaxCreditAndEnrichQLI
    *  @param CaseId , invoiceNumber
    *  @return void      - 
    *  @Jira Story Ref   - EDGE-216407(added by shubhi)
    */
    private static void EnrichQLI(Map<String,Set<String>> caseToInvoicenumListMap){
        if(caseToInvoicenumListMap!=null && !caseToInvoicenumListMap.isEmpty()){
            ID jobID = System.enqueueJob(new QLIEnrichQueueable(caseToInvoicenumListMap));         
        }
    } 
}