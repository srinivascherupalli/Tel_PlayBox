/*------------------------------------------------------------ 
Author: Mahima Gandhe 
Company: Telstra 
Description: Controller for the component OneOffcreditComponent
Test Class: OneOffCreditControllerTest 
History :
<16-04-2019> <Mahima Gandhe> <EDGE-64232 Created the class for oneoff credit functionlity> 
<16-04-2019> <Mahima Gandhe> <EDGE-64232 Made changes related to Insert logic on resubmit the same form.> 
------------------------------------------------------------*/
public  with sharing class OneOffCreditController {
    /*------------------------------------------------------------ 
Metohd: SaveCreditAdjustmentRec 
Description: Creates the record of CreditsAndAdjustents object. 
Inputs: Fields map, caseid, creditID 
Returns: Records of this object 
History 
<16-04-2019> <Mahima Gandhe>
------------------------------------------------------------*/
    @AuraEnabled
    public static Credits_and_Adjustments__c SaveCreditAdjustmentRec( Map<String, String> credAdj,string caseIDdetail, string creditID){
        Credits_and_Adjustments__c credAdjObj= new Credits_and_Adjustments__c();
        try{          
            Case cs=  [select Status from Case where id=:caseIDdetail limit 1];        
            if(cs.Status!= 'Closed')
            {
                //String credAdj,
                //Map<String, String> mapCredAdj = (Map<String, String>)JSON.deserializeUntyped(credAdj);
                credAdjObj= new Credits_and_Adjustments__c( Billing_Account_Number_BAN__c=credAdj.get('Billing_Account_Number_BAN__c'), 
                                                           Case_Number__c=caseIDdetail,
                                                           Credit_Change_Amount__c=decimal.valueOf(credAdj.get('Credit_Change_Amount__c')),
                                                           Non_Marketable_Product__c=credAdj.get('Non_Marketable_Product__c'),
                                                           Date_when_credit_was_given_to_customer__c= Date.valueOf(credAdj.get('Date_when_credit_was_given_to_customer__c')),
                                                           Reason_Code__c=credAdj.get('Reason_Code__c'));
                
                insert credAdjObj;
            }
            else
            {credAdjObj= null;}
        }
        catch(exception e)
        {
            system.debug(e.getMessage());
        }
        return credAdjObj; 
    }
    /*------------------------------------------------------------ 
Metohd: makeCallout 
Description: Make API call out to apply oneoff credit for Insolvent and Billing Credit and Debit in BDS. 
Inputs: credAdj Credit Adjustment object record
Returns: Response from callout 
History 
<16-04-2019> <Mahima Gandhe>
<26-06-2020> <Pradeep <EDGE-149471>>
------------------------------------------------------------*/
    @AuraEnabled
    public static Map<string, string> makeCallout( Credits_and_Adjustments__c credAdj,Boolean isPredebt,String caseRecord,String caseNumber){
        String selectedProduct =  getSelectedProductName(credAdj.Non_Marketable_Product__c);
        system.debug('Scenario:'+caseRecord+' for predebt flag as'+ isPredebt);
        Map<string, string> resMap= new Map<string, string>();
        try{
            if((caseRecord == System.Label.Insolvency_Management && isPredebt) || (selectedProduct == System.Label.ServiceEstablishmentProductId ))   
            {
                resMap= OnceoffCreditValidateManager.ApplyOnceOffDebit(credAdj,caseNumber); 
            }
            else{ 
                resMap= OnceoffCreditValidateManager.ApplyOnceOffCredit(credAdj,caseNumber);
            } 
            system.debug('Response :'+resMap);
        }catch(exception ex)
        {
            system.debug(ex.getMessage());
        }
        return resMap;
    }
    /*------------------------------------------------------------ 
Metohd: updateCaseDetails 
Description: Update Case and Credit orecord based of response. 
Inputs: CaseID, credAdjId,failureReason.
Returns: Records of this object 
History 
<16-04-2019> <Mahima Gandhe>
<26-06-2020> <Pradeep<EDGE-149471>>
------------------------------------------------------------*/
    @AuraEnabled
    public static void updateCaseDetails(Id CaseID, Id credAdjId,string failureReason,String caseRecord){
        Case cas= new Case(id=CaseID);
        Credits_and_Adjustments__c creAdj= new Credits_and_Adjustments__c(id=credAdjId);
        try{
            if(failureReason!= null && failureReason!='') {
                creAdj.Failure_Reason__c=failureReason;
            }
            else       {
                creAdj.Failure_Reason__c='';                
                creAdj.Submitted__c=true;
                if (caseRecord != System.Label.Insolvency_Management){
                    cas.status='Closed';
                }
            }
            update creAdj;
            update cas;
        }catch(exception ex)
        {
            system.debug(ex.getMessage());
        }
        
    }
    /*------------------------------------------------------------ 
Metohd: checkPredebtAccount 
Description: EDGE-149630 : check whether billing account is predebt or not 
Inputs: billingAccountId
Returns: return boolean value 
History 
<18-06-2020> <Pradeep<EDGE-149471>>
------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean checkPredebtAccount(String billingAccountId)
    {
        List<Billing_Account__c> accountList=[select id,PreDebt__c from Billing_Account__c where id=:billingAccountId];
        Boolean PreDebt=false;
        if (!accountList.isEmpty())       
        {
            PreDebt=accountList[0].PreDebt__c;
        }
        return PreDebt;
    }
    
     /*------------------------------------------------------------ 
Metohd: getSelectedProduct 
Description: EDGE-158381 : Get selected product list from custom meta data
Inputs: productName,caseRecordType
Returns: return  Map<String,List<Non_Marketable_Products__mdt>> values 
History 
<26-06-2020> <Pradeep<EDGE-158381>>
------------------------------------------------------------*/ 
     @AuraEnabled
        public static Map<String,List<Non_Marketable_Products__mdt>> getSelectedProduct(String productName,String caseRecordType)
    {     
        List<Non_Marketable_Products__mdt> selectedProd  ;
        Map<String,List<Non_Marketable_Products__mdt>> custMap=new Map<String,List<Non_Marketable_Products__mdt>>();
        List<Non_Marketable_Product__c> prodList=[SELECT name,specId__c FROM Non_Marketable_Product__c where id=:productName];
    
        if (!prodList.isEmpty()) {
       selectedProd=[select DeveloperName,Display_Product__c,Adjustment_Type__c,Name__c from Non_Marketable_Products__mdt WHERE Name__c =: caseRecordType AND DeveloperName =: prodList[0].specId__c];  
        }
       custMap.put('selectedProduct',selectedProd);       
        return custMap;
     }
/*------------------------------------------------------------ 
Metohd: getSelectedProductName 
Description: DPG-3598 : Get selected product Name 
Inputs: productName
Returns: return  String Non Marketable Product Name values 
------------------------------------------------------------*/     
    @AuraEnabled
    public static String getSelectedProductName(String productName)
    {     
        
        Map<String,List<Non_Marketable_Product__c>> custMap=new Map<String,List<Non_Marketable_Product__c>>();
        Non_Marketable_Product__c productItem = [SELECT name,specId__c FROM Non_Marketable_Product__c where id=:productName];
        
        return productItem.name;
     }
    
   
/*------------------------------------------------------------ 
Metohd: getselectOptions 
Description: EDGE-149471 : retrive pick list values of reason code 
Inputs: objObject,fieldName
Returns: return List <String> values 
History 
<26-06-2020> <Pradeep<EDGE-149471>>
------------------------------------------------------------*/ 
    
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, String fieldName) {
        
        List < String > allOptions = new list < String > ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry > values =  fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry value: values) { 
            allOptions.add(value.getValue());
        }
        allOptions.sort();
        return allOptions;
    }   
}