global with sharing class CustomButtonAdditionalOrderInformation extends ValidateBasketStage {

  public cscfga__Product_Basket__c basket {get; set;}
  @testVisible
  private String basketId {get; set;}
    
  private String prevFinancialCIDN {get; set;}
  private String prevInvArrangID {get; set;}
  private String billingAccStatus {get; set;}

  public CustomButtonAdditionalOrderInformation() {
    basketId = apexpages.currentpage().getparameters().get('basketId');
    basket = [SELECT Maxim_Opportunity_ID__c, Customer_Request_Date__c, Order_Description__c, Project_Manager__c,
              Maxim_Opportunity_Name__c, Special_Deal__c, Purchase_Order_Number__c, Hot_Cutover_Comments__c, Financial_CIDN__c,
              Invoice_Arrangement_ID__c, Aggregator__c,Billing_Acc_Status__c,
              Service_Number__c, Hot_Cutover__c FROM cscfga__Product_Basket__c WHERE
              ID = :Apexpages.currentPage().getParameters().get('basketId') LIMIT 1];
      
     prevFinancialCIDN = basket.Financial_CIDN__c;
     prevInvArrangID= basket.Invoice_Arrangement_ID__c;
     billingAccStatus= basket.Billing_Acc_Status__c;
      
  }

  public String performAction (String bskId)  {//c__additionalOrderInformation?basketId=
    //Checks if the basket stage is closed won. If so, returns error
    String validateClosedWon = validateBasketStageClosedWon(bskId);
    String validateCancelled = validateBasketStageCancelled(bskId);
    String retVal = validateClosedWon != null ? validateClosedWon : null;
    retVal = ((retVal == null) && validateCancelled != null) ? validateCancelled : retVal;
    if (validateClosedWon == null && validateCancelled == null) {
      PageReference addInfo = new PageReference('/apex/c__additionalOrderInformation?basketId=' + bskId);
      return '{"status":"ok","text":"Launching Order Information UI.....","redirectURL":"' + addInfo.getUrl() + '"}';
    } else {
      return retVal;
    }
  }

  public void renderHotCutOverAttribute() {
    System.debug('renderHotCutOVerAttribute : ' + basket.Hot_Cutover__c);
    if (!basket.Hot_Cutover__c) {
      basket.Hot_Cutover_Comments__c = null;
      basket.Service_Number__c = null;
    }
  }

  public PageReference save() {
    PageReference ref = null;
    try {
      /*if (String.isBlank(basket.Maxim_Opportunity_ID__c)) {

        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.Additional_Order_Info_Max_Opp_Id_Req_Error);
        ApexPages.addMessage(msg);

      }*/
      if (String.isBlank(basket.Aggregator__c) && String.isBlank(basket.Invoice_Arrangement_ID__c) && !String.isBlank(basket.Financial_CIDN__c)) {

        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.Additional_Order_Info_oneoftwo_req_Error);
        ApexPages.addMessage(msg);

      } else {

        if (!String.isBlank(basket.Financial_CIDN__c) && !String.isBlank(basket.Invoice_Arrangement_ID__c )  
            && ((prevFinancialCIDN != basket.Financial_CIDN__c || prevInvArrangID != basket.Invoice_Arrangement_ID__c)
                || (prevFinancialCIDN == basket.Financial_CIDN__c && prevInvArrangID == basket.Invoice_Arrangement_ID__c && billingAccStatus!='Valid')) ) {

          BillingAccountValidateResponseDTO resDTO = BillingAccountManager.validateBillingAccount(basket.Financial_CIDN__c, basket.Invoice_Arrangement_ID__c);

          if (resDTO == null) {

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.Additional_Order_Info_billing_callout_Error);
            ApexPages.addMessage(msg);
            return ref;

          } else if (resDTO.flexcabError != null && resDTO.flexcabError.errorCode != null) {

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Additional_Order_Info_billing_technical_Error);
            ApexPages.addMessage(msg);
            return ref;

          } else if (resDTO.flexcabResponse != null && resDTO.flexcabResponse.product != null &&
                     resDTO.flexcabResponse.product.owner != null && resDTO.flexcabResponse.product.owner.party != null &&
                     resDTO.flexcabResponse.product.owner.party.errorCode != null) {

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.Additional_Order_Info_billing_nomatch_Error);
            ApexPages.addMessage(msg);
            return ref;

          } else {
                basket.Billing_Acc_Status__c='Valid';                         
          }
        }


        upsert basket;
        ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
        ref.setRedirect(true);
      }

    } catch (Exception e) {
      System.debug(e.getStackTraceString());
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.Additional_Order_Info_Error);
      ApexPages.addMessage(msg);
    }
    return ref;
  }

  public PageReference cancel() {
    PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
    ref.setRedirect(true);
    return ref;
  }


}