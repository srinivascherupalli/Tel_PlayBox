/*
    AUTHOR : Abhishek Rao
    DESCRIPTION : EDGE-93284 :: <Technical story> Batch script to update Customer Primary Contact for existing and migrated Agreement records
*/

global class CustomerPrimaryContactBatchSchedular implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		BatchCustomerPrimaryContactAssignment primaryContactreassign = new BatchCustomerPrimaryContactAssignment();
		ID batchprocessid = Database.executeBatch(primaryContactreassign,10);
	}
}