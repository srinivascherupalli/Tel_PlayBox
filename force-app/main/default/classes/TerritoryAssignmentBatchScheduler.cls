/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Scheduler Class for Batch Assignment of Accounts and Open Opportunities based on Territory
					Allows Admins to schedule this to run at a specified time without using Anonymous Apex
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

global class TerritoryAssignmentBatchScheduler implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		BatchAccountAssignment reassign = new BatchAccountAssignment();
		ID batchprocessid = Database.executeBatch(reassign);
	}
}