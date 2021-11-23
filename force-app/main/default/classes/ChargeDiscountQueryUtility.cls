/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : ChargeDiscountQueryUtility  
* @Jira : Edge-127073
* @test class : ChargeDiscountQueryUtilityTest
1. Ankit Goswami     24/02/2020  Added fetchChargeLineItemForStatus method as part of Edge 123594
2. Aman Soni         26/02/2020  Modified by Aman Soni as a part of EDGE-135278
3. Shubhi           5/03/2020  modified the if codition as commercial product id will not be there for nguc voice EDGE-121376
4. Ankit Goswami     12/03/2020  Added fetchChargeLineItemForSolution,fetchPreviousChargeLineItemForSolution method as part of Edge 134880 
5. Aman Soni         26/02/2020  Modified by Aman Soni as a part of EDGE-138169 || Added status__c='New' OR status__c='' to prevent DLI from getting orphan.
*/
public with sharing class ChargeDiscountQueryUtility {
    
    public Map<String,Charge_Line_Item__c> fetchExistingChargeLineItem(Set<String> GuidList){
        System.debug('GuidList inside fetchExistingChargeLineItem...'+GuidList);
        Map<String,Charge_Line_Item__c> existingChargeLineItemMap=new Map<String,Charge_Line_Item__c>();
        if(GuidList!=null && GuidList.size()>0){
            for(Charge_Line_Item__c cli:[SELECT id,serviceId__c,basketId__c,Product_Configuration__c,commercialProductId__c,guid__c,CorrelationId__c,BusinessID__c,contractTerm__c,status__c,solutionId__c,componentName__c FROM Charge_Line_Item__c where guid__c IN: GuidList AND (status__c='New' OR status__c='')])//Modified by Aman Soni || EDGE-135278
            {
              if(!String.isBlank(cli.guid__c) && !String.isBlank(cli.solutionId__c) && !String.isBlank(cli.BusinessID__c)){//modified by shubhi EDGE-121376 || Modified by Aman Soni || EDGE-135278
                 existingChargeLineItemMap.put(cli.guid__c+'_'+cli.solutionId__c+'_'+cli.BusinessID__c,cli);//Modified by Aman Soni || EDGE-135278
                 }
           }
        }
        System.debug('existingChargeLineItemMap...'+existingChargeLineItemMap);
       return existingChargeLineItemMap;
    }
    //Added fetchChargeLineItemForStatus method as part of Edge 123594
    public Map<String,Charge_Line_Item__c> fetchChargeLineItemForStatus(Set<String> GuidList,String basketID){
        System.debug('GuidList inside fetchChargeLineItemForStatus...'+GuidList);
        Map<String,Charge_Line_Item__c> existingChargeLineItemMap=new Map<String,Charge_Line_Item__c>();
        if(GuidList!=null && GuidList.size()>0 && String.isNotBlank(basketID)){
            for(Charge_Line_Item__c cli:[SELECT id,guid__c,status__c,Product_Charge_Identifier__c FROM Charge_Line_Item__c where guid__c IN: GuidList AND basketId__c =: basketID AND Product_Charge_Identifier__c ='AddOn']){
                 if(!String.isBlank(cli.guid__c)){
                     existingChargeLineItemMap.put(cli.guid__c,cli); 
                 }
             }
       }
        System.debug('existingChargeLineItemMap...'+existingChargeLineItemMap);
       return existingChargeLineItemMap;
    }
    //END 

     //Added fetchChargeLineItemForEM method as part of Edge 134880 by ankit
    public Map<String,list<Charge_Line_Item__c>> fetchChargeLineItemForSolution(Set<String> GuidList,String basketID,string SoutionID){
        System.debug('GuidList inside fetchChargeLineItemForStatus...'+GuidList+''+basketID+''+SoutionID);
        Map<String,list<Charge_Line_Item__c>> existingChargeLineItemMap=new Map<String,list<Charge_Line_Item__c>>();
        if(GuidList!=null && GuidList.size()>0 && String.isNotBlank(basketID) && String.isNotBlank(SoutionID)){
            for(Charge_Line_Item__c cli:[SELECT id,guid__c,status__c,Product_Charge_Identifier__c,totalContractValue__c,avgDiscountedPrice__c FROM Charge_Line_Item__c where guid__c IN: GuidList AND basketId__c =: basketID AND solutionId__c=:SoutionID]){
                 List<Charge_Line_Item__c> ChargeItemList=new List<Charge_Line_Item__c>();
                 System.debug('cli...'+cli);
                 if( !existingChargeLineItemMap.containsKey(cli.guid__c) ){
                     ChargeItemList.add(cli);
                     existingChargeLineItemMap.put(cli.guid__c,ChargeItemList); 
                 }else{
                 existingChargeLineItemMap.get(cli.guid__c).add(cli);
                 }
            }   
        }
        System.debug('existingChargeLineItemMap...'+existingChargeLineItemMap);
       return existingChargeLineItemMap;
    }

     public Map<String,list<Charge_Line_Item__c>> fetchPreviousChargeLineItemForSolution(Set<String> GuidList){
        System.debug('GuidList inside fetchChargeLineItemForStatus...'+GuidList);
        Map<String,list<Charge_Line_Item__c>> existingChargeLineItemMap=new Map<String,list<Charge_Line_Item__c>>();
        if(GuidList!=null && GuidList.size()>0 ){
            for(Charge_Line_Item__c cli:[SELECT id,guid__c,status__c,avgDiscountedPrice__c,totalContractValue__c,Product_Charge_Identifier__c FROM Charge_Line_Item__c where guid__c IN: GuidList ]){
                 List<Charge_Line_Item__c> ChargeItemList=new List<Charge_Line_Item__c>();
                  System.debug('cli...'+cli);
                 if(!String.isBlank(cli.guid__c) && !existingChargeLineItemMap.containsKey(cli.guid__c) ){
                     ChargeItemList.add(cli);
                     existingChargeLineItemMap.put(cli.guid__c,ChargeItemList); 
                 }else{
                 existingChargeLineItemMap.get(cli.guid__c).add(cli);
             }
       }
        }
        System.debug('existingChargeLineItemMap...'+existingChargeLineItemMap);
       return existingChargeLineItemMap;
    }
    //END Edge 134880 by ankit

    public List<Charge_Line_Item__c> fetchChargeLineItem(Set<String> CliIDSet){
        System.debug('CliIDSet inside fetchChargeLineItem...'+CliIDSet);
     return [SELECT id,Product_Configuration__c,commercialProductId__c,guid__c,CorrelationId__c,
                                     BusinessID__c,contractTerm__c,status__c,solutionId__c,componentName__c,totalContractValue__c
                                    FROM Charge_Line_Item__c where id IN: CliIDSet];
    }
    //Modified by Aman Soni || EDGE-135278 || Start
    public Map<String,List<Discount_Line_Item__c>> fetchAssociatedDiscountLineItem(Set<String> GuidList){
        Map<String,List<Discount_Line_Item__c>> cliToDliMap=new Map<String,List<Discount_Line_Item__c>>();
        if(GuidList!=null && GuidList.size()>0){
        for(Discount_Line_Item__c dli:[SELECT id,BusinessID__c,chargeInstance__c,chargeInstance__r.guid__c,
                                     chargeInstance__r.commercialProductId__c,chargeInstance__r.BusinessID__c,chargeInstance__r.solutionId__c,description__c,
                                     discountType__c,discountValue__c,duration__c,durationUoM__c                                  
                                    FROM Discount_Line_Item__c where chargeInstance__r.guid__c IN: GuidList]){
           List<Discount_Line_Item__c> dliList=new List<Discount_Line_Item__c>();

               if(cliToDliMap.containsKey(dli.chargeInstance__r.guid__c+'_'+ dli.chargeInstance__r.solutionId__c+'_'+ dli.chargeInstance__r.BusinessID__c)){
                   dliList.addAll(cliToDliMap.get(dli.chargeInstance__r.guid__c+'_'+ dli.chargeInstance__r.solutionId__c+'_'+ dli.chargeInstance__r.BusinessID__c));
               }                           
               dliList.add(dli);
               cliToDliMap.put(dli.chargeInstance__r.guid__c+'_'+ dli.chargeInstance__r.solutionId__c+'_'+ dli.chargeInstance__r.BusinessID__c,dliList);                     
            }
      }
        return cliToDliMap;
        //Modified by Aman Soni || EDGE-135278 || End
    }
    public List<Discount_Line_Item__c> fetchAssociatedDiscountLineItemFromCliID(Set<String> CliList){
        List<Discount_Line_Item__c> dliList=new List<Discount_Line_Item__c>();
        if(CliList!=null && CliList.size()>0){
        for(Discount_Line_Item__c dli:[SELECT id,BusinessID__c,chargeInstance__c,chargeInstance__r.guid__c,
                                     chargeInstance__r.commercialProductId__c,description__c,
                                     discountType__c,discountValue__c,duration__c,durationUoM__c                                  
                                    FROM Discount_Line_Item__c where chargeInstance__c IN: CliList]){                         
           dliList.add(dli);
      }
        }
        return dliList;
    }
}