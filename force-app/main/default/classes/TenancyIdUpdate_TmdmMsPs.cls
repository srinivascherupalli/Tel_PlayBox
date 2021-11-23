/*
*******************************************************************************
Class : TenancyIdUpdate_TmdmMsPs
Developer Name : Ila Anmol Verma
Test Class : TenancyIdUpdate_TmdmMsPsTest
Description: Update Subscription,Service Status and Trigger RTB for MS for TMDM/MS/PS and update Tenancy Id for MS and PS
Date : 10/8/2020
Story: DPG-2579
***************************
Updated on: 23/08/2021
Story DPG:-14803
Updated By: Akshay G 
********************************************************************************
*/
public class TenancyIdUpdate_TmdmMsPs {

    public static final String ManagedService_MarketableOffer = 'DMCAT_Offer_000854';
    public static final String ProfessionalService_MarketableOffer = 'DMCAT_Offer_000750';
    public static final String TMDM_MarketableOffer = 'DMCAT_Offer_000681';
    public static final String FULFILMENT  = 'FULFILMENT';
/**************************************  
Name:  updateTenancyId
Description: Update Tenancy Id for MS & PS with TMDM invoked from Cancel Subscription Process builder
Story: DPG-2579
Author: Ila
/******************************************/    
   @InvocableMethod
   public static void updateTenancyId(List<String> param) {
       system.debug('param***' +param);
       String ordId;
       String tenancyId;
        List<Id> newListid = new List<Id>();
        Map<Id, List<id>> oePCSubscriptionIDMap = new Map<Id, List<id>>();
       List<FulfillmentLineItem__c> FulfilmetToInsert = new List<FulfillmentLineItem__c>();
       List<Id> professionalServicesPCList = new List<Id>();
        List<String> PCConfigId= new list<String>();
       Map<id,Map<String,String>> calloutResults;
       
       if(param.isEmpty())  {
           return;
       }  
       
       List<String> parameter = param[0].split(':::');
            
       if(parameter[0]== null){
           return;
       }
       
       ordId = parameter[0];
               
           if(parameter[1]!='false'){
               tenancyId = parameter[1];
           }
         
         system.debug('tenancyId**&' +tenancyId);
     Boolean triggerRtbFlag = false;
       Boolean individualFlag =false;
       Boolean createTaskFlag=false; //DPG-4967Fix2
       List<csord__Subscription__c> subscriptionIds = new List<csord__Subscription__c>();
       List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
       Set<Id> msSet = new Set<Id>();
       List<csord__Subscription__c> managedSub= new List<csord__Subscription__c>();
       List<csord__Service__c> subServList = new List<csord__Service__c>();
       List<csord__Service__c> indivSubServList = new List<csord__Service__c>();
       List<id> oeSubscriptionIDList = new List<id>();
       List<csord__Subscription__c> professionalServicesSubsList = new List<csord__Subscription__c>();
       Set<Id> newSetid = new Set<Id>();
       Set<Id> PsPcId = new Set<Id>();
       List<csord__Subscription__c> tmdmSubs = new List<csord__Subscription__c>();

       
       if(ordId!=null){
       
          tmdmSubs=[Select Id from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' and MarketableOffer__r.Offer_ID__c =: TMDM_MarketableOffer and csord__Order__c=:ordId];
    subList=[Select id,Name,csord__Status__c,csord__Account__c ,csord__Order__r.csord__Order_Number__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,MarketableOffer__r.Offer_ID__c,(SELECT Id,csord__Status__c from csord__Services__r),TenancyID__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Name  from csord__Subscription__c where csord__Order__c=:ordId and MarketableOffer__r.Offer_ID__c !=: TMDM_MarketableOffer];           
           system.debug('subList' +subList);
       if(subList.isEmpty())
       {
           return;
       }
       
       for(csord__Subscription__c subs: subList){
      
           
            if(subs.MarketableOffer__r.Offer_ID__c == ManagedService_MarketableOffer){ //Check for MS
               system.debug('MS marketable offer**' +subs.MarketableOffer__r.Offer_ID__c);
               msSet.add(subs.Id);
           }
                  
           if(subs.MarketableOffer__r.Offer_ID__c == ProfessionalService_MarketableOffer){
               PsPcId.add(subs.csordtelcoa__Product_Configuration__c);
               professionalServicesSubsList.add(subs);
              //DPG-4567 If Individual PS subscription is Active mark MS services as connected
               if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' && subs.csord__Status__c.equalsIgnoreCase('Active')){
                   system.debug('inside triggerRtbFlag');
               triggerRtbFlag=true;
               }
           }
    
           if(subs.MarketableOffer__r.Offer_ID__c!=null && subs.TenancyID__c==null && tenancyId!=null  &&(subs.MarketableOffer__r.Offer_ID__c == ManagedService_MarketableOffer|| subs.MarketableOffer__r.Offer_ID__c == ProfessionalService_MarketableOffer)) {
              system.debug('subs.MarketableOffer__r.Offer_ID__c' +subs.MarketableOffer__r.Offer_ID__c);
               subs.TenancyID__c=tenancyId;
               // Added if-else loop as a part of DPG-14803
               if(PsPcId.isEmpty()){
                triggerRtbFlag=true;      
               }else{
                createTaskFlag=true; //DPG-4967Fix2
               }

               system.debug('subs.TenancyID__c' +subs.TenancyID__c);
           }
           
       }
       update subList;

       if(tenancyId!=null && createTaskFlag==true){
                // Create FLI :DPG-3624
       
List<cscfga__Attribute__c> attrPS = [Select Id, Name,cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c IN:PsPcId and Name='Operational User' and cscfga__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'];
//DPG-4967Fix2
List<FulfillmentLineItem__c> taskList = [select id from FulfillmentLineItem__c where subscription__c IN: professionalServicesSubsList];
if(taskList.isEmpty()){
       for(csord__Subscription__c subscr: professionalServicesSubsList){
   
                 FulfillmentLineItem__c fulfillmentLineItem = new FulfillmentLineItem__c();
                 fulfillmentLineItem.Name = subscr.Name;
                 fulfillmentLineItem.Account__c = subscr.csord__Account__c;
                   if(!attrPS.isEmpty() && attrPS[0].cscfga__Value__c!=null){
                                    fulfillmentLineItem.OwnerId= attrPS[0].cscfga__Value__c;
                                   }else
                                       fulfillmentLineItem.OwnerId = subscr.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                         fulfillmentLineItem.Offer_Name__c = subscr.MarketableOffer__r.Name; // Offer Name for fulfillment Line item
                                   fulfillmentLineItem.subscription__c = subscr.Id; //link to the subscription
                                   fulfillmentLineItem.Assigned_Date__c = System.today();
                                   if(!tmdmSubs.isEmpty()){
                                   fulfillmentLineItem.FCR_Subscriptions__c = tmdmSubs[0].Id;
                                        }
                                   FulfilmetToInsert.add(fulfillmentLineItem);
           
       }
       
       insert FulfilmetToInsert;   
}            
       // List of Services
       List<csord__Service__c> srvcList = [SELECT Id,Name,csord__Order__c,csord__Service__c,toBeCancelled__c,csord__Subscription__r.eventId__c,Action_Type__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Service__c WHERE csord__Subscription__c IN :subList and  csord__Subscription__r.MarketableOffer__r.Offer_ID__c =: ManagedService_MarketableOffer];
       system.debug('srvcList*+' +srvcList);
       
        Map<Id,Attachment> servAttachmentRecordMap = new Map<Id,Attachment>();
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
        Map<String,String> addAttrMap = NULL;
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
         Map<String,String> tenancyAddAttrMap = new Map<String,String>();
        List<Id> allServiceId = new List<id>();
 Map<Id,String> serIdTenancyMap = new Map<Id,String>();
         
        for(csord__Service__c svc: srvcList){
              
               allServiceId.add(svc.id);
        }
       system.debug('allServiceId*' +allServiceId);
       for(Attachment att: [Select id,body,parentId from Attachment where parentId in :allServiceId]){
               servAttachmentRecordMap.put(att.parentId,att);
               serviceAttachmentMap.put(att.parentId,att.body.toString());}
               
               system.debug('servAttachmentRecordMap++' +servAttachmentRecordMap);
           system.debug('serviceAttachmentMap++' +serviceAttachmentMap);
             for(csord__Service__c serv : srvcList){
                  if(serviceAttachmentMap.get(serv.Id)!=null){
               List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(serv.Id)),'SOMOpenAir');
              system.debug('srvspecList::'+srvspecList);
                  
           for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
               
               addAttrMap = new Map<String,String>();
               for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.SimpleAttributes){
                   addAttrMap.put(attr.name,attr.value);
                   if(addAttrMap.containsKey('TenancyID')){
                   tenancyAddAttrMap.put('TenancyID',tenancyId);
                   serIdTenancyMap.put(serv.id,srvSpec.guid);
                   }
                   }
             
           } 
             }
             }
             system.debug('serIdTenancyMap::'+serIdTenancyMap);   
             if(!serIdTenancyMap.isEmpty()){
           for(Id ser :serIdTenancyMap.keySet()){
               system.debug('3rd' + tenancyAddAttrMap);
           String attach =csedm.API_1.addCharacteristic(serviceAttachmentMap.get(ser),ser, serIdTenancyMap.get(ser), tenancyAddAttrMap);
           system.debug('attach::'+attach);
           Attachment attAdd = servAttachmentRecordMap.get(ser);
               system.debug('Get service IId' +servAttachmentRecordMap.get(ser));
           attAdd.body = Blob.valueOf(attach);
           serviceAttachmentMap.put(attAdd.parentId,attAdd.Body.toString());
           updatedAttSet.put(attAdd.id,attAdd);
           
           system.debug('serAttachmentMap1::'+serviceAttachmentMap);
          
       }
             }
       system.debug('updatedAttSet::'+updatedAttSet);
       if(!updatedAttSet.isEmpty()){
           update updatedAttSet.values();
       }
            
            }
            
            
       if(msSet!=null && triggerRtbFlag==true){
           
           managedSub=[Select Id,csord__Status__c,(SELECT Id,csord__Status__c from csord__Services__r),csordtelcoa__Product_Configuration__r.ConfigurationType1__c,triggerBill_RTB__c from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' AND Id IN:msSet];
           
           system.debug('managedSub++' +managedSub);
             //DPG-4567 Commenting , below code will be handled via orchestration class
              /*for(csord__Subscription__c sub: managedSub){
                   if(sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent'){
           system.debug('inside subs sol');
                     if((!sub.csord__Status__c.equalsIgnoreCase('Active')) && (!sub.csord__Status__c.equalsIgnoreCase('Provisioned')) && (!sub.csord__Status__c.equalsIgnoreCase('Bill Readiness In Progress')))
           {
             system.debug('inside provisioned');
                           sub.csord__Status__c = 'Provisioned';
             
           }
           if(sub.csord__Status__c.equalsIgnoreCase('Provisioned'))
           {
                           system.debug('inside RTB');
             sub.triggerBill_RTB__c=true;
              
           }
                       subscriptionIds.add(sub);
            if(sub.csord__Services__r!=null)
           subServList.add(sub.csord__Services__r);   
                       system.debug('subServList+' +subServList);
           
         }
       
       }*/
       /*
       if(!subscriptionIds.isEmpty())
       {
           
           update subscriptionIds;
           individualFlag=true;
       }
       
           if(!subServList.isEmpty()){
       for(csord__Service__c serv: subServList)
       {
           if(serv.csord__Status__c != 'Connected')
           serv.csord__Status__c = 'Connected';
       }   
   
               update subServList;
           }*/
               for(csord__Subscription__c subscr: managedSub){
         //if(individualFlag == true && subscr.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' ){
          /* if((!subscr.csord__Status__c.equalsIgnoreCase('Active')) && (!subscr.csord__Status__c.equalsIgnoreCase('Provisioned')) && (!subscr.csord__Status__c.equalsIgnoreCase('Bill Readiness In Progress'))){
             system.debug('inside indiv subs prov');
                           subscr.csord__Status__c = 'Provisioned';
           }
           if(subscr.csord__Status__c.equalsIgnoreCase('Provisioned')){
                           system.debug('innside rtb indiv sub');
             subscr.triggerBill_RTB__c=true;
           }
           */
         
          if(subscr.csord__Services__r!=null)
           indivSubServList.add(subscr.csord__Services__r);
                 
           
         }
            system.debug('indivSubServList+' +indivSubServList);
           // update managedSub;
      
           if(!indivSubServList.isEmpty()){
            
            for(csord__Service__c service: indivSubServList)
       {
           if(service.csord__Status__c != 'Connected')
           service.csord__Status__c = 'Connected';
           
       }  
               update indivSubServList;
           }
           
       }
        
       }
   }


}