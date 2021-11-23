/*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -LineItemAdjustmentsController
Description -Class for Sending Line Item Adjustments request to BDS and receive response from BDS .
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
public Without sharing class LineItemAdjustmentsController {
    /*----------------------------------------------------------------------------
EDGE        -88294
Method Name -getCreditAndAdjustment
Description -Get CreditAndAdjustment record
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @AuraEnabled Public static Credits_and_Adjustments__c getCreditAndAdjustment(String id){
        Try{
            if(string.isNotBlank(id)){
                return[SELECT id,Accepted_by_Customer__c,Submitted__c,Case_Number__c,Case_Number__r.Status,Billing_Account_Number_BAN__c,Determination_Status__c FROM Credits_and_Adjustments__c where id=:id] ;   
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger('LineItemAdjustmentsController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return null;
    }
    /*--------------------------------------------------------------------------------
EDGE        -88294
Method Name -doSubmit
Description -Creating Line Item Adjustments request for BDS API callout. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @AuraEnabled  public static String doSubmit(string creditAndAdjustmentId,string handler){
        ResponseWrapper  responseObj;
        String message;
        Credits_and_Adjustments__c creditAndAdjustment=new Credits_and_Adjustments__c();
        List<Queried_Line_Item__c> queriedLineItemList=new List<Queried_Line_Item__c>();
        List<Invoice_Line_Item__c> invoiceLineItemList=new List<Invoice_Line_Item__c>();
        adjustmentTarget adjustment=new adjustmentTarget();
        List<InvoiceItem> invoiceItemList=new List<InvoiceItem>();
        List<Invoice__c> invoiceList=new List<Invoice__c>();
        LineItemAdjustmentRequest request=new LineItemAdjustmentRequest();
        set<id> invoiceIdSet=new set<id>();
        map<string,string> reasonCodeAndReasonDescriptionMap=new map<string,string>();
        //Start of EDGE: 129882
        String creditAdjustmentType;
        //End of EDGE: 129882
        Try{
            For(QueriedLineItem__mdt queriedLineItem:[SELECT Reason_Code__c,Reason_Description__c from QueriedLineItem__mdt]){
                reasonCodeAndReasonDescriptionMap.put(queriedLineItem.Reason_Description__c,queriedLineItem.Reason_Code__c); 
            }
            //System.debug('reasonCodeAndReasonDescriptionMap result-->:'+reasonCodeAndReasonDescriptionMap);
            /**Start of EDGE-153461
@ModifiedBy: Ramya G
@Team              : Osaka
@Description: Removed the case description (Case_Number__r.description) since it is optional and causing issues due to special characters in U2C
**/
            creditAndAdjustment =[SELECT id,Accepted_by_Customer__c,Failure_Reason__c,Date_when_credit_was_given_to_customer__c,Submitted__c,Case_Number__r.CaseNumber,Case_Number__r.id,Case_Number__r.subject ,Billing_Account_Number_BAN__r.Billing_Account_Number__c,Billing_Account_Number_BAN__r.id,recordtypeid,Determination_Status__c FROM Credits_and_Adjustments__c WHERE id=:creditAndAdjustmentId ];
            //END of EDGE-153461
            /**  Start of EDGE:113051
@Modified/updatedBy: Sasidhar Devarapalli
@team              : Osaka
@Description: Deleted InvoiceLineNumber and TransactionId from QueriedLineItem object
Added InvoiceLineNumber and TransactionId from InvoiceLineItem object
**/
            queriedLineItemList=[SELECT id,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice__c,Invoice_Line_Item__r.Invoice_Line_Number__c,Invoice_Line_Item__r.Invoice_Transaction_ID__c,Determination_Amount__c,Reason_Code__c,Credit_Adjustment__c,Case__c FROM Queried_Line_Item__c WHERE Credit_Adjustment__c=:creditAndAdjustmentId];
            //End of EDGE:113051
            if(creditAndAdjustment != NULL){
                //Start of EDGE: 129882 -BAN not required as per Swagger 2.0
                /*
if(creditAndAdjustment.Billing_Account_Number_BAN__r.Billing_Account_Number__c != NULL){
request.billingAccountNumber=Decimal.valueOf(creditAndAdjustment.Billing_Account_Number_BAN__r.Billing_Account_Number__c);
}
*/
                //End of EDGE: 129882
                //Start of EDGE: 129882
                creditAdjustmentType = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosById().get(creditAndAdjustment.recordtypeid).getname();
                if(creditAdjustmentType =='Line Item Credit'){
                    request.adjustmentType ='Line-item-credit';
                }
                //End of EDGE: 129882
                //EDGE-181251: Removing case subject from U2C request.
                //request.description=creditAndAdjustment.Case_Number__r.Subject;
                //EDGE-153461:Comment will not be mapped henceforth due to special characters from TConnect failing in U2C
                //request.comments=creditAndAdjustment.Case_Number__r.description;
                request.instanceId=creditAndAdjustment.id;
                //Start of EDGE:113051
                //Mapping caseNumber field to caseReferenceNumber as addmin caseNumber in the Request payload
                request.caseReferenceNumber=creditAndAdjustment.Case_Number__r.CaseNumber;
                
                //End of EDGE:113051
                creditAndAdjustment.Accepted_by_Customer__c=true;
            }
            request.currencyCode=Label.Currency;
            // system.debug('zeeshan-queriedLineItemList.size():' + queriedLineItemList.size());
            if(queriedLineItemList.size() >0){
                for(Queried_Line_Item__c queriedLineItem:queriedLineItemList){
                    invoiceIdSet.add(queriedLineItem.Invoice_Line_Item__r.Invoice__c);
                    InvoiceItem item=new InvoiceItem();
                    /**  Start of EDGE:113051
@Modified/updatedBy: Sasidhar Devarapalli
@team              : Osaka
@Description:Mapping Invoice Line Number from the  Invoice Line Item Instead of Queried Line Item Object
as InvoiceLineNumber is deleted from QueriedLineItem
**/
                    item.invoiceLineNumber=Integer.valueOf(queriedLineItem.Invoice_Line_Item__r.Invoice_Line_Number__c);
                    //Mapping TransactionId from InvoiceLineItem object instead of QuerieldLineItem Object
                    /*** START OF EDGE-125016   ***/
                    item.invoiceTransactionId = queriedLineItem.Invoice_Line_Item__c!=null? queriedLineItem.Invoice_Line_Item__r.Invoice_Transaction_ID__c.longValue():null;
                    /*** END OF EDGE-125016 ***/
                    //End of EDGE: 113051
                    item.creditAmount=Double.valueOf(queriedLineItem.Determination_Amount__c);
                    item.ChargeType=queriedLineItem.Invoice_Line_Item__r.Charge_Type__c;
                    item.lineItemReasonCode=Integer.valueOf(reasonCodeAndReasonDescriptionMap.get(queriedLineItem.Reason_Code__c));
                    invoiceItemList.add(item);
                }
            }
            if(invoiceIdSet.size() > 0){
                invoiceList=[SELECT id,Billing_Account__c,Aria_Invoice_Number__c from Invoice__c WHERE id=:invoiceIdSet];
            }
            //Start of EDGE:113051 
            request.ariaInvoiceNumber= !invoiceList.isEmpty()? Long.valueOf(invoiceList[0].Aria_Invoice_Number__c) : null;
            //End of EDGE:113051
            
            //system.debug('zeeshan invoiceItemList.size()'+invoiceItemList.size());
            if(invoiceItemList.size()>0){
                adjustment.invoiceItem=invoiceItemList;
                request.adjustmentTarget=adjustment;
            }
            message=sendLineItemAdjustmentsRequest(JSON.serialize(request),handler,creditAndAdjustment);
            
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger('LineItemAdjustmentsController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return message;
    }
    
    
    
    /*----------------------------------------------------------------------------
EDGE        -88294
Method Name -sendLineItemAdjustmentsRequest
Description -Creating Line Item Adjustments request for BDS API callout. 
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------*/
    @AuraEnabled public static string sendLineItemAdjustmentsRequest(String reqBody,String handler, Credits_and_Adjustments__c creditAndAdjustment){
        System.debug('Calling sendLineItemAdjustmentsRequest$$');

        Boolean setCaseStatus = true;
		List <Case> closedCase = new List<Case> ();
        string message='';
        system.debug('reqBody=='+reqBody);
        ResponseWrapper  responseObj;
        HttpResponse response=LineItemAdjustmentsService.LineItemAdjustmentsRequest(reqBody,handler,creditAndAdjustment.Billing_Account_Number_BAN__r.Billing_Account_Number__c);
        if(response !=null){
            responseObj= (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
            if(response.getStatusCode()==200 || response.getStatus()=='Success' || response.getStatusCode()==201 || response.getStatus()=='Created'){
                creditAndAdjustment.Submitted__c=true;
                creditAndAdjustment.Date_when_credit_was_given_to_customer__c = System.today();

                if(setCaseStatus){

				if(creditAndAdjustment.Case_Number__r.id != null){
					List<Case> caseRecord = [Select id, Status from Case where ID =: creditAndAdjustment.Case_Number__r.id];
					for (Case caseStatus : caseRecord){
                        if(caseStatus.Status != 'Closed'){
                            caseStatus.Status = 'Closed';
                            closedCase.add(caseStatus);

                                setCaseStatus = false;
                            }

                        }
					}
				}
                message=Label.BDS_Response_Success_Message;
            }
            else{
                creditAndAdjustment.Failure_Reason__c=responseObj.errors[0].message;
                message=Label.BDS_Response_Error_Message;
            }
        }
        update creditAndAdjustment;

        if(creditAndAdjustment.Submitted__c){

			update closedCase;
		}
        return message;
    } 
    /*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -LineItemAdjustmentRequest
Description -Wrapper class fot creating request payload .
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    public Class LineItemAdjustmentRequest{
        /*Start of EDGE: 129882 Defect fix BAN not required as per Swagger 2.0
Decimal billingAccountNumber;
Integer amount;
String gstIndicator;
End of EDGE: 129882 */
        //String description; //INC000096527193 -DIGI-5690
        //String productId;
        String instanceId;
        String adjustmentType; 
        String currencyCode;
        //Start of EDGE: 129882    
        Long ariaInvoiceNumber;
        //End of EDGE: 129882
        //String comments;  //INC000096527193 -DIGI-5690
        adjustmentTarget adjustmentTarget;
        String caseReferenceNumber; // Added as part of EDGE: 113051
    }
    /*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -adjustmentTarget
Description -Wrapper class fot creating request payload of invoiceItem.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    Public Class adjustmentTarget{
        List<invoiceItem> invoiceItem;
    }
    /*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -InvoiceItem
Description -Wrapper class fot creating request payload of invoiceItem.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    public class InvoiceItem{
        //Start of EDGE: 129882 Renamed
        Integer lineItemReasonCode;
        //End of EDGE: 129882 
        String chargeType;
        Long invoiceLineNumber;  
        Long invoiceTransactionId; 
        Double creditAmount;
        
    }
    /*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -ResponseWrapper
Description -Wrapper class for response .
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    public class ResponseWrapper{
        @AuraEnabled  public String correlationId;
        @AuraEnabled  public Integer code;
        @AuraEnabled  public Integer status;
        @AuraEnabled  public String  message;
        @AuraEnabled  public List<errors> errors;
    }
    /*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -Errors
Description -error class for response .
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    public Class Errors{
        @AuraEnabled  public String code;
        @AuraEnabled  public String field;
        @AuraEnabled  public String message;
        
    }
    /**
    *  The method will fetch latest Credit and Adjustment Record relatd to Case
    *  @generatePayLoad     - 
    *  @param qli_List      - Current Case Id
    *  @return Credits_and_Adjustments__c - Credits_and_Adjustments__c/null
    *  @throws exception    - 
    *  @jira Story Ref      - EDGE-157956
    *  @createdBy           - Abhishek Mallick
    *  @team                - OSAKA
    **/
    @AuraEnabled public static Credits_and_Adjustments__c getCreditAndAdjustmentRecord(String id){
        Try{
            if(string.isNotBlank(id)){
                return[SELECT id,Determination_Status__c,Submitted__c,CreatedDate from Credits_and_Adjustments__c 
                       where Case_Number__c =:id ORDER BY CreatedDate desc LIMIT 1];   
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger('LineItemAdjustmentsController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return null;
    }
}