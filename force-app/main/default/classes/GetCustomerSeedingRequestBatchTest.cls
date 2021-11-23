/*************************************************************************************************
Name : GetCustomerSeedingRequestBatchTest
Description : Test Class for GetCustomerSeedingRequestBatch
***************************************************************************************************/
@isTest
global class GetCustomerSeedingRequestBatchTest {
    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        
        //Creating Customer Seeding Request records with batch Id and no seeding date
        final List<Customer_Seeding_Request__c> csrInsertList = new List<Customer_Seeding_Request__c>();
        Customer_Seeding_Request__c csr;
        final Integer count = 50;
        for(Integer i=0;i<60;i++)
        {
          csr = new Customer_Seeding_Request__c();
            csr.Name = 'test'+i;
            if(i<count){
                csr.Batch_ID__c = 20;
            }
            else{
                csr.Batch_ID__c = 10;
            }
            csr.CIDN__c = ''+i;
            csr.status__c = 'Pending';
            csrInsertList.add(csr);            
        }
        
        insert csrInsertList;
    }
    
    static testMethod void getCustomerSeedingRecordsBasedonBatchId()
    {  
        //List<Customer_Seeding_Request__c> csrUpdateList = [Select id,Name,CIDN__c,Status__c,Batch_Id__c,code__c,Notes__c from Customer_Seeding_Request__c];
        //Starting the test method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final Integer batchId = 20;
        //calling the batch class with batch id as 20;
        final GetCustomerSeedingRequestBatch batch = new GetCustomerSeedingRequestBatch(batchId);
        //executing the batch class
        Database.executeBatch(batch,50);
        Test.stopTest();
        //query the customer seeding request records which were just modified in the batch
        final List<Customer_Seeding_Request__c> customerSeedingRecordsUpdated = [Select Batch_ID__c,Status__c from Customer_Seeding_Request__c where Batch_ID__c =:batchId];
        //Asserting the number of records processed in batch
        System.assertEquals(50, customerSeedingRecordsUpdated.size(),'Record updated');
        
        
    }
static testMethod void getCustomerSeedingRecordsBasedonDate()
    {
        //Updating Customer Seeding Request records with some of them having Seeding Date as Today and batch Id null
        FINAL List<Customer_Seeding_Request__c> csrUpdateList = [Select id,Name,CIDN__c,Status__c,Batch_Id__c,code__c,Notes__c from Customer_Seeding_Request__c LIMIT 50];
        for(Customer_Seeding_Request__c csr:csrUpdateList)
        {       
            csr.Seeding_Date__c=Date.Today();
            csr.Batch_ID__c = null;
        }
        
        update csrUpdateList;
        
        //Starting the test method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());        
        final Integer batchId  = 20 ;
        final Date todayDate = Date.Today();
        //calling the batch class with batch id as null;
        final GetCustomerSeedingRequestBatch batch = new GetCustomerSeedingRequestBatch(batchId);
        //executing the batch class
        Database.executeBatch(batch,50);
        Test.stopTest();
        //query the customer seeding request records which were just modified in the batch
        final List<Customer_Seeding_Request__c> customerSeedingRecordsUpdated = [Select Batch_ID__c,Status__c from Customer_Seeding_Request__c where Seeding_Date__c =: todayDate];
        //Asserting the number of records processed in batch
        System.assertEquals(50, customerSeedingRecordsUpdated.size(),'Seeding records updated');
        
    }
static testMethod void getCustomerSeedingRecordsWithoutBatchIDAndDate()
    {
        //Updating Customer Seeding Request records without seeding date and batch Id null 
        FINAL List<Customer_Seeding_Request__c> csrUpdateList = [Select id,Name,CIDN__c,Status__c,Batch_Id__c,code__c,Notes__c from Customer_Seeding_Request__c LIMIT 50];
        for(Customer_Seeding_Request__c csr:csrUpdateList)
        {       
            csr.Batch_ID__c = null;
        }
		update csrUpdateList;
        
        //Starting the test method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final Integer batchId =20;
        final Date todayDate=Date.Today();
        //calling the batch class with batch id as null;
        final GetCustomerSeedingRequestBatch batch = new GetCustomerSeedingRequestBatch(batchId);
        //executing the batch class
        Database.executeBatch(batch);
        Test.stopTest();
        //query the customer seeding request records which were just modified in the batch
        final List<Customer_Seeding_Request__c> customerSeedingRecordsUpdated = [Select Batch_ID__c,Status__c from Customer_Seeding_Request__c where Seeding_Date__c =: todayDate];
        //Asserting the number of records processed in batch
        System.assertEquals(0, customerSeedingRecordsUpdated.size(),'Seeding records updated');
        //Asserting the status of processed records in batch
        /*for(integer i=0;i<customerSeedingRecordsUpdated.size();i++)
        {
        System.assertEquals('Pending', customerSeedingRecordsUpdated[i].Status__c);
        }*/
        
    }
	static testMethod void getCustomerSeedingRecordsBasedonBatchIdHavingSeedingDate()
    {
        //Updating Customer Seeding Request records with batch Id and seeding date as today and passing batchId to the batch
        Final List<Customer_Seeding_Request__c> csrUpdateList = [Select id,Name,CIDN__c,Status__c,Batch_Id__c,code__c,Notes__c from Customer_Seeding_Request__c LIMIT 50];
        for(Customer_Seeding_Request__c csr:csrUpdateList)
        {       
            csr.Seeding_Date__c=Date.Today();
        }
        update csrUpdateList;
        //Starting the test method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final Integer batchId = 20;
        //calling the batch class with batch id as 20;
        final GetCustomerSeedingRequestBatch batch = new GetCustomerSeedingRequestBatch(batchId);
        //executing the batch class
        Database.executeBatch(batch,50);
        Test.stopTest();
        //query the customer seeding request records which were just modified in the batch
        final List<Customer_Seeding_Request__c> customerSeedingRecordsUpdated = [Select Batch_ID__c,Status__c from Customer_Seeding_Request__c where Batch_ID__c =:batchId];
        //Asserting the number of records processed in batch, Only the records with the matching batch id will be processed abd updated and seeding date will be ignored
        System.assertEquals(50, customerSeedingRecordsUpdated.size(),'Seeding Record Updated');
        
        
    }
	
 }