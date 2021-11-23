/*************************************************************************************************
Name : ProductConfigurationCustomTrigger
Description : Test class for UpdateBasketFieldsAfterPCRCreation
Ch.No.    Developer Name          Date          Story Description
1.        Pooja                   20/07/2020:   CS Spring'20 Upgrade
***************************************************************************************************/

//Trigger in-activated as CS Spring'20 Upgrade change
trigger ProductConfigurationCustomTrigger on cscfga__Product_Configuration__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  
{ 
    //Pooja: CS Spring'20 Upgrade Start
    /*if(Trigger.isbefore && Trigger.isUpdate)
    {
        for (cscfga__Product_Configuration__c pc : Trigger.new)
        {
            if (pc.cscfga__Screen_Flow__c != null)
            {
                pc.cscfga__Screen_Flow__c = null;
            }
        }
    } 
    if (Trigger.isbefore && Trigger.isInsert)
    {
        for (cscfga__Product_Configuration__c pc : Trigger.new)
        {
            if (pc.cscfga__Screen_Flow__c != null)
            {
                pc.cscfga__Screen_Flow__c = null;
            }
        }
    }    

    //****************************************************************************************************************************************************************
    //* Code Logic to update the Basket Status = Valid, when all the related child PC's Configuration Status is Valid
    //***************************************************************************************************************************************************************** / 
   if(Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug('***Entered trigger:ProductConfigurationCustomTrigger, Event:AfterUpdate to update basket status***');
        Set<Id> basketToLookUpIds =  new Set<Id>(); 
        Set<Id> basketToIgnoreIds =  new Set<Id>();
        List<cscfga__Product_Basket__c> basketsToUpdate = new List<cscfga__Product_Basket__c>();
        Map<Id, cscfga__Product_Basket__c> basketToPCListMap = new Map<Id, cscfga__Product_Basket__c>();
        for (cscfga__Product_Configuration__c pc : Trigger.new)
        {
            System.debug('pc == '+pc);
            if (//*Trigger.oldMap.get(pc.Id).cscfga__Configuration_Status__c!='Valid' && * //Trigger.newMap.get(pc.Id).cscfga__Configuration_Status__c=='Valid')
            {
                /*if(basketToPCListMap.keyset().contains(pc.cscfga__Product_Basket__c)){
                    basketToPCListMap.get(pc.cscfga__Product_Basket__c).add(pc)
                }else{
                    basketToPCListMap.put(pc.cscfga__Product_Basket__c,pc);
                }//* /
                basketToLookUpIds.add(pc.cscfga__Product_Basket__c);
            }
        }
        if(basketToLookUpIds.size()>0){
            for(cscfga__Product_Basket__c basket : [SELECT Id, Name, cscfga__Basket_Status__c, (SELECT Id, Name, cscfga__Configuration_Status__c from cscfga__Product_Configurations__r) FROM cscfga__Product_Basket__c WHERE ID IN: basketToLookUpIds]){
                basketToPCListMap.put(basket.Id, basket);
            }
        }
        system.debug('basketToPCListMap====>>>>>'+basketToPCListMap.keyset());
        for(Id baskId: basketToPCListMap.keyset()){
            for(cscfga__Product_Configuration__c pc: basketToPCListMap.get(baskId).cscfga__Product_Configurations__r){
                if(pc.cscfga__Configuration_Status__c!='Valid'){
                    basketToIgnoreIds.add(baskId);
                    break;
                }
            }
        }
        basketToLookUpIds.removeAll(basketToIgnoreIds);
        system.debug('basketToLookUpIds====>>>>>'+basketToLookUpIds);
        for(Id baskId: basketToPCListMap.keyset()){
            if(basketToLookUpIds.size()>0 && basketToLookUpIds.contains(baskId) && basketToPCListMap.get(baskId).cscfga__Basket_Status__c!='Valid'){
                cscfga__Product_Basket__c basketUpd = new cscfga__Product_Basket__c();
                basketUpd.Id = baskId;
                basketUpd.cscfga__Basket_Status__c='Valid';
                basketsToUpdate.add(basketUpd);
            }
        }
        system.debug('basketsToUpdate====>>>>>'+basketsToUpdate);
        if(basketsToUpdate.size()>0){
            update basketsToUpdate;
        }
    } */
    //Pooja: CS Spring'20 Upgrade End
}