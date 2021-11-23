/************************************************************ 
* @version      - 0.1
* @createdBy    - Jawahar
* @team         - OSAKA
* @jirastoryRef - EDGE-138355
*************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
 1                  Aditya Pareek        EDGE-207870         18/05/2021
 2                  Aman Soni            EDGE-207867         18/05/2021
 3.                 Shubhi               EDGE-212404         13-05-2021 
 4.                 Shubhi               EDGE-216407         02-06-2021                
**************************************************************************/ 

public class CreateInvoice implements Queueable, Database.AllowsCallouts {

    string caseId;
    String invoiceSerialized;
    String strUsageCharge;
    string transactionid;
    string contactEmail;
    string InvoiceNumber;
    
    public CreateInvoice (String invoiceSerialized, String strUsageCharge, string caseId,string transactionid,string contactEmail){
        this.invoiceSerialized= invoiceSerialized;
        this.strUsageCharge= strUsageCharge;
        this.transactionid= transactionid;
        this.contactEmail= contactEmail;
        this.caseId=caseId;
    }

    public void execute(QueueableContext context){       
        //Start of EDGE-145150:FDR:Made and to or for StrUsageCharge which contains one summary charge & transaction ID which has the ID of the drilldown record
        Boolean invoiceCheck = (invoiceSerialized!='' && caseId!='' && (strUsageCharge!=''|| transactionid!=''));
        //End of EDGE-145150
        system.debug('transactionid'+transactionid+'invoiceCheck'+invoiceCheck);
        if(invoiceCheck)
        CreateInvoiceRecord(invoiceSerialized,strUsageCharge,caseId,transactionid,contactEmail);
        //Colombo team: Shubhi Edge-212404 start---------
        Map<string,EnvironmentVariable__c> featureToggleMap=EnvironmentVariable__c.getAll(); //added to handle dormancy for 1663
        if(featureToggleMap!=null && featureToggleMap.containsKey('enableBillingEnquiry1663') && featureToggleMap.get('enableBillingEnquiry1663').value__c=='true'){
            if(!Test.isRunningTest())
            ID jobID = System.enqueueJob(new GetMaxCreditAmountValue(caseId,InvoiceNumber)); ////edge-212404          
        }else{
            if(!Test.isRunningTest())
            ID jobID = System.enqueueJob(new GetMaxCreditAmountValue(caseId));  // existing call
        }
        //Colombo team: Shubhi Edge-212404 end---------
    }   
     
