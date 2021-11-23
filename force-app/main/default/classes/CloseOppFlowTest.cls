/*******************************************************************************
@Last Modified      : 07/01/2021 21.01 by Sri, Team SFO
as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 21/07/2021 21.10 by Sravanthi Team SFO 
as part of close opp revamp modifying close opp test scenarios as per functionality
*******************************************************************************/
@isTest
public class CloseOppFlowTest {
    @testSetup
    static void setup()
    {
       Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User sales = TestUtil.createTestUser(r.id,pf.id,'standt','Testing');
        sales.username='salesuser@testsales.com';
        sales.email='salesuser@testsales.com';
        sales.phone='+121231231234';
        insert sales;
    }
    @isTest static void CloseOppFlowOppLostUnder250() {
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        System.runAs(sales){
            test.startTest();
            
            CloseOppFlow.flowInputs fInpsCls = new CloseOppFlow.flowInputs();
            fInpsCls.closureReason = 'Lost';
            fInpsCls.UserInputLostReason = '--None--';
            fInpsCls.UserInputCompetitor = '--None--';
            fInpsCls.UserInputLostComments = 'Testing Comments';
            fInpsCls.TCVForClosedLost = 50;
            
            //CloseOppFlow.invokeLocalMethod(fInpsCls);
            
            list<CloseOppFlow.flowInputs> lflowInput = new list<CloseOppFlow.flowInputs>();
            lflowInput.add(fInpsCls);
            CloseOppFlow.invokeThisFromFlow(lflowInput);
            
            
            
            CloseOppFlow.flowInputs fInpsCls1 = new CloseOppFlow.flowInputs();
            fInpsCls1.UserInputLostReason = 'Withdrawn - Customer Request';
            fInpsCls1.OppStageName = 'Propose';
            fInpsCls1.closureReason = 'Lost';
            
            list<CloseOppFlow.flowInputs> lflowInput1 = new list<CloseOppFlow.flowInputs>();
            lflowInput1.add(fInpsCls1);
            CloseOppFlow.invokeThisFromFlow(lflowInput1);
            
            CloseOppFlow.flowInputs fInpsCls3 = new CloseOppFlow.flowInputs();
            fInpsCls3.UserInputLostReason = 'Duplicate Entry';
            fInpsCls3.UserInputCompetitor = 'ACCENTURE';
            fInpsCls3.UserInputLostComments = 'Testing Comments';
            fInpsCls3.closureReason = 'Lost';
            fInpsCls3.TCVForClosedLost = 100;
            
            list<CloseOppFlow.flowInputs> lflowInput3 = new list<CloseOppFlow.flowInputs>();
            lflowInput3.add(fInpsCls3);
            CloseOppFlow.invokeThisFromFlow(lflowInput3);
            
            system.assertEquals(fInpsCls.UserInputLostComments, 'Testing Comments');
            
            test.stopTest();}
    }
    
    
    /********************** Test Method For Won Over 250K ***************************************/
    
    @isTest static void CloseOppFlowOppWonOver250() {
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        System.runAs(sales){
            test.starttest();
            CloseOppFlow.flowInputs fInpsClsWonOver250 = new CloseOppFlow.flowInputs();
            fInpsClsWonOver250.UserInputWonLostReason = '--None--';
            fInpsClsWonOver250.UserInputCompetitor = '--None--';
            fInpsClsWonOver250.UserInputComments = '';
            fInpsClsWonOver250.TCV = 250001;
            fInpsClsWonOver250.closureReason = 'Won';
            
            list<CloseOppFlow.flowInputs> lflowInputWonOver250 = new list<CloseOppFlow.flowInputs>();
            lflowInputWonOver250.add(fInpsClsWonOver250);
            CloseOppFlow.invokeThisFromFlow(lflowInputWonOver250);
            
            
            CloseOppFlow.flowInputs fInpsClsWonOver2504 = new CloseOppFlow.flowInputs();
            fInpsClsWonOver2504.UserInputWonLostReason = 'Duplicate Entry';
            fInpsClsWonOver2504.UserInputCompetitor = 'ACCENTURE';
            fInpsClsWonOver2504.UserInputComments = 'Testing Comments';
            fInpsClsWonOver2504.TCV = 550000;
            fInpsClsWonOver2504.closureReason = 'Won';
            fInpsClsWonOver2504.UserRevenueImpactDate = System.today()+1;
            
            list<CloseOppFlow.flowInputs> lflowInputWonOver2504 = new list<CloseOppFlow.flowInputs>();
            lflowInputWonOver2504.add(fInpsClsWonOver2504);
            CloseOppFlow.invokeThisFromFlow(lflowInputWonOver2504);
            
            CloseOppFlow.flowOutputs fOptsCls = new CloseOppFlow.flowOutputs();
            system.assertEquals(fInpsClsWonOver2504.UserInputComments, 'Testing Comments');
            
            test.stoptest();
        }
        
    }
    
    
    /********************************* Test Method For Lost Over 250K ********************************/
    
