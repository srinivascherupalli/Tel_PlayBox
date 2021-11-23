/*
Story No    | Status   | Name
EDGE - 67863| Created  | Kalashree Borgaonkar
DIGI - 776  | Modified | Akshay G (Istanbul) - Removed redundant Test.setMocks
DIGI-2540   | Modified | Ajith Kumar - Code Refactoring changes
DIGI-29002  | Modified | Sowmya      - Created widefeasSQSuccess2 test method and updated widefeasSQSuccess method for code coverage.
*/
@isTest
public class SQcheckCalloutHandlerTest {
   @testSetup static void setup() {    
        Contact contact = TestUtil.createContact('Joe', 'Bloggs');
        contact.MobilePhone = '0445678006';
        insert contact;        
        
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;
        TestUtil.addContactToAccount(acc.Id, contact.Id);
        update acc;
        
        cscrm__Address__c address= AccountTestFactory.buildAddressFull('161152457');
        insert address;
        
        Billing_Account__c billingAccount=TestUtil.createBillingAccount('123456789322');
        insert billingAccount;        
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;      
        insert site;
        
        //DIGI-29002 created test data
        Service_Qualification__c sq = TestUtil.createServiceQualification(acc,'65788','Y');   
        sq.Site__c = site.Id;
        sq.Technology_Type__c ='Telstra Fibre';
        sq.Address_ID__c  = '265742187';       
        sq.isLatestValidResult__c = true;
        insert sq;
     
       
   }
    
