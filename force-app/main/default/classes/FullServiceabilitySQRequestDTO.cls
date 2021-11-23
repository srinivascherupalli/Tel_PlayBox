public class FullServiceabilitySQRequestDTO {
	
    public Data data;
    
	public class Data {
		public String addressId;
		public String fnn;
		public String priority;
		public String nbnCustomerAuthorityDate;
		public String lineOfBusiness;
		public String customerConsent;
		public Boolean batteryBackup;
		public List<AccessProfiles> accessProfiles;
		public List<ServiceTypes> serviceTypes;
		public Data()
		{
			this.priority='Standard';
			this.batteryBackup = false;
			this.customerConsent = 'No';	
		}
	}

	public class ServiceTypes {
		public String service;
		public Boolean internetAccessLevel;
		public String sessionAdmissionControl;
		public String specialServiceIndicator;
		public ServiceTypes()
		{
			this.internetAccessLevel = false;
			this.sessionAdmissionControl = '0';	
			this.specialServiceIndicator = '';	
		}
	}
		
	public class AccessProfiles {
		public String trafficClass;
		public String downloadSpeedMbps;
		public String uploadSpeedMbps;
	}

	public boolean checkMandatoryParams(){
        if((Data.addressId != '' && Data.addressId != null) && 
        	(Data.lineOfBusiness != '' && Data.lineOfBusiness != null) &&
        	(!Data.serviceTypes.isEmpty() && Data.serviceTypes != null) &&
        	(Data.ServiceTypes[0].service != '' && Data.ServiceTypes[0].service != null)){

        	if(Data.batteryBackup == true && (Data.customerConsent == '' || Data.customerConsent == null || Data.customerConsent =='No')){
        		return false;
        	}else{
        		return true;
        	}        
		}
		return false;
    }

	public static FullServiceabilitySQRequestDTO parse(String json) {
		return (FullServiceabilitySQRequestDTO) System.JSON.deserialize(json, FullServiceabilitySQRequestDTO.class);
	}
}