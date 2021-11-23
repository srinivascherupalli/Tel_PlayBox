/*
@ DEVELOPER : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : Test class for SearchAddressBatch class
@ DIGI-13813 
@ DIGI-28079 :- amended SearchAddressBatch Constructor
*/
@isTest 
public class SearchAddressBatchTest {

	@testSetup
	public static void setup(){
	Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;
   List<Orchestration_Technical__c> orchestrationTechList=new List<Orchestration_Technical__c>();
    for(Integer i=0;i<3;i++){
        Orchestration_Technical__c orchTechObj=new Orchestration_Technical__c();
        orchTechObj.External_Id_1__c=acc.id;
        orchTechObj.Field_3__c='New';
        if(i==0){
        orchTechObj.Field_4__c='262619086';
        }
        else if(i==1){
        orchTechObj.Field_4__c='26261';
        }
        else{
        orchTechObj.Field_4__c=' ';
        }
        orchTechObj.Field_2__c='Level 11 35 Collins Street Melbourne VIC 3000';
        orchTechObj.Field_1__c='Test SIteName';
        orchTechObj.Field_7__c='FALSE';
        orchestrationTechList.add(orchTechObj);
    }
    insert orchestrationTechList;

        // Adding for DIGI-28079
        ApplicationLog__c application = new ApplicationLog__c();
        application.Reference_Info__c = 'BulkSiteUploadHandler';
        application.Request_Message__c = 'Bulk_Site_Upload_';
        application.Message__c = 'File Uploaded';
        insert application;
		
	}
    //Method to validate success response with AdborId 
    public static testMethod void searchByAdborId(){
        Orchestration_Technical__c orchTechObj= [SELECT External_Id_1__c FROM Orchestration_Technical__c WHERE Field_4__c='262619086'];        
		// Added for DIGI-28079
        ApplicationLog__c application = [Select Id from ApplicationLog__c limit 1];Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Adbor'));
        Test.startTest();
        // Added for DIGI-28079
        // amended for DIGI-28079
        SearchAddressBatch addressBatchObj=new SearchAddressBatch(orchTechObj.External_Id_1__c,application.Id,System.now());
        Database.executebatch(addressBatchObj);
        Test.stopTest();
        System.assertEquals(addressBatchObj!=null,true);
    }
    //Method to validate success response with Full Address search 
    public static testMethod void searchByFullAddress(){
        // Added for DIGI-28079
        ApplicationLog__c application = [Select Id from ApplicationLog__c limit 1];
		Orchestration_Technical__c orchTechObj= [SELECT External_Id_1__c FROM Orchestration_Technical__c WHERE Field_4__c=''];		
		Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('AutoResponse_success'));
        Test.startTest();
        // amended for DIGI-28079
        SearchAddressBatch addressBatchObj=new SearchAddressBatch(orchTechObj.External_Id_1__c,application.Id,System.now());
        Database.executebatch(addressBatchObj);
        Test.stopTest();
        System.assertEquals(addressBatchObj!=null,true);    
	}
    //Method to validate Not Found address response with AdborId
    public static testMethod void searchByInvalidAdborId(){

        Orchestration_Technical__c orchTechObj= [SELECT External_Id_1__c FROM Orchestration_Technical__c WHERE Field_4__c='26261'];
		// Added for DIGI-28079
        ApplicationLog__c application = [Select Id from ApplicationLog__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('NotFoundAddress'));
        Test.startTest();
        // amended for DIGI-28079
        SearchAddressBatch addressBatchObj=new SearchAddressBatch(orchTechObj.External_Id_1__c,application.Id,System.now());
        Database.executebatch(addressBatchObj);
        Test.stopTest();
        System.assertEquals(addressBatchObj!=null,true);    
	}
    //Method to validate else block full address response with AdborId
    public static testMethod void validateFullAddressSearch(){	

		Orchestration_Technical__c orchTechObj= [SELECT External_Id_1__c FROM Orchestration_Technical__c WHERE Field_4__c='26261'];
		// Added for DIGI-28079
        ApplicationLog__c application = [Select Id from ApplicationLog__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('FullAddressResp'));
        Test.startTest();
        // amended for DIGI-28079
        SearchAddressBatch addressBatchObj=new SearchAddressBatch(orchTechObj.External_Id_1__c,application.Id,System.now());
        Database.executebatch(addressBatchObj);
        Test.stopTest();
        System.assertEquals(addressBatchObj!=null,true);    
	}
    //Method to validate else block Failed address search   
    public static testMethod void validateNotFoundFullAddress(){
	
		Orchestration_Technical__c orchTechObj= [SELECT External_Id_1__c FROM Orchestration_Technical__c WHERE Field_4__c=''];
		// Added for DIGI-28079
        ApplicationLog__c application = [Select Id from ApplicationLog__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('AddressSearch'));
        Test.startTest();
        // amended for DIGI-28079
        SearchAddressBatch addressBatchObj=new SearchAddressBatch(orchTechObj.External_Id_1__c,application.Id,System.now());
        Database.executebatch(addressBatchObj);
        Test.stopTest();
        System.assertEquals(addressBatchObj!=null,true); 
	}    
}