/*****************************************************************************************************************************
Name : BSK_Utilities
Description : Utility class for Product Basket common functionalities
Jira : DIGI-518
******************************************************************************************************************************/
public class BSK_Utilities {
    
    public static Map<String,String> offerId_Vs_OfferCode = new Map<String,String>();
    
    //static final String CASE_STATUS = 'CaseStatus';
    
    public static List<String> productSpecCodes=new List<String>(AllCQEnvironmentVariable.getValueAsList('ProductSpeccificationCode'));
    
    //helper method to get child product-configurations of basket 
    public static list<cscfga__Product_Configuration__c> getPCsForBasket(String basketId){
        list<cscfga__Product_Configuration__c> prodcList = null;
        //BasketUtilitySettings__c bskSettings = BasketUtilitySettings__c.getValues('Status');
        //String status=bskSettings.Value__c;    
        String status='CaseStatus';
        try{
            if(prodcList!=null)
                return prodcList;
            else{  
                //EDGE-113291 Added 'Telstra Collaboration' in below query 
                //EDGE-117967 Added 'Device Outright Purchase' in below query
                //EDGE-165326 added Product Family | Refactoring for this to be taken as part of utility method for EDGE-135349
                // Refactor filter
                prodcList=[SELECT id,Marketable_Offer__r.Offer_ID__c,
                           cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c,                       
                           csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c,
                           cscfga__Parent_Configuration__r.Offername__c,
                           cscfga__Product_Definition__r.product_Specification__c,
                           cscfga__Parent_Configuration__r.Offer_Reference__r.Name,
                           cscfga__Parent_Configuration__r.Name,
                           cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,(SELECT id,name,cscfga__Value__c FROM cscfga__Attributes__r WHERE name=:status) 
                           FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId AND (Commercial_Config__c='Yes'
                                                                                                                OR cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes)];
                //Refactor filter end
            }  
        }
        catch(exception ex){
            C2O_Utilities.createException(ex);
        }
        return prodcList;
    }
    
    //helper method to get distinct offers added in the basket
    public static Set<String> getOffersInBasket(String basketId){
        Set<String> offers = null;
        try{
            if(offers!=null)
                return offers;
            else{ 
                offers = new Set<String>();                     
                for(cscfga__Product_Configuration__c pcloop:getPCsForBasket(basketId)){
                    if(!String.isBlank(pcloop.Offername__c)){                    
                        //EDGE-165831 - changed method parameter
                        offers.add(getOfferFamily(pcloop.Marketable_Offer__r.Offer_ID__c));
                    }
                    if(pcloop.cscfga__Parent_Configuration__c!=null && !String.isBlank(pcloop.cscfga__Parent_Configuration__r.Offername__c)){
                        //EDGE-165831 - method parameter change
                        offers.add(getOfferFamily(pcloop.cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c));
                    }
                }                          
            }
        }
        catch(exception ex){
            C2O_Utilities.createException(ex);
        }
        return offers;
    }
    //helper method to identify the offer-family for a selected offer
    public static String getOfferFamily(String offerName){
        //EDGE-165831 - replaced offer name with offer code.
        List<Offer_Id__mdt> lstOfferIds = [Select MasterLabel,Template_Family__c,IsActive__c from Offer_Id__mdt where IsActive__c = true];
        if(!lstofferIds.isEmpty()){
            for(Offer_Id__mdt oids:lstofferIds){
                offerId_Vs_OfferCode.put(oids.MasterLabel,oids.Template_Family__c);                
            }    
        }       
        return offerId_Vs_OfferCode.get(offerName);
    } 
    
    public static cscfga__Product_Basket__c getBasket(String basketId){
        //Total Contract Value field added in query. EDGE-11104
        //cscfga__Opportunity__r.Owner.Email added in query EDGE - 115457, EDGE-117966: Parallel MACD added csordtelcoa__Change_Type__c
        //Changed dynamic query to static
        cscfga__Product_Basket__c productBasket = [SELECT cscfga__Opportunity__c,id, Name,csbb__Account__c, cscfga__Opportunity__r.Owner.Email,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.OwnerId,Maxim_Opportunity_ID__c,Customer_Request_Date__c,cscfga__Basket_Status__c,csbb__Account__r.OwnerId,csbb__Account__r.Name,csbb__Account__r.Owner.Name,csbb__Account__r.Owner.Email,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c,
                                                   cscfga__total_contract_value__c,cscfga__Opportunity__r.Model_Change__c,Express_Flow__c,csordtelcoa__Change_Type__c,cscfga__pricing_status__c FROM cscfga__Product_Basket__c where id =: basketId];
        return productBasket;
    }
    
    public static boolean doesBasketHaveOffer(cscfga__Product_Basket__c basket, String offerName) { 
        try{
            Set<String> offersInBasket = new Set<String>();
            List<cscfga__Product_Configuration__c> offNameList = [select Offername__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basket.Id and Offername__c != null];
            for(cscfga__Product_Configuration__c pc: offNameList) {
                offersInBasket.add(pc.Offername__c);
            }
            if(offersInBasket.contains(offerName)) {
                return true;
            } else {
                return false;
            }
        }
        catch(Exception e){   
            C2O_Utilities.createException(e);
        }
        return false;
    }
}