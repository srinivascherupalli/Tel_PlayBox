@isTest
public class ABNValidatorTest {

    static testMethod void validABN() {
        Test.startTest();
        System.debug('ABNValidatorTest.validABN()');
        System.assertEquals(true, ABNValidator.runValidation('51824753556'));
        Test.stopTest();
    }

    static testMethod void invalidABN_1() {
        Test.startTest();
        System.assertEquals(false, ABNValidator.runValidation('51824753557'));
        Test.stopTest();
    }

    static testMethod void invalidABN_2() {
        Test.startTest();
        System.assertEquals(false, ABNValidator.runValidation('12345'));
        Test.stopTest();
    }

}