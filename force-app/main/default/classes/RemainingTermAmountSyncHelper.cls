/******************************************************************
User Story   : DIGI-25050
Description  : To update get configuration, subscription details and invoke class for BDS Sync callout
Class Name   : RemainingTermAmountSyncHelper
Created By   : Team Alexandria, Divakar Tangudu
Created On   : 28 October 2021
*******************************************************************/
global without sharing class RemainingTermAmountSyncHelper implements cssmgnt.RemoteActionDataProvider  {
    public class FieldSetMemberWrapperClass{
         
         public String configurationID 					 { get; set; }
         public String DMcatid 						 	{ get; set; }
          public String Durationremaining 						 { get; set;} 
          public String Chargeremaining 						 { get; set; }
          public String Subscriptionid 					     { get; set; }
          public boolean isSuccess                      	{ get; set; }
		  public string config_name                    { get; set; }
  }  
  @RemoteAction
  global static Map<String,Object> getData(Map<String,object> inputMap) {
     list<cscfga__Product_Configuration__c> config_list= new list<cscfga__Product_Configuration__c>();
     List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
	 Map<String, Object> returnMap = new Map<String, Object>();
	 map<string,string> resMap = new map<string,string>();
	
    Set<String> inputKey = inputMap.keySet();
    system.debug('inputKey'+inputKey); 
    system.debug('value===='+inputMap.get('GetConfig')); 
    String configIds = (String)inputMap.get('GetConfig'); 
    list<string> configIdList=configIds.split(',');
    set<id> configIdSet=new set<id>();
    for(string idstr:configIdList)
    {
      configIdSet.add(idstr);
    }      
      config_list=[select id,name,csordtelcoa__Replaced_Subscription__c ,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c, 
      Billing_Account__r.Billing_Account_Number__c,
      csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c
      from cscfga__Product_Configuration__c where id IN :configIdSet];
          system.debug('config record list'+config_list);  
      for(cscfga__Product_Configuration__c con:config_list)
      {
		 FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();		
          String billingAccountNo=con.Billing_Account__r.Billing_Account_Number__c;
          String subscrNo=con.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c;
          system.debug('billing acc'+con.Billing_Account__r.Billing_Account_Number__c);   
          system.debug('sub no'+con.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c);  
		resMap=		FetchPayoutDetailsSync.fetchPayoutDetails(billingAccountNo,subscrNo);
        system.debug('resMap==='+resMap);
			wrapper.configurationID=con.Id;
			wrapper.config_name=con.name;
			wrapper.Subscriptionid=con.csordtelcoa__Replaced_Subscription__c;
			wrapper.DMcatid=con.cscfga__Product_Definition__r.product_Specification__c;
			
			
		if(resMap.get('result')=='success'){

			wrapper.Durationremaining=resMap.get('durationRemaining');
			wrapper.Chargeremaining=resMap.get('chargeRemaining');
			wrapper.isSuccess= True;
			
		}
		
		else{
			wrapper.Durationremaining=null;
			wrapper.Chargeremaining=null;
			wrapper.isSuccess= False;
			
		}
		system.debug('wrapper===='+wrapper);
		wrapperList.add(wrapper);
		
        }

        system.debug('wrapperList++++'+wrapperList);
                
              String data=json.serialize(wrapperList);  
       
         returnMap.put('GetTermAmount', data);
         return returnMap;
  }
  
  }