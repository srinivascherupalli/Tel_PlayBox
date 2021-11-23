/*****************************************************************************
@Author: Sandeep Soni
@CreateDate: 30-July-2019
@Description: This Test class contains Test methods for salesup_ThankYouScreenController class.
@References
Story:EDGE-98449

Version    Author            Last Modified Date     Description     
v1.1       Vivian (Hawaii)   11 Oct 2019            Updated method parameters
*******************************************************************************/
@isTest(seeAllData=False)
public class salesup_ThankYouScreenControllerTest {


    /**
    * This method is used to create the cases as required in the test methods.
    * @Author: Sandeep Soni
    * @Date: 30-July-2019
    */
    @testSetup public static void DataSetup() {

        System.runAs(new User(Id=UserInfo.getUserId())){
            Profile ServiceEntB2B = [Select Id From Profile Where Name = 'Service Enterprise – B2B' LIMIT 1];

            List<User> lstSalesCertUsers = new List<User>();
            User CertAgent = new User(
                ProfileId = ServiceEntB2B.Id,
                LastName = 'Requester',
                Email = 'test@team.telstra.com',
                Username = 'test@team1.telstra.com' + System.currentTimeMillis(),
                CompanyName = 'Telstra',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                phone='+121231231234'
            );

            lstSalesCertUsers.add(CertAgent);
            insert lstSalesCertUsers;

        }
        opportunity opp = soc_TestUtility.CreateOpportunity();
        Account acc = soc_TestUtility.CreateAccount();

        Integer NumberOfCases = 20;
        List<Case> CasesOfCertitude = new List<Case>();
        for(Integer i=0;i<NumberOfCases;i++){
            Case CaseOfCertitude = new Case();
            CaseOfCertitude.Subject = 'Pending Case : '+ i;
            CaseOfCertitude.Description = 'sdjshdks : '+ i;
            CaseOfCertitude.OpportunityId__c = opp.id;
            CaseOfCertitude.AccountId = acc.id;
            CaseOfCertitude.Status = 'New';
            CaseOfCertitude.Requestor__c = Userinfo.getUserId();
            CaseOfCertitude.salesup_Support_Type__c = 'Feasibility Request';
            CaseOfCertitude.srvsup_Categories__c = 'Feasibility';
            CaseOfCertitude.salesup_Work_Required__c = 'Wideband';
            CaseOfCertitude.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Support').getRecordTypeId();
            CasesOfCertitude.add(CaseOfCertitude);
        }
        insert CasesOfCertitude;
    }

    /**
    * This method is used (for positive test case scenario) to test getCaseDetails method.
    * @Author: Sandeep
    * @Date: 30-July-2019
    */
    @isTest static void getCaseDetailsTestPositive(){
        List<Case> lstCases = new List<Case>([Select Id,OwnerId,CaseNumber,AccountId,Requestor__c,RecordTypeId,ContactId From Case]);
        String[] caseArr = new String[1];
        caseArr[0] = lstCases[0].id;
        if(lstCases!=null){
            String jsonString = '[{"salesup_Product_Details__c":null,"salesup_Site_Address__c":"test","salesup_Site_Contact__c":"'+lstCases.get(0).ContactId+'","salesup_Technical_Contact__c":"","salesup_Billing_Account_Number__c":"3","Network_FNN__c":null,"soc_Customer_Required_Date_CRD__c":null,"salesup_Products__c":["DOT"],"salesup_Flow_Data__c":"FLOWDATA","Origin":"Internal","Subject":"dfg  -  New Order","OpportunityId__c":"","salesup_No_of_sites_or_services__c":3,"Description":"dfg","AccountId":"'+lstCases.get(0).AccountId+'","RecordTypeId":"'+lstCases.get(0).RecordTypeId+'","srvsup_Categories__c":"Ordering","salesup_Work_Required__c":"New Order","salesup_Support_Type__c":"Non SFD Order Request","Requestor__c":"'+lstCases.get(0).Requestor__c+'","soc_SFD_Offshore_Restricted__c":true,"salesup_Portfolio_Code__c":"22334","Id":"'+lstCases.get(0).id+'"}]';
            Test.startTest();
            List<Case> lstCase = salesup_ThankYouScreenController.getCaseDetails(jsonString, caseArr, true); // v1.1
            system.assert(lstCase != null);
            System.assert(lstCase.get(0).CaseNumber!=null);
            Test.stopTest();
        }
       }
    /**
    * This method is used(for negative test case scenario) to test getCaseDetails method.
    * @Author: Sandeep
    * @Date: 30-July-2019
    */
    @isTest static void getCaseDetailsTestNegative(){
        List<Case> lstCases = new List<Case>([Select Id,OwnerId,CaseNumber,AccountId,Requestor__c,RecordTypeId,ContactId From Case]);
        if(lstCases!=null){
            String jsonString = null;
            Test.startTest();
            List<Case> lstCase = salesup_ThankYouScreenController.getCaseDetails(jsonString, null);
            salesup_ThankYouScreenController.returnBaseUrl(); // v1.1
            system.assert(lstCase.size()<1);
            salesup_ThankYouScreenController.returnBaseUrl();
            Test.stopTest();
        }
       }
}