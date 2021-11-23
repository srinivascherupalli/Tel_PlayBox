//
// DTO class for SQ Response for Site
//
public class SiteSQResponseDTO {
    public Integer status;
    public String correlationId;
    public Data data;
    public List<Messages> errors;
    public String code;
    public String message;
    public String Error_Code;
    public String Error_Description;
    public String responseTime;
    public Request request;
    
    public class Request {
        public String correlationId;
        public String requestId;
        public String method;
        public String path;
        public Params params;
    }
    
    public class Params{
        public String nbnCustomerAuthorityDate;
        public String adborId;
    }
    
	public class ProductResourceIdentifierDetails {
		public String productResourceIdentifierID;
		public String serviceProviderId;
		public String refCopperPairID;
		public String maxDownstreamSpeed;
		public String maxUpstreamSpeed;
		public String nbnPriorityAssist;
		public String portLinkage;
		public List<PortDetails> portDetails;
		public String refNTD;
		public String batteryPowerStatus;
		public String batteryInstallDate;
		public String batteryMonitoringStatus;
		public String ntdLoc;
		public String ntdInstallDate;
		public String ntdType;
		public String ntdPowerType;
		public String appointmentRequired;
	}

	public class ResourceDetails {
		public String ntdId;
		public String ntdLoc;
		public String ntdInstallDate;
		public String ntdType;
		public String ntdPowerType;
		public List<PortDetails_Z> portDetails;
		public String batteryPowerUnit;
		public String powerSupplywithBatteryBackupInstallDate;
		public String batteryPowerUnitMonitored;
	}

	public class UnconditionedLocalLop {
		public String nbnResourceId;
		public String unconditionedLocalLoopId;
		public String demandType;
		public String maxDownstreamSpeed;
		public String maxUpstreamSpeed;
		public String serviceProviderId;
		public String appointmentRequired;
	}

	public class ServiceTypeQualifications {
		public String serviceType;
		public String status;
		public String serviceTransferIndicator;
		public String statusReason;
		public String technologyType;
		public String readyForServiceDate;
		public String serviceabilityClass;
		public String newDevelopmentChargesApply;
		public String locationId;
		public String csaId;
		public String priorityAssistApplicable;
		public String tc2EnabledCsa;
		public List<Characteristics> characteristics;
		public List<ProviderResources> providerResources;
	}

	public class PortDetails {
		public String uniPortType;
		public String portId;
	}

	public class PortDetails_Z {
		public String uniPortType;
		public String portId;
		public String portStatus;
	}

	public class Messages {
		public String code;
		public String message;
	}

	public class Characteristics {
		public String name;
		public String value;
	}

	public class Data {
		public String addressId;
		public List<ServiceTypeQualifications> serviceTypeQualifications;
		public List<Characteristics> additionalTrafficClassAvailability;
		public ScheduledDates scheduledDates;
		public OrderableTC2Capacity orderableTC2Capacity;
		public List<UnconditionedLocalLop> unconditionedLocalLop;
		public List<ProductResourceIdentifierDetails> productResourceIdentifierDetails;
		public List<ResourceDetails> resourceDetails;
		public List<Messages> messages;
	}
	
	public class OrderableTC2Capacity{
		public String maxBackhaul;
		public String maxSpareCopperPair;
		public String maxTransitioningCopperPair;	
	}
	
	public class ProviderResources {
		public String resourceType;
		public String id;
		public String status;
		public String serviceabilityClass;
	}

	public class ScheduledDates {
		public String orderStabilityPeriodDate;
		public String ceaseSaleDate;
	}

	
	public static SiteSQResponseDTO parse(String json) {
		String jsonString = json.replace('"time"', '"responseTime"');
		return (SiteSQResponseDTO) System.JSON.deserialize(jsonString, SiteSQResponseDTO.class);
	}
}