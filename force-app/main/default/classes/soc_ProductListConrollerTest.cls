/*****************************************************************************
@Author: nitesh
@CreateDate: 30/08/2018
@ModifiedByandDate: 
@Description: This Class is created to cover the test coverage
soc_ProductListController = 100%
*******************************************************************************/
@isTest
public class soc_ProductListConrollerTest {
    
    
     @isTest
  public  static void test_PicklistTest(){
      
   		
   		 test.startTest();
        String[] resultMap=soc_ProductListController.picklist_values('Case','Status');
          test.stopTest();
      
      System.assert(resultMap!=null);
       
  }
    
  /*@isTest
  public  static void testProductList(){
      
   		 OpportunityLineItem oppLine = soc_TestUtility.createOpportunityLineItem();
      	String recId_SFD_ProductType=[Select id from RecordType where sObjectType = 'Case' and DeveloperName ='soc_SFD_Product' ].id;
      
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.OpportunityId__c = oppLine.OpportunityId;
        caseObj.RecordTypeId=recId_SFD_ProductType;
   		 test.startTest();
      	 insert caseObj;
         Map<String,Object> results=soc_ProductListController.getProductList(caseObj.id);
         String status=(String)results.get('status');
         system.assert(status!=null);
          test.stopTest();
       
  }
    
    
    
    /*@isTest
  public  static void testProductListSave(){
      
   		 OpportunityLineItem oppLine = soc_TestUtility.createOpportunityLineItem();
      	String recId_SFD_ProductType=[Select id from RecordType where sObjectType = 'Case' and DeveloperName ='soc_SFD_Product' ].id;
        List<SObject> newList=new List<SObject>();
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.OpportunityId__c = oppLine.OpportunityId;
        caseObj.RecordTypeId=recId_SFD_ProductType;
        newList.add(caseObj);
   		 test.startTest();
         Map<String,Object> results=soc_ProductListController.saveProductList(newList);
         String status=(String)results.get('status');
         system.assert(status!=null);
          test.stopTest();
       
  }
    
     @isTest
  public  static void testProductListSave2(){
      
   		 OpportunityLineItem oppLine = soc_TestUtility.createOpportunityLineItem();
      	String recId_SFD_ProductType=[Select id from RecordType where sObjectType = 'Case' and DeveloperName ='soc_SFD_Product' ].id;
        List<SObject> newList=new List<SObject>();
        
        newList.add(oppLine);
   		 test.startTest();
         Map<String,Object> results=soc_ProductListController.saveProductList(newList);
         String status=(String)results.get('status');
         system.assert(status!=null);
          test.stopTest();
       
  }
    
    @isTest
  public  static void test_FieldDependency(){
      
   		
   		 test.startTest();
        Map<String, List<String>> resultMap=soc_ProductListController.getDependentMap(new Case(),'soc_SFD_Product_Status__c','soc_SFD_Sub_Status__c');
          test.stopTest();
      
      System.assert(resultMap!=null);
       
  }*/
    
    
   
    
   

        

}