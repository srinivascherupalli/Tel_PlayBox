/*
@ DEVELOPER : Shishir 
@ TEAM: Istanbul
@ DESCRIPTION : Test class BulkUploadSiteDataController
@ DIGI-6187/DIGI-332
******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.        Omkar Jante         07/Oct/2021     DIGI-28081 : Updated logic for soft delete
*/
@IsTest
public with sharing class BulkUploadSiteDataControllerTest {
    
    // setting up data for test
    @TestSetup
    static void setupTestData() {
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;  

        String templateData = 'Site Name,Adbor ID,Site Address';
        ContentVersion template = new ContentVersion();
        template.Title = 'Bulk Site Template';
        template.PathOnClient = 'TestCSV.csv';
        template.VersionData = Blob.valueOf(templateData);
        template.IsMajorVersion = true;

        String csvData = 'Site Name,Adbor ID,Site Address' + '\n' + 'Test Site Name,1234,"Level 11, 35 Collins Street Melbourne VIC 3000"' + '\n' + 'Test Site Name,1234,Level 11 35 Collins Street Melbourne VIC 3000';
        ContentVersion contentVer = new ContentVersion();
        contentVer.Title = 'CSV Document';
        contentVer.PathOnClient = 'TestCSV.csv';
        contentVer.VersionData = Blob.valueOf(csvData);
        contentVer.IsMajorVersion = true;

        String csvData2 = 'Site Name,Adbor ID' + '\n' + 'Test Site Name,1234,"Level 11, 35 Collins Street Melbourne VIC 3000"';
        ContentVersion contentVer2 = new ContentVersion();
        contentVer2.Title = 'CSV Document 2';
        contentVer2.PathOnClient = 'TestCSV.csv';
        contentVer2.VersionData = Blob.valueOf(csvData2);
        contentVer2.IsMajorVersion = true;

        String csvData3 = 'Site Name,Adbor ID,Site Address' + '\n' + 'Test Site Name,1234,Level 11, 35 Collins Street Melbourne VIC 3000';
        ContentVersion contentVer3 = new ContentVersion();
        contentVer3.Title = 'CSV Document 3';
        contentVer3.PathOnClient = 'TestCSV.csv';
        contentVer3.VersionData = Blob.valueOf(csvData);
        contentVer3.IsMajorVersion = true;
        
        String csvDataEmpty ='Null,,' +'';
        ContentVersion contentVer4 = new ContentVersion();
        contentVer4.Title = 'CSV Document 4';
        contentVer4.PathOnClient = 'TestCSV.csv';
        contentVer4.VersionData = Blob.valueOf(csvDataEmpty);
        contentVer4.IsMajorVersion = true;
        
        List<ContentVersion> listOfContentVersion = new List<ContentVersion>();
        listOfContentVersion.add(template);
        listOfContentVersion.add(contentVer);
        listOfContentVersion.add(contentVer2);
        listOfContentVersion.add(contentVer3);
        listOfContentVersion.add(contentVer4);
        insert listOfContentVersion;

        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = template.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
		
		List<Orchestration_Technical__c> objOrchTech = new List<Orchestration_Technical__c>();
        Orchestration_Technical__c objOrchestrationTechnical = new Orchestration_Technical__c();
        objOrchestrationTechnical.External_Id_1__c=acc.Id;
        objOrchestrationTechnical.Field_4__c='12341';
        objOrchestrationTechnical.Field_2__c='Test';
        objOrchestrationTechnical.Field_3__c='New';
        objOrchestrationTechnical.Field_1__c='Test Site';
        objOrchestrationTechnical.Field_7__c='FALSE';
        objOrchestrationTechnical.Process_Name__c='Bulk_Site_Upload';
        objOrchestrationTechnical.CorrelationId__c=GuidUtil.NewGuid();
        objOrchTech.add(objOrchestrationTechnical);
		
		Orchestration_Technical__c objOrchestrationTechnical1 = new Orchestration_Technical__c();
        objOrchestrationTechnical1.External_Id_1__c=acc.Id;
        objOrchestrationTechnical1.Field_4__c='123415667';
        objOrchestrationTechnical1.Field_2__c='Test';
        objOrchestrationTechnical1.Field_3__c='Match Found';
        objOrchestrationTechnical1.Field_1__c='Test Site';
        objOrchestrationTechnical1.Field_6__c = 'Address';
        objOrchestrationTechnical1.Field_7__c='FALSE';
        objOrchestrationTechnical1.BackupJson__c = '{"status":null,"results":[{"source":"experian","raw":"AUE|30641203-1f7b-4aa9-9565-92a753b9e7c8|7.730zOAUEHAXlBwAAAAAIAgEAAAACULsp0BAhAQYQCCEAAhAA4AAAAAAAAAAA..9kAAAAAP....8AAAAAAAAAAAAAAAAAAABMZXZlbCAxMSAzNSBDb2xsaW5zIFN0cmVldCBNZWxib3VybmUgVklDIDMwMDAAAAAAAA--$45","position":0,"name":"Level 11  35 Collins Street, MELBOURNE  VIC  3000"},{"source":"experian","raw":"AUE|30641203-1f7b-4aa9-9565-92a753b9e7c8|7.730iOAUEHAXlBwAAAAAIAgEAAAACTp8c0BAhAIIQAOAAAAAAAAAxMQAA..9dAAAAAP....8AAAAAAAAAAAAAAAAAAABMZXZlbCAxMSAzNSBDb2xsaW5zIFN0cmVldCBNZWxib3VybmUgVklDIDMwMDAAAAAAAA--$45","position":1,"name":"Unit 11  25-45 Collins Street, MELBOURNE  VIC  3000"},{"source":"experian","raw":"AUE|30641203-1f7b-4aa9-9565-92a753b9e7c8|7.730NOAUEHAXlBwAAAAAIAgEAAAACTp6YUADgAAAAAAEATGV2ZWwgMTEAAAD..1AAAAAA.....wAAAAAAAAAAAAAAAAAAAExldmVsIDExIDM1IENvbGxpbnMgU3RyZWV0IE1lbGJvdXJuZSBWSUMgMzAwMAAAAAAA$45","position":2,"name":"Level 11 17-65 Collins Street, MELBOURNE  VIC  3000"},{"source":"experian","raw":"AUE|30641203-1f7b-4aa9-9565-92a753b9e7c8|7.730gOAUEHAXlBwAAAAAIAgEAAAACTp7.EBBhAIIQAOAAAAAAAAAAAP..UAAAAAD.....AAAAAAAAAAAAAAAAAAAATGV2ZWwgMTEgMzUgQ29sbGlucyBTdHJlZXQgTWVsYm91cm5lIFZJQyAzMDAwAAAAAAA-$45","position":3,"name":"Level 1  25-45 Collins Street, MELBOURNE  VIC  3000"}],"responseTime":null,"request":null,"message":null,"errors":null,"ErrorDescription":null,"ErrorCode":null,"dataZ":null,"data":null,"correlationId":"adbef212-b84d-452b-2655-2e2ddbf266c9","code":null}';
        objOrchestrationTechnical1.Process_Name__c='Bulk_Site_Upload';
        objOrchestrationTechnical1.CorrelationId__c=GuidUtil.NewGuid();
        objOrchTech.add(objOrchestrationTechnical1);
		
		Orchestration_Technical__c objOrchestrationTechnical2 = new Orchestration_Technical__c();
        objOrchestrationTechnical2.External_Id_1__c=acc.Id;
        objOrchestrationTechnical2.Field_4__c='123416';
        objOrchestrationTechnical2.Field_2__c='Test';
        objOrchestrationTechnical2.Field_3__c='Failed';
        objOrchestrationTechnical2.Field_1__c='Test Site';
        objOrchestrationTechnical2.Field_7__c='FALSE';
        objOrchestrationTechnical2.Process_Name__c='Bulk_Site_Upload';
        objOrchestrationTechnical2.CorrelationId__c=GuidUtil.NewGuid();
        objOrchTech.add(objOrchestrationTechnical2);
        
        Orchestration_Technical__c objOrchestrationTechnical3 = new Orchestration_Technical__c();
        objOrchestrationTechnical3.External_Id_1__c=acc.Id;
        objOrchestrationTechnical3.Field_4__c='123417';
        objOrchestrationTechnical3.Field_2__c='Test1425';
        objOrchestrationTechnical3.Field_3__c='Match Found';
        objOrchestrationTechnical3.Field_1__c='Test Site';
        objOrchestrationTechnical3.Field_6__c = 'AdborId';
        objOrchestrationTechnical3.Field_7__c='FALSE';
        objOrchestrationTechnical3.BackupJson__c = '[{"subAddressType":null,"subAddressNumber":null,"subAddressLine":null,"subAddresslevel4":null,"subAddresslevel3":null,"subAddresslevel2":null,"subAddresslevel1":null,"subAddressCodeset":null,"streetTypeSuffix":null,"streetType":null,"streetName":null,"status":"CONFIRMED","state":"VIC","serLocXchange":null,"serLocReady":null,"serLocLong":null,"serLocLat":null,"serLocFace":null,"ruralMailType":null,"ruralmailNumber":null,"responseStatus":200,"readyForServiceDate":null,"propertyNumberTo":null,"propertyNumberFrom":null,"postcode":"3000","postalDeliveryType":null,"postalDeliveryNumber":null,"planNumber":null,"parentAddressId":null,"parcelType":null,"ParcelNumber":null,"parcelDescriptor1":null,"numberToSuffix":null,"numberToPrefix":null,"numberTo":null,"numberSuffix":null,"numberStart":null,"numberPrefix":null,"numberOfSubAddresses":null,"nbnStatus":null,"name":null,"longZ":null,"locationId":null,"locality":"MELBOURNE","lat":null,"greaterLocality":null,"facsRealm":null,"exchangeServiceAreaId":null,"customerServiceAreaId":null,"connectivityServiceAreaId":null,"confirmed":null,"condorCode":null,"addrTypeLvl4":null,"addrTypeLvl3":null,"addrTypeLvl2":null,"addrTypeLvl1":null,"addrNumLvl4":null,"addrNumLvl3":null,"addrNumLvl2":null,"addrNumLvl1":null,"addressType":null,"addressLine":"BG 1, L 24,35 COLLINS ST","addressId":"262619086","addNotFound":null,"accountId":null}]';
        objOrchestrationTechnical3.Process_Name__c='Bulk_Site_Upload';
        objOrchestrationTechnical3.CorrelationId__c=GuidUtil.NewGuid();
        objOrchTech.add(objOrchestrationTechnical3); 
        
        Orchestration_Technical__c objOrchestrationTechnical4 = new Orchestration_Technical__c();
        objOrchestrationTechnical4.External_Id_1__c=acc.Id;
        objOrchestrationTechnical4.Field_4__c='123418';
        objOrchestrationTechnical4.Field_2__c='Test1425';
        objOrchestrationTechnical4.Field_3__c='Found';
        objOrchestrationTechnical4.Field_1__c='Test site2';
        objOrchestrationTechnical4.Field_6__c = 'AdborId';
        objOrchestrationTechnical4.Field_7__c='FALSE';
        objOrchestrationTechnical4.BackupJson__c = '[{"subAddressType":null,"subAddressNumber":null,"subAddressLine":null,"subAddresslevel4":null,"subAddresslevel3":null,"subAddresslevel2":null,"subAddresslevel1":null,"subAddressCodeset":null,"streetTypeSuffix":null,"streetType":null,"streetName":null,"status":"CONFIRMED","state":"VIC","serLocXchange":null,"serLocReady":null,"serLocLong":null,"serLocLat":null,"serLocFace":null,"ruralMailType":null,"ruralmailNumber":null,"responseStatus":200,"readyForServiceDate":null,"propertyNumberTo":null,"propertyNumberFrom":null,"postcode":"3000","postalDeliveryType":null,"postalDeliveryNumber":null,"planNumber":null,"parentAddressId":null,"parcelType":null,"ParcelNumber":null,"parcelDescriptor1":null,"numberToSuffix":null,"numberToPrefix":null,"numberTo":null,"numberSuffix":null,"numberStart":null,"numberPrefix":null,"numberOfSubAddresses":null,"nbnStatus":null,"name":null,"longZ":null,"locationId":null,"locality":"MELBOURNE","lat":null,"greaterLocality":null,"facsRealm":null,"exchangeServiceAreaId":null,"customerServiceAreaId":null,"connectivityServiceAreaId":null,"confirmed":null,"condorCode":null,"addrTypeLvl4":null,"addrTypeLvl3":null,"addrTypeLvl2":null,"addrTypeLvl1":null,"addrNumLvl4":null,"addrNumLvl3":null,"addrNumLvl2":null,"addrNumLvl1":null,"addressType":null,"addressLine":"BG 1, L 24,35 COLLINS ST","addressId":"262619086","addNotFound":null,"accountId":null}]';
        objOrchestrationTechnical4.Process_Name__c='Bulk_Upload';
        objOrchestrationTechnical4.CorrelationId__c=GuidUtil.NewGuid();
        objOrchTech.add(objOrchestrationTechnical4);
        insert objOrchTech; 

        //DIGI-28079 inserting custom setting to test logger
        Environment_Configurations__c environmentConfig = New Environment_Configurations__c();
        environmentConfig.Custom_Logging__c = true;
        insert environmentConfig;

        // Adding for DIGI-28079
        ApplicationLog__c application = new ApplicationLog__c();
        application.Reference_Info__c = 'BulkSiteUploadHandler';
        application.Request_Message__c = 'Bulk_Site_Upload_';
        application.Message__c = 'File Uploaded';
        insert application;
        
    }
    //DIGI-10971 This method validates the file upload parsing valid CSV
    @IsTest
    static void testparseCSVandUpload() {
        try{
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'CSV Document'];
        Account accRecord = [Select id from Account Limit 1];
        Test.startTest();
            Map<String, String> mapOfPropertyToValue = BulkUploadSiteDataController.parseCSVandUpload(contentVer.ContentDocumentId,accRecord.id);
			Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Adbor'));
        	Map<String,string> returnVal = BulkUploadSiteDataController.getProcessedRecords(accRecord.Id,0,1,true);
        Test.stopTest();
        System.assertEquals(mapOfPropertyToValue.get('isCSVValid'),'true');
    }
    catch(Exception ex){
        
    }
    }
	//DIGI-10971 This method validates the invalid CSV 
    @IsTest
    static void testparseCSVandUploadNegative() {
        try{
        Account accRecord = [Select id from Account Limit 1];
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'CSV Document 2'];
        Test.startTest();
            Map<String, String> mapOfPropertyToValue = BulkUploadSiteDataController.parseCSVandUpload(contentVer.Id,accRecord.id);
        Test.stopTest();		
        System.assertEquals(mapOfPropertyToValue.get('isCSVValid'),'false');
        }
        catch(Exception ex){
            
        }
    }
    //DIGI-10971 This method validates the empty CSV  
    @IsTest
    static void testparseCSVandUploadEmpty() {
        try{
        Account accRecord = [Select id from Account Limit 1];
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'CSV Document 4'];
        Test.startTest();
            Map<String, String> mapOfPropertyToValue = BulkUploadSiteDataController.parseCSVandUpload(contentVer.Id,accRecord.id);
        Test.stopTest();
        System.assertEquals(mapOfPropertyToValue.get('isCSVValid'),'false');
        }
        catch(Exception ex){
            
        }
    }
    @IsTest
    static void testparseCSVNegativeContentId() {
        try{
        Account accRecord = [Select id from Account Limit 1];
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'CSV Document 4'];
        Test.startTest();
            Map<String, String> mapOfPropertyToValue = BulkUploadSiteDataController.parseCSVandUpload(null,null);
        	system.debug('Print the map-->'+mapOfPropertyToValue);
        Test.stopTest();
        System.assertEquals(mapOfPropertyToValue.Values().size()==0,true);
        }
        catch(Exception ex){
            
        }
    }
	
    //DIGI-10971 This method validates the else block valid CSV
    @IsTest
    static void testparseCSVandUploadForElseCase() {
        Account accRecord = [Select id from Account Limit 1];
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'CSV Document 3'];
        Test.startTest();
            Map<String, String> mapOfPropertyToValue = BulkUploadSiteDataController.parseCSVandUpload(contentVer.ContentDocumentId,accRecord.id);
        Test.stopTest();

        System.assertEquals(mapOfPropertyToValue.get('isCSVValid'),'true');
    }
	//DIGI-10971 This method validates the template records
    @IsTest
    static void testGetTemplate() {
        Account accRecord = [Select id from Account Limit 1];
         Map<String, Integer> testString = New Map<String, Integer>();
            
        Test.startTest();
            testString = BulkUploadSiteDataController.getSitesCount(accRecord.Id);
        Test.stopTest();
        System.assert(testString.size()>0,'true');
    }
    //DIGI-10971 This method validates the failed Record count
    @IsTest
    static void testGetCountOfFailedRecord() {
		Orchestration_Technical__c accRecord = [Select External_Id_1__c from Orchestration_Technical__c where Field_4__c='123416' Limit 1];
        Test.startTest();
       	List<AggregateResult> count = BulkUploadSiteDataController.getCountOfFailedRecord(accRecord.External_Id_1__c,new List<String>{'Failed'},'Field_3__c');
        Test.stopTest();
        
        System.assertEquals(1,count.size(), 'Count should be one');
    } 
	//DIGI-10971 This method check the re-validation of manual batchcall
    @IsTest
    static void manualBatchCall() {
		Account accRecord = [Select Id from Account Limit 1];
        
        Test.startTest();
        	Map<String,string> returnVal = BulkUploadSiteDataController.manualBatchCall(accRecord.Id,'');
        Test.stopTest();
        
        System.assertEquals(returnVal.size()>0,true);
    }
	//DIGI-10971 This method validates the add Site with adborId
	@IsTest
    static void addNewSiteforAdborId() {
		Account accRecord = [Select Id from Account Limit 1];
        Orchestration_Technical__c objOrchTech = [Select id,CorrelationId__c from Orchestration_Technical__c where Field_3__c = 'Match Found' and field_6__c = 'AdborId' Limit 1];
        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Adbor'));
			Map<String,string> returnVal = BulkUploadSiteDataController.addSiteRecord(objOrchTech.CorrelationId__c,accRecord.Id,'L1 Test Data');
        Test.stopTest();
        
        System.assertEquals(returnVal.size()>0,true);
    } 
    //DIGI-10971 This method validates the add Site with adborId
	@IsTest
    static void addNewSiteforAddress() {
		Account accRecord = [Select Id from Account Limit 1];
        Orchestration_Technical__c objOrchTech = [Select id,CorrelationId__c from Orchestration_Technical__c where Field_3__c = 'Match Found' and field_6__c= 'Address' Limit 1];
		Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Success'));
        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Success'));
        	Map<String,string> returnVal = BulkUploadSiteDataController.addSiteRecord(objOrchTech.CorrelationId__c,accRecord.Id,'L1 Test Data');
        Test.stopTest();
        
        System.assertEquals(returnVal.size()>0,true);
    } 
	//DIGI-10971 This method validates the exported records
	@IsTest
    static void exportUnmatchedSites() {
		Account accRecord = [Select Id from Account Limit 1];
        Test.startTest();
        	List<Orchestration_Technical__c> returnVal = BulkUploadSiteDataController.exportUnmatchedSites(accRecord.Id,new List<String>{'Match Found'});
        Test.stopTest();
        
        System.assertEquals(returnVal.size()>0,true);
    } 
	//DIGI-10971 This method validates the deletion of records
	@IsTest
    static void deleteSiteRecord() {
		Account accRecord = [Select Id from Account Limit 1];
        Test.startTest();
		Orchestration_Technical__c objOrchTech = [Select id,CorrelationId__c from Orchestration_Technical__c where Field_3__c = 'Match Found' Limit 1];
        	Map<String,String> returnVal = BulkUploadSiteDataController.deleteSiteRecord(objOrchTech.CorrelationId__c,accRecord.Id);
        Test.stopTest();
        
        System.assertEquals(returnVal.size()>0,true);
    }
    //DIGI-10971 This method checks the pagination and records processed after insertion
    @IsTest
    static void validategetProcessedRecords(){
        Orchestration_Technical__c accRecord = [Select External_Id_1__c from Orchestration_Technical__c where Field_6__c='AdborId' Limit 1];
       	Test.startTest();
        Map<String,String> mapOfPropertyToValue =BulkUploadSiteDataController.getProcessedRecords(accRecord.External_Id_1__c,0,0,true);
        Test.stopTest();
        System.assertEquals(mapOfPropertyToValue.Values().size()>0,true);
    }
    //DIGI-10971 Method validates the batch id and execute the batch
    @IsTest
    static void manualBatchValidation(){
        Orchestration_Technical__c accRecord = [Select External_Id_1__c from Orchestration_Technical__c where Field_6__c='AdborId' Limit 1];
		ApplicationLog__c application = [Select Id from ApplicationLog__c limit 1];
        Id batchProcessId = Database.executebatch(new SearchAddressBatch(accRecord.External_Id_1__c,application.Id,System.now()),Coms_BulkSiteUploadUtils.Batch_Size);   //DIGI-28079 moving batch size in static variable     
       	Test.startTest();
        Map<String,String> mapOfPropertyToValue =BulkUploadSiteDataController.manualBatchCall(accRecord.External_Id_1__c,batchProcessId);
        Test.stopTest();
        System.assertEquals(mapOfPropertyToValue.Values().size()>0,true);
    }
 	@IsTest
    static void logException(){
       	Orchestration_Technical__c accRecord = [Select External_Id_1__c from Orchestration_Technical__c where Field_3__c='Found' Limit 1];
        Test.startTest();
        try{           
            BulkUploadSiteDataController.logException(null,null,null);
            BulkUploadSiteDataController.deleteSiteRecord(null,null);           
            BulkUploadSiteDataController.manualBatchCall(null,'');
            BulkUploadSiteDataController.getProcessedRecords(null,-1,-12,false);
            BulkUploadSiteDataController.getSitesCount(null);
        }
        catch(Exception ex){
            system.assertEquals(ex.getMessage(),'Script-thrown exception');
        }        
        Test.stopTest();
	}  
    @IsTest
    static void getSitesCount(){
        Account accRecord = [Select Id from Account Limit 1];
        Test.startTest();
        try{
            BulkUploadSiteDataController.getCountOfFailedRecord(accRecord.id,null,'test');
            BulkUploadSiteDataController.addSiteRecord( null,'-232', '@43435,3243');
            BulkUploadSiteDataController.parseCSVandUpload('-1','-1');
            BulkUploadSiteDataController.exportUnmatchedSites(accRecord.id,new List<string>{null});
        }
        catch(Exception ex){
            system.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
        
    }
    @IsTest
    static void deleteDocument(){
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'CSV Document 3'];
        Test.startTest();
        BulkUploadSiteDataController.deleteDocument(contentVer.id);
        Test.stopTest();
    }
}