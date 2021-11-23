public with sharing class BillingOrderUtil {
	private static BillingOrderUtil singleton = new BillingOrderUtil( );

   	/* A private Constructor prevents any other
    * class from instantiating.
    */
	private BillingOrderUtil() { }

   /* Static 'instance' method */
  	public static BillingOrderUtil getInstance( ) {
      return singleton;
   	}
	
	public static Billing_Account__c createBillingAccountRecord(String BAN){
		Billing_Account__c ba= new Billing_Account__c();
		ba.Billing_Account_Number__c=BAN;
		insert ba;
	
		return ba;
	}
}