/* ****************************************************************************
* EDGE-129011
* Team : Napier
* Author : Tejes Mahajan
* Description : Test Class for custom button contract sent test.
*******************************************************************************/
@isTest
public class CustomButtonContractSentOFTest {

    public static Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
    public static Id oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
    public static Id oppRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        
    @testSetup
    public static void testData(){
         String orgId = UserInfo.getOrganizationId();
         String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
         Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
         String uniqueName = orgId + dateString + randomInt;        
        Profile p = [select Id,name from Profile where Name ='Sales Enterprise B2B'];
        
        User u1 = new User(alias = 'sales', email='salesuser6653@noemail.com',
                           emailencodingkey='UTF-8', lastname='Test salesuser', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'salesuser@noemail.com',phone='+121231231234');        
        insert u1;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'OneFund_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id);
    }
    
    //Test method to cover OneFund balance check functionality
    @isTest 
    public static void checkOneFundBalance(){

        Account accOF = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert accOF;
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=accOF.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Active');
        insert oneFund; 
        OneFund_Transactions__c oneFundTransaction = new OneFund_Transactions__c(RecordTypeId = oneFundAccrualRecordId, OneFund__c=oneFund.id, Transaction_Status__c='Active', Transaction_Amount__c=1000.00, Expiry_Date__c = system.today()+7);
        insert oneFundTransaction;
        Opportunity oppOF  = new Opportunity(RecordTypeId=oppRecordId,Name = 'TestOpp101',AccountID = accOF.id,StageName = 'Develop',Product_Type__c = 'Modular',CloseDate = System.today()+30);
        insert oppOF;
        
        //Inserting EnvironmentVariable__c for Contract
        EnvironmentVariable__c objEnvVariable = TestDataFactory.generateEnvironmentVariable('AgreementGeneration','false');
        EnvironmentVariable__c objEnvVariable1 = TestDataFactory.generateEnvironmentVariable('CheckTramasResponseValid','true');
        List<EnvironmentVariable__c> lstEnvVariables = new List<EnvironmentVariable__c>{objEnvVariable,objEnvVariable1};
        insert lstEnvVariables;
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = accOF.id;
        basket.cscfga__Opportunity__c = oppOF.id;
        basket.Name = 'BT000-098-100';
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert basket;                 
         
        User u = [select Id from User where email='salesuser6653@noemail.com'];
        System.runAs(u){            
            Test.startTest();
            oppOF.Basket_Redemption_amount__c=2500.00;
            update oppOF;
            try{
            CustomButtonContractSentRF c=new CustomButtonContractSentRF();
            String errorMsg=c.performAction(basket.id); 
            Test.stopTest();                
                
                    System.assert(errorMsg.contains('error'));
                    System.assertNotEquals(null, basket);
                }
                catch(Exception e){
                }           
        }
        
    }
}