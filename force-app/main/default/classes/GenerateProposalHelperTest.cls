/*
* @Author :  Srujana Durvasula
* @Date   :  12 Jan 2021
* @Desc   :  TestClass for GenerateProposalHelper
* @Jira   :  P2OB-11268 
*/

@IsTest
public class GenerateProposalHelperTest {
    @isTest 
    static void getCongaURLPositive(){
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        //insert acc;
        System.assertNotEquals(null, acc);
    
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
    
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
    
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod, pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.Conga_Status__c = 'InProgress';
        insert opp;
          
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId=opp.id;
        otm.OpportunityAccessLevel='Read';
        otm.UserId=UserInfo.getUserId();
        insert otm;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
        Opportunity opp1 = [Select id,StageName,Conga_URL__c,Conga_Status__c from Opportunity where id =: prodbasket.cscfga__Opportunity__c limit 1];
        opp1.Conga_URL__c = '&Id=0064Y000002H0UAQA0&TemplateId=a6p4Y0000000YCo&FP0=0&QMode=Attachments&QueryId=[ProposalPCConfig]a6h4Y00000002hE?pv0=a3Q4Y0000005jsuUAA,[SolutionName]a6h4Y00000006y4?pv0=a3Q4Y0000005jsuUAA&OFN=StandardProductCatalog-DIP_NonAdapt- BT000-231-799';
        opp1.Conga_Status__c = 'Success';
        update opp1;
        Test.startTest();
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = 'Quote';
        template.Sequence__c = 1;
        INSERT template;
        
        APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
        query1.APXTConga4__Name__c = 'SPCGroupByProducts';
        insert query1;   
            
        List<String> nameOfTemplates = new list<String> {'Quote'};
        Map<String, String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates, 'template');
        System.assertNotEquals(null, mapOfTemplates);     
        
        GenerateProposalHelper.FlowInputs testData = new GenerateProposalHelper.FlowInputs();
        testData.basketId = prodbasket.Id;
        testData.templateName = 'Quote';

        //Test.startTest();

        List<Opportunity> listOfOpportunity;
       // GenerateProposalHelper generateProposal = new GenerateProposalHelper();
        try{
             listOfOpportunity = GenerateProposalHelper.createProposal(new List<GenerateProposalHelper.FlowInputs>{testData});

        } catch (Exception e) {
            System.assert(false, 'Exception ' + e.getStackTraceString());
        }
        Test.stopTest();
        System.assertNotEquals(listOfOpportunity, null, 'List should not be null');
    }

}