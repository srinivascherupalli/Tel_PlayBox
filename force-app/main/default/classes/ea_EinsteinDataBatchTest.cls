/**
* Author : Shreyansh Sharma(Jaipur)
* Date : 5/24/2021
* Description: P2OB-14430, Test class for ea_EinsteinDataBatch
**/
@isTest(seeAllData=false)
public class ea_EinsteinDataBatchTest {
    
    public static String recId_SalesChildSupport= Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    public static Id einsteinQueue = [select id,developerName from group where developerName = 'Pending_Einstein_Processing_Do_not_use' LIMIT 1].id; 

    @testSetup
    static void setup(){
        
          Id queueId = [select id,developerName from group where developerName = 'Pending_Einstein_Processing_Do_not_use'].id;

         Account customerAccount=TestUtil.createAccount('Testacc');
        customerAccount.APTPS_Off_Shore_Restricted__c = true;
        insert customerAccount;
        
          Case   caseObj2 = new Case();
            caseObj2.OwnerId = queueId;
            caseObj2.subject = 'Test Case Record1 ';
            caseObj2.Status = 'New';
            caseObj2.soc_SFD_Offshore_Restricted__c =false;
            caseObj2.description = 'Test Case description';
            caseObj2.salesup_No_of_sites_or_services__c= 1;
            caseObj2.ss_Type__c= 'Billing';
           
            caseObj2.AccountId=customerAccount.id;//P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
            caseObj2.RecordTypeId = recId_SalesChildSupport;
         //   CasesOfService.add(caseObj);
        
        insert caseObj2;
    }
 	//Check for Service Fnn request, offshore true
    static testMethod void ServicePosTest(){
        
        test.startTest();
       Case cs = [select id,soc_FNNs__c,subject from case where subject ='Test Case Record1' LIMIT 1];
 		cs.soc_FNNs__c = 'N0020353R';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
        ea_EinsteinDataBatch.resultDummy = '{"action":"query","responseId":"4cMeSKuQ2QpfQkAxpifVsV","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"q.VisibleSvcDescription","type":"string"},"inputs":[{"id":"q.VisibleSvcDescription"}]},{"field":{"id":"q.Svc_Type","type":"string"},"inputs":[{"id":"q.Svc_Type"}]}]},"queryLanguage":"SAQL"}],"records":[{"Svc_Type":"DATA","VisibleSvcDescription":"N0020353R"}]},"query":"q = load'+'0Fb5P0000002znvSAA/0Fc5P000000A3THSA0'+';q = filter q by '+'VisibleSvcDescription'+' in [N0020353R];q = foreach q generate '+'VisibleSvcDescription'+','+'Svc_Type'+';q = limit q 20;","responseTime":6}';
        Database.executeBatch(M,1);
        Case cs1 = [select id,soc_SFD_Offshore_Restricted__c,subject from case where subject ='Test Case Record1' LIMIT 1];
       system.assertEquals(true, cs1.soc_SFD_Offshore_Restricted__c);
     
        
        test.stopTest();
        
    }
    //Check for Customer Acc no. value. offshore true
    static testMethod void BillPosTest(){
        
        test.startTest();
        Case cs = [select id,soc_FNNs__c,subject from case where subject ='Test Case Record1' LIMIT 1];
 		cs.Salesup_Customer_Account_Number__c = '2156215800';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
        ea_EinsteinDataBatch.resultDummy = '{"action":"query","responseId":"4cMw5S9iQE1RJk9lZjigt-","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"q.Billing_Account_Info","type":"string"},"inputs":[{"id":"q.Billing_Account_Info"}]},{"field":{"id":"q.count","type":"numeric"}}],"input":{"type":"group","groups":[{"id":"q.Billing_Account_Info"}]}},"queryLanguage":"SAQL"}],"records":[{"Billing_Account_Info":"2156215800 FlexCAB","count":7},{"Billing_Account_Info":"2156215800 FlexCAB","count":7}]},"query":"q = load'+'0Fb5P0000002znvSAA/0Fc5P000000A3THSA0'+';'+'q = group q by '+'Billing_Account_Info'+';'+'q = filter q by '+'Billing_Account_Info'+' like 2156215800%MICA &#124;&#124; '+'Billing_Account_Info'+' like 2156215800%FlexCAB;q = foreach q generate '+'Billing_Account_Info'+','+' count() as '+'count'+';'+'q = limit q 20;","responseTime":8516}';
        Database.executeBatch(M,1);
        
      Case cs1 = [select id,soc_SFD_Offshore_Restricted__c,subject from case where subject ='Test Case Record1' LIMIT 1];
       system.assertEquals(true, cs1.soc_SFD_Offshore_Restricted__c);
        
        test.stopTest();
        
    } 
    //Check for Customer Acc no. value. No bill product
     static testMethod void BillNegTest(){
        
        test.startTest();
        Case cs = [select id,soc_FNNs__c,subject from case where subject ='Test Case Record1' LIMIT 1];
 		cs.Salesup_Customer_Account_Number__c = '1';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
        ea_EinsteinDataBatch.resultDummy = '{"action":"query","responseId":"4cMw5S9iQE1RJk9lZjigt-","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"q.Billing_Account_Info","type":"string"},"inputs":[{"id":"q.Billing_Account_Info"}]},{"field":{"id":"q.count","type":"numeric"}}],"input":{"type":"group","groups":[{"id":"q.Billing_Account_Info"}]}},"queryLanguage":"SAQL"}],"records":[{"Billing_Account_Info":"2156215800 FlexCAB","count":7},{"Billing_Account_Info":"2156215800 FlexCAB","count":7}]},"query":"q = load'+'0Fb5P0000002znvSAA/0Fc5P000000A3THSA0'+';'+'q = group q by '+'Billing_Account_Info'+';'+'q = filter q by '+'Billing_Account_Info'+' like 123%MICA &#124;&#124; '+'Billing_Account_Info'+' like 123%FlexCAB;q = foreach q generate '+'Billing_Account_Info'+','+' count() as '+'count'+';'+'q = limit q 20;","responseTime":8516}';

        Database.executeBatch(M,1);
        
       Case cs1 = [select id,ss_billing_Product__c,subject from case where subject ='Test Case Record1' LIMIT 1];
       system.assertEquals(NULL, cs1.ss_billing_Product__c);
        
        test.stopTest();
        
    }
    //Check for Service Fnn request , no bill prod
   static testMethod void ServNegTest(){
        
        test.startTest();
        Case cs = [select id,soc_FNNs__c,subject from case where subject ='Test Case Record1' LIMIT 1];
 		cs.soc_FNNs__c = '1';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
        ea_EinsteinDataBatch.resultDummy = '{"action":"query","responseId":"4cMeSKuQ2QpfQkAxpifVsV","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"q.VisibleSvcDescription","type":"string"},"inputs":[{"id":"q.VisibleSvcDescription"}]},{"field":{"id":"q.Svc_Type","type":"string"},"inputs":[{"id":"q.Svc_Type"}]}]},"queryLanguage":"SAQL"}],"records":[{"Svc_Type":"Test","VisibleSvcDescription":"123"}]},"query":"q = load'+'0Fb5P0000002znvSAA/0Fc5P000000A3THSA0'+';q = filter q by '+'VisibleSvcDescription'+' in [123];q = foreach q generate '+'VisibleSvcDescription'+','+'Svc_Type'+';q = limit q 20;","responseTime":6}';

        Database.executeBatch(M,1);
        
      	Case cs1 = [select id,ss_billing_Product__c,subject from case where subject ='Test Case Record1' LIMIT 1];
        system.assertEquals(NULL, cs1.ss_billing_Product__c);
        
        test.stopTest();
        
    }
    //Check for Customer Acc no. value. offshore true
     static testMethod void BillNegTestAcc(){
        
        test.startTest();
        Account acc = [select id,APTPS_Off_Shore_Restricted__c from Account where Name = 'Testacc' LIMIT 1];
        acc.APTPS_Off_Shore_Restricted__c = false;
        update acc;
         
        Case cs = [select id,soc_FNNs__c,subject from case where subject ='Test Case Record1' LIMIT 1];
 		cs.Salesup_Customer_Account_Number__c = '1';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
        ea_EinsteinDataBatch.resultDummy = '{"action":"query","responseId":"4cMw5S9iQE1RJk9lZjigt-","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"q.Billing_Account_Info","type":"string"},"inputs":[{"id":"q.Billing_Account_Info"}]},{"field":{"id":"q.count","type":"numeric"}}],"input":{"type":"group","groups":[{"id":"q.Billing_Account_Info"}]}},"queryLanguage":"SAQL"}],"records":[{"Billing_Account_Info":"2156215800 FlexCAB","count":7},{"Billing_Account_Info":"2156215800 FlexCAB","count":7}]},"query":"q = load'+'0Fb5P0000002znvSAA/0Fc5P000000A3THSA0'+';'+'q = group q by '+'Billing_Account_Info'+';'+'q = filter q by '+'Billing_Account_Info'+' like 123%MICA &#124;&#124; '+'Billing_Account_Info'+' like 123%FlexCAB;q = foreach q generate '+'Billing_Account_Info'+','+' count() as '+'count'+';'+'q = limit q 20;","responseTime":8516}';

        Database.executeBatch(M,1);
        
     	 Case cs1 = [select id,soc_SFD_Offshore_Restricted__c,subject from case where subject ='Test Case Record1' LIMIT 1];
       system.assertEquals(true, cs1.soc_SFD_Offshore_Restricted__c);
        
        test.stopTest();
        
    }
   static testMethod void ServNegTestAcc(){
        test.startTest();
        Account acc = [select id,APTPS_Off_Shore_Restricted__c from Account where Name = 'Testacc' LIMIT 1];
        acc.APTPS_Off_Shore_Restricted__c = false;
        update acc;
       
        Case cs = [select id,soc_FNNs__c,subject,ss_billing_Product__c from case where subject ='Test Case Record1' LIMIT 1];
 		cs.soc_FNNs__c = '1';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
        ea_EinsteinDataBatch.resultDummy = '{"action":"query","responseId":"4cMeSKuQ2QpfQkAxpifVsV","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"q.VisibleSvcDescription","type":"string"},"inputs":[{"id":"q.VisibleSvcDescription"}]},{"field":{"id":"q.Svc_Type","type":"string"},"inputs":[{"id":"q.Svc_Type"}]}]},"queryLanguage":"SAQL"}],"records":[{"Svc_Type":"Test","VisibleSvcDescription":"1"}]},"query":"q = load'+'0Fb5P0000002znvSAA/0Fc5P000000A3THSA0'+';q = filter q by '+'VisibleSvcDescription'+' in [1];q = foreach q generate '+'VisibleSvcDescription'+','+'Svc_Type'+';q = limit q 20;","responseTime":6}';
		Database.executeBatch(M,1);
        system.assertNotEquals('DATA', cs.ss_billing_Product__c);
     
        
        test.stopTest();
        
    }
    //get the DML error
    static testMethod void ServNegTestAccTrueDMLEr(){
        test.startTest();
       
        Case cs = [select id,soc_FNNs__c,lastmodifieddate,subject from case where subject ='Test Case Record1' LIMIT 1];
 		cs.soc_FNNs__c = '1';    
        update cs;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes ='{"name":"Test"}';
		Database.executeBatch(M,1);
        
        system.assertNotEquals(system.now(), cs.lastmodifieddate);
        
        test.stopTest();
        
    }
    //test case for blank service and customerAccNo.
    static testMethod void ServCANBlank(){
        test.startTest();
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
		Database.executeBatch(M,1);
        Case cs = [select id,OwnerId,subject from case where subject ='Test Case Record1' LIMIT 1];

        system.assertEquals(einsteinQueue, cs.OwnerId);
        
        test.stopTest();
        
    }
    static testMethod void ServCANBlankNegTest(){
        test.startTest();

        Account acc = [select id,APTPS_Off_Shore_Restricted__c from Account where Name = 'Testacc' LIMIT 1];
        acc.APTPS_Off_Shore_Restricted__c = false;
        update acc;
        
        ea_EinsteinDataBatch  M = new ea_EinsteinDataBatch();
        ea_EinsteinDataBatch.jsonRes = '{"name":"Test"}';
		Database.executeBatch(M,1);
        Case cs = [select id,OwnerId,subject from case where subject ='Test Case Record1' LIMIT 1];

        system.assertEquals(einsteinQueue, cs.OwnerId);
        
        test.stopTest();
        
    }
    
}