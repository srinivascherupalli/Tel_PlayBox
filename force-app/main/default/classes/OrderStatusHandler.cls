/*********************************************************************************************************************************
*Class Name      :   OrderStatusHandler
 Test class       : OrderStatusHelperTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vaibhav Deshpande       23/12/2019     EDGE-127367 DML and SOQL inside FOR loop
*********************************************************************************************************************************
*/

public with sharing class OrderStatusHandler
{
    public static void changeOrderStatus( List<Id> orderIDList )
    {
        if(orderIDList!=null && orderIDList.size()>0){
            Map<String,Id> recordTypeMap = new Map<String,Id>();
            List<RecordType> orderRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
            //push all the record types of order into the map with their Id
            for(RecordType recObj:orderRecordTypeList)
            {
                 recordTypeMap.put(recObj.Name,recObj.Id);           
            }
            
            //initiate all the lists and sets
            //List to perform DML operation
            //Set to use remove() method using direct elements. List remove() method needs index to remove a particular element which costs extra soqls
            
            List<csord__Service__c> parentServiceList = new List<csord__Service__c>();
            List<csord__Service__c> apptReqdParentServiceList = new List<csord__Service__c>();
            List<csord__Service__c> apptNotReqdParentServiceList = new List<csord__Service__c>();
            Set<csord__Order__c> secondaryOrderSet = new Set<csord__Order__c>();
            List<csord__Order__c> secondaryOrderList = new List<csord__Order__c>();
            Set<csord__Order__c> apptReqdPrimaryOrderSet = new Set<csord__Order__c>();
            Set<csord__Order__c> apptNotReqdPrimaryOrderSet = new Set<csord__Order__c>();
            List<csord__Order__c> apptReqdPrimaryOrderList = new List<csord__Order__c>();
            List<csord__Order__c> apptNotReqdPrimaryOrderList = new List<csord__Order__c>();
            
            Set<Id> inputOrderRequestList = new Set<Id>();
            for(csord__Order__c ord : [select id,csord__Order_Request__c from csord__Order__c where id in : orderIDList]){
                inputOrderRequestList.add(ord.csord__Order_Request__c);
            }
            //fetch all parentServices using the input serviceIdList
            parentServiceList = [select id,Name,Appointment_Required__c,csord__Order__c,csord__Order_Request__c from csord__Service__c where csord__Service__c = null and csord__Order_Request__c in : inputOrderRequestList];
            //fetch all appointment required root level services
            apptReqdParentServiceList = [select id,Name,Appointment_Required__c,csord__Order__c,csord__Order_Request__c from csord__Service__c where id in :parentServiceList and Appointment_Required__c = 'true'];
            //fetch all appointment not required root level services
            apptNotReqdParentServiceList = [select id,Name,Appointment_Required__c,csord__Order__c,csord__Order_Request__c from csord__Service__c where id in :parentServiceList and Appointment_Required__c = 'false'];
            
            //iterate over all root level services
            List<Id> ordList=new List<Id>(); //EDGE-127367 - created list of Id's to store order Id's
            for(csord__Service__c serv : parentServiceList){
               ordList.add(serv.csord__Order__c);
               /* Commenting code as part of EDGE-127367
                 //iterate over secondary orders using root level service iterator
                for(csord__Order__c secOrder : [select id, csord__Primary_Order__c FROM csord__Order__c WHERE id =: serv.csord__Order__c]){
                    secondaryOrderSet.add(secOrder);
                }*/
            }
             //EDGE-127367 : taken Soql query outside for loop, resolved as per sonar findings
            //iterate over secondary orders using root level service iterator
            if(!ordList.isEmpty()){
               for(csord__Order__c secOrder : [select id, csord__Primary_Order__c FROM csord__Order__c WHERE id IN :ordList]){
                    secondaryOrderSet.add(secOrder);
                }
            }
            
            //set order status and record type of all secondary orders
            for(csord__Order__c secOrder : secondaryOrderSet){
                System.debug('*****Traversing SecondaryOrderList');
                secOrder.csord__Status2__c='';
                secOrder.RecordTypeId=recordTypeMap.get('Secondary Order');
            }
            if(!secondaryOrderSet.isEmpty()){
                secondaryOrderList.addAll(secondaryOrderSet);
                update secondaryOrderList;
            }
            
            //iterate over appointment required Parent Services
            List<Id> ordReqList=new List<Id>();//EDGE-127367 - created list of Id's to store order request Id's
            for(csord__Service__c serv : apptReqdParentServiceList){
                ordReqList.add(serv.csord__Order_Request__c);
               /* Commenting code as part of EDGE-127367
                 //iterate over primary order for this service using order request object
                for(csord__Order__c primOrder : [select id, csord__Primary_Order__c,csord__Status2__c,RecordTypeId FROM csord__Order__c WHERE csord__Order_Request__c =: serv.csord__Order_Request__c and csord__Primary_Order__c = null]){
                    apptReqdPrimaryOrderSet.add(primOrder);
                }*/
            }
            //EDGE-127367 : taken Soql query outside for loop, resolved as per sonar findings 
            //iterate over primary order for this service using order request object
                if(!ordReqList.isEmpty()){
               for(csord__Order__c primOrder : [select id, csord__Primary_Order__c,csord__Status2__c,RecordTypeId FROM csord__Order__c WHERE csord__Order_Request__c IN :ordReqList and csord__Primary_Order__c = null]){
                    apptReqdPrimaryOrderSet.add(primOrder);
               }}
            
            List<Id> newOrdReqList=new List<Id>();//EDGE-127367 - created list of Id's to store order request Id's
            //iterate over appointment not required Parent Services             
            for(csord__Service__c serv : apptNotReqdParentServiceList){
                newOrdReqList.add(serv.csord__Order_Request__c);
                /* Commenting code as part of EDGE-127367
                 //iterate over primary order for this service using order request object
                for(csord__Order__c primOrder : [select id, csord__Primary_Order__c,csord__Status2__c,RecordTypeId FROM csord__Order__c WHERE csord__Order_Request__c =: serv.csord__Order_Request__c and csord__Primary_Order__c = null]){
                    apptNotReqdPrimaryOrderSet.add(primOrder);
                }*/
            }
            //EDGE-127367 : taken Soql query outside for loop, resolved as per sonar findings 
            //iterate over primary order for this service using order request object
           if(!newOrdReqList.isEmpty()){  
            for(csord__Order__c primOrder : [select id, csord__Primary_Order__c,csord__Status2__c,RecordTypeId FROM csord__Order__c WHERE csord__Order_Request__c IN :newOrdReqList and csord__Primary_Order__c = null]){
                    apptNotReqdPrimaryOrderSet.add(primOrder);
            }}
            
            //set status of Primary order to Appointment Required for New order scenario and for its parent service having appointment required flag as true
            //check if same primary order exists in Not Reqd Primary Order set, remove that element from NotReqd set
            //this has to be done when there are multiple root level services for a secondary order where only 1 parent service is appointment required 
            //and the other ones do not require appointment for eg. IP Network and UCE do not require but IP Site requires.
            for(csord__Order__c primOrder : apptReqdPrimaryOrderSet){
                if(apptNotReqdPrimaryOrderSet.contains(primOrder)){
                    apptNotReqdPrimaryOrderSet.remove(primOrder);
                }
                
                primOrder.csord__Status2__c='Appointment Required';
                primOrder.RecordTypeId = recordTypeMap.get('Appointment Required');
            }
            
            //set status of Primary order to Appointment Required for Mac order scenario when there is no addition of appointment required products/services
            for(csord__Order__c primOrder : apptNotReqdPrimaryOrderSet){
                primOrder.csord__Status2__c='Ready for Submit';
                primOrder.RecordTypeId = recordTypeMap.get('Ready for Submit');
            }
            
            //update the Primary Orders
            if(!apptReqdPrimaryOrderSet.isEmpty()){
                apptReqdPrimaryOrderList.addAll(apptReqdPrimaryOrderSet);
                update apptReqdPrimaryOrderList;
            }
            
            if(!apptNotReqdPrimaryOrderSet.isEmpty()){
                apptNotReqdPrimaryOrderList.addAll(apptNotReqdPrimaryOrderSet);
                update apptNotReqdPrimaryOrderList;
            }
        }
    
  }
  
  public static void changeSecOrderStatus( List<Id> msisdnSecOrderIDs)
  {
  
  List<csord__Order__c> msisdnSecOrderList = [select id from csord__Order__c where id IN: msisdnSecOrderIDs];
  List<RecordType> secondorderRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c' and name='Secondary Order' limit 1];
  
  system.debug('Only secondary change orders'+ msisdnSecOrderList);
  
  if (!msisdnSecOrderList.isEmpty())
  {
  for(csord__Order__c secOrder : msisdnSecOrderList){
                secOrder.csord__Status2__c='';
                secOrder.RecordTypeId=secondorderRecordType[0].Id;
  
  }
  update msisdnSecOrderList;
  }
  }
}