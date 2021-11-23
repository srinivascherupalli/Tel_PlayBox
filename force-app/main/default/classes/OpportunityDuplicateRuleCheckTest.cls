/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Test Coverage for OpportunityDuplicateRuleCheck and CloseOppFlowDuplicateCheck
Author      	- Amar Chakka. 
************************************************************************************************************ */
@isTest
public class OpportunityDuplicateRuleCheckTest {
    @testSetup
    public static void createData(){
        List<user> userList = new List<user>();
        User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        admin.Phone = '0444444444';
        userList.add(admin);
        insert userList;
        
        System.runAs(admin){
            Account customerAccount=TestUtil.createAccount('Testacc');
            customerAccount.OwnerId=admin.id;
            customerAccount.CIDN__c='484450740';
            customerAccount.Customer_Status__c = 'Active';
            insert customerAccount;
            
            
            Id pricebookId = Test.getStandardPricebookId();
            
            //CREATE Pricebook
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
            insert pbk1;
            
            //CREATE Product
            Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
            insert prd1;
            
            //CREATE PricebookEntry
            PricebookEntry pbEntry = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
            insert pbEntry;
            
            //CREATE Opportunities
            List<Opportunity> oppList = new List<Opportunity>();
            for(integer i=0;i<5;i++){
                Opportunity opp = TestUtil.createOpportunity(customerAccount.id);
                opp.Name='testopporunityDuplicateCheck'+i;
                //P2OB-6787 , Bypassed the NPSS field population for modular opportunities.
                opp.Product_Type__c =Label.Opp_ProductType_NonModular;
                if(i == 4){
                    opp.Product_Type__c = Label.Opp_ProductType_Modular;
                }
                oppList.add(opp);
            }
            insert oppList;
            
            
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            for(integer i=0;i<5;i++){
                OpportunityLineItem oppLineItem = TestUtil.createOpportunityLineItem(oppList[i].id);
                oppLineItem.PriceBookEntryID=pbEntry.id;
                oppLineItem.Product_Code__c ='Test_ProductCode'+i;
                oppLineItem.Product_Status__c = 'WON';
                oppLineItem.Renewal_Revenue__c = 10.00;
                oppLineItem.Incremental_Revenue__c = 20.00;
                
                oppLineItemList.add(oppLineItem);
            }
            
            insert oppLineItemList;
            
        }
    }
    
    
    /* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Test Coverage for OpportunityDuplicateRuleCheck(dupOppCheck Method) and CloseOppFlowDuplicateCheck(invokeThisFromFlow)
Author      	- Amar Chakka. 
************************************************************************************************************ */            
    
    @isTest
    static void oppDuplicateCheeck(){   
        Opportunity opp1 = [SELECT id from Opportunity where Name = 'testopporunityDuplicateCheck0'];
        test.starttest();
        OpportunityDuplicateRuleCheck.OppInfo oppdupResult = OpportunityDuplicateRuleCheck.dupOppCheck(opp1?.id);
        system.assert(oppdupResult?.duplicateOpp,true);
        CloseOppFlowOppDupCheck.FlowInputs fInpsCls = new CloseOppFlowOppDupCheck.FlowInputs();
        fInpsCls.oppId = opp1?.id;
        CloseOppFlowOppDupCheck.invokeLocalMethodWon(fInpsCls);
        
        
        list<CloseOppFlowOppDupCheck.FlowInputs> lflowInput = new list<CloseOppFlowOppDupCheck.FlowInputs>();
        lflowInput.add(fInpsCls);
        CloseOppFlowOppDupCheck.invokeThisFromFlow(lflowInput);
        
        Opportunity opp4 = [SELECT id,Product_Type__c from Opportunity where Name = 'testopporunityDuplicateCheck4'];
        system.debug('Modular Opp is Result is '+opp4);
        OpportunityDuplicateRuleCheck.OppInfo oppdupResult1 = OpportunityDuplicateRuleCheck.dupOppCheck(opp4?.id);
        system.debug('Modular Opp is Result is '+oppdupResult1);
        system.assertEquals(oppdupResult1?.duplicateOpp,false);
        test.stoptest();
    }
}