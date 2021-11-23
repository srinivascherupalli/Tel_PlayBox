/**
* Factory Default class for Unit Testing framework
*
* Note : To specify defaults for objects, use the naming convention [ObjectName]Defaults.
*        For Custom Objects, omit the __c from the object name  
* 
* @author  	Nandan Narasappa
* @version 	1.0
* @since   	15/04/2020 
*
*/
@isTest
public with sharing class SYS_TestFactoryDefaults {

	//Account Default class for unit testing
	public class AccountDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Account.Name => 'Test Account',
                Account.Customer_status__c => 'ACTIVE'
            };
        }
	}
    
    // Opportunity Default class for unit testing
	public class OpportunityDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Opportunity.Name => 'Test Opportunity',
                Opportunity.StageName => System.label.Opp_Stage_Develop,
                Opportunity.Description__c=>'Test',
                Opportunity.Product_Domain__c=>'MOBILES',
                Opportunity.CloseDate => Date.today().addDays(365)
            };
        }
	}

	// Contact Default class for unit testing
	public class ContactDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Contact.FirstName => 'Test',
				Contact.LastName => 'Contact',
				Contact.Email => 'myemailcon@getnada.com',
				Contact.Birthdate => System.today().addDays(-7500),
				Contact.Salutation => 'MR'
            };
        }
	}

	// Product Default class for unit testing
	public class Product2Defaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Product2.Name => 'Test Product' ,
				Product2.ProductCode => 'testProductCode'
            };
        }
	}

	// Pricebook Default class for unit testing
	public class Pricebook2Defaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Pricebook2.Name => 'Test Pricebook'
            };
        }
	}

	/*// Asset Default class for unit testing
	public class AssetDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Asset.Name => 'Test Asset'
            };
        }
	}

	// Order Default class for unit testing
	public class OrderDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				Order.Status => 'Draft',
				Order.EffectiveDate => System.today(),
				Order.OrderReferenceNumber => 'ORD-3421'
            };
        }
	}

	// OrderItem Default class for unit testing
	public class OrderItemDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				OrderItem.UnitPrice => 10,
				OrderItem.Quantity => 1
            };
        }
	}*/

	// User Default class for unit testing
	public class UserDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
				User.FirstName => 'Test' ,
				User.LastName => 'User',
				User.Alias => 'tUserX',
				User.Email => 't.user@testUserXTelstra.com.au',
				User.UserName => 't.user@testUserXTelstra.com.au' + System.now().millisecond(),
				User.EmailEncodingKey => 'UTF-8',
				User.LanguageLocaleKey => 'en_US',
				User.LocaleSidKey => 'en_AU',
                User.MobilePhone => '+61405350775',
				User.TimeZoneSidKey => 'Australia/Sydney'
				
            };
        }
	}

	
    
    // Case Default class for unit testing
	public class CaseDefaults implements SYS_TestFactory.FieldDefaults{
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Case.subject => 'Subject',
                Case.status => 'Open',
                Case.Description => 'Test',
				Case.Origin => 'Phone'       	
            };
        }
    }
    
    //defaults for cspmb__Price_Item__c
    public class PriceItemDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                cspmb__Price_Item__c.cspmb__Effective_End_Date__c => Date.today().addDays(365),
                cspmb__Price_Item__c.cspmb__Effective_Start_Date__c => Date.today().addDays(-30),
                cspmb__Price_Item__c.cspmb__Is_Active__c => false,
                cspmb__Price_Item__c.cspmb__Is_Authorization_Required__c => false,
                cspmb__Price_Item__c.cspmb__Is_One_Off_Discount_Allowed__c => false,
                cspmb__Price_Item__c.cspmb__Is_Recurring_Discount_Allowed__c => false,
                cspmb__Price_Item__c.Currency__c => 'AUD',
                cspmb__Price_Item__c.Prorate__c => 'false',
                cspmb__Price_Item__c.taxTreatment__c => 'GST Applicable',
                cspmb__Price_Item__c.Offer_Id__c => 'DMCAT_Offer_000618',
                cspmb__Price_Item__c.BillingSpecId__c => 'BSOTC001_CB',
                cspmb__Price_Item__c.Billing_Description__c => 'Polycom IP phone VVX 411',
                cspmb__Price_Item__c.ChargeFrequency__c => 'Monthly'
                
            };
        }
    }
    
    public class NgUCPriceItemDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                cspmb__Price_Item__c.cspmb__Effective_End_Date__c => Date.today().addDays(365),
                cspmb__Price_Item__c.cspmb__Effective_Start_Date__c => Date.today().addDays(-30),
                cspmb__Price_Item__c.cspmb__Is_Active__c => false,
                cspmb__Price_Item__c.cspmb__Is_Authorization_Required__c => false,
                cspmb__Price_Item__c.cspmb__Is_One_Off_Discount_Allowed__c => false,
                cspmb__Price_Item__c.cspmb__Is_Recurring_Discount_Allowed__c => false,
                cspmb__Price_Item__c.Currency__c => 'AUD',
                cspmb__Price_Item__c.Prorate__c => 'false',
                cspmb__Price_Item__c.taxTreatment__c => 'GST Applicable',
                cspmb__Price_Item__c.Offer_Id__c => 'DMCAT_Offer_000618',
                cspmb__Price_Item__c.Billing_Description__c => 'Polycom IP phone VVX 411',
                cspmb__Price_Item__c.ChargeFrequency__c => 'Monthly',
                cspmb__Price_Item__c.cspmb__Price_Item_Code__c => 'Unified Communication Device',
                cspmb__Price_Item__c.Commercial_Product_Code__c => 'Unified Communication Device', 
                cspmb__Price_Item__c.cspmb__Product_Definition_Name__c => 'Unified Communication Device',
                cspmb__Price_Item__c.Charge_Id__c => 'DMCAT_Offer_000618',
                cspmb__Price_Item__c.Package_Name__c => 'Adaptive Collaboration', //DIGI-3352 B2B-1762 - Offer Name Change
                cspmb__Price_Item__c.Type__c => 'IP Handsets Device',
                cspmb__Price_Item__c.Unit_Of_Measure__c => 'per Device',
                cspmb__Price_Item__c.BillingSpecId__c => 'BSOTC001_CB',
                cspmb__Price_Item__c.Unit_Of_Measure__c => 'per Device',
                cspmb__Price_Item__c.BillingSpecId__c => 'BSOTC001_CB'
            };
        }
    }
    
    //defaults for cspmb__Add_On_Price_Item__c
    public class AddOnPriceItemDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                cspmb__Add_On_Price_Item__c.Name => 'Basic',
				cspmb__Add_On_Price_Item__c.cspmb__Add_On_Price_Item_Code__c => 'Mobile Access',
				cspmb__Add_On_Price_Item__c.cspmb__Add_On_Price_Item_Description__c => 'Manually Created',
				cspmb__Add_On_Price_Item__c.cspmb__Apply_One_Off_Charge_Account_Discount__c => false,
				cspmb__Add_On_Price_Item__c.cspmb__Apply_Recurring_Charge_Account_Discount__c => false,
				cspmb__Add_On_Price_Item__c.cspmb__Billing_Frequency__c => 'Monthly',
				cspmb__Add_On_Price_Item__c.cspmb__Effective_End_Date__c => Date.today().addDays(365),
				cspmb__Add_On_Price_Item__c.cspmb__Effective_Start_Date__c => Date.today().addDays(-30),
				cspmb__Add_On_Price_Item__c.cspmb__Is_Active__c => false,
				cspmb__Add_On_Price_Item__c.cspmb__Is_Authorization_Required__c => false,
				cspmb__Add_On_Price_Item__c.cspmb__Is_One_Off_Discount_Allowed__c => false,
				cspmb__Add_On_Price_Item__c.cspmb__Is_Recurring_Discount_Allowed__c => false,
				cspmb__Add_On_Price_Item__c.cspmb__Product_Definition_Name__c => 'Mobile Access',
				cspmb__Add_On_Price_Item__c.cspmb__Recurring_Charge__c => 10.0,
				cspmb__Add_On_Price_Item__c.cspmb__Sequence__c => 0.0,
				cspmb__Add_On_Price_Item__c.External_Id__c => 'DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_101',
				cspmb__Add_On_Price_Item__c.Price_Override__c => false,
				cspmb__Add_On_Price_Item__c.ProdSpecId__c => 'DMCAT_ProductSpecification_000263',
				cspmb__Add_On_Price_Item__c.BillInAdvance__c => 'true',
				cspmb__Add_On_Price_Item__c.BillingSpecId__c => 'BSRC001_CB',
				cspmb__Add_On_Price_Item__c.Billing_Description__c => 'International call pack - basic',
				cspmb__Add_On_Price_Item__c.Frequency__c => 'Monthly',
				cspmb__Add_On_Price_Item__c.Offer_Id__c => 'DMCAT_Offer_000646',
				cspmb__Add_On_Price_Item__c.Offer_Name__c => 'Corporate Mobile Plus',
				cspmb__Add_On_Price_Item__c.Prorate__c => 'false',
				cspmb__Add_On_Price_Item__c.Unit_Of_Measure__c => 'each',
				cspmb__Add_On_Price_Item__c.taxTreatment__c => 'GST Applicable'
            };
        }
    }
    
    //defaults for cspmb__Discount_Level__c
    public class DiscountLevelDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                cspmb__Discount_Level__c.cspmb__Discount_Type__c => 'Amount',
                cspmb__Discount_Level__c.cspmb__Discount__c => 4.6,
                cspmb__Discount_Level__c.cspmb__Discount_Values__c => '4.6',
                cspmb__Discount_Level__c.Effective_End_Date__c => Date.today().addDays(30),
                cspmb__Discount_Level__c.Effective_Start_Date__c => Date.today().addDays(-30),
                cspmb__Discount_Level__c.Discount_Application_Point__c => 'Billing Pre-Itemization',
                cspmb__Discount_Level__c.Is_Delegated__c => true,
                cspmb__Discount_Level__c.is_Unlimited__c => true,
                cspmb__Discount_Level__c.cspmb__duration__c => 2.0,
                cspmb__Discount_Level__c.Description__c => 'test plan'
                
            };
        }
    }
    
    //defaults for csord__Solution__c
    public class SolutionDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                csord__Solution__c.csord__Identification__c => 'Solution Management',
                csord__Solution__c.csord__Status__c => 'Completed',
                csord__Solution__c.cssdm__total_contract_value__c => 0.0,
                csord__Solution__c.cssdm__total_one_off_charge__c => 0.0,
                csord__Solution__c.cssdm__total_recurring_charge__c => 0.0
            };
        }
    }
    
    //Added by P.M for csord__Subscription__c default records
    public class SubscriptionDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                csord__Subscription__c.csord__Identification__c => 'TestValue',
                csord__Subscription__c.Name => 'Test Subscription',
                csord__Subscription__c.csord__Identification__c => 'test',
                csord__Subscription__c.csord__Status__c => 'NA',
                csord__Subscription__c.stage__c => 'NA'   
            };
        }
    }
    
    //defaults for csord__Service__c
    public class ServiceDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                csord__Service__c.csord__Identification__c => 'TestValue',
                csord__Service__c.Name => 'Test Service',
                csord__Service__c.csord__Status__c => 'Success'  
            };
        }
    }

    //Added by P.M for AccountShare default records
    public class AccountShareDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                AccountShare.AccountAccessLevel => 'Edit',
                AccountShare.OpportunityAccessLevel => 'Edit'
            };
        }
    }
    
    //Added by P.M for OpportunityLineItem default records
	public class OpportunityLineItemDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                OpportunityLineItem.TotalPrice => 2000,
                OpportunityLineItem.Quantity => 2,
                OpportunityLineItem.Product_Status__c => 'Won',
                OpportunityLineItem.Product_Name__c => 'Test Product'    
            };
        }
    }
    
    //Added by P.M for csord__Order__c default records
	public class OrderDefaults implements SYS_TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                csord__Order__c.Name => 'TestOrder',
                csord__Order__c.csord__Identification__c => 'test',
                csord__Order__c.isMSISDNHeld__c => false 
            };
        }
    }
    
}