/**================================================================
 * Appirio, Inc
 * Name: OrchestratorConstants
 * Description: Class to store the constants for order orchestration
 * Created Date: May 19, 2020
 * Created By: Gaurang Maheshwari
 *
 *  Sr.No.    Developer Name        Date          Description
    1         Gaurang Maheshwari  19/05/2020      Added Orcestration process template Constants
    2         Gaurang Maheshwari  23/05/2020      Added Product Config Type, Subscription and Order Status Constants
    3         Martand Atrey       29/05/2020      Added subscriptionStatuses, OrderStatus "In Error"
    4         Gaurang Maheshwari  01/06/2020      Added Constants for delta orders
    5         Martand Atrey       02/06/2020      Added Constants for GenerateTransientData => specCodes
    6         Gaurang Maheshwari  06/06/2020      Added Object Types
    7         Martand Atrey       11/06/2020      Removed the Creation of list here
    8         Martand Atrey       17/06/2020      Added Attachment Name : TransientData, Asset Status, Subs MarketableOfferType, offerName , sObject record types, Service Name, Service Spec Status
    9         Vitap Ramdevputra   3/12/2020       Added new value ('Waiting') in OrchestratorProcessEnum
    10      Pawan devaliya          01/01/2020    EDGE-170463 : Added Inflight order Template Name
	11     Aparna Anisetti    		08/20/2020    DIGI-5635 :Modified Telstra Collaboration Professional Service 
												  to Adaptive Collaboration Professional Service
 ==================================================================*/

public class OrchestratorConstants {
    public static final OrchestratorStepEnum OrchestratorStep = new OrchestratorStepEnum();
    public static final OrchestratorProcessEnum OrchestratorProcess = new OrchestratorProcessEnum();
    public static final DataOrchestrationAttNames DataOrchestrationNames = new DataOrchestrationAttNames();
    public static final ServiceStatusEnum ServiceStatus = new ServiceStatusEnum();
    public static final SubscriptionStatusEnum SubscriptionStatus = new SubscriptionStatusEnum();
    public static final OrderStatusEnum OrderStatus = new OrderStatusEnum();
    public static final OrchestratorTemplateName OrchesTemplateName = new OrchestratorTemplateName();
    public static final ProductConfigTypeEnum ProductConfigType = new ProductConfigTypeEnum();
    public static final ProductConfigEnum ProductConfig = new ProductConfigEnum();
    public static final AttachmentNameEnum AttachmentName = new AttachmentNameEnum();
    public static final ExclusionEnum Exclusion = new ExclusionEnum();
    public static final TargetSystemEnum TargetSystem = new TargetSystemEnum();
    public static final SpecNameEnum SpecName = new SpecNameEnum();
    public static final BasketConfigurationEnum BasketConfiguration = new BasketConfigurationEnum();
    public static final ProductRequirementTypeEnum ProductRequirementType = new ProductRequirementTypeEnum();
    public static final ServiceActionTypeEnum ServiceActionType = new ServiceActionTypeEnum();
    public static final ServicePaymentTypeEnum ServicePaymentType = new ServicePaymentTypeEnum();
    public static final ProductConfigMarketableOfferEnum ProductConfigMarketableOffer = new ProductConfigMarketableOfferEnum();
    public static final OrchestrationObjectTypeEnum OrchestrationObjectType = new OrchestrationObjectTypeEnum();
    public static final SystemConstantEnum SystemConstant = new SystemConstantEnum();
    public static final AssetStatusEnum AssetStatus = new AssetStatusEnum();
    public static final SubscriptionMarketableOfferTypeEnum SubscriptionMarketableType = new SubscriptionMarketableOfferTypeEnum();
    public static final OfferNameEnum OfferName = new OfferNameEnum();
    public static final sObjectRecordTypeEnum sObjectRecordType = new sObjectRecordTypeEnum();
    public static final OrchestrationProcessStateEnum OrcehstrationProcessState = new OrchestrationProcessStateEnum();
    public static final ServiceNameEnum ServiceName = new ServiceNameEnum();
    public static final ServiceSpecificationKeyEnum ServiceSpecificationKey = new ServiceSpecificationKeyEnum();
    public static final ServiceSpecsStatusEnum ServiceSpecsStatus = new ServiceSpecsStatusEnum();
    public static final SobjectNameEnum SOBJECT_ENUM = new SobjectNameEnum();

