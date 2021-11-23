public class Orchestration_ProcessedRecords {
	public String StepId;

	//NEW LISTS to be used in JSON Creation
	public Set<String> orderIds;
	public Set<String> subsIds;
	public Set<String> serviceIds;
	public Set<String> attachmentIds;
	public Set<String> numberIds;
	public Set<String> skipRecordsIds;
    public Set<String> pcIds;
	//public Set<String> caseInsertIdentifiers;

	//Properties for Generate Prices Schedule
	public Set<String> chargeLineItems;
	public Set<String> priceScheduleLineItems;
	public Set<String> tierLineItems;
	public Set<String> discountAssociations;
	public Set<String> discountLineItems;

	//Map of unique identifiers aginst the SF id of the records inserted with step execution
	public Map<String, String> mapInsertedRecords;
	public Map<String, String> mapDetailRecords;

	public Orchestration_ProcessedRecords() {
	}
}