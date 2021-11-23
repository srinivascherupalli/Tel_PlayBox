/******************************************************************
User Story   : DIGI-30060
Description  : Wrapper class to parse response received from BDS for different subscriptions in Technical Orchestration Object
Class Name   : UpdateRemainingTermWrapper
Created By   : Team Alexandria, Divakar Tangudu
Created On   : 7 October 2021
*******************************************************************/
public class UpdateRemainingTermWrapper {

        public String eventTimeStamp;
        public List<BillingAccounts> billingAccounts;
        public class ChargesDetails {  
            public String subscriptionId;  
            public String instanceId;
            public String durationUnit;
            public Integer durationRemaining;
            public Integer chargeRemaining;
            public Integer units;
            public String taxTreatment;
            public String status;
            public String code;
            public String message;
            
            }
    
            public class BillingAccounts {
            public Long billingAccountNumber;
            public List<ChargesDetails> chargesDetails;
        }
     
        
        public static UpdateRemainingTermWrapper parse(String json) {
            return (UpdateRemainingTermWrapper) System.JSON.deserialize(json, UpdateRemainingTermWrapper.class);
        }
    }