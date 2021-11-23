public with sharing class AppointmentReserveRequestDTO {
    public Data data{get;set;}
    public class Data {
        @AuraEnabled
        public List<Contacts> contacts;
        @AuraEnabled
        public Customer customer;
        //@AuraEnabled
        //public TicketDetails ticketDetails;
        //@AuraEnabled
        //public OrderDetails orderDetails;
        @AuraEnabled
        public String notes;
        //@AuraEnabled
        //public List<TaskItems> taskItems;
    }

    public class Contacts{
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String phoneNumber {get; set;}
        @AuraEnabled
        public String role {get; set;}
    }
    public class Customer{
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String customerclass {get; set;}
    }

    /*public class TicketDetails{
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String serviceLevelAgreement {get; set;}
        @AuraEnabled
        public String impact {get; set;}
        @AuraEnabled
        public String serviceIdentifier {get; set;}
        @AuraEnabled
        public Boolean isSilentLine {get; set;}
        @AuraEnabled
        public String customerRequiredDate {get; set;}
        @AuraEnabled
        public String obligatoryCompletionDate {get; set;}
        @AuraEnabled
        public String notes {get; set;}
        @AuraEnabled
        public Faultdetails faultdetails;
    }
    public class Faultdetails{
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public List<codes> codes;
    }
    public class Codes{
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String value {get; set;}
    }

    public class OrderDetails{
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String type {get; set;}
    }
    public class TaskItems{
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String notes {get; set;}
        @AuraEnabled
        public List<ProductCharacteristics> productCharacteristics;
        @AuraEnabled
        public List<JobItems> jobItems;
    }
    
    public class JobItems{
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String notes {get; set;}
        @AuraEnabled
        public List<ProductCharacteristics> productCharacteristics;
    }

    public class ProductCharacteristics{
        @AuraEnabled
        public String lineItemNumber {get; set;}
        @AuraEnabled
        public String serviceLevel {get; set;}
        @AuraEnabled
        public String serviceIdentifier {get; set;}
        @AuraEnabled
        public String productOfferName {get; set;}
        @AuraEnabled
        public String productOfferId {get; set;}
        public List<Characterstics> characterstics;
    }

    public class Characterstics{
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String action {get; set;}
    }*/

    
    public static AppointmentReserveRequestDTO.Data parse(String json) {
        return (AppointmentReserveRequestDTO.Data) System.JSON.deserialize(json, AppointmentReserveRequestDTO.Data.class);
    }

}