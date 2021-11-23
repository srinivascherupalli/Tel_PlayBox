@isTest(SeeAllData=false)
public class APTPS_ExportSchedulesControllerTest {
    
    @isTest
     static void APTPS_ExportSchedulesController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
      
        
        PageReference pageRef = Page.APTPS_Init_ExportSchedules;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        APTPS_ExportSchedulesController controller = new APTPS_ExportSchedulesController();
        system.assertEquals(agmt.id, controller.parentAgreementId);
        
        controller.generateCSV();
         APTPS_ExportSchedulesController.generateCSV(agmt.id);
       
        Test.stopTest();
    }

}