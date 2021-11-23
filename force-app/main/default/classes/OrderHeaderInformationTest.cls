@isTest
private class OrderHeaderInformationTest 
{
    static testMethod void validateOrderHeaderInformation()
    {       
        List<ID> orderIdList =  new List<ID>();
        Account acc = new Account(Name='Test Account');
        csord__Order__c orderObj = ProductTestService.getNewOrderWithOrderHeader(acc);
        orderIdList.add(orderObj.id);
        OrderHeaderInformation.updateOrderHeaderInformation( orderIdList );
        
        csord__Order__c newOrderObj = new csord__Order__c();
        newOrderObj = [SELECT Opportunity_ID__c,Hot_Cutover__c,Hot_Cutover_Comments__c,Service_Number__c,Billing_Account__c,Project_ID__c,Project_Complexity__c,PM_Required__c,Project_Manager_User_ID__c,Project_Manager_Contact_Number__c,Project_Manager_Email__c from csord__Order__c LIMIT 1];
     
        System.assertEquals(newOrderObj.Opportunity_ID__c, '1111');
        System.assertEquals(newOrderObj.Service_Number__c, '22');
        System.assertEquals(newOrderObj.Hot_Cutover__c, true);
        System.assertEquals(newOrderObj.Hot_Cutover_Comments__c, 'Comments');
		System.assertNotEquals(newOrderObj.Billing_Account__c, null);
        System.assertEquals(newOrderObj.Project_ID__c,'acc01');
        System.assertEquals(newOrderObj.Project_Complexity__c , 'Complex');
        System.assertEquals(newOrderObj.PM_Required__c ,true);
        System.assertEquals(newOrderObj.Project_Manager_User_ID__c ,'test01');
        System.assertEquals(newOrderObj.Project_Manager_Contact_Number__c,'9985018467');
        System.assertEquals(newOrderObj.Project_Manager_Email__c,'test@gmail.com');
    }    
     
}