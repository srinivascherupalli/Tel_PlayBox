/**
* This class is written for story EDGE-118623.
* It has logic to update the SkipLine Items steps and create case and fulfillment Line items.
* @JIRA STORY : EDGE-118623
**/
/***History of Updates 
Purushottama Sahu: 05/02/2020  EDGE-130011  Creating Fuctional Contact Role
RaviTeja: 18/02/2020  EDGE-124063  Making Operational User as Owner of Case and FLI
Purushottama Sahu: 29/04/2020  EDGE-137134  Added fflib_SObjectUnitOfWork Framework and For NGUC FCR will create for the Parent Subscription
***/
public with sharing class ManualFulfillment {
  // EDGE-137134 >> Start
    private fflib_SObjectUnitOfWork sObjectUOW = null;




    public ManualFulfillment(){
        this.sObjectUOW = new fflib_SObjectUnitOfWork(new List<SObjectType> {
                Case.SObjectType,
                FulfillmentLineItem__c.SObjectType,
                Functional_Contact_Role__c.SObjectType,
                csord__Order__c.SObjectType,
                csord__Service__c.SObjectType,
                csord__Subscription__c.SObjectType});
    }

    public void commitWork(){
        sObjectUOW.commitWork();
    }
  // EDGE-137134 >> End

    //Update skipFulfillment__c = true for order where basketConfiguration is having "SOMOpenAir"
    public void isFulfillmentRequired(List<csord__Subscription__c> subscriptions){
        List<csord__Order__c> skipFulfillmentOrder = new List<csord__Order__c>();
        Map<Id,List<csord__Subscription__c>> orderSubscriptionMap = loadOrderSubscriptionMap(subscriptions);
        for(Id orderId : orderSubscriptionMap.keySet()){
            Integer countRecord = 0;
            csord__Order__c orderRecord = null;
            for(csord__Subscription__c subscription : orderSubscriptionMap.get(orderId)){
                if(subscription.MarketableOffer__r != NULL && String.isNotBlank(subscription.MarketableOffer__r.Config__c)){
                    Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                    if(basketConfiguration.get('SOMOpenAir') != NULL && (Boolean)basketConfiguration.get('SOMOpenAir')){
                        countRecord++;
                    }
                }
                orderRecord = subscription.csord__Order__r;
            }
            if(orderSubscriptionMap.get(orderId).size() == countRecord){
                orderRecord.skipFulfillment__c = true;
                //skipFulfillmentOrder.add(orderRecord); // EDGE-137134 >> -
                sObjectUOW.registerDirty(orderRecord);  // EDGE-137134 >> +
            }
        }
    }

    public void fulfillmentByCASE(List<csord__Subscription__c> subscriptions){
        Map<Id,List<csord__Subscription__c>> solutionSubscriptionMap = filterSubscriptionByFulfillmentType(subscriptions);
        system.debug('solutionSubscriptionMap'+solutionSubscriptionMap);
        if(!solutionSubscriptionMap.isEmpty()){
            //createFulfillmentLineItem(solutionSubscriptionMap);
            createFulfillmentLineItem(solutionSubscriptionMap, getOrderSubscriptionConfigMapping(subscriptions));  //EDGE-130011 
        }
    }
    // Get Subscriptions for Order Id
    public List<csord__Subscription__c> getSubscriptionByOrderId(List<Id> orderIds){
        List<csord__Subscription__c> subscriptionList = [SELECT Id,Name,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Order__r.csord__Status2__c,cssdm__solution_association__c,
        csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,csord__Account__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
        MarketableOffer__c, MarketableOffer__r.Config__c,MarketableOffer__r.Name,toBeCancelled__c,Trigger_RTS__c,triggerBill_RTB__c,Billing_Account__c,MarketableOffer__r.Offer_ID__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Type__c,Parent_Subscription__c,
        (SELECT Id,Tenancy_Id__c,Purchase_Order_No__c,csord__Status__c from csord__Services__r)
        from csord__Subscription__c where csord__Order__c IN :orderIds];
        return subscriptionList;
    }
    //Create order and Subcription Map
    private Map<Id,List<csord__Subscription__c>> loadOrderSubscriptionMap(List<csord__Subscription__c> subscriptions){
        Map<Id,List<csord__Subscription__c>> orderSubscriptionMap = new Map<Id,List<csord__Subscription__c>>();
        for(csord__Subscription__c subscription : subscriptions){
            if(orderSubscriptionMap.get(subscription.csord__Order__c) == NULL){
                orderSubscriptionMap.put(subscription.csord__Order__c,new List<csord__Subscription__c>{subscription});
            } else {
                orderSubscriptionMap.get(subscription.csord__Order__c).add(subscription);
            }
        }
        return orderSubscriptionMap;
    }
    private Map<Id,List<csord__Subscription__c>> filterSubscriptionByFulfillmentType(List<csord__Subscription__c> subscriptions){
        Map<Id,List<csord__Subscription__c>> orderSubscriptionMap = new Map<Id,List<csord__Subscription__c>>();
        processManagedServicesOffers(subscriptions);//EDGE-135488
        
        for(csord__Subscription__c subscription :  subscriptions){
            if(subscription.MarketableOffer__r != NULL && subscription.csordtelcoa__Product_Configuration__r != NULL &&
                    String.isNotBlank(subscription.MarketableOffer__r.Type__c) &&
                    subscription.MarketableOffer__r.Type__c == 'Professional Service' &&
                    subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' &&
                    String.isNotBlank(subscription.MarketableOffer__r.Config__c))
            {
                Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                if(basketConfiguration.get('SOMOpenAir') != NULL && (Boolean)basketConfiguration.get('SOMOpenAir')){
                    if(orderSubscriptionMap.get(subscription.csord__Order__c) == NULL){
                        orderSubscriptionMap.put(subscription.csord__Order__c,new List<csord__Subscription__c>{subscription});
                    } else {
                        orderSubscriptionMap.get(subscription.csord__Order__c).add(subscription);
                    }
                }
            }
        }
        return orderSubscriptionMap;
    }
    //EDGE-130011 >> Start
    private Map<Id,Map<String,List<csord__Subscription__c>>> getOrderSubscriptionConfigMapping(List<csord__Subscription__c> subscriptions){
        Map<Id,Map<String,List<csord__Subscription__c>>> orderSubscriptionConfigMap = new Map<Id,Map<String,List<csord__Subscription__c>>>();
        for(csord__Subscription__c subscription :  subscriptions){
                if(subscription.csordtelcoa__Product_Configuration__r != NULL && String.isNotBlank(subscription.ConfigSpecID__c)){
                if(orderSubscriptionConfigMap.get(subscription.csord__Order__c) == NULL){
                    Map<String,List<csord__Subscription__c>> configSubsriptionMap = new Map<String,List<csord__Subscription__c>>();
                    configSubsriptionMap.put(subscription.ConfigSpecID__c, new List<csord__Subscription__c>{subscription});
                    orderSubscriptionConfigMap.put(subscription.csord__Order__c, configSubsriptionMap);
                } else if(orderSubscriptionConfigMap.get(subscription.csord__Order__c).get(subscription.ConfigSpecID__c) == NUll){
                    orderSubscriptionConfigMap.get(subscription.csord__Order__c).put(subscription.ConfigSpecID__c, new List<csord__Subscription__c>{subscription});
                } else {
                    orderSubscriptionConfigMap.get(subscription.csord__Order__c).get(subscription.ConfigSpecID__c).add(subscription);
                }
            }
        }
        return getOrderEnrichmentSubscription(subscriptions,orderSubscriptionConfigMap);
    }
    private Map<Id,Map<String,List<csord__Subscription__c>>> getOrderEnrichmentSubscription(List<csord__Subscription__c> subscriptions,Map<Id,Map<String,List<csord__Subscription__c>>> orderSubscriptionConfigMap){
        List<String> fileList= new  List<String>();
        //Retrieve the File Names (Non Commerical File name for PS) from FCR_Settings__c Custom settings 
        for(FCR_Settings__c fcr:FCR_Settings__c.getAll().values()){
        fileList.add(fcr.File_Name__c);
        }
        Map<Id,csord__Subscription__c> ProductConfigIDMap = new Map<Id,csord__Subscription__c>();
        Map<id,csord__Subscription__c> enrichmentSubscriptionMap = new Map<id,csord__Subscription__c>();
        for(csord__Subscription__c subscription :  subscriptions){
            ProductConfigIDMap.put(subscription.csordtelcoa__Product_Configuration__c,subscription);
        }
        //Parse Json File and Create subScriptionFLIMap with Subscription id and Product Configuration Id
        for(attachment attloop:[SELECT Id,name,body,ParentId FROM Attachment WHERE ParentId IN:ProductConfigIDMap.keySet() AND name IN:fileList]){
            String strbody = attloop.body.tostring();
            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(strbody);
            List<Object> reqAttrList = (List<Object>) request.get('configurations'); 
            for (Object simpleAttr : reqAttrList) {
                Map<String, Object> smpObj = (Map<String, Object>) simpleAttr;
                if(!String.isBlank((string)smpObj.get('Network')))
                enrichmentSubscriptionMap.put((string)smpObj.get('Network'),ProductConfigIDMap.get(attloop.ParentId));
            }
        }
        for(csord__Subscription__c sub:[select Id,ConfigSpecID__c,Parent_Subscription__c FROM csord__Subscription__c WHERE id IN:enrichmentSubscriptionMap.keySet()])
        {
            csord__Subscription__c subscription = enrichmentSubscriptionMap.get(sub.id);
            if(subscription.csordtelcoa__Product_Configuration__r != NULL && String.isNotBlank(sub.ConfigSpecID__c)){
                if(orderSubscriptionConfigMap.get(subscription.csord__Order__c) == NULL){
                    Map<String,List<csord__Subscription__c>> configSubsriptionMap = new Map<String,List<csord__Subscription__c>>();
                    configSubsriptionMap.put(sub.ConfigSpecID__c, new List<csord__Subscription__c>{sub});
                    orderSubscriptionConfigMap.put(subscription.csord__Order__c, configSubsriptionMap);
                } else if(orderSubscriptionConfigMap.get(subscription.csord__Order__c).get(sub.ConfigSpecID__c) == NUll){
                    orderSubscriptionConfigMap.get(subscription.csord__Order__c).put(sub.ConfigSpecID__c, new List<csord__Subscription__c>{sub});
                } else {
                    orderSubscriptionConfigMap.get(subscription.csord__Order__c).get(sub.ConfigSpecID__c).add(sub);
                }
            }
        }
        return orderSubscriptionConfigMap;
    }
    //EDGE-130011 << End
    // Create case and fulfillment Record
    //private void createFulfillmentLineItem(Map<Id,List<csord__Subscription__c>> orderSubscriptionMap){
    private void createFulfillmentLineItem(Map<Id,List<csord__Subscription__c>> orderSubscriptionMap, Map<Id,Map<String,List<csord__Subscription__c>>> orderSubscriptionConfigMap){
        //Get record type for Fulfillment.
        Id caseFulfillmentRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();
        //Retrieve the All the Offer Mapping for PS from FCR_Settings__c Custom settings 
        Map<String, FCR_Settings__c >  offerMapping= FCR_Settings__c.getAll();
        Id fcrPortalAdminRecordTypeID =  Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Admin').getRecordTypeId();
        //List<Functional_Contact_Role__c> functionalContactRoleList = new List<Functional_Contact_Role__c>();
        //Get the Attributes selected part of Enrichment for Operations User
        map<id,map<string,map<string,string>>> enrichmentAttributeValuesMap = getOrderEnrichmentAttributeValues(orderSubscriptionMap, new list<string>{'Operations User_schema.json'},new list<string>{'Operational User','OfferName'});
        system.debug('enrichmentAttributeValuesMap'+enrichmentAttributeValuesMap);
        //Get Offers from the Attribute map         
        set<string> OffersInBasket= getOfferswithOpsUser(enrichmentAttributeValuesMap);
        system.debug('OffersInBasket'+OffersInBasket);
        Map<Id, user> userContactMap=getOperationalUserContact(enrichmentAttributeValuesMap);
        for(Id orderId : orderSubscriptionMap.keySet()){
            //Create one case record for each order.
            Case fulfillmentRecord = new Case(RecordTypeId = caseFulfillmentRecordTypeId);
            //Create fulfillment record for each service
            for(csord__Subscription__c subscription : orderSubscriptionMap.get(orderId)) {
                map<String,String> Attributevalues= new map<String,String>();
                if(enrichmentAttributeValuesMap.ContainsKey(subscription.csordtelcoa__Product_Configuration__c)){
                    Attributevalues=EnrichmentAttributeValuesMap.get(subscription.csordtelcoa__Product_Configuration__c).get('Operations User_schema.json');
                }
                fulfillmentRecord.Subject = subscription.csord__Order__r.csord__Order_Number__c;//Subject of the Order is order number.
                //EDGE-124063 Assign Operational user selected as part of Enrichment as Owner of Case
                if(OffersInBasket.contains('Telstra Collaboration Professional Services') && subscription.Name=='Telstra Collaboration Professional Services'){
                    fulfillmentRecord.OwnerId = Attributevalues.get('Operational User');
                } else if(OffersInBasket.contains('T-MDM Professional Services')){
                    fulfillmentRecord.OwnerId = Attributevalues.get('Operational User');
                } else {
                    fulfillmentRecord.OwnerId = subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;//owner of case is opportunity owner
                }
                fulfillmentRecord.OpportunityId__c = subscription.csord__Order__r.csordtelcoa__Opportunity__c;
                fulfillmentRecord.AccountId = subscription.csord__Account__c;
                FulfillmentLineItem__c fulfillmentLineItem = new FulfillmentLineItem__c();
                fulfillmentLineItem.Name = subscription.Name;
                fulfillmentLineItem.Account__c=subscription.csord__Account__c;//EDGE-117829
                //fulfillmentLineItem.OwnerId = subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                //EDGE-124063 Assign Operational user selected as part of Enrichment as Owner of FLI
                fulfillmentLineItem.OwnerId = (Attributevalues.ContainsKey('Operational User')) ?
                                              Attributevalues.get('Operational User') :  subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                fulfillmentLineItem.Offer_Name__c = subscription.MarketableOffer__r.Name;// Offer Name for fulfillment Line item
                fulfillmentLineItem.subscription__c = subscription.Id;//link to the subscription
                fulfillmentLineItem.Assigned_Date__c=System.today(); //EDGE-132349
                // EDGE-130011 >> Start- Telstra Collaboration - DMCAT_Offer_000936 :: Network Service ID : DMCAT_ProductSpecification_000871
                if(offerMapping.containsKey(subscription.ConfigSpecID__c)){
                    List<csord__Subscription__c> ngVoiceSubscriptionId = orderSubscriptionConfigMap.get(orderId).get(offerMapping.get(subscription.ConfigSpecID__c).Product_Configuration_code__c);
                    if(ngVoiceSubscriptionId != null){
                        // EDGE-137134 >> Start
                        set<Id> newSetid = new set<Id>();
                        List<Id> newListid = new List<Id>();
                        for(csord__Subscription__c subs : ngVoiceSubscriptionId){
                            newSetid.add(subs.Parent_Subscription__c != null ? subs.Parent_Subscription__c:subs.id);
                            newListid.add(subs.id);
                        }
                        // EDGE-137134 >> End
                        
                        for(Id ngvsubscription : newSetid){
                            String Ownerid=Attributevalues.ContainsKey('Operational User')?Attributevalues.get('Operational User'):subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                            String ContactId=Attributevalues.ContainsKey('Operational User')?UserContactMap.get(Attributevalues.get('Operational User')).Contactid:subscription.csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId;
                            Functional_Contact_Role__c fcr = new Functional_Contact_Role__c(Role__c = offerMapping.get(subscription.ConfigSpecID__c).Role_Name__c,
                                    Role_Type__c = 'Subscription',
                                    RecordTypeId = fcrPortalAdminRecordTypeID,
                                    SubscriptionID__c=ngvsubscription,
                                    Partner_User__c=Ownerid,
                                    ContactID__c=ContactId
                            );
                            sObjectUOW.registerNew(fcr,Functional_Contact_Role__c.Fulfillment_Task__c,fulfillmentLineItem);
                        }
            String subList = String.join(newListid, ',');     // EDGE-137134 >> +
                        fulfillmentLineItem.FCR_Subscriptions__c=subList; // EDGE-137134 >> +
                    }
                }
                sObjectUOW.registerNew(fulfillmentLineItem,FulfillmentLineItem__c.case__c,fulfillmentRecord);
            }
            sObjectUOW.registerNew(fulfillmentRecord);
        }
    }


    /********************
    Name:getOrderProductConfigs
    Description: Method to get the the Product Configuraton Ids from the Order and Subscription map
    ************************/
    private  List<id>  getOrderProductConfigs(Map<Id,List<csord__Subscription__c>> orderSubscriptionMap){
        List<id> ProductConfigIds= new list<id>();
        for(Id orderId : orderSubscriptionMap.keySet()){
            for(csord__Subscription__c subscription:orderSubscriptionMap.get(orderId)){
                ProductConfigIds.add(subscription.csordtelcoa__Product_Configuration__c);
            }
        }
        return ProductConfigIds;
    }
    /********************
    Name:getOffers
    Description: Method to read the offers from the Attribute Map derived from JSON files tagged to Product COnfiguration
    ************************/
    private  set<String>  getOfferswithOpsUser(map<Id,map<string,map<string,string>>> enrichmentAttributeValuesMap){
        set<String> OffersInBasket= new Set<String>();
        for(String str:enrichmentAttributeValuesMap.KeySet()){
            map<string,string> AttrMap=enrichmentAttributeValuesMap.get(str).get('Operations User_schema.json');
            if(AttrMap.ContainsKey('OfferName'))
                OffersInBasket.add(AttrMap.get('OfferName'));
        }
        return OffersInBasket;
    }
    /********************
    Name:getOperationalUserContact
    Description: Method to get the user details from the Attribute Map derived from JSON files tagged to Product COnfiguration
    ************************/
    private  map<id,user>  getOperationalUserContact(map<Id,map<string,map<string,string>>> enrichmentAttributeValuesMap){
        set<String> Userids= new Set<String>();
        for(String str:enrichmentAttributeValuesMap.KeySet()){
            map<string,string> AttrMap=enrichmentAttributeValuesMap.get(str).get('Operations User_schema.json');
            if(AttrMap.ContainsKey('Operational User'))
                Userids.add(AttrMap.get('Operational User'));
        }
        Map<Id, user> userMap = new Map<Id, user>([select id,contactid from user where id in :Userids]);
        return userMap;
    }

    /***************************
    Name:getOrderEnrichmentAttributeValues
    Description: Method to read the values provided part of enrichment from Product Configuration based on Subscription.
    **************************/
    private  map<id,map<string,map<string,string>>> getOrderEnrichmentAttributeValues(Map<Id,List<csord__Subscription__c>> orderSubscriptionMap,List<String> NonCommercialSChemastoRead,list<string> AttributestoLoad){
        //Map of Product configuration and Attribute values to be read from the JSON file 

        map<id,map<string,map<string,string>>> pcmap= new map<id,map<string,map<string,string>>>();
        //try{
            String NonCommConfig=NonCommercialSChemastoRead+'_schema.json';
            //Get the Product Configs to Query the Attachments
            List<id> ProductConfigIds=getOrderProductConfigs(orderSubscriptionMap);
            for(attachment attloop:[SELECT Id,name,body,ParentId FROM Attachment WHERE ParentId IN:ProductConfigIds and Name in :NonCommercialSChemastoRead])
                {
                    map<String,map<String,String>> pcatributeMap= new map<String,map<String,String>>();
                    system.debug('attloop'+attloop);
                    String strbody = attloop.body.tostring();
                    Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(strbody);
                    List<Object> reqAttrList = (List<Object>) request.get('configurations');
                    map<string,string> attributeMap= new map<string,string>();
                    for (Object simpleAttr : reqAttrList) {
                        Map<String, Object> smpObj = (Map<String, Object>) simpleAttr;
                        for(string Attribute:AttributestoLoad ){
                            if(!String.isBlank((string)smpObj.get(Attribute)))
                                attributeMap.put(Attribute,(string)smpObj.get(Attribute));
                        }
                    }

                    pcatributeMap.put(attloop.Name,attributeMap);
                    pcmap.put(attloop.ParentId,pcatributeMap);
                    system.debug('pcatributeMap'+pcatributeMap);
                }
            system.debug('pcmap'+pcmap);
       /* }
        catch(exception e)
        {
            System.debug('e:'+e.getMessage()+' :'+e.getLineNumber());
        }*/
        return pcmap;
    }
    private void processManagedServicesOffers(List<csord__Subscription__c> subscriptions){ //EDGE-135488
       system.debug('subscriptions&' +subscriptions);
        for(csord__Subscription__c subscription :subscriptions){
            if(subscription.MarketableOffer__r.Type__c == 'Managed Service') {
                subscription.csord__Status__c = 'Provisioned';
                if(subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent'){
                    subscription.triggerBill_RTB__c = true;
                }
                
                sObjectUOW.registerDirty(subscription);
        
            //}
            for (csord__Service__c svc : subscription.csord__Services__r) {
                svc.csord__Status__c = 'Connected';
                sObjectUOW.registerDirty(svc);
            }
            }
      
  }
    }
    
  
    /**************************************  
    Name:  processAdaptiveCare
    Description: Update Trigger RTB for Individual Subscription for Adaptive Care 
  Stor: DPG-1914
  Author: Ila
    /******************************************/

     public void processAdaptiveCare(List<csord__Subscription__c> subscriptions){
         Boolean triggerRtbFlag = false;
         Set<Id> billAcc=new Set<Id>();
        
            
                 for(csord__Subscription__c subscription :subscriptions){
                     if(subscription.MarketableOffer__r.Offer_ID__c== 'DMCAT_Offer_001251'){
                    billAcc.add(subscription.Billing_Account__c);
                
                     } 
                 }

     system.debug('billAcc++' +billAcc);
     List<csord__Subscription__c> subsWithSameBillAcc=[Select Id, Billing_Account__c,triggerBill_RTB__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,toBeCancelled__c,MarketableOffer__c, MarketableOffer__r.Offer_ID__c from csord__Subscription__c where Billing_Account__c IN :billAcc and MarketableOffer__r.Offer_ID__c=: 'DMCAT_Offer_001251'];
    
         system.debug('subsWithSameBillAcc' +subsWithSameBillAcc);   
                
                for(csord__Subscription__c sub :subsWithSameBillAcc){
       triggerRtbFlag = ( sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent' && sub.triggerBill_RTB__c==true) ? true : false;
      system.debug('sub.triggerBill_RTB__c' +sub.triggerBill_RTB__c);
     }
     
             system.debug('inside triggerRtbFlaginside' +triggerRtbFlag);
     
     for(csord__Subscription__c subsc: subsWithSameBillAcc){
      
         if(subsc.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' && triggerRtbFlag==true){
           system.debug('inside ifff');
                   subsc.triggerBill_RTB__c=true;
         }
     
     }
         update subsWithSameBillAcc;
            
     }
         
         
    /**************************************  
    Name:  updateRTSAdaptive
    Description: Update RTS for individual subscription for Adaptive care
  Stor: DPG-1914
  Author: Ila
    /******************************************/
     public void updateRTSAdaptive(List<csord__Subscription__c> subscriptions){ 
        system.debug('subscriptions**' +subscriptions);
        for(csord__Subscription__c subscription :subscriptions){
            system.debug('configgg&&&' +subscription);
            system.debug('configgg' +subscription.MarketableOffer__r.Config__c);
             if(subscription.MarketableOffer__r != NULL && String.isNotBlank(subscription.MarketableOffer__r.Config__c)){

            Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
            
                system.debug('inside updateRTSAdaptive'+basketConfiguration);
            //Update Trigger RTS for Individual Subscription for Adaptive Care 
                if(subscription.toBeCancelled__c=='true' && subscription.MarketableOffer__r.Type__c == 'Managed Service' && subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' && basketConfiguration.get('SOMOpenAir') != NULL && (Boolean)basketConfiguration.get('SOMOpenAir'))  
                {
                    system.debug('inside if of updateRTSAdaptive');
                    subscription.Trigger_RTS__c=true;
                }
               
          }
        }
         
     }
    
/**************************************  
Name:  updateTenancyId
Description: Update Tenancy Id for MS & PS with TMDM 
Stor: DPG-2579
Author: Ila
/******************************************/    
    @InvocableMethod
    public static void updateTenancyId(List<String> param) {
        
        system.debug('param**' +param);
        /*
        List<String> parameter = param[0].split(':::');
             String ordId;
       		String tenancyId;
            
        if(parameter != null){
                ordId = parameter[0];
            	
            if(parameter[1]!='false'){
                tenancyId = parameter[1];
            }
           }
      
      Boolean triggerRtbFlag = false;
        Boolean individualFlag =false;
        Set<Id> listOfSolution = new Set<Id>();
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        Set<Id> msSet = new Set<Id>();
		List<csord__Subscription__c> managedSub= new List<csord__Subscription__c>();
        
        if(ordId!=null){
        subList=[Select id,csord__Status__c,MarketableOffer__r.Offer_ID__c,TenancyID__c from csord__Subscription__c where csord__Order__c=:ordId and MarketableOffer__r.Offer_ID__c != 'DMCAT_Offer_000681'];
        
            system.debug('subList' +subList);
        if(!subList.isEmpty()){
        
        for(csord__Subscription__c subs: subList){
			
			 if(subs.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000854'){ //MS
                system.debug('subs.MarketableOffer__r.Offer_ID__c**' +subs.MarketableOffer__r.Offer_ID__c);
                msSet.add(subs.Id);
            }
                   triggerRtbFlag = ( subs.csord__Status__c=='Active' && subs.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000750') ? true : false;
            
            if(subs.MarketableOffer__r.Offer_ID__c!=null && subs.TenancyID__c==null && tenancyId!=null  &&(subs.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000750'|| subs.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000854')) {
               system.debug('subs.MarketableOffer__r.Offer_ID__c' +subs.MarketableOffer__r.Offer_ID__c);
                subs.TenancyID__c=tenancyId;
                system.debug('subs.TenancyID__c' +subs.TenancyID__c);
            }
		}
		update subList;
		
		 system.debug('msSet' +msSet);
            
		
		
		if(msSet!=null && triggerRtbFlag==true){
			managedSub=[Select Id,csord__Status__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,triggerBill_RTB__c from csord__Subscription__c where Id IN:msSet];
			
            
               for(csord__Subscription__c sub: managedSub){
                    
                    if(sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent'){
               system.debug('sub.csord__Status__c' +sub.csord__Status__c);
                sub.csord__Status__c = 'Provisioned';
                sub.triggerBill_RTB__c=true;
                    individualFlag=true;
            }
              
		}
		update managedSub;
         
                for(csord__Subscription__c subscr: managedSub){
                    if(individualFlag == true && subscr.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent'){
                        subscr.csord__Status__c = 'Provisioned';
                		subscr.triggerBill_RTB__c=true;
                    
                }
            }
            
		}
            
    update managedSub;
        
        }
          
        }*/
    }
    
/**************************************  
Name:  FlowInputs
Description: Get OrderId and TenancyID from ProcessBuilder 
Stor: DPG-2579
Author: Ila
/******************************************/ 
    /*   public class FlowInputs{
    
        @InvocableVariable
        public String orderId;
        
        @InvocableVariable
        public String tenancyId;
          
       
        
    }*/
  
}