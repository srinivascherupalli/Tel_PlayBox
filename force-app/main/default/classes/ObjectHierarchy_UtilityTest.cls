@isTest
public class ObjectHierarchy_UtilityTest {
    
    @testSetup
    public static void testData(){
        Account parentAcc=new Account(name='testParentAccount',CIDN__c='12345',Parent_CIDN__c='12345678');
        insert parentAcc;
        Account childAcc = new Account(name='testChildAccount',ParentId=parentAcc.id,CIDN__c='123',Parent_CIDN__c='1234',Ultimate_Parent_CIDN__c='1234');
        insert childAcc;
    }
    
    @isTest
    public static void testHierarchyDataWhenHierarchyLevelIsNull(){
        ObjectHierarchy_Utility.QueryConfig config = new ObjectHierarchy_Utility.QueryConfig('Account','Name','ParentId');
        Account parentAcc = [SELECT ID,Name FROM Account WHERE name='testParentAccount'];
        
        List<ObjectHierarchy_Utility.ObjectWrapper> listObjectWrapper = new List<ObjectHierarchy_Utility.ObjectWrapper>();
        ObjectHierarchy_Utility.ObjectWrapper obj = new ObjectHierarchy_Utility.ObjectWrapper(parentAcc,NULL,'name');
        listObjectWrapper.add(obj);
        
        Set<Id> testFilterIds = new Set<Id>();
        config.filterIds = testFilterIds;
        testFilterIds.add(parentAcc.id);
        String query = config.getQuery();
        listObjectWrapper = ObjectHierarchy_Utility.getHierarchyData(config,'full');
        System.debug('listObjectWrapper' +listObjectWrapper);
        System.assertNotEquals(NULL, listObjectWrapper);
    }
    
 
    @isTest
    public static void testHierarchyDataWhenHierarchyLevelIsNotNull(){
        ObjectHierarchy_Utility.QueryConfig config = new ObjectHierarchy_Utility.QueryConfig('Account','Name','ParentId');
        Account parentAcc = [SELECT ID,Name FROM Account WHERE name='testParentAccount'];
        Account childAcc = [SELECT ID,name FROM Account WHERE name='testChildAccount'];
        System.debug('parentAcc' +parentAcc);
        System.debug('childAcc' +childAcc);
        
        List<ObjectHierarchy_Utility.ObjectWrapper> listObjectWrapper = new List<ObjectHierarchy_Utility.ObjectWrapper>();
        ObjectHierarchy_Utility.ObjectWrapper obj = new ObjectHierarchy_Utility.ObjectWrapper(childAcc,parentAcc.id,'name');
        listObjectWrapper.add(obj);
        
        Set<Id> testFilterIds = new Set<Id>();
        testFilterIds.add(childAcc.id);
        config.filterIds = testFilterIds;
        String query = config.getQuery();
        listObjectWrapper = ObjectHierarchy_Utility.getHierarchyData(config,'full');
        System.debug('listObjectWrapper' +listObjectWrapper);
        System.assertNotEquals(NULL, listObjectWrapper);
    }

    
    @isTest
    public static void getColumnConfigTest(){
        String width = '10'; 
        String header ='10';
        String value ='test';
        String wideCellClass = 'testwide';
        String headerClass = 'testHeader';
        ObjectHierarchy_Utility.ColumnWrapper objColumnWrapper= new ObjectHierarchy_Utility.ColumnWrapper(width,header,value,wideCellClass,headerClass); 
        String nameFieldAPIName= 'Title__c';
        Set<String> fieldsToDisplay = new Set<String>();
        fieldsToDisplay.add('ParentId');
        //Schema.DescribeSObjectResult objectDescribe; //null 
        Schema.DescribeSObjectResult objectDescribe  = Account.SObjectType.getDescribe();
        List<ObjectHierarchy_Utility.ColumnWrapper> listWrapper = ObjectHierarchy_Utility.getColumnConfig(objectDescribe,nameFieldAPIName,fieldsToDisplay);
        System.debug('listWrapper' +listWrapper);
        System.assertNotEquals(NULL, listWrapper);
    }
    
    @isTest
    public static void validateFieldTest(){
        Schema.DescribeSObjectResult objectDescribe  = Account.SObjectType.getDescribe();
        String nameFieldAPIName= 'Title__c';
        Boolean retVal = ObjectHierarchy_Utility.validateField(objectDescribe,nameFieldAPIName);
        System.debug('retVal');
        System.assertNotEquals(False, retVal);
        
        String nameFieldAPIName1= 'Test';
        Boolean retVal1 = ObjectHierarchy_Utility.validateField(objectDescribe,nameFieldAPIName1);
        System.assertNotEquals(True, retVal1);
    }
    
    @isTest
    public static void getValidFieldsToDisplayTest(){
        Set<String> getValidCSV = new Set<String>();
        Schema.DescribeSObjectResult objectDescribe  = Account.SObjectType.getDescribe();
        String fieldsToDisplayCSV ='Title__c';
        getValidCSV = ObjectHierarchy_Utility.getValidFieldsToDisplay(objectDescribe,fieldsToDisplayCSV);
        System.debug('getValidCSV' +getValidCSV); //Title__c 
        System.assertNotEquals(NULL, getValidCSV);
    }
 
}