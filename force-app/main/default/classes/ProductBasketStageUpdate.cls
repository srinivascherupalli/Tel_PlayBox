public class ProductBasketStageUpdate 
{
     public static String DISPLAY_MESSAGE;
     public static String  updateProductBasketStage(String basketId, String stageName)
     {
         cscfga__Product_Basket__c productBasket = getValidProductBasket(basketId);
         if(productBasket == null)
         {
           DISPLAY_MESSAGE = 'One or more invalid product configurations in the basket';
           return 'error';
         }
         if(!String.isEmpty(stageName))
         {
            productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues(stageName).Enrichment_Basket_Stage__c;
         }
         update productBasket;
         DISPLAY_MESSAGE = 'Basket status updated successfully';
         return 'ok';
     }
   @TestVisible
    private static cscfga__Product_Basket__c getValidProductBasket(String basketId) 
    {
        String queryString = 'SELECT ' + OpportunitySyncUtil.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id = \'' + basketId + '\'';
        List <cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        // check if all product configuration are valid
        for (cscfga__Product_Configuration__c pc: productBasketList[0].cscfga__Product_Configurations__r)
        {
            if (pc.cscfga__Configuration_Status__c != 'Valid') 
            {
                return null; 
            }
        }
        return productBasketList[0];
    }
    @TestVisible
    public static String getSobjectFields(String so) 
    {
        String fieldString;
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        List < Schema.SObjectField > fields = sot.getDescribe().fields.getMap().values();
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }
}