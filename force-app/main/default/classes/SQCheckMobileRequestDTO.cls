/*******************************************************************************************************************
Name : SQCheckMobileRequestDTO
EDGE-> 107149
Description : Request dto for the callout to the portin SQ Check API to get the Qualify details of the selected MSISDN
====================================================================================================================*/

public class SQCheckMobileRequestDTO {

	public Data data;

	public class Attributes {
		public String fieldList;
	}

	public class Data {
		public List<Resources> resources;
		public Attributes attributes;
	}

	public class Resources {
		public String resourceId;
	}

	
	public static SQCheckMobileRequestDTO parse(String json) {
		return (SQCheckMobileRequestDTO) System.JSON.deserialize(json, SQCheckMobileRequestDTO.class);
	}
}