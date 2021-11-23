/**************************************************************************************
* Author      : Romil Anand
* Class Name  : BasketRedemptionHelper 
* Description : Class for fetching the basket Redemption Amount for all the solutions. 
* Story       : EDGE-113091 and EDGE-112717 - Show available OneFund balance from CIDN at the time of basket creation
*               EDGE-116121- Cancellation of CS Basket before Order submission and syncing the opportunity with basket
*               EDGE-134518- Changes to SOQL query in Basket Redemption Helper
*               EDGE-136954- Implement code review comments provided by Governance Review
                EDGE-199056- As part of label change implemented code change for recordType API retrival
*               EDGE-202315- Inflight Amend/Cancel changes
**************************************************************************************/
global with sharing class BasketRedemptionHelper implements cssmgnt.RemoteActionDataProvider  {
    public static Id redemptionRecordTypeId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String basketId = (String)inputMap.get('GetBasket');    
        Double res = GetBasket(basketId); 
        returnMap.put('GetBasket', res);
        return returnMap;
    }  
    
    global static Double getBasket(String basketId){  
        Double sumOfBasketRedemption=0;
        Id baskID;   
        Id oppID;
  // AB : Spring 20 Upgrade Changes
        Double oppRedemptionAmount = 0;
        
        if(basketId.length()>0){
            List<cscfga__Attribute__c> attributeList = [SELECT ID,cscfga__Value__c,cscfga__Product_Configuration__r.subType__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Basket_Redemption_amount__c
                                                        FROM cscfga__Attribute__c
                                                        WHERE  cscfga__Product_Configuration__r.cscfga__Product_Basket__r.name =:basketId AND (name ='RedeemFund')]; //Removed changes related to EDGE-164623 | No changes in test class 
            if(!attributeList.isEmpty()) {
                baskID = attributeList[0].cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id;
                oppID = attributeList[0].cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c;
                oppRedemptionAmount = attributeList[0].cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Basket_Redemption_amount__c;
                for(cscfga__Attribute__c att :attributeList) {
                    if(att.cscfga__Product_Configuration__r.subType__c != null && att.cscfga__Product_Configuration__r.subType__c == 'Inflight Cancel')
                        sumOfBasketRedemption = sumOfBasketRedemption - decimal.valueOf(att.cscfga__Value__c != null ? att.cscfga__Value__c : '0'); //EDGE-202315
                    else
                        sumOfBasketRedemption = sumOfBasketRedemption + decimal.valueOf(att.cscfga__Value__c != null ? att.cscfga__Value__c : '0'); //EDGE-164931 fix for empty attribute
                }
            }                                        
        }
        //update only if there is a change
        if(oppRedemptionAmount != sumOfBasketRedemption) {
            updateBasketRedemptionAmount(oppID,baskID, sumOfBasketRedemption); 
        }
        return sumOfBasketRedemption;
    }
    
    public static void updateBasketRedemptionAmount(Id oppurtunityID,Id basketID, Double redemptionAmt){        
        List<Opportunity> opty = [Select Id,Basket_Redemption_amount__c,(Select Id, csbb__Synchronised_With_Opportunity__c from cscfga__Product_Baskets__r where id =: basketID and csbb__Synchronised_With_Opportunity__c = true) from Opportunity where id =: oppurtunityID limit 1 ];//added by romil EDGE-134518 and EDGE-136954
        if(opty.size()!=0){
            opty[0].Basket_Redemption_amount__c = redemptionAmt;
            update opty;
        }       
    }
    
    //AB changed input param to map to avoid the need for SOQL
    public static void updateRedemptionTransactions(Map<Id, cscfga__Product_Basket__c> basketMap){
        List<Id> accountIdList = new List<Id>();
        List<Id> basketIdList = new List<Id>();
        List<OneFund__c> fundList = new List<OneFund__c>();
        //find only contract rejected baskets and maintain above variables for them
        for (cscfga__Product_Basket__c pb : basketMap.values()) {
            if(pb.csordtelcoa__Basket_Stage__c == 'Contract Rejected') {
                accountIdList.add(pb.csbb__Account__c);
                basketIdList.add(pb.Id);
            }
        }
        //run logic only if needed
        if (!basketIdList.isEmpty()) {
            //get record type ids
            Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
            Id oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
            Id RedemptionRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();
            fundList = [SELECT Id FROM OneFund__c WHERE CIDN__c IN :accountIdList];
            List<OneFund_Transactions__c> otnsvp = new List<OneFund_Transactions__c>();
            
            for(OneFund_Transactions__c otn : [SELECT Transaction_Status__c,RecordTypeId 
                                               FROM OneFund_Transactions__c
                                               WHERE (OneFund__c IN :fundList AND Transaction_Status__c = 'Active' AND Product_Basket__c IN :basketIdList)]){
                if(otn.RecordTypeId==RedemptionRecordId){
                    otn.Transaction_Status__c='Declined';
                    otnsvp.add(otn);
                } else if(otn.RecordTypeId==oneFundAccrualRecordId){
                    otn.Redeemed_Amount__c=0;
                    otnsvp.add(otn);
                }
            }
            if(!otnsvp.isEmpty()) {
                update otnsvp;
            }
        }
    }        
}