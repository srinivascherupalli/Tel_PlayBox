/****************************************************************************
@Name: SFOEventTriggerHandlerTest.
@Author: SFO/Vamshi
@CreateDate: 09/04/2020
@Sprint : 20.05[P2OB-5475]
@Description: This Class is for test coverage SFOEventTriggerHandler - P2OB-5475
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*****************************************************************************/
@isTest
public class SFOEventTriggerHandlerTest {
    /****************************************************************************
    @Method Name: sfoEventTriggerHandlerUnitTest
    @Author: SFO/Vamshi
    @Sprint : 20.05[P2OB-5475]
    @CreateDate: 09/04/2020
    @Description: This Method is est coverage SFOEventTriggerHandler.handleBeforeInsert method
    ******************************************************************************/      
    public static testMethod void sfoEventTriggerHandlerUnitTest(){        
        Test.startTest();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Event> eventList = new List<Event>();
        
        for(integer i=0; i<20 ; i++){
            Account accRecord = TestUtil.createAccount('Test Account' + i);
            accList.add(accRecord);
        }
        insert accList;
        
        for(Integer y=0; y<20; y++){
            Contact conRecord = TestUtil.createContact(accList[y].id ,'test', 'contact' + y);
            conList.add(conRecord);
        }
        insert conList;
        
        for(Integer z=0; z<20; z++){
            Event eventRecord = new Event();
            eventRecord.contact__c = conList[z].Id;
        	eventRecord.whatId = accList[z].Id;
			eventRecord.DurationInMinutes = 10;
			eventRecord.ActivityDateTime = system.now();
            eventList.add(eventRecord);
        }
        insert eventList;
        
        system.assertEquals(eventList[0].whatId, accList[0].Id);
        Test.stopTest();
    }    
        
}