/********************************************************************************
* Class Name  : OrderConstants
* Description : Class to hold the static Constant values for all Order related objects 
* Created By  : Sudheendra
********************************************************************************/
public class C2O_OrderConstants {

    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');
	
    public static final String ACTIVE = 'Active';
    public static final String PAID_OUT = 'Paid Out';
    public static final String INACTIVE = 'Inactive';
    public static final String SUSPENDED = 'Suspended';
    public static final String CLOSED = 'Closed';
    public static final String CONNECTED = 'Connected';
    public static final String PROVISIONING = 'Provisioning In Progress';
    public static final String DISCONNECTED = 'Disconnected';
    public static final String BEINGFULFILLED = 'Being Fulfilled';
    
    public static final string STATUS_PROVISIONED = 'Provisioned';
    public static final string STATUS_BILL_READINESS_IN_PROGRESS = 'Bill Readiness In Progress';
    public static final string STATUS_BILLING_COMPLETE = 'Billing Complete';
    public static final string STATUS_ACTIVE = 'Active';
    public static final string STATUS_INACTIVE = 'Inactive';
    public static final string STATUS_FAILED = 'Failed';
    public static final string STATUS_SUSPENDED = 'Suspended';
    public static final string STATUS_PARTIAL_ACTIVE = 'Partial Active';
    public static final string STATUS_PROVISIONING_IN_PROGRESS = 'Provisioning In Progress';
    public static final string STATUS_CLOSED_REPLACED = 'Closed Replaced';
    public static final string STATUS_MIGRATION = 'Migration';
    public static final string DELAY_NOTIFICATION = 'Delay Notification';
    public static final string STAGE_BEING_FULFILLED = 'Being Fulfilled';
    public static final string STAGE_OREDR_RECEIVED = 'Order Received';
    public static final string EDGE_PARTNERS_NETWORKID = customMetadataNameValueMap.containsKey('EDGE_Partners_Network_Id')?String.valueOf(customMetadataNameValueMap.get('EDGE_Partners_Network_Id').get('Value__c')):'';
    public static final string PROFILE_NAME_ASA = 'Assurance Service Agent';
    public static final string PROFILE_NAME_SEU = 'Sales-Enterprise-Unified';
    public static final string PROFILE_NAME_SEB = 'Service Enterprise – B2B';
    public static final string PROFILE_NAME_PCU_AUSTRALIA = 'PRM Community User - Australia';
    public static final string PROFILE_NAME_PRM_ADMIN_AUSTRALIA = 'PRM Admin - Australia';
    public static final string SEPERATOR = ':::';
    public static final string CREATE_OPERATION = 'C';
    public static final string UPDATE_OPERATION = 'U';
    public static final string FALSE_STRING ='false';
    public static final string DMCAT_OFFER_000681 = 'DMCAT_Offer_000681';
    public static final string DMCAT_OFFER_000750 = 'DMCAT_Offer_000750';
    public static final string STATUS_FULFILLED = 'Fulfilled';    
    public static final string OPP_TYPE_MIGRATION = 'Migration';
    public static final string STATUS_COMPLETED = 'Completed';
    public static final string STATUS_IN_PROGRESS = 'In Progress';
    public static final string STATUS_COMPLETE = 'Complete';
    public static final string STATUS_READY_FOR_SUBMIT = 'Ready For Submit';
    public static final string STATUS_OREDR_FAILED = 'Order Decomposition Failed';
    public static final string STAGE_READY_FOR_USE= 'Ready For Use';
	public static final string STAGE_AMEND_PENDING = 'Amend Pending';
    public static final string STAGE_AMEND_REJECTED = 'Amend Rejected';
    public static final string STAGE_CANCELLATION_PENDING = 'Cancellation Pending';
    public static final string STAGE_CANCELLATION_IN_PROGRESS = 'Cancellation In Progress';
    public static final string STAGE_CANCELLED = 'Cancelled';
    public static final string STAGE_PENDING = 'Pending';
    
}