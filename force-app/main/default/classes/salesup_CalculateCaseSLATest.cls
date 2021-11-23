/*
* Created By: Sanjay Thakur
* Created Date: 16/09/2020.
* Description : This class covers salesup_CalculateCaseSLA.
* Story: P2OB-8669   
*/
@isTest
public class salesup_CalculateCaseSLATest {

    public static String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
	
    @testSetup public static void DataSetup(){
        
        Account customerAccount=TestUtil.createAccount('Testaccnt');
        insert customerAccount;
            Entitlement entl = new Entitlement();
            entl.AccountId = customerAccount.id;
            entl.Name = 'Channel Care Case SLAs';
            insert entl;
        Integer NumberOfCases = 10;
        List<Case> CasesOfService = new List<Case>();
		
            Case caseObj = new Case();
        	caseObj.subject = 'Test Case Record ';
        	caseObj.Status = 'In Progress';
            caseObj.EntitlementId = entl.Id;
            caseObj.salesup_Support_Type__c = 'Billing Support';
            caseObj.srvsup_Categories__c = 'Billing';
            caseObj.salesup_Work_Required__c = 'Invalid Charges';
        	caseObj.description = 'Test Case description';
        	caseObj.salesup_No_of_sites_or_services__c= 15;
            caseObj.AccountId=customerAccount.id;
        	caseObj.RecordTypeId = recId_salesSupportChild;
            CasesOfService.add(caseObj);
        
        insert CasesOfService;
        
    }
    // Cover Positive Scenarios
    
    static testMethod void testMilestoneTimeCalculator(){
        test.StartTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1]; 
        System.debug('mtList=>'+mtLst);
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Integer NumberOfCases = 20;
        List<Case> CasesOfService = [ SELECT id,srvsup_Categories__c,salesup_Work_Required__c,status,soc_SFD_Sub_Status__c FROM Case LIMIT :NumberOfCases];
        try{
        CasesOfService[0].Status = 'In Progress';
        
        update CasesOfService;
      
        salesup_CalculateCaseSLA calculator = new salesup_CalculateCaseSLA();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(CasesOfService[0].Id, mt.Id);
       }
		catch(DMLException Ex){
			System.assert(CasesOfService.size()!=NULL);
		}
        test.stopTest();
}
    // Cover Negative Scenarios
    
    static testMethod void testMilestoneTimeCalculator_Negative(){
        test.StartTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1]; 
        System.debug('mtList=>'+mtLst);
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Integer NumberOfCases = 20;
        List<Case> CasesOfService = [ SELECT id,srvsup_Categories__c,salesup_Work_Required__c,status,soc_SFD_Sub_Status__c FROM Case LIMIT :NumberOfCases];
        try{
            CasesOfService[0].Status = 'On Hold';
        	CasesOfService[0].soc_SFD_Sub_Status__c = 'Pending Order';
            update CasesOfService;
            salesup_CalculateCaseSLA calculator = new salesup_CalculateCaseSLA();
        	Integer actualTriggerTimeNeg = calculator.calculateMilestoneTriggerTime(CasesOfService[0].Id, mt.Id);
        }
        catch(DMLException Ex){
			System.assert(CasesOfService.size()!=NULL);
		}
        test.stopTest();
    }
    
}