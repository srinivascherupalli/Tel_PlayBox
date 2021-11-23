/*
* @Author : Gnana
* @Date : 28 Jan 2020
* @Desc : Product Configuration object record handler  
* @Jira : Edge-132211
* @test class : 
* Modified by Ankit Goswami as a part of EDGE-145446 bug fix
*modified by shubhi for Edge-169909
*/

public with sharing class ProductConfigObjectRecordHandler {
    public static List<String> BASKET_STAGE = new List<String>{'Commercial Configuration','Draft'}; // Edge-169909
  
    @InvocableMethod(label='Associate CLI to PC Record' description='Associate Charge Line Items with Prodcut Configuration record')
    public static void updateChargeLineItemWithPC(List<ID> pcIds){
        System.debug('List of PC Ids...'+pcIds);
    Map<String,cscfga__Product_Configuration__c> guidConfigRecordMap = new Map<String,cscfga__Product_Configuration__c>();
            Map<String,String> guidConfigBasketMap = new Map<String,String>();
            for(cscfga__Product_Configuration__c pc : [SELECT Id, Name, configGUID__c, cscfga__Product_Basket__c, cscfga__Configuration_Offer__c,
                                                       cscfga__Configuration_Status__c FROM cscfga__Product_Configuration__c
                                                       WHERE Id IN: pcIds AND cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c  IN :BASKET_STAGE ]){
                                                           if(!String.isBlank(pc.configGUID__c)){
                                                               guidConfigRecordMap.put(pc.configGUID__c,pc);
                                                               guidConfigBasketMap.put(pc.configGUID__c,pc.cscfga__Product_Basket__c);//Added by Ankit Goswami as a part of EDGE-145446 bug fix
                                                           }
            }
            ChargeDiscountQueryUtility cdqUtility = new ChargeDiscountQueryUtility();
            Map<String,Charge_Line_Item__c> chargeLineItemMap = cdqUtility.fetchExistingChargeLineItem(guidConfigRecordMap.keySet());
            List<Charge_Line_Item__c> updatedCLIList = new List<Charge_Line_Item__c>();
            System.debug('guidConfigBasketMap...'+ guidConfigBasketMap.values());
            for(Charge_Line_Item__c cli : chargeLineItemMap.values()){
                System.debug('cli.Product_Configuration__c...'+ cli.Product_Configuration__c);
                System.debug('guidConfigRecordMap.containsKey(cli.guid__c)...'+ guidConfigRecordMap.containsKey(cli.guid__c));
                System.debug('guidConfigBasketMap.containsKey(cli.guid__c)...'+ guidConfigBasketMap.containsKey(cli.guid__c));
                System.debug('guidConfigBasketMap.get(cli.guid__c)...'+ guidConfigBasketMap.get(cli.guid__c));
                if(cli.Product_Configuration__c == null && guidConfigRecordMap.containsKey(cli.guid__c) && guidConfigBasketMap!=null && guidConfigBasketMap.containsKey(cli.guid__c) && guidConfigBasketMap.get(cli.guid__c).contains(cli.basketId__c) )//Added guidConfigBasketMap.containsKey(cli.guid__c) && guidConfigBasketMap.get(cli.guid__c)==cli.basketId__c by Ankit Goswami as a part of EDGE-145446 bug fix
                {
                    system.debug('conditions satisfied to update CLI...');
                    cli.Product_Configuration__c = guidConfigRecordMap.get(cli.guid__c).Id;
                    updatedCLIList.add(cli);
                }
                
            }
            System.debug('updatedCLIList...'+updatedCLIList);
            if(updatedCLIList != null && !updatedCLIList.isEmpty()){
                ComplexChargeDisountFactory ccd = new ComplexChargeDisountFactory();
                ccd.updateChargeLineItem(updatedCLIList);
            }
        }
   
}