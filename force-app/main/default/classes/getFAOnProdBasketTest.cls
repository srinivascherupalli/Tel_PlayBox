/****************************************************************************************************************************************************
Main Class : getFAOnProdBasket
Test Class : getFAOnProdBasketTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story                       Description
1.        Parmanand           15-09-2020      DIGI-15376              
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest
public class getFAOnProdBasketTest {
    
    @isTest
    public static void fetchLookUpValues()
    {
        Account acc=TestUtil.createAccount('Test Account');
        insert acc;
        Contact con = TestUtil.createContact(acc.id,'Parma','test');
        insert con;
        opportunity opp = TestUtil.createOpportunity(acc.Id);
        opp.Pricing_Method__c = 'Delegated Pricing';
        insert opp;
        
        Delegated_Pricing_Request__c insertDPR = new Delegated_Pricing_Request__c();
        insertDPR.Description__c = 'Test';
        insertDPR.Opportunity__c = opp.id;
        insertDPR.isPrimary__c = False;
        insertDPR.Mark_as_Variation__c = False;
        insertDPR.Parent_DPR__c = 'Test';
        insert insertDPR;
        
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=opp.id;
        fam.csconta__Account__c=acc.Id;
        fam.csconta__Status__c = 'Active';
        fam.Delegated_Pricing_Request__c = insertDPR.Id;
        fam.isPrimary__c = true;

        fam.csconta__effective_start_date__c = Date.today().addDays(-2);
        fam.csconta__effective_end_date__c = Date.today().addDays(2);
        insert fam;
        List<csconta__frame_agreement__c>falist= [select Id, Name, csconta__Agreement_Name__c,Check_Todays_date__c,csconta__Account__c,csconta__status__c from csconta__frame_agreement__c];
        system.debug('falist'+falist);
        
        csconta__Account_Frame_Agreement_Association__c faAss = new csconta__Account_Frame_Agreement_Association__c();
        faAss.csconta__Account__c = acc.Id;
        faAss.csconta__Frame_Agreement__c = fam.id;
        insert faAss;
                
        Map<String, String> params = new Map<String, String>{'id'=>'','orderByCriteria' =>''};
        Test.startTest();
        String queryRes = getFAOnProdBasket.query(params,acc.Id);
        Test.stopTest();   
       System.assert(queryRes != null);
    }
}