/* 
Author : Vimal Verma 
Company : Telstra
Description : EDGE-1145 - Manage Order interface structure component 
History : Initail Version Mon Oct 16 09:56:44 2017 
*/
public with sharing class AppointmentServiceHelper {
    public static Map<String,Task__c>  getAppointmentsDetails(list<Id> subIds){
        Map<String, Task__c> taskAppointmentMap = new Map<String, Task__c>();
        
        List<Task__c> taskList= [Select TaskId__c, jobid__c, Appointment__c, Appointment__r.Category__c, Appointment__r.Notes__c,Appointment__r.SlotId__c, Appointment__r.EndDate__c, Appointment__r.StartDate__c, Appointment__r.Subscription__c, Appointment__r.Product_Configuration__c, Appointment__r.StartDateText__c, Appointment__r.EndDateText__c  from Task__c where Appointment__r.Subscription__c IN: subIds];
        for(Task__c tasks :taskList){
            taskAppointmentMap.put(tasks.TaskId__c, tasks);
        }
        
        return taskAppointmentMap;
    }
    
Public static Map<Id, csord__Service__c> getServiceData(list<Id> serviceIds){
       //commented to add new field in query toBeCancelled__c  for US EDGE-32377
     //  Map<Id, csord__Service__c> serviceList = new Map<Id, csord__Service__c>([Select Id, Not_Before_CRD__c, Preferred_CRD__c, Notes__c from csord__Service__c where Id IN: serviceIds]);
    // added for 65707 :: 19.4 :: 14/3/2019 :: added one variable :- csordtelcoa__Replaced_Service__c
    // added for 80750: Scenario Type, Incumbent Number, Customer Authorization Date, CA Expiry Date
    //Start

    Map<Id, csord__Service__c> serviceList = new Map<Id, csord__Service__c>([Select Id,recoveryMethod__c,returnReasonType__c,
                                                devicecareCaseId__c,TNowCaseId__c,csord__Service__c,
                                                csordtelcoa__Product_Configuration__c,TenancyPrimaryContact__c,
                                                TenancyPrimaryContact__r.firstName,TenancyPrimaryContact__r.lastName,
                                                TenancyPrimaryContact__r.MobilePhone,TenancyPrimaryContact__r.Phone,
                                                TenancyPrimaryContact__r.Email, Not_Before_CRD__c, Cust_Req_Disconn_Date__c,
                                                Preferred_CRD__c, Notes__c , toBeCancelled__c ,Delivery_Address__c,
                                                Delivery_Address__r.Address_ID__c,csordtelcoa__Service_Number__c, 
								Primary_Contact__r.firstName,Primary_Contact__r.lastName,Primary_Contact__r.Email,
								Primary_Contact__r.MobilePhone,Primary_Contact__r.Title,
								csordtelcoa__Replaced_Service__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, 
								csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c, 
								Scenario_Type__c, Incumbent_Account_Number__c,Replaced_Device_Id__c,
                                                 Customer_Authorised_date__c, CA_Expiry_Date__c from csord__Service__c where Id IN: serviceIds]);
    System.debug('serviceList==>'+serviceList);
    //End 
       
    return serviceList;
    
    }
}