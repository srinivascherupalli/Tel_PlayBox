/*****************************************************************************
@Name: ContactAccountRelationChecktest
@Author: SFO Team : Chhaveel
@CreateDate: 25/05/2021
@Description: test class for ContactAccountRelationCheck class and SFOOpportunityContactRoleTriggerHandler Class
*******************************************************************************/


@isTest
public class ContactAccountRelationCheckTest {
    
    
    @testSetup static void setup() {
        
        
        list<account> acclist = new list<account>();
        list<contact> conlist = new list<contact>();

        
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acclist.add(acc);        
        Account acc1 = AccountTestFactory.buildAccount('Test Account1') ;
        acclist.add(acc1);     
        Account acc2 = AccountTestFactory.buildAccount('Test Account2') ;
        acclist.add(acc2);
		insert acclist;        
                
        //Create Contact
        Contact c = testUtil.createContact(acc.id,'Test','101 user');
        conlist.add(c);
        Contact c1 = testUtil.createContact(acc2.id,'Test','102 user');
        conlist.add(c1);
        insert conlist;
        
    }
    

    @isTest
    public static void testIsRelated(){  
        
        //create opportunity
        Contact con = [SELECT Id FROM Contact WHERE Name='Test 101 User' LIMIT 1];       
        Contact con1 = [SELECT Id FROM Contact WHERE Name='Test 102 User' LIMIT 1];
        Account acct = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Account acct1 = [SELECT Id FROM Account WHERE Name='Test Account1' LIMIT 1];
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acct);
        opp.Customer_Key_Contact__c = con.id;
        
        test.startTest();
        insert opp;
        
        //create OpportunityContactRole
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.id;
        ocr.OpportunityId = opp.id;
        
        insert ocr;
        boolean checkval = ContactAccountRelationCheck.isRelated(acct1.id,con.id);
        system.assertEquals(checkval ,True);
        
        List<OpportunityContactRole>  ocrList = [SELECT Id,ContactId,OpportunityId FROM OpportunityContactRole WHERE ContactId =: con.id LIMIT 1];
        ocrList[0].contactId = con1.id;
        update ocrlist;
        test.stopTest();
    }
    
    /*  Test Method for OCR insert exception coverage*/
    @isTest
    public static void testInsertError(){  
        try{
            
            //create opportunity
            Account acct1 = [SELECT Id FROM Account WHERE Name='Test Account1' LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE Name='Test 101 User' LIMIT 1]; 
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acct1);
            opp.Customer_Key_Contact__c = con.id;
            insert opp;
            
            test.stopTest();
        } catch(Exception e)
            
        {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            
            System.AssertEquals(expectedExceptionThrown, true);
            
        } 
    }
    
    /*  Test Method for OCR update exception coverage*/
    @isTest
    public static void testUpdateError(){  
        try{
            
            //create opportunity
            Account acct = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE Name='Test 101 User' LIMIT 1];     
            Contact con1 = [SELECT Id FROM Contact WHERE Name='Test 102 User' LIMIT 1];
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acct);
            opp.Customer_Key_Contact__c = con.id;
            
            Disabled_Triggers__c disabledTriggersUser = new Disabled_Triggers__c();
            disabledTriggersUser.SetupOwnerId = UserInfo.getUserId();
            disabledTriggersUser.Trigger_Name_List1__c = 'OpportunityContactRoleTrigger';
            disabledTriggersUser.Trigger_Name_List1__c = 'OpportunityContactRoleTrigger';
            insert disabledTriggersUser;
            
            test.startTest();
            insert opp;
            
            boolean checkval = ContactAccountRelationCheck.isRelated(acct.id,con.id);
            system.assertEquals(checkval ,True);
            
            List<OpportunityContactRole>  ocrList = [SELECT Id,ContactId,OpportunityId FROM OpportunityContactRole WHERE OpportunityId =: opp.id LIMIT 1];
            ocrList[0].contactId = con1.id;
            update ocrlist;
            test.stopTest();
        } 
        catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            
            System.AssertEquals(expectedExceptionThrown, true);
            
        } 
    }
    
}