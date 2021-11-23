public class OpptyConstants {

    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');
    //STRING 
    public static final String PARTNER_USERTYPE = 'PowerPartner';
    public static final String IN_CONTRACT_YES = 'Yes';
    public static final String EDIT = 'Edit';
    public static final String ContactStatus_INACTIVE = 'Inactive';
    public static final String PARTNER_CONTACT = 'Partner_Contact';
    public static final String BUYER = 'Buyer';
    public static final String ACCOUNT_ACTIVE = 'Active';
    public static final String ACCOUNT_NON_MODULAR = 'Non Modular';
    public static final String CHANNEL_INDIRECT = 'Indirect';
    public static final String BUSINESS_PLUS = 'Business Plus';
    public static final String APPROVED = 'Approved';
    public static final String SUBMITTED = 'Submitted';
    public static final String REJECTED = 'Rejected';
    public static final String RECALLED = 'Recalled';
    public static final String APPROVAL_PROCESS_NAME = 'Submit_to_Partner';
    public static final String ACC_MANAGER = 'Account Manager';
    public static final String SALES_REP = 'Sales Rep';
    public static final String PARTNER = 'Partner';
    public static final String NOMINATE = 'Nominate';
    public static final String DISTRIBUTOR = 'Distributor';
    public static final String ONBOARDING_ACTIVE = 'Active';
    public static final String PARTNER_SM = 'Partner Sales Manager';
    public static final String PERMISSSION_SET_PCS =  customMetadataNameValueMap.containsKey('Partner_Community_User')?String.valueOf(customMetadataNameValueMap.get('Partner_Community_User').get('Value__c')):'';
    public static final String QUEUE_USER_WITHOUT_CHATTER_PERM = customMetadataNameValueMap.containsKey('Users_not_to_Assign_Chatter_Capability')?String.valueOf(customMetadataNameValueMap.get('Users_not_to_Assign_Chatter_Capability').get('Value__c')):'';
    public static final string EDGE_PARTNERS_NETWORK_ID = customMetadataNameValueMap.containsKey('EDGE_Partners_Network_Id')?String.valueOf(customMetadataNameValueMap.get('EDGE_Partners_Network_Id').get('Value__c')):'';
    public static final string POWERPARTNER = 'PowerPartner';
    public static final string CAMPAIGN = 'Campaign';
    public static final String CHANGE_SOLUTION = 'Change Solution';
    public static final String PARTNER_MULTITIER_APPROVAL_PROCESS = 'PRM_Submit_to_Partner_Multitier';
    public static final String SUBMIT_TO_PARTNER_PROCESS = 'Submit_to_Partner';
    public static final String PRM_Chatter_Request_to_Close_Opportunity = customMetadataNameValueMap.containsKey('PRM_Chatter_Request_to_Close_Opportunity')?String.valueOf(customMetadataNameValueMap.get('PRM_Chatter_Request_to_Close_Opportunity').get('Value__c')):'';
    public static final String PRM_Chatter_Opportunity_Closure_Approved = customMetadataNameValueMap.containsKey('PRM_Chatter_Opportunity_Closure_Approved')?String.valueOf(customMetadataNameValueMap.get('PRM_Chatter_Opportunity_Closure_Approved').get('Value__c')):'';
    public static final String PRM_Chatter_Opportunity_Closure_Rejected = customMetadataNameValueMap.containsKey('PRM_Chatter_Opportunity_Closure_Rejected')?String.valueOf(customMetadataNameValueMap.get('PRM_Chatter_Opportunity_Closure_Rejected').get('Value__c')):'';
    public static final String PRM_Chatter_SLA_breached_notification = customMetadataNameValueMap.containsKey('PRM_Chatter_SLA_breached_notification')?String.valueOf(customMetadataNameValueMap.get('PRM_Chatter_SLA_breached_notification').get('Value__c')):'';
    public static final String TBTC_Partner_Admin = customMetadataNameValueMap.containsKey('TBTC_Partner_Admin')?String.valueOf(customMetadataNameValueMap.get('TBTC_Partner_Admin').get('Value__c')):'';
    public static final String TBTC_Partner_User = customMetadataNameValueMap.containsKey('TBTC_Partner_User')?String.valueOf(customMetadataNameValueMap.get('TBTC_Partner_User').get('Value__c')):'';
    public static final String PRM_ENV_URL = customMetadataNameValueMap.containsKey('PRM_ENV_URL')?String.valueOf(customMetadataNameValueMap.get('PRM_ENV_URL').get('Value__c')):'';
    public static final String PRM_Chatter_Pending_Opportunity_Approval = customMetadataNameValueMap.containsKey('PRM_Chatter_Pending_Opportunity_Approval')?String.valueOf(customMetadataNameValueMap.get('PRM_Chatter_Pending_Opportunity_Approval').get('Value__c')):'';
    public static final String TBTCProfile1 = customMetadataNameValueMap.containsKey('TBTCProfile1')?String.valueOf(customMetadataNameValueMap.get('TBTCProfile1').get('Value__c')):'';
    public static final String TBTCProfile2 = customMetadataNameValueMap.containsKey('TBTCProfile2')?String.valueOf(customMetadataNameValueMap.get('TBTCProfile2').get('Value__c')):'';
    public static final String TBTCProfile3 = customMetadataNameValueMap.containsKey('TBTCProfile3')?String.valueOf(customMetadataNameValueMap.get('TBTCProfile3').get('Value__c')):'';

    
    // Boolean 
    public static final Boolean isTRUE = TRUE;
    public static final Boolean isFALSE = FALSE;
    
    // SET 
    public static final Set<String> SET_SUBMITSTATUS = new Set<String> {'Rejected','Recalled'};
        
}