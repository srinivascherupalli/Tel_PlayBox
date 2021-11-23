/********************************************************************
* DEVELOPER   : Vamshi/Hari
* TEAM        : Napier
* DESCRIPTION : This class has logic to call ARIA System 
* EDGE-117021, EDGE-116922, EDGE-124053, EDGE-116083, EDGE-124045, EDGE-124896,EDGE-135560
* Date        :20/02/2020
* Modified by : Amsterdam/12/07/2021 DIGI-725- updating SOQL query to not fetch chargetype as "creditcharge"
*******************************************************************/
public without sharing class OneFundRetrospectiveRedemption {

    public string errorKey{get;set;}
    public string errorMessage{get;set;} 
    /********************************************************************
    EDGE        : 116222
    Description : Method to getCaseDetails
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :20/02/2020
    *******************************************************************/
    @AuraEnabled
    public static Case getcaseDetatils( Id caseRecord){        
        
        case caseDetailsRecord = [SELECT Id,CaseNumber,AccountId,Billing_Account__c,status,Billing_Account__r.Billing_Account_Number__c,Attachment_Count__c,
                                 (SELECT Id,Redemption_Amount__c,Invoice_Line_Number__c,Invoice_Line_Item__c,Invoice_Line_Item__r.Offer_Name__c,
                                 Invoice_Line_Item__r.Charge_Including_GST__c,Invoice_Line_Item__r.Charge_Excluding_GST__c,Eligible_for_Redemption__c,
                                 Max_Credit_Amount__c,Invoice_Line_Item__r.Service_Type__c,Invoice_Line_Item__r.Charge_Type__c
                                 FROM Queried_Line_Items__r 
                                 WHERE Redemption_Amount__c != null)
                                 FROM Case WHERE ID =: caseRecord LIMIT 1 ];  
                                                          
      
                                                          
        Return caseDetailsRecord;        
    }
    
    /********************************************************************
    EDGE        : 116222
    Description : Method for Making Call to  the ARIA System
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    
    @AuraEnabled
    public static List<invoiceLineitem> callAria(string invnumber1, string customerAccountNumber){
       list<Invoice__c> Inv = [Select id,Aria_Invoice_Number__c,Name,Payments_and_Adjustments__c,(Select id,Invoice_Line_Number__c,Offer_Name__c,Service_Type__c,Charge_Including_GST__c,Charge_Type__c,Charge_Excluding_GST__c,Charge_Identifier__c,Start_Date__c,Is_Queryable__c,Excluding_Cost__c,Invoice_Transaction_ID__c,Name,Offer_Total_Excluding_GST_Cost__c,Offer_Total_Including_GST_Cost__c,Invoice_Def__c,Physical_Location_Name__c,Site_Excluding_GST_Cost__c,Site_Including_GST_Cost__c,Including_Cost__c,Sigma_Id__c,Is_Aggregated__c,Is_Taxable__c from Invoice_Line_Items__r  where Charge_Type__c != 'CreditCharge') from Invoice__c where Name =:invnumber1 limit 1];
        String ariaInvoiceNumber = null;
        double paymentsAndAdjustments =null;
        EligibleRedemAmountRequestDTO  ERAresp_DTO=null;
        List<invoiceLineitem> existingInvResponse=null;
        List<invoiceLineitem> currentInvResponse=null;
        id invid;
        HttpResponse response = null;
        List<EligibleRedemption> eligibleAmountList = null;
        list<Invoice_Line_Item__c> invoiceLineItemList = null;
        EligibleRedemptionAmountResponseDTO maxCreditAmounts = null;
          if(!Inv.isEmpty()){  
            invid=Inv[0].id;
            ariaInvoiceNumber = Inv[0].Aria_Invoice_Number__c;
            paymentsAndAdjustments =Inv[0].Payments_and_Adjustments__c;
            invoiceLineItemList =Inv[0].Invoice_Line_Items__r;
            if(invoiceLineItemList!=null){
                ERAresp_DTO= generatePayLoadforExistingInvoice(invoiceLineItemList, customerAccountNumber, ariaInvoiceNumber);
                maxCreditAmounts=OneFundCalloutHandler.calloutQLI1(ERAresp_DTO);
                if(maxCreditAmounts!=null){
                    eligibleAmountList=getEligibleRedemption(maxCreditAmounts);
                                }
                currentInvResponse = addEligibleRedemptionAmountforExistingIvoice(eligibleAmountList, invoiceLineItemList, ariaInvoiceNumber,customerAccountNumber,paymentsAndAdjustments,invnumber1);
                system.debug(' current response:::'+currentInvResponse);
                        }  
        }else{
            OneFundInvoiceRequestDTO requestDto = OneFundCalloutHandler.createPayload(customerAccountNumber,Long.valueOf(invnumber1));
            response =  OneFundCalloutHandler.calloutInvoiceByNumber(requestDto);
            system.debug('response:::'+response);
            OneFundInvoiceResponseDTO responseDto = OneFundInvoiceResponseDTO.parse(response.getBody());
            existingInvResponse= getInvoiceLineitems(responseDto);
            if(existingInvResponse[0].errorKey==null  || existingInvResponse[0].errorKey == ''){   
                ERAresp_DTO= generatePayLoad(existingInvResponse);
                            maxCreditAmounts=OneFundCalloutHandler.calloutQLI1(ERAresp_DTO);
                if(maxCreditAmounts!=null){
                    eligibleAmountList=getEligibleRedemption(maxCreditAmounts);
                                }
                String  handlerName = 'OneFundInvoiceByNumberHandler';
                currentInvResponse=addEligibleRedemptionAmount(eligibleAmountList, existingInvResponse);
                Logger2 logger = Logger2.getLogger(handlerName);
                logger.logMessages(response.getBody(), response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
            }else{
                            currentInvResponse=existingInvResponse;
                        }
                        }
            return currentInvResponse;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to Generate payload for existing invoice
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static EligibleRedemAmountRequestDTO generatePayLoadforExistingInvoice(list<Invoice_Line_Item__c> invList, String customerAccountNumber, String ariaInvoiceNumber){
        EligibleRedemAmountRequestDTO ERM_DTO = null;
        try{
            if(!invList.isEmpty() && invList.size() > 0 ){
                ERM_DTO = new EligibleRedemAmountRequestDTO();
                List<EligibleRedemAmountRequestDTO.chargeDetails> chargeDetailsList = new List<EligibleRedemAmountRequestDTO.chargeDetails>();
                ERM_DTO.customerAccountNumber = customerAccountNumber;
                ERM_DTO.ariaInvoiceNumber = long.valueOf(ariaInvoiceNumber);
                for(Invoice_Line_Item__c ILI : invList)
                {
                    EligibleRedemAmountRequestDTO.chargeDetails chargeDetails = new EligibleRedemAmountRequestDTO.chargeDetails();
                    //Integer  chargeidf=ILI.chargeIdentifier;
                    chargeDetails.chargeIdentifier =(ILI.Charge_Identifier__c).intValue();
                    chargeDetails.chargeType = ILI.Charge_Type__c;
                    Decimal invoiceNum = ILI.Invoice_Line_Number__c;
                    chargeDetails.invoiceLineNumber = invoiceNum.longValue();
                    chargeDetailsList.add(chargeDetails);
                }
                if(!chargeDetailsList.isEmpty() && chargeDetailsList.size()>0){
                    ERM_DTO.chargeDetails =  chargeDetailsList;
                }
            }
            return ERM_DTO;
        }
        catch(Exception e){
            System.debug('generatePayLoad :: Payload generating failed :: '+e);
            return null;
        }
    }
    
    /********************************************************************
    EDGE        : 116222
    Description : Method to getEligibleRedemption for invoice
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static List<EligibleRedemption> getEligibleRedemption(EligibleRedemptionAmountResponseDTO ERM) {
        List<EligibleRedemption> eligibleAmountList = new List<EligibleRedemption>();
        if(ERM!=null){
            if(ERM.creditAdjustmentEligibility!=null){
                for(EligibleRedemptionAmountResponseDTO.creditAdjustmentEligibility cae: ERM.creditAdjustmentEligibility){
                    eligibleAmountList.add(new EligibleRedemption(cae.chargeIdentifier,cae.invoiceLineNumber,cae.maxCreditAmount));
                }
            }   
        }
        return eligibleAmountList;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to add addEligibleRedemptionAmount for exiting invoice
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static List<invoiceLineitem> addEligibleRedemptionAmountforExistingIvoice(List<EligibleRedemption> ERMList, list<Invoice_Line_Item__c> InvList, String ariaInvoiceNumber,String accountNumber,double paymentsAndAdjustments,string invnumber1 ){
        Integer id =0;
        List<invoiceLineitem>  einvlist = new List<invoiceLineitem>();
        if(ERMList!= null && InvList!= null){
            Double EligibleRedemptionAmount = null;
            for(Invoice_Line_Item__c lineItemRecord :InvList ){
                if(lineItemRecord.Charge_Type__c =='OnceOffCharge') 
                {  
                    for(integer y=0; y<ERMList.size(); y++){
                        if(lineItemRecord.Invoice_Line_Number__c == ERMList[y].invoiceLineNumber && ERMList[y].maxCreditAmount>0){
                            EligibleRedemptionAmount=ERMList[y].maxCreditAmount;
                        }
                    }
                    id=id+1;
                    
                    einvlist.add(new invoiceLineitem(Integer.valueOf(lineItemRecord.Invoice_Line_Number__c),lineItemRecord.Offer_Name__c,lineItemRecord.Service_Type__c,
                                                     double.valueOf(lineItemRecord.Charge_Including_GST__c),lineItemRecord.Charge_Type__c,double.valueOf(lineItemRecord.Charge_Excluding_GST__c),'','N',ariaInvoiceNumber,accountNumber,
                                                     Integer.valueOf(lineItemRecord.Charge_Identifier__c), String.Valueof(lineItemRecord.Start_Date__c),lineItemRecord.Is_Queryable__c,null,paymentsAndAdjustments,double.valueOf(lineItemRecord.Excluding_Cost__c),
                                                     null,Integer.valueof(lineItemRecord.Invoice_Transaction_ID__c),invnumber1,double.valueOf(lineItemRecord.Offer_Total_Excluding_GST_Cost__c),double.valueOf(lineItemRecord.Offer_Total_Including_GST_Cost__c),
                                                     Integer.valueof(lineItemRecord.Invoice_Def__c),lineItemRecord.Physical_Location_Name__c,lineItemRecord.id,0,
                                                     double.valueOf(lineItemRecord.Including_Cost__c),lineItemRecord.Sigma_Id__c,lineItemRecord.Is_Aggregated__c,lineItemRecord.Is_Taxable__c,id,EligibleRedemptionAmount));
                   system.debug('einvlist====>'+einvlist);
                }
            }
        }
        return einvlist;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to add EligibleRedemptionAmount to invoice 
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static List<invoiceLineitem> addEligibleRedemptionAmount(List<EligibleRedemption> ERMList, List<invoiceLineitem> InvList ){
        if(ERMList!= null && InvList!=null){
            for(integer x=0; x<InvList.size(); x++){
                for(integer y=0; y<ERMList.size(); y++){
                    if(InvList[x].invoiceLineNumber ==ERMList[y].invoiceLineNumber && ERMList[y].maxCreditAmount>0){
                        if(InvList[x].isTaxable == true){
                            InvList[x].EligibleRedemptionAmount=ERMList[y].maxCreditAmount;
                        }else{
                            InvList[x].EligibleRedemptionAmount=ERMList[y].maxCreditAmount * 1;
                        }
                    }
                }
            }
        }
        return InvList;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Class to get Eligible Redemptions
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    public class EligibleRedemption{
        @AuraEnabled
        public Integer chargeIdentifier {get;set;}
        @AuraEnabled
        public Integer invoiceLineNumber {get;set;}
        @AuraEnabled
        public double maxCreditAmount {get;set;} 
        
        public EligibleRedemption(Integer chargeIdentifier,Integer invoiceLineNumber,double maxCreditAmount){
            this.chargeIdentifier          = chargeIdentifier;
            this.invoiceLineNumber         = invoiceLineNumber;
            this.maxCreditAmount           = maxCreditAmount;  
        }
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to getEligibleRedemption for invoice
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static EligibleRedemAmountRequestDTO generatePayLoad(List<invoiceLineitem> invList){
        EligibleRedemAmountRequestDTO ERM_DTO = null;
        try{
            if(!invList.isEmpty() && invList.size() > 0 ){
                ERM_DTO = new EligibleRedemAmountRequestDTO();
                List<EligibleRedemAmountRequestDTO.chargeDetails> chargeDetailsList = new List<EligibleRedemAmountRequestDTO.chargeDetails>();
                ERM_DTO.customerAccountNumber = invList[0].accountNumber;
                ERM_DTO.ariaInvoiceNumber = Long.valueOf(invList[0].ariaInvoiceNumber);
                for(invoiceLineitem ILI : invList)
                {
                    EligibleRedemAmountRequestDTO.chargeDetails chargeDetails = new EligibleRedemAmountRequestDTO.chargeDetails();
                    chargeDetails.chargeIdentifier =ILI.chargeIdentifier;
                    chargeDetails.chargeType = ILI.chargeType;
                    Decimal invoiceNum = ILI.invoiceLineNumber;
                    chargeDetails.invoiceLineNumber = invoiceNum.longValue();
                    chargeDetailsList.add(chargeDetails);
                }
                if(!chargeDetailsList.isEmpty() && chargeDetailsList.size()>0){
                    ERM_DTO.chargeDetails =  chargeDetailsList;
                }
            }
            return ERM_DTO;
        }
        catch(Exception e){
            System.debug('generatePayLoad :: Payload generating failed :: '+e);
            return null;
        }
    }
    /********************************************************************
    EDGE        : 116222
    Description : Class to get EligibleRedemptionAmountResponse
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    public class EligibleRedemptionAmountResponse{
        @AuraEnabled
        public Integer chargeIdentifier {get;set;}
        @AuraEnabled
        public Integer invoiceLineNumber {get;set;}
        @AuraEnabled
        public double maxCreditAmount {get;set;}
        @AuraEnabled
        public String creditAdjustmentEligibility {get;set;}
        public EligibleRedemptionAmountResponse(Integer chargeIdentifier,Integer invoiceLineNumber,double maxCreditAmount){
            this.chargeIdentifier               = chargeIdentifier;
            this.invoiceLineNumber              = invoiceLineNumber;
            this.maxCreditAmount              = maxCreditAmount;
        }
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to get list of invoiceLineitem by using InvoiceResponseDTO class to deserialize the response
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static List<invoiceLineitem> getInvoiceLineitems(OneFundInvoiceResponseDTO jsc) {
        Integer id = 0;
        List<invoiceLineitem> invList = new List<invoiceLineitem>();
        List<Invoice__c> invoiceListToBeInserted = new List<Invoice__c>();
        if(jsc!=null){
            if(jsc.serviceSummary!= null){
                for(OneFundInvoiceResponseDTO.ListOfOffers lof: jsc.serviceSummary.ListOfOffers){
                    if(lof != null && lof.ListOfProducts != null && lof.invoiceDef==1){
                        for(OneFundInvoiceResponseDTO.ListOfProducts lop :lof.ListOfProducts){
                            if(lop.ListOfChargesAndCredits.OnceOffChargesAndCredits != null){
                                for(OneFundInvoiceResponseDTO.OnceOffChargesAndCredits occ :lop.ListOfChargesAndCredits.OnceOffChargesAndCredits){
                                    if((occ.servicetype != null) &&(occ.InvoiceLineAttributes != null)){
                                        system.debug('Inside OCC Loop=====>'+occ.InvoiceLineAttributes +occ.servicetype);
                                        for(OneFundInvoiceResponseDTO.InvoiceLineAttributes ila :occ.InvoiceLineAttributes){
                                            id = id +1;
                                            invList.add(new invoiceLineitem(ila.invoiceLineNumber,lof.offername,occ.servicetype,ila.chargeIncludingGST,occ.chargeType,ila.chargeExcludingGST,'','N',
                                                                            jsc.invoiceDetails.ariaInvoiceNumber,jsc.invoiceDetails.accountNumber,occ.chargeIdentifier, jsc.invoiceDetails.invoiceIssueDate,occ.isQueryable,
                                                                            jsc.paymentSummary.totalDue,jsc.paymentSummary.paymentsAndAdjustments,occ.excludingGstCost,jsc.paymentSummary.newCharges,ila.invoiceTransactionId,
                                                                            jsc.invoiceDetails.invoiceNumber,lof.offerTotalExcludingGstCost,lof.offerTotalIncludingGstCost,lof.invoiceDef,lop.physicalLocationName,null,
                                                                            0,occ.includingGstCost,occ.sigmaSpecId,occ.isAggregated,occ.isTaxable,id,null));                               
                                        }
                                    }
                                } 
                            }
                        } 
                    }
            //EDGE-165647: Enhance Onefund Credit/Debit charges to be applicable for all the products available in B2B Digi stack
                    else if(lof != null && (lof.invoiceDef==2 || lof.invoiceDef==3)){
                        if(lof.ListOfChargesAndCredits.OnceOffChargesAndCredits != null){
                                for(OneFundInvoiceResponseDTO.OnceOffChargesAndCredits occ :lof.ListOfChargesAndCredits.OnceOffChargesAndCredits){
                                    if((occ.servicetype != null) &&(occ.InvoiceLineAttributes != null)){
                                        system.debug('Inside OCC Loop=====>'+occ.InvoiceLineAttributes +occ.servicetype);
                                        for(OneFundInvoiceResponseDTO.InvoiceLineAttributes ila :occ.InvoiceLineAttributes){
                                            id = id +1;
                                            invList.add(new invoiceLineitem(ila.invoiceLineNumber,lof.offername,occ.servicetype,ila.chargeIncludingGST,occ.chargeType,ila.chargeExcludingGST,'','N',
                                                                            jsc.invoiceDetails.ariaInvoiceNumber,jsc.invoiceDetails.accountNumber,occ.chargeIdentifier, jsc.invoiceDetails.invoiceIssueDate,occ.isQueryable,
                                                                            jsc.paymentSummary.totalDue,jsc.paymentSummary.paymentsAndAdjustments,occ.excludingGstCost,jsc.paymentSummary.newCharges,ila.invoiceTransactionId,
                                                                            jsc.invoiceDetails.invoiceNumber,lof.offerTotalExcludingGstCost,lof.offerTotalIncludingGstCost,lof.invoiceDef,null,null,
                                                                            0,occ.includingGstCost,occ.sigmaSpecId,occ.isAggregated,occ.isTaxable,id,null));                               
                                        }
                                    }
                                } 
                            }
                        
                    }
                } 
            }   
            else {
                if(jsc.errorKey!=null){
                    invList.add(new invoiceLineitem(null,'','',null,'',null,jsc.errorKey,'','','',null,'',false,null,null,null,null,null,'',null,null,null,'',null,null,null,'',false,false,id,null));
                }
            } 
        }
        return invList;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to update Queried Line Items on click of submit button after providing the redemption amount
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        : 05/03/2019
    *******************************************************************/    
    @AuraEnabled
    public static void updateQueriedLineItems(List<Queried_Line_Item__c> redemptions){
        //List<QueriedLineItem> updateQurLineItemList = (List<QueriedLineItem>) JSON.deserialize(redemptions, List<QueriedLineItem>.class);
        System.debug('updateQurLineItemList--> : ' +redemptions);
        Update redemptions;
    
    }
    /********************************************************************
    EDGE        : 116222,EDGE-135560
    Description : Method to insert Queried Line Items on click of submit button after providing the redemption amount
    Author      : Hari/Vamshi
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static void insertQueriedLineItems(String invoices, String redemptions, Id caseid){
        list<Invoice_Line_Item__c> invids =null;
        List<Queried_Line_Item__c> QueriedItemList = new list<Queried_Line_Item__c>();
        List<invoiceLineitem> fieldList1 = (List<invoiceLineitem>) JSON.deserialize(invoices, List<invoiceLineitem>.class);
        if(fieldList1[0].invoicelineitemid == null){
            Invoice__c inv=[Select id,(Select id,Invoice_Line_Number__c,Line_Item_Identifier__c from Invoice_Line_Items__r) from Invoice__c where Aria_Invoice_Number__c= :fieldList1[0].ariaInvoiceNumber];
            invids=inv.Invoice_Line_Items__r;   
        }
        Case caseRec=getcaseDetatils(caseid);
        List<QueriedLineItem> fieldList2 = (List<QueriedLineItem>) JSON.deserialize(redemptions, List<QueriedLineItem>.class);
        List<Queried_Line_Item__c> QLTlist=[Select id,Invoice_Line_Number__c  from Queried_Line_Item__c where Case__c =: caseid];
        Map<Decimal,id> MapEQLT =new Map<Decimal,id>();
        if(QLTlist!=null){
            for(Queried_Line_Item__c SQLI :QLTlist ){
                MapEQLT.put(SQLI.Invoice_Line_Number__c,SQLI.id );
            }
        }
            if(fieldList1!= null && fieldList2!=null){
            Queried_Line_Item__c qli;
            for(integer x=0; x<fieldList1.size(); x++){
                for(integer y=0; y<fieldList2.size(); y++){
                    if(fieldList1[x].id ==fieldList2[y].id && fieldList2[y].nullredemptionamt>0){
                        if(MapEQLT.containsKey(fieldList1[x].invoiceLineNumber)){
                            qli =new Queried_Line_Item__c(id=MapEQLT.get(fieldList1[x].invoiceLineNumber));
                        }else{
                            qli =new Queried_Line_Item__c();
                            qli.Case__c=caseid;
                            qli.Invoice_Line_Number__c=fieldList1[x].invoiceLineNumber;
                            
                            if(fieldList1[x].invoicelineitemid!=null){
                                qli.Invoice_Line_Item__c=fieldList1[x].invoicelineitemid;
                                qli.Line_Item_Identifier__c=fieldList1[x].chargeType + fieldList1[x].chargeIdentifier + fieldList1[x].invoiceTransactionId + caseRec.CaseNumber;
                            }else if(invids!=null){
                                for(Invoice_Line_Item__c sid:invids){
                                    if(fieldList1[x].invoiceLineNumber == sid.Invoice_Line_Number__c)
                                        qli.Invoice_Line_Item__c=sid.id;
                                      //qli.Line_Item_Identifier__c=sid.Line_Item_Identifier__c + caseRec.CaseNumber;     
                                }
                            }
                        }
                        qli.Redemption_Amount__c=fieldList2[y].nullredemptionamt;
                        qli.Reason_Code__c='Onefunds Redemption Credit Charge';
                        qli.Max_Credit_Amount__c=fieldList1[x].EligibleRedemptionAmount;
                        
                        QueriedItemList.add(qli);
                    }
                }
            }
            upsert QueriedItemList;
        }
    }
    /********************************************************************
    EDGE        :116222
    Description : Method to insert Invoice and Invoice Line Items and case status to In Progress on click of initiate redemption button.
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static void insertInvoices(string invoices, case caseRecord){ 
        caseRecord.status = 'In Progress'; 
        update caseRecord;
        String duplicateerror ;
        List<string> dateStringSplit;
        String str=null;
        String year=null;
        Map <String, Integer> monthNames = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
            List<Invoice_Line_Item__c> invLineItemList = new list<Invoice_Line_Item__c>();
        List<invoiceLineitem> fieldList = (List<invoiceLineitem>) JSON.deserialize(invoices, List<invoiceLineitem>.class);
        Integer invcount =  [Select count() from Invoice__c where Name = :fieldList[0].invoiceNumber ];
        if(invcount == 0)
        {
            if(fieldList == null){
                throw new AuraHandledException('Impossible to retrieve the field list. Contact your system administrator');
            }try{
                if(fieldList!= null){
                    Invoice__c inv = new Invoice__c();
                    inv.Aria_Invoice_Number__c = fieldList[0].ariaInvoiceNumber;
                    inv.Payments_and_Adjustments__c = fieldList[0].paymentsAndAdjustments;
                    inv.New_Charge__c = fieldList[0].newCharge;
                    inv.Name = fieldList[0].invoiceNumber;
                    //inv.Billing_Account__c = cc.Billing_Account__c;
                    inv.Billing_Account__c = caseRecord.Billing_Account__c;
                    insert inv;
                    for(integer i=0; i<fieldList.size(); i++){
                        system.debug('chargeIdentifier'+fieldList[i].chargeIdentifier);
                        List <String> stringParts = fieldList[i].invoiceIssueDate.split(' ');
                        Invoice_Line_Item__c invLineItemRec = new Invoice_Line_Item__c();
                        invLineItemRec.Invoice_Line_Number__c = fieldList[i].invoiceLineNumber;
                        invLineItemRec.Charge_Including_GST__c = fieldList[i].chargeIncludingGST;
                        invLineItemRec.Charge_Excluding_GST__c = fieldList[i].chargeExcludingGST;
                        invLineItemRec.Invoice_Transaction_ID__c = fieldList[i].invoiceTransactionId;
                        invLineItemRec.Invoice__c = inv.Id;
                        invLineItemRec.Offer_Name__c = fieldList[i].offerName;
                        invLineItemRec.Invoice_Def__c = fieldList[i].invoiceDef;
                        invLineItemRec.Offer_Total_Excluding_GST_Cost__c = fieldList[i].offerTotalExcludingGstCost;
                        invLineItemRec.Offer_Total_Including_GST_Cost__c = fieldList[i].offerTotalIncludingGstCost;
                        invLineItemRec.Physical_Location_Name__c = fieldList[i].physicalLocationName;
                        invLineItemRec.Site_Excluding_GST_Cost__c = fieldList[i].siteExcludingGstCost;
                        invLineItemRec.Service_Type__c = fieldList[i].serviceType;
                        invLineItemRec.Charge_Type__c = fieldList[i].chargeType;
                        invLineItemRec.Charge_Identifier__c = fieldList[i].chargeIdentifier;
                        invLineItemRec.Sigma_Id__c = fieldList[i].sigmaSpecId;
                        invLineItemRec.Excluding_Cost__c = fieldList[i].excludingGstCost;
                        invLineItemRec.Including_Cost__c = fieldList[i].includingGstCost;
                        invLineItemRec.Is_Aggregated__c = fieldList[i].isAggregated;
                        invLineItemRec.Is_Taxable__c = fieldList[i].isTaxable;
                        invLineItemRec.Is_Queryable__c = fieldList[i].isQueryable;
                        invLineItemRec.Line_Item_Identifier__c = fieldList[i].chargeType + fieldList[i].chargeIdentifier + fieldList[i].invoiceTransactionId;
                        if(fieldList[i].invoiceIssueDate!=null){
                            dateStringSplit =  fieldList[i].invoiceIssueDate.split(' ');
                            str='20'+dateStringSplit[2]+  '-'+monthNames.get(dateStringSplit[1])+'-'+  dateStringSplit[0];
                            invLineItemRec.Start_Date__c = Date.valueOf(str);
                            year = '20'+dateStringSplit[2];
                            dateStringSplit.clear();
                        }
                        if(invLineItemRec.Charge_Type__c != 'RecurringCharge'){
                            invLineItemList.add(invLineItemRec);
                        }
                    }
                    system.debug('invLineItemList:' +invLineItemList);
                    insert invLineItemList;
                } 
            }catch(exception e){
                duplicateerror = e.getMessage();
                system.debug('Line Number:'+e.getLineNumber()+':: message :;'+duplicateerror);
            }
        }
        //return invLitemist;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Method to fetch AvailableOneFundBalance from flow
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static Decimal GetAvailableOneFundBalance(Id AccountId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('recordId', AccountId);
        Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen ShowOneFundBalance = new Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen(params);
        ShowOneFundBalance.start();
        Decimal  AvailableOneFundBalance = (Decimal) ShowOneFundBalance.getVariableValue('TotalOneFundAmount');
        System.debug('Flow returned ' + AvailableOneFundBalance);        
        return AvailableOneFundBalance;
    }
    /********************************************************************
    EDGE        : 116222
    Description : Class to insert Invoice and Invoice Line Items on click of initiate redemption button.
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    public class invoiceLineitem{
        @AuraEnabled
        public Integer invoiceLineNumber {get;set;}
        @AuraEnabled
        public String offername {get;set;}
        @AuraEnabled
        public String servicetype {get;set;}
        @AuraEnabled
        public Integer quantity {get;set;}
        @AuraEnabled
        public double chargeIncludingGST {get;set;}
        @AuraEnabled
        public String chargeType {get;set;} 
        @AuraEnabled
        public double chargeExcludingGST {get;set;} 
        @AuraEnabled
        public String errorKey {get;set;} 
        @AuraEnabled
        public String Flag {get;set;} 
        @AuraEnabled
        public String ariaInvoiceNumber {get;set;} 
        @AuraEnabled
        public String accountNumber {get;set;} 
        @AuraEnabled
        public String invoiceIssueDate {get;set;} 
        @AuraEnabled
        public Double totalDue {get;set;} 
        @AuraEnabled
        public double paymentsAndAdjustments {get;set;} 
        @AuraEnabled
        public String dueDate {get;set;} 
        @AuraEnabled
        public double newCharge {get;set;} 
        @AuraEnabled
        public Integer invoiceTransactionId {get;set;}
        @AuraEnabled
        public string invoiceNumber {get;set;}
        @AuraEnabled
        public double offerTotalExcludingGstCost {get;set;}
        @AuraEnabled
        public double offerTotalIncludingGstCost {get;set;}
        @AuraEnabled
        public double invoiceDef {get;set;}
        @AuraEnabled
        public string physicalLocationName {get;set;}
        @AuraEnabled
        public double siteExcludingGstCost {get;set;}
        @AuraEnabled
        public String  invoicelineitemid {get;set;}
        @AuraEnabled
        public double nullredemptionamt {get;set;} 
        @AuraEnabled
        public double excludingGstCost {get;set;}
        @AuraEnabled
        public double includingGstCost {get;set;}
        @AuraEnabled
        public string sigmaSpecId {get;set;}
        @AuraEnabled
        public boolean isAggregated {get;set;}
        @AuraEnabled
        public boolean isTaxable {get;set;}
        @AuraEnabled
        public boolean isQueryable {get;set;}
        @AuraEnabled
        public Integer chargeIdentifier {get;set;}
        @AuraEnabled
        public Integer id {get;set;} 
        @AuraEnabled
        public double EligibleRedemptionAmount {get;set;}   
          public invoiceLineitem(Integer invoiceLineNumber,String offername,String servicetype,double chargeIncludingGST,String chargeType, 
                               double chargeExcludingGST, string errorKey,String Flag,string ariaInvoiceNumber,string accountNumber,Integer chargeIdentifier,String invoiceIssueDate,boolean isQueryable,
                               Double totalDue,double paymentsAndAdjustments,double excludingGstCost,double newCharge,Integer invoiceTransactionId,string invoiceNumber,double offerTotalExcludingGstCost,double offerTotalIncludingGstCost,
                               Integer invoiceDef,String physicalLocationName,String invoicelineitemid, double nullredemptionamt,double includingGstCost,string sigmaSpecId,boolean isAggregated,boolean isTaxable,
                               Integer id,double EligibleRedemptionAmount ){
                                   this.invoiceLineNumber          = invoiceLineNumber;
                                   this.offername                = offername;
                                   this.servicetype              = servicetype;
                                   this.chargeIncludingGST       = chargeIncludingGST;
                                   this.chargeType               = chargeType;  
                                   this.chargeExcludingGST       = chargeExcludingGST;
                                   this.errorKey                 = errorKey;
                                   this.Flag                     = Flag;
                                   this.ariaInvoiceNumber        = ariaInvoiceNumber;
                                   this.accountNumber            = accountNumber;
                                   this.invoiceIssueDate         = invoiceIssueDate;
                                   this.totalDue                 = totalDue;
                                   this.paymentsAndAdjustments   = paymentsAndAdjustments;
                                   this.dueDate                  = dueDate;
                                   this.newCharge                = newCharge;
                                   this.invoiceTransactionId     = invoiceTransactionId;
                                   this.invoiceNumber              = invoiceNumber;
                                   this.offerTotalExcludingGstCost = offerTotalExcludingGstCost;
                                   this.offerTotalIncludingGstCost = offerTotalIncludingGstCost;
                                   this.invoiceDef                 = invoiceDef;
                                   this.physicalLocationName       = physicalLocationName;
                                   this.invoicelineitemid       = invoicelineitemid;
                                   this.excludingGstCost           = excludingGstCost;
                                   this.includingGstCost           = includingGstCost;
                                   this.sigmaSpecId                = sigmaSpecId;
                                   this.isAggregated               = isAggregated;
                                   this.isTaxable                  = isTaxable;
                                   this.isQueryable                = isQueryable;
                                   this.chargeIdentifier           = chargeIdentifier;
                                   this.id                        = id;
                                   this.EligibleRedemptionAmount    =EligibleRedemptionAmount;
                                   this.nullredemptionamt=nullredemptionamt;
                               }        
    }
    /********************************************************************
    EDGE        : EDGE-116222
    Controller  : EligibleRedemAmountRequestDTO
    Description : Class to insert Queried Line Items on click of submit button after providing the redemption amount
    Author      : Vamshi/Hari
    TEAM        : Romil
    Date        :22/12/2019
    *******************************************************************/
    public class QueriedLineItem{
        @AuraEnabled
        public double nullredemptionamt {get;set;}
        @AuraEnabled
        public Integer id {get;set;}
        public QueriedLineItem(double nullredemptionamt,Integer id){
            this.nullredemptionamt  = nullredemptionamt;
            this.id                = id;
        }
    }
    /********************************************************************
    EDGE        : EDGE-116222
    Description : Class to bind all the data at one place Added by Romil
    Author      : Romil
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    
    public class QueriedLineItemList{
        @AuraEnabled
        public double invoiceLineNumber {get;set;}
        @AuraEnabled
        public String offername {get;set;}
        @AuraEnabled
        public String servicetype {get;set;}
        @AuraEnabled
        public Integer quantity {get;set;}
        @AuraEnabled
        public double chargeIncludingGST {get;set;}
        @AuraEnabled
        public String chargeType {get;set;}
        @AuraEnabled
        public double chargeExcludingGST {get;set;}
        @AuraEnabled
        // Flag not there
        public String Flag {get;set;}
        @AuraEnabled
        public double nullredemptionamt {get;set;}
        @AuraEnabled
        public String id {get;set;}  
        @AuraEnabled
        public double EligibleRedemptionAmount {get;set;}      
    }
     /********************************************************************
    EDGE        : EDGE-116222
    Description : Method to update  case status
    Author      : Vamshi/Hari
    TEAM        : Napier
    Date        :22/12/2019
    *******************************************************************/
    @AuraEnabled
    public static void updatecasestatus(case caserec){
        caserec.status = 'Initiate Redemption'; 
        update caserec;
    }
    /********************************************************************
    EDGE        : EDGE-116231
    Description : Method to fetch QueriedLineItems Added by Romil
    Author      : Romil/Hari
    TEAM        : Napier
    Date        :22/01/2020
    *******************************************************************/
    @AuraEnabled
    public static List<QueriedLineItemList> getQueriedLineItems(string invoices, string redemptions){
        List<QueriedLineItemList> QueriedItemList = new list<QueriedLineItemList>();
        List<invoiceLineitem> fieldList1 = (List<invoiceLineitem>) JSON.deserialize(invoices, List<invoiceLineitem>.class);
        List<QueriedLineItem> fieldList2 = (List<QueriedLineItem>) JSON.deserialize(redemptions, List<QueriedLineItem>.class);
        for(integer y=0; y<fieldList2.size(); y++){ 
        }
        if(fieldList1.size()!= null && fieldList2.size()!=null ){
            integer i=1;
            for(integer x=0; x<fieldList1.size(); x++){  
                QueriedLineItemList qli        = new QueriedLineItemList();
                qli.invoiceLineNumber          = fieldList1[x].invoiceLineNumber;
                qli.offername                  = fieldList1[x].offername;
                qli.servicetype                = fieldList1[x].servicetype;
                qli.chargeIncludingGST         = fieldList1[x].chargeIncludingGST;
                qli.chargeType                 = fieldList1[x].chargeType;  
                qli.chargeExcludingGST         = fieldList1[x].chargeExcludingGST;
                qli.Flag                       = fieldList1[x].Flag;                   
                qli.id                         = string.valueof(fieldList1[x].id);
                qli.EligibleRedemptionAmount   = fieldList1[x].EligibleRedemptionAmount;
                qli.nullredemptionamt=0.00;
                for(integer y=0; y<fieldList2.size(); y++){
                    if(fieldList1[x].id == fieldList2[y].id && fieldList2[y].nullredemptionamt > 0 ){
                        qli.nullredemptionamt = fieldList2[y].nullredemptionamt;
                    }
                }
                QueriedItemList.add(qli);  
            }            
        }
        return QueriedItemList;
    }
    
    
    /********************************************************************
    EDGE        : EDGE-135560
    Description : Method to display saved QueriedLineItems
    Author      : Vamshi
    TEAM        : Napier
    Date        : 26/02/2020
    *******************************************************************/
    @AuraEnabled
    public static List<QueriedLineItemList> displaySavedQueriedLineItems(Id caseRecord){
        system.debug('caseRecord===>'+caseRecord);
        List<QueriedLineItemList> SavedQueriedLineItems = new list<QueriedLineItemList>();
        
        case caseDetailsRecord = getcaseDetatils(caseRecord);
                                 
        system.debug('caseDetailsRecord===>'+caseDetailsRecord);
        
        for(Queried_Line_Item__c qlisavedRecord :caseDetailsRecord.Queried_Line_Items__r){
            QueriedLineItemList qli        = new QueriedLineItemList();
            qli.invoiceLineNumber          = qlisavedRecord.Invoice_Line_Number__c;
            qli.offername                  = qlisavedRecord.Invoice_Line_Item__r.Offer_Name__c;
            qli.servicetype                = qlisavedRecord.Invoice_Line_Item__r.Service_Type__c;
            qli.chargeIncludingGST         = qlisavedRecord.Invoice_Line_Item__r.Charge_Including_GST__c;
            qli.chargeType                 = qlisavedRecord.Invoice_Line_Item__r.Charge_Type__c; 
            qli.chargeExcludingGST         = qlisavedRecord.Invoice_Line_Item__r.Charge_Excluding_GST__c;
            qli.Flag                       = qlisavedRecord.Eligible_for_Redemption__c;                   
            qli.EligibleRedemptionAmount   = qlisavedRecord.Max_Credit_Amount__c;
            qli.nullredemptionamt          = qlisavedRecord.Redemption_Amount__c;
            qli.id                 = qlisavedRecord.Id;
            
            SavedQueriedLineItems.add(qli);        
        }
        
        return SavedQueriedLineItems;
        
    }
        }