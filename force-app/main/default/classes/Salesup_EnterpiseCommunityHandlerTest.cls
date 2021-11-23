/*****************************************************************************
@Author: Chandrakant Wani
@CreateDate: 16-July-2020
@Description: This Test class is for Salesup_EnterpiseCommunityHandler class.
@References
Story : P2OB-8340
*******************************************************************************/

@isTest
public class Salesup_EnterpiseCommunityHandlerTest {

    /**
    * This method is used to test getCaseNumber method.
    * @Author: Chandrakant
    * @Date: 16-July-2020
    */
    @isTest
    public static void getCaseNumberTest(){

        List<Case> lstCase = new List<Case>();        
        for(integer i=0;i<3;i++)
        {lstCase.add(new Case(Subject='Community Case '+i,
                Status = 'New',
                Origin = 'Telstra.com')           
            );
        }
        insert lstCase;        
        Case newCase = [Select Id, caseNumber From Case Limit 1];
        List<ID> caseIdlist = new List<ID>();
        caseIdlist.add(newCase.Id);

        Test.startTest(); 
        List<String> caseNumberList= Salesup_EnterpiseCommunityHandler.getCaseNumber(caseIdlist);
        System.assertEquals(newCase.caseNumber, caseNumberList[0]);
        Test.stopTest();
    }
}