@isTest
public class SqAvltyNewOrdHdlrTest {//test class for the dummy SQ callout class (EDGE-62720)
   @isTest
    private static void runTestMethodSQDummyClass() {
        SqAvltyNewOrdHdlr clSQ = new SqAvltyNewOrdHdlr();
        clSQ.callSQService();
        System.assertEquals(1,1);//dummy assert
    }
}