/*************************************************************************************************
Name : ProductBasketFieldsUpdate
Description : Used to update Basket Name and Account Info from related Opportunity
              Called in before insert method of ProductBasketTriggerHandler Class 
              which is called from ProductBasketTrigger

Added code to update other basket stages to Cancelled when one basket is submitted for order
1.      Ankit Goswami           02/11/2020      EDGE-181996     Tech Story-Product Basket Enahanchment**
***************************************************************************************************/
public class ProductBasketFieldsUpdate{

    public static void updateNameAndAccountInfo(cscfga__Product_Basket__c[] newBskt)
     {
         //Set to hold opportunity Ids of newly created baskets
         Set<Id> opportunityIdSet = new Set<Id>();
         for(cscfga__Product_Basket__c bkt: newBskt)
         {
            if(bkt.cscfga__Opportunity__c != null){//EDGE-181996  added null check by ankit
             opportunityIdSet.add(bkt.cscfga__Opportunity__c);
         }
         }
         
        if(!opportunityIdSet.isEmpty()){//EDGE-181996  added empty check by ankit
         //Query map holding opportunity name and account id
         Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select id, name,AccountId from Opportunity where id in :opportunityIdSet]);
         
         for(cscfga__Product_Basket__c bkt: newBskt)
         {
             //If the basket has opportunity which is present in the query map
             if(oppMap.get(bkt.cscfga__Opportunity__c)!= null)
              {
                
                //Assigning name and account on opportunity to basket name and account, if these fields on opportunity are not null
                //if(oppMap.get(bkt.cscfga__Opportunity__c).name!=null)
                   //bkt.name = oppMap.get(bkt.cscfga__Opportunity__c).name;
                if(oppMap.get(bkt.cscfga__Opportunity__c).AccountId!=null)
                   bkt.csbb__Account__c = oppMap.get(bkt.cscfga__Opportunity__c).AccountId;
              }     
         }
     }
     }

 

  public static void updateFrameAgreement(cscfga__Product_Basket__c[] newBskt) {
    //get neeed accounts
    Set<Id> accountIds = new Set<Id>();
    for (cscfga__Product_Basket__c bkt: newBskt) {
      accountIds.add(bkt.csbb__Account__c);
    }
    //get accounts with their active FA
    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,
                                                      (SELECT id, csconta__Account__c FROM csconta__Frame_Agreements__r WHERE csconta__Status__c = 'Active')
                                                      FROM Account
                                                          WHERE Id IN: accountIds]);
    for (cscfga__Product_Basket__c bkt: newBskt) {
      Account acc = accountMap.get(bkt.csbb__Account__c);
      //if exaclty one active FA for this account then select it on basket
      if (acc.csconta__Frame_Agreements__r.size() == 1) {
        bkt.csconta__Frame_Agreement__c = acc.csconta__Frame_Agreements__r[0].Id;
      }
    }
  }

  //START: Added for DIGI-3338
  public static void updateFrameAgreementOnBasket(cscfga__Product_Basket__c[] newBskt) {
    //get neeed accounts
    Set<Id> accountIds = new Set<Id>();
    for (cscfga__Product_Basket__c bkt: newBskt) {
      accountIds.add(bkt.csbb__Account__c);
    }
    Map<Id, List<Id>> afaAssociationMap = new Map<Id, List<Id>>();    
    Map<Id, Id> AccountToFrameAgreementId = new Map<Id, Id>();
    List<csconta__Account_Frame_Agreement_Association__c> frameAgreementAssociation = new List<csconta__Account_Frame_Agreement_Association__c>(
                                                          [SELECT Id, csconta__Account__c, csconta__Frame_Agreement__c, csconta__Frame_Agreement__r.csconta__Status__c,csconta__Frame_Agreement__r.Check_Todays_date__c
                                                          FROM csconta__Account_Frame_Agreement_Association__c
                                                          WHERE csconta__Account__c IN :accountIds AND csconta__Frame_Agreement__r.csconta__Status__c = 'Active'
                                                          AND csconta__Frame_Agreement__r.Check_Todays_date__c = true]);

    for(csconta__Account_Frame_Agreement_Association__c afa: frameAgreementAssociation){
      if(!afaAssociationMap.containsKey(afa.csconta__Account__c)){
        afaAssociationMap.put(afa.csconta__Account__c, new List<Id> {});
      }
      afaAssociationMap.get(afa.csconta__Account__c).add(afa.csconta__Frame_Agreement__c);
    }

    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, 
                                                    (SELECT id, csconta__Account__c FROM csconta__Frame_Agreements__r WHERE csconta__Status__c = 'Active' AND Check_Todays_date__c = true) 
                                                    FROM Account
                                                    WHERE Id IN: accountIds]);
          
    if(!afaAssociationMap.isEmpty()){
      for(Id accnt: afaAssociationMap.keyset()){
        if(afaAssociationMap.get(accnt).size() == 1){
          AccountToFrameAgreementId.put(accnt, afaAssociationMap.get(accnt)[0]);
        }
        else if(!accountMap.isEmpty()){
          for(Id acc : accountMap.keyset()){
            if(accountMap.get(acc).csconta__Frame_Agreements__r.size() == 1){
              AccountToFrameAgreementId.put(acc, accountMap.get(acc).csconta__Frame_Agreements__r[0].Id);
            }
          }
        }
      }
    }
    else{
      for(Id acc : accountMap.keyset()){
        if(accountMap.get(acc).csconta__Frame_Agreements__r.size() == 1){
          AccountToFrameAgreementId.put(acc, accountMap.get(acc).csconta__Frame_Agreements__r[0].Id);
        }
      }
    }
   
    if(!AccountToFrameAgreementId.isEmpty()){
      for (cscfga__Product_Basket__c bkt: newBskt) {
        //if exaclty one active FA for this account then select it on basket
          bkt.csconta__Frame_Agreement__c = AccountToFrameAgreementId.get(bkt.csbb__Account__c);
      }
    }
    
  }
  //END for DIGI-3338
     public static void updateBasketStage(cscfga__Product_Basket__c[] newBskt)
     {
        
         Set<Id> opportunityIdSet = new Set<Id>();
         Set<Id> basketSet = new Set<Id>();
         for(cscfga__Product_Basket__c bkt: newBskt)
         {
            if(bkt.cscfga__Opportunity__c !=null && CustomConfigurationOptions__c.getValues('Submitted')!=null && CustomConfigurationOptions__c.getValues('Submitted').Enrichment_Basket_Stage__c !=null)//EDGE-181996  added null check by ankit
            {
                if(bkt.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('Submitted').Enrichment_Basket_Stage__c)
                 {
                  opportunityIdSet.add(bkt.cscfga__Opportunity__c);
                  basketSet.add(bkt.Id);
                 } 
            }   
         }
         
         List<cscfga__Product_Basket__c> productBasketUpdateList = new List<cscfga__Product_Basket__c> ();
        if(!opportunityIdSet.isEmpty()){ //EDGE-181996  added empty check by ankit
         Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select id,(Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Baskets__r where id not in :basketSet) from Opportunity where id in :opportunityIdSet]);
         
         for(Opportunity op: oppMap.Values())
         {
            
            for(cscfga__Product_Basket__c bkt: oppMap.get(op.Id).cscfga__Product_Baskets__r)
             {
              if(CustomConfigurationOptions__c.getValues('CancelBasket')!=null && CustomConfigurationOptions__c.getValues('CancelBasket').Enrichment_Basket_Stage__c !=null)
              {
                  bkt.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('CancelBasket').Enrichment_Basket_Stage__c;
                  productBasketUpdateList.add(bkt);
              }    
             }  
         
         }
        }
         
         if(productBasketUpdateList!=null && productBasketUpdateList.size()>0)
         {
            update productBasketUpdateList;
         }
     }
     
     
}