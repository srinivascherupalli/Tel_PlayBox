/*************************************************************************************************
EDGE -98319
Name: WidefeaseSQResponseDTO
Description: DTO Class for widefeasSQ 
Author:Aishwarya
***************************************************************************************************/
/*************************************************************************************************
DIGI-2540
Name: WidefeaseSQResponseDTO
Description: DTO Class for widefeasSQ referred in SCAddressSearchController and not referred anymore in SQCheckCalloutHandler
Modified:Ajith Kumar
***************************************************************************************************/
public class WidefeaseSQResponseDTO {
    public class Errors {
		public List<ErrorDetails> errorDetails;
	}
    public Integer code;
	public Integer status;
    public String time_x;
	public Errors errors;
	public Data data;
	public String correlationId;
	public Request request;

	public class ProductDetails {
		public String carriageSolution;
		public String carriageSolutionStatus;
		public String carriageSolutionReasonCode;
		public Integer maximumESABandwidth;
		public Integer maximumDeviceBandwidth;
		public String interfaceType;
		//Removed the SQcheckcallout handler reference variables
	}

	public class Request {
		public Params params;
		public String path;
		public String method;
		public String requestId;
		public String correlationId;
	}

	public class Params {
		public String addressId;
	}

	public class Data {
		public List<Location> location;
	}

	public class Location {
		public Integer adborId;
		public String addressType;
		public String fibreAvailabilityStatus;
		public String fibreAvailabilityReasonCode;
		public List<ProductDetails> productDetails;
	}

	public class ErrorDetails {
		public String code;
		public String message;
	}
	public static WidefeaseSQResponseDTO parse(String json) {
		return (WidefeaseSQResponseDTO) System.JSON.deserialize(json.replace('time', 'time_x'), WidefeaseSQResponseDTO.class);
	}

}