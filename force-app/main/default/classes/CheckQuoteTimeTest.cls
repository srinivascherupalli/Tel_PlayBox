@isTest
public class CheckQuoteTimeTest {
    private static Quote quo;
    //test data
    static void setup() {
       DateTime myDateTime = DateTime.newInstance(2018, 2, 11, 8, 6, 16);
        //Account acc = new Account(Name='Test Account');
        //Insted of creating separate test data, using existing TestUtil factory method for creating Account. 
        //Sprint 19.17 P2OB-4149
       Account acc=TestUtil.createAccount('Test Account');
       insert acc;
       Opportunity opp=new Opportunity(Name='TestOpp', StageName='Define', CloseDate=myDateTime.date(),AccountId = acc.Id);
       insert opp;
       Quote quoNew=new Quote(Name='TestQuote');
       quoNew.OpportunityId=opp.Id;
       quoNew.Conga_Request_Time__c = system.now();
       insert quoNew;
       quo=[SELECT ID,CREATEDDATE,Conga_Request_Time__c FROM QUOTE WHERE ID=:quoNew.Id];
    }
    
    //In Progress status test case
    static testMethod void displayErrorInProgressTest(){
       setup();
       String result=CheckQuoteTime.displayError(quo.Id);
       System.assertEquals('InProgress',result);        
    }
    
    //Success status test case
    static testMethod void displayErrorSuccessTest(){
       setup();
       insert new QuoteDocument(Document = Blob.toPDf('Test PDF content'),QuoteId = quo.Id);
       String result=CheckQuoteTime.displayError(quo.Id);
       System.assertEquals('Success',result);        
    }
    
    //Failure status test case
    static testMethod void displayErrorFailureTest(){
       setup();
       system.debug('quo'+quo);
       DateTime myDateTime=quo.createddate.addDays(1);
       quo.Conga_Request_Time__c = myDateTime;
       upsert quo;
       String result=CheckQuoteTime.displayError(quo.Id);
       System.assertEquals('Failure',result);        
    }
    
    static testMethod void displayErrorNullPointerTest(){
       String quoteId='';
       String result=CheckQuoteTime.displayError(quoteId);
       System.assertEquals('Failure',result);        
    }
    static testMethod void displayErrorCatchTest(){
       setup();
       system.debug('quo'+quo);
       DateTime myDateTime=quo.createddate.addMinutes(15);
       Test.setCreatedDate(quo.Id,myDateTime);
       String result=CheckQuoteTime.displayError(null);
       System.assertEquals('Failure',result);         
    }
    @isTest
    static void searchLookupMethodPRM() {
        Test.startTest();
        try{
            
            
            boolean isPRMuser = CheckQuoteTime.userInfoPRM(); 
            system.assert(isPRMuser!=null);
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
    
     @isTest
    static void getNotificationMsgOnStatusTest() {
        Test.startTest();
        try{
         
            boolean msg = CheckQuoteTime.getNotificationMsgOnStatus(); 
            system.assert(msg!=null);
            setup();
            CheckQuoteTime.getQuoteStatus(quo.Id);
            
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
}