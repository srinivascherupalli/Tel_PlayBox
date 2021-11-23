/*------------------------------------------------
EDGE        - TED-383
Description - Test class for GetEchosignAgreementTemplate
Author      - Vamsi Krishna Vaddipalli
Date        - 07OCT2021
--------------------------------------------------*/
@isTest
public class GetEchosignAgreementTemplateTest {
  @IsTest
    static void getEchoSignAgreementTemplateIdsTest(){
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids = new List<echosign_dev1__Agreement_Template__c>();
        echosign_dev1__Agreement_Template__c templateid1 = new echosign_dev1__Agreement_Template__c();
        templateid1.name = 'CAF Flow';
        eSignTemplateids.add(templateid1);
        echosign_dev1__Agreement_Template__c templateid2 = new echosign_dev1__Agreement_Template__c();
        templateid2.name = 'BSA Flow';
        eSignTemplateids.add(templateid2);
        insert eSignTemplateids;
        Test.startTest();
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids1 = GetEchosignAgreementTemplate.getEchoSignAgreementTemplateIds();
        Test.stopTest();
        System.assert(eSignTemplateids1 != null);        
    }
    @IsTest
    static void getEchoSignAgreementTemplateIdsTestNegative(){
        Test.startTest();
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids1 = GetEchosignAgreementTemplate.getEchoSignAgreementTemplateIds();
        Test.stopTest();
        System.assert(eSignTemplateids1 == null);        
    }
}