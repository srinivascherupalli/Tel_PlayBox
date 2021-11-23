/*
Story No    | Status   | Name
EDGE- 71662 | Author   | Ravi Shankar
DIGI-2540   | Modified | Ajith Kumar - Code Refactoring changes
DIGI-26327   | Modified | Omkar Jante - Code changes for coverage
*/
@isTest
public class SiteSQCheckControllerTest {
   @testSetup static void setup() {
    
        Contact contact = TestUtil.createContact('Joes', 'Bloaggs');
        contact.MobilePhone = '0445378006';
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
   
        /********************************************************************************************
        EDGE-> 119161
        Author: Ila
        Description : Test data
        ***********************************************************************************************/
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();       
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        sqRecord.isLatestValidResult__c=True;
        sqRecord.Technology_Type__c='Fibre';
        sqRecord.Site__c=site.Id;
        sqList.add(sqRecord);
        Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'61422222222','N');
        sqRecord1.isLatestValidResult__c=True;
        sqRecord1.Technology_Type__c='Telstra Fibre';
        sqRecord1.Site__c=site.Id;
        sqList.add(sqRecord1);
        // P2OB-7333 new technology type for NBN Ethernet
        Service_Qualification__c sqRecord2 = TestUtil.createServiceQualification(acc,'61433333333','N');
        sqRecord2.isLatestValidResult__c=True;
        sqRecord2.Technology_Type__c='Enterprise Ethernet Access Service';
        sqRecord2.Site__c=site.Id;
        sqList.add(sqRecord2);
        insert sqList;       
   }

   /*************************************************************************************************
    Name : callSQService_Success
    EDGE-> 119161
    Author: Ila
    Description : Test method to get callSQService_Success
    ***********************************************************************************************/
    @isTest
    public static void callSQService_Success(){
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c siteRec = [select Id from cscrm__Site__c where AdborID__c = '161152457' and cscrm__Account__c= :acc.id];
        Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Search'));
		SiteSQCheckController sqCtlr = new SiteSQCheckController();
		string resultStr = SiteSQCheckController.triggerSQCheck('161152457', siteRec.id,'Fibre');
        System.assertEquals((resultStr!=null), true);
        Test.stopTest();    
    }
 
    /*************************************************************************************************
    Name : getLatestSQ
    EDGE-> 119161
    Author: Ila
    Description : Test method to get latest SQ
    ***********************************************************************************************/
    @isTest
    public static void getLatestSQ(){
       
       List<Service_Qualification__c> sqList = [Select id,Status__c,isLatestValidResult__c,LastModifiedDate,Technology_Type__c from Service_Qualification__c where isLatestValidResult__c=True];
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
		cscrm__Site__c siteRec = [select Id from cscrm__Site__c where AdborID__c = '161152457' and cscrm__Account__c= :acc.id];
        List<SiteSQCheckController.SubWrapper> subWrap=SiteSQCheckController.getLatestSq(siteRec.Id);
        Test.stopTest();
        system.assert(subWrap!=null, true);
    }

    /*************************************************************************************************
    Name : testSiteStatusUpdate
    DIGI-> 335
    Author: Nitin Kumar
    Description : Test method for ServiceQualTriggerHandler.resetLatestRecFlgSrvQual
    ***********************************************************************************************/
    @isTest
    public static void testSiteStatusUpdate(){
       
       List<Service_Qualification__c> sqList = [Select id,Status__c,isLatestValidResult__c,LastModifiedDate,Technology_Type__c,Site__c from Service_Qualification__c where isLatestValidResult__c=True];
       List<Service_Qualification__c> newSQList = new List<Service_Qualification__c>();
       for(Service_Qualification__c sq:sqList){
          Service_Qualification__c sqRec = new Service_Qualification__c();
          sqRec.isLatestValidResult__c = true; 
          sqRec.Technology_Type__c= sq.Technology_Type__c;
          sqRec.Site__c=sq.Site__c;
          sqRec.status__c = 'Available';
          sqRec.Location_ID__c = 'LOC00014519312';// DIGI-26327
          newSQList.add(sqRec);
       }
       insert newSQList;
       
       cscrm__Site__c siteRec = [select Id,T_Fibre_Serviceability_Status__c,NBN_EE_Serviceability_Status__c,NBN_Serviceability_Status__c, NBN_Location_ID__c from cscrm__Site__c where id =: sqList[0].site__c ];
       system.assertEquals(siteRec.T_Fibre_Serviceability_Status__c,'Available');
       system.assertEquals(siteRec.NBN_EE_Serviceability_Status__c,'Available');
       System.assertEquals(siteRec.NBN_Location_ID__c, 'LOC00014519312');
    }
    /*************************************************************************************************
    Name : testlogException
    DIGI-> 2540
    Author: Ajith Kumar
    Description : Test method for SiteSQCheckController.logException
    ***********************************************************************************************/
    @isTest
    public static void testlogException(){
        Test.startTest();
        try{
            List<SiteSQCheckController.SubWrapper> subWrap=SiteSQCheckController.getLatestSq(null);
            SiteSQCheckController.logException(null,null);
        }
        catch(NullPointerException ex){            
            system.assertEquals(ex.getMessage(),'Null Pointer exception');
        }        
        Test.stopTest();
    }
}