/********************************************************
Class Name : scheduleEDISBatch
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             Pawan Devaliya         08/07/2021          DIGI-869
2.				Pawan Devaliya		  27/07/2021		Updates batch frequency logic to dynamic
**********************************************************/

global class ScheduleEDISBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        Environment_Configurations__c ec = Environment_Configurations__c.getOrgDefaults();
        integer BatchSize = 8;
		Integer EDIS_Batch_Frequencyinhrs  = 24;
        if(ec.EDIS_Batch_size__c != null){
        BatchSize = Integer.valueOf(ec.EDIS_Batch_size__c);
        }
		
		if(ec.EDIS_Batch_Frequency_inhrs__c != null && ec.EDIS_Batch_Frequency_inhrs__c > 0){
        EDIS_Batch_Frequencyinhrs = Integer.valueOf(ec.EDIS_Batch_Frequency_inhrs__c);
        }
        
        database.executebatch(new EDIS_Batch(), BatchSize);
   

//Start : Scheduling next batch execution
 DateTime last_hr_updated = Datetime.now().addHours(EDIS_Batch_Frequencyinhrs);
 String day = string.valueOf(last_hr_updated.day());
 String month = string.valueOf(last_hr_updated.month());
 String year = string.valueOf(last_hr_updated.year());
 String hour = string.valueOf(last_hr_updated.hour());
 
String strSchedule = 0 + ' ' + 1 + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
String strJobName = 'EDIS Batch-' +strSchedule;
System.schedule(strJobName, strSchedule, new ScheduleEDISBatch());
   } 
}