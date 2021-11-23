/*********************
Class Name: AccountLevelProductObserverHelperTest
============================================================================
ChangeSet   No    Name            Date                    Description
EDGE-89844  1     Rohit T 		 12-June-2019             Products are not getting added for MAC Mobility order
*********************/
global with sharing class AccountLevelProductObserverHelper
{
   global static void checkSubPresentOnAcc(cscfga__Product_Configuration__c prodConfig)
   {
       System.debug('Entereed in AccountLevelProductObserverHelper');
       Set<Id> pcSet = new Set<Id>();
       List<Id> subIds = new List<Id>();
       Integer iIPVPNCount = 0, iUCECount = 0;
       try
       {
               cscfga__Product_Basket__c bkt = [select id,name,csbb__Account__r.Name, csordtelcoa__Change_Type__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c from cscfga__Product_Basket__c where id IN (select cscfga__Product_Basket__c from cscfga__Product_Configuration__c where id =: prodConfig.Id) AND cscfga__Opportunity__r.Product_Type__c = 'Modular'  LIMIT 1];
               System.debug('Basket value for current configuration====>'+bkt.Name);
              
               if(bkt.csordtelcoa__Change_Type__c == null) {
                        bkt.csordtelcoa__Change_Type__c = 'Upgrade';
                        update bkt;
                    }
                     Map<Id, csord__Subscription__c > mapSubs = new Map<Id,csord__Subscription__c>([SELECT Id, Name, csord__Status__c,csord__Account__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__product_basket__c FROM csord__Subscription__c WHERE csord__Account__r.Id =: bkt.csbb__Account__c AND ( Name =: System.Label.IP_Network OR Name =: System.Label.UC_Config_Name) AND  csord__Status__c = 'Active']);
                     Map<Id,cscfga__Product_Configuration__c> mapProdConfig = new map<Id,cscfga__Product_Configuration__c>([Select id, Name, cscfga__Product_Definition__r.name from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id =:bkt.Id AND  ( cscfga__Product_Definition__r.name =: System.Label.IP_Network OR cscfga__Product_Definition__r.name =: System.Label.UC_Enterprise )]);
               // got Ipnetwork sub and account
               List<csord__Subscription__c> subListOnAcc  = mapSubs.values();                 
                    List<cscfga__Product_Configuration__c> prodConfig1 = mapProdConfig.values();                    
                    for(cscfga__Product_Configuration__c prodConf : prodConfig1)
                    {
                        system.debug('***********prodConfig.cscfga__Product_Definition__r.name AccountLevelProductObserverHelper: '+prodConfig.cscfga__Product_Definition__r.name);
                        if(prodConf.cscfga__Product_Definition__r.name == System.Label.IP_Network)
                        {
                            iIPVPNCount++;
                        }
                        
                        if(prodConf.cscfga__Product_Definition__r.name == System.Label.UC_Enterprise)
                        {
                            iUCECount++;
                        }
                    }
                    
                    
                        if(iIPVPNCount < 1 &&  iUCECount < 1){
                            for(csord__Subscription__c sub : subListOnAcc){
                                subIds.add(sub.id);
                                System.debug('subIds with ip net AccountLevelProductObserverHelper==='+subIds);
                            }
                        }
               
                List <csord__Subscription__c> subSelected = [select Id,csord__Status__c,csordtelcoa__Change_Type__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__product_basket__c from csord__Subscription__c where id IN: subIds];
                System.debug('subSelected for AccountLevelProductObserverHelper=====>'+subSelected);
             //  List<csordtelcoa__Subscr_MACDProductBasket_Association__c> subMacPBList = new List<csordtelcoa__Subscr_MACDProductBasket_Association__c>();
                
                List<csordtelcoa__Subscription_MACDOpportunity_Association__c> subMacOppList = new List<csordtelcoa__Subscription_MACDOpportunity_Association__c>();
                Set<Id> pcToUpdateIdSet =  new Set<Id>();                  
                    for(csord__Subscription__c sub:subSelected)
                    {
                        //	EDGE-89844
                         if(sub.csordtelcoa__Change_Type__c=='' && sub.csordtelcoa__Change_Type__c==null){
                            sub.csordtelcoa__Change_Type__c = system.label.Modify;
                        }
                    
                        csordtelcoa__Subscription_MACDOpportunity_Association__c subMACOppty = new csordtelcoa__Subscription_MACDOpportunity_Association__c();
                        subMACOppty.csordtelcoa__Subscription__c = sub.Id;
                        subMACOppty.csordtelcoa__Opportunity__c = bkt.cscfga__Opportunity__c;   
                        subMacOppList.add(subMACOppty); 
                        
                        
            if(sub.csordtelcoa__Product_Configuration__c != null){
                pcToUpdateIdSet.add(sub.csordtelcoa__Product_Configuration__c);
            }
                    }
                    
                    insert subMacOppList;
                    
                    
         List<cscfga__Product_Configuration__c> pcToUpdateList = new List<cscfga__Product_Configuration__c>();
        
        for(csord__Service__c modServices: [Select id,name,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.Type__c from csord__Service__c where csord__Subscription__c IN : subIds]){
            if(modServices.csordtelcoa__Product_Configuration__c != null && modServices.csordtelcoa__Product_Configuration__r.Type__c!='Modify'){
                pcToUpdateIdSet.add(modServices.csordtelcoa__Product_Configuration__c);
            }
                
        }
        for(Id pcIds: pcToUpdateIdSet){
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
            pc.Id = pcIds;
            pc.Type__c='Modify';
            pcToUpdateList.add(pc);
        }
        
        if(!pcToUpdateList.isEmpty()){
            update pcToUpdateList;
        }
                   System.debug('Subs Id '+subIds);
           			System.debug('Basket Id '+bkt.id);
                    csordtelcoa.API_V1.addSubscriptionsToMacBasket(subIds, bkt.id, false);
              
                    System.debug('end of loop fro AccountLevelProductObserverHelper');
       }
       catch(Exception ex){
           //throw new AuraHandledException(ex.getMessage());
       }
   }

}