/*
===============================================================================================================================
Class : SubscriptionDetailsResponse  
Developer Name :
Test Class : GetSubscriptionHelperTest
===============================================================================================================================
Sr.No.  Developer  Date          Story Description
1.      Pradeep   02/May/2018    EDGE-66609 - Added new fields in DTO - MSISDN,CIDN,billingAccountNumber,
mobileServiceindicator,serviceStatus 
2.     Vaibhav    19/11/2019     EDGE-98384 added suspensionReason
3.     Dheeraj    08-June-2020   EDGE-149915 -Modify GetSubscriptionDetails API to support duplicate number/subscription records
4.     Dheeraj    04-Aug-2020    EDGE-162161  -Enhance Get Subscription API by exposing old device id for replacement device subscription to support device replacement orders
5.     Dheeraj    25-Aug-2020    EDGE-165567/EDGE-168274 -Enhance Inv MS - Get Subscription API to provide scenario type for new/cancel orders and Commercial orders
6.     Venkat T   17-Feb-2021    EDGE-200008-Notify Inventory Microservice on the Nickname changes and provide nickname details
7.     Sayantan   05-Aug-2021    EDGE-10299 - Added tonBarringStatus
===================================================================================================================================================================================
*/

public class SubscriptionDetailsResponse {
    
    public DataDTO data {get;set;}
    
    public class DataDTO{
        public String subscriptionId {get;set;}
        public String subscriptionNumber {get;set;}
        public String correlationID {get;set;}
        public String name {get;set;}
        public String status {get;set;}
        public String customerID {get;set;}
        public String MSISDN {get;set;}
        public String CIDN {get;set;}
        public String mobileServiceIndicator {get;set;}//EDGE-149912-Dheeraj Bhatt
        public String billingAccountNumber {get;set;}
        public String adborID {get;set;}
        public String orderSubmissionDate {get;set;}
        public String orderCreationDate {get;set;}
        public String offerId {get;set;}
        public String contractTerm {get;set;}
        public String serviceabilityLocation {get;set;}
        public String contractStartDate {get;set;}
        public String subscriptionVersion{get;set;}
        public String modelChange{get;set;}
        public String subscriptionCode {get;set;}
        public String transactionID {get;set;}
        public String transactionTime {get;set;}
        public String suspensionContext {get;set;}
        public String solutionSubscriptionNumber {get;set;} //EDGE-99311
        public String suspensionReason {get;set;}//EDGE-98384
        public String suspensionReasonSummary {get;set;}//DPG-4574
        public String offerName;//EDGE-149912-Dheeraj Bhatt-Modify existing GetSubscriptionDetails API to include "Parent subscription name".
        public String nickName {get;set;} //EDGE-200008
        public String tonBarringStatus{get;set;}//EDGE-10299Addding tonBarringStatus
        public List<assetList> asset;//EDGE-162161
        public List<ServiceList> services {get;set;}
        public List<error> error{get;set;}
        
    }
  //  EDGE-162161
    public class assetList{
        public String name;
        public String value;
    }
    public class ServiceList{
        public String serviceId {get;set;}
        public String scenarioType;
        public String serviceNumber {get;set;}
        public String serviceVersion {get;set;}
        public String serviceName {get;set;}
        public String serviceStatus {get;set;}
        public String code {get;set;} //DIGI-24735/Gururaj Shetty
        public String modelChange {get;set;}
        public List<ServiceSpecifications> specifications {get;set;}
        
    }
    public class ServiceSpecifications{
        
        public String version;
        public String status;
        public String modelChange;
        public String startDate;
        public String specExternalID;
        public String serviceId;
        public String productConfigurationId;
        public String name;
        public String guid;
        public String endDate;
        public String description;
        public String code;
        public List<Attributes> attributes;
        
    }
    
    public class Attributes {
        public Object value;
        public String name;
    }
    
    public class error{
        public String status {get;set;}
        public String code {get;set;}
        public String message {get;set;}
        public String correlationID {get;set;}
    }
    
}