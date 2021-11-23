/***********************************************************************************************
Name          : SolutionGetAllowanceDataTest
Created By    : Mahaboob Basha
Created Date  : July 03 2019
Description   : This is a test class to simulate and test the logic of SolutionGetAllowanceData
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        03-07-2019      Created
1.2         Mahaboob        03-07-2019      Added methods getDataTest
2.          shubhi          07-05-2020      Edge-120919
**********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionGetAllowanceDataTest {
    // edge-120919 created testdata method separately
    @testSetup
    static void testData(){
         cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c(Name = 'Test priceItem');
        INSERT priceItem;
        cspmb__Add_On_Price_Item__c addOn = new cspmb__Add_On_Price_Item__c(AOPI_External_Id__c = '12345', External_Id__c = '1234', ProdSpecId__c = '123');
        INSERT addOn;
        cspmb__Usage_Type__c usageType = new cspmb__Usage_Type__c(cspmb__type__c = 'Single', cspmb__unit_of_measure__c = 'Minute');
        INSERT usageType;
        List<cspmb__Allowance__c> allowaceList=new List<cspmb__Allowance__c>();
        cspmb__Allowance__c allowance = new cspmb__Allowance__c(External_Id__c = '12345', cspmb__usage_type__c = usageType.Id);
        INSERT allowance;
        // start edge-120919
        List<cspmb__Commercial_Product_Allowance_Assoc__c> allowanceAssociatonList=new List<cspmb__Commercial_Product_Allowance_Assoc__c>();
        cspmb__Commercial_Product_Allowance_Assoc__c piAllowAssoc1 = new cspmb__Commercial_Product_Allowance_Assoc__c(cspmb__commercial_product__c = priceItem.Id, cspmb__allowance__c = allowance.Id);
        allowanceAssociatonList.add(piAllowAssoc1);
        cspmb__Commercial_Product_Allowance_Assoc__c piAllowAssoc2 = new cspmb__Commercial_Product_Allowance_Assoc__c(cspmb__add_on__c = addOn.Id, cspmb__allowance__c = allowance.Id);
       allowanceAssociatonList.add(piAllowAssoc2);
        insert allowanceAssociatonList;
         //added profile and user for edge-120919
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;  
    	//end edge-120919
    
    }
    
    /************************************************************************************************
    * Method Name : getDataTest
    * Description : Used to simulate and test the logic of getData method in SolutionGetAllowanceData
    * Parameters  : NA
    * Return      : NA                      
    ************************************************************************************************/
    static testmethod void getDataTest() {
        Test.startTest();
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> inputMap = new Map<String,Object>();
        cspmb__Price_Item__c priceItem=[Select id from cspmb__Price_Item__c limit 1];
        cspmb__Add_On_Price_Item__c addOn=[Select id from cspmb__Add_On_Price_Item__c limit 1];
        User sales=[Select id from User limit 1];// edge-120919
        system.Runas(sales){
        inputMap.put('priceItemId', priceItem.Id);
        inputMap.put('addOnPriceItemId', addOn.Id);
        result = SolutionGetAllowanceData.getData(inputMap);
        System.assertNotEquals(NULL, result);
        System.assert(result.size() > 0);
        System.assert(result.containsKey('allowances'));
        }
        Test.stopTest();
    }
}