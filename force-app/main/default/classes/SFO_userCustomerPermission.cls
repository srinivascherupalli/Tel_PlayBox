/*
    Class       : SFO_userCustomerPermission
    Team        : Team SFO
    Author      : Pallavi B
    Objective   : This class Checks for the customer permissions enabled for user
    Test Class  : SFO_userCustomerPermissionTest
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

*/
Public class SFO_userCustomerPermission {
    
    /*
    MethodName  : flowInputs
    Team        : Team SFO
    Author      : Pallavi B
    Objective   : Stored Inputs values to from flow
    References  : Create Pricing Support Case(Flow)
    Test Class  : SFO_userCustomerPermissionTest
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

   */
    
     public class flowInputs {
        @InvocableVariable(required=false) 
        public String SalesAndMarketingPermission;
         
        @InvocableVariable(required=false) 
        public String OperationsPermission;
         
        @InvocableVariable(required=false) 
        public String SalesB2BPermission ; 
        
        @InvocableVariable(required=false) 
        public string PricingSupportCase;
        
       }
    
    /*
    MethodName  : FlowOutputs
    Team        : Team SFO
    Author      : Pallavi B
    Objective   : Stored Output values to send to flow
    References  : Create Pricing Support Case(Flow)
    Test Class  : SFO_userCustomerPermissionTest
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

   */
    
        public class FlowOutputs {
        @InvocableVariable 
        public Boolean userHasPermission =false; 
      
       }
    
    /*
    Class       : SFO_userCustomerPermission
    Team        : Team SFO
    Author      : Pallavi B
    Objective   : This class Checks for the customer permissions enabled for user
    References  : Create Pricing Support Case(Flow)
    Test Class  : SFO_userCustomerPermissionTest
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

   */    
    @InvocableMethod
    public static List<FlowOutputs> checkForUserCustomPermissions(List<flowInputs> flowValues){
		List<FlowOutputs> flwOpts = new List<FlowOutputs>();
        FlowOutputs fOpts = new FlowOutputs();
        Boolean customPermissionCheck = (FeatureManagement.checkPermission(System.label.Sales_and_Marketing_Custom_Permission) || FeatureManagement.checkPermission(System.label.Operations_Custom_Permission) || FeatureManagement.checkPermission(System.label.Sales_B2B_Permission) || FeatureManagement.checkPermission(System.label.Pricing_Support_Case_Custom_Permission));
        fOpts.userHasPermission = customPermissionCheck;
        flwOpts.add(fOpts);
		return flwOpts;
    }
  

    
}