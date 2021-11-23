/*
===============================================================================================================================
Class : ManageOrderAcknowledgeHandler
Developer Name :
Test Class : ManageOrderAcknowledgeHandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
  1.        Shubhi Vijayvergia  21/3/2018     Edge-53883 Order Submission for Sim Replacement for Assurance service agen Profile  
  2.       Prajakta Patil       17/03/2020    EDGE-115932
  3.       Prajakta/Pawan       27/07/2020    EDGE-163608
  4.       Vaibhav Deshpande    01/12/2020    EDGE-170550
===============================================================================================================================
*/
public with sharing class ManageOrderAcknowledgeHandler {


    /*
    *    The params will be a list of order Ids that needs to be sent to fulfilment application
    *    To do - see if order request ids can be passed to reduce SOQL and simplify the logic
    */
    public static void processAcknowledgements(Map<Id, String> orderStatus) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> failedOrderIds = new Set<Id>();
        
        /* *******************************************************8
        /*for(Id orderId: new List<Id>(orderStatus.keySet())){
            orderIds.add(orderId);
        }fetch all the order request ids, required for all order related including secondary orders/delivery orders
        List<csord__Order__c> primaryorders = [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c,csord__Account__c FROM csord__Order__c WHERE Id IN : orderIds and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)];Sr1. added csord__Account__c for sim repplcement*/ 
        
        //List<csord__Order__c> primaryorders = [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c,csord__Account__c FROM csord__Order__c WHERE Id IN : orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)]; //Sr1. added csord__Account__c for sim repplcement
        
        /*List<Id> orderRequestsIds = new List<Id>();
        for(csord__Order__c primaryord: [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c,csord__Account__c FROM csord__Order__c WHERE Id IN : orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)]){
            orderRequestsIds.add(primaryord.Id);//Sr1. added csord__Account__c for sim repplcement
            if(orderStatus.get(primaryord.Id) != 'Success')
                failedOrderIds.add(primaryord.csordtelcoa__Opportunity__c);
        } */ //Sr1. added csord__Account__c for sim repplcement
        
        /* ********************************************************************************* */
        
        //query all the orders and update the stasuses
        List<csord__Order__c> orders = [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Id IN :orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)]; //Sr1. modified for sim replacement order
         List<csord__Order__c> ordersToUpdate = new  List<csord__Order__c>();
System.debug('orders recieved::::'+orders);
        if(!orders.isEmpty()){
            for(csord__Order__c ord: [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Id IN :orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)])
            {                  
                System.debug('the Ord :::::'+ord);
                //if(!failedOrderIds.contains(ord.csordtelcoa__Opportunity__c)){
                if(orderStatus.get(ord.Id) != 'Success'){ //sr1. for sim repplcement
                    System.debug('ord.csord__Order_Type__c:::'+ord.csord__Order_Type__c);
                    if(ord.csord__Order_Type__c.contains('Amend')){
                        ord.Fulfilment_Order_Version__c = ord.Fulfilment_Order_Version__c + 1;
                    }
                    ord.csord__Status2__c = 'In Error';

                } else{
                    ord.csord__Status2__c = 'In Progress';
                }
                System.debug('ord:::'+ord);
        ordersToUpdate.add(ord);
            }
            System.debug('orders:::'+ordersToUpdate);
            try{
                update ordersToUpdate;
            }
            catch(Exception e){
                system.debug('Exception'+e);
            }
        }
    }
    
    //added as EDGE-115932
     public static void processAcknowledgementsMSUpdate(List<csord__Order__c> orderList,Map<Id, String> ordStatusMap,Map<Id,Boolean> ordIdisSuspendResume) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> failedOrderIds = new Set<Id>();
        
        /* *******************************************************8
        /*for(Id orderId: new List<Id>(orderStatus.keySet())){
            orderIds.add(orderId);
        }fetch all the order request ids, required for all order related including secondary orders/delivery orders
        List<csord__Order__c> primaryorders = [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c,csord__Account__c FROM csord__Order__c WHERE Id IN : orderIds and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)];Sr1. added csord__Account__c for sim repplcement*/ 
        
        //List<csord__Order__c> primaryorders = [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c,csord__Account__c FROM csord__Order__c WHERE Id IN : orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)]; //Sr1. added csord__Account__c for sim repplcement
        
        /*List<Id> orderRequestsIds = new List<Id>();
        for(csord__Order__c primaryord: [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c,csord__Account__c FROM csord__Order__c WHERE Id IN : orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)]){
            orderRequestsIds.add(primaryord.Id);//Sr1. added csord__Account__c for sim repplcement
            if(orderStatus.get(primaryord.Id) != 'Success')
                failedOrderIds.add(primaryord.csordtelcoa__Opportunity__c);
        } */ //Sr1. added csord__Account__c for sim repplcement
        
        /* ********************************************************************************* */
        
        //query all the orders and update the stasuses
       // List<csord__Order__c> orders = [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Id IN :orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)]; //Sr1. modified for sim replacement order
         List<csord__Order__c> ordersToUpdate = new  List<csord__Order__c>();
            //System.debug('orders recieved::::'+orders);
          //  for(csord__Order__c ord: [SELECT Id, Name, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Id IN :orderStatus.keyset() and (csordtelcoa__Opportunity__c != null OR csord__Account__c!=null)])
           // for(csord__Order__c ord :orderList)
             for(csord__Order__c ord :[SELECT id,Name, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate,csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c FROM csord__Order__c where Id IN :orderList])
            { //SOQl added as part of EDGE-170550
        
                if(!ordIdisSuspendResume.get(ord.id) && ord.csord__Status2__c != 'Completed'){  //EDGE-163608 :Added ord.csord__Status2__c != 'Completed' - Pawan
                if(ord!= null){
                System.debug('the Ord :::::'+ord);
                //if(!failedOrderIds.contains(ord.csordtelcoa__Opportunity__c)){
                if(ordStatusMap.get(ord.Id) != 'Success'){ //sr1. for sim repplcement
                    System.debug('ord.csord__Order_Type__c:::'+ord.csord__Order_Type__c);
                    if(ord.csord__Order_Type__c.contains('Amend')){
                        ord.Fulfilment_Order_Version__c = ord.Fulfilment_Order_Version__c + 1;
                    }
                    ord.csord__Status2__c = 'In Error';
                }

                else if(ord.csord__Status2__c != 'Amend Rejected'){ //check added as part of EDGE-170550

                    ord.csord__Status2__c = 'In Progress';
                }
                System.debug('ord:::'+ord);
                ordersToUpdate.add(ord);}
                
                }
            }
            System.debug('orders:::'+ordersToUpdate);
            try{
                if(!ordersToUpdate.isEmpty()){
                update ordersToUpdate;}
            }
            catch(Exception e){
                system.debug('Exception'+e);
            }    
    } 
    // End EDGE-115932
    
}