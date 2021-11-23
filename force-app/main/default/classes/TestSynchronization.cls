@isTest
public class TestSynchronization 
{
    public static Account CreateAccount(string AccountName, Boolean WithInsert)
    {
        Account tmpAccount = new Account(Name = AccountName,RecordTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId());
        //tmpAccount.Type=Type;
        //tmpAccount.NumberOfEmployees=NumberOfEmployees;
        //tmpAccount.Phone=Phone;
                
        if (WithInsert) insert tmpAccount;
        
        return tmpAccount;
    }
    
    public static Account CreateAccount(string AccountName)
    {
        return CreateAccount(AccountName, true);
    }
    
     //create Opportunity
    public static Opportunity CreateOpportunity(Account Acc, Boolean WithInsert)
    {
        Opportunity tmpOpportunity = new Opportunity(Name = 'Test', AccountId=Acc.Id, StageName = 'Prospecting', CloseDate=Date.today()+5,Product_Type__c='Modular');
        
        if (WithInsert) insert tmpOpportunity;
        
        return tmpOpportunity;
    }
    
    public static Opportunity CreateOpportunity(Account Acc)
    {
        return CreateOpportunity(Acc,true);
    }
    
    
    public static cscfga__Product_Definition__c createProductDefinition(String Name, Boolean WithInsert) 
    {
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = Name;
        prodDef.cscfga__Description__c=Name; 
         
        if (WithInsert) insert prodDef;

        return prodDef;
    }   
    
    public static cscfga__Product_Definition__c createProductDefinition(String Name)
    {
        return createProductDefinition(Name,true);
    }
    
     //create Attribute Definition
    public static cscfga__Attribute_Definition__c createAttributeDefinition(string name, cscfga__Product_Definition__c productDef, string AttribType, string DataType, Boolean WithInsert) 
    {
        cscfga__Attribute_Definition__c attDef = new cscfga__Attribute_Definition__c();
            attDef.Name = name;
            attDef.cscfga__Type__c = AttribType;
            attDef.cscfga__Data_Type__c=DataType;
            attDef.cscfga__Product_Definition__c = productDef.Id;
         
         if (WithInsert) insert attDef;

         return attDef;
    }
    
    public static cscfga__Attribute_Definition__c createAttributeDefinition(string name, cscfga__Product_Definition__c productDef, string AttribType, string DataType)
    {
        return createAttributeDefinition(name,productDef, AttribType,DataType, true);
    }
    
    //create Attribute Field Definition
    public static cscfga__Attribute_Field_Definition__c createAttributeFieldDefinition(string name, string Value, cscfga__Attribute_Definition__c AttributeDefinition, 
        Boolean WithInsert)
    {
        cscfga__Attribute_Field_Definition__c attDefFieldDefinition = new cscfga__Attribute_Field_Definition__c(Name=name,cscfga__Default_Value__c=Value,
            cscfga__Attribute_Definition__c=AttributeDefinition.Id);
            
        if (WithInsert) insert attDefFieldDefinition;
        
        return attDefFieldDefinition;
    }
    
    public static cscfga__Attribute_Field_Definition__c createAttributeFieldDefinition(string name, string Value, cscfga__Attribute_Definition__c AttributeDefinition)
    {
        return createAttributeFieldDefinition(name,Value,AttributeDefinition,true);
    }
    
     //create Product Configuration
    public static cscfga__Product_Configuration__c createProductConfiguration(string Name, integer ContractTerm, cscfga__Product_Basket__c ProductBasket, cscfga__Product_Definition__c ProductDefinition, Boolean WithInsert)
    {
        cscfga__Product_Configuration__c ProductConfiguration = new cscfga__Product_Configuration__c();
        ProductConfiguration.Name=Name;
        ProductConfiguration.cscfga__Contract_Term__c=ContractTerm;
        ProductConfiguration.cscfga__Product_Basket__c=ProductBasket.Id;
        ProductConfiguration.cscfga__Product_Definition__c=ProductDefinition.Id;
        ProductConfiguration.cscfga__Quantity__c=1;
        ProductConfiguration.Quantity_Product_Configuration__c=1;
        
        if (WithInsert) insert ProductConfiguration;
        
        return ProductConfiguration;
    }
    