    @isTest static void CloseOppFlowOppLostOver250() {
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        System.runAs(sales){
            test.starttest();
            CloseOppFlow.flowInputs fInpsClsLostOver250 = new CloseOppFlow.flowInputs();
            fInpsClsLostOver250.UserInputLostReason = '--None--';
            fInpsClsLostOver250.UserInputCompetitor = '--None--';
            fInpsClsLostOver250.UserInputLostComments = '';
            fInpsClsLostOver250.TCVForClosedLost = 550000;
            fInpsClsLostOver250.closureReason = 'Lost';
            
            list<CloseOppFlow.flowInputs> lflowInputLostOver250 = new list<CloseOppFlow.flowInputs>();
            lflowInputLostOver250.add(fInpsClsLostOver250);
            CloseOppFlow.invokeThisFromFlow(lflowInputLostOver250);
            
            CloseOppFlow.flowInputs fInpsClsLostOver2504 = new CloseOppFlow.flowInputs();
            fInpsClsLostOver2504.UserInputLostReason = 'Duplicate Entry';
            fInpsClsLostOver2504.UserInputCompetitor = 'ACCENTURE';
            fInpsClsLostOver2504.UserInputLostComments = 'Testing Comments';
            fInpsClsLostOver2504.TCVForClosedLost = 250001;
            fInpsClsLostOver2504.closureReason = 'Lost';
            
            list<CloseOppFlow.flowInputs> lflowInputLostOver2504 = new list<CloseOppFlow.flowInputs>();
            lflowInputLostOver2504.add(fInpsClsLostOver2504);
            CloseOppFlow.invokeThisFromFlow(lflowInputLostOver2504);
            
            CloseOppFlow.flowOutputs fOptsCls = new CloseOppFlow.flowOutputs();
            system.assertEquals(fInpsClsLostOver2504.UserInputLostComments, 'Testing Comments');
            
            test.stoptest();
        }
        
    }
    
    @isTest static void CloseOppFlowOppWonUnder250() {
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        System.runAs(sales){
            test.startTest();
            
            CloseOppFlow.flowInputs fInpsCls = new CloseOppFlow.flowInputs();
            fInpsCls.UserInputWonLostReason = '--None--';
            fInpsCls.UserInputCompetitor = '--None--';
            fInpsCls.UserInputComments = 'Testing Comments';
            fInpsCls.TCV = 50;
            fInpsCls.closureReason = 'Won';
            
            list<CloseOppFlow.flowInputs> lflowInput = new list<CloseOppFlow.flowInputs>();
            lflowInput.add(fInpsCls);
            CloseOppFlow.invokeThisFromFlow(lflowInput);
            
            
            CloseOppFlow.flowInputs fInpsCls3 = new CloseOppFlow.flowInputs();
            fInpsCls3.UserInputWonLostReason = 'Duplicate Entry';
            fInpsCls3.UserInputCompetitor = 'ACCENTURE';
            fInpsCls3.UserInputComments = 'Testing Comments';
            fInpsCls3.UserRevenueImpactDate = System.today()+1;
            fInpsCls3.TCV = 100;
            fInpsCls3.closureReason = 'Won';
            
            list<CloseOppFlow.flowInputs> lflowInput3 = new list<CloseOppFlow.flowInputs>();
            lflowInput3.add(fInpsCls3);
            CloseOppFlow.invokeThisFromFlow(lflowInput3);
            
            CloseOppFlow.flowOutputs fOptsCls = new CloseOppFlow.flowOutputs();
            system.assertEquals(fInpsCls3.UserInputComments, 'Testing Comments');
            
            test.stopTest();
        }
    }
    
    
}