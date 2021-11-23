/*************************************************************************************************
EDGE -90327
Name: PpvCalloutTest
Description: Test class for PpvCallout 
Author: Aishwarya
***************************************************************************************************/
@isTest
public class PpvCalloutTest {

    /*************************************************************************************************
EDGE -90327
Method: setupdata
Description: Data setup
Author:Aishwarya
***************************************************************************************************/
	public static PpvRequestDTO setupdata(){
	PpvRequestDTO requestDto = new PpvRequestDTO();
        requestDto.correlationId=EDISSingleManager.getUID();
        requestDto.timestamp = JSON.serialize(Datetime.now());
        PpvRequestDTO.Data reqData= new PpvRequestDTO.Data();
         reqData.externalId='az189280421';
        reqData.portNumber='6236890543';
        //Kalashree Borgaonkar. Removing this attribute.        
        //reqData.prePaidBrand='N';
        requestDto.data = reqData;
        return requestDto;
	}
	
    /*************************************************************************************************
EDGE -90327
Method: ppvCallout_Success
Description:Test method to cover positive and negative scenario for PPV tool callout
Author:Aishwarya
***************************************************************************************************/
    @isTest
    public static void ppvCallout_Success(){
		PpvRequestDTO requestDto = new PpvRequestDTO();
        requestDto=setupdata();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockPPVCalloutResponse('success_Search'));
        PpvCallout ppv = new PpvCallout();
        PpvResponseDTO ppvReq = PpvCallout.calloutToPpvTool(requestDto);
        System.assertEquals((ppvReq!=null), true, 'Callout Failed');
        Test.setMock(HttpCalloutMock.class, new MockPPVCalloutResponse('success_Error'));
        ppvReq = PpvCallout.calloutToPpvTool(requestDto);
        System.assertEquals((ppvReq!=null), true, 'Callout Failed');       
        Test.stopTest();    
    }
/*************************************************************************************************
EDGE -90327
Method: createPayloadTest
Description:Request payload test method
Author:Aishwarya
***************************************************************************************************/
	@isTest
    public static void createPayloadTest(){
		setupdata();
		PpvCallout ppv = new PpvCallout();
		PpvCallout.createPayload('az189280421','6236890543');
        System.assertEquals((setupdata()!=null), true, 'Payload creation failed');       
           
    }
/*-------------------------------------------------------- 
EDGE-132716
Method: ppvCalloutFromTrigger
Description: Method to create payload for PPV tool callout
Author:Kalashree Borgaonkar
--------------------------------------------------------*/    
    @isTest
    public static void ppvCalloutFromTriggerTest(){
		setupdata();
		PpvCallout ppv = new PpvCallout();
		Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
        caf.Is_active__c=true;
        caf.MSISDN__c='6236890543';
        caf.PPV_status__c='';
        insert caf;
        Test.startTest();
        String childRecordid = PpvCallout.createPPVrecord(caf.id,'6236890543');
        PpvCallout.ppvCalloutFromTrigger(caf.id);
        Test.stopTest();
        System.assertEquals((setupdata()!=null), true, 'Payload creation');       
           
    }
/*--------------------------------------------------------
EDGE		-88791,144140
Method		-createPPVrecord
Description -create child record (PPV)
Author		-Kalashree Borgaonkar
--------------------------------------------------------*/   
    @isTest
    public static void createPPVrecordTest(){
		setupdata();
		Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
        caf.Is_active__c=true;
        caf.MSISDN__c='6236890543';
        caf.PPV_status__c='';
        insert caf;
        Test.startTest();
        String childRecordid = PpvCallout.createPPVrecord(caf.id,'6236890543');
        Test.stopTest();
        System.assertEquals((childRecordid!=null), true, 'child record created');       
           
    }
    /*--------------------------------------------------------
EDGE		-88791,144140
Method		-createPPVrecord
Description -create child record (PPV)
Author		-Kalashree Borgaonkar
--------------------------------------------------------*/   
    @isTest
    public static void createResendPPVrecordTest(){
		setupdata();
		Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
        caf.Is_active__c=true;
        caf.MSISDN__c='6236890543';
        caf.PPV_status__c='';
        insert caf;
        Test.startTest();
        String childRecordid = PpvCallout.createResendPPVrecord(caf.id,'6236890543',null);
        Test.stopTest();
        System.assertEquals((childRecordid!=null), true, 'child record created');       
           
    }
     /*--------------------------------------------------------
EDGE		-88791,144140
Method		-saveResponse
Description -save response from PPV tool in child record
Author		-Kalashree Borgaonkar
--------------------------------------------------------*/   
 @isTest
    public static void saveResponseTest(){
        setupdata();
		Customer_Authority_Form__c caf = new Customer_Authority_Form__c();
        caf.Is_active__c=true;
        caf.MSISDN__c='6236890543';
        caf.PPV_status__c='';
        insert caf;
        Test.startTest();
        String success_Search ='{"status":202,"code":202,"responseCode":"MPPV-ACCEPTED","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","timeStamp":"2019-02-27T00:22:19.737Z","path":"/generate-code","method":"POST","data":{"externalId":"abc1234","resourceId":"145sdhju176-wh2327-9474f-f56g5"}}'; 
        PpvResponseDTO responsedto= PpvResponseDTO.parse(success_Search);
        String childRecordid = PpvCallout.createPPVrecord(caf.id,'6236890543');
        PpvCallout.saveResponse(caf,responsedto);
        Test.stopTest();
        System.assertEquals(([SELECT count() FROM Customer_Authority_Form__c]>0), true, 'response saved');
    }   
    
}