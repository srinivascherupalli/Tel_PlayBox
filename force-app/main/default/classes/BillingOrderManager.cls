/**
* Class  Billing Account Manager.
*/
/********************************************************
Class Name      :   BillingOrderManager
Test Class : BillingOrderManagerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil        22/10/19         EDGE-112016,EDGE-81140 & EDGE-115840
2.            Sandeep R             30/10/19         EDGE- 118632
3.            Manish Jha            27/04/2020       INC000092427869 
**********************************************************
*/
public with sharing class BillingOrderManager {
    private static BillingOrderManager singleton = new BillingOrderManager( );
    
    /* A private Constructor prevents any other
* class from instantiating.
*/
    private BillingOrderManager() { }
    
    /* Static 'instance' method */
    
    public static BillingOrderManager getInstance( ) {
        return singleton;
    }
    
    public static String allocateBillingAccount(){
        //system.debug('BillingOrderService.requestBillingAccountAllocation() '+BillingOrderService.requestBillingAccountAllocation());
        return BillingOrderService.requestBillingAccountAllocation();   
    }
    
    public static BillingAccountDetailsDTO fetchBillingDetailsFromBDS(String ban){
        System.debug('ban '+ban);
        BillingAccountDetailsDTO billingAccDetails=BillingOrderService.requestBillingAccountDetails(ban);
        ///EDGE-147537
        List<Billing_Account__c> billAcc = [select id, Billing_Account_Number__c,Written_Off__c,Write_off_in_U2C__c from Billing_Account__c where Billing_Account_Number__c=:ban];
        try{
            //EDGE-151581. Kalashree. check if record is locked for Approval
            if(!Approval.isLocked(billAcc[0].id) && !billAcc.isEmpty() && billingAccDetails != null && billingAccDetails.billingAccount !=null) {
                billAcc[0].Write_off_in_U2C__c=(!billAcc[0].Written_Off__c && billingAccDetails.billingAccount.writtenOffStatus=='WriteOff')?true:false;
                //EDGE-151581. Kalashree. Saving balance amount
                if(!billAcc[0].Written_Off__c && billingAccDetails.billingAccount!=null && billingAccDetails.billingAccount.accountBalance!=null){
                    billAcc[0].Balance_Amount__c =  billingAccDetails.billingAccount.accountBalance.totalBalance ;
                } 
                update billAcc;
            }
        }
        
        catch(Exception e){
            System.debug('Exception in fetchBillingDetailsFromBDS: '+e.getStackTraceString());
        }
        return  billingAccDetails;
    }
    
    @future(callout=true)
    public static void createBillingAccount(String id){
        BillingAccountDTO billingAccountDTO = new BillingAccountDTO();
        BillingAccountDTO.BillingAccount billingAccount = new BillingAccountDTO.BillingAccount();
        //BillingAccountDTO.BillingContact billingContact = new BillingAccountDTO.BillingContact();
        BillingAccountDTO.BillingAddress billingAddress = new BillingAccountDTO.BillingAddress();
        //19.15 : EDGE- 118632 : Changed the billing address to add the line 2 and line 3.
        Billing_Account__c billAcc = [select id, Billing_Account_Number__c,Customer_Account_Number__c,Billing_Account_Owner__r.firstname,
                                      Billing_Account_Owner__r.lastname, Account__r.name,Account__r.ABN__c,Account__r.ACN__c,
                                      Account__r.Legacy_ROU__c,
                                      Billing_Address__r.name, Billing_Address__r.Locality__c, 
                                      Billing_Address__r.cscrm__Zip_Postal_Code__c, 
                                      Billing_Address__r.cscrm__State_Province__c, Billing_Address__r.cscrm__Country__c,
                                      Billing_Address__r.Address_Line_1__c,Billing_Address__r.Address_Line_2__c,
                                      Billing_Address__r.Address_Line_3__c,Status__c,
                                      Written_Off__c,PreDebt__c,BillCycleday__c,Retention__c from Billing_Account__c where id=:id];
        
        //billingAccountDTO.correlationId=IntegrationRecordHandlerUtil.getUUID();
        //billingAccountDTO.sourceSystem='SFDC';    
        //EDGE-147511
        if(billAcc.Written_Off__c == false && (billAcc.Status__c == 'Final' || billAcc.Status__c =='Pending Finalisation')){
            billingAccount.status = billAcc.Status__c;
        }
        if(billAcc.PreDebt__c){
            billingAccount.accountType = 'PreDebt';
        }
        if(billAcc.Billing_Account_Number__c!=null){
            billingAccount.billingAccountNumber = Long.valueOf(billAcc.Billing_Account_Number__c);
        }
        //billingAccount.billCycleDay=01;
        billingAccount.billCycleDay=Integer.valueOf(billAcc.BillCycleday__c);//EDGE-131005
        billingAccount.paymentTerms=30;
        string str=billAcc.Account__r.Legacy_ROU__c; 
        if(str!=null && str.length()>20){
            billingAccount.rouCode=str.substring(0, 20);
        }
        else{
            billingAccount.rouCode=billAcc.Account__r.Legacy_ROU__c;
        }
        
        billingAccount.retentionFlag = billAcc.Retention__c; //Added for EDGE-198149 
        
        billingAccount.currencyCode='AUD';
        billingAccount.language='English';
        string firstName=billAcc.Billing_Account_Owner__r.firstname;
        /*if(firstName!=null && firstName.length()>32){
        billingContact.firstName=firstName.substring(0, 32);
        }
        else{
        billingContact.firstName=billAcc.Billing_Account_Owner__r.firstname;
        }
        string lastName=billAcc.Billing_Account_Owner__r.lastname;
        if(lastName!=null && lastName.length()>32){
        billingContact.lastName=lastName.substring(0, 32);
        }
        else{
        billingContact.lastName=billAcc.Billing_Account_Owner__r.lastname;
        }
        if(billAcc.Account__r.ABN__c!=null&&billAcc.Account__r.ABN__c!='10000000000'){ 
        billingContact.abn=(billAcc.Account__r.ABN__c);
        }
        else if(billAcc.Account__r.ACN__c!=null){
        billingContact.abn=(billAcc.Account__r.ACN__c);
        }
        billingContact.companyName=billAcc.Account__r.name;*/
        //billingAccount.companyName=billAcc.Account__r.name;   
        billingAccount.companyName=billAcc.Account__r.name;   
        //billingAddress.address=billAcc.Billing_Address__r.Address_Line_1__c;
        //19.15 : EDGE- 118632 : Changed the billing address to add the line 2 and line 3. 
        //Added Null checks as part of coding standards -Manish Jha INC000092427869 
        String address = billAcc.Billing_Address__r.Address_Line_1__c + ' ';
        if(billAcc.Billing_Address__r.Address_Line_2__c != null && billAcc.Billing_Address__r.Address_Line_2__c != '')
            address =  address + billAcc.Billing_Address__r.Address_Line_2__c + ' ';
        if(billAcc.Billing_Address__r.Address_Line_3__c != null && billAcc.Billing_Address__r.Address_Line_2__c != '')
            address =  address + billAcc.Billing_Address__r.Address_Line_3__c;
        billingAddress.address = address;
        string loc=billAcc.Billing_Address__r.Locality__c;
        if(loc!=null && loc.length()>32){
            billingAddress.locality=loc.substring(0, 32);
        }
        else{
            billingAddress.locality=billAcc.Billing_Address__r.Locality__c;
        }
        string poCode=billAcc.Billing_Address__r.cscrm__Zip_Postal_Code__c;
        if(poCode!=null && poCode.length()>15){
            billingAddress.postcode=poCode.substring(0, 15);
        }
        else{
            billingAddress.postcode=billAcc.Billing_Address__r.cscrm__Zip_Postal_Code__c;
        }
        string state=billAcc.Billing_Address__r.cscrm__State_Province__c;
        if(state!=null && state.length()>10){
            billingAddress.state=state.substring(0, 10);
        }
        else{
            billingAddress.state=billAcc.Billing_Address__r.cscrm__State_Province__c;
        }
        string Country=billAcc.Billing_Address__r.cscrm__Country__c;
        if(Country!=null && Country.length()>32){
            billingAddress.country=Country.substring(0, 32);
        }
        else{
            billingAddress.country=billAcc.Billing_Address__r.cscrm__Country__c;
        }
        billingAccountDTO.BillingAccount=billingAccount;
        //billingAccountDTO.BillingAccount.billingAccountOwner=billingContact;
        billingAccountDTO.BillingAccount.BillingAddress=billingAddress;
        string result =  BillingOrderService.requestBillingAccountCreate(billingAccountDTO);
        billAcc.Status__c = result;
       // billAcc.BillCycleday__c=null;//EDGE-131005:we cannot store bill cycle day in SF so making it clear
        BillingHandler.run=false;
        update billAcc;    
    }
    public static void triggerPostSubscription(List<Id> subIds,boolean isIncludeSolution){
        boolean isProductActionExpire = false;
        BillingOrderService.sendBillingOrder(subIds,isIncludeSolution,isProductActionExpire);
    } 
}