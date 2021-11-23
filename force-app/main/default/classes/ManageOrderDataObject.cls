public with sharing class ManageOrderDataObject{

       public class ProductOrder {
            @AuraEnabled
            public Integer version    {get;set;}
            @AuraEnabled
            public String  systemId   {get;set;}
            @AuraEnabled
            public String  externalId {get;set;}
            @AuraEnabled
            public String  requestedCompletionDate {get;set;}
            @AuraEnabled
            public String  marketType {get;set;}
            @AuraEnabled
            public String  orderReasonCode {get;set;}
            @AuraEnabled
            public String  orderSpecificationCode {get;set;}
            @AuraEnabled
            public List<CharacteristicDataObject> orderCharacteristic {get;set;}
            @AuraEnabled
            public List<RelatedPartyDataObject> relatedParty    {get;set;}
            @AuraEnabled
            public List<OrderRelationShipDataObject> orderRelationship{get;set;}
            @AuraEnabled
            public List<OrderItemDataObject> orderItem  {get;set;}
          }
      
       public class CharacteristicDataObject{
            @AuraEnabled
            public String value {get;set;}
            @AuraEnabled
            public String name {get;set;}
            
         }
     
     
        public class OrderRelationShipDataObject{
        
        
       }
       
         public class RelatedPartyDataObject{
            @AuraEnabled
            public String id  {get;set;}
            @AuraEnabled
            public String name{get;set;}
            @AuraEnabled
            public String type{get;set;}
            @AuraEnabled
            public String role{get;set;}
            @AuraEnabled
            public String hRef{get;set;}
         }
     
          public class OrderItemDataObject{
           @AuraEnabled
           public String  id      {get;set;}
           @AuraEnabled
           public Integer version {get;set;}
           @AuraEnabled
           public String  requestedCompletionDate {get;set;}
           @AuraEnabled
           public String  action  {get;set;}
           @AuraEnabled
           public List<BillingAccountDataObject> billingAccount {get;set;}
           @AuraEnabled
           public AppointmentDataObject appointment {get;set;}
           @AuraEnabled
           public List<CharacteristicDataObject> orderItemCharacteristic {get;set;}
           @AuraEnabled
           public ProductDataObject product{get;set;}
         }
     
        public class BillingAccountDataObject{
           @AuraEnabled
           public String id   {get;set;}
           @AuraEnabled
           public String name {get;set;}
           @AuraEnabled
           public String href {get;set;}
           @AuraEnabled
           public String accountType {get;set;}
         }
     
         
         public class AppointmentDataObject {
           @AuraEnabled
           public String id   {get;set;}
           @AuraEnabled
           public String href {get;set;}
           @AuraEnabled
           public String category  {get;set;}
           @AuraEnabled
           public String startDate {get;set;}
           @AuraEnabled
           public String endDate   {get;set;}
           @AuraEnabled
           public String notes   {get;set;}
          }
      
            
          public class ProductDataObject{
            @AuraEnabled
            public String id     {get;set;}
            @AuraEnabled
            public String action {get;set;}
            @AuraEnabled
            public ProductSpecificationDataObject productSpecification{get;set;}
            @AuraEnabled
            public List<CharacteristicDataObject> productCharacteristic {get;set;}
            @AuraEnabled
            public List<ProductRelationshipDataObject>   productRelationship    {get;set;}
            @AuraEnabled
            public List<PlaceDataObject> place {get;set;}
            
         }
     
         
             
        public class ProductRelationshipDataObject{
             @AuraEnabled
             public String type     {get;set;}
             //@AuraEnabled
             //public String code     {get;set;}
             @AuraEnabled
             public ProductDataObject product {get;set;}
            
           }
      
          public class ProductSpecificationDataObject{
           @AuraEnabled
           public String code {get;set;}
          }
          
          public class PlaceDataObject{
           @AuraEnabled
           public String role {get;set;}
           @AuraEnabled
           public AddressDataObject address {get;set;}
           @AuraEnabled
           public List<ContactDataObject> contact {get;set;}
         }
         
          public class AddressDataObject{
            @AuraEnabled
            public String id     {get;set;}
            @AuraEnabled
            public String href   {get;set;}
            @AuraEnabled
            public String type   {get;set;}
            @AuraEnabled
            public String street1{get;set;}
            @AuraEnabled
            public String street2{get;set;}
            @AuraEnabled
            public String city   {get;set;}
            @AuraEnabled
            public String stateOrProvince {get;set;}
            @AuraEnabled
            public String postCode {get;set;}
            @AuraEnabled
            public String country  {get;set;}
            @AuraEnabled
            public String room     {get;set;}
            @AuraEnabled
            public String apartment{get;set;}
            @AuraEnabled
            public String floor    {get;set;}
            @AuraEnabled
            public String buildingName {get;set;}
            @AuraEnabled
            public String streetType {get;set;}
            @AuraEnabled
            public String streetName {get;set;}
            @AuraEnabled
            public String streetNr   {get;set;}
            @AuraEnabled
            public String streetSuffix{get;set;}
            @AuraEnabled
            public String locality   {get;set;}
            @AuraEnabled
            public String town       {get;set;}
            @AuraEnabled
            public String county     {get;set;}
            @AuraEnabled
            public GeocodeDataObject geocode {get;set;}
          
          }
          
          public class GeocodeDataObject{
            @AuraEnabled
            public String latitude {get;set;}
            @AuraEnabled
            public String longitude{get;set;}
           
          }
      
          public class ContactDataObject{
           @AuraEnabled
           public String id     {get;set;}
           @AuraEnabled
           public String name   {get;set;}
           @AuraEnabled
           public String gender {get;set;}
           @AuraEnabled
           public String givenName {get;set;}
           @AuraEnabled
           public String familyName {get;set;}
           @AuraEnabled
           public String middleName {get;set;}
           @AuraEnabled
           public String title {get;set;}
           @AuraEnabled
           public String type   {get;set;}
           @AuraEnabled
           Public List<ContactMediumDataObject> contactMedium {get;set;}
         
         }
         
         public class ContactMediumDataObject{
          @AuraEnabled
          public String type   {get;set;}
          @AuraEnabled
          public MediumDataObject medium {get;set;}
         
         }
         
         public class MediumDataObject{
         // Number is reserved word
          @AuraEnabled
          public String number1 {get;set;}
          @AuraEnabled
          public String emailAddress  {get;set;}
         
         }

}