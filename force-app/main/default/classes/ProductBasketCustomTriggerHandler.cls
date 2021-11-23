/**********************************************************************************************************************************
 *Class Name      :   ProductBasketCustomTriggerHandler
 *Story             :   EDGE-104215
 *Developer         :   Abinash

Test Class : ProductBasketCustomTriggerHandlerTest
===============================================================================================================================
Sr.No.  Developer Name          Date            Story Description
1.      Abinash Barik           08/02/2019      EDGE-104215/EDGE-81085        
2.      Mohammed Zeeshan        04/05/2020      EDGE-144055 - Updated 
3.      Pooja                   20/07/2020      Spring 20 upgrade 
4.      Shweta Mamadapure       01/09/2020      EDGE-172955-Refactoring
5.      Pooja Bhat/Shweta M     28/09/2020      EDGE-178203 Technical Refactoring - Opportunity Sync - DML Operations
6.      Srujana Durvasula       12/11/2020      P2OB-10782 Adding condition that Autosync platform event should NOT be fired for ‘TESA User’
7.      Ankit Goswami           02/11/2020      EDGE-181996     Tech Story-Product Basket Enahanchment**
8.      Srujana Durvasula       19/03/2021     P2OB-13499 TESA Writeback Sync not working (Baskets created from TESA)
9.    Akanksha Jain      10/03/2021    EDGE-195863    Updated code to update device care contact reuiqred to No or Yes for Inflight basket
10.      Srujana Durvasula       08/04/2021   	P2OB-13544 Manual Sync- Revenue details on the opportunity are not synced
 *********************************************************************************************************************************
*/
public with sharing class ProductBasketCustomTriggerHandler {
    
    public void OnBeforeInsert(cscfga__Product_Basket__c[] newBskt) {
        ProductBasketFieldsUpdate.updateNameAndAccountInfo(newBskt);
        //START: Added for DIGI-3338
        ProductBasketFieldsUpdate.updateFrameAgreementOnBasket(newBskt);
        //END for DIGI-3338
        //Below FOR Loop checks if the opportunity has more than 0 primary basket, then do make the
        //primary basket and sync flags as false for the new basket to be inserted- To handle the Cloned Basket issue
        Integer basketCount = 0;
            if(newBskt[0].cscfga__Opportunity__c !=null){//EDGE-181996 
                List<cscfga__Product_Basket__c> listProductBasket =
                    [SELECT Id, Primary_Basket__c
                        FROM cscfga__Product_Basket__c
                        WHERE cscfga__Opportunity__c = : newBskt[0].cscfga__Opportunity__c
                    ];
                basketCount = listProductBasket.size();
                //Sets Primary_Basket__c = true for the first basket
                if(basketCount <1) {
                    newBskt[0].Primary_Basket__c = true;
                }
                Boolean isPrimaryBasketPresent =false;
                //Below code checks if the basket to be inserted is the first basket, then make the basket as primary
                for(cscfga__Product_Basket__c prodBasket :listProductBasket) {
                    if(prodBasket.Primary_Basket__c) {
                        isPrimaryBasketPresent=true; 
                        break;
                    }
                }
                //Below code checks if the previous basket has primary as true then it updates the is Primary false 
                if(isPrimaryBasketPresent) {
                    for(cscfga__Product_Basket__c newBasket :newbskt) {  
                        if(newBasket.Primary_Basket__c){
                            newBasket.Primary_Basket__c = false;
                            newBasket.csordtelcoa__Synchronised_with_Opportunity__c = false;
                            newBasket.csbb__Synchronised_With_Opportunity__c = false;   
                        }
                    }
                }
            }
        //Start of EDGE-144055-Enable only online users to skip the contract/order form approval process
        set<Id> productBasketId = new set<Id>();
        List<account> accountObject= new List<account>();
        List<Opportunity> opportunityData;
        set <Id> accountList = new set <Id> ();
        set <Id> accountList1 = new set <Id> ();
        List <cscfga__Product_Basket__c> prodBasketList;
        List <ContractJunction__c> contractJunList;
        Boolean updateRequired = false;
        Boolean contractStatus = false; 
        //Check if user has Skip_Contract_Basket_Express_Order permission set assigned

        Boolean hasCustomPermission = FeatureManagement.checkPermission('Express_Order_Enabled');
        system.debug('hasCustomPermission-->'+hasCustomPermission);
            
        if(hasCustomPermission && newBskt[0].cscfga__Opportunity__c !=null) {//EDGE-181996 
            opportunityData =[ SELECT AccountId FROM OPPORTUNITY WHERE ID  =: newBskt[0].cscfga__Opportunity__c   LIMIT 1];
            system.debug('opportunityData---->'+opportunityData);
            for (OPPORTUNITY opp: opportunityData ){
                accountList1.add(opp.AccountId);
            }
            contractJunList = [SELECT Id, Account__C, BSA_Generated__c, Status__c FROM ContractJunction__c where Account__C IN: accountList1];
            //Set a hidden flag based on the BSA flag in contract and the status in contract junction.
            for (ContractJunction__c contractJun: contractJunList) {
                contractStatus= contractJun.BSA_Generated__c && !System.Label.contract_Status.contains(contractJun.Status__c); 
                // If BSA flag is true on Contract junction set BSA Generated flag on Product Basket
                if (contractStatus) {
                    for (cscfga__Product_Basket__c updateBasket: newBskt) {
                        updateBasket.BSA_Generated__c = true;
                        updateRequired = true;    
                    }
                //End of EDGE-144055-Enable only online users to skip the contract/order form approval process 
                }
            }
        }   //End of if(hasCustomPermission)   
    }   //End of OnBeforeInsert()

      //Changed the parameter from Trigger.old to Trigger.oldMap to avoid nested for loops as part of Refactoring 
    public void OnBeforeUpdate(Map<Id,cscfga__Product_Basket__c> oldBsktsMap,cscfga__Product_Basket__c[] updatedBskts) {
        
       
        for(cscfga__Product_Basket__c updateBsk:updatedBskts)
        {
            cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(updateBsk.id);  
            String recordTypeName = productBasket.recordType.Name;
            if(oldBsktsMap.get(updateBsk.Id).csordtelcoa__Basket_Stage__c!= 'Contract Accepted' &&
            updateBsk.csordtelcoa__Basket_Stage__c== 'Contract Accepted')
            {
              if (recordTypeName != 'Inflight Change' ){
              updateBsk.csordtelcoa__Synchronised_with_Opportunity__c = true;
              updateBsk.csbb__Synchronised_With_Opportunity__c = true;
            }
            }
            if((updateBsk.Project_Complexity__c == 'Complex' || updateBsk.Project_Complexity__c == 'Complex Plus')
            && updateBsk.csordtelcoa__Basket_Stage__c == 'Contract Accepted'){
              updateBsk.PM_Required__c = true;
           }
            if(updateBsk.Project_Complexity__c == 'Simplex' || updateBsk.Project_Complexity__c == 'Simplex Plus'){
              updateBsk.PM_Required__c = false;
           }
            
          if(updateBsk.RecordTypeId!=null && updateBsk.csordtelcoa__Basket_Stage__c == 'Contract Accepted')
      {  Id basketRecordTypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        if(basketRecordTypeId ==updateBsk.RecordTypeId)
        {
          set <Id> inflightBasketId = new set <Id> ();
          inflightBasketId.add(updateBsk.Id);
          if(inflightBasketId.size()>0)
          {
                      list<cscfga__Product_Configuration__c > lstProdConfig= [select cscfga__Product_Basket__r.Id,cscfga__Product_Basket__r.Is_Device_Care_Contact_Required__c,Id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c IN:inflightBasketId and cscfga__Product_Definition__r.product_Specification__c ='DMCAT_ProductSpecification_001208' and type__c ='New']; 
            if(lstProdConfig.size()>0)
                      {
                          for(cscfga__Product_Configuration__c prodConfig : lstProdConfig)
                          {
                              if(prodConfig.cscfga__Product_Basket__r.Id ==updateBsk.Id)
                                  updateBsk.Is_Device_Care_Contact_Required__c = 'Yes';
                          }
                          system.debug('Inflight basket---if'+updateBsk.Is_Device_Care_Contact_Required__c);
                      }
                      else
                      {
                          updateBsk.Is_Device_Care_Contact_Required__c = 'No'; 
                          system.debug('Inflight basket---else'+updateBsk.Is_Device_Care_Contact_Required__c);
                      }
          }
         }
      }
           system.debug('updatedBskt>>>>' + updateBsk.PM_Required__c+updateBsk.RecordTypeId);
        }
      }
   /*************************************************************************************************
Name        : OnAfterUpdateTransition
Description : update transition json on status change 
Author      : Kalashree Borgaonkar
Story       : EDGE-203022,EDGE-198379
Revision 	: Making the code dormant as story is on hold
***************************************************************************************************/ 
   /* public void onAfterUpdateTransition( Map<ID, cscfga__Product_Basket__c> oldBsktsMap,Map<ID, cscfga__Product_Basket__c> updateBsktsMap) {
        Set<Id> basketIdSet = new Set<Id> ();
        for(String ids : updateBsktsMap.keyset()){
            if(updateBsktsMap.get(ids).Transition_basket_stage__c!=oldBsktsMap.get(ids).Transition_basket_stage__c
               && (updateBsktsMap.get(ids).Transition_basket_stage__c == 'Reservation Completed' || updateBsktsMap.get(ids).Transition_basket_stage__c == 'Check Eligibility Completed')){
                   basketIdSet.add(ids);
               } 
        } 
        System.debug('basketIdSet: '+basketIdSet);
        if(!basketIdSet.isEmpty()){
            UpdateTramasResponseTransition updateTramas = new UpdateTramasResponseTransition(basketIdSet);    
            ID jobID = System.enqueueJob(updateTramas);
        }        
    }*/
    public void OnAfterUpdate(cscfga__Product_Basket__c[] oldBskts, Map<ID, cscfga__Product_Basket__c> oldBsktsMap,
                              cscfga__Product_Basket__c[] updatedBskts, Map<ID, cscfga__Product_Basket__c> updateBsktsMap) {
      if (StaticUtilForRecursion.runOnceAfterUpdateBasket()) {
        System.debug(LoggingLevel.INFO, 'OnAfterUpdate.oldBskts = ' + oldBskts);
        System.debug(LoggingLevel.INFO, 'OnAfterUpdate.updatedBskts = ' + updatedBskts);
        ProductBasketTriggerHelper.updateAttributeInfo(oldBskts, oldBsktsMap, updatedBskts, updateBsktsMap);
        //  EDGE-178203 Changes Start : Commented as part of EDGE-178203 Technical Refactoring - Opportunity Sync - DML Operations, this is now handled in ProductBasketCustomTrigger
        // Id profileId = userinfo.getProfileId();
        // String profileName = '';
        // List<Profile> profileList =
        //   [
        //     SELECT Id, Name
        //     FROM Profile
        //     WHERE Id = :profileId
        //   ];
        // if (profileList != null && profileList.size() > 0)
        //   profileName = profileList[0].Name;
        //   //Collect opportunity Ids 
        //   Set<Id> oppIds=new Set<Id>();
        //   Map<Id,Opportunity> oppMap=new Map<Id,Opportunity>();
        //   for(cscfga__Product_Basket__c bas: updatedBskts){
        //         oppIds.add(bas.cscfga__Opportunity__c);
        //   }
        //   for (Opportunity opp : [
        //            SELECT id, StageName, Product_Type__c
        //            FROM Opportunity
        //            WHERE id IN : oppIds
        //          ]) {
        //           oppMap.put(opp.Id, opp);
        //          }
        //Replaced nested for loops as part of Refactoring  
        // Map<Id,cscfga__Product_Basket__c> oppIdBasketMap=new Map<Id,cscfga__Product_Basket__c>();
        // Map<Id,String> oppIdBasketStageMap=new Map<Id,String>();
        //   for(cscfga__Product_Basket__c bas: updatedBskts){
        //     //Boolean entryCriteria = false;
            
        //         if(oldBsktsMap.get(bas.Id).csordtelcoa__Basket_Stage__c !=bas.csordtelcoa__Basket_Stage__c &&
        //         bas.csordtelcoa__Basket_Stage__c!='Submitted'){
        //             //entryCriteria = true;
                
        //         if (oppMap.get(bas.cscfga__Opportunity__c).Product_Type__c == 'Non Modular' && bas.Primary_Basket__c && oppMap.get(bas.cscfga__Opportunity__c).StageName != 'Closed Won' &&
        //           !(profileName == 'Sales - Enterprise' || profileName == 'Sales Manager - Enterprise' || profileName == 'Sales-Enterprise-Unified')) {
        //             oppIdBasketMap.put(bas.cscfga__Opportunity__c,bas);
        //             if (bas.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c &&
        //             bas.cscfga__Products_In_Basket__c != NULL)
        //          // OpportunitySyncUtil.updateOpptInfo(bas, 'CommercialConfiguration');
        //              oppIdBasketStageMap.put(bas.cscfga__Opportunity__c,'CommercialConfiguration');
        //             else if (bas.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c)
        //          // OpportunitySyncUtil.updateOpptInfo(bas, 'Quote');
        //              oppIdBasketStageMap.put(bas.cscfga__Opportunity__c,'Quote');
        //       }
        //      }
        //     }
        
        // Added the method updateOpptInfo from OpportunitySyncUtil Class to avoid the SOQLs inside for loop as part of Refactoring     
        //   List<Opportunity> oppList=[SELECT id, StageName, pricebook2id, (SELECT id FROM OpportunityLineItems)
        //   FROM Opportunity WHERE id IN : oppIdBasketStageMap.KeySet()] ; 
        //   for(Opportunity opp:oppList){
        //       if(!oppIdBasketStageMap.isEmpty()){
        //         //for Phoenix Users only from Define to Develop 
        //         if((profileName == 'Sales - Enterprise' || profileName == 'Sales Manager - Enterprise' || profileName == 'Sales-Enterprise-Unified') && opp.StageName == 'Define' && oppIdBasketStageMap.get(opp.Id) == 'CommercialConfiguration')
        //            opp.StageName = CustomConfigurationOptions__c.getValues(oppIdBasketStageMap.get(opp.Id)).Opportunity_Stage__c;
        //          else if (!(profileName == 'Sales - Enterprise' || profileName == 'Sales Manager - Enterprise'))
        //            opp.StageName = CustomConfigurationOptions__c.getValues(oppIdBasketStageMap.get(opp.Id)).Opportunity_Stage__c;
        //         System.debug(LoggingLevel.INFO, 'updateOpptInfo.StageName = ' + opp.StageName);
        //       }
        //         opp.Amount = oppIdBasketMap.get(opp.Id).cscfga__total_contract_value__c;
        //   }
        //   update oppList;
  
        // //Replaced nested for loops as part of Refactoring 
        // //fix error to check null
        // List<cscfga__Product_Basket__c> updatedBasket =new List<cscfga__Product_Basket__c>();
        // for(cscfga__Product_Basket__c basket: updatedBskts){
        //     if(oldBsktsMap.get(basket.Id).csordtelcoa__Basket_Stage__c !='Contract Accepted' && 
        //     basket.csordtelcoa__Basket_Stage__c == 'Contract Accepted'){
        //         updatedBasket.add(basket);
                
        //     }
        // }
            
        // system.debug(LoggingLevel.INFO, 'OnAfterUpdate.updatedBasket = ' + updatedBasket);

        //  if(updatedBasket.size()>0){
        //   if (new CustomButtonOpportunitySync().syncMessage(updatedBasket[0].Id, false).contains('ok'))
        //     OpportunitySyncUtil.updateOpptInfo(updatedBasket[0], 'ContractAccepted');
        // }
        //  EDGE-178203 Changes End : Commented as part of EDGE-178203 Technical Refactoring - Opportunity Sync - DML Operations, this is now handled in ProductBasketCustomTrigger
        /* JIRA - EDGE-25504 - MAQ */
        ProductBasketTriggerHelper.updateOldQuotesToVoid(oldBskts, oldBsktsMap, updatedBskts, updateBsktsMap);
    } 
	
	 Set<Id> setOfBasketId = new Set<Id>();
        for(cscfga__Product_Basket__c bas : updatedBskts) {
            setOfBasketId.add(bas.Id);
        }
                     
      List<cscfga__Product_Basket__c> productBaskets = new List<cscfga__Product_Basket__c>([Select id,LastModifiedBy.Name from cscfga__Product_Basket__c where Id IN: setOfBasketId]);
      Map<Id, cscfga__Product_Basket__c> mapOfBasket = new Map<Id,cscfga__Product_Basket__c>(productBaskets);

      List<AutoSync__e> syncEvents = new List<AutoSync__e>();
      for (cscfga__Product_Basket__c bas : updatedBskts) {
        System.debug(LoggingLevel.INFO, 'OnAfterUpdate.cscfga__Basket_Status__c = ' + bas.cscfga__Basket_Status__c + bas.cscfga__Products_Id_Qty_In_Basket__c);
        System.debug(LoggingLevel.INFO, 'OnAfterUpdate.Primary_Basket__c = ' + bas.Primary_Basket__c);
        System.debug(LoggingLevel.INFO, 'OnAfterUpdate.csbb__Synchronised_with_Opportunity__c = ' + bas.csbb__Synchronised_with_Opportunity__c);
    
		String lastModifiedBasName;
        if(mapOfBasket != null &&  mapOfBasket.get(bas.Id) != null) {
        	lastModifiedBasName =  mapOfBasket.get(bas.Id).LastModifiedBy.Name;     
        }
        System.debug(LoggingLevel.INFO, 'OnAfterUpdate.LastModifiedBy.Name = ' + lastModifiedBasName); 
    
        //P2OB-10782 Adding condition that Autosync platform event should NOT be fired for ‘TESA User’
          if (!String.isBlank(lastModifiedBasName) && lastModifiedBasName != System.Label.TESAIntegrationUserName && bas.BasketOppType__c != Label.Modular && bas.Primary_Basket__c &&
            ((bas.cscfga__Basket_Status__c == 'Valid' && !bas.csbb__Synchronised_with_Opportunity__c) ||
             (oldBsktsMap.get(bas.Id).cscfga__Products_Id_Qty_In_Basket__c != bas.cscfga__Products_Id_Qty_In_Basket__c)) &&
            StaticUtilForRecursion.runAutoSyncOnce())
          syncEvents.add(new AutoSync__e(Basket_Id__c = bas.id, SyncFlag__c = false)) ;
		   //P2OB-13544 Fix for Manual Sync- Revenue details on the opportunity are not synced For Standard Opportunities
         else if (!String.isBlank(lastModifiedBasName) && lastModifiedBasName != System.Label.TESAIntegrationUserName && bas.BasketOppType__c != Label.Modular && bas.Primary_Basket__c &&
                  ((bas.cscfga__Basket_Status__c == 'Valid' && bas.csbb__Synchronised_with_Opportunity__c) ||
                   (oldBsktsMap.get(bas.Id).cscfga__Products_Id_Qty_In_Basket__c != bas.cscfga__Products_Id_Qty_In_Basket__c)) &&
                  StaticUtilForRecursion.runAutoSyncOnce())
          syncEvents.add(new AutoSync__e(Basket_Id__c = bas.id, SyncFlag__c = false)) ;
      }
                                    
      System.debug(LoggingLevel.INFO, 'ProductBasketCustomTriggerHandler.syncEvents = ' + syncEvents);
      if (syncEvents.size() > 0)
        EventBus.publish(syncEvents);
    }
  }