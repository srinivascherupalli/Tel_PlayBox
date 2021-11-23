public with sharing class ManageOrderServicesDTO {
	public Id svcId; public String svcName; public String svcNumber; public String svcSubscriptionId; public String status;

	public ManageOrderServicesDTO(Id svcId, String svcName, String svcNumber, String svcSubscriptionId, String status) {
		this.svcId = svcId;
		this.svcName = svcName;
		this.svcNumber = svcNumber;
        this.svcSubscriptionId = svcSubscriptionId;
        this.status = status;
	}

	public Boolean equals(Object o){
		if(o instanceof ManageOrderServicesDTO){
			ManageOrderServicesDTO s = (ManageOrderServicesDTO) o;
			return ((svcId == s.svcId) && (svcName == s.svcName) && (svcNumber == s.svcNumber) && (svcSubscriptionId == s.svcSubscriptionId));
		}
		return false;
	}

	public String hashCode(){
		return String.valueOf(svcId);
	}
}