    public static cscfga__Product_Configuration__c createProductConfiguration(string Name, integer ContractTerm, cscfga__Product_Basket__c ProductBasket, cscfga__Product_Definition__c ProductDefinition)
    {
        return createProductConfiguration(Name, ContractTerm,Productbasket,ProductDefinition,true);
    }
    
    //create Attribute
    public static cscfga__Attribute__c createAttribute(string Name, cscfga__Attribute_Definition__c AttributeDefinition, Boolean IsLineItem, double Price, 
        cscfga__Product_Configuration__c ProductConfiguration, Boolean Recurring, string Value, Boolean WithInsert)
    {
        
        cscfga__Attribute__c Attribute = new cscfga__Attribute__c();
        Attribute.Name=Name;
        Attribute.cscfga__Attribute_Definition__c=AttributeDefinition.Id;
        Attribute.cscfga__Is_Line_Item__c=IsLineItem;
        Attribute.cscfga__Price__c=Price;
        Attribute.cscfga__Product_Configuration__c=ProductConfiguration.Id;
        Attribute.cscfga__Recurring__c=Recurring;
        Attribute.cscfga__Value__c=Value;
        Attribute.cscfga__Line_Item_Description__c=Name;
        
        if (WithInsert) insert Attribute;
        
        return Attribute;
    }
    
    public static cscfga__Attribute__c createAttribute(string Name, cscfga__Attribute_Definition__c AttributeDefinition, Boolean IsLineItem, double Price, 
        cscfga__Product_Configuration__c ProductConfiguration, Boolean Recurring, string Value)
    {
        return createAttribute(Name,AttributeDefinition,IsLineItem,Price, ProductConfiguration, Recurring,Value, true);
    }
    
    
    //create AttributeField
    public static cscfga__Attribute_Field__c createAttributeField(string Name,cscfga__Attribute__c Attribute, string Value, Boolean WithInsert)
    {
        cscfga__Attribute_Field__c AttributeField = new cscfga__Attribute_Field__c();
        AttributeField.Name=Name;
        AttributeField.cscfga__Attribute__c=Attribute.Id;
        AttributeField.cscfga__Value__c=Value;
        
        if (WithInsert) insert AttributeField;
        
        return AttributeField;
    }
    
    public static cscfga__Attribute_Field__c createAttributeField(string Name,cscfga__Attribute__c Attribute, string Value)
    {
        return createAttributeField(Name,Attribute,Value,true);
    }
    
    
    public static cscfga__Product_Basket__c createProductBasket(string Name, Account Acc, Opportunity Opp, Boolean WithInsert)
    {
        cscfga__Product_Basket__c ProductBasket = new cscfga__Product_Basket__c();
        ProductBasket.Name=Name;
        if (Acc!=null) ProductBasket.csordtelcoa__Account__c=Acc.Id;
        if (Opp!=null) ProductBasket.cscfga__Opportunity__c=Opp.Id;
        ProductBasket.cscfga__Basket_Status__c='Valid';
        ProductBasket.csordtelcoa__Synchronised_with_Opportunity__c=true;

        if (WithInsert) insert ProductBasket;
        
        return ProductBasket;   
    }
    
    
    public static cscfga__Product_Basket__c createProductBasket(string Name, Account Acc, Opportunity Opp)
    {
        return createProductBasket(Name, Acc, Opp, true);   
    }
    
    public static Product2 createProduct2(string Name, string ProductFamily, Boolean IsActive,Boolean WithInsert)
    {
        Product2 tmpProduct2 = new Product2();
        tmpProduct2.Family=ProductFamily;
        tmpProduct2.Name = Name;
        tmpProduct2.IsActive = IsActive;

        if (WithInsert) insert tmpProduct2;
        
        return tmpProduct2;
    }
    
