/*
* @Author : Ajith Kumar
* @Date : 2 AUG 2021
* @Desc : Service Qualification Tab controller  
* @Jira : DIGI-333
*/
@isTest
public class SQTabViewControllerTest {
    public static Service_qualification__c sq,sq1,sq2;
@TestSetup
    static void setup(){
        Account acc =TestUtil.createAccount('test');
        insert acc;
        Contact con = TestUtil.createContact(acc.id,'TestFirst','TestLast');
        insert con;
        Contact con2 = TestUtil.createContact(acc.id,'TestFirst2','TestLast2');
        insert con2;
        cscrm__Address__c addr = TestUtil.createAddress();
        addr.cscrm__Account__c = acc.Id;
        insert addr;
        cscrm__Site__c site = TestUtil.createSite(con.Id,con2.Id,acc.Id);
        site.cscrm__Installation_Address__c = addr.Id;
        site.Composite_Key__c = '1234';
        insert site;
        List<Service_qualification__c> serviceQual =new  List<Service_qualification__c>();
        sq=new Service_qualification__c();
        sq.Account__c=acc.Id;
        sq.Site__c = site.Id;
        sq.Technology_Type__c ='Telstra Fibre';
        sq.Address_ID__c  = '265742187';
        sq.isLatestValidResult__c = true;
        serviceQual.add(sq);
        sq1=new Service_qualification__c();
        sq.Account__c=acc.Id;
        sq1.Site__c = site.Id;
        sq1.Technology_Type__c ='Wireless';
        sq1.Address_ID__c  = '265742187';
        sq1.isLatestValidResult__c = true;
        serviceQual.add(sq1);
        sq2=new Service_qualification__c();
        sq2.Account__c=acc.Id;
        sq2.Site__c = site.Id;
        sq2.Technology_Type__c='Enterprise Ethernet Access Service';
        sq2.Address_ID__c  = '265742187';
        sq2.isLatestValidResult__c = true;
        serviceQual.add(sq2);
        insert serviceQual; 
        Service_Qualification_Provider_Resource__c serviceProvider = TestUtil.createSQProviderResource(serviceQual[1].Id);
        insert serviceProvider;
        
        Service_Qualification_Resource_Detail__c serviceDetail = TestUtil.createSQResource(serviceQual[1].Id);
        insert serviceDetail;
        
        Service_Qualification_Port_Detail__c servicePort = TestUtil.createPortDetails(serviceDetail.Id);
        insert servicePort;
            
    }
    public static testmethod void ValidateTelstraFibreSQ(){    
        Service_qualification__c sq=[select id,Site__c from Service_qualification__c where Technology_Type__c='Telstra Fibre'];        
        Carriage_Solutions__c carriagesol = TestUtil.createCarriageSolutions(sq.id);
        insert carriagesol;        
        Test.startTest();
        SQTabViewController.getServiceQualificationRecords(sq.Site__c);
        SQTabViewController.SQTabWrapper sqTelstraFibre=SQTabViewController.getServiceQualificationRecords(sq.Site__c);    
        System.assertEquals('Telstra Fibre',sqTelstraFibre.TelstraFibreSQ.Technology_Type__c);    
        Test.stopTest();
    }
    public static testmethod void ValidateNBESFibreSQ(){
        Service_qualification__c sq=[select id,Site__c from Service_qualification__c where Technology_Type__c='Wireless'];       
        Test.startTest();
            SQTabViewController.getServiceQualificationRecords(sq.Site__c);  
            SQTabViewController.SQTabWrapper sqNebsFibre=SQTabViewController.getServiceQualificationRecords(sq.Site__c);    
            System.assertEquals('Wireless',sqNebsFibre.NBESFibreSQ.Technology_Type__c);   
        Test.stopTest();
    }
    public static testmethod void ValidateNBNEternert(){
        Service_qualification__c sq=[select id,Site__c from Service_qualification__c where Technology_Type__c='Enterprise Ethernet Access Service'];
        Test.startTest();
            SQTabViewController.getServiceQualificationRecords(sq.Site__c);
            SQTabViewController.SQTabWrapper sqEthernet=SQTabViewController.getServiceQualificationRecords(sq.Site__c);    
            System.assertEquals('Enterprise Ethernet Access Service',sqEthernet.NBNEthernertSQ.Technology_Type__c);    
        Test.stopTest();
    } 
}