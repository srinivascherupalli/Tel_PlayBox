/************************************************************ 
 * @version      - 0.1
 * @createdBy    - Pradeep Bhumi
 * @team         - OSAKA
 * @jirastoryRef - EDGE-136960
 * @Description  - This class will make Express Order field in basket conditionally editable based on BSA Contract Flag in contract/basket.
 ******************************************************************/

public with sharing class BSAContractHandler {

    @InvocableMethod
    public static void updateBSACheckFlag(List < Id > productBasketId) {

        List < Id > accountList = new List < Id > ();
        List < cscfga__Product_Basket__c > prodBasketList;
        List < ContractJunction__c > contractJunList;
        Boolean updateRequired = false;
        Boolean contractStatus = false;

            prodBasketList = [SELECT Id, cscfga__Opportunity__r.AccountId FROM cscfga__Product_Basket__c where id IN: productBasketId];
            for (cscfga__Product_Basket__c basket: prodBasketList) {
                accountList.add(basket.cscfga__Opportunity__r.AccountId);
            }
            contractJunList = [SELECT Id, Account__C, BSA_Generated__c, Status__c FROM ContractJunction__c where Account__C IN: accountList];
            //Set a hidden flag based on the BSA flag in contract and the status in contract junction.
            for (ContractJunction__c contractJun: contractJunList) {
                contractStatus= contractJun.BSA_Generated__c && !System.Label.contract_Status.contains(contractJun.Status__c);  
                if (contractStatus) {
                    for (cscfga__Product_Basket__c updateBasket: prodBasketList) {
                        if (updateBasket.cscfga__Opportunity__r.AccountId == contractJun.Account__C)

                        {
                            updateBasket.BSA_Generated__c = true;
                            updateRequired = true;
                        }

                    }

                }
            }
            //Update the flag i basket record only for skip contract scenarios.
            if (updateRequired)
                upsert prodBasketList;
       
    }
}