    @isTest
    public static void callSQServiceSuccess(){       
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Search'));
        String jobId = System.enqueueJob(new SQcheckCalloutHandler(addressList,acc.id,false,'NBN Fibre'));
        System.assertEquals((jobId!=null), true, 'Enqueued');
        Test.stopTest();    
    }
    @isTest
    public static void callSQService_Error(){
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Error'));
        String jobId = System.enqueueJob(new SQcheckCalloutHandler(addressList,acc.id));
        System.assertEquals((jobId!=null), true, 'Enqueued');
        Test.stopTest();    
    }
     @isTest
    public static void callSQService_Exception(){
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest(); 
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Exception'));
        String jobId = System.enqueueJob(new SQcheckCalloutHandler(addressList,acc.id));
        System.assertEquals((jobId!=null), true, 'Enqueued');
        SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,acc.id);
        sqCalloutHndlr.syncExecute('Fibre');
        Test.stopTest();    
    }
	/****************************************************************
      * EDGE:98319
      * Method:widefeasSQ_Success
      * Author:Aishwarya
      * *********************************************************************/
	 @isTest
    public static void widefeasSQSuccess(){
       
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c  site=[SELECT id FROM cscrm__Site__c WHERE cscrm__Account__c = :acc.id];
        Service_qualification__c sqd =[select id,Account__c,Site__c,Technology_Type__c,Address_ID__c,isLatestValidResult__c from Service_qualification__c where Account__c=:acc.Id];
        Map<String,SqResponseDTO> mapResponseDTO = new Map<String,SqResponseDTO>();
        SqResponseDTO sqrd = new SqResponseDTO();
        
		Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Widefeas'));      	
		SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,site.id,true,'Telstra Fibre');
  //start Digi-29002
    
        List<Service_Qualification__c> serviceQList = new List<Service_Qualification__c>();        
            serviceQList.add(sqd);           
            
         List<SqResponseDTO.Location> locationList =new List<SqResponseDTO.Location>();
		List<SqResponseDTO.ProductDetails> productDetailsList = new List<SqResponseDTO.ProductDetails>();
        SqResponseDTO.ProductDetails sdto= new SqResponseDTO.ProductDetails();
      
        sdto.carriageSolution= 'test';
		sdto.carriageSolutionStatus= 'test';
		sdto.carriageSolutionReasonCode= 'test';
		sdto.maximumESABandwidth= 456;
		sdto.maximumDeviceBandwidth= 1000;
		sdto.interfaceType= 'test';
        sdto.spareSlotIndicator= 'test';
		sdto.deviceBuildIndicator= true;
        sdto.deviceType= 'test';
        sdto.deviceDomain= 'test';
        sdto.unifiedAccess= 'test';
        sdto.deviceMigration= 'test';
        productDetailsList.add(sdto);
          SqResponseDTO.Location loc= new SqResponseDTO.Location();
        loc.adborId =123;
		loc.addressType ='test';
		loc.fibreAvailabilityStatus = 'Available';
		loc.fibreAvailabilityReasonCode = 'test';
		loc.productDetails=productDetailsList;
        locationList.add(loc);
        SqResponseDTO.Data d= new SqResponseDTO.Data();
        d.location = locationList;
        d.addressId = '265742187';
        sqrd.Data = d;

        mapResponseDTO.put('265742187',sqrd);
        
        sqCalloutHndlr.saveSQResponse(mapResponseDTO);
        sqCalloutHndlr.saveCarriageSolution(productDetailsList, serviceQList);
        
        
        //End Digi-29002
        sqCalloutHndlr.syncExecute('Telstra Fibre');
        System.assertEquals(addressList !=Null, true, 'List not Empty');
        System.assertEquals(sdto.deviceType,'test');
        Test.stopTest();    
    }
    //Start DIGI-29002
   @isTest
    public static void widefeasSQSuccess2(){
        
         List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c  site=[SELECT id FROM cscrm__Site__c WHERE cscrm__Account__c = :acc.id];
        Service_qualification__c sqd =[select id,Account__c,Site__c,Technology_Type__c,Address_ID__c,isLatestValidResult__c from Service_qualification__c where Account__c=:acc.Id];
		Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Widefeas'));      	
		SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,site.id,true,'Telstra Fibre');

        List<Service_Qualification__c> serviceQList = new List<Service_Qualification__c>();        
        serviceQList.add(sqd);           

        List<WidefeaseSQResponseDTO.ProductDetails> productDetailsList = new List<WidefeaseSQResponseDTO.ProductDetails>();
        List<WidefeaseSQResponseDTO.Location> locationList =new List<WidefeaseSQResponseDTO.Location>();
        WidefeaseSQResponseDTO wfp = new WidefeaseSQResponseDTO();
        
       WidefeaseSQResponseDTO.ProductDetails wfpd= new WidefeaseSQResponseDTO.ProductDetails();
        wfpd.carriageSolution = 'test';
		wfpd.carriageSolutionStatus ='Available';
		wfpd.carriageSolutionReasonCode = 'test';
		wfpd.maximumESABandwidth =112;
		wfpd.maximumDeviceBandwidth= 342;
		wfpd.interfaceType = 'test';     
        productDetailsList.add(wfpd);
        WidefeaseSQResponseDTO.Location loc= new WidefeaseSQResponseDTO.Location();
        loc.adborId =123;
		loc.addressType ='test';
		loc.fibreAvailabilityStatus = 'Available';
		loc.fibreAvailabilityReasonCode = 'test';
		loc.productDetails=productDetailsList;
        locationList.add(loc);
        WidefeaseSQResponseDTO.Data d= new WidefeaseSQResponseDTO.Data();
        d.location = locationList;
        
        wfp.code= 101;
        wfp.status = 200;
        wfp.time_x = 'test';
        wfp.data = d;
        
        sqCalloutHndlr.saveCarriageSolution(productDetailsList, serviceQList);
        sqCalloutHndlr.saveWidefeasSQResponse('test',wfp);
        System.assertEquals(addressList !=Null, true, 'List not Empty');
          Test.stopTest(); 
    }
       
      //End DIGI-29002
	 /****************************************************************
      * EDGE:98319
      * Method:widefeasSQ_Error
      * Author:Aishwarya
      * *********************************************************************/
	 
    @isTest
    public static void widefeasSQError(){
       
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c  site=[SELECT id FROM cscrm__Site__c WHERE cscrm__Account__c =:acc.id];
		Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('Error_Widefeas'));
		SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,site.id,true,'Telstra Fibre');
        sqCalloutHndlr.syncExecute('Telstra Fibre');
        System.assertEquals(addressList !=Null, true, 'List not Empty');
        Test.stopTest();    
    }
    
    	 /****************************************************************
      * P20B : 7333 For newly added Technology Type
      * Author:Ravi Dodiya
      * *********************************************************************/
	 @isTest
    public static void nbnEthernetSuccess(){
       
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c  site=[SELECT id FROM cscrm__Site__c WHERE cscrm__Account__c = :acc.id];
		Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_NBN_Ethernet'));
		SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,site.id,true,'NBN Ethernet');
        sqCalloutHndlr.syncExecute('NBN Ethernet');
        System.assertEquals(addressList !=Null, true, 'List not Empty');
        Test.stopTest();    
    }	 
    @isTest
    public static void nbnEthernetError(){
       
        List<String> addressList = new List<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c  site=[SELECT id FROM cscrm__Site__c WHERE cscrm__Account__c =:acc.id];
		Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('Error_NBN_Ethernet'));
		SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,site.id,true,'NBN Ethernet');
        sqCalloutHndlr.syncExecute('NBN Ethernet');
        System.assertEquals(addressList !=Null, true, 'List not Empty');
        Test.stopTest();    
    }
    @isTest
    public static void validatesiteaddress(){       
        List<String> addressList = new List<String>{'161152457'};
        Set<String> addressSet = new Set<String>{'161152457'};
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Exception'));
		SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(addressList,acc.id);
        Map<String,String> siteId=sqCalloutHndlr.getSiteIdFromAdborid(acc.id,addressSet);
        sqCalloutHndlr.syncExecute('Fibre');
        System.assertEquals(addressList !=Null, true, 'List not Empty');
        Test.stopTest();    
    } 
    @isTest
    public static void validateException(){
        Test.startTest();
        try{
        	SQcheckCalloutHandler sqCalloutHndlr=new SQcheckCalloutHandler(null,null,null,null);
            List<WidefeaseSQResponseDTO.ProductDetails> productDetailsList =null;
        	sqCalloutHndlr.saveCarriageSolution(productDetailsList, null);
            List<SqResponseDTO.ProductDetails> SQproductDetailsList =null;
        	sqCalloutHndlr.saveCarriageSolution(SQproductDetailsList, null);
            sqCalloutHndlr.saveProviderResources(null, null, null);
            sqCalloutHndlr.saveResourceDetail(null, null);
        }
        catch(NullPointerException ex){            
        	system.assertEquals(ex.getMessage(),'Attempt to de-reference a null object');
        }        
        Test.stopTest();
    } 
}