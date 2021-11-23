public with sharing class Constants {
    public Constants() {
        
    }

    public static final Set<String> incompleteOrchestrationProcessStatuses = new Set<String> {'Initializing','In Progress','Warning','Error'};  
    public static final String orchestrationProcessActive = 'Active';
    public static final String orchestrationProcessComplete = 'Complete';
    public static final String orchestrationProcessPending = 'Pending';
    public static final String orchestrationProcess_type_Cease = 'Cease';
    
    public static final String orchestrationProcess_STATE_INACTIVE = 'INACTIVE';
    
    public static final String ADDRESS_TYPE_PRIMARY = 'Primary Address';
    public static final String DEFAULT_CONTACT_ROLE = 'Full Authority';
    
    //Record Types for Service Object
    public static final String DEVICE = 'Device';
    public static final String ACCESSORIES = 'Accessories';
    public static final String ADDITIONAL_STATIC_IP_SUBNET = 'Additional Static IP Subnet';
    public static final String TRAINING = 'Training';

    //Subscription Statuses
    public static final String subscriptionStatus_Cancel = 'Cancel';  
    public static final String subscriptionStatus_Pending = 'Pending Cancel'; 
    
    public static final String CANCEL_SUBSCRIPTION_CONFIRMATION = 'Cancel Subscription Initiated';
    
    //Product Definition Names
    public static final string PRODUCT_DEFINITION_BUSINESS_BROADBAND = 'Business Broadband';
    public static final string PRODUCT_DEFINITION_TBIZ_VOICE = 'T-Biz Voice';
    public static final string PRODUCT_DEFINITION_DIGITAL_OFFICE_TECHNOLOGY = 'Digital Office Technology'; 

    //Orchestration Process Template Names
    public static final string SUBSCRIPTION_FULFILMENT_WORKFLOW = 'Subscription Fulfilment Workflow';
    
    public static final String CREATE_EVENT = 'CREATE';
    public static final String AMEND_EVENT = 'AMEND';
    public static final String CANCEL_EVENT = 'CANCEL';
    public static final String APPLICATION = 'Cloudsense';
    public static Integer VERSION = 1;
    public static final String PR = 'PR';
    public static final String DEFAULT_AMEND = 'Default Amend';
    public static final String ROLE_CUSTOMER = 'Customer';
    public static final String PRODUCT_RELATIONSHIP_TYPE = 'contains';

    public static final String MARKET_TYPE = 'BUSINESS'; // TBC
    public static final String Subscription_Status = 'In progress';
    public static final String Service_Status = 'Pending';
    public static final String Asset_Status = 'InActive';
    public static final String Replaced_Service_Status = 'Replaced Closed';
    
    
    // Laxmi - Added for EDGE-132685 
    public static final String TIERED_RECURRING = 'Tiered Recurring';
   
    // Laxmi - Added for EDGE-127421
    public static final String MRO_BUSINESS_ID = 'DMCAT_Discount_000962' ;
    public static final String MRO_DISCOUNT_NAME = 'Postpaid MRO Plan Discount' ;
    public static final String MRO_DISCOUNT_DESC = 'Mobile Repayment Bonus provides customers with bonus credit based on the value of the device they are selecting';
	public static final String DISCOUNT_TYPE = 'Amount';
    public static final String DURATION = '24';
    public static final String DURATION_MONTHS = 'Months';

     // Laxmi - Changes End - Added for EDGE-127421
   
   /* public static final String AMEND_EVENT = 'AMEND';
    public static final String CANCEL_EVENT = 'CANCEL';*/
    
    //Gnana - Added as part of Edge-132211
    public static final string BASKET_STAGE = 'Commercial Configuration';
    
    //Gnana - Added as part of EDGE-124017
    public static final string CASE_MEDIUM_PRIORITY = 'Medium';
    public static final string CASE_NEW_STATUS = 'New';
    public static final string CASE_RELATED_TO_OPPTY = 'Opportunity';
    public static final string CASE_OTHER_CATEGORY = 'Other';
    
    //Added by Aman Soni as a part of EDGE-123575 || Start
    public static Map<String,String> getChargeAttributeNameMap(String componentName){
    Map<String,String> returnMap = new  Map<String,String>();
        if(componentName!=null){
        system.debug('componentName:::::::::::'+componentName);
            switch on componentName{
                when 'Mobile Subscription'{
                returnMap.put('DMCAT_RecurringCharge_000654','PlanShadowTCV');
                returnMap.put('DMCAT_RecurringCharge_000669','IDDShadowTCV');
                returnMap.put('DMCAT_RecurringCharge_000497','MessageBankShadowTCV');
                returnMap.put('DMCAT_RecurringCharge_000857','deviceShadowRCTCV');//Edge-135837 by shubhi
                }
            }            
        }
        return returnMap;
    }
    //Added by Aman Soni as a part of EDGE-123575 || End
    
    
     //Added by Laxmi Rahate  as a part of EDGE-132685 || Start - this method returns the charge type based on the DMCAT ID
    public static String getChargeType(String dmcatID){
    	String chargeType = '';
        Map<String,String> chargeTypeMap = new  Map<String,String>();
		{
            chargeTypeMap.put('DMCAT_RecurringCharge_000654','Flat Recurring');
            chargeTypeMap.put('DMCAT_RecurringCharge_000669','Flat Recurring');
            chargeTypeMap.put('DMCAT_RecurringCharge_000497','Flat Recurring');
            chargeTypeMap.put('DMCAT_RecurringCharge_000857','Flat Recurring');//Edge-135837 added by shubhi                  
                   
        }
        chargeType = chargeTypeMap.get (dmcatID);
        if (chargeType == null )
            {
                chargeType = '';
            }
 
        return chargeType;
    }
    //Added by Laxmi Rahate  as a part of EDGE-132685  || End
}