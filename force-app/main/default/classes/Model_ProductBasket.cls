/*************************************************************************************************
Name : Model_ProductBasket
TestName:Model_ProductBasketTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Ankit              2-Nov-2020        EDGE-181979
2.         shubhi           7/01/2021       EDGE-170016 modified SOQL to fetch amentType of basket in GetBasket method
3.        Vamsi          8/01/2021       EDGE-192911 modified SOQL to fetch RecordTypeID,Frameagreement,DeviceCareContact,PreviousBasket of basket in GetProductBasket method
4.        Shubhi            8/01/2021       EDGE-170016 modified SOQL to fetch amentType of basket in GetProductBasket method
5.        Aman Soni         20/01/2021      EDGE-191076 Added Opportunity_Type__c in Soql in getProductBasket method for EDGE-191076
6.        Shubhi            9/2/2021        EDGE-193068 Added new method getProductBasketAccount to get Account details
7.        Kamlesh           10/2/2021       EDGE-199065 Added custom field which is required  in getProductBasket method
8.       Aditya             19/02/2021      EDGE-197580
9.       Shubhi/Vamsi       22-Feb-2021     EDGE-152457/EDGE-152456
10.      Kamlesh            25-Feb-2021     EDGE-199074/EDGE-205509
11.      Aman Soni          02-Mar-2021     EDGE-191138 Get Basket for CHOWN Journey
12.      Shubhi             12/03/2021      Edge-202203(error handling)
===============================================================================================================================
***************************************************************************************************/

