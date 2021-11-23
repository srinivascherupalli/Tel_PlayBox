/*************************************************************************************************
Name : OpportunitySyncUtil 
Description : Opportunity Sync class
Sr.No.    Developer Name      Date          Story Description
2.        Shubhi Vijay      21/08/2019      EDGE-81113 MDM migration order
          Team Hawaii           09/03/2019      P2OB-2714 Updating Last Sync Date
**************************************************************************************************/
public with sharing class OpportunitySyncUtil {
    public static String DISPLAY_MESSAGE;
    private static Pricebook2 stdPriceBook;
    
    public static void syncWithOpportunity(cscfga__Product_Basket__c productBasket) {
        syncWithOpportunity(productBasket, null);
    }
    
    public static String syncWithOpportunity(String basketId, String stage){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE Id =:basketId].get(0);
        return (syncWithOpportunity(basket, stage));
    }

    public static String syncWithOpportunity(cscfga__Product_Basket__c productBasket, String stageName) {        
        try {   
            String basketStage = stageName;            
            if(productBasket == null) {
                DISPLAY_MESSAGE = 'One or more invalid product configurations in the basket';
                return 'error';
            }
            
            // Set the oppt price book to standard
            setOppToStdPriceBook(productBasket);
            
            // basket sync with opportunity
            CustomButtonSynchronizeWithOpportunity cbswo = new CustomButtonSynchronizeWithOpportunity();
            cbswo.performAction(productBasket.Id);
            
            System.debug(LoggingLevel.INFO, 'syncWithOpportunity.basketStage = ' + basketStage);
            if(!String.isEmpty(basketStage))
                productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues(basketStage).Enrichment_Basket_Stage__c;
            productBasket.csbb__synchronised_with_opportunity__c = true;
            productBasket.Primary_Basket__c = true;
            update productBasket;
            
            // Clean up the baskets
            cleanupOtherBaskets(productBasket);
            
            // Update the oppt info
            // Commented as part of EDGE-11104 requirement. Now, this method will be individually called by CustomButtonOpportunitySync, CustomButtonQuote and CustomButtonContractSent Classes.
            //updateOpptInfo(productBasket, basketStage);
            DISPLAY_MESSAGE = 'Basket sync with Opportunity completed successfully';
        }
        catch(Exception e){
            DISPLAY_MESSAGE = e.getMessage();
            System.debug(LoggingLevel.INFO, 'syncWithOpportunity.DISPLAY_MESSAGE = ' + DISPLAY_MESSAGE);
            if(DISPLAY_MESSAGE == null || DISPLAY_MESSAGE.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'))
                DISPLAY_MESSAGE = 'Only the opportunity owner can sync the product basket';
            System.debug(LoggingLevel.INFO, 'syncWithOpportunity.DISPLAY_MESSAGE = ' + DISPLAY_MESSAGE);
            return 'error'+'-'+ DISPLAY_MESSAGE;
        }        
        return 'ok' + '-'+ DISPLAY_MESSAGE;
    }
    
    // Get a comma separated SObject Field list
    @TestVisible
    public static String getSobjectFields(String so){
        String fieldString;
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        List < Schema.SObjectField > fields = sot.getDescribe().fields.getMap().values();
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }
    
    @TestVisible
    private static void setOppToStdPriceBook(cscfga__Product_Basket__c productBasket){
        // if pricebook attached to the opportunity is not standard delete all 
        // opportunity line items and attach opportunity to standard pricebook
        if (!productBasket.cscfga__Opportunity__r.Pricebook2.IsStandard) {
            Opportunity opp = [
                SELECT id, pricebook2id,
                    (SELECT id FROM OpportunityLineItems)
                FROM Opportunity
                WHERE id = :productBasket.cscfga__Opportunity__c
            ];
            if (opp.OpportunityLineItems.size() > 0) {
                delete opp.OpportunityLineItems;
            }
            // get Id of standard pricebook and attach it to the opportunity 
            
            opp.Pricebook2Id = getStdPricebookId();
             // Team Hawaii - P2OB-2368     
           // opp.Last_Basket_Sync__c = System.now();
            update opp;
        }
    }
    
    @TestVisible
    private static void cleanupOtherBaskets(cscfga__Product_Basket__c productBasket){
        // clear synchronized with opportunity flag for baskets attached to the opportunity 
        List <cscfga__Product_Basket__c> productBasketList = [
            SELECT id, csbb__synchronised_with_opportunity__c,Primary_Basket__c
            FROM cscfga__Product_Basket__c
            WHERE cscfga__opportunity__c = : productBasket.cscfga__Opportunity__c 
                AND (csbb__synchronised_with_opportunity__c = true OR Primary_Basket__c = true)
                AND id != : productBasket.Id
        ];
        if(productBasketList.size() > 0) {
            for(Integer i = 0; i < productBasketList.size(); i++) {
                productBasketList[i].csbb__Synchronised_with_Opportunity__c = false;
                productBasketList[i].Primary_Basket__c = false;
            }
            update productBasketList;
        }
    }
    
    public static void updateOpptInfo(cscfga__Product_Basket__c productBasket, String basketStage) {
        List<Opportunity> oppList = [
            SELECT id, StageName, pricebook2id, 
                (SELECT id FROM OpportunityLineItems)
            FROM Opportunity
            WHERE id = :productBasket.cscfga__Opportunity__c
        ];
        // StageName added in above query EDGE-11107.
        System.debug('PP basketStage : '+basketStage + ' && oppList: ' + oppList );
        Id profileId=userinfo.getProfileId();
        List<profile> profileList = [
            SELECT Id,Name 
            FROM Profile 
            WHERE Id = :profileId
        ];   
        String profileName = '';
        if(profileList !=null && profileList.size() > 0)
        profileName= profileList[0].Name;
  
        for(Opportunity opp : oppList){
             if(basketStage != null && basketStage.length() > 0) {
                //for Phoenix Users only from Define to Develop 
                if((profileName == 'Sales - Enterprise' || profileName == 'Sales Manager - Enterprise' || profileName == 'Sales-Enterprise-Unified') && opp.StageName == 'Define' && basketStage == 'CommercialConfiguration')
                   opp.StageName = CustomConfigurationOptions__c.getValues(basketStage).Opportunity_Stage__c;
                 else if (!(profileName == 'Sales - Enterprise' || profileName == 'Sales Manager - Enterprise'))
                   opp.StageName = CustomConfigurationOptions__c.getValues(basketStage).Opportunity_Stage__c;
                System.debug(LoggingLevel.INFO, 'updateOpptInfo.StageName = ' + opp.StageName);
            }
            opp.Amount = productBasket.cscfga__total_contract_value__c;
            // Team Hawaii - P2OB-2368                  
            //opp.Last_Basket_Sync__c = System.now();
            
        }
        update oppList;
    } 
    
    public static Pricebook2 getStdPriceBook () {
        if (stdPriceBook == null)
            stdPriceBook = [
                SELECT id, name 
                FROM Pricebook2 
                WHERE isStandard = true 
                LIMIT 1
            ];
        return stdPriceBook;    
    }
    
    public static ID getStdPricebookId() {
        if (Test.isRunningTest())
            return Test.getStandardPricebookId();
        return getStdPricebook().id;    
    }
    
    public static Boolean checkOppContactRole(Id basketId, cscfga__Product_Basket__c fullBasket)
  {
      System.debug('OpportunitySyncUtil checkOppContactRole ' + basketId + ' ' + fullBasket);
    List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        // if block added for edge-81113
        if(fullBasket !=null && fullBasket.cscfga__Opportunity__c != null && fullBasket.cscfga__Opportunity__r.Model_Change__c==true ){
            return true;
        }
    if (fullBasket != null && fullBasket.cscfga__Opportunity__c != null && fullBasket.cscfga__Opportunity__r.Id != null)
    {
      contactRolesList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId =: fullBasket.cscfga__Opportunity__r.Id];
    }
    else if (basketId != null)
    {
      cscfga__Product_Basket__c currentBasket = [SELECT cscfga__Opportunity__r.Id FROM cscfga__Product_Basket__c WHERE Id =: basketId];
      contactRolesList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId =: currentBasket.cscfga__Opportunity__r.Id];
    }
    System.debug('OpportunitySyncUtil checkOppContactRole + contactRolesList: ' + contactRolesList);
    if (contactRolesList.size()>0)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
    // Team Hawaii
    public static void updateSyncOpportunityInfo(Id opptyId){
        Opportunity oppty = new Opportunity(id = opptyId, Last_Basket_Sync__c = System.now());
        update oppty;
    }
}