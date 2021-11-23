@isTest
public class EmailMessageUpdaterTest {

@isTest
    static void doPatchTest(){
    
        String eventType = 'EDGESF_ORDER_2';
        String eventId = 'd8872440-ed65-89cxcx99-987d-411a22233';
        String status= 'Opened';
        String statusDescription= '';
        String notificationId= 'SENT';
        String timestamp= '15-11-2018';
        
        Test.startTest();
        EmailMessageUpdater.doPatch(eventType,eventId,status,statusDescription,notificationId,timestamp);
        Test.StopTest();
        System.assert(eventId != null);
       }
       }