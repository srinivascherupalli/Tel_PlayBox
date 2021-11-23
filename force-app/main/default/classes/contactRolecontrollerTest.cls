/*
 * BRAM
 * 
 * EDGE-1616331- Created for contact role creation
 * 
 * */
@isTest(SeeAllData=FALSE)
public class contactRolecontrollerTest {

 @isTest static void performUserValidation() {
     
     Test.startTest();
    		
     Account acc = new Account(Name = 'Test Account for CBQ');
     acc.Customer_Status__c = 'ACQUIRED';
     List<Account> accList = new List<Account>{acc};
     insert accList;
	
     Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
     opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
     insert opp;

      list<Contact> con=new list<Contact>();
     Contact c = new Contact();
     //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
     c.AccountId = acc.id;
     c.FirstName = 'Testing';
     c.LastName = 'Test';
     c.email='test@test.com';
     con.add(c);
    
     Contact c1 = new Contact();
     c1.AccountId = acc.id;
     c1.FirstName = 'Testing cr';
     c1.LastName = 'Test';
    c1.email='testcr@test.com';
      con.add(c1);
    INSERT con;

     OpportunityContactRole ocr = new OpportunityContactRole();
     ocr.ContactId = con[0].Id;
     ocr.OpportunityId = opp.Id;
     ocr.IsPrimary = TRUE;
     ocr.Role = 'Decision Maker';
     
     INSERT ocr;
     
 	
    
     OpportunityContactRole opproledetails=contactRolecontroller.getOpptyContactRole(ocr.Id);
     
     
     contactRolecontroller.createOpptyContactRole(opp.Id,'Decision Maker',true,con[0].Id);
     
     contactRolecontroller.createOpptyContactRole(opp.Id,'Decision Maker',true,con[1].Id);
     
     contactRolecontroller.getOpptydetails(opp.Id);
     contactRolecontroller.getOpptyrolefromcontactoppty(opp.Id,con[0].Id);
     
     contactRolecontroller.updateOpptyContactRole(ocr.Id,'Decision Maker',true);
     contactRolecontroller.picklist_values('OpportunityContactRole','Role');
     Test.stopTest();
     
     
  	 System.assertEquals(opproledetails.Role,'Decision Maker');
     
 	}
    
}