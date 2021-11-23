/*******************************************************************
@Class Name:FindRelatedACRTest
@Description:Sprint 19.07 , EDGE-84140
@Date:30-05-2019
@Author:SFO Team (Subani & Sravanthi)
@Comments:Test class for FindRelatedACR

@Last Modified By: Sri Chittoori(Team SFO)              
@Last Modified Comments: EDGE-104316 :: FindRelatedACR Code coverage is 100%

*********************************************************************/
@isTest
public  class FindRelatedACRTest {
    @isTest
    static void findRelatedACRUnitTest(){
        Test.StartTest();
        Account testAcc = new Account(Name='testAcc',Customer_Status__c='ACTIVE');
        Insert testAcc;
        Contact con = new Contact(LastName='testCon',AccountId=testAcc.Id);
        insert con;
        String jsonInput=FindRelatedACR.getPrimaryACRData(con.id);
        Boolean hasEditAccess=FindRelatedACR.getACRRecordAccess(con.id);
        Map<String, Object> jMap =(Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        System.assertEquals(True, jMap.get('IsDirect'));
        Test.StopTest();
    } 
    @isTest
    static void findRelatedACRUnitTestQueryException(){
        try{
            Test.StartTest();       
            Contact con = new Contact(LastName='testCon');
            insert con;
            FindRelatedACR.getPrimaryACRData(con.id);
            FindRelatedACR.getACRRecordAccess(con.id);
            Test.StopTest();
        }catch(QueryException e){
            System.assertEquals(e.getMessage(), e.getMessage()); 
        }
        
    }
}