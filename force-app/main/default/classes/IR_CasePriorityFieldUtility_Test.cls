@isTest
private class IR_CasePriorityFieldUtility_Test {
    
    static testMethod void priorityAutomation_PositiveScenario(){   
        Account acc=new Account(name='Acme');
        insert acc;
        
        Case testCase1= new Case(Subject='Test',
                                 AccountId=acc.id,
                                 IR_Issue_Risk_Type__c='Internal',
                                 IR_Category__c='Billing',
                                 IR_Impact__c='Customer Service And Operations',
                                 IR_Issue_Assessment__c='High',
                                 IR_Likelihood_to_Occur__c='Likely',
                                 Description='Test');
        testCase1.RecordTypeId=Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('IR_Issue_Register').getRecordTypeId();
        
        Test.startTest();
        
        // Insert case
        insert testCase1;
 
        Test.stopTest();
 
        // Retrieve the new case
        testCase1 = [SELECT Priority FROM Case WHERE Id =:testCase1.Id];
        System.assertEquals('High', testCase1.Priority);
    }
    
    // this covers negative scenario of the use case
    static testMethod void priorityAutomation_NegativeScenario(){   
        Account acc=new Account(name='Acme');
        insert acc;
        
        Case testCase1= new Case(Subject='Test',
                                 AccountId=acc.id,
                                 IR_Issue_Risk_Type__c='Internal',
                                 IR_Category__c='Billing',
                                 IR_Impact__c='Customer Service And Operations',
                                 IR_Issue_Assessment__c='High',
                                 IR_Likelihood_to_Occur__c='Almost Certain',
                                 Description='Test');
        testCase1.RecordTypeId=Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('IR_Issue_Register').getRecordTypeId();
        
        Test.startTest();
        
        // Insert case
        insert testCase1;
 
        Test.stopTest();
 
        // Retrieve the new case
        testCase1 = [SELECT Priority FROM Case WHERE Id =:testCase1.Id];
        System.assertNotEquals(testCase1.Priority,'Low');
    }
    
    static testMethod void priorityAutomation_BulkificationScenario() { 
        
        List<Case> listIR_Case=new List<Case>();
        
        for(Integer i=0;i<200;i++){
            case testCase=new Case();
            testCase.RecordTypeId=Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('IR_Issue_Register').getRecordTypeId();
            testCase.Subject='Test'+i;
            testCase.IR_Issue_Risk_Type__c='Internal';
            testCase.IR_Category__c='Billing';
            testCase.IR_Impact__c='Customer Service And Operations';
            testCase.IR_Issue_Assessment__c='Low';
            testCase.IR_Likelihood_to_Occur__c='Likely';
            testCase.Description='Test';
            listIR_Case.add(testCase);
        }
        
        Test.startTest();
        
        // Insert caseList
        insert listIR_Case;
 
        Test.stopTest();
 
        // Retrieve new cases
        List<Case> caseList=new List<Case>();
        for(Case c:[SELECT Id,Priority FROM Case LIMIT 200]){
            caseList.add(c);
        }
        
        //Check for the results
        for(Case c:caseList){
        System.assertEquals('Low', c.Priority);
        System.assertNotEquals(c.Priority,'High');
        }
    }
    static testMethod void priorityAutomation_ProfileBasedScenario(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;     
        Profile profileId = [SELECT Id FROM Profile Where Name ='Sales - Enterprise' LIMIT 1];
        User user = new User(LastName = 'xxx',
                           FirstName='xxx',
                           Alias = 'dummy',
                           Email = 'xxx@test.com',
                           Username = uniqueName+'xxx@test.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                           phone='+121231231234'
                           );
        insert user;
        System.runAs(user){        
        Case testCase1= new Case(Subject='Test',
                                 IR_Issue_Risk_Type__c='Internal',
                                 IR_Category__c='Billing',
                                 IR_Impact__c='Customer Service And Operations',
                                 IR_Issue_Assessment__c='High',
                                 IR_Likelihood_to_Occur__c='Possible',
                                 Description='Test');
        testCase1.RecordTypeId=Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('IR_Issue_Register').getRecordTypeId();
        
        Test.startTest();
        
        // Insert case
        insert testCase1;
 
        Test.stopTest();
 
        // Retrieve the new case
        testCase1 = [SELECT Priority FROM Case WHERE Id =:testCase1.Id];
        System.assertEquals('Medium',testCase1.Priority);
        System.assertNotEquals(testCase1.Priority,'Low');
        }
    }
}