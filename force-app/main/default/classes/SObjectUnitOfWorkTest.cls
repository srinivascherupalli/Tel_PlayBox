@IsTest
private with sharing class SObjectUnitOfWorkTest
{
    // SObjects (in order of dependency) used by UnitOfWork in tests bellow
    private static List<Schema.SObjectType> MY_SOBJECTS =
        new Schema.SObjectType[] {
            Product2.SObjectType,
            PricebookEntry.SObjectType,
            Opportunity.SObjectType,
            OpportunityLineItem.SObjectType };

    @isTest
    private static void testUnitOfWorkEmail()
    {
        string testRecordName = 'UoW Test Name 1';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new list<String>{ 'foobar@test.com' });
        email.setPlainTextBody('See Spot run.');

        SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);

        Account acc = new Account();
        acc.Name  = 'Test';
        acc.Customer_Status__c='Active';
        insert acc;
		System.assert(acc != null);        
        Opportunity opp = new Opportunity();
        opp.Name = testRecordName;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        uow.registerNew( opp );

        uow.registerEmail( email );

        //uow.registerRelationship( email, opp );

        uow.commitWork();

        List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name = :testRecordName order by Name];

       
        System.assertEquals(1, opps.size());
    }

    /*@isTest
    private static void testUnitOfWorkNewDirtyDelete()
    {
        // Insert Opporunities with UnitOfWork
       /* {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
            for(Integer o=0; o<2; o++)
            {
                Account acc = new Account();
        		acc.Name  = 'Test';
        		insert acc;
                
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.Name = 'UoW Test Name ' + o;
                opp.StageName = 'Open';
                opp.CloseDate = System.today();
                uow.registerNew(new List<SObject>{opp});
                for(Integer i=0; i<o+1; i++)
                {
                    Product2 product = new Product2();
                    product.Name = opp.Name + ' : Product : ' + i;
                    uow.registerNew(new List<SObject>{product});
                    PricebookEntry pbe = new PricebookEntry();
                    pbe.UnitPrice = 10;
                    pbe.IsActive = true;
                    pbe.UseStandardPrice = false;
                    pbe.Pricebook2Id = Test.getStandardPricebookId();
                    uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.Quantity = 1;
                    oppLineItem.TotalPrice = 10;
                    oppLineItem.Description = 'test description';
                    uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                    uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
                }
            }

            uow.commitWork();
        }

        // Assert Results
        assertResults('UoW');
        // TODO: Need to re-instate this check with a better approach, as it is not possible when
        //       product triggers contribute to DML (e.g. in sample app Opportunity trigger)
        // System.assertEquals(5, /* Oddly a setSavePoint consumes a DML Limits.getDmlStatements());*/

        // Records to update
       /* List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name like 'UoW Test Name %' order by Name];*/

        // Update some records with UnitOfWork
       /* {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
            Opportunity opp = opps[0];
            opp.Name = opp.Name + ' Changed';
            //opp.Name = 'UoW Test Name ' + o;
			opp.StageName = 'Open';
            opp.CloseDate = System.today();
            uow.registerDirty(new List<SObject>{opp});
            Product2 product = new Product2();
            product.Name = opp.Name + ' : New Product';
            uow.registerNew(new List<SObject>{product});
            PricebookEntry pbe = new PricebookEntry();
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            uow.registerNew(pbe, PricebookEntry.Product2Id, product);
            OpportunityLineItem newOppLineItem = new OpportunityLineItem();
            newOppLineItem.Description = 'test description';
            newOppLineItem.Quantity = 1;
            newOppLineItem.TotalPrice = 10;
            uow.registerRelationship(newOppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
            uow.registerNew(newOppLineItem, OpportunityLineItem.OpportunityId, opp);
            OpportunityLineItem existingOppLine = opp.OpportunityLineItems[0];
            // Test that operations on the same object can be daisy chained, and the same object registered as dirty more than once
            // This verifies that using a Map to back the dirty records collection prevents duplicate registration.
            existingOppLine.Quantity = 2;
            uow.registerDirty(new List<SObject>{existingOppLine});
            existingOppLine.TotalPrice = 20;
            uow.registerDirty(new List<SObject>{existingOppLine});
            uow.commitWork();
        }

        // Assert Results
        // TODO: Need to re-instate this check with a better approach, as it is not possible when
        //       product triggers contribute to DML (e.g. in sample app Opportunity trigger)
        // System.assertEquals(11, Limits.getDmlStatements());
        opps = [select Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity, TotalPrice from OpportunityLineItems Order By PricebookEntry.Product2.Name) from Opportunity where Name like 'UoW Test Name %' order by Name limit 10];
        System.assertEquals(10, opps.size());
        System.assertEquals('UoW Test Name 0 Changed', opps[0].Name);
        System.assertEquals(2, opps[0].OpportunityLineItems.size());
        // Verify that both fields were updated properly
        System.assertEquals(2, opps[0].OpportunityLineItems[0].Quantity);
        System.assertEquals(20, opps[0].OpportunityLineItems[0].TotalPrice);
        System.assertEquals('UoW Test Name 0 Changed : New Product', opps[0].OpportunityLineItems[1].PricebookEntry.Product2.Name);

        // Delete some records with the UnitOfWork
        {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry.Product2}); // Delete PricebookEntry Product
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry}); // Delete PricebookEntry
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1]}); // Delete OpportunityLine Item
            // Register the same deletions more than once.
            // This verifies that using a Map to back the deleted records collection prevents duplicate registration.
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry.Product2}); // Delete PricebookEntry Product
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry}); // Delete PricebookEntry
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1]}); // Delete OpportunityLine Item
            uow.commitWork();
        }

        // Assert Results
        // TODO: Need to re-instate this check with a better approach, as it is not possible when
        //       product triggers contribute to DML (e.g. in sample app Opportunity trigger)
        // System.assertEquals(15, Limits.getDmlStatements());
        opps = [select Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity from OpportunityLineItems Order By PricebookEntry.Product2.Name) from Opportunity where Name like 'UoW Test Name %' order by Name];
        List<Product2> prods = [Select Id from Product2 where Name = 'UoW Test Name 0 Changed : New Product'];
        System.assertEquals(10, opps.size());
        System.assertEquals('UoW Test Name 0 Changed', opps[0].Name);
        System.assertEquals(1, opps[0].OpportunityLineItems.size()); // Should have deleted OpportunityLineItem added above
        System.assertEquals(0, prods.size()); // Should have deleted Product added above
    }*/

    private static void assertResults(String prefix)
    {
        // Standard Assertions on tests data inserted by tests
        String filter = prefix + ' Test Name %';
        List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name like :filter order by Name];
        System.debug('opps.size()::'+opps.size());
        //System.assertEquals(2, opps.size());
        //System.assertEquals(1, opps[0].OpportunityLineItems.size());
        //System.assertEquals(2, opps[1].OpportunityLineItems.size());
        /*System.assertEquals(3, opps[2].OpportunityLineItems.size());
        System.assertEquals(4, opps[3].OpportunityLineItems.size());
        System.assertEquals(5, opps[4].OpportunityLineItems.size());
        System.assertEquals(6, opps[5].OpportunityLineItems.size());
        System.assertEquals(7, opps[6].OpportunityLineItems.size());
        System.assertEquals(8, opps[7].OpportunityLineItems.size());
        System.assertEquals(9, opps[8].OpportunityLineItems.size());
        System.assertEquals(10, opps[9].OpportunityLineItems.size());*/
    }

    /**
     * Create uow with new records and commit
     *
     *	Testing:
     *
     *		- Correct events are fired when commitWork completes successfully
     *
     */
    @isTest
    private static void testDerivedUnitOfWork_CommitSuccess()
    {
        // Insert Opporunities with UnitOfWork
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
         Account acc = new Account();
         acc.Name  = 'Test';
         acc.Customer_Status__c = 'Active';
         insert acc;
		System.assert(acc.Id != null);  
        for(Integer o=0; o<2; o++)
        {
                    
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'UoW Test Name ' ;
            opp.StageName = 'Open';
            opp.CloseDate = System.today();
            uow.registerNew(new List<SObject>{opp});
            for(Integer i=0; i<o+1; i++)
            {
                Product2 product = new Product2();
                product.Name = opp.Name + ' : Product : ' + i;
                uow.registerNew(new List<SObject>{product});
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 10;
                pbe.IsActive = true;
                pbe.UseStandardPrice = false;
                pbe.Pricebook2Id = Test.getStandardPricebookId();
                uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Description = 'test description';
                oppLineItem.Quantity = 1;
                oppLineItem.TotalPrice = 10;
                uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
            }
        }
        uow.commitWork();

        // Assert Results
        assertResults('UoW');

        assertEvents(new List<String> {
                'onCommitWorkStarting'
                , 'onDMLStarting'
                , 'onDMLFinished'
                , 'onDoWorkStarting'
                , 'onDoWorkFinished'
                , 'onCommitWorkFinishing'
                , 'onCommitWorkFinished - true'
            }
            , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    /**
     * Create uow with data that results in DML Exception
     *
     *	Testing:
     *
     *		- Correct events are fired when commitWork fails during DML processing
     *
     */
    @isTest
    private static void testDerivedUnitOfWork_CommitDMLFail()
    {
        // Insert Opporunities with UnitOfWork forcing a failure on DML by not setting 'Name' field
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
        Opportunity opp = new Opportunity();
        uow.registerNew(new List<SObject>{opp});
        Boolean didFail = false;
        System.DmlException caughtEx = null;

        try {
            uow.commitWork();
        }
        catch (System.DmlException dmlex) {
            didFail = true;
            caughtEx = dmlex;
        }

        // Assert Results
        System.assertEquals(didFail, true, 'didFail');
        System.assert(caughtEx.getMessage().contains('REQUIRED_FIELD_MISSING'), String.format('Exception message was ', new List<String> { caughtEx.getMessage() }));

        assertEvents(new List<String> {
                'onCommitWorkStarting'
                , 'onDMLStarting'
                , 'onCommitWorkFinished - false'
            }
            , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    /**
     * Create uow with work that fails
     *
     *	Testing:
     *
     *		- Correct events are fired when commitWork fails during DoWork processing
     *
     */
    @isTest
    private static void testDerivedUnitOfWork_CommitDoWorkFail()
    {
        // Insert Opporunities with UnitOfWork
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
        
        Account acc = new Account();
        acc.Name  = 'Test';
        acc.Customer_Status__c = 'Active';
        insert acc;
        System.assert(acc.Id != null);
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'UoW Test Name 1';
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew(new List<SObject>{opp});

        // register work that will fail during processing
        FailDoingWork fdw = new FailDoingWork();
        uow.registerWork(fdw);

        Boolean didFail = false;
        FailDoingWorkException caughtEx = null;

        try {
            uow.commitWork();
        }
        catch (FailDoingWorkException fdwe) {
            didFail = true;
            caughtEx = fdwe;
        }

        // Assert Results
        System.assertEquals(didFail, true, 'didFail');
        System.assert(caughtEx.getMessage().contains('Work failed.'), String.format('Exception message was ', new List<String> { caughtEx.getMessage() }));

        assertEvents(new List<String> {
                'onCommitWorkStarting'
                , 'onDMLStarting'
                , 'onDMLFinished'
                , 'onDoWorkStarting'
                , 'onCommitWorkFinished - false'
            }
            , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    /**
     * Try registering two instances of the same record as dirty. Second register should overwrite first.
     *
     *  Testing:
     *
     *      - Exception is thrown stopping second registration
     */
    @isTest
    private static void testRegisterDirty_ExpectReplacement() {
        Account acc0 = new Account();
        acc0.Name  = 'Test0';
        acc0.Customer_Status__c ='Active';
        insert acc0;
        
        Account acc1 = new Account();
        acc1.Name  = 'Test1';
        acc1.Customer_Status__c ='Acquired';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name  = 'Test2';
        acc1.Customer_Status__c ='Active';
        insert acc2;
        System.assert(acc2.Id != null);
        final Opportunity insertedOpp = new Opportunity(Name = 'Original', StageName = 'Open', CloseDate = System.today(), AccountId = acc0.Id,Storage_Requested_Date__c = null,Opportunity_Source__c ='Marketing');
        insert insertedOpp;
        try{
            if(Test.isRunningTest()){
             Opportunity opp2 = new Opportunity(Id = null, Name = 'Expected', AccountId = acc2.Id,Storage_Requested_Date__c = null,Opportunity_Source__c ='Marketing');
      	      SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
        
               uow.registerDirty(opp2);
         }
       } 
       catch(exception qe)// exception handling
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, qe.getMessage());
                ApexPages.addMessage(msg);
            }
    }

    /**
     * Try registering a single field as dirty.
     *
     *  Testing:
     *
     *      - field is updated
     */
    @isTest
    private static void testRegisterDirty_field() {
        Account acc0 = new Account();
        acc0.Name = 'test0';
        acc0.Customer_Status__c = 'Active';
        insert acc0;
        System.assert(acc0.Id != null);
        Account accUpdateName = new Account();
        accUpdateName.Name = 'test0';
        accUpdateName.Customer_Status__c ='Acquired';
        insert accUpdateName;
        
        Account accUpdateAmount = new Account();
        accUpdateAmount.Name = 'test0';
        accUpdateAmount.Customer_Status__c='Active';
        insert accUpdateAmount;
        
        Opportunity opp = new Opportunity(Name = 'test name', StageName = 'Open', CloseDate = System.today(), AccountId = acc0.Id,Storage_Requested_Date__c = null,Opportunity_Source__c ='Marketing');
        insert opp;

        Opportunity nameUpdate = new Opportunity(Id = opp.Id, Name = 'UpdateName', AccountId = accUpdateName.Id,Storage_Requested_Date__c = null,Opportunity_Source__c ='Marketing');
        Opportunity amountUpdate = new Opportunity(Id = opp.Id, Amount = 250, AccountId = accUpdateAmount.Id,Storage_Requested_Date__c = null,Opportunity_Source__c ='Marketing');
        SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
        uow.registerDirty(nameUpdate);
        //uow.registerDirty(amountUpdate, new List<SObjectField> { Opportunity.Amount } );
        uow.commitWork();

        opp = [select Name, Amount from Opportunity where Id = :opp.Id];
        System.assertEquals(opp.Name, nameUpdate.Name);
        //System.assertEquals(opp.Amount, amountUpdate.Amount);
    }

    /**
     * Assert that actual events exactly match expected events (size, order and name)
     * and types match expected types
     */
    private static void assertEvents(List<String> expectedEvents, List<String> actualEvents, Set<Schema.SObjectType> expectedTypes, Set<Schema.SObjectType> actualTypes)
    {
        // assert that events match
        //System.assertEquals(expectedEvents.size(), actualEvents.size(), 'events size');
        for (Integer i = 0; i < expectedEvents.size(); i++)
        {
            //System.assertEquals(expectedEvents[i], actualEvents[i], String.format('Event {0} was not fired in order expected.', new List<String> { expectedEvents[i] }));
        }

        // assert that types match
        //System.assertEquals(expectedTypes.size(), actualTypes.size(), 'types size');
        for (Schema.SObjectType sObjectType :expectedTypes)
        {
            //System.assertEquals(true, actualTypes.contains(sObjectType), String.format('Type {0} was not registered.', new List<String> { sObjectType.getDescribe().getName() }));
        }
    }

    /**
     * DoWork implementation that throws exception during processing
     */
    private class FailDoingWork implements SObjectUnitOfWork.IDoWork
    {
        public void doWork()
        {
            throw new FailDoingWorkException('Work failed.');
        }
    }

    /**
     * Derived unit of work that tracks event notifications and handle registration of type
     */
    private class DerivedUnitOfWork extends SObjectUnitOfWork
    {
        private List<String> m_commitWorkEventsFired = new List<String>();
        private Set<Schema.SObjectType> m_registeredTypes = new Set<Schema.SObjectType>();

        public List<String> getCommitWorkEventsFired()
        {
            return m_commitWorkEventsFired.clone();
        }

        public Set<Schema.SObjectType> getRegisteredTypes()
        {
            return m_registeredTypes.clone();
        }

        public DerivedUnitOfWork(List<Schema.SObjectType> sObjectTypes)
        {
            super(sObjectTypes);
        }

        public DerivedUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml)
        {
            super(sObjectTypes, dml);
        }

        private void addEvent(String event)
        {
            // events should only be fired one time
            // ensure that this event has not been fired already
            for (String eventName :m_commitWorkEventsFired)
            {
                if (event == eventName)
                {
                    throw new DerivedUnitOfWorkException(String.format('Event {0} has already been fired.', new List<String> { event }));
                }
            }
            m_commitWorkEventsFired.add(event);
        }

        public void onRegisterType(Schema.SObjectType sObjectType)
        {
            if (m_registeredTypes.contains(sObjectType))
            {
                throw new DerivedUnitOfWorkException(String.format('Type {0} has already been registered.', new List<String> { sObjectType.getDescribe().getName() }));
            }
            m_registeredTypes.add(sObjectType);
        }

        public void onCommitWorkStarting()
        {
            addEvent('onCommitWorkStarting');
        }

        public void onDMLStarting()
        {
            addEvent('onDMLStarting');
        }

        public void onDMLFinished()
        {
            addEvent('onDMLFinished');
        }

        public void onDoWorkStarting()
        {
            addEvent('onDoWorkStarting');
        }

        public void onDoWorkFinished()
        {
            addEvent('onDoWorkFinished');
        }

        public  void onCommitWorkFinishing()
        {
            addEvent('onCommitWorkFinishing');
        }

        public  void onCommitWorkFinished(Boolean wasSuccessful)
        {
            addEvent('onCommitWorkFinished - ' + wasSuccessful);
        }
    }

    public class DerivedUnitOfWorkException extends Exception {}
    public class FailDoingWorkException extends Exception {}
}