    public void CreateInvoiceRecord(String invoiceSerialized, String strUsageCharge, String caseId,string transactionid,string contactEmail){
        Invoice__c invoice = new Invoice__c();
        InvoiceResponseDTO invLineItemDTO=(InvoiceResponseDTO) JSON.deserialize(invoiceSerialized,InvoiceResponseDTO.class);
        
        List <Invoice_Line_Item__c > lineItemList = new List <Invoice_Line_Item__c >();
        List <Queried_Line_Item__c> queryList = new List <Queried_Line_Item__c> ();
        List<integer> inputTransactionList = new List<integer>();
        List<string> inputTransactionstring = new List<string>();
        Queried_Line_Item__c queryLineobj = new Queried_Line_Item__c();
        Boolean skipCallout=true;
        //Code Refactoring
        List<Id> caseCreated = new List<Id> ();
        caseCreated.add(caseId);
        //Create Invoice record
            
        invoice = InvoiceCalloutHandler.saveInvoice(invLineItemDTO,skipCallout);
        InvoiceNumber=invoice.Name; //edge-212404
        //Create ILI records
        InvoiceCalloutHandler.saveResponse(invLineItemDTO, invoice);
        List<Integer> chargeIntList = new List<Integer>();
        //Create QLI records
        List<string> chargeUsageList;
        strUsageCharge=strUsageCharge.replace('(','');
        strUsageCharge=strUsageCharge.replace(')','');
        strUsageCharge =strUsageCharge.replaceAll('[\\s+]', '');
        system.debug('strUsageCharge'+strUsageCharge);
        chargeUsageList = strUsageCharge.split(',');
        //EDGE-145150 - added null check if strUsageCharge is empty after removing braces
        if(!string.isEmpty(strUsageCharge) && strUsageCharge.length()> 0){
            for(String usage : chargeUsageList){
                chargeIntList.add(Integer.valueOf(usage));
            }
        }
        system.debug('chargeIntList---->'+chargeIntList);
        //Inorder to cater the fix when there is no ussage drilldown record selected. - Zeeshan
        if(transactionid != '[]'){
            //Start of EDGE-133408  Component - Remove extra braces
            transactionid=transactionid.replace('[','');
            transactionid=transactionid.replace(']','');
            transactionid =transactionid.replaceAll('[\\s+]', '');
            inputTransactionstring = transactionid.split(',');
            //End of EDGE-133408 component
            for(String usage : inputTransactionstring){
                inputTransactionList.add(Integer.valueOf(usage.trim()));
            }
        }
        
        // EDGE-207870 Start-->
        Case caseUpdate =new Case();
        caseUpdate=String.isNotBlank(caseId)?[select id,CaseNumber from case where id =: caseId]:new Case();
        // EDGE-207870 End-->

        //Added for EDGE-207867 by Aman Soni || Start
        List<String> IliQliLst = new  List<String>();
        if(String.isNotBlank(caseId)){
            IliQliLst = getExistingQlis(caseId);
        }
        //Added for EDGE-207867 by Aman Soni || End

        //Added filter((id NOT IN :IliQliLst)) to prevent duplicate QLI for EDGE-207867 by Aman Soni
        lineItemList = [select id,name,Service_Type__c,Charge_Type__c, Charge_Id__c, Line_Item_Identifier__c,Invoice_Line_Number__c, Charge_Identifier__c, Charge_excluding_GST__c, Invoice__c,Invoice_Transaction_ID__c from Invoice_Line_Item__c where  ((Charge_Identifier__c IN: chargeIntList  and Charge_Identifier__c !=null) OR (Invoice_Transaction_ID__c IN: inputTransactionList)) AND (id NOT IN :IliQliLst)];

        if(lineItemList != null && lineItemList.size() > 0){          
            for(Invoice_Line_Item__c invoiceData: lineItemList){
                queryLineobj = new Queried_Line_Item__c();
                queryLineobj.Case__c = caseId;
                queryLineobj.Invoice_Line_Item__c = invoiceData.id;
                queryLineobj.Queried_Amount__c = invoiceData.Charge_excluding_GST__c;
                //Start of EDGE-139436 
                queryLineobj.Invoice_Line_Number__c = invoiceData.Invoice_Line_Number__c;
                //End of EDGE-139436 
                //EDGE-207870 Start-->
                queryLineobj.CaseNumber__c=caseUpdate!=null?caseUpdate.CaseNumber:'';
                queryLineobj.ChargeDescription__c = invoiceData.Service_Type__c;
                queryLineobj.ChargeType__c = invoiceData.Charge_Type__c;
                queryLineobj.InvoiceID__c = invoiceData.name;
                //EDGE-207870 End-->
                queryList.add(queryLineobj);
            }
            system.debug('Get the size of number of line items------>'+queryList.size());
            upsert queryList;      
        }
    }

    /*****************************************************************************************************
    Story(Sprint) : EDGE-207867(21.06)
    Method        : getExistingQlis
    Description   : Method to return existing QLi's against ILI's
    Author        : Aman Soni
    ******************************************************************************************************/
    private List<String> getExistingQlis(string caseId){
        List<Queried_Line_Item__c> qliList = new List<Queried_Line_Item__c>();
        qliList = [select id,name,Case__c,Invoice_Line_Item__c from Queried_Line_Item__c where Case__c = :caseId];
        List<String> IliQliExistLst = new List<String>();
        if(!qliList.isEmpty()){
            for(Queried_Line_Item__c qli : qliList){
                IliQliExistLst.add(qli.Invoice_Line_Item__c);
            }
        }
        return IliQliExistLst;
    }
}