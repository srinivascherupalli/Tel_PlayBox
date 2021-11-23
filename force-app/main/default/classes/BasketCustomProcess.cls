/**
* @File Name          : BaksetCustomProcess.cls
* @Description        :
* @Author             : Girish P
* @Group              :
* @Last Modified By   : Girish P
* @Last Modified On   : 7/18/2019, 7:55:56 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                        Modification
*==============================================================================
* 1.0    7/18/2019, 5:47:18 PM   Girish P     Initial Version
**/
public class BasketCustomProcess {
    /**
* @description
* @author Girish P | 7/18/2019
* @param Set<String> setMarketbaleOffers : set all unique offers in a Basket
* @return boolean if custom business rule/validation at basket level should be skipped for whole basket
*/
    public static boolean isConfigOnlyBasket(Set<String> setMarketbaleOffers){
        Map<String,Object> mapAllConfigs;
        Boolean skipValidations=true;
        for(Marketable_Offer__c eachMarketableOffer: [Select id,Name,Config__c from Marketable_Offer__c
                                                      where name in: setMarketbaleOffers]) {
                                                          //find if validation should be skipped
                                                          mapAllConfigs=(Map<String,Object>) JSON.deserializeUntyped(eachMarketableOffer.Config__c);
                                                          //break the loop and exits atleast one offer exists which triggers validations
                                                          if(mapAllConfigs.containsKey('skipBasketSyncValidations')
                                                             && !(Boolean)mapAllConfigs.get('skipBasketSyncValidations')) {
                                                                 skipValidations=false;
                                                                 break;
                                                             }
                                                      }
        return skipValidations;
    }
}