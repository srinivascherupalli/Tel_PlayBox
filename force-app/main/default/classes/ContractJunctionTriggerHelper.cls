/****************************************************************************
@Author: Maq
@CreateDate: 08/11/2018.
@Description: ContractJunctionTrigger trigger to handle delete event.
@TestCoverageClass: ContractJunctionTriggerHelperTest
@ChangeLog: v1 - Created
==============================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vishal Arbune         31/12/2020      EDGE-195678: Ensure TM2 call is triggered for MACD Order post Contract Accepted
2.            Manish Berad          14/01/2021      EDGE-190304: Allow Auto creation of Flexi OneFund for customer ordering through Order First journey once Contract is Accepted
3.            Anurag singh          03/03/2021      EDGE-198373: Removed TM2 related methods and moved the funcationlity to the Number Management --> Transition --> Retrieve Services 
********************************************************************************/
public with sharing class ContractJunctionTriggerHelper { 
    public static final String initiatedStatus = 'Initiated';//EDGE-207342 added changes 
    public static final String pendingApprovalStatus = 'Pending Approval';//EDGE-207342 added changes  
    public static final String contractAcceptedStatus='Contract Accepted';//EDGE-207342 added changes  
    public void FCRRecordRelatedToContract(List<ContractJunction__c> newList,Map<Id,ContractJunction__c> newFCRMap,List<ContractJunction__c> oldList,Map<Id,ContractJunction__c> oldFCRMap){
        try{
            list<Functional_Contact_Role__c> deleteFCRList = new list<Functional_Contact_Role__c>();
            String fcrRecTypeContractRole = getObjRecordTypeId('Contract_Role', 'Functional_Contact_Role__c');
            for(Functional_Contact_Role__c FCR : [SELECT Id FROM Functional_Contact_Role__c WHERE Contract__c != NULL AND Contract__c IN :oldList AND Billing_Account_ID__c = NULL AND Billing_Account_Number__c = NULL AND SiteID__c = NULL AND RecordTypeId =: fcrRecTypeContractRole]){
                deleteFCRList.add(FCR);
            }
            if(!deleteFCRList.isEmpty())
                delete deleteFCRList;
        }
        catch(Exception e) {
            
        } 
        
    }
    
   
   
    @TestVisible
    private String getObjRecordTypeId(String recTypeDevName, String ObjectAPIString){
         System.debug('------>>>>>9');
        String objectAPIName = ObjectAPIString;
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofCaseRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
            if(info.getDeveloperName() == recTypeDevName){
                return info.getRecordTypeId();
            }
        }
        return null;
    }
    
   
    
     /* ****************************************************************************
* Author : Manish Berad : EDGE-190304
* Date : 13 Jan 2021
* Description : 1) Allow Auto creation of Flexi OneFund for customer ordering through Order First journey once Contract is Accepted.
* Parameters : New List,Old Map 
* *****************************************************************************/
    public void createFlexiOneFund(List<ContractJunction__c> newList,Map<Id,ContractJunction__c> OldMap){
        final String StatusAccepted = 'Contract Accepted';
        Set<Id> setOfBasketIds = new Set<Id>();
        Set<Id> setOfAccIds = new Set<Id>();
        Set<Id> setOfCJIds = new Set<Id>();
        Map<String,OneFund__c> mapOfAccVsOneFund=new Map<String,OneFund__c>();
        List<OneFund__c> lstFlexiOneFundToInsert=new List<OneFund__c>();
        try{
            for(ContractJunction__c cjRec : newList){
                if(cjRec.Status__c == StatusAccepted && cjRec.Status__c != OldMap.get(cjRec.Id).Status__c){
                    setOfCJIds.add(cjRec.Id);
                    setOfAccIds.add(cjRec.Account__c);
                }
            }
            if(!setOfAccIds.isEmpty()){
                List<OneFund__c> lstOfFlexiOneFund  = [Select ID,CIDN__c 
                                                        from OneFund__c 
                                                        where CIDN__c IN:setOfAccIds
                                                        and RecordType.DeveloperName = 'OneFund_Flexible'];
            //                                            and RecordType.Name = 'OneFund_Flexible'];
                                                        
                if(!lstOfFlexiOneFund.isEmpty()){
                    for(OneFund__c onefund:lstOfFlexiOneFund){
                        mapOfAccVsOneFund.put(onefund.CIDN__c,onefund);
                    }
                }
            }
            if(!setOfCJIds.isEmpty()){
                List<ContractJunction__c> lstOfCJ=[Select Id,Status__c,Account__c,Related_Basket__r.csordtelcoa__Basket_Stage__c,Related_Basket__r.cscfga__Opportunity__r.recordtype.Name,
                                                   Related_Basket__r.cscfga__Opportunity__r.Product_Type__c,Related_Basket__r.cscfga__Opportunity__r.Pricing_Method__c
                                                   From ContractJunction__c
                                                   Where Id IN:setOfCJIds];
                if(!lstOfCJ.isEmpty()){
                    for(ContractJunction__c cj:lstOfCJ){
                        if(cj.Status__c==StatusAccepted
                          && cj.Related_Basket__r.cscfga__Opportunity__r.recordtype.Name =='Enterprise - Standard' && mapOfAccVsOneFund.isEmpty() &&
                          cj.Related_Basket__r.cscfga__Opportunity__r.Product_Type__c == 'Modular' && cj.Related_Basket__r.cscfga__Opportunity__r.Pricing_Method__c!='Delegated Pricing'){
                             OneFund__c flexiOF=mapOfAccVsOneFund.get(cj.Account__c);
                              if(flexiOF==null){
                                  OneFund__c flexiOneFund=new OneFund__c();
                                  flexiOneFund.CIDN__c=cj.Account__c;
                                  flexiOneFund.Start_Date__c=Date.today();
                                  flexiOneFund.OneFund_Accrual_Frequency__c='Monthly';
                                  flexiOneFund.OneFund_Status__c='Active';
                                  flexiOneFund.RecordTypeId=Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();//Schema.SObjectType.OneFund__c.getRecordTypeInfosByName().get('Telstra Enterprise Plus Fund Flexi').getRecordTypeId();
                                  lstFlexiOneFundToInsert.add(flexiOneFund);
                              }
                        }
                    }
                }
            }
            if(!lstFlexiOneFundToInsert.isEmpty()){
                insert lstFlexiOneFundToInsert;
            }
            
        }
        catch(Exception e) {
            System.debug('error Caught :: '+e.getMessage());
        } 
        
    }
    /* ****************************************************************************
* Author : Rahul Asarma : //EDGE-207342
* Date : 13 Jan 2021
* Description : This function has written to send Notify Order Form and CIS Email.
* Parameters : New List,Old Map 
* *****************************************************************************/
    public void sendNotifyOrCISEmailService(List<ContractJunction__c> newList,Map<Id,ContractJunction__c> OldMap){
        
          
          Map<id,ContractJunction__c> updateMapofConJunction= new  Map<id,ContractJunction__c>();
          Map<id,cscfga__Product_Basket__c > updateMapofprodBasket= new  Map<id,cscfga__Product_Basket__c >();
          List<id> cisContactId= new List<id>();
          List<id> notifyContactId= new List<id>();
        try{
            for(ContractJunction__c cjRec : [select id,isOrderFormGenerated__c,Related_Basket__r.Pre_Authorised__c,Related_Basket__r.cscfga__total_contract_value__c,isSendOrderFormEmail__c,Status__c,Contract_Type__c,Customer_Primary_Contact__c,Related_Price_Schedule__r.VariationNotApplicable__c,Related_Basket__c,Related_Basket__r.csconta__Frame_Agreement__c,Related_Opportunity__r.Contract_Type__c from ContractJunction__c where id=:newList]){//DIGI-683 Added fields
                if(OldMap!=null && OldMap.size()>0){
                    system.debug('cjRec.isOrderFormGenerated__c----->>>>>:'+cjRec.isOrderFormGenerated__c);
                    system.debug('cjRec.isSendOrderFormEmail__c----->>>>>:'+cjRec.isSendOrderFormEmail__c);
                    system.debug('cjRec.Status__c----->>>>>:'+cjRec.Status__c);
                    system.debug('cjRec.Customer_Primary_Contact__c----->>>>>:'+cjRec.Customer_Primary_Contact__c);
                    system.debug('OldMap.get(cjRec.Id).isOrderFormGenerated__c----->>>>>:'+OldMap.get(cjRec.Id).isOrderFormGenerated__c);
                  //  system.debug('cjRec.Related_Basket__r.Pre_Authorised__c::' + cjRec.Related_Basket__r.Pre_Authorised__c); // Secure code review fix
                    system.debug('cjRec.Related_Basket__r.cscfga__total_contract_value__c::'+cjRec.Related_Basket__r.cscfga__total_contract_value__c);
                    system.debug('cjRec.Related_Price_Schedule__r.VariationNotApplicable__c::'+cjRec.Related_Price_Schedule__r.VariationNotApplicable__c);  
                    system.debug('cjRec.Contract_Type__c::'+cjRec.Contract_Type__c);
                    if(cjRec.isOrderFormGenerated__c == true && cjRec.isOrderFormGenerated__c != OldMap.get(cjRec.Id).isOrderFormGenerated__c && cjRec.isSendOrderFormEmail__c==true &&   cjRec.Status__c==initiatedStatus && cjRec.Customer_Primary_Contact__c!=null && (cjRec.Related_Price_Schedule__r != null && cjRec.Related_Price_Schedule__r.VariationNotApplicable__c=='NoAgreeement')){//DIGI-683 Added extra conditions
                        system.debug('in ContractJunctionHelper class for InContract flow to send order FORM'+cjRec);
                        
                        notifyContactId.add(cjRec.id);
                    }
                    //DIGI-30673 Start
                    if(cjRec.isOrderFormGenerated__c == true && cjRec.isOrderFormGenerated__c != OldMap.get(cjRec.Id).isOrderFormGenerated__c && cjRec.isSendOrderFormEmail__c==true &&   cjRec.Status__c==initiatedStatus && cjRec.Customer_Primary_Contact__c!=null){
                        system.debug('in ContractJunctionHelper class for InContract flow to send order FORM for BSA'+cjRec);
                        
                        notifyContactId.add(cjRec.id);
                    }
                    //DIGI-30673 End
                    if(cjRec.isOrderFormGenerated__c == true && cjRec.isOrderFormGenerated__c != OldMap.get(cjRec.Id).isOrderFormGenerated__c && (cjRec.Related_Basket__r.Pre_Authorised__c == true || cjRec.Related_Basket__r.cscfga__total_contract_value__c <= 10000) && ((cjRec.Related_Price_Schedule__r != null && cjRec.Related_Price_Schedule__r.VariationNotApplicable__c=='NoAgreeement')) &&  cjRec.Status__c==initiatedStatus && cjRec.Customer_Primary_Contact__c!=null && cjRec.Contract_Type__c=='DSA'){//Added conditions as per DIGI-683  //Removed FA Condition as per DIGI-37579
                        //Added condition of Related_Basket__r.csconta__Frame_Agreement__c!=NULL for Incident - INC000096147354 Fix
                         system.debug('In this if----->>>>>');
                        cjRec.Status__c=contractAcceptedStatus;
                        updateMapofConJunction.put(cjRec.id,cjRec);
                        cscfga__Product_Basket__c prodBasket= new cscfga__Product_Basket__c();
                        if(cjRec.Related_Basket__c!=null){
                            prodBasket.id=cjRec.Related_Basket__c;
                            prodBasket.csordtelcoa__Basket_Stage__c=contractAcceptedStatus;
                            updateMapofprodBasket.put(cjRec.Related_Basket__c,prodBasket);
                        }
                        system.debug('in ContractJunctionHelper class for the flow that do not have family change'+cjRec);
                        notifyContactId.add(cjRec.id);
                    }
                    
                    if(cjRec.Status__c==pendingApprovalStatus && cjRec.Status__c!=OldMap.get(cjRec.Id).Status__c && cjRec.Contract_Type__c=='BSA' && cjRec.Customer_Primary_Contact__c!=null){
                        system.debug('in ContractJunctionHelper class block to send CIS in BSA Enabled Product'+cjRec);
                        cisContactId.add(cjRec.id);
                    }
                }
                else{
                system.debug('in ContractJunctionHelper class for DSA Contract Type'+cjRec);
                    if(cjRec.Status__c==initiatedStatus && cjRec.Contract_Type__c=='DSA' && cjRec.Customer_Primary_Contact__c!=null ){
                        system.debug('in ContractJunctionHelper class block to send CIS in DSA Enabled Product'+cjRec);
                        cisContactId.add(cjRec.id);
                    }
                }
                
            }
            
            if(updateMapofConJunction.size()>0)
                update updateMapofConJunction.values();
            if(updateMapofprodBasket.size()>0)
                update updateMapofprodBasket.values();
            System.debug('notifyContactId----->>>>>:'+notifyContactId);
            if( notifyContactId !=null && notifyContactId.size()>0){//DIGI-683 Added Null check
                SendOrderFormEmailService.processSendOrderFormEmail(notifyContactId);
            }
            system.debug('cisContactId::'+ cisContactId);
            if(cisContactId!=null && cisContactId.size()>0){//DIGI-683 Added Null check
                CISEmailService.processCISMail(cisContactId);
            }
        }
        catch(Exception e) {
            System.debug('error Caught :: '+e.getMessage()+ e + 'Line number' + e.getLineNumber());
        } 
        
    }
    
}