    public class OrchestratorStepEnum {
        public final String Complete = 'Complete';
        public final String Error = 'Error';
        public final String InProgress = 'In Progress';
        public final String Waiting = 'Waiting';
    }

    public class sObjectRecordTypeEnum {
        public final String Case_Fulfilment = 'Fulfillment';
        public final String FCR_PortalAdmin = 'Portal Admin';
    }

    public class OrchestratorProcessEnum {
        public final String Complete = 'Complete';
    }

    public class DataOrchestrationAttNames {
        public final String service = 'ServiceSpecifications.json';
        public final String order = 'OrderSpecifications.json';
        public final String subscription = 'SubscriptionSpecifications.json';
        public final String processedIds = 'ProcessedIds.json';
        public final String callOutResponse = 'CallOutResponse.json';
        public final String TransientData = 'TransientDataDetails.json';
        public final String OperationsUserSchema = 'Operations User_schema.json';
    }

    public class ServiceStatusEnum {
        public final String InProgress = 'In Progress';
        public final String Connected = 'Connected';
        public final String DisconnectPending = 'Disconnect Pending';
        public final String Disconnected = 'Disconnected';
        public final String PaidOut = 'Paid Out';
        public final String Pending = 'Pending';
        public final String Created = 'Created';
    }

    public class ServiceSpecsStatusEnum {
        public final String Completed = 'Completed';
        public final String DisconnectPending = 'Disconnect Pending';
        public final String Disconnected = 'Disconnected';
        public final String Suspended = 'Suspended';
        public final String Failed = 'Failed';
        public final String Canceled = 'Canceled';
        public final String Created = 'Created';
        public final String PaidOut = 'Paid Out';
    }

    public class SubscriptionStatusEnum {
        public final String InProvisioning = 'In Provisioning';
        public final String Active = 'Active';
        public final String Pending = 'Pending';
        public final String Inactive = 'Inactive';
        public final String CancellationInProgress = 'Cancellation In Progress';
        public final String Failed = 'Failed';
        public final String Cancelled = 'Cancelled';
        public final String BillingComplete = 'Billing Complete';
        public final String Suspended = 'Suspended';
        public final String InProgress = 'In Progress';
        public final String Provisioned = 'Provisioned';
        public final String ProvisioningInProgress = 'Provisioning In Progress';
        public final String DisconnectPending = 'Disconnect Pending';
        public final String DisconnectInProgress = 'Disconnect in Progress';
        public final String PaidOut = 'Paid Out';
    }

    public class OrderStatusEnum {
        public final String InProgress = 'In Progress';
        public final String CancellationInProgress = 'Cancellation In Progress';
        public final String Failed = 'Failed';
        public final String Cancelled = 'Cancelled';
        public final String Completed = 'Completed';
        public final String InError = 'In Error';
        public final String AppointmentRequired = 'Appointment Required';
        public final String ReadyForSubmit = 'Ready For Submit';
    }

    public class OrchestrationProcessStateEnum {
        public final String Active = 'Active';
    }

    public class OrchestratorTemplateName {
        public final String serviceTemplate = 'Service Fulfilment Process';
        public final String serviceTemplateNew = 'Service Fulfilment Process_New';
        public final String fulfilmentSubsTemplate = 'Subscription Fulfilment Process';
        public final String ceaseSubsTemplate = 'Subscription Cease Process';
        public final String msisdnReserveTemplate = 'MSISDN Reserve Process';
        public final String inflightOrderTemplate = 'Inflight Orchestration Process'; //EDGE-170463
        public final String autoCompleteSubsTemplate = 'Auto Completed Subscription Process'; //MT
        public final String svcFulfillmentProvision = 'Subscription Fulfilment Process_Provision'; //MT
        public final String svcFulfillmentActivation = 'Subscription Fulfilment Process_Activation'; //MT
    }

