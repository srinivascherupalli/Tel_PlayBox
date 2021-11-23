/**
     Description :  P2OB-6525 Test class for controller GenericNewController 
     Author      :  Ritika Jaiswal, Team Hawaii 
     Created Date:  15 May 2020 
     Jira        :  P2OB-6525
 **/
@isTest
public class GenericNewControllerTest {
    
    static testMethod void genericfetchLookUpValues_Test(){
        String flowName= '';
        Test.startTest();
        flowName = GenericNewController.getCmpNameFromMetadata('PartnerFundClaim','new','');
        Test.stopTest();
        System.assert(!String.isEmpty(flowName));
    }
}