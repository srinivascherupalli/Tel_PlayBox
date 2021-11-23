/********************************************************************************
 EDGE       -172954
Description -To handle all the constant value in CustomButtonEnrichBasket
Author      -Gokul
1	  Akanksha		19/10/2020	   EDGE-174219- added SIMAvailabilityType
2   Pawan Singh 06/08/2020     DIGI-5648 replaced TELSTRA_COLLABORATION value to 'Adaptive Collaboration'
 ********************************************************************************/
public class EnrichBasketConstants {
  public static final String UseExitingSIM = 'UseExitingSIM'; //Dheeraj
  public static final String CALL_RESTRICTION = 'Call Restriction';
  public static final String SITE_DELIVERY_ADDRESS = 'SiteDeliveryAddress';
  public static final String ORDER_PRIMARY_CONTACT_ID = 'Orderprimarycontactid';
  public static final String TOTAL_USER_QTY = 'TotalUserQty';
  public static final String TOTAL_NUMBERS = 'TotalNumbers';
  public static final String PRIMARY_CONTACT_ID = 'Primarycontactid';
  public static final String TECHNICAL_CONTACT_ID = 'Technicalcontactid';
  public static final String WIFI_ADD_ON_USER_MODIFIED = 'WifiAddOnUserModified';
  public static final String SITE_DELIVERY_CONTACT = 'SiteDeliveryContact';
  public static final String PREFERRED_CRD = 'Preferred CRD';
  public static final String NOT_BEFORE_CRD = 'Not Before CRD';
  public static final String SHIPPING_REQUIRED = 'ShippingRequired';
  public static final String SIM_AVAILABILITY_TYPE = 'SimAvailabilityType'; // EDGE-174219 added SimAvailabilityType
  public static final String DEVICE_SHIPPING = 'DeviceShipping';
  public static final String MOBILE_SUBSCRIPTION = 'Mobile Subscription';
  public static final String IOT_SUBSCRIPTION = 'IOT Subscription';
  public static final String NEW_STR = 'New';
  public static final String NEXT_GENERATION_MOBILE_DEVICE = 'Next Generation Mobile Device';
  public static final String ENTERPRISE_MOBILITY_PLAN = 'Enterprise Mobility Plan';
  public static final String IP_SITE = 'IP Site';
  public static final String UNIFIED_COMMUNICATION = 'Unified Communication';
  public static final String CANCEL = 'Cancel';
  public static final String PAID_OUT = 'PaidOut';
  public static final String PAY_OUT = 'PayOut';
  public static final String DMCAT_PRODUCTOFFERING_000304 = 'DMCAT_ProductOffering_000304';
  public static final String IP = 'IP';
  final static String NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c; //DIGI-5648
  // public static final String TELSTRA_COLLABORATION = 'Telstra Collaboration';  DIGI-5648
  public static final String TELSTRA_COLLABORATION = NGUC_OFFER_NAME;
  public static final String SOLUTION_COMPONENT = 'Solution Component';
  public static final String OE = 'OE';
  public static final String DCC = 'DCC';
  public static final String CLOSED_WON = 'Closed Won';
  public static final String CLOSED_WON1 = 'ClosedWon';
  public static final String CANCEL_BASKET = 'CancelBasket';
    public static final String VALIDATE_BILL_ACC_ENRICH = 'validateBillAccEnrich';
    public static final String FALSE_STR = 'FALSE';
  public static final String MOBILE_DEVICE_CARE = 'Mobile Device Care';
    public static final String TENANCY_BRODSOFT_TENANCY = 'Tenancy_BrodsoftTenancy';
    public static final String TENANCY_PRIMARY_CONTACT = 'Tenancy Primary Contact';
    public static final String BUSINESS_CALLING = 'Business Calling';
  public static final String OK = 'ok';
    public static final String SERVICE_DETAILING = 'ServiceDetailing';
    public static final String TRUE_STR = 'true';
    public static final String INCOMPLETE = 'Incomplete';
  public static final String COMPLEX = 'Complex';
    public static final String COMPLEX_PLUS = 'Complex Plus';
    public static final String ENABLE_B2B4 = 'EnableB2B4';
    public static final String SIMPLEX = 'Simplex';
  public static final String SIMPLEX_PLUS = 'Simplex Plus';
    public static final String TRANSITION = 'Transition';
    public static final String LISTED = 'Listed';
    public static final String LISTED_FAX = 'Listed Fax';
    public static final String UNLISTED = 'Unlisted';
    public static final String LE = 'LE';
    public static final String NUMBER_MANAGEMENT_V1 = 'NumberManagementv1';
    public static final String QUANTITY = '<Quantity>';
    public static final String VALID = 'Valid';
    public static final String ERROR_STATUS  = '{"status":"error", "text":"';
    public static final String ERROR_STATUS1 = '{"status":"error","text":"';
    public static final String CLOSE_BRACKET = '"}';
    public static final String DISPLAY_IN_DIALOG = 'displayInDialog';
    public static final String MDM_TENANCY_ERROR = '{"status":"error","text":"MDM Tenancy enrichment is incomplete", "redirectURL":"';
    public static final String NUM_ASSIGNMENT_ERROR = '{"status":"error","text":"Each product configuration must be assigned with the number", "redirectURL":"';
    public static final String OE_ERROR = '{"status":"error","text":"Order Enrichment have Errors, Please check.", "redirectURL":"';
    public static final String REDIRECT_URL_STR = '", "redirectURL":"';
    public static final String REDIRECT_URL = '/apex/csbb__basketbuilderapp?Id=';
    public static final String SOME_ERROR = '{"status":"error","text":"some error..."}';
    public static final String OK_STATUS = '{"status":"ok","text":"';
    public static final String CANCELLATION_REASON_REDIRECT = '{"status":"ok","text":"Opening Cancellation Reason...", "displayInDialog": true,"size": "S","modalTitle": "Cancellation Reason Details", "redirectURL":"/apex/c__MACSolutionCancellation?basketID=';
  public static final String ACCOUNT_ID = '&accountId=';
    public static final String OPP_ID = '&opportunityId=';
     public static final String END_URL_STR = '&isdtp=vw"}';
    
     public static void doNothing() {

       }
        

}