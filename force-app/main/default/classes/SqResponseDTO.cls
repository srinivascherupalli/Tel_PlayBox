/*
Story No    | Status   | Name
EDGE - 67863| Created  | Kalashree Borgaonkar
DIGI - 776  | Modified | Akshay G (Istanbul) - Deserialized extra field to Map with new created fields in Service Qualification, 
                         Service Qualification Provider Resource and Service Qualification Details objects.
DIGI - 2540 | Modified | Ajith Kumar - Merged the SqResposnse and widefeas Response wrapper class
DIGI-29002  | Modified | Sowmya      - created wrapper variables for new fields.
*/
public without sharing class SqResponseDTO {

    public class ServiceTypeQualifications {
        public String serviceType ;
        public String technologyType ;
        public String readyForServiceDate ;
        public String serviceabilityClass ;
        public String newDevelopmentChargesApply ;
        public String locationId ;
        public String csaId ;
        public String demandType ;
        public List<ProviderResources> providerResources ;
        public List<Characteristics> characteristics ;
        public String statusReason ;
        public String status ;
        public String serviceTransferIndicator ;
        public Boolean tc2EnabledCsa ;
        public String priorityAssistApplicable ;
        public String appointmentRequired ;
        public Properties properties ;
        public String copperPairIndicator ;
        public String estimatedAvailabilityDate ;
        public List<CopperPairs> copperPairs; // DIGI - 776

    }

    public class PortDetails {
        public String uniPortType ;
        public String portId ;
        public String portStatus ;
    }

    public class Messages {
        public String code ;
        public String message ;
    }

    public Integer code ;
    public Integer status ;
    public String time_res ;
    public Data data ;
    public Request request ;
    public String correlationId ;
    public String message;
	public Errors errors;
    
    public class Request {
        public Params params ;
        public ProviderResources data ;
        public String path ;
        public String method ;
        public String requestId ;
        public String correlationId ;
    }

    public class Params {
        public String addressId ;
    }

    public class Data {
		public List<Location> location;
        public String addressId ;
        public List<ServiceTypeQualifications> serviceTypeQualifications ;
        public List<ResourceDetails> resourceDetails ;
        public List<AdditionalTrafficClassAvailability> additionalTrafficClassAvailability ;
        public List<Messages> messages ;
        public ScheduledDates scheduledDates ;
        public OrderableTC2Capacity orderableTC2Capacity;
    }

    public class ProviderResources {
    	public String resourceType;
		public String id;
		public String status;
        /****** DIGI - 776 Start *****/
        public String sicIndicator;
        public String sicCode;
        public String sicReason;
        /****** DIGI - 776 End *****/
		public String serviceabilityClass;
    }

    public class Properties {
        public String subStatus ;
        public String maxDownloadSpeed ;
        public String minDownstreamSpeed ;
        public String maxDownstreamSpeed ; 
        public String estimatedDownstreamSpeed ;
        public String fieldWorkRequired ;
        public String exchangeWorkRequired ;
    }

    public class ScheduledDates {
        public String ceaseSaleDate ;
        public String orderStabilityPeriodDate ;
    }

    public class ResourceDetails {
        public String ntdId ;
        public String ntdLoc ;
        public String ntdInstallDate ;
        public String ntdType ;
        public String ntdPowerType ;
        public String batteryPowerUnit ;
        public String powerSupplyWithBatteryBackupInstallDate ;
        public String batteryPowerUnitMonitored ;
        public List<PortDetails> portDetails ;
    }

    public class Characteristics {
        public String name ;
        public String value ;
    }

    public class Location {
		public Integer adborId;
		public String addressType;
		public String fibreAvailabilityStatus;
		public String fibreAvailabilityReasonCode;
		public List<ProductDetails> productDetails;
	}
	
	public class ProductDetails {
		public String carriageSolution;
		public String carriageSolutionStatus;
		public String carriageSolutionReasonCode;
		public Integer maximumESABandwidth;
		public Integer maximumDeviceBandwidth;
		public String interfaceType;
        public String spareSlotIndicator;
		public Boolean deviceBuildIndicator;
        //Start DIGI-29002 
        public String deviceType;
        public String deviceDomain;
        public String unifiedAccess;
        public String deviceMigration;
        //End DIGI-29002 
	}
	
	public class Errors {
		public List<ErrorDetails> errorDetails;
	}

	public class ErrorDetails {
		public String code;
		public String message;
	}
	
    /******DIGI - 776 Start *****/
    public class CopperPairs{
        public String id;
    }

    public class OrderableTC2Capacity{
        public string maxBackhaul;
        public string maxSpareCopperPair;
    }
    public class AdditionalTrafficClassAvailability{
        public String name ;
        public String value ;        
    }    
    /******DIGI - 776 End *****/

    public static SqResponseDTO parse(String json) {
        return (SqResponseDTO) System.JSON.deserialize(json, SqResponseDTO.class);
    }
}