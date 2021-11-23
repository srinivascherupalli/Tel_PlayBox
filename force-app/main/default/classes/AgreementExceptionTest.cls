@IsTest
public with sharing class AgreementExceptionTest {
    @isTest 
    static void AgreementException(){
        test.startTest();
        String methodName = 'Test Method';
        String referenceNumber = '1234';
        String errorMessage='Error message';
        String businessDescription = 'Business Description';
        AgreementException agEX = new AgreementException(methodName,referenceNumber,errorMessage,businessDescription);
        test.stopTest();
        system.debug('agEX:'+agEX.methodName);
        system.assertEquals('Test Method', agEX.methodName);
        
    }

}