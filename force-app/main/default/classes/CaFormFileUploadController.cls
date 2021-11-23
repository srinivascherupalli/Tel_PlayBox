/*----------------------------------------------------------------------
EDGE        -142351
Class       -CaFormFileUploadController
Description -Port Out Reversal screen to attach a signed Reversal Authority PDF document
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
public with sharing class CaFormFileUploadController {
    /*----------------------------------------------------------------------
EDGE        -142351
Method      -getActiveCustomerAuthorityForm
Description -fetch active CA formto show on UI
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
    @AuraEnabled public static List<Customer_Authority_Form__c> getActiveCustomerAuthorityForm(String basketId){
        List<cscfga__Product_Basket__c> basketList=getBasketDetails(basketId);
        return [SELECT id,Is_active__c,Account__c,Opportunity__c,CA_Expiry_Date__c,Name,Customer_Authorised_date__c,CA_status__c,CreatedDate FROM Customer_Authority_Form__c WHERE Opportunity__c =:basketList[0].cscfga__Opportunity__c AND is_active__c=true LIMIT 1];
    }
    /*----------------------------------------------------------------------
EDGE        -142351
Method      -getBasketDetails
Description -fetch basket deatils from basketid
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
    public static List<cscfga__Product_Basket__c> getBasketDetails( String basketId){
        return [SELECT csbb__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c where id =:basketId LIMIT 1];
    }
    /*------------------------------------------------------------------------------------
EDGE        -142351
Method      -saveFile
Description -save uploaded file to newly created CA Form and make old CA form Inactive
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------*/
    @AuraEnabled public static void saveFile(Date cafDate,String basketId,String fileName, String base64Data, String contentType,Boolean isRegenerateCAForm)  {
        Savepoint sp = Database.setSavepoint();
        List<Customer_Authority_Form__c> cafList= getActiveCustomerAuthorityForm(basketId);
        List<cscfga__Product_Basket__c> basketList=getBasketDetails(basketId);
        Customer_Authority_Form__c caf=new Customer_Authority_Form__c();
        caf.Account__c=basketList[0].csbb__Account__c;
        caf.Opportunity__c=basketList[0].cscfga__Opportunity__c;
        caf.Customer_Authorised_date__c=cafDate;
        caf.Is_active__c=true;
        caf.CA_status__c='Active';
        try{
            Insert caf;
           ConstantMetadataUtility.uploadFile(caf.ID, fileName, base64Data,contentType);
            //EDGE-149259-Dheeraj Bhatt-Ability to regenerate CA form for port out reversal order.
            if(isRegenerateCAForm==true){
                updateCaDateInServiceForRegenrateCaForm(basketId,caf.Customer_Authorised_date__c,label.PortOutReversal);
            }
            List<Customer_Authority_Form__c> cafupdateList = new List<Customer_Authority_Form__c>();
            for(Customer_Authority_Form__c ca:cafList)
            {
                if(ca.Is_active__c==true){
                    ca.Is_active__c=false;
                    ca.CA_status__c='Inactive';
                    cafupdateList.add(ca);
                }  
            }
            if(!cafupdateList.isEmpty()){
                update cafupdateList;
            }
        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug('Exception ocured at line number'+ex.getLineNumber()+' due to'+ex.getMessage());
        }   
    }
    /*-------------------------------------------------------------------------------
EDGE        -150285
Method      -updateCaDateInServiceForRegenrateCaForm
Description -Update customer Authorised Date in port out reversal number service record.
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------*/
    public static void updateCaDateInServiceForRegenrateCaForm(Id basketId,Date customerAuthorisedDate,String type){
        List<cscfga__Product_Basket__c> basketList=[SELECT id,Primary_Basket__c,cscfga__Opportunity__c, 
                                                    (SELECT id,Type__c,Basket__c,Service_Id__c FROM Numbers__r WHERE 
                                                     Type__c =:type AND Product_Configuration__c != NULL LIMIT 1) 
                                                    FROM cscfga__Product_Basket__c WHERE  id =:basketId  LIMIT 1];
        if(!basketList[0].Numbers__r.isEmpty()){
            List<csord__Service__c> serviceList=[SELECT Id,CA_Expiry_Date__c,csordtelcoa__Service_Number__c, 
                                                 Customer_Authorised_date__c,Scenario_Type__c FROM csord__Service__c
                                                 WHERE csordtelcoa__Service_Number__c =:basketList[0].Numbers__r[0].Service_Id__c 
                                                 AND Scenario_Type__c =:type ];
            if(!serviceList.isEmpty()){
                serviceList[0].Customer_Authorised_date__c=customerAuthorisedDate;
                update serviceList;
            }
        }
    }  
}