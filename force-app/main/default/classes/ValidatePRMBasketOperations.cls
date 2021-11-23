/**
* @CreatedDate : 17/05/2021
* @Breif : Trigger Approval Process if the Active Partner Of Record exits with another Partner.
* EDGE-202824
**/
public without sharing class ValidatePRMBasketOperations {
    
    public static string checkActivePOR(cscfga__Product_Basket__c productBasket,List <cscfga__Product_Configuration__c> configList){
        Set<String> dominSet = new  Set<String>();
        Boolean isPORActivePartner=false;
        Boolean isPORActiveOtherPartner=false;
        for(cscfga__Product_Configuration__c prodConfig: configList){
            dominSet.add(prodConfig.Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c);
        }
        
        User userRecord=[select id,accountid from user where id=:UserInfo.getUserId()];
        for(Partner_of_Record_Domain__c porDomain: [select id,Partner_of_Record__r.Partner__c from Partner_of_Record_Domain__c where Partner_of_Record__r.Customer__c = :productBasket.cscfga__Opportunity__r.AccountId and status__c = 'Active' and Domain_Name__c IN :dominSet]){
            if(porDomain.Partner_of_Record__r.Partner__c == userRecord.accountid){
                isPORActivePartner=true;
            }else
                isPORActiveOtherPartner=true;
        }
      
        if(!isPORActivePartner){
            if(isPORActiveOtherPartner){
                productBasket.csordtelcoa__Basket_Stage__c='CE POR Basket Review';
                update productBasket;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(productBasket.id);
                req.setProcessDefinitionNameOrId('CE_POR_Basket_Approval');
                Approval.ProcessResult approvalResult = Approval.process(req);
                return '{"isValidPartner":"false","status":"error"}';
            }
        }
        return 'Ok';
    }
}