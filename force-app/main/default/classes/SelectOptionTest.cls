@isTest
public class SelectOptionTest {
    @isTest
    static void optionsTest(){
        SelectOptionz test1;
    	SelectOptionz test2;
        Test.startTest();
        test1 = new SelectOptionz('value', 'label');
        test2 = new SelectOptionz('value', 'label', true);
        Test.stopTest();
        system.assert(test1!=null && test2!=null);
    }
}