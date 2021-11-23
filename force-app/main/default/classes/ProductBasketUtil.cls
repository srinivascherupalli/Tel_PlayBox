public class ProductBasketUtil {
    
    public static Set<String> offersInBasket(cscfga__Product_Basket__c productBasket) {
        System.debug('productBasket: '+productBasket); 
        //EDGE-128633. Using offername attribute instead of parent
        List<cscfga__Product_Configuration__c> pcList = [select Offername__c from 
                                                         cscfga__Product_Configuration__c where 
                                                         cscfga__Product_Basket__c = :productBasket.Id and 
                                                         Offername__c != null];
        Set<String> offersInBasket = new Set<String>();
        System.debug('pcList: '+pcList);
        for(cscfga__Product_Configuration__c pc: pcList) {
            offersInBasket.add(pc.Offername__c);
        }
        System.debug('offersInBasket: '+offersInBasket);
        return offersInBasket;
    }
    
    public static boolean doesBasketHaveOffer(ID basketId, String offerName) {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c where id=:basketId];
        return doesBasketHaveOffer(basket, offerName);
    }
    
    public static boolean doesBasketHaveOffer(cscfga__Product_Basket__c basket, String offerName) {
        System.debug('offersInBasket1:'); 
        
        Set<String> offersInBasket = offersInBasket(basket);
        
        System.debug('offersInBasket: '+offersInBasket); 
        if(offersInBasket.contains(offerName)) {
            return true;
        } else {
            return false;
        }
    }
}