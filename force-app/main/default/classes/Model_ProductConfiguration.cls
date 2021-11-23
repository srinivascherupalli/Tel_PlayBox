/*************************************************************************************************
Name : Model_ProductConfiguration
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Shubhi             1-july-2020       EDGE-147513 (new )
2.         Ankit              2-Nov-2020        EDGE-181979
2.         Aman Soni          5-Oct-2020        EDGE-176693
3.         Shubhi V           18-Nov-2020       EDGE-185011
4.         Shubhi V           15-12-2020        EDGE-185856
5.         Aman Soni          05-01-2021        EDGE-196842(Defect)
6.         Kamlesh Kumar      10-2-2021         EDGE-199065(Added custom field and sub query which is missing in getConfigList method)
===============================================================================================================================
***************************************************************************************************/

public with sharing class Model_ProductConfiguration{
   
     /*  
     * Method Name : getConfigMap
     * Input Parameter 1 : accountId
     * Return Parameter : returns Billiing acc with finalization and pending Finalization status
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    private static String correlationId =   GuidUtil.NewGuid();
    public static Map<String,cscfga__Product_Configuration__c> getConfigMap(String basketId,Set<String> attNameFilterSet){
        
        Map<String,cscfga__Product_Configuration__c> pcMap=new Map<String,cscfga__Product_Configuration__c>();
        
        if(String.isNotBlank(basketId) && attNameFilterSet!=null && attNameFilterSet.size()>0){
               for(cscfga__Product_Configuration__c pc:[Select 
            id,ConfigurationType1__c,cssdm__solution_association__c, cscfga__Product_Basket__c,Type__c,cscfga__Configuration_Status__c,cscfga__pricing_status__c,
            ( SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r where name IN:attNameFilterSet) from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basketId]){
                pcMap.put(pc.id,pc);
            }
            
        } 
            return pcMap;
        }
    
     /*  
     * Method Name : getConfigList
     * Input Parameter  : basketId,Pd Name
     * Return Parameter : returns List of product config
     * Owner : Ankit Goswami
     * Jira : EDGE-181979
    */
     public static list<cscfga__Product_Configuration__c> getConfigList(String basketId){
         List<cscfga__Product_Configuration__c> pclist=new List<cscfga__Product_Configuration__c>();
        if(String.isNotBlank(basketId)){
            //EDGE-199065
            pclist=[Select 
            id,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.name,cscfga__Product_Definition__r.product_Specification__c,Name,Marketable_Offer__r.name,cscfga__Configuration_Status__c,cscfga__total_contract_value__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Description__c,cscfga__Contract_Term__c,Type__c,configGUID__c,ConfigurationType1__c,
            (
                SELECT id, Name, cscfga__Value__c
                FROM cscfga__Attributes__r where name IN ('Product','BillingAccountAttName')
            )                                                   
            from cscfga__Product_Configuration__c 
            where 
            cscfga__Product_Basket__c=:basketId ];
            
        }
        //END EDGE-199065
        return pclist;
    }
    
     /*  
     * Method Name      : getConfigListForTTRUpdate
     * Input Parameter  : basketId,transitionLabel
     * Return Parameter : returns List of product config
     * Description      : query all the transition configurations under the required basket 
     * Owner            : Aman Soni
     * Jira             : EDGE-176693 || EDGE-196842
     */
     public static Map<Id, cscfga__Product_Configuration__c> getConfigListForTTRUpdate(String basketId, String transitionLabel){
        //List<cscfga__Product_Configuration__c> pclist=new List<cscfga__Product_Configuration__c>();//Commented for EDGE-196842 by Aman Soni
        //Added for EDGE-196842 by Aman Soni || Start
        Map<Id, cscfga__Product_Configuration__c> pcMap;
        List<String> subTypeList=transitionLabel.split(',');
        //Added for EDGE-196842 by Aman Soni || End
        if(String.isNotBlank(basketId)){
            pcMap = new Map<Id, cscfga__Product_Configuration__c>([Select id,Name,subType__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE subType__c IN: subTypeList and cscfga__Product_Basket__c =: basketId]);            
        }
        return pcMap; 
    }
     /*  
     * Method Name      : getPC
     * Input Parameter  : PCid
     * Return Parameter : returns product config
     * Owner            : Shubhi V
     * Jira             : EDGE-185011/ Edge-185856(updated query)
     */
     public static cscfga__Product_Configuration__c getConfig(String pcid){
        cscfga__Product_Configuration__c pc=new cscfga__Product_Configuration__c();
        if(String.isNotBlank(pcid)){
            pc=[Select id,csordtelcoa__Replaced_Product_Configuration__r.cssdm__solution_association__c,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c FROM cscfga__Product_Configuration__c WHERE id =: pcid];            
        }
        return pc; 
    }

    /*  
     * Method Name      : getPC
     * Input Parameter  : PCid
     * Return Parameter : returns product config
     * Owner            : Shubhi V
     * Jira             : EDGE-185011/ Edge-185856(updated query)
     */
     public static list<cscfga__Product_Configuration__c> getConfigWithReplacedSubs(list<String> subscriptionIdList){
        list<cscfga__Product_Configuration__c> pcList = new list<cscfga__Product_Configuration__c>(); 
        try{
            for(cscfga__product_configuration__c pc : [Select Id, cscfga__product_basket__c, cscfga__product_basket__r.Name,
                                                  cscfga__product_basket__r.csordtelcoa__Basket_Stage__c, cscfga__product_basket__r.OwnerId,
                                                  cscfga__product_basket__r.Owner.Name, cscfga__product_basket__r.Owner.Email 
                                                  from cscfga__product_configuration__c 
                                                  where csordtelcoa__replaced_subscription__c IN : subscriptionIdList and 
                                                  cscfga__product_basket__r.csordtelcoa__Basket_Stage__c != 'Cancelled']){
                                                    
                                                    pcList.add(pc);
                                                }
                                                return pcList;
         
        }catch(Exception e) {
            GenericUtilityClass.logException('Model_ProductConfiguration','getReplacedSubs','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while submitting CoBA request',C2O_ExceptionHandler.Capability.ORD);
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
    }  
        

}