    public class ProductConfigEnum {
        public final String ConnectedWorkplaceSolution = 'Connected Workplace Solution';
    }

    public class ProductConfigTypeEnum {
        public final String SolutionComponent = 'SolutionComponent';
    }

    public class ProductConfigMarketableOfferEnum {
        public final String DeviceOutrightPurchase = 'Device Outright Purchase';
    }

    public class AttachmentNameEnum {
        public final String NumberManagement = 'NumberManagement';
        public final String NumberManagementExist = '%NumberManagement%';
    }

    public class ExclusionEnum {
        public final String DeltaCheck = 'DeltaCheck';
    }

    public class TargetSystemEnum {
        public final String FULFILMENT = 'FULFILMENT';
        public final String BILLING = 'BILLING';
        public final String ASSURANCE = 'ASSURANCE';
    }

    public class AssetStatusEnum {
        public final String InActive = 'InActive';
    }

    public class SpecNameEnum {
        public final String DMCAT_ProductSpecification_000423 = 'DMCAT_ProductSpecification_000423';
        public final String DMCAT_ProductSpecification_000622 = 'DMCAT_ProductSpecification_000622';
        public final String DMCAT_ProductSpecification_000623 = 'DMCAT_ProductSpecification_000623';
        public final String DMCAT_ProductSpecification_000423_Fulfilment = 'DMCAT_ProductSpecification_000423_Fulfilment';
        public final String DMCAT_ProductSpecification_000622_Fulfilment = 'DMCAT_ProductSpecification_000622_Fulfilment';
        public final String DMCAT_ProductSpecification_000163 = 'DMCAT_ProductSpecification_000163';
        public final String DMCAT_ProductSpecification = 'DMCAT_ProductSpecification';
    }

    public class BasketConfigurationEnum {
        public final String SOMOpenAir = 'SOMOpenAir';
    }

    public class ProductRequirementTypeEnum {
        public final String NotRequired = 'NotRequired';
        public final String OnlyFulfilmentRequired = 'OnlyFulfilmentRequired';
        public final String BothRequired = 'BothRequired';
        public final String OnlyBillingRequired = 'OnlyBillingRequired';
    }

    public class ServiceActionTypeEnum {
        public final String PayOut = 'PayOut';
        public final String None = 'None';
        public final String PaidOut = 'PaidOut';
    }

    public class ServicePaymentTypeEnum {
        public final String Rental = 'Rental';
    }
    public class SubscriptionMarketableOfferTypeEnum {
        public final String Professional = 'Professional Service';
        public final String Managed = 'Managed Service';
    }

    public class OfferNameEnum {
        public final String OfferName = 'Offername';
        public final String TelstraCollabProfService = Offer_Id__mdt.getInstance('Telstra_Collaboration_Professional_Servi')?.Template_family__c;//DIGI-5635
        public final String TMDMProfService = 'T-MDM Professional Services';
    }

    public class OrchestrationObjectTypeEnum {
        public final String Order = 'Order';
        public final String Subscription = 'Subscription';
        public final String Service = 'Service';
        public final String Attachment = 'Attachment';
    }

    public class ServiceNameEnum {
        public final String IPNetwork = 'IP Network';
    }

    public class ServiceSpecificationKeyEnum {
        public final String AdditionalAttributes = 'additionalAttributes';
        public final String TotalNumberOfUsers = 'TotalNumberOfUsers';
        public final String Specifications = 'specifications';
        public final String Code = 'code';
        public final String Guid = 'guid';
        public final String Name = 'name';
        public final String ProductConfigurationId = 'productConfigurationId';
        public final String Attributes = 'attributes';
        public final String Status = 'status';
        public final String TargetSystem = '__targetSystem';
    }

    public class SystemConstantEnum {
        public final Integer TextAreaSize = 131072;
        public final String AttachmentMsg = 'Please look at Notes & Attachments related list';
        public final Integer OrchestrationProcessRecordsLimit = 200;
        public final String stepResetMsg = 'Step has been reset';
    }

    public class SobjectNameEnum {
        public final String SUBSCRIPTION = 'Subscription';
        public final String SERVICE = 'Service';
        public final String ATTACHMENT = 'Attachment';
    }
}