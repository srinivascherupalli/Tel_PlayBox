public class FullServiceabilitySQResponseDTO {
    public String correlationId;
	public Data data;
	public List<Errors> errors;
    public String code;
	public String message;
	public Integer status;
	public String Error_Code;
	public String Error_Description;
	public String responseTime;

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
		public String appointmentRequired;
	}

	public class ResourceDetails {
		public String preferredNTD;
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

	public class ServiceTypeQualifications {
		public String serviceType;
		public String status;
		public String serviceTransferIndicator;
		public String statusReason;
		public String infrastructurePlannedDate;
		public String technologyType;
		public String readyForServiceDate;
		public String serviceabilityClass;
		public String newDevelopmentChargesApply;
		public String locationId;
		public String csaId;
		public String tc2EnabledCsa;
		public String priorityAssistApplicable;
		public List<ProviderResources> providerResources;
		public List<Characteristics> characteristics;
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
    
    public class Errors {
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
		public List<UnconditionedLocalLoop> unconditionedLocalLoop;
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

	public class UnconditionedLocalLoop {
		public String nbnResourceId;
		public String unconditionedLocalLoopID;
		public String demandType;
		public String maxDownstreamSpeed;
		public String maxUpstreamSpeed;
		public String serviceProviderId;
		public String appointmentRequired;
	}

	public class ScheduledDates{
		public string orderStabilityPeriodDate;
		public string ceaseSaleDate;
	}
	
	public static FullServiceabilitySQResponseDTO parse(String json) {
		String jsonString = json.replace('"time"', '"responseTime"');
		return (FullServiceabilitySQResponseDTO) System.JSON.deserialize(jsonString, FullServiceabilitySQResponseDTO.class);
	}
}