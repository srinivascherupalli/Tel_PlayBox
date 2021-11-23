/*---------------------------
Class Updated by Ayush(Appirio) 
for story number P2OB-7585 
Date - 30th June 2020
-----------------------------*/
@istest 
public class PRMWebtoLeadContrTest {
    @isTest
    public static void testSaveLead(){
        //String abrResultsString = '{"entityName": "TELSTRA CORPORATION LIMITED","listBusinessName": ["somestring1", "somestring2"],"noOfYrsInBusiness": 1}';
        Test.setMock(HttpCalloutMock.class, new PRMWebToLeadContrMock());
        PRMWebtoLeadContr.ABRResults abrResult = new PRMWebtoLeadContr.ABRResults();
        PRMWebtoLeadContr newCntr=new PRMWebtoLeadContr();
        Test.startTest();

        Lead s = new Lead(lastname='acbc',firstname='TestClassLead',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByName().get('TE-A Partner Expression of Interest').getRecordTypeId(),
                        phone='031245678',ABN__c='123',Lead_Type__c='Call Me Now',Lead_Source_Original__c='Events',CIDN__c='123445',status='open');
        String token = '03AOLTBLQ4Gwm5HLUoXdpdV385bBHolYIx2xkQ8HrdXismvBCeMg94ozvgPE0qS-X1UXkmN3793ExJIvrSDJa8B8SLfXXq2DU8VbQ--8Tt6iOJc5WIyRe7jzdaSqkbd4L9B2yb5ATKTMtiKkmyaIGd8rYYefy-H1bBD2WYUqFXgR7NflLy8LI3a4hESTNnSOMsFmgwvz2RqsNZsT5Srkmuh7NlFZR2LrVC7EcSroHOQS45kni5Y8O28C1plXxV9vtgKTQysNeqIR9Kwzr74m7LWKRvoh9IfQLgeVJMdP-5GYBC6PZqYYLHw6T1Uc3T6hASC9Oa2SA2HpEe-_hkKTjqjwcyJ3YCwWRJzQ';
        PRMWebtoLeadContr.saveLead(s,token);
        Test.stopTest();
        
        List<Lead> leadList = [Select id from lead where firstname='TestClassLead'];
        if(!leadList.isEmpty()){
            system.assertNotEquals(null, leadList.get(0).id);
        }

    }
    @isTest
    public static void testABNService(){
        Test.startTest();
        String res = PRMWebtoLeadContr.callABNService('33051775556');
        String res1 = PRMWebtoLeadContr.callABNService('123');
        Test.stopTest();
        Map<String, Object> op =(Map<String, Object>)JSON.deserializeUntyped(res1);
        Boolean yearsCheck = Integer.valueOf(op.get('noOfYrsInBusiness'))>0 ? true : false;
        //Hawaii Fixes Sprint 20.09 (Ayush Appirio) - Assert updated because number of years will be calculated Dynamically
        system.assertEquals(true, yearsCheck);
        
    }
    @isTest
    public static void testIndustryVertical(){
        Test.startTest();
        Map<String,String> industryVertical = PRMWebtoLeadContr.getIndustryVertical();
        Test.stopTest();
        system.assertEquals(10, industryVertical.size());
    }
    @isTest
    public static void testPicklistValues(){
        Test.startTest();
        List<String> partnerCategories=PRMWebtoLeadContr.getpicklistvalues('Partner_categories__c');
        List<String> sourceInfo=PRMWebtoLeadContr.getpicklistvalues('Source_Info_Telstra_Channel_Partner_prog__c');
        List<String> annualRevenue=PRMWebtoLeadContr.getpicklistvalues('Annual_Revenue__c');
        Test.stopTest();
        System.assertEquals(9,partnerCategories.size());
        System.assertEquals(true,sourceInfo.size()>0);
        System.assertEquals(4,annualRevenue.size());
    }
    @isTest
    public static void testWebToLead(){
        Test.setMock(HttpCalloutMock.class, new PRMWebToLeadContrMock());
        Test.startTest();
        String thankYouURL = PRMWebtoLeadContr.CallWebToLead('testOrgId');
        Test.stopTest();
        system.assertEquals('nullthank-you', thankYouURL);
    }
    @isTest
    public static void testCommunityUrl(){
        Test.startTest();
        String commUrl = PRMWebtoLeadContr.getCommunityUrl();
        Test.stopTest();
        system.assertEquals(null, commUrl);
    }
}