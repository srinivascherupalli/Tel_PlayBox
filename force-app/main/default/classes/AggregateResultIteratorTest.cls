@IsTest
public class AggregateResultIteratorTest {
    
    @testSetup static void setup() {
    	List<Profile_Layout__c> plList = new List<Profile_Layout__c>();
    	
    	//Insert a record into Profile_Layout__c
    	Profile_Layout__c pl1 = new Profile_Layout__c();
    	pl1.Layout__c = 'Account-Account Layout';
    	pl1.Profile_Key__c = 'Account-Admin-';
    	plList.add(pl1);
    	
    	Profile_Layout__c pl2 = new Profile_Layout__c();
    	pl2.Layout__c = 'Contact-Contact Layout';
    	pl2.Profile_Key__c = 'Order Entry User';
    	plList.add(pl2);
    	
    	insert plList;        
    }
    
    @isTest
    static void hasNextTest() {
    	AggregateResultIterator aggItr = new AggregateResultIterator();
    	System.assertEquals(aggItr.results.size(), 2, 'Error: Unexpected number of Profile Layout Records retrived');
    	System.assert(aggItr.hasNext(), 'Error: Iterator cannot find next record');    	 
    }
	 	
 	@isTest
    static void nextTest() {
    	AggregateResultIterator aggItr = new AggregateResultIterator();
    	AggregateResult ar1 = aggItr.next();
    	System.assert(ar1 != null, 'Error: Not able to retrieve first AggregateResult record');
    	System.assertEquals(ar1.get('Layout__c'), 'Account-Account Layout', 'Error: Unexpected layout name');
    	
    	AggregateResult ar2 = aggItr.next();
    	System.assert(ar2 != null, 'Error: Not able to retrieve next AggregateResult record');
    	System.assertEquals(ar2.get('Layout__c'), 'Contact-Contact Layout', 'Error: Unexpected layout name');
    }	   
    
 	@isTest
    static void iteratorTest() {    	
    	AggregateResultIterator aggItr = new AggregateResultIterator();
    	Iterator<AggregateResult> aggIterator = aggItr.Iterator();
    	
    	System.assert(aggIterator.hasNext(), 'Error: Iterator cannot find next record');    	     	
    }	
}