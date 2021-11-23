@isTest
public class PickListControllerTest {
    @isTest
    public static void TestgetPickListValuesIntoList(){
		list<string> pickList=PickListController.getPickListValuesIntoList('Notification__c','eventType__c');
        system.debug('pickList ::: ' + pickList );
	
        system.assertEquals('delay', pickList[0]);
    }
}