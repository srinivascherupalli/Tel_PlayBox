/****************************************************************************
@Name: GOEDCardControllerTest.
@Author: Einstein Team(Khazan)
@CreateDate:
@Description: P2OB-1653 to see the Opportunity Scoring against each Opportunity
********************************************************************************/

@isTest
public class GOEDCardControllerTest {

    
    static testmethod void positiveTest(){
        OpportunityTestFactory.createDataforTest();
		
		Opportunity oppRecord = [SELECT Id,Name FROM Opportunity LIMIT 1];
        system.assertEquals(oppRecord.Name, 'TestOpp');
    	Map<String, String> parameterMap = new Map<String, String>();
        parameterMap.put('recId',oppRecord.Id);
        parameterMap.put('outcomeField','Opportunity_Score_Pilot__c');
        parameterMap.put('explanationField','Pilot_Score_Reasons__c');
        parameterMap.put('recommendationField','Pilot_Score_Recommendations__c');
        
        GOEDCardController.getEDInfo(JSON.serialize(parameterMap));
        
    }
    
    static testmethod void negativeTest(){
        OpportunityTestFactory.createDataforTest();
		
		Opportunity oppRecord = [SELECT Id,Name FROM Opportunity LIMIT 1];
        system.assertEquals(oppRecord.Name, 'TestOpp');
    	Map<String, String> parameterMap = new Map<String, String>();
        parameterMap.put('recId',oppRecord.Id);
        parameterMap.put('outcomeField','Non_existent_1__c');
        parameterMap.put('explanationField','Non_existent_2__c');
        parameterMap.put('recommendationField','Non_existent_3__c');
        
        GOEDCardController.getEDInfo(JSON.serialize(parameterMap));
        
    }
    
}