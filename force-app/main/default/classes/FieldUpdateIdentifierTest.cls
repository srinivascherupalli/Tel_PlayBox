@isTest
public class FieldUpdateIdentifierTest {
@isTest
static void testFieldUpdateIdentifier(){
    test.startTest();   
    FieldUpdateIdentifier fuObj=new FieldUpdateIdentifier(Account.sObjectType);
    system.assertNotEquals(Null, fuObj);
    test.stopTest(); 
}
@isTest
        static void testFieldUpdateIdentifier1(){
        test.startTest();   
        FieldUpdateIdentifier fuObj=new FieldUpdateIdentifier(Account.sObjectType,Label.CustomerMS_Integration);
        system.assertNotEquals(Null, fuObj);
        test.stopTest(); 
        }
}