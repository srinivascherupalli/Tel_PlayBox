/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : ComplexChargeDisountFactory 
* @Jira : Edge-127073
* @test class : ComplexChargeDiscountFactoryTest
1. Aman Soni         26/02/2020  Modified by Aman Soni as a part of EDGE-135278
2. Shubhi            5/3/2020  //Edge-121376 //EDGE-133963
*/
global with Sharing class ComplexChargeDisountFactory extends DiscountLineItem implements ChargeLineInstance {
    /*initializing dli record Edge-127073*/
    public override Discount_Line_Item__c getDiscountLineItem(Charge_Line_Item__c cli,Discount_Line_Item__c dli){
        Discount_Line_Item__c dli_new =new Discount_Line_Item__c();
        if(dli!=null && cli !=null){           
            dli_new=dli;
            system.debug('cli-->'+ cli);
            dli_new.chargeInstance__c=cli.id;
            system.debug('dli_new-->'+ dli_new);
        }
        return dli_new ;
    }
    /*initializing dli record Edge-127073*/
    public Charge_Line_Item__c getChargeLineItem(Charge_Line_Item__c cli_new){
        Charge_Line_Item__c cli=new Charge_Line_Item__c();
        if(cli !=null){
            cli=cli_new;
        }
        return cli;
    }
    /*unit of work insert & update cli's and insert dli's //Edge-121376 added by shubhi || Renamed from Insert to Upsert*/ 
    public void upsertChargeDiscountLineItem(Map<String, Map<String,List<Discount_Line_Item__c>>>  CliToDliMap, Map<String, Map<String,Charge_Line_Item__c>> cliMap){
    if(CliToDliMap.size()>0 && cliMap.size()>0){
      List<Schema.SObjectType> sObjectTypeList = new Schema.SObjectType[] {  
      Charge_Line_Item__c.SObjectType, 
      Discount_Line_Item__c.SObjectType};// updated the order as uow needs parent first
      SObjectUnitOfWork UoW = new SObjectUnitOfWork(sObjectTypeList);
      ChargeDiscountQueryUtility cdq=new ChargeDiscountQueryUtility(); 
      Set<String> CLIidSet=new Set<String>();
      List<Discount_Line_Item__c> ExistingdliList=new List<Discount_Line_Item__c>();               
      if(cliMap.size()>0){
        Map<String,Charge_Line_Item__c> existingCLiMap=cdq.fetchExistingChargeLineItem(cliMap.keySet());
        if(existingCLiMap.size()>0){
          for(Charge_Line_Item__c cli:existingCLiMap.values()){
            CLIidSet.add(cli.id); // updated for EDGE-136331 by shubhi
          }
          for(Discount_Line_Item__c dli:cdq.fetchAssociatedDiscountLineItemFromCliID(CLIidSet)){
            dli.chargeInstance__c=null;
            UoW.registerDirty(dli);
          }
        }
        for(String guid:cliMap.keySet()){
            for(String chargeId:cliMap.get(guid).keyset()){
                
                Charge_Line_Item__c cli=cliMap.get(guid).get(chargeId);
                if(!existingCLiMap.containsKey(cli.guid__c+'_'+cli.solutionId__c+'_'+cli.BusinessID__c)){//Modified by Aman Soni as a part of EDGE-135278
                     UoW.registerNew(cli);
                 }else{
                  Charge_Line_Item__c cli_new=existingCLiMap.get(cli.guid__c+'_'+cli.solutionId__c+'_'+cli.BusinessID__c);//Modified by Aman Soni as a part of EDGE-135278
                  cli.id=cli_new.id;
                  UoW.registerDirty(cli);
              //CLIidSet.add(cli.id);
              }
              List<Discount_Line_Item__c> dliList=new List<Discount_Line_Item__c>();
              if(CliToDliMap.containskey(guid) && CliToDliMap.get(guid).containskey(chargeId)){
                    system.debug('guid-->'+guid);
                    system.debug('chargeId-->'+chargeId);
                  dliList.addAll(CliToDliMap.get(guid).get(chargeId));
                    system.debug('dliList-->'+dliList);
                for(Discount_Line_Item__c dli:dliList){     
                     UoW.registerNew(dli);
                     system.debug('cli to be inserted-->'+cli+''+'dli to be inserted-->'+dli+''+'dli.chargeInstance__c-->'+''+dli.chargeInstance__c); 
                     UoW.registerRelationship(dli, Discount_Line_Item__c.chargeInstance__c, cli); 
                  }
              }
            }  
        }
        system.debug('@@uow-->'+uow);
        UoW.commitWork();
      }
    }
    }
    /*method to update cli Edge-127073*/
    public void updateChargeLineItem(List<Charge_Line_Item__c> cliList){
        List<Schema.SObjectType> sObjectTypeList = new Schema.SObjectType[] { 
                    Charge_Line_Item__c.SObjectType};
        SObjectUnitOfWork UoW = new SObjectUnitOfWork(sObjectTypeList);
        for(Charge_Line_Item__c cli : cliList){
            UoW.registerDirty(cli);
        }
        system.debug('@@uow-->'+uow);
        UoW.commitWork();
    }
    /*method to update dli Edge-127073*/
    public void updateDiscountLineItem(List<Discount_Line_Item__c> dliList){
    }
}