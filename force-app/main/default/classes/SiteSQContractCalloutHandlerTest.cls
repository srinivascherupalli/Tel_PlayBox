/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : Test Class to cover : SiteSQContractCalloutHandler
 * Revision :
 * 
 * *****************************************************************************/
@isTest
public class SiteSQContractCalloutHandlerTest {

    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : testSetup method to create test data
 * Revision :
 * 
 * *****************************************************************************/
    @testSetup static void setup() {

    
        Contact contact = TestUtil.createContact('Joe', 'Bloggs');
        contact.MobilePhone = '0445678006';
        insert contact;
        System.assertNotEquals(null,contact);
        
        
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;
        System.assertNotEquals(null,acc);
        TestUtil.addContactToAccount(acc.Id, contact.Id);
        update acc;
        
        cscrm__Address__c address= AccountTestFactory.buildAddressFull('161152457');
        address.Address_ID__c ='161152457';
        insert address;
        System.assertNotEquals(null,address);
        
        Billing_Account__c billingAccount=new Billing_Account__c();
        billingAccount.Billing_Account_Number__c='123456789322';
        billingAccount.Billing_Address__c=address.id;
        billingAccount.Billing_Account_Owner__c=contact.Id;
        billingAccount.Account__c=acc.Id;
        insert billingAccount;
        System.assertNotEquals(null,billingAccount);
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;
      //site.composite_key__c = '1234567891161152457';
        insert site;
       System.assertNotEquals(null,site);
   }
    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : Method to test : SaveSQResponse() success scenario
 * Revision :
 * 
 * *****************************************************************************/
    @isTest
    public static void testSaveSQResponse_Success(){
        cscrm__Address__c address= [select id from cscrm__Address__c limit 1 ];
        Account acc = [Select Id From Account Limit 1];
        String success_Search ='{"code":200,"status":200,"time":"2019-03-05T13:12:45+10:00","request":{"params":{"addressId":"161152457","serviceFilter":"Internet"},"data":{},"path":"/service-addresses","method":"GET","requestId":"cec27ea8-d1f4-4f05-89ac-d11ddaa67774","correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"},"correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b","data":{"addressId":"161152457","serviceTypeQualifications":[{"serviceType":"Internet","technologyType":"Fibre","readyForServiceDate":"2011-10-09","serviceabilityClass":"12","locationId":"LOC160829045445","csaId":"CSA200000000199","demandType":"Standard Install","providerResources":[{"resourceType":"Copper Pair","id":"New Path","status":"","sicIndicator":"Y","sicCode":"SIC_NEW_PATH_SELECTED_INFLIGHT_INPLACE","sicReason":"SIC is applicable due to In flight order in place","serviceabilityClass":"12"}],"characteristics":[{"name":"TC4 Downstream Upper Rate","value":"25 Mbps"},{"name":"TC4 Downstream Lower Rate","value":""},{"name":"TC4 Upstream Upper Rate","value":"5 Mbps"},{"name":"TC4 Upstream Lower Rate","value":""}],"statusReason":"NBN Internet is serviceable at this address","status":"Available","serviceTransferIndicator":"N","appointmentRequired":"Yes","copperPairIndicator":"Y"}],"additionalTrafficClassAvailability":[{"name":"High Speed TC2 (greater or equal to 20Mbps)","value":"No"},{"name":"TC2","value":"No"},{"name":"NCAS TC2 5Mbps Capacity","value":"No"},{"name":"NCAS TC2 10Mbps Capacity","value":"No"},{"name":"NCAS TC2 20Mbps Capacity","value":"No"},{"name":"NCAS TC2 30Mbps Capacity","value":"No"},{"name":"NCAS TC2 40Mbps Capacity","value":"No"},{"name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)","value":"No"},{"name":"Multicast","value":"No"}],"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""},"resourceDetails":[{"ntdId":"NTD400000353005","ntdLoc":"INDOOR","ntdInstallDate":"2016-10-16T01:06:17Z","ntdType":"INTERNAL","ntdPowerType":"AC","batteryPowerUnit":"Yes","powerSupplyWithBatteryBackupInstallDate":"2014-10-16T01:06:17Z","batteryPowerUnitMonitored":"ENABLED","portDetails":[{"uniPortType":"UNI-D","portId":"1-UNI-D1","portStatus":"Used"},{"uniPortType":"UNI-D","portId":"1-UNI-D2","portStatus":"Free"},{"uniPortType":"UNI-D","portId":"1-UNI-D3","portStatus":"Free"},{"uniPortType":"UNI-D","portId":"1-UNI-D4","portStatus":"Used"},{"uniPortType":"UNI-V","portId":"1-UNI-V1","portStatus":"Used"},{"uniPortType":"UNI-V","portId":"1-UNI-V2","portStatus":"Free"}]}]}}';
        
            
            SqResponseDTO responseDTO=SqResponseDTO.parse(success_Search);      
            Test.startTest();
            
            Service_Qualification__c sq = new SiteSQContractCalloutHandler().saveSQResponse(address.id,responseDTO,acc.Id);
            System.assertNotEquals(sq, null);
            Test.stopTest();
            
    }
    
      /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : Method to test : SaveSQResponse() error scenario
 * Revision :
 * 
 * *****************************************************************************/
    @isTest
    public static void testSaveSQResponse_Error(){
        cscrm__Address__c address= [select id from cscrm__Address__c limit 1 ];
        Account acc = [Select Id From Account Limit 1];
        String error_Search ='{"code":200,"status":200,"time":"2019-03-05T13:12:45+10:00"}';
        
            
            SqResponseDTO responseDTO=SqResponseDTO.parse(error_Search);        
            Test.startTest();
            
            Service_Qualification__c sq = new SiteSQContractCalloutHandler().saveSQResponse(address.id,responseDTO,acc.Id);
            System.assertEquals(sq, null);
            Test.stopTest();
            
    }
    
    
}