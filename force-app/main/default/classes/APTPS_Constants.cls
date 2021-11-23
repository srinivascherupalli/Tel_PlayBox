/*****************************************************************
@Name: APTPS_Constants
@Author: Ruchika Patil 
@CreateDate: 5/5/2016
@Description: This class contains all the Constants used by other custom classes.
@UsedBy: All classes 
******************************************************************/ 
public class APTPS_Constants{
  //romil.anand: Changes for User story EDGE-69221 moving all the  constant variable to CustomLabels.
  //ruchika
  public static final String SYSTEM_ADMINISTRATOR = Label.SYSTEM_ADMINISTRATOR; 
  public static final String COMPLETED_STATUS = Label.COMPLETED_STATUS;
  public static final String FULLY_SIGNED_STATUS = Label.FULLY_SIGNED_STATUS; 
  public static final String TERMINATED_STATUS = Label.TERMINATED_STATUS;
  public static final String EXPIRED_STATUS = Label.EXPIRED_STATUS;
  public static final String IN_EFFECT_STATUS_CATEGORY = Label.IN_EFFECT_STATUS_CATEGORY;
  public static final String PENDING_STATUS = Label.PENDING;
  public static final String POST_TERMINATION_ACTIVITY_STATUS = Label.POST_TERMINATION_ACTIVITY_STATUS;
  public static final String SOURCE_VAL_INTERNAL_PAPER = 'Internal Paper';//EDGE-219001
  public static final String SOURCE_VAL_INTERNAL_DIGITAL = 'Internal Digital';//EDGE-219001
  public static final String DSA_AGMT_CATEGORY = 'Digital Services';//EDGE-219001
  public static final String BSA_AGMT_CATEGORY = 'Business Services';//EDGE-219001
  
  
  
  //shishir
  public static final String MERGED_DOCUMENT_FILE_NAME = Label.MERGED_DOCUMENT_FILE_NAME;
  public static final String SOAP_API_ADDRESS = Label.SOAP_API_ADDRESS;
  public static final String CSV_DATE_FORMAT = Label.CSV_DATE_FORMAT;
  public static final String GENERATED_ATTACHMENT_ORIGINAL = Label.GENERATED_ATTACHMENT_ORIGINAL;
  public static final String REGENERATED_ATTACHMENT_REGENERATED = Label.REGENERATED_ATTACHMENT_REGENERATED;
  public static final String IN_EFFECT_STATUS = Label.IN_EFFECT_STATUS;
  
  public static final String IN_AUTHORING_STATUS_CATEGORY = Label.IN_AUTHORING_STATUS_CATEGORY;
  public static final String IN_AUTHOR_CONTRACT_STATUS = Label.IN_AUTHOR_CONTRACT_STATUS;
  public static final String REQUEST_STATUS_CATEGORY_AND_STATUS = Label.REQUEST_STATUS_CATEGORY_AND_STATUS;
  public static final String IN_SIGNATURES_STATUS_CATEGORY = Label.IN_SIGNATURES_STATUS_CATEGORY;
  public static final String IN_SIGNATURES_STATUS = Label.IN_SIGNATURES_STATUS;
  public static final String CCO_CENTRAL_QUEUE = Label.CCO_CENTRAL_QUEUE;
  public static final String OTHER_PARTY_SIGNATURES_STATUS = Label.OTHER_PARTY_SIGNATURES_STATUS;
  public static final String IN_FILING_STATUS_CATEGORY = Label.IN_FILING_STATUS_CATEGORY;
  public static final String DOCUSIGN_SIGNER_1 = Label.DOCUSIGN_SIGNER_1;
  public static final String DOCUSIGN_SIGNER_2 = Label.DOCUSIGN_SIGNER_2;
  public static final String DOCUSIGN_SIGNER_3 = Label.DOCUSIGN_SIGNER_3;
  public static final String DOCUSIGN_SIGNER_4 = Label.DOCUSIGN_SIGNER_4;
  public static final String NDA_MULTI_PARTY = Label.NDA_MULTI_PARTY;
  //Start : Niranjan Mehta: Changes for User story EDGE-13251 // Updated for Special character
  public static final String ACTIVATED_STATUS = Label.ACTIVATED_STATUS; 
  public static final String TERMINATED_STATUS_CATEGORY = Label.TERMINATED_STATUS_CATEGORY;  
  public static final String CANCELLED_STATUS_CATEGORY = Label.CANCELLED_STATUS_CATEGORY;  
  public static final String FULLY_SIGNED_MIGRATED_STATUS = Label.FULLY_SIGNED_MIGRATED_STATUS;  
  public static final String SUPERSEDED_STATUS = Label.SUPERSEDED_STATUS;  
  public static final String ROLLING_STATUS = Label.ROLLING_STATUS;  
  public static final String BEINGRENEWED_STATUS = Label.BEINGRENEWED_STATUS;  
  public static final String BEINGAMENDED_STATUS = Label.BEINGAMENDED_STATUS;  
  public static final String BEINGTERMINATED_STATUS = Label.BEINGTERMINATED_STATUS;  
  public static final String INAMENDMENT_STATUS = Label.INAMENDMENT_STATUS;  
  public static final String PENDINGAPPROVAL = Label.PENDINGAPPROVAL; 
//Lokesh D : Changes for User story EDGE-81538 added custum label for Minimum Spend information from CALMS to CVT   
  public static final String checkCalmsPermission = Label.checkCalmsPermission;
  public static final String preventWorkflowAlerts = Label.PreventWorkflowAlerts;
  //End : Niranjan Mehta: Changes for User story :EDGE-13251
  //EDGE-134661-- Added Static Variable--Start Here---//
  public static final list<String> apttusStatusCategory = New list<String>{'Request','In Effect','In Authoring','In Signatures','In Filing','Amended','In Approvals'};
  public static final String SERVICE_TERMS='Service Terms';
  public static final String CO_MOBILE_PLUS='Corporate Mobile Plus';
  public static final String CONNECTIVITY='Connectivity';
  public static final String SCHEDULE='Schedule';
  public static final String PRODUCT_KEY_FACTS='Product_Key_Facts';
  public static final String PRICING='Pricing';
  public static final String PRICE_BOOK='Price Book';
  public static final String STANDARD='Standard';
   //EDGE-134661-- Added Static Variable--End Here---//
  public static final string CONST_YES = 'Yes';
   
