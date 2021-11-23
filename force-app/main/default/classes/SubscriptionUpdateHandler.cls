/********************************************************
Class Name :SubscriptionUpdateHandler
Test Class :SubscriptionUpdateHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.             Venkat T              04/01/2021      created( EDGE-191827 : In-Flight: Roll up PONR status to order level)
2              Venkat T               03-02-2020      EDGE-200953 Fix
3.          Vamsi Krishna Vaddipalli 17/feb/2021      EDGE-199772 Soft delete
*******************************************************************************************************************************/
public class SubscriptionUpdateHandler {
    
  public static void UpdateSubsOrderPONRFlags(Set<ID> serviceIds){ 
            
      
      //variable decleration
        // List<csord__Subscription__c> subscriptionsToUpdate = new List<csord__Subscription__c>();
         Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
         set<ID> orderIds = new Set<ID>(); 
         Map<csord__Order__c, List<csord__Subscription__c>> orderToSubMap = new Map<csord__Order__c, List<csord__Subscription__c>>(); 
         boolean cancelOrder = false;
         boolean amendOrder = false;
         //List<csord__Service__c> servicesToupdate = new List<csord__Service__c>();
           
           try{           
               for(csord__Service__c service: [Select Id, csord__Order__c,csord__Subscription__r.Point_of_No_Return_Reached__c, 
                                               csord__Subscription__r.cancel_Point_of_No_Return_Reached__c, csordtelcoa__Point_of_No_Return_Reached__c,
                                               cancel_Point_of_No_Return_Reached__c,csord__Service__c,csord__Service__r.cancel_Point_of_No_Return_Reached__c,
                                               csord__Order__r.csord__Status2__c,csord__Order__r.Fulfilment_Order_Version__c,csord__Subscription__r.orderversion__c,
                                               Action_Type__c,csordtelcoa__Cancelled_By_Change_Process__c from csord__Service__c where ID IN : serviceIds]){
                
 //SOQL by Vamsi for EDGE-199772 on 17FEB2021                                  
                                                                                                      
                                                   
                    //IF amend on any service is true then update subscription to true
                    if(service.csordtelcoa__Point_of_No_Return_Reached__c == true){
                        service.csord__Subscription__r.Point_of_No_Return_Reached__c = true;
                       // service.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c = true;
                        amendOrder = true;
                    } 
                    // when order status is Amend Rejected then updating sub's PONR amend flag to false
                    else if(service.csordtelcoa__Point_of_No_Return_Reached__c == false 
                            &&  service.csord__Order__r.csord__Status2__c == Label.AmendRejectStatus) {
                                service.csord__Subscription__r.Point_of_No_Return_Reached__c = false;
                    }
                 
                                                   
                    //IF cancel on any service is true then update subscription to true
                    if(service.cancel_Point_of_No_Return_Reached__c == true){
                        service.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c = true;
                       // service.csord__Subscription__r.Point_of_No_Return_Reached__c = true;
                        cancelOrder = true;
                    }
                    // when order status is Amend Rejected then updating sub's PONR cancel flag to false
                    else if(service.cancel_Point_of_No_Return_Reached__c == false 
                            &&  service.csord__Order__r.csord__Status2__c == Label.AmendRejectStatus) {
                                service.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c = false;
                    }
                   //subscriptionsToUpdate.add(service.csord__Subscription__r);
                   
                  //Added by Vamsi for EDGE-199772 on 17FEB2021 starts
                                                   if( service.csord__Service__c == null && String.isNOTBlank(service.Action_Type__c) && service.Action_Type__c.equalsIgnoreCase('Inflight Cancel') && service.csord__Order__r.csord__Status2__c == 'Amend Rejected')
                                                   {
                                                       if( service.csord__Order__r.Fulfilment_Order_Version__c != null && service.csord__Subscription__r.orderversion__c != null && service.csord__Order__r.Fulfilment_Order_Version__c == service.csord__Subscription__r.orderversion__c)
                                                           service.csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c = false;
                                                   }
                //Added by Vamsi for EDGE-199772 on 17FEB2021 ends
                   
                   subscriptionsToUpdate.put(service.csord__Subscription__r.Id, service.csord__Subscription__r);

                    // update all sercices to PONR reached if any service PONR reached
                    // comenting out to avoid unwanted DML disscussed with Sandeep Yelane
                    // also subscription are updated from child services records no need to update parent service records
                   /* if(amendOrder && service.csordtelcoa__Point_of_No_Return_Reached__c == false){
                        service.csordtelcoa__Point_of_No_Return_Reached__c = true;  
                        servicesToupdate.add(service);
                    }
                    else if(cancelOrder && service.cancel_Point_of_No_Return_Reached__c == false){
                        service.cancel_Point_of_No_Return_Reached__c = true;
                        servicesToupdate.add(service);
                    }*/
                                                  
                              orderIds.add(service.csord__Order__c);
                                
                                                  
                                                   
                }
               
               
             
                //if servicesupdate list has records update it
              /* if(!servicesToupdate.isEmpty()){
                    update servicesToupdate;
                } */
             
                
                //if subscriptionupdate list has records update it
                if(!subscriptionsToUpdate.isEmpty()){
                    update subscriptionsToUpdate.values();
                       
                }
               
                     
               
                // Update amend and cancel PONR statuses on order   
                if(orderIds != null){
                
                 
                    
                    List<csord__Order__c> orderList = [SELECT id,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c, 
                                                 (select id, Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c from csord__Subscriptions__r)
                                                 FROM csord__Order__c 
                                                 WHERE id IN:orderIds ];
                                                 
                    for(csord__Order__c ord : orderList){
                       orderToSubMap.put(ord, ord.csord__Subscriptions__r);                    
                    }
                    
                  
                  
                    //IF order map is not empty update orders
                  
                    if(!orderToSubMap.isEmpty() ){            
                        ManageOrderNotificationServiceMSUpdate.updateOrderRecordMS(orderToSubMap);
                        
                        
                    }              
              
                }               
                
            }
            catch(Exception ex){
                System.debug('Exception occoured '+ex);
            }
        }
}