    public static Product2 createProduct2(string Name, string ProductFamily, Boolean IsActive)
    {
        return createProduct2(Name,ProductFamily,IsActive,true);
    }
    
    public static csbb__Product_Configuration_Request__c createProductConfigurationRequest(cscfga__Product_Basket__c ProductBasket,cscfga__Product_Configuration__c ProductConfiguration,Boolean WithInsert)
    {
        csbb__Product_Configuration_Request__c ProductConfigurationRequest = new csbb__Product_Configuration_Request__c();
        ProductConfigurationRequest.csbb__Product_Configuration__c = ProductConfiguration.Id;
        ProductConfigurationRequest.csbb__Product_Basket__c = ProductBasket.Id;
        
        if (WithInsert) insert ProductConfigurationRequest;
        
        return ProductConfigurationRequest;
    }
    
    public static csbb__Product_Configuration_Request__c createProductConfigurationRequest(cscfga__Product_Basket__c ProductBasket,cscfga__Product_Configuration__c ProductConfiguration)
    {
        return createProductConfigurationRequest(ProductBasket,ProductConfiguration,true);
    }
    
    
    static testMethod void TestSync()
    {
        Account tmpAcc = CreateAccount('Test Account');
        Opportunity tmpOpp = CreateOpportunity(tmpAcc);
        
        cscfga__Product_Definition__c tmpProductDef = createProductDefinition('Test Product Definition');
        
        cscfga__Attribute_Definition__c tmpAttDefRecurringBasic = createAttributeDefinition('Recurring Price Basic', tmpProductDef, 'Display Value', 'Double');
        cscfga__Attribute_Definition__c tmpAttDefOneOffBasic = createAttributeDefinition('One Off Price Basic', tmpProductDef, 'Display Value', 'Double');
        cscfga__Attribute_Definition__c tmpAttDefRecurringOther = createAttributeDefinition('Recurring Price Other', tmpProductDef, 'Display Value', 'Double');
        cscfga__Attribute_Definition__c tmpAttDefOneOffOther = createAttributeDefinition('One Off Price Other', tmpProductDef, 'Display Value', 'Double');
        
        
    
        cscfga__Product_Basket__c tmpProductBasket = createProductBasket('Test basket', tmpAcc, tmpOpp);    
        
        cscfga__Product_Configuration__c tmpProductConfig = createProductConfiguration('Test Product Configuration 1', 12, tmpProductBasket, tmpProductDef);
        
        cscfga__Attribute__c tmpAttributeRecurring1 = createAttribute('Recurring Price Basic', tmpAttDefRecurringBasic, true, 10, tmpProductConfig, true, '10.0');      
        tmpAttributeRecurring1.cscfga__Line_Item_Description__c='Test recurring description';
            
        cscfga__Attribute__c tmpAttributeOneOff1 = createAttribute('One off Price Basic', tmpAttDefOneOffBasic, true, 20, tmpProductConfig, false, '20.0');     
        tmpAttributeRecurring1.cscfga__Line_Item_Description__c='Test recurring description';

        cscfga__Attribute__c tmpAttributeRecurring2 = createAttribute('Recurring Price Other', tmpAttDefRecurringOther, true, 10, tmpProductConfig, true, '10.0');      
        tmpAttributeRecurring2.cscfga__Line_Item_Description__c='Test recurring description';
            
        cscfga__Attribute__c tmpAttributeOneOff2 = createAttribute('One off Price Other', tmpAttDefOneOffOther, true, 20, tmpProductConfig, false, '20.0');     
        tmpAttributeRecurring2.cscfga__Line_Item_Description__c='Test recurring description';



        cscfga__Product_Configuration__c tmpProductConfig2 = createProductConfiguration('Test Product Configuration 2', 12, tmpProductBasket, tmpProductDef);
        
        cscfga__Attribute__c tmpAttributeRecurring3 = createAttribute('Recurring Price Basic', tmpAttDefRecurringBasic, true, 10, tmpProductConfig2, true, '10.0');     
        tmpAttributeRecurring3.cscfga__Line_Item_Description__c='Test recurring description';
            
        cscfga__Attribute__c tmpAttributeOneOff3 = createAttribute('One off Price Basic', tmpAttDefOneOffBasic, true, 20, tmpProductConfig2, false, '20.0');    
        tmpAttributeRecurring3.cscfga__Line_Item_Description__c='Test recurring description';

        cscfga__Attribute__c tmpAttributeRecurring4 = createAttribute('Recurring Price Other', tmpAttDefRecurringOther, true, 10, tmpProductConfig2, true, '10.0');     
        tmpAttributeRecurring4.cscfga__Line_Item_Description__c='Test recurring description';
            
        cscfga__Attribute__c tmpAttributeOneOff4 = createAttribute('One off Price Other', tmpAttDefOneOffOther, true, 20, tmpProductConfig2, false, '20.0');    
        tmpAttributeRecurring4.cscfga__Line_Item_Description__c='Test recurring description';

        Product2 tmpProduct1 = createProduct2('Recurring Price Basic','Test Product Definition',true);
        Product2 tmpProduct2 = createProduct2('Test Product Configuration 2','Test Product Definition',true);
        
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;
        
        OLI_Sync__c OLISync = new OLI_Sync__c(); 
        OLISync.SetupOwnerId = UserInfo.getUserId();        
        insert OLISync;

        //test 1        
        OLISync = OLI_Sync__c.getInstance(UserInfo.getUserId());
        OLISync.Product_Configuration_Level__c=false;   
        OLISync.Sum_One_Off_And_Recurring__c=false;
        update OLISync;
        
        
        SyncBasketFromPageLayout.SynchronizeBasket(tmpProductBasket.Id);
        
        CustomButtonSynchronizeWithOpportunity cbswo = new CustomButtonSynchronizeWithOpportunity();
        //cbswo.performAction(tmpProductBasket.Id);
                

        //test 2        
        /*OLISync = OLI_Sync__c.getInstance(UserInfo.getUserId());
        OLISync.Product_Configuration_Level__c=true;    
        OLISync.Sum_One_Off_And_Recurring__c=false;
        update OLISync;
        
        SyncBasketFromPageLayout.SynchronizeBasket(tmpProductBasket.Id);
        
        //cbswo.performAction(tmpProductBasket.Id);

        //test 3        
        OLISync = OLI_Sync__c.getInstance(UserInfo.getUserId());
        OLISync.Product_Configuration_Level__c=false;   
        OLISync.Sum_One_Off_And_Recurring__c=true;
        update OLISync;
        
        SyncBasketFromPageLayout.SynchronizeBasket(tmpProductBasket.Id);
        
        //cbswo.performAction(tmpProductBasket.Id);
                
        //test 4        
        OLISync = OLI_Sync__c.getInstance(UserInfo.getUserId());
        OLISync.Product_Configuration_Level__c=true;    
        OLISync.Sum_One_Off_And_Recurring__c=true;
        update OLISync;
        
        SyncBasketFromPageLayout.SynchronizeBasket(tmpProductBasket.Id);
        
        //cbswo.performAction(tmpProductBasket.Id);
        
        tmpProductBasket.csordtelcoa__Synchronised_with_Opportunity__c=false;
        update tmpProductBasket;        
        
        
        //test 5
        csbb__Product_Configuration_Request__c tmpProductConfigurationRequest=createProductConfigurationRequest(tmpProductBasket,tmpProductConfig);
        */
        cbswo.performAction(tmpProductBasket.Id);
        
        System.assertEquals(tmpProductBasket.csbb__Synchronised_With_Opportunity__c, false);
    }
}