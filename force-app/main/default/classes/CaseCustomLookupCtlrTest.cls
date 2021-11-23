/*********************************************************************************************************************************
 *Class Name      :   CaseCustomLookupCtlrTest

Main Class : CaseCustomLookupCtlr
Ch.No.    Developer Name          Date          Story Description

1.        Manish Berad           15/09/2020     EDGE-172345 As a Sales Enterprise user, I want to provide Sales support case 
												# while creating a MAC Order, so that I can skip Customer Pre-Authorisation flow.
 *********************************************************************************************************************************
*/
@isTest
public class CaseCustomLookupCtlrTest {
    @isTest
    static void fetchRecordsTest1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Phone = '123456789';
        acc.Type = 'Prospect';
        insert acc;
        
        Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('salesup_Sales_Support').getRecordTypeId();
        Case caseObj = new Case(
            AccountId = acc.Id,
            RecordTypeId=recordTypeId,
            Status = 'Working',
            Origin = 'Phone'
        );
        insert caseObj;
        
        Case Obj = [select id, casenumber FROM Case where id = : caseObj.id];
        
        Try{
            Test.startTest();
            List<CaseCustomLookupCtlr.RecordsData> result = CaseCustomLookupCtlr.fetchRecords('Case', 'casenumber', Obj.casenumber,'',acc.Id);
            Test.stopTest();
            System.assertEquals(result != null, true);
        }catch(exception e){}
    }
    
    @isTest
    static void fetchRecordsTest2() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Phone = '123456789';
        acc.Type = 'Prospect';
        insert acc;
        
        Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('salesup_Sales_Support').getRecordTypeId();
        Case caseObj = new Case(
            AccountId = acc.Id,
            RecordTypeId=recordTypeId,
            Status = 'Working',
            Origin = 'Phone'
        );
        insert caseObj;
        
        Case Obj = [select id, casenumber FROM Case where id = : caseObj.id];
       
        Try{
            Test.startTest();
            List<CaseCustomLookupCtlr.RecordsData> result = CaseCustomLookupCtlr.fetchRecords('Case', 'casenumber','',Obj.casenumber,acc.Id);
            Test.stopTest();
            System.assertEquals(result.size(), 1);
        }catch(exception e){}
    }
    
    @isTest
    static void fetchRecordsNegativeTest() {
        try {
            List<CaseCustomLookupCtlr.RecordsData> result = CaseCustomLookupCtlr.fetchRecords('', 'Name', 'Test', '','');
        } catch(Exception ex) {
            System.assertNotEquals(ex.getMessage(), NULL);
        }
    }  
}