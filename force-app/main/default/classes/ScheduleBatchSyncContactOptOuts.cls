/*******************************************************************
@Class Name			: ScheduleBatchSyncContactOptOuts
@Sprint 			: 21.08  & P2OB-13388
@Author				: SFO Team (Pallavi B)
@CreateDate			: 21/06/2021
@description		: Schedules BatchSyncContactOptOuts Class.
@Last Modified      : 
*********************************************************************/

global with sharing class ScheduleBatchSyncContactOptOuts implements Schedulable {

         global void execute(SchedulableContext sc) {
             
                ID BatchId = Database.executeBatch(new BatchSyncContactOptOuts(), 200);
             
         }

}