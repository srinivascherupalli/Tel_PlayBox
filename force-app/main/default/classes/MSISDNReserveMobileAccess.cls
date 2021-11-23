/**************************************************************************
 Name: MSISDNReserveMobileAccess
 Description: 1)Class will fetch all orders of input services and invoke OrderStatusHandler.changeOrderStatus to change the order status.
                 2)Updates the page layout and invoke MSISDN Orchestration creation process for IP Site with Mobile Site technology primary orders
 ***************************************************************************/

public with sharing class MSISDNReserveMobileAccess {
    
    public static void MSISDNReserve(List<Id> serviceIds){

//fetching all primary orderids of input serviceids
List<csord__order__c>  allOrderList = [select id from csord__order__c where csord__Order_Request__c IN (select csord__Order_Request__c from csord__service__c where id IN: serviceIds) and csord__Primary_Order__c = null];
Set<csord__order__c> allOrderIds = new Set<csord__order__c>();
allOrderIds.addAll(allOrderList);

system.debug('all primary orders'+ allOrderIds);

// fetching  primary orderids of IP Site with Mobile Access from input serviceids
List<csord__order__c> msisdnOrderlist=[select id from csord__order__c where csord__Order_Request__c IN (select csord__Order_Request__c from csord__service__c where id IN: serviceIds and TechnologyType__c= 'Mobile Access') and csord__Primary_Order__c = null];
Set<csord__order__c> msisdnOrderIds = new Set<csord__order__c>();
msisdnOrderIds.addAll(msisdnOrderlist);

system.debug('primary orderids of IP Site'+ msisdnOrderIds);

// removing primary order of IP Site with Mobile Access(msisdnOrderIds) from all allOrderIds set(allOrderIds). 
allOrderIds.removeAll(msisdnOrderIds);

system.debug('Only Primary oders'+ allOrderIds);

//converting to list type and changing the record type for msisdnOrderIds orders and invoking MSISDNOrchestrationProcess . 

List<csord__order__c> msisdnIds =  new List<csord__order__c>();
msisdnIds.addAll(msisdnOrderIds);

system.debug('list type msisdnOrderIds'+ msisdnIds);

if (!msisdnIds.isEmpty())
{
List<RecordType> orderRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c' and name='MSISDN Required' limit 1];
for(csord__Order__c primOrder : msisdnIds)
{
primOrder.csord__Status2__c=orderRecordTypeList[0].Name;
primOrder.RecordTypeId = orderRecordTypeList[0].Id;
}
update msisdnIds;
}
 // fetching  secondary orderids of IP Site with Mobile Access from input serviceids
List<csord__order__c> msisdnsecondaryord=[select id from csord__order__c where csord__Order_Request__c IN (select csord__Order_Request__c from csord__service__c where id IN: serviceIds and TechnologyType__c= 'Mobile Access') and csord__Primary_Order__c != null];   
List<Id> secOrderIdmsisdn = new List<Id>();
for (csord__order__c sl: msisdnsecondaryord)
{
secOrderIdmsisdn.add(sl.id); 
} 
  
if (!secOrderIdmsisdn.isEmpty())
{
system.debug('secondary orders msisdn'+ secOrderIdmsisdn);
OrderStatusHandler.changeSecOrderStatus(secOrderIdmsisdn);
}  
         
List<String> allmsisdnOrderlist = new List<String>();
for (csord__order__c sl: msisdnIds) 
{
allmsisdnOrderlist.add(sl.id);  
}
system.debug('list type allmsisdnOrderlist'+ allmsisdnOrderlist);
ManageMSISDNOrchestrationHandler.createMSISDNOrchestrationProcess(allmsisdnOrderlist);  
         
 //invoking changeOrderStatus for all the orders other than IP Site primary orders
 
if (!allOrderIds.isEmpty())
{
List<Id> allOrderIdlist = new List<Id>();
for (csord__order__c sl: allOrderIds)
{
allOrderIdlist.add(sl.id); 
} 
OrderStatusHandler.changeOrderStatus(allOrderIdlist);
system.debug('list type all orders'+ allOrderIdlist);
}  
}
}