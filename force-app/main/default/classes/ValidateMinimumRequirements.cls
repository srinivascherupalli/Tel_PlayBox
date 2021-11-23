/*************************************************************************************************
Name : ValidateMinimumRequirements
Description : Used to validate minimum two customer sites per basket

1.     13-Nov-2019 .        Updated the condition for NgUC sync issue with additional criteria. deployed via defect EDGE - EDGE-123418
2.     06-Dec-2019       StarData MOD ORDER - Not able to modify single site EDGE-125039
3.    26-Jun-2020         Shubhi    20.09   EDGE-147513    BillingAcc check
4.    16-07-2020		shubhi for Pc name validation fix EDGE-162182
5.    23-07-2020		EDGE-165048 changes for modify fix nugc
6.      Vivek           10/04/2021    DIGI-14126          - FIX FOR REMOVING VALIDATION IN CHOWN

***************************************************************************************************/
public with sharing class ValidateMinimumRequirements{   // added with sharing to remove vulnerability 
    
    /*************************************************************************************************
Method Name : run(basketId)
Description : Used to validate minimum two customer sites per basket.
Called from CustomButtonOpportunitySync class.
***************************************************************************************************/   
    static String PROD_CONFIGURATION_TYPE_MODIFY = 'Modify';
    //Fixed existing hard coded value issues by Venkat during EDGE - 98375 deployment
    static String prdDefNames = System.Label.CWP_ProDefNames;
    static List<String> prddefnamelst = prdDefNames.split(',');
    //static List<String> prddefnamelst = new List<String>{'Mobility' ,'IP Site', 'Connected Workplace'};
    
    public static string run(Id basketId)
    {   
        System.debug('product definition list:'+prddefnamelst);
        System.debug('basketId: '+basketId);
        boolean tcPresent = false;
        boolean uctPresent = false;
        Boolean isCHOWNBasket =false; // DIGI-14126
        if(basketId != null && !String.isBlank(basketId)){
        for(cscfga__Product_Configuration__c pc : [select OfferName__c,Name,ConfigurationType1__c,Type__c, cscfga__Product_Basket__r.Opportunity_Type__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and OfferName__c != null]){
            System.debug('Display Product Configuration:' +pc);
            //Modified by Sandip/Venkat for NgUC - UC Tenancy validation check on Sync - Related to EDGE - 98375
            //Added  additional criteria for sync issue by Venkat // commented PC name condition for EDGE-162182
            // added solution component check for EDGE-165048
            if(pc.OfferName__c == System.Label.NextGenUC && pc.ConfigurationType1__c=='SolutionComponent' && String.isNotBlank(pc.Type__c) && pc.Type__c == 'New') 
            {
                tcPresent = true;
            }else if(pc.OfferName__c == System.Label.UnifiedCommunicationTenancy){
                uctPresent = true;
            }

            if(pc.cscfga__Product_Basket__r.Opportunity_Type__c == 'CHOWN'){
                isCHOWNBasket = true;
            }
            //DIGI-14126
        }
        }
        if(tcPresent){
            if( !isCHOWNBasket){
                if(!uctPresent){
                    return 'error' +'-'+System.Label.Label_UnifiedCommunicationTenancyNotPresent_Error;
                }else if(uctPresent){
                    return 'ok';
                }
            }

            if( isCHOWNBasket ){
                return 'ok';
            }
            
        }
        else if(uctPresent){//EDGE-137491 Added to show validation error if TC is not present in basket
            return 'error' +'-'+System.Label.Label_UnifiedCommunicationTenancyPresent_Error;
        }

        //Flag to if iIPVPCount and iUCECount is checked
        Boolean checkIpvpAndUceCount = false;    
        //Querying CWP products under the basket for modular basket
        cscfga__Product_Basket__c basket = [Select id, TransitionComplete__c,csbb__Account__c,cscfga__Opportunity__c , cscfga__Opportunity__r.Type,(Select id from cscfga__Product_Configurations__r where cscfga__Product_Definition__r.Name In :prddefnamelst) from cscfga__Product_Basket__c where id=:basketId];
        
        Id accountId = basket.csbb__Account__c;
        
        //Check if there are other subscriptions under the account of the basket which have different sites
        Integer iIPSiteCount = 0, iIPVPNCount = 0, iUCECount = 0;
        System.debug('ValidateMinimumRequirements run basket: '+ basket);
        System.debug('ValidateMinimumRequirements run EnvironmentVariable__c: '+ EnvironmentVariable__c.getValues('ValidationIPUCE').Value__c);
        String MacAddRecords1 = EnvironmentVariable__c.getValues('ValidationIPUCE').Value__c;
        System.debug('[ValidateMinimumRequirements]##### '+ MacAddRecords1 );
        
        if(MacAddRecords1=='1'){
            
            if(accountId != null){  
                List<csord__Subscription__c> lstSubFromAccount = [SELECT id, Name FROM csord__Subscription__c WHERE csord__Account__c =:accountId and csord__Status__c!='Cancelled'];
                for(csord__Subscription__c subFromAccount : lstSubFromAccount)
                {
                    if(subFromAccount.Name == System.Label.IP_Site)
                    {
                        iIPSiteCount++;
                    }
                    else if(subFromAccount.Name == System.Label.IP_Network)
                    {
                        iIPVPNCount++;
                    }
                    else if(subFromAccount.Name == System.Label.UC_Config_Name)
                    {
                        iUCECount++;
                    }
                }
            }
            List<cscfga__Product_Configuration__c> lstProdConfig = [Select id, Name, cscfga__Product_Definition__r.name, Type__c from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id =:basketId];
            system.debug('[ValidateMinimumRequirements]***********prodConfig.cscfga__Product_Definition__r.name : '+lstProdConfig);
            
            for(cscfga__Product_Configuration__c prodConfig : lstProdConfig)
            {
                if(prodConfig.Type__c == PROD_CONFIGURATION_TYPE_MODIFY){
                    checkIpvpAndUceCount = true;
                }
                system.debug('[ValidateMinimumRequirements]***********prodConfig.cscfga__Product_Definition__r.name : '+prodConfig.cscfga__Product_Definition__r.name);
                if(iIPSiteCount < 2 && prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Site)
                {
                    iIPSiteCount++;
                }
                if(prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Network)
                {
                    iIPVPNCount++;
                }
                if(prodConfig.cscfga__Product_Definition__r.name == System.Label.UC_Enterprise)
                {
                    iUCECount++;
                }
            }
            system.debug('[ValidateMinimumRequirements] Check iIPVPNCount and iUCECount:' + checkIpvpAndUceCount);
            system.debug('cscfga__Product_Configurations__r : '+basket.cscfga__Product_Configurations__r);
            system.debug('iIPSiteCount : '+iIPSiteCount);
            system.debug('iIPVPNCount : '+iIPVPNCount);
            system.debug('iUCECount : '+iUCECount);
            //if there are no CWP products in the modular basket return ok
            if (basket.cscfga__Product_Configurations__r ==null || basket.cscfga__Product_Configurations__r.size()==0)
            {
                //return 'error' +'-'+'Please add atleast one valid product before sync.';
                return 'ok';                
            }    
            //If both IP Network and Unified Communication Enterprise  products are not present
            else if(checkIpvpAndUceCount && iIPVPNCount < 1 && iUCECount < 1)
            {
                return 'error' + '-'+ System.Label.Label_IPUCEnterpriseBothNotPresent_Error;
            }
            //no IP Network module in the basket and no IP Network subscription
            else if(checkIpvpAndUceCount && iIPVPNCount < 1) {
                return 'error' + '-'+ System.Label.Label_IPNetwork_Error; 
            }          
            //no Unified Communication Enterprise module in the basket and no Unified Communication Enterprise subscription
            else if(checkIpvpAndUceCount && iUCECount < 1)
            {
                return 'error' + '-'+ System.Label.Label_UCEnterprise_Error;  
            }
            
            else if(iIPSiteCount < 2 && basket.cscfga__Opportunity__r.Type == 'New To Market')
            {
                return 'error' +'-'+System.Label.Label_CWP_Error; 
            }
            //Marking as a comment as we are not using transition complete flag at the checkpoint screen
            /* else if(basket.TransitionComplete__c == false )
                {
                return 'error' +'-'+System.Label.Label_Transition_Incomplete_Error; 
                }*/
            else if(basket.cscfga__Product_Configurations__r!=null  && iIPVPNCount == 1 && iUCECount == 1){
                return 'ok'; 
            }
            //if the account has different sites
            else if(iIPSiteCount > 1 ){
                return 'ok';    
            }  
            //If 2 sites and IP Network and Unified Communication Enterprise  products are not present
            else {
                return 'error' +'-'+System.Label.Label_2SitesIPUCEnterpriseNotPresent_Error; 
            }
        }
        else{
            if(accountId != null){  
                List<csord__Subscription__c> lstSubFromAccount = [SELECT id, Name FROM csord__Subscription__c WHERE csord__Account__c =:accountId and csord__Status__c!='Cancelled'];
                for(csord__Subscription__c subFromAccount : lstSubFromAccount)
                {
                    if(subFromAccount.Name == System.Label.IP_Site)
                    {
                        iIPSiteCount++;
                    }
                    else if(subFromAccount.Name == System.Label.IP_Network)
                    {
                        iIPVPNCount++;
                    }
                    else if(subFromAccount.Name == System.Label.UC_Config_Name)
                    {
                        iUCECount++;
                    }
                }
            }
            List<cscfga__Product_Configuration__c> lstProdConfig = [Select id, Name, cscfga__Product_Definition__r.name, Type__c from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id =:basketId];
            system.debug('***********prodConfig.cscfga__Product_Definition__r.name : '+lstProdConfig);
            
            for(cscfga__Product_Configuration__c prodConfig : lstProdConfig)
            {
                if(prodConfig.Type__c == PROD_CONFIGURATION_TYPE_MODIFY){
                    checkIpvpAndUceCount = true;
                }
                system.debug('[ValidateMinimumRequirements] Check iIPVPNCount and iUCECount:' + checkIpvpAndUceCount);
                system.debug('***********prodConfig.cscfga__Product_Definition__r.name : '+prodConfig.cscfga__Product_Definition__r.name);
                if(iIPSiteCount < 2 && prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Site)
                {
                    iIPSiteCount++;
                }
                if(prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Network)
                {
                    iIPVPNCount++;
                }
                if(prodConfig.cscfga__Product_Definition__r.name == System.Label.UC_Enterprise)
                {
                    iUCECount++;
                }
            }
            system.debug('cscfga__Product_Configurations__r : '+basket.cscfga__Product_Configurations__r);
            system.debug('iIPSiteCount : '+iIPSiteCount);
            system.debug('iIPVPNCount : '+iIPVPNCount);
            system.debug('iUCECount : '+iUCECount);
            //if there are no CWP products in the modular basket return ok
            if (basket.cscfga__Product_Configurations__r ==null || basket.cscfga__Product_Configurations__r.size()==0)
            {
                //return 'error' +'-'+'Please add atleast one valid product before sync.';  
                return 'ok';
            }    
            //If there is one IP Site,no IP VPN and UC
            else if(checkIpvpAndUceCount && iIPSiteCount < 2 && iIPVPNCount < 1 && iUCECount < 1 ){
                return 'error' +'-'+System.Label.Label_2SitesIPUCEnterpriseNotPresent_Error; 
            }
            //If both IP Network and Unified Communication Enterprise  products are not present
            else if(checkIpvpAndUceCount && iIPVPNCount < 1 && iUCECount < 1)
            {
                return 'error' + '-'+ System.Label.Label_IPUCEnterpriseBothNotPresent_Error;
            }
            //no IP Network module in the basket and no IP Network subscription
            else if(checkIpvpAndUceCount && iIPVPNCount < 1) {
                return 'error' + '-'+ System.Label.Label_IPNetwork_Error; 
            }          
            //no Unified Communication Enterprise module in the basket and no Unified Communication Enterprise subscription
            else if(checkIpvpAndUceCount && iUCECount < 1)
            {
                return 'error' + '-'+ System.Label.Label_UCEnterprise_Error;  
            }
            
            //more than 1 IP Network module in the basket 
            else if(checkIpvpAndUceCount && iIPVPNCount > 1){
                return 'error' + '-'+ System.Label.Label_MoreThanOneIPNetwork_Error;
            }           
            // more than 1 Unified Communication Enterprise module in the basket
            else if(checkIpvpAndUceCount && iUCECount > 1){
                return 'error'+ '-'+ System.Label.Label_MoreThanOneUCEnterprise_Error;  
            }
            
            else if(iIPSiteCount < 2 && basket.cscfga__Opportunity__r.Type == 'New To Market') // EDGE-125039
            {
                return 'error' +'-'+System.Label.Label_CWP_Error; 
            }
            
            //IF user does not trasition for legacy site
            /*else if(basket.TransitionComplete__c == false )
            {
                return 'error' +'-'+System.Label.Label_Transition_Incomplete_Error; 
            }*/
            else if(basket.cscfga__Product_Configurations__r!=null  && iIPVPNCount == 1 && iUCECount == 1){
                return 'ok'; 
            }
            //if the account has different sites
            else if(iIPSiteCount > 1  && ( (iIPVPNCount == 1 && iUCECount == 1) || !checkIpvpAndUceCount) ){
                return 'ok';    
            }  
            //If 2 sites and IP Network and Unified Communication Enterprise  products are not present
            else {
                return 'error' +'-'+System.Label.Label_2SitesIPUCEnterpriseNotPresent_Error; 
            }
            
        }
    }

    /*  
     * Method Name : getBillingAccLookupattribute
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    private static Map<String,cscfga__Attribute__c> getBillingAccLookupattribute(Map<String,cscfga__Product_Configuration__c> pcMap, Set<string>BillingAccSet){
        Map<String,cscfga__Attribute__c> billingAccAtt=new Map<String,cscfga__Attribute__c>() ;
        if(pcMap!=null && pcMap.size()>0 && BillingAccSet!=null && BillingAccSet.size()>0){
           for(cscfga__Product_Configuration__c config : pcMap.values()) {
               if(config.ConfigurationType1__c=='SolutionComponent' && config.cscfga__Attributes__r!=null){
                  	for(cscfga__Attribute__c attr : config.cscfga__Attributes__r) {
                    	if(attr.Name == System.Label.BillingAccountAttName && attr.cscfga__Value__c != null && BillingAccSet.contains(attr.cscfga__Value__c))
                        	billingAccAtt.put(config.cssdm__solution_association__c,attr);  
                    }
                }
           }
        }
        return billingAccAtt;
    }
       /*  
     * Method Name : getBillingAccLookupattribute
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    private static Boolean isInvalidbasket(Map<String,cscfga__Product_Configuration__c> pcMap, Set<string>BillingAccSet){
        Boolean isInvalidBasket=false;
        Map<String,cscfga__Attribute__c> billingAccAttMap=ValidateMinimumRequirements.getBillingAccLookupattribute(pcMap, BillingAccSet);
        String notAllowedTypesString=System.Label.notAllowedTypes;
        Set<String> notAllowedTypes=new Set<String>(notAllowedTypesString.split(','));
        Set<String> invalidSolutionSet=new Set<String>();
        List<cscfga__Product_Configuration__c> prodConfigTobeUpdated=new List<cscfga__Product_Configuration__c>();
        if(PcMap!=null && PcMap.size()>0 && billingAccAttMap!=null && billingAccAttMap.size()>0){
            for(cscfga__Product_Configuration__c pc:PcMap.values()){
                if(billingAccAttMap.containskey(pc.cssdm__solution_association__c) && pc.ConfigurationType1__c!='SolutionComponent' && (notAllowedTypes!=null && notAllowedTypes.contains(pc.Type__c))){
                    isInvalidBasket=true;
                    invalidSolutionSet.add(pc.cssdm__solution_association__c);
                }
            }
        }
        if(invalidSolutionSet!=null && invalidSolutionSet.size()>0)
            ValidateMinimumRequirements.makePcInvalid(invalidSolutionSet,pcMap);
        return isInvalidBasket;
    }
      /*  
     * Method Name : validateBasketforBillingAcc
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    public static Boolean validateBasketforBillingAcc(String basketId,String accountId){
        Boolean isInvalidBasket=false;
        if(String.isNotBlank(basketId) && String.isNotBlank(basketId) && String.isNotBlank(accountId) && String.isNotBlank(accountId)){
            Set<String> attNameFilterSet=new Set<String>{String.valueOf(System.Label.BillingAccountAttName)};
            Map<String,cscfga__Product_Configuration__c> PcMap=new Map<String,cscfga__Product_Configuration__c>();
            String statusValues=System.Label.BillingAccountStatus;
            Set<String> billingAccStatusSet=new Set<String>(statusValues.split(','));
            Map<String,Billing_Account__c> billingAccmap=Model_BillingAccount.getBillingAccountOnStatus(accountId,billingAccStatusSet);
            if(billingAccmap!=null && !billingAccmap.isEmpty()){
                PcMap=Model_ProductConfiguration.getConfigMap(basketId,attNameFilterSet);
                isInvalidBasket=ValidateMinimumRequirements.isInvalidbasket(pcMap,billingAccmap.keySet());
            }
        }
        
        return isInvalidBasket;// ? 'error' +'-'+System.Label.BillingAccountStatusValidation : 'ok';    
    }
    /*  
     * Method Name : makebasketInvalid
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    public static PageReference makebasketInvalid(cscfga__Product_Basket__c basket){
        PageReference ref ;
        if(basket!=null && basket.cscfga__Basket_Status__c!='Incomplete'){
            basket.cscfga__Basket_Status__c='Incomplete';
            basket.cscfga__pricing_status__c='Current';
            ref=new PageReference('/' + basket.Id);
            update basket;
        }
        return ref;
    }
    /*  
     * Method Name : makePcInvalid
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    private static void makePcInvalid(Set<String> invalidSolutions,Map<String,cscfga__Product_Configuration__c> pcMap){
        List<cscfga__Product_Configuration__c> pcTobeUpdatedList=new List<cscfga__Product_Configuration__c>(); 
        if(pcMap!=null && pcMap.size()>0 && invalidSolutions!=null && invalidSolutions.size()>0){
            for(cscfga__Product_Configuration__c pc:PcMap.values()){
                if(invalidSolutions.contains(pc.cssdm__solution_association__c) && pc.ConfigurationType1__c=='SolutionComponent'){
                   pc.cscfga__Configuration_Status__c='Incomplete';
                   pc.cscfga__pricing_status__c='Current';
                    pcTobeUpdatedList.add(pc);
                }
            }
        }
        if(pcTobeUpdatedList!=null && !pcTobeUpdatedList.isEmpty())
        update pcTobeUpdatedList;
    }
}