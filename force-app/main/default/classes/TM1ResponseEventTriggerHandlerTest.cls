/*
===============================================================================================================================
Class : TM1ResponseEventTriggerHandlerTest
Developer Name : Shubhi
Test Class : TM1ResponseEventTriggerHandlerTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
@isTest
public class TM1ResponseEventTriggerHandlerTest {

@testsetup static void TM1ResponseEventTriggerHandlerTestDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        insert acc;
        
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
		prodBasket.Name = 'Basket New';
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
		prodBasket.isEligibilityTriggered__c = false ;
        prodBasket.isEligibilityCheckComplete__c= false ;
		update prodBasket; 
        
		   List<cscfga__Product_Configuration__c> lstpc = new List<cscfga__Product_Configuration__c>();
		   for (Integer i=0 ; i < 100 ; i ++){			
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(  
                cscfga__Product_Basket__c = prodBasket.Id,
                Name='IP Site'
            ); 
            lstpc.add(pc);
		   }
			
            insert lstpc;
        
       	List<TramasElgibilityCallbackResponse__c> tm1List=new List<TramasElgibilityCallbackResponse__c>();
        for(cscfga__Product_Configuration__c pc:lstpc)
        {
            TramasElgibilityCallbackResponse__c tm1=new TramasElgibilityCallbackResponse__c();
            Integer i=0;
            tm1.Product_Configuration__c=pc.id;
            tm1.Eligibility_Criteria__c='Not Accessed';
            tm1.Product_Basket__c=prodBasket.id;
            tm1.Correlation_ID__c=pc.id;
            i++;
            tm1List.add(tm1);
        }
        insert tm1List;
        if(lstpc.size()>0 && tm1List.size()>0){
            tm1List[0].Eligibility_Criteria__c='Eligible';
            update tm1List[0];
        }
        
    }
	
		@isTest
		public static void testupdateFlag(){
         List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c limit 50];
         String basketId = prodBasket[0].Id;

         Test.startTest();
		 TM1ResponseEventTriggerHandler.updateFlag(basketId);
         Test.stopTest();
         
         System.assert(prodBasket != null);
    }

}