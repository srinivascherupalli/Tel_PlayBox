/******************************************************************************************************************************
Class Name : Model_ServiceAddOns
Test Class : Model_ServiceAddOnsTest 
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           19/10/2020    EDGE-173469(New Class)           20.14
2.      Aman Soni           29/10/2020    EDGE-176697                      20.15
3.      Aman Soni           28/01/2021    EDGE-191077                      21.02
4.      Aman Soni           05/02/2021    EDGE-194029                      21.02
5.      Aman Soni           17/02/2021    EDGE-203220                      21.03
******************************************************************************************************************************/
public with sharing class Model_ServiceAddOns{
    /*  
    * Method Name      : getServAddOnsForCleanUp
    * Input Parameter  : List<cscfga__Product_Basket__c> basketLst
    * Return Parameter : List<Service_Add_On__c>
    * Description      : will return service add ons records against basket List
    * Owner            : Aman Soni
    * Jira             : EDGE-194029
    */
    public static List<Service_Add_On__c> getServAddOnsForCleanUp(List<cscfga__Product_Basket__c> basketLst){
        List<Service_Add_On__c> servAddOnLst = new List<Service_Add_On__c>();
        Map<ID, Service_Add_On__c> servAddOnMap = new Map<ID, Service_Add_On__c>([select id,Product_End_Date__c,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Product_Basket__c,Transaction_Type__c, SKU__c from Service_Add_On__c where Product_Basket__c IN: basketLst FOR UPDATE]);    
        if(servAddOnMap != null){
            servAddOnLst = servAddOnMap.values(); 
        }         
        return servAddOnLst;
    }
    
    /*  
    * Method Name      : retSyncRemPendingBeforeSave
    * Input Parameter  : List<Id> addOnList
    * Return Parameter : Set<Service_Add_On__c>
    * Description      : will return service add ons records against addOnList
    * Owner            : Aman Soni
    * Jira             : EDGE-191077 
    */
    public static Set<Service_Add_On__c> retSyncRemPendingBeforeSave(List<Id> addOnList){
            List<Service_Add_On__c> servAddOnLst = new List<Service_Add_On__c>();
            Map<ID, Service_Add_On__c> servAddOnMap = new Map<ID, Service_Add_On__c>([select Product_End_Date__c,id,name,Legacy_Service__r.Select__c,Product_Basket__c,Solution_Id__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c, SKU__c from Service_Add_On__c where id IN: addOnList FOR UPDATE]);
            if(servAddOnMap != null){
                servAddOnLst = servAddOnMap.values(); 
            }          
            Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(servAddOnLst);
        return servAddOnSet;
    }
    
    /*  
    * Method Name      : getSynRemPendingAddOnsForTransition
    * Input Parameter  : String basketId, String solutionId, String contractType, String category, String opptyType)
    * Return Parameter : List<Service_Add_On__c>
    * Description      : will return service add ons records against input parameters
    * Owner            : Aman Soni
    * Jira             : EDGE-203220(20.03)
    */
    public static Set<Service_Add_On__c> getSynRemPendingAddOnsForTransition(String basketId, String solutionId, String contractType, String category, String opptyType){
        List<Service_Add_On__c> servAddOnLst = new List<Service_Add_On__c>();
        if(String.isNotBlank(basketId) && String.isNotBlank(contractType) && contractType.equalsIgnoreCase('MRO') && opptyType != 'Migration'){
            Map<ID, Service_Add_On__c> servAddOnMap = new Map<ID, Service_Add_On__c>([select id,Product_End_Date__c,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Product_Basket__c,Transaction_Type__c, SKU__c from Service_Add_On__c where Legacy_Service__r.Eligibility_Status__c =: Label.LegacyServiceEligible and Legacy_Service__r.Product_Basket__c =: basketId and Contract_Type__c =: contractType and Legacy_Service__r.Select__c = false and Status__c ='Sync Removal Pending' and Solution_Id__c =: solutionId and Transaction_Type__c = 'Transition' limit 1000 FOR UPDATE]);
            if(servAddOnMap != null){
                servAddOnLst = servAddOnMap.values(); 
            }           
        }
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(servAddOnLst);
        return servAddOnSet;
    }

    /*  
    * Method Name      : returnServiceAddonRecords
    * Input Parameter  : String basketId, String solutionId, String contractType, String category, Id accountId, String opptyType
    * Return Parameter : Set<Service_Add_On__c
    * Description      : will return all the service add ons records against the input parameters
    * Owner            : Aman Soni
    * Jira             : EDGE-191077/EDGE-194029(Solution Id check)
    */
    public static Set<Service_Add_On__c> returnServiceAddonRecords(String basketId, String solutionId, String contractType, String category, Id accountId, String opptyType){
        List<Service_Add_On__c> servAddOnLst = new List<Service_Add_On__c>();
        if(String.isNotBlank(contractType)){
            if(String.isNotBlank(basketId) && opptyType != 'Migration'){   
                //START: Added Product_End_Date__c for EDGE-215103            
                Map<ID, Service_Add_On__c> servAddOnMap = new Map<ID, Service_Add_On__c>([select Product_End_Date__c,id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Product_Basket__c,Transaction_Type__c, SKU__c  from Service_Add_On__c where Legacy_Service__r.Eligibility_Status__c =: Label.LegacyServiceEligible and Legacy_Service__r.Product_Basket__c =: basketId and Contract_Type__c =: contractType and ((Status__c ='Ready for Sync') or (Status__c ='Sync Completed' and Solution_Id__c =: solutionId)) and Transaction_Type__c = 'Transition' and Legacy_Service__r.Select__c = true limit 1000 FOR UPDATE]);
                //END for EDGE-215103             
                if(servAddOnMap != null){ 
                servAddOnLst = servAddOnMap.values(); 
                }
            }
            if(accountId != null && String.isNotBlank(opptyType) && opptyType.equalsIgnoreCase('Migration')){
                //START: Added Product_End_Date__c for EDGE-215103
                //Map<ID, Service_Add_On__c> servAddOnMap = new Map<ID, Service_Add_On__c>([select Product_End_Date__c,id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c, SKU__c from Service_Add_On__c where Contract_Type__c =: contractType and (Status__c in ('Ready for Sync','Sync Removal Completed') or (Status__c = 'Sync Completed' and Product_Basket__c =: basketId and Solution_Id__c =: solutionId)) and Account__c =: accountId and Transaction_Type__c = 'Migration' limit 1000 FOR UPDATE]);    
                //Added Original_Contract_Term__c in query by Jay(Osaka) as a part of DIGI-10894 
                Map<ID, Service_Add_On__c> servAddOnMap = new Map<ID, Service_Add_On__c>([select Product_End_Date__c,id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c, SKU__c,Original_Contract_Term__c from Service_Add_On__c where Contract_Type__c =: contractType and (Status__c in ('Ready for Sync','Sync Removal Completed') or (Status__c = 'Sync Completed' and Product_Basket__c =: basketId and Solution_Id__c =: solutionId)) and Account__c =: accountId and Transaction_Type__c = 'Migration' limit 1000 FOR UPDATE]);
                //END for EDGE-215103
                if(servAddOnMap != null){
                    servAddOnLst = servAddOnMap.values(); 
                }
            }           
        }                  
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(servAddOnLst);
        return servAddOnSet;
    }   
}