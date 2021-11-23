/*********************************************************************************************************************************
Class Name:  CustomButtonCreateOrder
Description: Class for custom button create order
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Antun Bartonicek        11/11/2019    EDGE-117966 (Parallel MACD validations)
 *********************************************************************************************************************************
*/
global with sharing class CustomButtonCreateOrder extends ValidateBasketStage {

    /**
     * performAction method overriden to provide create Order implementation
     *
     * @param      basketId  The basket identifier
     *
     * @return     String JSON format values
     */
    public String performAction(String basketId) {
         //Checks if the basket stage is closed won. If so, returns error
       cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
        //EDGE-117966 (Parallel MACD): first validate basket so that we don't waste SOQLs on other checks if basket shouldn't be moved forward
        String macdValidation = validateMACDbasket(productBasket, false);
        if (String.isNotEmpty(macdValidation)) {
            return macdValidation; //returns '{"status":"error", "text":"' + validationMessage + '"}';
        }
       String validateClosedWon = validateBasketStageClosedWon(productBasket);
       String validateCancelled = validateBasketStageCancelled(productBasket);
       String retVal = validateClosedWon!=null ? validateClosedWon : null;
       System.debug('validateClosedWon  : ' + retVal);
       if(validateClosedWon == null && validateCancelled == null){
           system.debug('before sync====////');
           CustomButtonOpportunitySync sync= new CustomButtonOpportunitySync();
           sync.performAction(basketId);
           system.debug('after sync====////');
           return CustomButtonCreateOrder.createOrder(basketId);
       }
       else{ 
             retVal = ((retVal==null) && validateCancelled!=null) ? validateCancelled : retVal;
             System.debug('validateCancelled after: ' + retVal);
           return retVal;
       }
    }

    /**
     * Creates an order. Sets the Basket status so that that cloudSense automatically trigger order
     *
     * @param      basketId  The basket identifier
     *
     * @return     URL to Redirect once the order creation is done
     */
    public static String createOrder(String basketId) {
        try{
			Boolean bIsPrimaryAndTechnicalContactBlank = false;
            cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('ServiceDetailing');
            List<cscfga__Product_Configuration__c> lstProdConfig = [select Id, Name, (select Id, Name, cscfga__Value__c from cscfga__Attributes__r where Name in ('Primarycontactid', 'Technicalcontactid')) from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basketId and Name = 'IP Site'];
            for(cscfga__Product_Configuration__c prodConfig : lstProdConfig){
            	for(cscfga__Attribute__c att : prodConfig.cscfga__Attributes__r)
            	{
                    if(String.isBlank(att.cscfga__Value__c))
                    {
                        bIsPrimaryAndTechnicalContactBlank = true;
                        break;
                    }
            	}
                if(bIsPrimaryAndTechnicalContactBlank == true)
                {
                    break;
                }
            }
            if ((productBasket.csordtelcoa__Basket_Stage__c).contains('Label.Closed')) {    
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Create_Order_Closed_basket_Error));
                return '{"status":"error","text":"'+Label.Create_Order_Closed_basket_Error+'","title":"'+Label.Create_Order_Error_title+'"}';
             } 
             else if(productBasket.cscfga__Basket_Status__c != Label.Valid) {
                system.debug('I am inside else if Label Valid====////');                 
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Create_Order_Enrich_Basket_Error));
                return '{"status":"error","text":"'+Label.Create_Order_Enrich_Basket_Error+'"}';             
             }
            else if(bIsPrimaryAndTechnicalContactBlank == true)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Create_Order_PrimaryAndTechnical_Contact_Error));
                return '{"status":"error","text":"'+Label.Create_Order_PrimaryAndTechnical_Contact_Error+'"}';
            }
             else {
                 system.debug('I am inside else====////');
                productBasket.cscfga__Basket_Status__c = Label.IsValid;
                productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('Submitted').Enrichment_Basket_Stage__c;
            }
            system.debug('I am outside If else====////');
            try{
                update productBasket;
            }catch(Exception e){
                System.debug('<><> Excep Msg == ' + e.getMessage() + ' <><> ' + e.getStackTraceString());
            }
                    
            system.debug('I am outside If else update====////');
            closeWonOppt(productBasket);
            system.debug('I am outside If else update closedwo====////');
            List<csord__Service__c> serviceObj = [SELECT id,csord__Order__c FROM csord__Service__c where csordtelcoa__Product_Basket__c = :productBasket.id LIMIT 1];
            system.debug('serviceObj===////'+serviceObj);
            csord__Order__c orderObj;
            if(!serviceObj.isEmpty()) {
                orderObj = [SELECT id FROM csord__Order__c  where id =:serviceObj[0].csord__Order__c ];
            } 
            else {
                orderObj = [SELECT id, Name,csordtelcoa__Opportunity__c,csord__Account__c, csord__Primary_Order__c 
                            FROM csord__Order__c  
                            WHERE csordtelcoa__Opportunity__c = :productBasket.cscfga__Opportunity__c
                            ORDER BY createddate DESC LIMIT 1];
            }
            system.debug('orderObj===////'+orderObj);
            PageReference orderPage = new ApexPages.StandardController(orderObj).view();
            orderPage.setRedirect(true);
            return '{"status":"ok","text":"'+Label.Create_Order_success_text+'", "title":"'+Label.Create_Order_success_title+'", "redirectURL":"' + orderPage.getUrl() + '"}';
          
        } catch(Exception e){
            System.debug('<><> Excep == ' + e );
            System.debug('<><> Excep Msg == ' + e.getMessage() + ' <><> ' + e.getStackTraceString());
            Logger.getLogger(CustomButtonCreateOrder.class).debug(e);
            return '{"status":"error", "text":"'+Label.Create_Order_exception_message+'", "title":"'+Label.Create_Order_exception_title+'"}';
            
        }

    }
    
    public static void closeWonOppt(cscfga__Product_Basket__c productBasket) {
      try{
          system.debug('entered closed won opp====////');
            if(productBasket.cscfga__Opportunity__c != null) {
                system.debug('entered closed won opp if====////');
                Opportunity opp = [SELECT id, pricebook2id,stagename,Close_Reason__c, (SELECT id FROM OpportunityLineItems)
                                        FROM Opportunity
                                        WHERE id = :productBasket.cscfga__Opportunity__c];
                opp.StageName = CustomConfigurationOptions__c.getValues('ClosedWon').Opportunity_Stage__c;
                opp.Won_Lost_Reason__c = 'Pricing';
                opp.Amount = productBasket.cscfga__total_contract_value__c;
                system.debug('entered closed won opp enc====////'+opp);
				try{
					 update opp;
				}catch(Exception ex) {
					System.debug('<><> Excep Msg == ' + ex.getMessage() + ' <><> ' + ex.getStackTraceString());
				}
               
                system.debug('entered closed won opp end====////'+opp);
              }
          }  
      Catch(Exception e)
      {
         System.debug('<><> Excep Msg == ' + e.getMessage() + ' <><> ' + e.getStackTraceString());
      }    
    }
}