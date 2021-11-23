@isTest
public class MassReassignOpportunitiesControllerTest {
    public static testmethod void testReassign(){
        
        Account testAccount = new Account();
        testAccount.Name = 'test';
        testAccount.Customer_Status__c='Active';
        insert testAccount;
        
        Opportunity testOpty = new Opportunity();
        testOpty.StageName = 'Develop';
        testOpty.CloseDate = System.today()+1;
        testOpty.AccountId = testAccount.Id;
        testOpty.Name ='testOpty';
        testOpty.Description = 'testDesc';
        //testOpty.Industry__c = 'Education';
        testOpty.Product_Domain__c = 'MOBILES';
        insert testOpty;
        
        MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();
        controller.refreshOptyList();
        controller.filterId = controller.listviewoptions[1].getValue();
        controller.refreshOptyList();
        controller.searchRecord.stageName = 'Develop';
        
        controller.helperRecord.ClosedDate_From__c=System.today();
        controller.helperRecord.ClosedDate_To__c=System.today()+2;
        controller.helperRecord.From__c=System.today();
        controller.helperRecord.To__c=System.today()+1;
        /*
        controller.searchRecord.Type = 'testType';*/
        controller.refreshOptyListBySearch();
        
        //System.assert(controller.optyList.size()>0);
        MassReassignOpportunitiesController.cOpty copp=new MassReassignOpportunitiesController.cOpty(testOpty);
        copp.oOpty=testOpty;
        controller.optyList.add(copp);
        controller.optyList[0].selected = true;
        controller.helperRecord.Assign_to__c = UserInfo.getUserId();
        controller.Assign();
          
    }
    
}