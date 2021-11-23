/*********************************************************************************************************************************
 *Class Name      :   ShowSolutionsOnMACButtonController

Test Class : ShowSolutionsOnMACButtonCntrlrTest
Ch.No.    Developer Name          Date          Story Description
1.        Rohit  Tripathi       15/07/2019      EDGE-95594 (When I selected the Requestor during MAC selection but getting Error saying that Contact Role is not                                             there. Hence Contact is not add after selecting the Requestor)
2.        Rohit  Tripathi       02/10/2019      EDGE-115558 (CWP is not visible after clicking MACD solution button)
3.        Venkata Ramanan 
                   & Ankit      27/11/2019      EDGE- 123211 Code to reset the dirty flag in solution json for the selected solution during MAC journey.
4.        Rohit Tripathi        30/04/2020      EDGE-141989 Upgrade MAC screen to redirect to basket after MAC configurations are validated
5.        Gnana                 12/05/2020      EDGE-144681 Enable multi solution modifications in MACD Modify Or Cancel Order flow
6.        Vaibhav Deshpande     26/05/2020      EDGE-138655 Enhance search criteria and provide Subscription list view for a Solution during MACD Order flow
7.        Vaibhav Deshpande     01/06/2020      EDGE-149079 Enhance search criteria in MACD Order flow to allow search of EM Device Solution using Device IDs
8.       shubhi V               01/07/2020      EDGE-147513 
9.       Manish Berad           17/07/2020      EDGE-153459 Skip Pre-Authorisation flow for Assurance Service Agent, when TNOW Case ID is provided as a customer authorisation to raise a MACD Order in Phoenix
10.      Shubhi Vijayvergia     28.07.2020      incident INC000093454566
9.        Pallavi D              02/07/20202    :Auntun B   commented dirty flag related implementation and added null pointer check for decimal values - EDGE-155244
10.     Sandip Deshmane         14/8/2020       EDGE-169967 - Removed Solution Status check. Its filtered on Subscription status.
11.     shubhi                  24/08/2020                EDGE-166269 PRM macd fix
12.     Manish Berad            17/09/2020      EDGE-172345 EDGE-172345 As a Sales Enterprise user, I want to provide Sales support case # while creating a MAC Order, so that I can skip Customer Pre-Authorisation flow
13.     Aman Soni               18/09/2020      EDGE-167800      
14.     Shubhi V                24/09/20202     Parallel macd fix
15.     Aarathi Iyer            24/09/2020      EDGE 165478
16.     Swapna Deshpande        04/11/2020          EDGE-182533 Added Filter on Subscription status for blank SIM
17.     Shubhi Vijayvergia      6/11/2020           EDGE-188859
18      Dheeraj Bhatt           26-Nov-2020     EDGE-185845  Ability to skip Quote and Contract for orders that are migrated from AM-L to AM-D
19.    Gnana          01-04-2021    EDGE-144681 Added new method getBasketDetails_New to handle Multiple Solutions
20.     Aman Soni/Shubhi V      08/07/2020      EDGE-224786   Update the MACD logic to use alternate CS API that does not create opportunity and basket, to avoid creation of Opporunity with defaults
21.		Payel/Radhika			27/07/2021 		DIGI-926	  Updated the getSubscriptionDetails for MACD Disconnection
22.    Antun Bartonicek    08-09-2021    R34UPGRADE  R34 related changes: async part of MACD is no longer needed as it happens on Heroku side
*********************************************************************************************************************************
*/
public with sharing class ShowSolutionsOnMACButtonController {
    public class MyAuraException extends Exception {}//Added by Aman Soni/Shubhi V  for EDGE-224786
    private static final String OPPORTUNITY_REC_TYPE = 'Enterprise - In Contract';
    private static final String OPPORTUNITY_STAGE = 'Develop';
    private static final String OPPORTUNITY_TYPE_MAC = 'MACs (Moves, Adds & Change)';
    private static final String OPPORTUNITY_TYPE_DISCONNECT = 'Disconnect';
    private static final String OPPORTUNITY_PRODUCT_TYPE = 'Modular';
    private static final String OPPORTUNITY_PRIMARY_DOMAIN = 'Other';
    private static final String OPPORTUNITY_IN_CONTRACT = 'Yes';
    private static final String CHANGE_TYPE_MODIFY = 'Modify';
    private static final String CHANGE_TYPE_CANCEL = 'Cancel';
    private static final String CHANGE_TYPE = 'Change Solution';//Added by Aman Soni/Shubhi V  for EDGE-224786
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-185845-Dheeraj Bhatt- Get the constant value from metadata
    @AuraEnabled
    public Static String getCurrentUserProfile(){
        PROFILE P= [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        return p.Name;
    }

    private static final String BASKET_CHANGE_TYPE = 'Upgrade';
    private static final String BASKET_CHANGE_STAGE = 'Commercial Configuration';

    @AuraEnabled
    public static Account acc {
        get;
        set;
    }
    //private static final string  ERROR_MESSAGE = 'Error Message From Apex: ';
    @AuraEnabled
    public static String errorMsg {
        get;
        set;
    }
    @AuraEnabled
    public static Account getAccountDetails(String basketId, String accountId) {
        if (basketId != '') {
            cscfga__Product_Basket__c bas = [Select id, csbb__Account__c from cscfga__Product_Basket__c where Id =: basketId];
            acc = [Select id, name from Account where Id =: bas.csbb__Account__c];
        } else if (accountId != '') {
            acc = [Select id, name from Account where Id =: accountId];
        }

        return acc;
    }
    
    @AuraEnabled
    public static String basketId{
        get;
        set;
    }
    /* 
    Modified this method as part of EDGE-144681
    Modified first parameter "solIdList" type from String to List<String>
    */


    //AB: post upgrade changes
    @AuraEnabled
    public static responseStructure createMacOppResponse {
        get;
        set;
    }

/*    @AuraEnabled()
    public static responseStructure getBasketDetails(List<String> solIdList, String accountId, String sourceBasketId, String tnowRefId,String salesSupportCaseId) {
   try{
       /*START-EDGE-185845-Dheeraj Bhatt-To check parent opportunity type is Migration or Not 
      List<csord__Solution__c> solutionList=[SELECT Id,cssdm__product_basket__r.cscfga__Opportunity__r.type FROM csord__Solution__c WHERE ID IN:solIdList];
       string parentOppType= !solutionList.IsEmpty()?solutionList[0].cssdm__product_basket__r.cscfga__Opportunity__r.type:''; 
       /*END-EDGE-185845 
        system.debug('Elements in the solutionList: '+solutionList);
        System.debug('before If solIdList:::'+solIdList);  
        System.debug('salesSupportCaseId:::'+salesSupportCaseId);
        System.debug('sourceBasketId=='+sourceBasketId);
        if (solIdList != null && solIdList.size()>0) {  
            System.debug('Inside solIdList:::'+solIdList);
                //String solId= solIdList;//.substring(2,20);
                //system.debug('solid-->'+solid);
                //system.debug('sourceBasketId-->'+sourceBasketId);
                //AB: post upgrade changes start
            for(String solutionId : solIdList){  //Added this for..loop as part of EDGE-144681
                //different API depending on starting point
                System.debug('SolutionID::'+solutionId);
                if (sourceBasketId == null || sourceBasketId.length() == 0 || sourceBasketId == '') {
                    System.debug('sourceBasketId::'+sourceBasketId);
                    String response = cssmgnt.API_1.createMacOpportunityForSolution(solutionId);
                    system.debug('@@response '+response );
                        createMacOppResponse = (responseStructure) System.JSON.deserializeStrict(response, responseStructure.class);
                        basketId = createMacOppResponse.targetBasketId;
                    
                }
                else {
                    basketId   = sourceBasketId;
                    String response = cssmgnt.API_1.addSolutionToChange(basketId, solutionId);
                    system.debug('addSolutionToChange API response...'+response );
                    createMacOppResponse = (responseStructure) System.JSON.deserializeStrict(response, responseStructure.class);
                }
                //AB: post upgrade changes end
            }
                //basketId = [Select id, Name, cscfga__Opportunity__c, csbb__Account__c, createddate FROM cscfga__Product_Basket__c WHERE csbb__Account__c =: accountId ORDER BY createddate DESC LIMIT 1];
                system.debug('**basketId**'+basketId);
                cscfga__Product_Basket__c macBasket = new cscfga__Product_Basket__c();
                Id macBasketId = Id.valueOf(basketId);
                // EDGE 165478 start- update preauthorised to true when POR is present
                macBasket = [Select Id, cscfga__Opportunity__c,cscfga__Opportunity__r.isPOROpportunity__c,referencenumber__c, csbb__Account__c, csbb__Account__r.Name, csordtelcoa__Change_Type__c from cscfga__Product_Basket__c WHERE Id =: macBasketId LIMIT 1];
               system.debug('macBasket-->'+macBasket);
                macBasket.csordtelcoa__Change_Type__c = 'Change Solution';
                if(tnowRefId != null && tnowRefId != '') {//EDGE-132715
                    macBasket.referencenumber__c = tnowRefId.toUpperCase();
                    macBasket.Pre_Authorised__c=true;//EDGE-153459
                }
                //EDGE-172345 start
                if(String.isNotEmpty(salesSupportCaseId)){
                    macBasket.SalesSupport_CaseNumber__c =salesSupportCaseId;
                    macBasket.Pre_Authorised__c=true;
                }
             //EDGE-172345 end
             update macBasket;
            //update Opportunity if MACD started from 
            //EDGE-185845-Dheeraj Bhatt-Sending Parent opportunity Type in updateOpportunity Method
            if (sourceBasketId == null || sourceBasketId.length() == 0){
                updateOpportunity(macBasket.cscfga__Opportunity__c, macBasket.csbb__Account__r.Name,parentOppType);
             }
            // EDGE-165478 start - to update Pre_Authorised__c if POR is present
            cscfga__Product_Basket__c updatePreOuthForPOR = [Select Id,Pre_Authorised__c,cscfga__Opportunity__c,cscfga__Opportunity__r.isPOROpportunity__c from cscfga__Product_Basket__c WHERE Id =: macBasketId LIMIT 1];
            if(updatePreOuthForPOR.cscfga__Opportunity__r.isPOROpportunity__c){
                updatePreOuthForPOR.Pre_Authorised__c=true;
            }
            update updatePreOuthForPOR;
            // EDGE-165478 end
            system.debug('heap check custom code after package API '+limits.getHeapSize());

        }
            return createMacOppResponse;
        }catch(Exception e){
            system.debug('heap check in the exception'+limits.getHeapSize());
            throw new AuraHandledException('Error Retrieving Records: '+ e.getMessage());
        }
    }
*/
    
  
    @AuraEnabled()
    public static responseStructure getBasketDetails_new(String solId, String accountId, String sourceBasketId, String tnowRefId,String salesSupportCaseId, String contactId) {
    try{
        /*START-EDGE-185845-Dheeraj Bhatt-To check parent opportunity type is Migration or Not */
        List<csord__Solution__c> solutionList=[SELECT Id,cssdm__product_basket__r.cscfga__Opportunity__r.type FROM csord__Solution__c WHERE ID =:solId];
        string parentOppType= !solutionList.IsEmpty()?solutionList[0].cssdm__product_basket__r.cscfga__Opportunity__r.type:''; 
        /*END-EDGE-185845 */
        system.debug('Elements in the solutionList: '+solId);
        if (solId != null && solId !='') {  
                //different API depending on starting point
            if (sourceBasketId == null || sourceBasketId.length() == 0 || sourceBasketId == '') {
                System.debug('sourceBasketId::'+sourceBasketId);
                String response = cssmgnt.API_1.createMacOpportunityForSolution(solId);
                system.debug('@@response '+response );
                createMacOppResponse = (responseStructure) System.JSON.deserializeStrict(response, responseStructure.class);
                basketId = createMacOppResponse.targetBasketId;

                system.debug('**basketId**'+basketId);
                cscfga__Product_Basket__c macBasket = new cscfga__Product_Basket__c();
                Id macBasketId = Id.valueOf(basketId);
                // EDGE 165478 start- update preauthorised to true when POR is present
                macBasket = [Select Id, cscfga__Opportunity__c,cscfga__Opportunity__r.isPOROpportunity__c,referencenumber__c, csbb__Account__c, csbb__Account__r.Name, csordtelcoa__Change_Type__c,Pre_Authorised__c from cscfga__Product_Basket__c WHERE Id =: macBasketId LIMIT 1];
                system.debug('macBasket-->'+macBasket);
                createMacOppResponse.opportunityId = macBasket.cscfga__Opportunity__c;
                macBasket.csordtelcoa__Change_Type__c = 'Change Solution';
                if(tnowRefId != null && tnowRefId != '') {//EDGE-132715
                    macBasket.referencenumber__c = tnowRefId.toUpperCase();
                    macBasket.Pre_Authorised__c=true;//EDGE-153459
                }
                //EDGE-172345 start
                if(String.isNotEmpty(salesSupportCaseId)){
                    macBasket.SalesSupport_CaseNumber__c =salesSupportCaseId;
                    macBasket.Pre_Authorised__c=true;
                }
                //EDGE-172345 end
                // EDGE-165478 start - to update Pre_Authorised__c if POR is present
                if(macBasket.cscfga__Opportunity__r.isPOROpportunity__c){
                    macBasket.Pre_Authorised__c=true;
                }
                update macBasket;
                //update Opportunity if MACD started from 
                //EDGE-185845-Dheeraj Bhatt-Sending Parent opportunity Type in updateOpportunity Method
                updateOpportunity(macBasket.cscfga__Opportunity__c, macBasket.csbb__Account__r.Name,parentOppType);
                
                // EDGE-165478 start - to update Pre_Authorised__c if POR is present
                //cscfga__Product_Basket__c updatePreOuthForPOR = [Select Id,Pre_Authorised__c,cscfga__Opportunity__c,cscfga__Opportunity__r.isPOROpportunity__c from cscfga__Product_Basket__c WHERE Id =: macBasketId LIMIT 1];
                //if(updatePreOuthForPOR.cscfga__Opportunity__r.isPOROpportunity__c){
                    //updatePreOuthForPOR.Pre_Authorised__c=true;
                //}
                //update updatePreOuthForPOR;

                // Create Oppty Contact Role
                createContactInOpportunity(macBasket.cscfga__Opportunity__c, contactId);
            }
            else {
                System.debug('Basket Id is not NULL...'+sourceBasketId);
                basketId   = sourceBasketId;
                String response = cssmgnt.API_1.addSolutionToChange(basketId, solId);
                system.debug('addSolutionToChange API response...'+response );
                createMacOppResponse = (responseStructure) System.JSON.deserializeStrict(response, responseStructure.class);
                cscfga__Product_Basket__c macBasket = new cscfga__Product_Basket__c();
                Id macBasketId = Id.valueOf(basketId);
                macBasket = [Select Id, cscfga__Opportunity__c,cscfga__Opportunity__r.isPOROpportunity__c,referencenumber__c, csbb__Account__c, csbb__Account__r.Name, csordtelcoa__Change_Type__c,Pre_Authorised__c from cscfga__Product_Basket__c WHERE Id =: macBasketId LIMIT 1];
                system.debug('macBasket-->'+macBasket);
                createMacOppResponse.opportunityId = macBasket.cscfga__Opportunity__c;
                System.debug('createMacOppResponse...'+createMacOppResponse);
            }
                //AB: post upgrade changes end
            
               
            // EDGE-165478 end
            system.debug('heap check custom code after package API '+limits.getHeapSize());

        }
        return createMacOppResponse;
        }catch(Exception e){
            system.debug('heap check in the exception'+limits.getHeapSize());
            throw new AuraHandledException('Error Retrieving Records: '+ e.getMessage());
        }
    }

    // Method to get all list view option available for the Account object 
    @AuraEnabled(cacheable=true)
        public static List < SolWrapper > getSolutionView(String basketId, String accountId) {
        String accId = accountId;
        String basId = basketId;

        //System.debug('getSolutionView basketId:'+ basketId);
        //System.debug('getSolutionView accountId:'+ accountId);
        // EDGE-138655 - Start
        Map<string,string> siteMap=new Map<string,string>();
        Map<String,String> subtoSolMap=new  Map<String,String>();
        Map<String,String> fixedNumMap=new Map<String,String>();
        Map<String,String> mobileNumMap=new Map<String,String>();
        Map<string,string> subIdtoSolMap=new Map<string,string>(); //EDGE-149079
        Map<string,string> assetIDMap=new Map<string,string>();//EDGE-149079
            for(csord__subscription__c sub:[select id,Site__c,Site__r.cscrm__Installation_Address__r.Name,cssdm__solution_association__c,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Account__c=:accountId])
            { 
            //System.debug('sub'+sub);
           if(sub.Site__c!=null && sub.Site__r.cscrm__Installation_Address__r.Name!=null && sub.cssdm__solution_association__c!=null){
               if(siteMap.containsKey(sub.cssdm__solution_association__c))
               {
                   String sites=siteMap.get(sub.cssdm__solution_association__c);
                   sites=sites+'||'+sub.Site__r.cscrm__Installation_Address__r.Name;
                   siteMap.put(sub.cssdm__solution_association__c,sites);
               }else{
                   String sites1=sub.Site__r.cscrm__Installation_Address__r.Name;
                   siteMap.put(sub.cssdm__solution_association__c,sites1);
               }
            }
            subtoSolMap.put(sub.csordtelcoa__Subscription_Number__c,sub.cssdm__solution_association__c);
            subIdtoSolMap.put(sub.id,sub.cssdm__solution_association__c);//EDGE-149079
            }
             //System.debug('subtoSolMap'+subtoSolMap);
            for(Number__c num:[select id,Mobile__c,Service_Number__c,Service_Id__c,Subscription_number__c from Number__c where Subscription_number__c IN :subtoSolMap.keyset()])
            {  
                if(num.Mobile__c=='Fixed')
                {
                 if(fixedNumMap.containsKey(subtoSolMap.get(num.Subscription_number__c)))
                   {
                   String fixedNum=fixedNumMap.get(subtoSolMap.get(num.Subscription_number__c));fixedNum=fixedNum+','+num.Service_Number__c;
                   fixedNumMap.put(subtoSolMap.get(num.Subscription_number__c),fixedNum);
                   }else{
                   String fixedNum1=num.Service_Number__c;fixedNumMap.put(subtoSolMap.get(num.Subscription_number__c),fixedNum1);
                  }
                }else{
                    if(mobileNumMap.containsKey(subtoSolMap.get(num.Subscription_number__c)))
                    {
                    String mobileNum=mobileNumMap.get(subtoSolMap.get(num.Subscription_number__c));
                    mobileNum=mobileNum+','+num.Service_Number__c;mobileNumMap.put(subtoSolMap.get(num.Subscription_number__c),mobileNum);
                    }else{
                    String mobileNum1=num.Service_Number__c;mobileNumMap.put(subtoSolMap.get(num.Subscription_number__c),mobileNum1);
                   }
                }

            }
            //EDGE-149079 - start
            for(Asset aset : [Select id,name,AssetID__c,Subscription__c,Status from Asset where Subscription__c IN :subIdtoSolMap.keyset()])
            {
                if(aset.AssetID__c!=null){
                if(assetIDMap.containsKey(subIdtoSolMap.get(aset.Subscription__c)))
               {
                   String assets=assetIDMap.get(subIdtoSolMap.get(aset.Subscription__c));
                   assets=assets+'||'+aset.AssetID__c;
                   assetIDMap.put(subIdtoSolMap.get(aset.Subscription__c),assets);
               }else{
                   String assets1=aset.AssetID__c;
                   assetIDMap.put(subIdtoSolMap.get(aset.Subscription__c),assets1);
               }
            }

            }
            //EDGE-149079 - End
              //System.debug('mobileNumMap'+mobileNumMap);
              //System.debug('fixedNumMap'+fixedNumMap);
              //System.debug('assetIDMap'+assetIDMap);

           // EDGE-138655 - End

            cscfga__Product_Basket__c bas = new cscfga__Product_Basket__c();
        
        List <csord__Solution__c > solList = new List <csord__Solution__c >();
            //EDGE-166269 start------
                String MacdNotAppliedoffers=System.Label.MacdNotAppliedoffers;
                Set<String>  MacdNotAppliedoffersSet=new Set<String>(MacdNotAppliedoffers.split(','));
            //EDGE-166269 end------
        if(basId != null && basId != ''){

            bas = [Select id, csbb__Account__c from cscfga__Product_Basket__c where Id =: basketId];
            accId = bas.csbb__Account__c;

            //get solutions from the basket
            List<csord__Solution__c> existingList = [
                SELECT Id, Name, csord__Status__c, csord__Account__c, cssdm__product_basket__c from csord__Solution__c
                WHERE csord__Account__c =: accId AND Id IN (SELECT cssdm__solution_association__c FROM cscfga__Product_Configuration__c
                    WHERE cscfga__Product_Basket__c =: basId)                
            ];
            Set<Id> solSet = new Set<Id>();
            for(csord__Solution__c sol: existingList){
                solSet.add(sol.Id);
            }
            //filter already present solution from the query
            
            solList = [
                SELECT id, Name, CreatedDate, csord__Status__c, cssdm__total_contract_value__c, cssdm__total_one_off_charge__c, cssdm__total_recurring_charge__c, 
                CreatedById, CreatedBy.Name, csord__Account__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name 
                FROM csord__Solution__c
                WHERE Id IN (SELECT cssdm__solution_association__c FROM csord__Subscription__c WHERE cssdm__solution_association__c != null and csord__Status__c NOT IN('Inactive', 'Closed') and csordtelcoa__Replacement_Subscription__c = null AND MarketableOffer__r.Offer_ID__c NOT IN:MacdNotAppliedoffersSet ) //change 2 //EDGE-182533-Added Filer on Status NOT IN('Inactive', 'Closed')
                    //SELECT cssdm__solution_association__c FROM csord__Subscription__c WHERE cssdm__solution_association__c != null) 
                AND cssdm__product_basket__c !=: basId
                AND csord__Account__c =: accId
                                        //AND csord__Status__c = 'Completed' //EDGE-169967 - Removed Solution Status check. Its filtered on Subscription status.
                                                               AND Id !=: solSet ORDER BY CreatedDate desc //LIMIT 1
            ];
        }////EDGE-166269 updated subscription query to restrict non applicable subscription
        else{
            solList = [
                SELECT id, Name, CreatedDate, csord__Status__c, cssdm__total_contract_value__c, cssdm__total_one_off_charge__c, cssdm__total_recurring_charge__c, 
                CreatedById, CreatedBy.Name, csord__Account__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name 
                FROM csord__Solution__c
                WHERE Id IN (SELECT cssdm__solution_association__c FROM csord__Subscription__c WHERE cssdm__solution_association__c != null and csord__Status__c NOT IN('Inactive', 'Closed') and csordtelcoa__Replacement_Subscription__c = null AND MarketableOffer__r.Offer_ID__c NOT IN:MacdNotAppliedoffersSet ) //change 2 //EDGE-182533-Added Filer on Status NOT IN('Inactive', 'Closed')
                AND csord__Account__c =: accId
                //AND csord__Status__c = :LABEL.Solution_Status 
                ORDER BY CreatedDate desc //LIMIT 1//EDGE-188859 commented by shubhi
            ];          
        }
        List < Solwrapper > solwrapList = new List < SolWrapper > ();
        List < String > args = new String[] {
            '0',
            'number',
            '###,###,##0.00'
        };

        for (csord__Solution__c sol: solList) {
            SolWrapper solw = new SolWrapper();
            solw.SolutionID = sol.id;
            solw.SolutionName = sol.Name;  
            //solw.solutionNameLink = '/' + sol.id;
            solw.solutionNameLink ='/'+ sol.id;//solw.solutionNameLink ='/apex/subDetails?id='+ sol.id+'&isdtp=vw';
            solw.status = sol.csord__Status__c;
            solw.createdBy = sol.CreatedBy.Name;
            solw.productDefinitionName = sol.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name;
            //format date
            String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
            solw.createdDate = sol.CreatedDate.format(dateFormatString);
            //format currency
            Decimal oc;
            Decimal rc;
            Decimal cv;
                
             rc = sol.cssdm__total_recurring_charge__c == null? 0: sol.cssdm__total_recurring_charge__c;
             oc = sol.cssdm__total_one_off_charge__c == null? 0: sol.cssdm__total_one_off_charge__c;
             cv = sol.cssdm__total_contract_value__c == null? 0: sol.cssdm__total_contract_value__c;    
            
            String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
            String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
            String finalcv = cv.format().contains('.') ? cv.format() : (cv.format() + '.00');
                
            solw.totalRC = '$ ' + String.format(finalrc, args);
            solw.totalOC = '$ ' + String.format(finaloc, args);
            solw.totalCV = '$ ' + String.format(finalcv, args);
            //System.debug('getSolutionView sol_Name:'+ sol.Name);
            if (SYSTEM.LABEL.Active_Status.equalsIgnoreCase(sol.csord__status__c)) {
                solw.disableRow = false;
            }
            else {
                //System.debug('getSolutionView sol_Name:entered else'+ sol.Name);
                solw.disableRow = true;
            }//[EDGE-123942]to implement AC-5 of EDGE-113349 > to disable the records of professional service
            if(sol.Name == 'Professional Services') {
                //System.debug('getSolutionView sol_Name:entered if'+ sol.Name);
                solw.disableRow = true;
            }
            //System.debug('sites'+siteMap.get(sol.id));
            //System.debug('solID'+sol.id);
            solw.site=siteMap.get(sol.id);
            solw.mobile=mobileNumMap.get(sol.id); //added as part of EDGE-138655
             //System.debug('mobileNumMap'+mobileNumMap.get(sol.id));
            solw.fixedNo=fixedNumMap.get(sol.id); //added as part of EDGE-138655
            //System.debug('fixedNumMap'+fixedNumMap.get(sol.id));
            solw.deviceId=assetIDMap.get(sol.id); //added as part of EDGE-149079
            //System.debug('assetIDMap'+assetIDMap.get(sol.id));
            solwrapList.add(solw);
        }
        return solwrapList;
    }

    public static String getSobjectFields(String so) {
        String fieldString;
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        List < Schema.SObjectField > fields = sot.getDescribe().fields.getMap().values();
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }
    
    public static void updateOpportunity(Id oppId, String accountName,string parentOppType) {
        String profileName=getCurrentUserProfile() ;//EDGE-185845-Dheeraj Bhatt-get the logged in User Profile to check BOH user
        Opportunity opp = new Opportunity();
        //Added by Aman Soni for EDGE-167800 || Start
        Model_Opportunity getOpp = new Model_Opportunity();
        opp = getOpp.getOpportunity(oppId);
        //Added by Aman Soni for EDGE-167800 || End
        opp.Name = 'MACD Solution' + ' ' + accountName + ' ' + String.valueOf(opp.CreatedDate.format()); 
        opp.StageName = OPPORTUNITY_STAGE;
        opp.CloseDate = date.today().addDays(30);
        opp.Revenue_Impact_Date__c = opp.CloseDate + 15;//Added by Aman Soni for EDGE-167800
        opp.Product_Type__c = OPPORTUNITY_PRODUCT_TYPE;
        opp.Product_Domain__c = OPPORTUNITY_PRIMARY_DOMAIN;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();       
        opp.RecordTypeId = oppRecordTypeId; 
        //EDGE-185845-Dheeraj Bhatt-Checking parent opp is 'Migration' type or logged in user is BOH User then assign opportunity type to Migration
        if((customMetadataNameValueMap.containsKey('MigrationUserProfile') && profileName == customMetadataNameValueMap.get('MigrationUserProfile').get('Value__c') )&& parentOppType==customMetadataNameValueMap.get('Migration').get('Value__c')){
            opp.Type= String.valueOf(customMetadataNameValueMap.get('Migration').get('Value__c'));
        }
        else {
            opp.Type=OPPORTUNITY_TYPE_MAC;   
        }
            //opp.AccountId = accountId;        
        opp.In_Contract_MAC__c = OPPORTUNITY_IN_CONTRACT;
        opp.IS_MACD__c = true; //EDGE-140756
        Update opp;
    }    



    public static void updateOpportunityType(Id opportunityId, String changeType) {
        if (changeType == CHANGE_TYPE_MODIFY) {
            Opportunity opp = new Opportunity();
            opp = [SELECT Type FROM Opportunity WHERE Id =: opportunityId];

            if (opp.Type == OPPORTUNITY_TYPE_DISCONNECT) {
                opp.Type = OPPORTUNITY_TYPE_MAC;
                UPDATE opp;
            }
        }
    }

    public static Set < Id > getProductConfigurationsInUse(Id accountId) {
        Set < Id > prodConfigIdSet = new Set < Id > ();

        List < cscfga__Product_Configuration__c > prodConfigList = new List < cscfga__Product_Configuration__c > ();
        prodConfigList = [SELECT csordtelcoa__Replaced_Product_Configuration__c
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__r.csbb__Account__c =: accountId
            AND cscfga__Product_Basket__r.csbb__Synchronised_With_Opportunity__c = true
            AND cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c IN('Contract Initiated', 'Contract Accepted', 'Enriched', 'Submitted')
            AND csordtelcoa__Replaced_Product_Configuration__c != null
            AND(NOT cscfga__Product_Basket__r.cscfga__Opportunity__r.StageName LIKE 'Closed%')
            AND(NOT cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.UC_Config_Name + '%')
            AND(NOT cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.IP_Network)
        ];

        for (cscfga__Product_Configuration__c prodConfig: prodConfigList) {
            prodConfigIdSet.add(prodConfig.csordtelcoa__Replaced_Product_Configuration__c);
        }
        return prodConfigIdSet;
    }
    
    // Method to check if some product type is present in the basket 
    @AuraEnabled
    public static boolean ifProductPresent(String basketId, String type) {
        boolean present = false;
        List < cscfga__Product_Configuration__c > basket = new List < cscfga__Product_Configuration__c > ();
        basket = [
            SELECT id, Name
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c =: basketId
        ];
        for (cscfga__Product_Configuration__c product: basket) {
            if (product.Name.contains(type)) {
                present = true;
            }
        }
        return present;
    }
    @AuraEnabled
    public static Integer noOfProductPresentUnderModify(String basketId, String type) {
        Integer present = 0;
        List < cscfga__Product_Configuration__c > basket = new List < cscfga__Product_Configuration__c > ();
        basket = [
            SELECT id, Name, cscfga__Product_Definition__r.Name, Type__c
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c =: basketId
        ];
        for (cscfga__Product_Configuration__c product: basket) {
            if (product.cscfga__Product_Definition__r.Name.contains(type) && product.Type__c == 'Modify') {
                present++;
            }
        }
        return present;
    }

    @AuraEnabled
    public static AccountContactRelation acr {
        get;
        set;
    }
    @AuraEnabled
    public static AccountContactRelation getACRId(Id basketId) {
        List < cscfga__Product_Basket__c > basket = new List < cscfga__Product_Basket__c > ([select csbb__Account__r.id, cscfga__Opportunity__r.id from cscfga__Product_Basket__c where id =: basketId]);
        List < OpportunityContactRole > ocr = new List < OpportunityContactRole > ([Select Id, ContactId from OpportunityContactRole where OpportunityId =: basket[0].cscfga__Opportunity__r.id]);
        if (!ocr.IsEmpty()) {
            List < AccountContactRelation > listACR = new List < AccountContactRelation > ([select id, ContactId, AccountId, Contact_Name__c, Roles from AccountContactRelation where AccountId =: basket[0].csbb__Account__r.id and ContactId =: ocr[0].ContactId]);

            if (!listACR.IsEmpty())
                AccountContactRelation acr = new AccountContactRelation();
            acr = listACR[0];
            return acr;
        }
        return null;
    }
    
    // Create opportunity Contact Role
    @AuraEnabled
    public static void createContactInOpportunity(Id OppId, Id conId){
    //System.debug('Contact Obj--------'+ conId );
        //String mailId = (String)con.get('Email');
     List<OpportunityContactRole> ocrOld = new List<OpportunityContactRole>
                                ([Select Id , ContactId 
                                  from OpportunityContactRole 
                                    where OpportunityId =: OppId ]);
      if(!ocrOld.isEmpty())
          delete ocrOld;
     OpportunityContactRole ocr = new OpportunityContactRole(ContactId = conId,OpportunityId = OppId,Role='Decision Maker');
      //System.debug('New OCR--------'+ ocr);
    insert ocr;
    }
    //Ch no 1 EDGE-95594 Method to Get Opportunity ID from Basket ID
        @AuraEnabled
    public static Id getOpportunityId (Id basketId){
        Id opportunityId = [ 
                                SELECT cscfga__Opportunity__c
                                FROM cscfga__Product_Basket__c
                                WHERE Id = :basketId 
                           ].cscfga__Opportunity__c;
        return opportunityId;
    }
    // Added by Rohit for EDGE-141989
  @AuraEnabled(cacheable=false)
  public static String  getJobStatus (Id OpptyId){
        //System.debug('Oppty ID -->'+OpptyId);
        csordtelcoa.StatusResult jobStatus =  csordtelcoa.API_V1.pollOpportunitySubscriptionsResult(OpptyId); 
        String status = 'SUCCESS'; //R34UPGRADE defaulting to SUCCESS as async part of the process is removed so pollOpportunitySubscriptionsResult returns null
        if (jobStatus != null)
            status = string.valueof(jobStatus.status);
        //System.debug('Job Status...'+status);
        return status;
    }
    @AuraEnabled(cacheable=true)   //added method as part of EDGE-138655
    public static List <Subwrapper> getSubscriptionDetails(String solutionId) {
        //System.debug('getSubscriptionDetails..'+solutionId);
        //query modified as part of DIGI-926
        List <csord__Subscription__c > subList = [Select id,Name,csordtelcoa__Subscription_Number__c,Site__r.Name,customerFacingServiceId__c,
                                                  Site__r.Address__c,CreatedBy.Name,CreatedDate,Site__c,Access_Type__c,csord__Status__c,csord__Total_Recurring_Charges__c,Billing_Account__r.Billing_Account_Number__c,serviceMSISDN__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c from csord__Subscription__c where cssdm__solution_association__c=:solutionId];
        List <Subwrapper> subwrapList = new List <SubWrapper>();
        List < String > args = new String[] {
            '0',
                'number',
                '###,###,##0.00'
                };
                    for (csord__Subscription__c su: subList) {
                        SubWrapper suw = new SubWrapper();
                        suw.subNameLink ='/'+ su.id;
                        suw.SubscriptionID = su.id;
                        suw.subscriptionName = su.Name;
                        suw.SiteID = su.Site__c;
                        suw.accessType=su.Access_Type__c;
                        suw.siteAddress = su.Site__r.Address__c;
                        suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                        suw.status = su.csord__Status__c;
                        //added as part of DIGI-926                        
                        if  (su.csordtelcoa__Product_Configuration__c !=null && su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c!=null && su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c!= null && su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == System.label.SDWAN_ADAPT_OFFER)
                        {                            
                        suw.ServiceId = su.customerFacingServiceId__c;
                        }
                        else
                        {
                            suw.ServiceId = su.serviceMSISDN__c;
                        }
                        suw.createdBy = su.CreatedBy.Name;
                        suw.billingAccount = su.Billing_Account__r.Billing_Account_Number__c;
                        Decimal rc = su.csord__Total_Recurring_Charges__c;
                        String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
                        suw.createdDate = su.CreatedDate.format(dateFormatString);
                        String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                        suw.totalRC = '$ ' + String.format(finalrc, args);
                        subwrapList.add(suw);
                        
                    }
        //System.debug('getSubscriptionDetails.. subwrapList'+subwrapList);
        return subwrapList;
    }
    //
    /*  
     * Method Name : isBillingAccountValid
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    @AuraEnabled(cacheable=true)   
    public static Boolean isBillingAccountValid(List<String> solutionIdSet) {
        String statusValues=System.Label.BillingAccountStatus;
        Set<String> billingAccStatusSet=new Set<String>(statusValues.split(','));
        Map<String,csord__Subscription__c> submap= Model_Subscription.getSubscriptionsbasedonBillaccStatus(new Set<String>(solutionIdSet),billingAccStatusSet);
        return (submap!=null && submap.size()>0)?false:true;
    }

    //incident INC000093454566 added by shubhi start-------------
    /*@AuraEnabled(cacheable=true)
    public static ID updateDirtyFlag(List<String> solutionIdList) {
        ID jobID = System.enqueueJob(new dirtyFlagQueueable(solutionIdList));
        return jobID;
    }
    @AuraEnabled(cacheable=false)
    public static String getDirtyFlagJobStatus( ID jobID) {
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
       String status = '';
        if (jobInfo != null)
            status = jobInfo.status;
        return status;
    }*/
    //incident INC000093454566 added by shubhi end-------------

    //AB: post upgrade changes start
    //starts postSelectiveMACDProcessing API to relink PC to new solution
    @AuraEnabled(cacheable=false)
    public static string postSelectiveMACDProcessing(Id basketId, Id targetSolutionId){
        //getting all values from controller variables
        //added by shubhi for Parallel macd fix--------------------------------------start
        String response='';
        response = cssmgnt.API_1.postSelectiveMACDProcessing(basketId, targetSolutionId);
        system.debug('response==='+response);
        return response;
        //added by shubhi for Parallel macd fix--------------------------------------end
    } 

    //starts createHerokuMACDSolution API, needs to be seperate call as it contains callout so no DMLs allowed before it
    @AuraEnabled(cacheable=false)
    public static void createHerokuMACDSolution(Id replacedSolutionId, Id targetSolutionId, Id basketId, Id targetMainConfig){
        //getting all values from controller variables
        //Main configuration is now created so get it
        /*cscfga__Product_Configuration__c targetMainConfig = [SELECT Id
                                                        FROM cscfga__Product_Configuration__c 
                                                        WHERE csordtelcoa__Replaced_Product_Configuration__c = :replacedMainConfigurationId
                                                        LIMIT 1];*/// commented query for parallel macd fix
        Map<String, String> requestMap = new Map<String, String>{
            'replacedSolutionId' => replacedSolutionId,
            'targetSolutionId' => targetSolutionId,
            'targetBasketId' => basketId,
            'targetMainConfigurationId' => targetMainConfig,////added by shubhi for Parallel macd fix
            'changeType' => 'Change Request'
        };
        cssmgnt.SolutionMACDController.createHerokuMACDSolution(requestMap);
        //cssmgnt.SolutionMACDController.createHerokuMACDSolution(replacedSolutionId, targetSolutionId, basketId, targetMainConfig.Id, 'Change Request');
    }
    //DPG-1915
    @AuraEnabled
    public static boolean getUserValidatedForAC(string accountId )
    {
        boolean isValid= false;      
        Id userId = userinfo.getUserId();
        Account acc = [Select id, name,OwnerId from Account where Id =: accountId];
        // the if logged in user is partner
        Boolean hasCustomPartnerPermission=FeatureManagement.checkPermission('Partner_User');// for Partner user
        system.debug('hasCustomPartnerPermission==>'+hasCustomPartnerPermission);
        if(hasCustomPartnerPermission)
        {
            // check if partner of record is presend or not.
            //Single Query (Account and POR)
        List<Partner_of_Record__c> lst_por = [SELECT id,OwnerId, Start_Date__c,End_Date__c, Product_Domain__c, Name, Customer__c, Customer__r.FraudFlag__c, Customer__r.OwnerId,Customer__r.Name, Partner__c, Partner__r.OwnerId,Partner__r.Name FROM Partner_of_Record__c WHERE Customer__c =:accountId];
            //HasPOR__mdt por=[Select id, HasPOR__c from HasPOR__mdt];
            if(lst_por.size()>0 && lst_por[0]!=null)
            {
                isValid= true;
                //Errortxt=System.Label.No_POR;
            }
        }
        //if logged user is AE
        else if(acc.OwnerId==userId)
        { 
            isValid= true;
            system.debug('isValid==>'+isValid);         
        }
        // other than AE or Partner
        else
        {
            isValid= false;
        }
        return isValid;
    }

    //Added by Aman Soni/Shubhi for EDGE-224786 || Start
    @AuraEnabled
    public static String  processChangeSolution(String accountName,String solId, String accountId, String sourceBasketId, String tnowRefId,String salesSupportCaseId, String contactId) {
        try{
            List<csord__Solution__c> solutionList = new List<csord__Solution__c>();
            solutionList = [SELECT Id,cssdm__product_basket__r.cscfga__Opportunity__r.type FROM csord__Solution__c WHERE ID =:solId];
            String parentOppType = !solutionList.IsEmpty()?solutionList[0].cssdm__product_basket__r.cscfga__Opportunity__r.type:''; 
            String profileName = getCurrentUserProfile();

            if(solId != null && solId !='' && String.isBlank(sourceBasketId)) {
                
                //Create Opportunity Field Value Map for dynamic object creation
                Map<String,String> oppFieldValueMap = new Map<String,String>();
                oppFieldValueMap.put('Name','MACD Solution' + ' ' + accountName + ' ' + + String.valueOf(Datetime.Now().format()));
                oppFieldValueMap.put('AccountId',accountId);
                oppFieldValueMap.put('StageName',OPPORTUNITY_STAGE);
                oppFieldValueMap.put('CloseDate',String.valueof(date.today().addDays(30)));
                oppFieldValueMap.put('Revenue_Impact_Date__c',String.valueof(date.today().addDays(45)));
                oppFieldValueMap.put('Product_Type__c',OPPORTUNITY_PRODUCT_TYPE);
                oppFieldValueMap.put('Product_Domain__c',OPPORTUNITY_PRIMARY_DOMAIN);
                Id oppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();       
                oppFieldValueMap.put('RecordTypeId',oppRecordTypeId);
                oppFieldValueMap.put('In_Contract_MAC__c',OPPORTUNITY_IN_CONTRACT);
                oppFieldValueMap.put('csordtelcoa__Change_Type__c',CHANGE_TYPE);
                oppFieldValueMap.put('IS_MACD__c','true');
                if(contactId == 'dummy')
	                oppFieldValueMap.put('isInsolvencyCancel__c','true');//EDGE-9239				
                if((customMetadataNameValueMap.containsKey('MigrationUserProfile') && profileName == customMetadataNameValueMap.get('MigrationUserProfile').get('Value__c') ) && parentOppType==customMetadataNameValueMap.get('Migration').get('Value__c')){
                    oppFieldValueMap.put('Type',String.valueOf(customMetadataNameValueMap.get('Migration').get('Value__c')));
                }
                else {
                    oppFieldValueMap.put('Type',OPPORTUNITY_TYPE_MAC);   
                }

                //Call createDynamicOpportunity with oppty field value map for record creation
                String opportunityId = '';
                if(!oppFieldValueMap.isEmpty()){
                    opportunityId = CommercialMACOrderHelper.createDynamicOpportunity(oppFieldValueMap);
                }

                //Create Product Basket Field Value Map for dynamic object creation
                Map<String,String> basketFieldValueMap = new Map<String,String>();
                basketFieldValueMap.put('csordtelcoa__Change_Type__c',CHANGE_TYPE);
                if(String.isNotBlank(accountId) && String.isNotBlank(opportunityId)){
                    basketFieldValueMap.put('csbb__Account__c',accountId);
                    basketFieldValueMap.put('cscfga__Opportunity__c',opportunityId);
                }    
                if(String.isNotBlank(tnowRefId)) {
                    basketFieldValueMap.put('referencenumber__c',tnowRefId.toUpperCase());
                    basketFieldValueMap.put('Pre_Authorised__c','true');
                }
                if(String.isNotBlank(salesSupportCaseId)){
                    basketFieldValueMap.put('SalesSupport_CaseNumber__c',salesSupportCaseId);
                    basketFieldValueMap.put('Pre_Authorised__c','true');
                }

                //Call createDynamicProductBasket with basket field value map for record creation
                if(!basketFieldValueMap.isEmpty()){
                    sourceBasketId = CommercialMACOrderHelper.createDynamicProductBasket(basketFieldValueMap);
                }

                // Create Oppty Contact Role
                if(String.isNotBlank(opportunityId) && String.isNotBlank(contactId) && contactId != 'dummy'){//EDGE-9239 dummy check for insolvency
                    CommercialMACOrderHelper.createOpptyContactRole(opportunityId, contactId);
                }
            }
            if(Test.isRunningTest()){ 
                throw new MyAuraException('Throwing custom exception');
            }          
        }catch(Exception e){
            system.debug('Exception in processChangeSolution:: '+e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getMessage()); 
        }
        return sourceBasketId;
    }
    //Added by Aman Soni/Shubhi for EDGE-224786 || End

    //Added by Aman Soni/Shubhi for EDGE-224786 || Start
    @AuraEnabled
    public static responseStructure addSolutionTomacBasket(String sourceBasketId,String solId) {
        try{
            String response = '';
            if(String.isNotBlank(sourceBasketId) && String.isNotBlank(solId)){
                response = cssmgnt.API_1.addSolutionToChange(sourceBasketId, solId);
            }          

            createMacOppResponse = (responseStructure) System.JSON.deserializeStrict(response, responseStructure.class);
            cscfga__Product_Basket__c macBasket = new cscfga__Product_Basket__c();
            Id macBasketId = Id.valueOf(sourceBasketId);
            macBasket = [Select Id, cscfga__Opportunity__c,cscfga__Opportunity__r.isPOROpportunity__c,referencenumber__c, csbb__Account__c, csbb__Account__r.Name, csordtelcoa__Change_Type__c,Pre_Authorised__c from cscfga__Product_Basket__c WHERE Id =: macBasketId LIMIT 1];
            createMacOppResponse.opportunityId = macBasket.cscfga__Opportunity__c;
            if(macBasket.cscfga__Opportunity__r.isPOROpportunity__c){
                macBasket.Pre_Authorised__c=true;
            }
            update macBasket;
            if(Test.isRunningTest()){ 
                throw new MyAuraException('Throwing custom exception');
            }
        }catch(Exception e){
            system.debug('Exception in addSolutionTomacBasket:: '+e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getMessage());
        }
        return createMacOppResponse;
    }
    //Added by Aman Soni/Shubhi for EDGE-224786 || End

    //innner classes
    public class responseStructure {
        @AuraEnabled public string changeType {get; set;}
        @AuraEnabled public string replacedMainConfigurationId {get; set;}
        @AuraEnabled public string targetMainConfigurationId {get; set;}
        @AuraEnabled public string targetBasketId {get; set;}
        @AuraEnabled public string targetSolutionId {get; set;}
        @AuraEnabled public string replacedSolutionId {get; set;}
        @AuraEnabled public string opportunityId {get; set;}
    }
    //AB: post upgrade changes end

         //Added new method for parallel MAC validation-INC000097366399- Ramya, MTM    
         @AuraEnabled
         public static List<csord__Solution__c> checkExistingMac(List<String> solutionId){
             system.debug('solutionId' +solutionId);
             list <csord__Solution__c> macSolutionList =  new list <csord__Solution__c> ();
             try {
                 macSolutionList=[select id from csord__Solution__c where cssdm__replaced_solution__c IN :solutionId AND cssdm__product_basket__r.csordtelcoa__Basket_Stage__c!='Submitted' AND cssdm__product_basket__r.csordtelcoa__Basket_Stage__c!='Cancelled'
         ];
                 
             } catch (Exception e) {
                 system.debug('Exception in fetching solutionList in Method: checkExistingMac'+e);
             }
              system.debug('macSolutionList' +macSolutionList+'size'+macSolutionList.size());
             return macSolutionList;
         }
    
}