public with sharing class Model_ProductBasket{
    /*  
    * Method Name : getBasketId
    * Input Parameter  : basketId
    * Return Parameter : returns Basket Record
    * Owner : Ankit Goswami
    * Jira : EDGE-181979
   */
    public static cscfga__Product_Basket__c getProductBasket(String basketId){
       List<cscfga__Product_Basket__c> lstBasketRecord= new List<cscfga__Product_Basket__c>();
       if(String.isNotBlank(basketId)){
          // added by Vamsi for EDGE-192911 on 1/7/2021 //EDGE-170016 || Added Opportunity_Type__c for EDGE-191076 by Aman Soni// EDGE-199065
          // EDGE-199065 Added cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,csbb__Synchronised_With_Opportunity__c custom field
          //EDGE-199074/EDGE-205509 Added cscfga__Opportunity__r.StageName,OF_Reversal_Inserted__c,sync_job_Id__c
          lstBasketRecord=[select id,Name,csordtelcoa__Basket_Stage__c,
                           csbb__Account__c,referencenumber__c,
                           Order_Requester__c,Project_Complexity__c,
                           RecordTypeId,RecordType.name,recordtype.developername,
                           Amend_Type__c,Account_Id__c, 
                           cscfga__Opportunity__c,BasketType__c,
                           Opportunity_Type__c,csconta__Frame_Agreement__c,
                           Device_Care_Contact__c,Primary_Basket__c,Project_ID__c,
                           sync_job_Id__c,csordtelcoa__Previous_Product_Basket__c,cscfga__Basket_Status__c,csordtelcoa__Previous_Product_Basket__r.csbb__Account__c,
                           cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.StageName,OF_Reversal_Inserted__c,cscfga__Opportunity__r.Type,csbb__Synchronised_With_Opportunity__c 
                           from cscfga__Product_Basket__c
                           where id=:basketId];// added by Vamsi for EDGE-192911 on 1/7/2021 //EDGE-170016 || Added Opportunity_Type__c for EDGE-191076 by Aman Soni
       } 
       /*if(lstBasketRecord.size()>0)
           return lstBasketRecord[0];
       return null;*/
       return lstBasketRecord.size()>0 ? lstBasketRecord[0] : new cscfga__Product_Basket__c();
   }
   
   /*  
    * Method Name : getProductBasketonLoadSolution
    * Input Parameter  : basketId
    * Return Parameter : returns Basket Record
    * Owner : Shubhi V
    * Jira : EDGE-170016
   */
    public static cscfga__Product_Basket__c getProductBasketonLoadSolution(String basketId){
       
       cscfga__Product_Basket__c basketRecord= new cscfga__Product_Basket__c();
       //EDGE-98299  - Added CIDN in the GetBasket Method Query
       //Laxmi - EDGE-135885 - Added Basket Name in the below Query
       //EDGE-133590- Added Solutions inner query to Basket Query,EDGE-162597-Added Product configs to the query
       //EGDGE-170544 -Added recordType.name in the query 
       //EDGE-170016 - added amendtype in query
       ///EDGE-197580 added basket type in query
       //Shubhi Edge-152456 added Opportunity_Type__c
        List<cscfga__Product_Basket__c> lstBasketRecord= new List<cscfga__Product_Basket__c>();
       if(String.isNotBlank(basketId)){
             lstBasketRecord = [select Name, csordtelcoa__Change_Type__c,
                                csconta__Frame_Agreement__c , 
                                cscfga__Opportunity__r.Product_Type__c ,
                                csconta__Contract__r.CustomerSignedDate, 
                                csordtelcoa__Basket_Stage__c,Opportunity_Type__c, 
                                csbb__account__c,cscfga__Opportunity__c, 
                                csbb__account__r.CIDN__c,
                                recordType.name,
                                Amend_Type__c,
                                BasketType__c,
                                (select id, name from cssdm__Solutions__r), 
                                (select id, name, Marketable_Offer__r.Offer_ID__c from cscfga__Product_Configurations__r)      
                             from cscfga__Product_Basket__c
                            where id = :basketId LIMIT 1];
         
       }
       return lstBasketRecord.size()>0 ? lstBasketRecord[0] : new cscfga__Product_Basket__c();
    }
   

    /*  
    * Method Name : getProductBasketAccount
    * Input Parameter  : basketId
    * Return Parameter : returns Basket Record
    * Owner : Shubhi V
    * Jira : EDGE-193068
   */
   // updated by shubhi for EDGE-152457(chown)
   // updated by shubhi added OF_Reversal_Inserted__c for Edge-202203(error handling)
   public static List<cscfga__Product_Basket__c> getProductBasketAccount(Set<String> basketIdSet){
       List<cscfga__Product_Basket__c> lstBasketRecord= new List<cscfga__Product_Basket__c>();
       if(basketIdSet!=null && !basketIdSet.isEmpty()){
          lstBasketRecord=[select id,
                           csordtelcoa__Basket_Stage__c,csbb__Account__c,
                           recordtype.developername,
                           referencenumber__c,Order_Requester__c,
                           Project_Complexity__c,RecordTypeId,
                           RecordType.name,Amend_Type__c,Account_Id__c, 
                           cscfga__Opportunity__c,BasketType__c,
                           Opportunity_Type__c,csconta__Frame_Agreement__c,
                           Device_Care_Contact__c,Primary_Basket__c,
                           csordtelcoa__Previous_Product_Basket__c,Project_ID__c,sync_job_Id__c,
                           csbb__Account__r.CIDN__c,cscfga__Opportunity__r.Account.Name,cscfga__Opportunity__r.Accountid,Description__c,
                           csbb__Account__r.Parent_CIDN__c,csbb__Account__r.Ultimate_Parent_CIDN__c,OF_Reversal_Inserted__c,csbb__Synchronised_With_Opportunity__c
                           from cscfga__Product_Basket__c where id IN:basketIdSet];
       } 
           return lstBasketRecord;
   }
   
   /*  
   * Input Parameter 1 : Set<Id> basketIds
   * Return Parameter  : Set<cscfga__Product_Basket__c>
   * Owner             : Aman Soni
   * Jira              : EDGE-191138
   */
   public static Set<cscfga__Product_Basket__c> getbasketForChown(Set<Id> basketIds){
       List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
       basketLst = [select id,csbb__Account__c,BasketType__c from cscfga__Product_Basket__c where Id IN: basketIds];
       Set<cscfga__Product_Basket__c> basketSet = new Set<cscfga__Product_Basket__c>(basketLst);
       return basketSet;
   }   
  
}