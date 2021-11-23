/**
 * Class for link Appointment to subscription.
 */
public with sharing class LinkAppointmentSubscription {
    
    public static void assignSubscriptionToAppointment( List<Id> serviceIds){
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<Appointment__c> AppointmentListToUpdate = new List<Appointment__c>();
        
        serviceList = [SELECT id, csord__Subscription__c, csordtelcoa__Product_Configuration__c from csord__Service__c where id IN: serviceIds];
        
        for(csord__Service__c serv: serviceList){
        	List<Appointment__c> AppointmentList = new List<Appointment__c>();
        	AppointmentList = [SELECT id, Subscription__c, Product_Configuration__c from Appointment__c where Product_Configuration__c =: serv.csordtelcoa__Product_Configuration__c];
        	for(Appointment__c appointment: AppointmentList){
        		appointment.Subscription__c = serv.csord__Subscription__c;
        	}
        	AppointmentListToUpdate.addAll(AppointmentList);
        }
        if ( !AppointmentListToUpdate.isEmpty()) {
			update AppointmentListToUpdate;
		}
    }

}