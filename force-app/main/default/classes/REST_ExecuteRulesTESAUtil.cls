/*
* @Author :  Srujana Durvasula
* @Date   :  9 September 2020
* @Desc   :  Expose API end point to enable Execution of Product rules to Validate and Save products to basket.
* @Jira   :  P2OB-9124 
*/

@RestResource(urlMapping='/ExecuteRulesTESA/*')
global with sharing class REST_ExecuteRulesTESAUtil{  

    public static String productBasketId;
    //public static Integer batchSize= Integer.valueOf([Select Size_Value__c	from Batch_Size_CSRule__mdt where DeveloperName='BatchSizeforTESA'].Size_Value__c);
    //batch size configurable in BatchSizeforTESA CustomRule
    public static Integer batchSize = Integer.valueOf(System.Label.BatchSizeforTESA);
	    
    // HttpPost method invokes BatchClass for valid BasketID to execute product rules defined using CloudSense
    @HttpPost
    global static void doPost(String basketId) {
           try{
               	 if(basketId != null){                               
                        List<cscfga__Product_Basket__c> productBaskets = [Select id from cscfga__Product_Basket__c where Id =: basketId];
                        productBasketId = productBaskets[0].id; 
                        //Invoking BatchClass with BasketId and BatchSize as 1
                        ExecuteRulesInBatch myBatchObject = new ExecuteRulesInBatch(productBasketId); 
                        Id batchId = Database.executeBatch(myBatchObject,batchSize);   
                    }
                   else{ //To handle Null Basket Scenario
                        RestContext.response.statusCode = 500;
                        //RestContext.response.responseBody = Blob.valueOf('FAILURE, BAD_REQUEST');
                   }
            }        	
        	catch(System.Exception e){ //To handle InvalidBasketId and something else happens
                 RestContext.response.statusCode = 500;
                 RestContext.response.responseBody = Blob.valueOf(e.getMessage());
                 System.debug('e:' + e.getMessage());
            }        	
	}
    
  }