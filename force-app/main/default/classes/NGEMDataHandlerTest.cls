/*
* @Author : Yash
* @Date : 8th June 2020
* @Desc : Test class for NGEMDataHandler
* @Jira : EDGE-148721, EDGE-150587 and EDGE-148728
*/
@isTest
public class NGEMDataHandlerTest {
    private void setup() { 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        system.debug('acc: '+acc);
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        //billAcc.name = 'BA-0004772';
        billAcc.Account__c = acc.id;
        insert billAcc;
        system.debug('billAcc@@::' + billAcc);
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        system.debug('opp '+opp);
        //EDGE-184433 Start
         csconta__Frame_Agreement__c fa = new csconta__Frame_Agreement__c();
        fa.csconta__Status__c = 'Apporved';
        insert fa;
        //EDGE-184433 End
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        basket.csconta__Frame_Agreement__c = fa.Id; //EDGE-184433
        system.debug('basket '+basket);
        //insert basket;
    //EDGE-166406 Start
    List<cscfga__Product_Basket__c> lstBasket = new List<cscfga__Product_Basket__c>();
    lstBasket.add(basket);
    cscfga__Product_Basket__c basketBoltOn = ProductTestFactory.buildEmptyBasket();
        basketBoltOn.cscfga__Opportunity__c = opp.id;
        basketBoltOn.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basketBoltOn.csbb__Synchronised_With_Opportunity__c =true;
        basketBoltOn.cscfga__Basket_Status__c = 'Valid';
        basketBoltOn.cscfga__total_contract_value__c = 9999;
        system.debug('basket '+basketBoltOn);
        lstBasket.add(basketBoltOn);
       
    //EDGE-166406 End
    //EDGE-176737 Start
        cscfga__Product_Basket__c basketIRBoltOn = ProductTestFactory.buildEmptyBasket();
        basketIRBoltOn.cscfga__Opportunity__c = opp.id;
        basketIRBoltOn.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basketIRBoltOn.csbb__Synchronised_With_Opportunity__c =true;
        basketIRBoltOn.cscfga__Basket_Status__c = 'Valid';
        basketIRBoltOn.cscfga__total_contract_value__c = 9922;
        system.debug('basketIR '+basketIRBoltOn);
        lstBasket.add(basketIRBoltOn);
    //EDGE-176737 End
        insert lstBasket;
    system.debug('lstBasket::' + lstBasket);
    //EDGE-166406 End
        List<cscfga__Product_Basket__c> prodBasketList = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Definition__c> ngemPDList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c ngemPD = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemPD.product_Specification__c='DMCAT_ProductSpecification_001211';
        ngemPDList.add(ngemPD);
        //EDGE-148776 - Start    
        cscfga__Product_Definition__c ngemDeviceCarePD = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemDeviceCarePD.product_Specification__c='DMCAT_ProductSpecification_001208';
        ngemPDList.add(ngemDeviceCarePD); 
        //EDGE-148776 - End
        //EDGE-165326 Start
        cscfga__Product_Definition__c ngemPlanPD = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemPlanPD.product_Specification__c='DMCAT_ProductSpecification_001196';
        ngemPDList.add(ngemPlanPD);
        //EDGE-165326 END
        //EDGE-155059 & EDGE-162542 Start
        cscfga__Product_Definition__c ngemVoicemailPD = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemVoicemailPD.product_Specification__c='DMCAT_ProductSpecification_001186';
        ngemPDList.add(ngemVoicemailPD);
        //EDGE-155059 & EDGE-162542 End
        //EDGE-164623 Start 
        cscfga__Product_Definition__c appleCareP = ProductTestFactory.buildProductDefinition('Test','Test');
        appleCareP.product_Specification__c='DMCAT_ProductSpecification_001208';
         //EDGE-164623 End 
        ngemPDList.add(appleCareP); 
        //EDGE-176737 Start
        cscfga__Product_Definition__c ngemIRMonthPass = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemIRMonthPass.product_Specification__c='DMCAT_ProductSpecification_001341';  
        ngemPDList.add(ngemIRMonthPass);
        //EDGE-176737 End
        //DPG-3508- start
        cscfga__Product_Definition__c ngemMobAcc = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemMobAcc.product_Specification__c='DMCAT_ProductSpecification_001389';  
        ngemPDList.add(ngemMobAcc);
        //DPG-3508- end
        insert ngemPDList;
        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
        Marketable_Offer__c ngemMO = new Marketable_Offer__c();
        ngemMO.OfferDefinationName__c ='Next Generation Enterprise Mobility' ; // Modified as per real data DPG-3508
        ngemMO.Name = 'Standalone Devices and Accessories';  // Modified as per real data DPG-3508
        ngemMO.Offer_ID__c = 'DMCAT_Offer_001231';
        listOfOffers.add(ngemMO);
        //EDGE-165326 Start
        Marketable_Offer__c ngemPlanMO = new Marketable_Offer__c();
        ngemPlanMO.OfferDefinationName__c ='Next Generation Enterprise Mobility' ;
        ngemPlanMO.Name = 'Next Generation Plan';
        ngemPlanMO.Offer_ID__c = 'DMCAT_Offer_001233';
        listOfOffers.add(ngemPlanMO);
        //EDGE-165326 END
        insert listOfOffers;
        //EDGE-148722 - Start
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name='Replaced Product Configuration record';
        replacedConfig.cscfga__Product_Definition__c=ngemPDList[0].id;
        replacedConfig.cscfga__Product_Basket__c=basket.id;
        replacedConfig.cscfga__Description__c = 'test Description';
        replacedConfig.cscfga__Contract_Term__c = 36;
        replacedConfig.Commercial_Config__c='Yes';
        replacedConfig.Quantity_Product_Configuration__c=1;
        replacedConfig.cscfga__total_one_off_charge__c=100;
        replacedConfig.cscfga__total_recurring_charge__c=100;
        insert replacedConfig;
        system.debug('replacedConfig ' + replacedConfig.id);
        //EDGE-148722 - End
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();

        for (Integer i=1; i <= 40; i++){

            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(ngemPDList[0].id);
            config.cscfga__Product_Basket__c = basket.id;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Commercial_Config__c='Yes';
            config.Quantity_Product_Configuration__c=1;
            config.cscfga__total_one_off_charge__c=100;
            config.cscfga__total_recurring_charge__c=100;
            if(i == 1)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE GREY';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            if(i == 2)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPHONE 11 128GB 4GX RED';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            if(i == 3)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            if(i == 4)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='NETGEAR NIGHTHAWK M2 DEFAULT';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            //EDGE-148776 - Start
            if(i == 5)     
            {
                config.name='AppleCare+ Purchase';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[1].id;
                //config.cscfga__Product_Definition__r.product_Specification__c='DMCAT_ProductSpecification_001208';
                config.cscfga__Product_Family__c='Mobile Device Care';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            //EDGE-148776 - End
            //EDGE-148722 - Start
            if(i == 6)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPHONE 10 128GB 4GX RED';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-148722 - End
            //
            if(i == 7)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Enterprise Wireless-Enterprise Wireless';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = null;
                config.cscfga__Product_Basket__c = basket.id;
            }
            if(i == 8)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Mobile Broadband-Enterprise Lite';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = null;
                config.cscfga__Product_Basket__c = basket.id;
            }
            //EDGE-165326 Start
            if(i == 9)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Handheld-Enterprise Mid';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = null;
                config.cscfga__Product_Basket__c = basket.id;
            }
            if(i == 10)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Handheld-Enterprise Mid';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = null;
                config.cscfga__Product_Basket__c = basket.id;
            }
            if(i == 11)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Handheld-Enterprise Mid';
                config.Type__c = 'Modify';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                config.cscfga__Product_Basket__c = basket.id;
            }
            //EDGE-165326 END
            //EDGE-155059 & EDGE-162542 Start
             if(i == 12)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                //config.cscfga__unit_recurring_charge__c = 200;
                config.cscfga__total_recurring_charge__c = 20;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            if(i == 13)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Handheld-Enterprise Mid-Cancel';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                config.cscfga__Product_Basket__c = basket.id;
            }
            if(i == 14)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[3].id;
                config.name='Voicemail';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Voicemail';
                //config.cscfga__unit_recurring_charge__c = 200;
                config.cscfga__total_recurring_charge__c = 20;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                //config.cscfga__Parent_Configuration__c = ;
            }
            if(i == 15)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Enterprise Wireless-Enterprise Wireless-Cancel';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                config.cscfga__Product_Basket__c = basket.id;
            }
             if(i == 16)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[3].id;
                config.name='Voicemail';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Voicemail';
                //config.cscfga__unit_recurring_charge__c = 200;
                config.cscfga__total_recurring_charge__c = 20;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                //config.cscfga__Parent_Configuration__c = ;
            }
             if(i == 17)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Mobile Broadband-Enterprise Lite-Cancel';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[1].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                config.cscfga__Product_Basket__c = basket.id;
            }
            if(i == 18)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[3].id;
                config.name='Voicemail';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Voicemail';
                //config.cscfga__unit_recurring_charge__c = 200;
                config.cscfga__total_recurring_charge__c = 20;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                //config.cscfga__Parent_Configuration__c = ;
            }
            if(i == 19)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                //config.cscfga__unit_recurring_charge__c = 200;
                config.cscfga__total_recurring_charge__c = 20;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-164623 Start 
             if(i == 20)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[4].id;
                config.name='Mobile Device Care Purchase';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            if(i == 21)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[4].id;
                config.name='Mobile Device Care Purchase';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-164623 End 
            //EDGE-155059 & EDGE-162542 End
      //EDGE-166406 Start
      if(i == 22)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Enterprise Wireless-Epic-Agg';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__Product_Basket__c = basketBoltOn.id;
            }
      if(i == 23)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.name='Enterprise Wireless-Epic-Agg';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__Product_Basket__c = basketBoltOn.id;
            }
      if(i == 24)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[3].id;
                config.name='Data Features';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Data';
                config.cscfga__Product_Basket__c = basketBoltOn.id;
            }
      if(i == 25)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[3].id;
                config.name='Data Features';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Data';
                config.cscfga__Product_Basket__c = basketBoltOn.id;
            }
            //EDGE-165486 Changes Start
        if(i == 26)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPHONE 11 128GB 4GX RED';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            if(i == 27)     
            {
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE GREY';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
        if(i == 28)     
            {
                config.name='AppleCare+ Purchase';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[1].id;
                //config.cscfga__Product_Definition__r.product_Specification__c='DMCAT_ProductSpecification_001208';
                config.cscfga__Product_Family__c='Mobile Device Care';
                config.cscfga__unit_recurring_charge__c = 200;
            }
        if(i == 29)     
            {
                config.cscfga__Product_Basket__c = basketBoltOn.id;
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPHONE 11 128GB 4GX RED';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            if(i == 30)     
            {
                config.cscfga__Product_Basket__c = basketBoltOn.id;
                config.cscfga__Product_Definition__c = ngemPDList[0].id;
                config.name='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE GREY';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Next Generation Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
            }

            if(i == 31)//EDGE-181997- Code Change Start     
            {
                config.cscfga__Product_Basket__c = basketBoltOn.id;
                config.name='AppleCare+ Purchase';
                config.Type__c = 'Cancel';
                config.cscfga__Product_Definition__c = ngemPDList[1].id;
                //config.cscfga__Product_Definition__r.product_Specification__c='DMCAT_ProductSpecification_001208';
                config.cscfga__Product_Family__c='Mobile Device Care';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-181997- Code Change End

      //EDGE-166406 End
      //EDGE-165486 Changes End
      //EDGE-176737 Start
            if(i == 32)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='Enterprise Wireless-Epic-Agg_IR';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 100.00;
            }
            
            if(i == 33)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='International Roaming Month Pass';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[5].id;
                config.cscfga__Product_Family__c='EM International Roaming Month Pass';
                config.cscfga__unit_recurring_charge__c = 60.00;
                
            }
            if(i == 34)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='International Roaming Month Pass';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[5].id;
                config.cscfga__Product_Family__c='EM International Roaming Month Pass';
                config.cscfga__unit_recurring_charge__c = 60.00;
                
            }
            if(i == 35)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='International Roaming Month Pass';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[5].id;
                config.cscfga__Product_Family__c='EM International Roaming Month Pass';
                config.cscfga__unit_recurring_charge__c = 60.00;
                
            }
         //EDGE-176737 End
         //EDGE-185762 Start
         if(i == 36)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='Enterprise Wireless-Epic-Agg_IR_Modify';
                config.Type__c = 'Modify';
                config.cscfga__Product_Definition__c = ngemPDList[2].id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 100.00;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            
            if(i == 37)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='International Roaming Month Pass';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[5].id;
                config.cscfga__Product_Family__c='EM International Roaming Month Pass';
                config.cscfga__unit_recurring_charge__c = 60.00;
                
            }
             if(i == 38)   
            {
                config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='International Roaming Month Pass';
                config.Type__c = 'Modify';
                config.cscfga__Product_Definition__c = ngemPDList[5].id;
                config.cscfga__Product_Family__c='EM International Roaming Month Pass';
                config.cscfga__unit_recurring_charge__c = 60.00;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                
            }
            //EDGE-185762 End
            //DPG-3508- start
            if(i == 39)   
            {
                //config.cscfga__Product_Basket__c = lstBasket[2].id;
                config.name='Cables and chargers';
                config.Type__c = 'New';
                config.cscfga__Product_Definition__c = ngemPDList[6].id;
                config.cscfga__Product_Family__c='Mobile Accessory';
                config.cscfga__unit_recurring_charge__c = 60.00;
                //config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
                
            }
            if(i== 40)
            {
                config.cscfga__Product_Definition__c = ngemPDList[6].id;
                config.name='Watches and wearables';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Mobile Accessory';
                config.cscfga__unit_recurring_charge__c = 200;
            }
            //DPG-3508- End
            
            prodConfigList.add(config);         
        }  
        insert prodConfigList;
        system.debug('prodConfigList: '+prodConfigList[32] +'::' + prodConfigList[31]);
        //EDGE-155059 & EDGE-162542 Start
        List<cscfga__Product_Configuration__c> pcUpsertlist= new List<cscfga__Product_Configuration__c>();
        prodConfigList[13].cscfga__Parent_Configuration__c = prodConfigList[12].id;
        prodConfigList[15].cscfga__Parent_Configuration__c = prodConfigList[14].id;
        prodConfigList[17].cscfga__Parent_Configuration__c = prodConfigList[16].id;
        prodConfigList[23].cscfga__Parent_Configuration__c = prodConfigList[21].id;//EDGE-166406
        prodConfigList[24].cscfga__Parent_Configuration__c = prodConfigList[22].id;//EDGE-166406
        prodConfigList[32].cscfga__Parent_Configuration__c = prodConfigList[31].id;//EDGE-176737
        prodConfigList[33].cscfga__Parent_Configuration__c = prodConfigList[31].id;//EDGE-176737
        prodConfigList[34].cscfga__Parent_Configuration__c = prodConfigList[31].id;//EDGE-176737
        prodConfigList[36].cscfga__Parent_Configuration__c = prodConfigList[35].id;//EDGE-185762
        prodConfigList[37].cscfga__Parent_Configuration__c = prodConfigList[35].id;//EDGE-185762
        pcUpsertlist.add(prodConfigList[13]);
        pcUpsertlist.add(prodConfigList[15]);
        pcUpsertlist.add(prodConfigList[17]);
        pcUpsertlist.add(prodConfigList[23]);//EDGE-166406
        pcUpsertlist.add(prodConfigList[24]);//EDGE-166406
        pcUpsertlist.add(prodConfigList[32]);//EDGE-176737
        pcUpsertlist.add(prodConfigList[33]);//EDGE-176737
        pcUpsertlist.add(prodConfigList[34]);//EDGE-176737
        pcUpsertlist.add(prodConfigList[36]);//EDGE-185762
        pcUpsertlist.add(prodConfigList[37]);//EDGE-185762
        upsert pcUpsertlist;
        //EDGE-155059 & EDGE-162542 End
        List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngemPDList[0].Id,
            Name = 'AD1'
        );
        attDefList.add(ad);
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngemPDList[0].Id,
            Name = 'AD2'
        );
        attDefList.add(ad1);
        //EDGE-148776 - Start
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngemPDList[1].Id,
            Name = 'AD3'
        );
        attDefList.add(ad2);
        //DPG-3508
        cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngemPDList[6].Id,
            Name = 'AD4'
        );
        attDefList.add(ad3);
        //EDGE-148776 - End
        /*
        cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngemPDList[2].Id,
            Name = 'AD4'
        );
        attDefList.add(ad3); */
        insert attDefList;
        system.debug('attDefList: '+attDefList);
        cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
        testPriceItem.Name = 'PaymentTypeLookup';
        testPriceItem.cspmb__Contract_Term__c = '12';
        testPriceItem.cspmb__Recurring_Charge__c = 75;
        testPriceItem.cspmb__One_Off_Charge__c = 750;
        testPriceItem.Unit_Of_Measure__c='per device';

        testPriceItem.Billing_Description__c='APPLE IPHONE 10 128GB 4GX RED';//EDGE-181997- Code Change

        cspmb__Price_Item__c testPriceItem1 = new cspmb__Price_Item__c();
        testPriceItem1.Name = 'PaymentTypeLookup';
        testPriceItem1.cspmb__Contract_Term__c = '12';
        testPriceItem1.cspmb__Recurring_Charge__c = 75;
        testPriceItem1.cspmb__One_Off_Charge__c = 750;
        testPriceItem1.Unit_Of_Measure__c='per device';
        //EDGE-181997- Code Change Start
        testPriceItem1.Billing_Description__c='APPLE IPHONE 11 128GB 4GX RED';
         cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
        testPriceItem2.Name = 'PaymentTypeLookup';
        testPriceItem2.cspmb__Contract_Term__c = '12';
        testPriceItem2.cspmb__Recurring_Charge__c = 75;
        testPriceItem2.cspmb__One_Off_Charge__c = 750;
        testPriceItem2.Unit_Of_Measure__c='per device';
        testPriceItem2.Billing_Description__c='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE Grey';
          cspmb__Price_Item__c testPriceItem3 = new cspmb__Price_Item__c();
        testPriceItem3.Name = 'PaymentTypeLookup';
        testPriceItem3.cspmb__Contract_Term__c = '12';
        testPriceItem3.cspmb__Recurring_Charge__c = 75;
        testPriceItem3.cspmb__One_Off_Charge__c = 750;
        testPriceItem3.Unit_Of_Measure__c='per device';
        testPriceItem3.Billing_Description__c='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE';
        //DPG-3508
        cspmb__Price_Item__c testPriceItem4 = new cspmb__Price_Item__c();
        testPriceItem4.Name = 'PaymentTypeLookup';
        testPriceItem4.cspmb__Contract_Term__c = '12';
        testPriceItem4.cspmb__Recurring_Charge__c = 75;
        testPriceItem4.cspmb__One_Off_Charge__c = 750;
        testPriceItem4.Unit_Of_Measure__c='per device';
        testPriceItem4.Billing_Description__c='Watches and wearables';
        
        List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem,testPriceItem1,testPriceItem2,testPriceItem3, testPriceItem4};
            //EDGE-181997- Code Change End
            insert PIList;
        system.debug('PIList: '+PIList);
        //EDGE-148776 - Start
        cspmb__Add_On_Price_Item__c testAddon = new cspmb__Add_On_Price_Item__c();
        testAddon.Name = 'Mobile Device Care';
        testAddon.ProdSpecId__c='DMCAT_ProductSpecification_001208';
        testAddon.cspmb__One_Off_Charge__c = 750;
        List<cspmb__Add_On_Price_Item__c> addOnList = new List<cspmb__Add_On_Price_Item__c> {testAddon};
        //EDGE-166406 Start
    cspmb__Add_On_Price_Item__c IRMonthPass = new cspmb__Add_On_Price_Item__c();
        IRMonthPass.Name = 'international roaming month pass';
        IRMonthPass.ProdSpecId__c='DMCAT_ProductSpecification_001196';
        IRMonthPass.cspmb__Recurring_Charge__c = 60;
    IRMonthPass.Billing_Description__c = 'international roaming month pass';
    IRMonthPass.taxTreatment__c = 'TAX Exempt';
    addOnList.add(IRMonthPass);
    cspmb__Add_On_Price_Item__c standard = new cspmb__Add_On_Price_Item__c();
        standard.Name = 'standard';
        standard.ProdSpecId__c='DMCAT_RecurringCharge_001277';
        standard.cspmb__Recurring_Charge__c = 0.00;
    standard.Billing_Description__c = 'business demand data - standard';
    standard.taxTreatment__c = 'TAX Exempt';
    addOnList.add(standard);
    cspmb__Add_On_Price_Item__c Small = new cspmb__Add_On_Price_Item__c();
        Small.Name = 'Small';
        Small.Charge_Id__c='DMCAT_NonRecurringCharge_001273';
        Small.ProdSpecId__c = 'DMCAT_ProductSpecification_001158';
        Small.cspmb__Recurring_Charge__c = 0.00;
    Small.Billing_Description__c = 'Enterprise Wireless data top-up - small';
    Small.taxTreatment__c = 'TAX Exempt';
    addOnList.add(Small);
    cspmb__Add_On_Price_Item__c unshapeUser = new cspmb__Add_On_Price_Item__c();
        unshapeUser.Name = 'standard';
        unshapeUser.ProdSpecId__c='DMCAT_ProductSpecification_0011587';
        unshapeUser.Charge_Id__c = 'DMCAT_NonRecurringCharge_001274';
    unshapeUser.Billing_Description__c = 'User data top-up';
    unshapeUser.taxTreatment__c = 'TAX Exempt';
    addOnList.add(unshapeUser);
    cspmb__Add_On_Price_Item__c dataFeatures = new cspmb__Add_On_Price_Item__c();
        dataFeatures.Name = 'standard';
        dataFeatures.ProdSpecId__c='DMCAT_ProductSpecification_0011581';
        dataFeatures.Charge_Id__c = 'DMCAT_NonRecurringCharge_001273';
    dataFeatures.Billing_Description__c = 'Data Features';
    dataFeatures.taxTreatment__c = 'TAX Exempt';
    addOnList.add(dataFeatures);
    //EDGE-166406 End
    //EDGE-176737 Start
    cspmb__Add_On_Price_Item__c addOnPriceItem06 = new cspmb__Add_On_Price_Item__c();
        addOnPriceItem06.Name = 'international roaming month pass';
        addOnPriceItem06.ProdSpecId__c='DMCAT_ProductSpecification_001196';
        addOnPriceItem06.cspmb__Recurring_Charge__c = 60;
    addOnPriceItem06.Billing_Description__c = 'international roaming month pass_neg';
    addOnPriceItem06.taxTreatment__c = 'GST Applicable';
    addOnList.add(addOnPriceItem06);
    //EDGE-176737 End
            insert addOnList;
        system.debug('addOnList: '+addOnList);
        //EDGE-148776 - End  
        //EDGE-165326 Start
        List<cspmb__Price_Item__c> listNGEMplan= new List<cspmb__Price_Item__c>();//EDGE-181997- Code Changes
        cspmb__Price_Item__c testPriceItemNGEMPlan = new cspmb__Price_Item__c();
        testPriceItemNGEMPlan.Name = 'PaymentTypeLookup'; //or will it be Enterprise Mobility
        testPriceItemNGEMPlan.cspmb__Recurring_Charge__c = 45;
        testPriceItemNGEMPlan.Billing_Description__c='Mobile Enhanced Plan';
        testPriceItemNGEMPlan.Unit_Of_Measure__c='per Mobility Plan';
        insert testPriceItemNGEMPlan;

        //EDGE-181997- Code Change Start
        cspmb__Price_Item__c testPriceItemNGEMPlanwireless = new cspmb__Price_Item__c();
        testPriceItemNGEMPlanwireless.Name = 'PaymentTypeLookup'; //or will it be Enterprise Mobility
        testPriceItemNGEMPlanwireless.cspmb__Recurring_Charge__c = 45;
        testPriceItemNGEMPlanwireless.Billing_Description__c='Enterprise Wireless Epic Plan';
        testPriceItemNGEMPlanwireless.Unit_Of_Measure__c='per Mobility Plan';
        listNGEMplan.add(testPriceItemNGEMPlanwireless);
        cspmb__Price_Item__c testPriceItemNGEMPlanbb = new cspmb__Price_Item__c();
        testPriceItemNGEMPlanbb.Name = 'PaymentTypeLookup'; //or will it be Enterprise Mobility
        testPriceItemNGEMPlanbb.cspmb__Recurring_Charge__c = 45;
        testPriceItemNGEMPlanbb.Billing_Description__c='Mobile Broadband Essential Plan';
        testPriceItemNGEMPlanbb.Unit_Of_Measure__c='per Mobility Plan';
        listNGEMplan.add(testPriceItemNGEMPlanbb);
        insert listNGEMplan;
        //EDGE-181997- Code Change End

        //EDGE-165326 END
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[0].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[1].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[0].Id,
            Name = 'PaymentTypeLookup',
            cscfga__Value__c = PIList[3].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );//EDGE-181997- Code Change
        attList.add(att3);
        cscfga__Attribute__c att4 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[1].Id,
            Name = 'PaymentTypeLookup',
            cscfga__Value__c = PIList[1].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att4);
        //EDGE-148776 - Start  
        cscfga__Attribute__c att5 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[4].Id,
            Name = 'DeviceCarePaymentTypeLookup',
            cscfga__Value__c = addOnList[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );
        attList.add(att5);
        cscfga__Attribute__c att6 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[4].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );
        attList.add(att6);      
        //EDGE-148776 - End
        //EDGE-148722 - Start
        cscfga__Attribute__c att7 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[5].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att7); 
        cscfga__Attribute__c att8 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[5].Id,
            Name = 'PaymentTypeLookup',
            cscfga__Value__c = PIList[1].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att8); 
        cscfga__Attribute__c att9 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[5].Id,
            Name = 'RemainingTerm',
            cscfga__Value__c = '8',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att9); 
        cscfga__Attribute__c att10 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[5].Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att10);
        cscfga__Attribute__c att11 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[1].Id,
            Name = 'RC',
            cscfga__Value__c = '120',
            //EDGE-176688 - Start
            cscfga__Price__c = 120.00,
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = true,
            cscfga__Is_rate_line_item__c = false,
            //EDGE-176688 - End
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att11);
        //EDGE-148722 - End 
        //EDGE-165326 Start
        cscfga__Attribute__c att12 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[7].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Mobile Broadband',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att12);
        cscfga__Attribute__c att13 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[6].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Enterprise Wireless',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att13);
        cscfga__Attribute__c att14 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[8].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Handheld',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att14);
        cscfga__Attribute__c att15 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[8].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlan.id,
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );        
        attList.add(att15);
        cscfga__Attribute__c att16 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[10].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Handheld',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att16);
        cscfga__Attribute__c att17 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[10].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlan.id,
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );        
        attList.add(att17);
        //EDGE-165326 END
        //EDGE-155059 & EDGE-162542 Start
         cscfga__Attribute__c att18 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[1].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att18);
        cscfga__Attribute__c att19 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[0].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att19);
        cscfga__Attribute__c att20 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[12].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Handheld',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att20);
        cscfga__Attribute__c att21 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[14].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Enterprise Wireless',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att21);
        cscfga__Attribute__c att22 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[16].Id,
            Name = 'PlanTypeString',
            cscfga__Value__c = 'Mobile Broadband',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );         
        attList.add(att22);
        cscfga__Attribute__c att23 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[11].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true
           // cscfga__Attribute_Definition__c = attDefList[0].Id
        );
         attList.add(att23);
         cscfga__Attribute__c att24 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[11].Id,

            Name = 'RedeemFundCopy',
            cscfga__Value__c = '100',
            cscfga__is_active__c = true
           // cscfga__Attribute_Definition__c = attDefList[0].Id
        );//EDGE-181997- Code Changes

         attList.add(att24);
        cscfga__Attribute__c att25 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[18].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true
           // cscfga__Attribute_Definition__c = attDefList[0].Id
        );
         attList.add(att25);
         cscfga__Attribute__c att26 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[18].Id,

            Name = 'RedeemFundCopy',
            cscfga__Value__c = '100',
            cscfga__is_active__c = true
           // cscfga__Attribute_Definition__c = attDefList[0].Id
        );//EDGE-181997- Code Changes

         attList.add(att26);
        cscfga__Attribute__c att27 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[11].Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att27);
        cscfga__Attribute__c att28 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[18].Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att28);
        //EDGE-164623 Start
        cscfga__Attribute__c att29 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[19].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '100',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att29);
        cscfga__Attribute__c att30 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[19].Id,
            Name = 'OC',
            cscfga__Value__c = '190',
            cscfga__Price__c = 190,
            //EDGE-176688 - Start
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = false,
            cscfga__Is_rate_line_item__c = false,
            //EDGE-176688 - End
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att30); 
        cscfga__Attribute__c att31 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[19].Id,
            Name = 'RedeemFundCopy',
            cscfga__Value__c = '100',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att31);
        cscfga__Attribute__c att32 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[20].Id,
            Name = 'OC',
            cscfga__Value__c = '190',
            cscfga__Price__c = 190,
            //EDGE-176688 - Start
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = false,
            cscfga__Is_rate_line_item__c = false,
            //EDGE-176688 - End
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att32); 
        cscfga__Attribute__c att33 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[20].Id,
            Name = 'RedeemFundCopy',
            cscfga__Value__c = '100',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att33);
         //EDGE-164623 End 
        //EDGE-155059 & EDGE-162542 End
    //EDGE-166406 Start
    cscfga__Attribute__c att34 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[21].Id,
            Name = 'IR_MonthPass',
            cscfga__Value__c = addOnList[1].id,
            cscfga__is_active__c = true
        );
        attList.add(att34);
    cscfga__Attribute__c att35 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[21].Id,
        Name = 'PlanTypeString',
        cscfga__Value__c = 'Enterprise Wireless',
        cscfga__is_active__c = true
        );  
    attList.add(att35);
    cscfga__Attribute__c att36 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,
            Name = 'IR_MonthPass',
            cscfga__Value__c = addOnList[1].id,
            cscfga__is_active__c = true
        );
        attList.add(att36);
    cscfga__Attribute__c att37 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[22].Id,
        Name = 'PlanTypeString',
        cscfga__Value__c = 'Enterprise Wireless',
        cscfga__is_active__c = true
        );  
    attList.add(att37);
    cscfga__Attribute__c att38 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[23].Id,
        Name = 'BDDChargeLookup',
        cscfga__Value__c = addOnList[2].id,
        cscfga__is_active__c = true
        );  
    attList.add(att38);
    cscfga__Attribute__c att39 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[24].Id,
        Name = 'BDDChargeLookup',
        cscfga__Value__c = addOnList[2].id,
        cscfga__is_active__c = true
        );  
    attList.add(att39);
    cscfga__Attribute__c att40 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[21].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlan.id,
            cscfga__is_active__c = true
        ); 
    attList.add(att40);    
    cscfga__Attribute__c att41 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlan.id,
            cscfga__is_active__c = true
        ); 
    attList.add(att41);
    cscfga__Attribute__c att42 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[21].Id,
            Name = 'UnshapeUserChargeLookup',
            cscfga__Value__c = addOnList[4].id,
            cscfga__is_active__c = true
        ); 
    attList.add(att42);  
    cscfga__Attribute__c att43 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[23].Id,
            Name = 'ADTChargeLookup',
            cscfga__Value__c = addOnList[3].id,
            cscfga__is_active__c = true
        ); 
    attList.add(att43);  
    cscfga__Attribute__c att44 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[24].Id,
        Name = 'Data Features',
        cscfga__Value__c = addOnList[5].id,
        cscfga__is_active__c = true
         ); 
        attList.add(att44);
    //EDGE-166406 End
    //EDGE-165486 Changes Start
    cscfga__Attribute__c att45 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[25].Id,
            Name = 'RC',
            cscfga__Value__c = '120',
            //EDGE-176688 - Start
            cscfga__Price__c = 120.00,
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = true,
            cscfga__Is_rate_line_item__c = false,
            //EDGE-176688 - End
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att45);
        cscfga__Attribute__c att46 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[25].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att46);

    /*cscfga__Attribute__c att47 = new cscfga__Attribute__c(

            cscfga__Product_Configuration__c = prodConfigList[25].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id

        );//EDGE-181997- Code Changes
        attList.add(att47);*/

        cscfga__Attribute__c att48 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[26].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att48);
        cscfga__Attribute__c att49 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[26].Id,
            Name = 'PaymentTypeLookup',

            cscfga__Value__c = PIList[3].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );//EDGE-181997- Code Changes

        attList.add(att49);
        cscfga__Attribute__c att50 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[26].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att50);
         cscfga__Attribute__c att51 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[27].Id,
            Name = 'DeviceCarePaymentTypeLookup',
            cscfga__Value__c = addOnList[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );
        attList.add(att51);
        cscfga__Attribute__c att52 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[27].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );
        attList.add(att52);
        cscfga__Attribute__c att53 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[28].Id,
            Name = 'RC',
            cscfga__Value__c = '120',
            //EDGE-176688 - Start
            cscfga__Price__c = 120.00,
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = true,
            cscfga__Is_rate_line_item__c = false,
            //EDGE-176688 - End
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att53);
        cscfga__Attribute__c att54 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[28].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att54);
    cscfga__Attribute__c att55 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[28].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att55);
        cscfga__Attribute__c att56 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[29].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att56);
        cscfga__Attribute__c att57 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[29].Id,
            Name = 'PaymentTypeLookup',

            cscfga__Value__c = PIList[2].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );//EDGE-181997- Code Changes

        attList.add(att57);
        cscfga__Attribute__c att58 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[29].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att58);

        //EDGE-181997- Code Change Start
        cscfga__Attribute__c att59 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[14].Id,
            Name = 'Select Plan',
            cscfga__Value__c = listNGEMplan[0].id,
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );        
        attList.add(att59);
        cscfga__Attribute__c att60 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[16].Id,
            Name = 'Select Plan',
            cscfga__Value__c = listNGEMplan[1].id,
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );        
        attList.add(att60);
        cscfga__Attribute__c att61 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[12].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlan.id,
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[2].Id
        );        
        attList.add(att61);
        cscfga__Attribute__c att62 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[28].Id,
            Name = 'PaymentTypeLookup',
            cscfga__Value__c = PIList[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att62);
        cscfga__Attribute__c att63 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[6].Id,
            Name = 'Select Plan',
            cscfga__Value__c = listNGEMplan[0].id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att63);
        cscfga__Attribute__c att64 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[7].Id,
            Name = 'Select Plan',
            cscfga__Value__c = listNGEMplan[1].id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att64);
        cscfga__Attribute__c att65 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[11].Id,
            Name = 'PaymentTypeLookup',
            cscfga__Value__c = PIList[3].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att65);
        cscfga__Attribute__c att66 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[18].Id,
            Name = 'PaymentTypeLookup',
            cscfga__Value__c = PIList[3].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[1].Id
        );
        attList.add(att66);
        cscfga__Attribute__c att67 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[11].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '',
            cscfga__is_active__c = true
           // cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att67);
        cscfga__Attribute__c att68 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[18].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '',
            cscfga__is_active__c = true
           // cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att68);
        cscfga__Attribute__c att69 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[30].Id,
            Name = 'DeviceCarePaymentTypeLookup',
            cscfga__Value__c = addOnList[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );
        attList.add(att69);
        cscfga__Attribute__c att70 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[30].Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[2].Id
        );
        attList.add(att70);
        //EDGE-181997- Code Change End

        //EDGE-165486 Changes End
        //EDGE-176737 Start
        cscfga__Attribute__c att71 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[31].Id,
        Name = 'PlanTypeString',
        cscfga__Value__c = 'Enterprise Wireless',
        cscfga__is_active__c = true
        );  
        attList.add(att71);
        cscfga__Attribute__c att72 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[31].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlanwireless.id,
            cscfga__is_active__c = true
        ); 
        attList.add(att72);
        cscfga__Attribute__c att73 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[32].Id,
        Name = 'IR_MonthPass',
        cscfga__Value__c = addOnList[1].id,
        cscfga__is_active__c = true
        );
        attList.add(att73);
        cscfga__Attribute__c att74 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[33].Id,
        Name = 'IR_MonthPass',
        cscfga__Value__c = addOnList[6].id,
        cscfga__is_active__c = true
        );
        attList.add(att74);
        cscfga__Attribute__c att75 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[34].Id,
        Name = 'IR_MonthPass',
        cscfga__Value__c = addOnList[1].id,
        cscfga__is_active__c = true
        );
        attList.add(att75);
        //EDGE-176737 End
        //EDGE-185762 Start
        cscfga__Attribute__c att76 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[35].Id,
        Name = 'PlanTypeString',
        cscfga__Value__c = 'Enterprise Wireless',
        cscfga__is_active__c = true
        );  
        attList.add(att76);
        cscfga__Attribute__c att77 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[35].Id,
            Name = 'Select Plan',
            cscfga__Value__c = testPriceItemNGEMPlanwireless.id,
            cscfga__is_active__c = true
        ); 
        attList.add(att77);
        cscfga__Attribute__c att78 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[36].Id,
        Name = 'IR_MonthPass',
        cscfga__Value__c = addOnList[1].id,
        cscfga__is_active__c = true
        );
        attList.add(att78);
        cscfga__Attribute__c att79 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[37].Id,
        Name = 'IR_MonthPass',
        cscfga__Value__c = addOnList[6].id,
        cscfga__is_active__c = true
        );
        attList.add(att79);
        //EDGE-185762 End
    //
    //
    
        cscfga__Attribute__c att80 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[38].Id,
            Name = 'RC',
            cscfga__Value__c = '120',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att80);
        cscfga__Attribute__c att81 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[38].Id,
            Name = 'PaymentTypeShadow',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att81);
      cscfga__Attribute__c att82 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[38].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att82);
        
        //DPG-3508- start
        cscfga__Attribute__c att83 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[38].Id,
            Name = 'PaymentTypeShadow',
            cscfga__Value__c = 'Hardware Repayment',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[3].Id
        );
        attList.add(att83);
        cscfga__Attribute__c att84 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[38].Id,
            Name = 'ContractTermShadow',
            cscfga__Value__c = '12',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[3].Id
        );
        attList.add(att84);
        cscfga__Attribute__c att85 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[39].Id,
            Name = 'PaymentTypeShadow',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[3].Id
        );
        attList.add(att85);
        cscfga__Attribute__c att86 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[39].Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '75',
            cscfga__is_active__c = true
            //cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att86);
        //DPG-3508- END
        
        insert attList;
        system.debug('attList: '+attList);
        System.debug('prodConfigList: ' + prodConfigList);
        System.debug('prodConfigList:[19] ' + prodConfigList[19]);
        //test to fetch fields
        //cscfga__Attribute__c att181 = new cscfga__Attribute__c();
    }
    //EDGE-155059 & EDGE-162542 Positive Scenario
    @isTest static void getNGEMDevicesNewTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Boolean deviceCareFoundRC = false;
        Boolean deviceCareFoundOC = false;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler = new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceRC','Type'=>'New'});
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceOC','Type'=>'New'});
        System.debug('-----rows'+rows.isEmpty());
        System.debug('-----rows'+rows);
        System.debug('-----rows1'+rows1);
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assert(rows1.isEmpty() == false);
        /*
        system.assert(rows[0].get('Product_Module_Name') =='APPLE IPHONE 11 128GB 4GX RED <sup>#</sup>');//EDGE-155059 & EDGE-162542////EDGE-181997- Assert Change //EDGE-196119
        system.assert(String.valueof(rows[0].get('Quantity'))=='2' );//EDGE-165486 Assert
        //system.assert(String.valueof(rows1[0].get('Quantity'))=='2');//EDGE-165486 Assert
        //system.assert(rows1[0].get('Product_Module_Name') =='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE GREY <sup>#</sup>');//EDGE-181997- Assert comment
        system.assert(rows1[0].get('Product_Module_Name') =='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE <sup>#</sup>');//EDGE-181997- Assert change
        system.assert(rows[0].get('Discount_Text') =='$ 120 ex GST  per month over 36 months'); //EDGE-184433

        system.assert(rows[0].get('Rate') =='120'); //EDGE-148722 - To check values are coming from RC attribute
        */
        //EDGE-164623 - Start
        for(Map<String,Object> finalRow: rows){
            if(finalRow.get('Product_Module_Name') =='Mobile Device Care Purchase')
            deviceCareFoundRC = true;  
        }
        for(Map<String,Object> finalRow: rows1){
            if(finalRow.get('Product_Module_Name') =='AppleCare+ Purchase')  
            deviceCareFoundOC = true;  
        }
        system.debug('valueofdeviceCareFoundRC'+deviceCareFoundRC);
        system.debug('valueofdeviceCareFoundOC'+deviceCareFoundOC);
        system.assert(deviceCareFoundRC != true); //Excluding Device Care for New RC// Opposite the condition 
        system.assert(deviceCareFoundOC != true); 
        //EDGE-164623 | End
        system.assert(rows[0].get('Discount_Text') == '$ 120 ex GST  per month over 36 months'); //EDGE-183882 //EDGE-176688 - Price fetched from PC field
        system.assert(rows1[0].get('Discount_Text') == '$ 0.00 ex GST per device'); //EDGE-183882 //EDGE-176688 - Prices will not be fetched from Commercial Product

    }
    //EDGE-148776 - Start 
    //EDGE-165486 Negative Test Method Start here
    @isTest static void getNGEMDevicesNewTestNegative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Boolean deviceCareFoundRC = false;
        Boolean deviceCareFoundOC = false;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 9999 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler = new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceRC','Type'=>'New'});
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceOC','Type'=>'New'});
        System.debug('-----rows'+rows.isEmpty());
        System.debug('-----rows'+rows);
        System.debug('-----rows1'+rows1);
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assert(rows1.isEmpty() == false);

        system.assert(rows[0].get('Product_Module_Name') =='APPLE IPHONE 10 128GB 4GX RED <sup>#</sup>');//EDGE-155059 & EDGE-162542//EDGE-181997- Assert change //EDGE-196119

        system.assert(String.valueof(rows[0].get('Quantity'))=='1' );//EDGE-165486 Assert
        system.assert(String.valueof(rows1[0].get('Quantity'))=='1');//EDGE-165486 Assert
        system.assert(rows1[0].get('Product_Module_Name') =='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE GREY <sup>#</sup>');
        //system.assert(rows[0].get('Rate') =='120'); //EDGE-148722 - To check values are coming from RC attribute
    }
    //EDGE-165486 Negative Test Method Start here
    @isTest static void getNGEMDeviceCareTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler = new NGEMDataHandler();
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceOC','Type'=>'New'});
        System.debug('-----rows1'+rows1);
        //stem.debug('-----rows1'+rows1[0);
        Test.stopTest();
        System.assert(rows1.isEmpty() == false);
        system.assert(rows1[0].get('Discount_Text') =='$ 0.00 ex GST per device'); //EDGE-183882 //EDGE-176688 - Prices will not be fetched from Commercial Product

        //system.assert(rows1[0].get('Product_Module_Name') =='AppleCare+ Purchase');
    }
    //EDGE-148776 - End
    //EDGE-148722 - Start | NGEM Cancellation
    @isTest static void getNGEMDeviceCancelTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler = new NGEMDataHandler();
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceRC','Type'=>'Cancel'});
        System.debug('-----rows1'+rows1);
        Test.stopTest();
        System.assert(rows1.isEmpty() == false);
        system.assert(rows1[1].get('Product_Module_Name') =='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE');//EDGE-181997- Assert change
    }
    //EDGE-148722 - End
    //Negative scenario for EDGE-148776 & EDGE-148722 is covered as part of below method
    @isTest static void getNGEMDevicesTestFailure(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMDevices(null,null);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
    //EDGE-165326 Start
    @isTest static void getNGEMPlansTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows1 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLS','Type'=>'New'});
        List<Map<String,Object>> rows2 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanMBB','Type'=>'New'});
        List<Map<String,Object>> rows3 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanHH','Type'=>'New'});
        System.assert(rows1.isEmpty() == false);
        System.assert(rows2.isEmpty() == false);
       // System.assert(rows3.isEmpty() == false);
        //EDGE-181997- Assert change
        system.debug('rows1-->'+rows1);
        System.assert(rows1[0].get('Discount_Text') =='$ 0.00 ex GST per Mobility Plan'); //EDGE-183882 //EDGE-176688 - Prices will not be fetched from Commercial Product
        System.assert(rows1[0].get('Product_Module_Name') =='Enterprise Wireless Epic Plan'); //EDGE-196119
        System.assert(rows2[0].get('Product_Module_Name') =='Mobile Broadband Essential Plan'); //EDGE-196119
        //System.assert(rows3[0].get('Product_Module_Name') =='Mobile Enhanced Plan'); //EDGE-196119

        //EDGE-181997- Assert change
        Test.stopTest();
    }
    @isTest static void getNGEMPlansTestNegative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMNegative','Type'=>'Cancel'});
        //System.debug('-----getNGEMPlans rows: Negative check: '+rows.isEmpty());
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
    @isTest static void getNGEMPlansMACTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanHHMAC','Type'=>'Modify'});
        //System.assert(rows.isEmpty() == false);
        //System.assert(rows[0].get('Product_Module_Name') =='Handheld-Enterprise Mid');
        //System.assert(rows[0].get('Product_Module_Name') =='Mobile Enhanced Plan');//EDGE-181997- Assert change //EDGE-196119
        Test.stopTest();
    }

    @isTest static void getNGEMPlansTestMACNegative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMNegative','Type'=>'Cancel'});
        //System.debug('-----getNGEMPlans rows: Negative check: '+rows.isEmpty());
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
    //EDGE-165326 END
    //EDGE-155059 & EDGE-162542 Start
    //EDGE-155059 & EDGE-162542  Positive
    @isTest static void getNGEMPlansCancelTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows1 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLSCancel','Type'=>'Cancel'});
        List<Map<String,Object>> rows2 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanMBBCancel','Type'=>'Cancel'});
        List<Map<String,Object>> rows3 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanHHCancel','Type'=>'Cancel'});
        Test.stopTest();
        system.debug('rows1@@::' + rows1);
        system.debug('rows2@@::' + rows2);
        system.debug('rows3@@::' + rows3);
        System.assert(rows1.isEmpty() == false);
        System.assert(rows2.isEmpty() == false);
        //System.assert(rows3.isEmpty() == false);

        //EDGE-181997- Assert change Start
        System.assert(rows1[0].get('Product_Module_Name') =='Enterprise Wireless Epic Plan'); //EDGE-196119
        System.assert(rows2[0].get('Product_Module_Name') =='Mobile Broadband Essential Plan'); //EDGE-196119
        //System.assert(rows3[0].get('Product_Module_Name') =='Mobile Enhanced Plan'); //EDGE-196119
        //EDGE-181997- Assert change stop

    }
    //EDGE-155059 & EDGE-162542 Negative
    @isTest static void getNGEMPlansCancelTest_Negative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(null,null);
        Test.stopTest();
        system.debug('rows1@@::' + rows);
        System.assert(rows.isEmpty() == true);
    }
    //EDGE-155059 & EDGE-162542 End
    //EDGE-164623
    @isTest static void appleCarePlusCancelTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
        basketId = prodBasket.id;

        //EDGE-181997- Code Change Start
        cscfga__Product_Basket__c prodBasket1 = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 9999 limit 1];
        String basketId1 = '';
        if(prodBasket1 !=null)
            basketId1 = prodBasket1.id;
        //EDGE-181997- Code Change Start
        NGEMDataHandler handler= new NGEMDataHandler(); 
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceRC','Type'=>'Cancel'});
        List<Map<String,Object>> rows2 = handler.getNGEMDevices(basketId1,new Map<String,String>{'Query_Type'=>'NGEMDeviceOC','Type'=>'Cancel'});//EDGE-181997- Code Change
        Test.stopTest();
        system.debug('rows1@@::' + rows1);
        system.debug('rows2@@::' + rows1);
        System.assert(rows1.isEmpty() == false);
        System.assert(rows1[1].get('Product_Module_Name') =='GOOGLE PIXEL 3 XL 64GB 4GX HANDSET WHITE');//EDGE-181997- Assert change //EDGE-196119
        System.assert(rows1[1].get('Quantity') ==2); //Checking Aggregation Logic

    }
    @isTest static void appleCarePlusCancelTest_Negative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];    
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceRCY','Type'=>'Cancel123'});
        Test.stopTest();
        system.debug('rows1@@::' + rows1);
        System.assert(rows1.isEmpty() == true);
    } 
    //EDGE-164623 End 
    //EDGE-166406 Start
    @isTest static void getNGEMPlansBoltOnTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Object qtyBoltOn;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 9999];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLS','Type'=>'New'});
         Test.stopTest();
        System.assert(rows.isEmpty() == false);
        for(Map<String,Object> finalRow: rows){
            system.debug('getNGEMPlansBoltOnTest::rows::' + finalRow.get('Product_Module_Name'));
            if(finalRow.get('Product_Module_Name') =='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;business demand data - standard <sup>†</sup>')
                qtyBoltOn = finalRow.get('Quantity');
        }
       System.assert(qtyBoltOn ==2);
    }
    @isTest static void getNGEMPlansBoltOnTest_Negative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Boolean boltOnFound = false;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 9999];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLS','Type'=>'New'});
         Test.stopTest();
        System.assert(rows.isEmpty() == false);
        for(Map<String,Object> finalRow: rows){
            system.debug('getNGEMPlansBoltOnTest::rows::' + finalRow.get('Product_Module_Name'));
            if(finalRow.get('Product_Module_Name') =='Data Features')
                boltOnFound = true;
        }
       System.assert(boltOnFound ==false);
    }
    //EDGE-166406 End
    //EDGE-176737 Start
    @isTest static void getNGEMIRBoltOn(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Boolean boltOnFound = false;
        Object aggrQtyIR;
        Object noAggrQtyIR;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 9922];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLS','Type'=>'New'});
        Test.stopTest();
        system.debug('rows::' + rows);
        System.assert(rows.isEmpty() == false);
        for(Map<String,Object> finalRow: rows){
            system.debug('getNGEMIRBoltOn::rows::' + finalRow.get('Product_Module_Name'));
            if(finalRow.get('Product_Module_Name') =='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;international roaming month pass <sup>†</sup>')
                aggrQtyIR = finalRow.get('Quantity');
            if(finalRow.get('Product_Module_Name') =='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;international roaming month pass_neg')
                noAggrQtyIR = finalRow.get('Quantity');

        }
        System.assert(aggrQtyIR ==2);//EDGE-176737 Positive
        System.assert(noAggrQtyIR ==1);//EDGE-176737 Negative
        
    }
    //EDGE-176737 End
    //EDGE-185762 Start
    @isTest static void getNGEMIRBoltOnModify(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Boolean boltOnFound = false;
        Object newQtyIR;
        Object macQtyIR;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 9922];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLSMAC','Type'=>'Modify'});
        Test.stopTest();
        system.debug('rows::' + rows);
        //System.assert(rows.isEmpty() == false);
        for(Map<String,Object> finalRow: rows){
            system.debug('getNGEMIRBoltOn::rows::' + finalRow.get('Product_Module_Name'));
            if(finalRow.get('Product_Module_Name') =='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;international roaming month pass <sup>†</sup>')
                newQtyIR = finalRow.get('Quantity');
            if(finalRow.get('Product_Module_Name') =='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;international roaming month pass_neg')
                macQtyIR = finalRow.get('Quantity');

        }
       
        system.debug('newQtyIR@@::' + newQtyIR);
        system.debug('macQtyIR@@::' + macQtyIR);
        System.assert(newQtyIR ==1);//EDGE-185762 Positive
        System.assert(macQtyIR ==1);//EDGE-185762 Negative
        
        
    }
    //EDGE-185762 End
  
    //DPG-3508 - Start //EDGE-199301 - DPG Code Coverage
    @isTest static void getAMAccessoryNewTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Boolean deviceCareFoundRC = false;
        Boolean deviceCareFoundOC = false;
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        NGEMDataHandler handler = new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getAMAccessory(basketId,new Map<String,String>{'Query_Type'=>'AMaccessoryOC','Type'=>'New'});
        List<Map<String,Object>> rows1 = handler.getAMAccessory(basketId,new Map<String,String>{'Query_Type'=>'AMaccessoryRC','Type'=>'New'});
        System.debug('-----rows'+rows.isEmpty());        
        System.debug('-----rows1'+rows1);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);

        System.assert(rows1.isEmpty() == false);       

        
    }
    @isTest static void getDeviceAccessoryMobilityTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();        
        testclass.setup();   
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        Map<string,Map<String, String>> filters= new Map<string,Map<String, String>>();
        Map<String,String> subFil = new Map<String,String>();
        subFil.put('Query_Type','NGEMDeviceRC');
        subFil.put('Type','New');
        filters.put('NGEMDevice',subFil);               
        Map<string, string> subFil1= new Map<string, string>();
        subFil1.put('Query_Type','AMaccessoryRC');
        subFil1.put('Type','New');
        filters.put('AMaccessory',subFil1);
        Map<String,String> subFil2 = new Map<String,String>();
        subFil2.put('Query_Type','NGEMDeviceRC');
        subFil2.put('Type','New');
        filters.put('NGEMDevice',subFil2);              
        Map<string, string> subFil3= new Map<string, string>();
        subFil3.put('Query_Type','AMaccessoryRC');
        subFil3.put('Type','New');
        filters.put('AMaccessory',subFil3);
        NGEMDataHandler ngemHandler= new NGEMDataHandler();
        List<Map<String,Object>>  finalRows=ngemHandler.getDeviceAccessoryMobility(basketId,filters); 
        system.debug(finalRows.size()+' '+finalRows);
        Test.stopTest();
        system.assert(finalRows.size()>0); //EDGE-183882
    }
    //DPG-3508 - End //EDGE-199301 - Alexandria Code Coverage
    @isTest static void getNGEMPlansTestReact_Negative(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        list<cscfga__Product_Configuration__c> lstPCs = [select id,subType__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId];
        for(cscfga__Product_Configuration__c pc :lstPCs){
            pc.subType__c = '';
        }
        update lstPCs;
        NGEMDataHandler handler= new NGEMDataHandler();
        List<Map<String,Object>> rows1 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanWLS','Type'=>'Reactivate'});
        List<Map<String,Object>> rows2 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanMBB','Type'=>'Reactivate'});
        List<Map<String,Object>> rows3 = handler.getNGEMPlans(basketId,new Map<String,String>{'Query_Type'=>'NGEMPlanHH','Type'=>'Reactivate'});
        System.assert(rows1.isEmpty() == true);
        System.assert(rows2.isEmpty() == true);
        System.assert(rows3.isEmpty() == true);
        Test.stopTest();
    }
    //EDGE-188100 End   
    //EDGE-171311 Start //EDGE-199301 - Alexandria Code Coverage
    @isTest static void getNGEMDevicesInflightTest(){
        NGEMDataHandlerTest testclass= new NGEMDataHandlerTest();
        testclass.setup();      
        Test.startTest();
        list<recordtype> recType = [select id from recordtype where sObjectType = 'cscfga__Product_Basket__c' and developername = 'Inflight_Change'];
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null){
            basketId = prodBasket.id;
            prodBasket.recordtypeId = recType[0].Id;
            update prodBasket;
            list<cscfga__Product_Configuration__c> pcLst = [select id, subType__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId];
            for(cscfga__Product_Configuration__c pc:pcLst){
                pc.subType__c='Inflight Cancel';                
            }
            update pcLst;
        }
        NGEMDataHandler handler = new NGEMDataHandler();
        List<Map<String,Object>> rows = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceRCIC','Type'=>'Cancel'});
        List<Map<String,Object>> rows1 = handler.getNGEMDevices(basketId,new Map<String,String>{'Query_Type'=>'NGEMDeviceOCIC','Type'=>'Cancel'});
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assert(rows1.isEmpty() == false);
    } 
    //EDGE-171311 End
        
}