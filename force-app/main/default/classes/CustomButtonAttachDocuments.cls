global with sharing class CustomButtonAttachDocuments extends ValidateBasketStage {
  
  private String basketId {get;set;}
  private String accountId {get;set;}
  public Account accountObj {get;set;}
  public cscfga__Product_Basket__c basket {get;set;}
  public List<External_Attachment__c> extList {get;set;}
  public External_Attachment__c extAdd {get;set;}
  public Id selectedAtt {get;set;}
  public boolean isEdit {get;set;}
  public boolean fromAccount {get;set;}

  /**
   * Constructor method to initiate variables
   */
  public CustomButtonAttachDocuments() {
    isEdit = false;
    basketId = apexpages.currentpage().getparameters().get('basketId');
    accountId = apexpages.currentpage().getparameters().get('accountId');
    if(accountId != null){
        fromAccount = true;
        accountObj = [ SELECT Name
                        FROM Account 
                        WHERE Id = :Apexpages.currentPage().getParameters().get('accountId')];
                        
        extList = [  SELECT   Id, 
                Name, 
                File_Name__c, 
                URL__c, 
                Type__c, 
                Comments__c
            FROM External_Attachment__c
            WHERE Account__c = :accountId];
    }
    else if(basketId != null){
        fromAccount = false;
        basket = [  SELECT   Id, 
                Name,
                csordtelcoa__Basket_Stage__c, 
                csbb__Account__c,
                csbb__Account__r.Name
            FROM cscfga__Product_Basket__c 
            WHERE Id = :Apexpages.currentPage().getParameters().get('basketId') 
            LIMIT 1];
            
        extList = [  SELECT   Id, 
                Name, 
                File_Name__c, 
                URL__c, 
                Type__c, 
                Comments__c
            FROM External_Attachment__c
            WHERE Product_Basket__c = :basketId];
    }
    
    createEmptyAtt();
  }

  /**
   * Used to redirect the user from the product basket page to the custom attachment page
   */
  public String performAction (String bskId)  {
	cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
    String validateClosedWon = validateBasketStageClosedWon(productBasket);
        String validateCancelled = validateBasketStageCancelled(productBasket);
        String retVal = validateClosedWon!=null ? validateClosedWon : null;
        retVal = ((retVal==null) && validateCancelled!=null) ? validateCancelled : retVal;
        if(validateClosedWon == null && validateCancelled == null){
            PageReference attachDoc = new PageReference('/apex/c__attachDocumentInformation?basketId=' + bskId); 
      return '{"status":"ok","text":"Launching Attach Document Information UI.....","redirectURL":"' + attachDoc.getUrl() + '"}';
        }
        else{
            return retVal;
        }        
    }

    /**
     * Saves the attachment against the product basket object
     */
  public void save(){
    try {
      if (isEdit) {
        update extAdd;
      }
      else {
        insert extAdd;
        extList.add(extAdd);
      }
      createEmptyAtt();
      isEdit = false;
      
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.PROD_BASKET_ATTACHMENT_SUCCESS));
    }
    catch (Exception e) {
      if(accountId != null)
      System.debug('Exception occurred when adding attachment to account ' + accountId + '. Exception: ' + e + '.');
      else if(basketId != null)
      System.debug('Exception occurred when adding attachment to product basket ' + basketId + '. Exception: ' + e + '.');
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.PROD_BASKET_ATTACHMENT_ERROR));
    }
    }

    /**
     * Returns the user to the product basket page
     */
    public PageReference cancel(){
      PageReference ref;
      if(accountId != null)
      ref = new PageReference('/' + accountId);
      else if(basketId != null)
      ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
      ref.setRedirect(true);
      return ref;
    }

    /**
     * Deletes the attachment and removes it from the list
     */
    public void deleteAtt() {

    External_Attachment__c tobeDeleted = null;
    for(Integer i = 0; i < extList.size(); i++) {
      if (extList.get(i).Id == selectedAtt) {
        tobeDeleted = extList.get(i);
        extList.remove(i);
        break;
      }
    }
    delete tobeDeleted;
    }

    /**
     * Edits the current attachment
     */
    public void editAtt() {
      
      isEdit = true;
      for (External_Attachment__c ea : extList) {
        if (ea.Id == selectedAtt) {
          extAdd = ea;
          break;
        }
      }
    }    

    /**
     * Creates an empty attachment for use when adding multiple attachments one after the other
     * and clearing the form data after a successful insert
     */
  private void createEmptyAtt() {
    if(accountId != null)
    extAdd = new External_Attachment__c(Product_Basket__c = basketId, Account__c = accountId);
    else if(basketId != null)
    extAdd = new External_Attachment__c(Product_Basket__c = basketId, Account__c = basket.csbb__Account__c);
  }    

}