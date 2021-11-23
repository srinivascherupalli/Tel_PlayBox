/*
*******************************************************************************
Class : SequentialSubscriptionProvisioning
Developer Name : Ila Anmol Verma
Test Class : SequentialSubscriptionProvisioningTest
Description: Update Subscription,Service Status and Trigger RTB for PS for TMDM,MS and PS
Date : 17/9/2020
Story: DPG-2578
//DIGI 19170 Akshay Gujar
********************************************************************************
*/

public with sharing class SequentialSubscriptionProvisioning {

public static final String ManagedService_MarketableOffer = 'DMCAT_Offer_000854';
public static final String ProfessionalService_MarketableOffer = 'DMCAT_Offer_000750';

/**************************************  
Name:  updateSubsForPSFulfillment
Description: Update Subscription,Service Status and Trigger RTB for PS, invoked from Fulfillment Closure Process builder
Stor: DPG-2578
Author: Ila
/******************************************/ 
    @InvocableMethod
    public static void updateSubsForPSFulfillment(List<String> param) {
        
            String orderId;
        
        if(param.isEmpty()) {
            return;
        } 
        orderId = param[0];
                   
        List<csord__Subscription__c> subsList=new List<csord__Subscription__c>();
        system.debug('orderId' +orderId);
        Boolean flag =false;
        Set<Id> psSet = new Set<Id>();
        Boolean individualFlag =false;
        List<csord__Subscription__c> subscriptionIds = new List<csord__Subscription__c>();
        List<csord__Service__c> subServList = new List<csord__Service__c>();
        List<csord__Service__c> indivSubServList = new List<csord__Service__c>();

        if(orderId!=null){
        subsList=[Select Id,MarketableOffer__r.Offer_ID__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c from csord__Subscription__c where csord__Order__c=:orderId];
        }
            system.debug('subsList' +subsList);
        if(!subsList.isEmpty()){
        for(csord__Subscription__c sub: subsList){
            
           /* if(sub.MarketableOffer__r.Offer_ID__c == ManagedService_MarketableOffer){ //Check for MS  //DIGI 19170 
                system.debug('MS MO' +sub.MarketableOffer__r.Offer_ID__c);
                flag=true;
            } */
            if(sub.MarketableOffer__r.Offer_ID__c == ProfessionalService_MarketableOffer){//Check for PS
                psSet.add(sub.id);
            }
        }
        if (psSet!=null){ //DIGI 19170 remove flag equal true
            system.debug('inside flag' +flag +'psett' +psSet);
            List<csord__Subscription__c> subscription = [Select Id, csord__Status__c,triggerBill_RTB__c,(SELECT Id,csord__Status__c from csord__Services__r),csordtelcoa__Product_Configuration__r.ConfigurationType1__c from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' AND Id IN: psSet];
          //Commented to fix DPG-4567, stop status update for solution subscription of PS
          /*  for(csord__Subscription__c subs:subscription){
                if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent'){
                    
                    if((!subs.csord__Status__c.equalsIgnoreCase('Active')) && (!subs.csord__Status__c.equalsIgnoreCase('Provisioned')) && (!subs.csord__Status__c.equalsIgnoreCase('Bill Readiness In Progress'))){
                        system.debug('inside prov');
                        subs.csord__Status__c = 'Provisioned';
                         
                    }
                    if(subs.csord__Status__c.equalsIgnoreCase('Provisioned')){
                        system.debug('inside RTB*');
                         subs.triggerBill_RTB__c=true;
                        
                    }
                    subscriptionIds.add(subs);
                     system.debug('subscriptionIds***' +subscriptionIds);
                if(subs.csord__Services__r!=null)
                subServList.add(subs.csord__Services__r); 
                system.debug('subServList+' +subServList);

                }
        
            } 
            
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
        }   */

           
               for(csord__Subscription__c subs:subscription){
                             //DPG-4567 Commenting , below code will be handled via orchestration class

                       /* if((!subs.csord__Status__c.equalsIgnoreCase('Active')) && (!subs.csord__Status__c.equalsIgnoreCase('Provisioned')) && (!subs.csord__Status__c.equalsIgnoreCase('Bill Readiness In Progress'))){
                            system.debug('inside indiv prov*');
                            subs.csord__Status__c = 'Provisioned';
                       }
                       if(subs.csord__Status__c.equalsIgnoreCase('Provisioned')){
                           system.debug('inside indivRTB*');
                           subs.triggerBill_RTB__c=true;
                       }*/
                      
                   if(subs.csord__Services__r!=null)
                indivSubServList.add(subs.csord__Services__r);
                
               }
            
           //update subscription;
            system.debug('indivSubServList' +indivSubServList);
            if(!indivSubServList.isEmpty()) //For Individual Subscription
            {
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