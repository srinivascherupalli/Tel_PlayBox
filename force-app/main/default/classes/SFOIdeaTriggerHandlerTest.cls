/****************************************************************************
@Name: SFOIdeaTriggerHandlerTest.
@Author: SFO/ Sri
@CreateDate: 22/10/2019
@Sprint : 19.14[P2OB-3302]
@Description: This Class is for test coverage SFOIdeaTriggerHandler - P2OB-3302
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*****************************************************************************/
@isTest
public class SFOIdeaTriggerHandlerTest {
    /****************************************************************************
    @Method Name: sfoIdeaTriggerHandlerUnitTest
    @Author: SFO/Sri
    @Sprint : 19.14[P2OB-3302]
    @CreateDate: 22/10/2019
    @Description: This Method is est coverage SFOIdeaTriggerHandler.handleAfterInsert method
    ******************************************************************************/      
    public static testMethod void sfoIdeaTriggerHandlerUnitTest(){        
        Test.startTest();
        Idea ide =new Idea();
        ide.Title = 'TestIdea';
        ide.Categories = 'Account';
        String cname=Label.Community_Name;
        Community[] com = [SELECT Id FROM Community WHERE Name = :cname LIMIT 1];        
        ide.CommunityId = com[0].Id;
        ide.Body = 'TestIdea';
        insert ide;
        system.assertEquals(ide.Body,'TestIdea');
        Test.stopTest();
    }    
}