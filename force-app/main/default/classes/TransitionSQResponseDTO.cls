//Transition SQ Response DTO

public class TransitionSQResponseDTO {
	public String correlationId;
	public Data data;
	public List<Messages> errors;
	public Integer status;
	public String code;
	public String message;
	public String Error_Code;
	public String Error_Description;

	public class ResourceDetails {
		public String ntdId;
		public String ntdLoc;
		public String ntdInstallDate;
		public String ntdType;
		public String ntdPowerType;
		public String batteryPowerUnit;
		public String powerSupplywithBatteryBackupInstallDate;
		public String batteryPowerUnitMonitored;
		public List<PortDetails> portDetails;
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
		public String appointmentRequired;
		public String demandType;
		public List<Characteristics> characteristics;
		public List<ProviderResources> providerResources;
		public String priortiyAssistApplicable;
	}

	public class PortDetails {
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

	public class Characteristics_Z {
	}

	public class Data {
		public String addressId;
		public Boolean migration;
		public String reason;
		public List<ServiceTypeQualifications> serviceTypeQualifications;
		public ScheduledDates scheduledDates;
		public OrderableTC2Capacity orderableTC2Capacity;
		public List<Characteristics> additionalTrafficClassAvailability;
		public List<ResourceDetails> resourceDetails;
		public List<Messages> messages;
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

	public class OrderableTC2Capacity{
		public String maxBackhaul;
		public String maxSpareCopperPair;
		public String maxTransitioningCopperPair;	
	}
	
	public static TransitionSQResponseDTO parse(String json) {
		return (TransitionSQResponseDTO) System.JSON.deserialize(json, TransitionSQResponseDTO.class);
	}
}