/*************************************************************************************************************************
@Name: APTS_scheduledExpiredAgreement
@Author: Apttus team
@Created Date: 05/21/2020
@Descripton: Rolling status functionality.
*************************************************************************************************************************/
global Without sharing class APTS_scheduledExpiredAgreement implements Schedulable {
   global void execute(SchedulableContext SC) {
      APTS_AgreementBatch agreebatch = new APTS_AgreementBatch(); 
       database.executebatch(agreebatch);
   }
}