    /** DIGI-7386 26-08-2021 added the below constant Sale Eligibility*/
    public static final String INVITE_ONLY='Invite Only';
    // Agreement Statuses 
      public static final String FULLYSIGNED='Fully Signed';  
    public static final String INSIGNATURES='In Signatures';  
    public static final String SIGNATUREDECLINED='Signature Declined';  
    public static final String OTHERPARTYSIGN='Other Party Signatures';  
    public static final String CONTRACTACCEPTED='Contract Accepted';  
    public static final String CONTRACTREJECTED='Contract Rejected';  
    public static final String CUSTOMERREVIEW='Customer Review';
    public static final String CANCELLEDREQUEST='Cancelled Request';
    
    //Lokesh Thathuru: Added Constants Variables For Adobe Implementation - Start
    public static final String SIGN_AGREEMENT_STATUS_CREATED=Label.Adobe_Agreement_Status_Created;
    public static final String SIGN_AGREEMENT_STATUS_OUT_FOR_SIGNATURE='Out for Signature';
    public static final String SIGN_AGREEMENT_STATUS_OUT_FOR_ACCEPTANCE=Label.Adobe_Agreement_Status_Out_for_Acceptance;
    public static final String SIGN_AGREEMENT_STATUS_WAITING_FOR_COUNTER_SIGNATURE=Label.Adobe_Agreement_Status_Waiting_for_Counter_Signature;
    public static final String SIGN_AGREEMENT_STATUS_SIGNED=Label.Adobe_Agreement_Status_Signed;
    public static final string SIGN_AGREEMENT_STATUS_CANCELLED='Cancelled / Declined';
    public static final string SIGN_AGREEMENT_STATUS_EXPIRED='Expired';

    
    public static final String CONTRACTJUNCTION_STATUS_INITIATED=Label.Contract_Junction_Status_Initiated;
    public static final String CONTRACTJUNCTION_STATUS_PENDING_APPROVAL=Label.Contract_Junction_Status_Pending_Approval;
    public static final String CONTRACTJUNCTION_STATUS_CUSTOMER_REVIEW=Label.Contract_Junction_Status_Customer_Review;
    public static final String CONTRACTJUNCTION_STATUS_PENDING_COUNTERSIGN=Label.Contract_Junction_Status_Pending_Countersign;
    public static final String CONTRACTJUNCTION_STATUS_CONTRACT_ACCEPTED=Label.Contract_Junction_Status_Contract_Accepted;
    public static final String CONTRACTJUNCTION_STATUS_CANCELLED='Cancelled';
    public static final String CONTRACTJUNCTION_STATUS_SIGNATURE_DECLINED='Signature Declined';
    public static final String CONTRACTJUNCTION_STATUS_VOID='Void';
    public static final String CONTRACTJUNCTION_STATUS_IN_EFFECT='In Effect';
    public static final String Product_Basket_Status_Contract_Accepted=Label.Product_Basket_Status_Contract_Accepted;
    
    public static final String CUSTOMRE_AUTHORITY_FORM_STATUS_COMPLETED='Completed';
    //Lokesh Thathuru: Added Constants Variables For Adobe Implementation - End
    
}