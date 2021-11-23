@isTest
public class ACNValidatorTest {

    static testMethod void validACN() {
        Test.startTest();
        System.assertEquals(true, ACNValidator.runValidation('000000019'));
        Test.stopTest();
    }
    
    static testMethod void invalidACN_1() {
        Test.startTest();
        System.assertEquals(false, ACNValidator.runValidation('000000018'));
        Test.stopTest();
    }
    
    static testMethod void invalidACN_2() {
        Test.startTest();
        System.assertEquals(false, ACNValidator.runValidation('12345'));
        Test.stopTest();
    }

}