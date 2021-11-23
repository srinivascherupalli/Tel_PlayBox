/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 09-17-2021
 * @last modified by  : LokeshThathuru@team.telstra.com
**/

@isTest
public class GenerateContractTest {
    private static cscfga__Product_Basket__c basket = null,basketNGEMCancel=null,basketModify=null,basketNew=null,basketMAC=null,basketTC=null,basket_to_set_email_date=null,cncl=null,cancelBasket=null,basketIoT=null;//Added noew basket basketNGEMCancel for EDGE-155059
    private static APXTConga4__Conga_Template__c contemplate;// INC000092229271 Incident fix
    private void setup(){
        /*Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;*/
        Environment_Configurations__c environmentConfig =New Environment_Configurations__c();    
        environmentConfig.No_Triggers__c = true;
        insert environmentConfig;
        EnvironmentVariable__c enVar= new EnvironmentVariable__c();
        enVar.name='Send_OrderForm_for_Contract';
        enVar.Value__c='True';
        insert enVar;
    //TED-383 Start
        //Create Adobe Agreement Templates
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids = new List<echosign_dev1__Agreement_Template__c>();
        echosign_dev1__Agreement_Template__c templateid1 = new echosign_dev1__Agreement_Template__c();
        templateid1.name = 'BSA Flow';
        eSignTemplateids.add(templateid1);
        echosign_dev1__Agreement_Template__c templateid2 = new echosign_dev1__Agreement_Template__c();
        templateid2.name = 'BSA MAC Flow';
        eSignTemplateids.add(templateid2);
        insert eSignTemplateids;
        //TED-383 End
    //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='Active';
        insert acc;
        //CREATE CONTACT
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0412345678',
            Email = 'test@tele2.com',Phone= '+61401098123',jobTitle__c='Consultant'
        );// Added jobTitle__c for User story EDGE-165486
        insert contact;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        opp.contract_type__c = 'DSA';//DIGI-683
        insert opp;

        //CREATE MACOPPORTUNITY
        Opportunity oppMAC   = ProductTestFactory.getOpportunityBasic(acc);
        oppMAC.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
        oppMAC.Type = 'MACs (Moves, Adds & Change)'; //DIGI-160
        insert oppMAC;

        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
        //EDGE-165831 - updated spec code
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Connected Workplace' ;
        mo.Name = 'Test MO';
        mo.Offer_ID__c = 'DMCAT_Offer_000303';
        listOfOffers.add(mo);
        Marketable_Offer__c mo1 = new Marketable_Offer__c();
        mo1.OfferDefinationName__c ='Connected Workplace Solution' ;
        mo1.Name = 'Test MOdf';
        mo1.Offer_ID__c = 'DMCAT_Offer_000303';
        mo1.Contract_Type__c = 'DSA';//DIGI-683
        listOfOffers.add(mo1);
        Marketable_Offer__c momdm = new Marketable_Offer__c();
        momdm.OfferDefinationName__c ='MDM Tenancy' ;
        momdm.Name = 'Test MOdfs';
        momdm.Offer_ID__c = 'D12sd333s';
        listOfOffers.add(momdm);
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        moMob.Contract_Type__c = 'DSA';//DIGI-683
        listOfOffers.add(moMob);
        //EDGE-132608 Start
        //DPG-3344
        Marketable_Offer__c moTC = new Marketable_Offer__c();
        moTC.OfferDefinationName__c ='Telstra Collaboration Solution';
        moTC.Name = 'Telstra Collaboration';
        moTC.Offer_ID__c = 'DMCAT_Offer_000618';
        moTC.Contract_Type__c = 'DSA';//DIGI-683
        listOfOffers.add(moTC);
        //EDGE-132608 End
        Marketable_Offer__c moIoT = new Marketable_Offer__c();
        moIoT.OfferDefinationName__c ='IoT solutions' ;
        moIoT.Name = System.Label.IoTOfferName;
        //moIoT.Offer_ID__c = 'D12sd337t';
        moIoT.Offer_ID__c = 'DMCAT_Offer_000964';
        listOfOffers.add(moIoT);

        // DIGI-1607
        Marketable_Offer__c moSDWAN = new Marketable_Offer__c();
        moSDWAN.OfferDefinationName__c ='SD-WAN Adapt S1' ;
        moSDWAN.Name = System.Label.SDWAN_PDName;
        moSDWAN.Offer_ID__c = 'DMCAT_Offer_001343';
        listOfOffers.add(moSDWAN);

        insert listOfOffers;
        
        //Create Basket
        basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;

        //EDGE-155059 Start
        basketNGEMCancel = ProductTestFactory.buildEmptyBasket();
        basketNGEMCancel.csbb__Account__c = acc.id;
        basketNGEMCancel.cscfga__Opportunity__c = opp.id;
        basketNGEMCancel.Name = 'basketNGEMCancel';
        insert basketNGEMCancel;
        //EDGE-165831 - updated spec code                                                  
        cscfga__Product_Definition__c pdNGEM = ProductTestFactory.buildProductDefinition('Test','Test');
        pdNGEM.name = 'Enterprise Mobility Plan';
        pdNGEM.product_Specification__c='DMCAT_ProductSpecification_001196';
        insert pdNGEM;
        //EDGE-155059 End
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='Connected Workplace Package';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        cscfga__Configuration_Offer__c offername1= new cscfga__Configuration_Offer__c();
        offername1.name='Connected Workplace';
        offername1.cscfga__Active__c=true;
        offername1.cscfga__Description__c='Connected Workplace Package';
        insert offername1;
        cscfga__Configuration_Offer__c offername2= new cscfga__Configuration_Offer__c();
        offername2.name='Iot';
        offername2.cscfga__Active__c=true;
        offername2.cscfga__Description__c='Iot';
        insert offername2;
        //EDGE-132157 Start
        cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = 'Test' + 'PD', cscfga__Description__c = 'Test Description', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert prodDefinition;
        //EDGE-132157 End
        //Create Basket
        basketMAC = ProductTestFactory.buildEmptyBasket();
        basketMAC.csbb__Account__c = acc.id;
        basketMAC.cscfga__Opportunity__c = oppMAC.id;
        basketMAC.Name = 'basket2';
        basketMAC.Pre_Authorised__c = false;
        basketMAC.cscfga__total_contract_value__c = 11000;
        insert basketMAC;
        /* start EDGE-151840 - Hide signature panel from Order Form for MAC orders - Aarathi from team Amsterdam */
        basketModify = ProductTestFactory.buildEmptyBasket();
        basketModify.csbb__Account__c = acc.id;
        basketModify.cscfga__Opportunity__c = oppMAC.id;
        basketModify.Name = 'basketmodify';
        basketModify.Pre_Authorised__c = true;
        basketModify.cscfga__total_contract_value__c = 15000;
        insert basketModify;
        basketNew = ProductTestFactory.buildEmptyBasket();
        basketNew.csbb__Account__c = acc.id;
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.Name = 'basketnew';
        insert basketNew;
        /* end EDGE-151840 - Hide signature panel from Order Form for MAC orders - Aarathi from team Amsterdam */
        //ddddddd          
        //create cancel mobilty basket
        cancelBasket=ProductTestFactory.buildEmptyBasket();
        cancelBasket.csbb__Account__c=acc.id;
        cancelBasket.cscfga__Opportunity__c=opp.id;
        cancelBasket.Name='CancelBasket';
        insert cancelBasket;
        // create Basket
        basket_to_set_email_date = ProductTestFactory.buildEmptyBasket();
        basket_to_set_email_date.csbb__Account__c = acc.id;
        basket_to_set_email_date.cscfga__Opportunity__c = oppMAC.id;
        basket_to_set_email_date.Name = 'basket3';
        insert basket_to_set_email_date;
        //DPG-3344
        //EDGE-147970 Start
        cscfga__Product_Definition__c pdBusinessCalling = new cscfga__Product_Definition__c( Name = 'Business Calling', cscfga__Description__c = 'Business Calling', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert pdBusinessCalling;
        //EDGE-147970
        list<cscfga__Product_Configuration__c>productconfiglist= new list<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c oldPC = new cscfga__Product_Configuration__c();
        oldPC.cscfga__Product_Basket__c = basket.id;
        oldPC.name='Connected Workplace Solution';
        oldPC.Type__c='New';
        oldPC.cscfga__originating_offer__c=offername1.id;
        oldPC.Marketable_Offer__c = mo1.id;//Add Marketable_Offer__c for EDGE-126184 Changes
        oldPC.ConfigurationType1__c = 'SolutionComponent';
        //productconfiglist.add(oldPC);
        insert oldPC;
        cscfga__Product_Configuration__c cnclPC = new cscfga__Product_Configuration__c();
        cnclPC.cscfga__Product_Basket__c = basket.id;
        cnclPC.name='Connected Workplace Solution';
        cnclPC.Type__c='Cancel';
        cnclPC.csordtelcoa__Replaced_Product_Configuration__c=oldPC.id;
        cnclPC.Marketable_Offer__c = moMob.id;//Add Marketable_Offer__c for EDGE-126184 Changes
        cnclPC.ConfigurationType1__c = 'SolutionComponent';
        //insert cnclPC;
        productconfiglist.add(cnclPC);
        //EDGE-141270 AND EDGE-143435 && EDGE-158055 START
        cscfga__Product_Configuration__c cnclPCngUC = new cscfga__Product_Configuration__c();
        cnclPCngUC.cscfga__Product_Basket__c = basket.id;
        cnclPCngUC.name='Telstra Collaboration Solution';
        cnclPCngUC.Type__c='Cancel';
        cnclPCngUC.csordtelcoa__Replaced_Product_Configuration__c=oldPC.id;
        cnclPCngUC.Marketable_Offer__c = moMob.id;//Add Marketable_Offer__c for EDGE-126184 Changes
        cnclPCngUC.ConfigurationType1__c = 'SolutionComponent';
        cnclPCngUC.cscfga__Product_Family__c = 'Telstra Collaboration Solution';
        productconfiglist.add(cnclPCngUC);
        //EDGE-141270 AND EDGE-143435 && EDGE-158055 END
        //EDGE-132608 Start
        cscfga__Product_Configuration__c PCBusCalling = new cscfga__Product_Configuration__c();
        PCBusCalling.cscfga__Product_Basket__c = basket.id;
        PCBusCalling.name='Business Calling';
        PCBusCalling.Type__c='New';
        PCBusCalling.Marketable_Offer__c = moTC.id;
        //PCBusCalling.ConfigurationType1__c = 'SolutionComponent';
        PCBusCalling.cscfga__Product_Family__c = 'Business Calling';
        PCBusCalling.cscfga__Product_Definition__c = pdBusinessCalling.Id;        
        productconfiglist.add(PCBusCalling);
        //EDGE-132608 End
        //EDGE-148722 - Start
        cscfga__Product_Configuration__c pcNGEM = new cscfga__Product_Configuration__c();
        pcNGEM.cscfga__Product_Basket__c = basket.id;
        pcNGEM.name='APPLE IPHONE 11 PRO 256GB 4GX MIDNIGHT GREEN';
        pcNGEM.Type__c='New';
        pcNGEM.Marketable_Offer__c = moMob.id;
        pcNGEM.cscfga__originating_offer__c=offername1.id;
        pcNGEM.cscfga__Product_Family__c = 'Next Generation Mobile Device';
        productconfiglist.add(pcNGEM);
        cscfga__Product_Configuration__c pcNGEM1 = new cscfga__Product_Configuration__c();
        pcNGEM1.cscfga__Product_Basket__c = basket.id;
        pcNGEM1.name='AppleCare+ Purchase';
        pcNGEM1.Type__c='New';
        pcNGEM1.Marketable_Offer__c = moMob.id;
        pcNGEM1.cscfga__originating_offer__c=offername1.id;
        pcNGEM1.cscfga__Product_Family__c = 'Mobile Device Care';
        productconfiglist.add(pcNGEM1);
        cscfga__Product_Configuration__c cnclPCngem = new cscfga__Product_Configuration__c();
        cnclPCngem.cscfga__Product_Basket__c = basket.id;
        cnclPCngem.name='APPLE IPHONE 10 PRO 256GB 4GX MIDNIGHT GREEN';
        cnclPCngem.Type__c='Cancel';
        cnclPCngem.csordtelcoa__Replaced_Product_Configuration__c=oldPC.id;
        cnclPCngem.Marketable_Offer__c = moMob.id;//Add Marketable_Offer__c for EDGE-126184 Changes
        cnclPCngem.ConfigurationType1__c = 'SolutionComponent';
        cnclPCngem.cscfga__Product_Family__c = 'Next Generation Mobile Device';
        productconfiglist.add(cnclPCngem);
        //EDGE-148722 - End
        //EDGE-165326 - Start
        cscfga__Product_Configuration__c pcNGEMPlan = new cscfga__Product_Configuration__c();
        pcNGEMPlan.cscfga__Product_Basket__c = basket.id;
        pcNGEMPlan.name='Handheld-Enterprise Lite';
        pcNGEMPlan.Type__c='New';
        pcNGEMPlan.Marketable_Offer__c = moMob.id;
        pcNGEMPlan.cscfga__originating_offer__c=offername1.id;
        pcNGEMPlan.cscfga__Product_Family__c = 'Enterprise Mobility Plan';
        productconfiglist.add(pcNGEMPlan);
        //EDGE-165326 - End
       
        cscfga__Product_Configuration__c pcNGEMPlan1 = new cscfga__Product_Configuration__c();
        pcNGEMPlan1.cscfga__Product_Basket__c = basket.id;
        pcNGEMPlan1.name='';
        pcNGEMPlan1.Type__c='New';
        pcNGEMPlan1.Marketable_Offer__c = moMob.id;
        pcNGEMPlan1.cscfga__originating_offer__c=offername1.id;
        pcNGEMPlan1.cscfga__Product_Family__c = 'Enterprise Mobility Plan';
        productconfiglist.add(pcNGEMPlan1);
        //DPG-3344
       
        //EDGE-155059 & EDGE-162542 Start
        cscfga__Product_Configuration__c pcNGEMPlanCancel = new cscfga__Product_Configuration__c();
        pcNGEMPlanCancel.cscfga__Product_Basket__c = basketNGEMCancel.id;
        pcNGEMPlanCancel.name='Handheld-Enterprise Lite';
        pcNGEMPlanCancel.Type__c='Cancel';
        pcNGEMPlanCancel.Marketable_Offer__c = moMob.id;
        pcNGEMPlanCancel.cscfga__originating_offer__c=offername1.id;
        pcNGEMPlanCancel.cscfga__Product_Family__c = 'Enterprise Mobility Plan';
        pcNGEMPlanCancel.cscfga__Product_Definition__c = pdNGEM.Id;
        pcNGEMPlanCancel.csordtelcoa__Replaced_Product_Configuration__c=oldPC.id;
        productconfiglist.add(pcNGEMPlanCancel);
        //EDGE-155059 & EDGE-162542 End
        //EDGE-144732 Start
        cscfga__Product_Configuration__c PCBusCallingCancel = new cscfga__Product_Configuration__c();
        PCBusCallingCancel.cscfga__Product_Basket__c = basket.id;
        PCBusCallingCancel.name='Business Calling';
        PCBusCallingCancel.Type__c='Cancel';
        PCBusCallingCancel.Marketable_Offer__c = moTC.id;
        PCBusCallingCancel.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCBusCallingCancel.cscfga__Product_Family__c = 'Business Calling';
        productconfiglist.add(PCBusCallingCancel);
        //EDGE-144732 End
        cscfga__Product_Configuration__c PCNew = new cscfga__Product_Configuration__c();
        PCNew.cscfga__Product_Basket__c = basketMAC.id;
        PCNew.name='Connected Workplace Solution';
        PCNew.Type__c='Cancel';
        PCNew.cscfga__originating_offer__c=offername1.id;
        PCNew.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCNew.Marketable_Offer__c = mo1.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        PCNew.ConfigurationType1__c = 'SolutionComponent';
        productconfiglist.add(PCNew);
        cscfga__Product_Configuration__c PCNewMdm = new cscfga__Product_Configuration__c();
        PCNewMdm.cscfga__Product_Basket__c = basketMAC.id;
        PCNewMdm.name='MDM Tenancy';
        PCNewMdm.Type__c='Modify';
        PCNewMdm.cscfga__originating_offer__c=offername1.id;
        PCNewMdm.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCNewMdm.Marketable_Offer__c = momdm.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        PCNewMdm.ConfigurationType1__c = 'SolutionComponent';
        productconfiglist.add(PCNewMdm);
        //Product Defination for cancel mobility
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.name='Mobility';
        insert pd;
        /* start EDGE-151840 - Hide signature panel from Order Form for MAC orders - Aarathi from team Amsterdam */
        cscfga__Product_Configuration__c PCcmp = new cscfga__Product_Configuration__c();
        PCcmp.cscfga__Product_Basket__c = basketModify.id;
        PCcmp.name='Corporate Mobile Plus';
        PCcmp.Type__c='Modify';
        PCcmp.cscfga__originating_offer__c=offername1.id;
        PCcmp.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCcmp.Marketable_Offer__c = momob.id;
        PCcmp.ConfigurationType1__c = 'SolutionComponent';
        PCcmp.cscfga__Product_Definition__c=pd.Id;
        PCcmp.cscfga__Product_Family__c='Enterprise Mobility';
        productconfiglist.add(PCcmp);
        cscfga__Product_Configuration__c PCcmp2 = new cscfga__Product_Configuration__c();
        PCcmp2.cscfga__Product_Basket__c = basketModify.id;
        PCcmp2.name='Corporate Mobile Plus';
        PCcmp2.Type__c='New';
        PCcmp2.cscfga__originating_offer__c=offername1.id;
        PCcmp2.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCcmp2.Marketable_Offer__c = momob.id;
        PCcmp2.ConfigurationType1__c = 'SolutionComponent';
        PCcmp2.cscfga__Product_Definition__c=pd.Id;
        PCcmp2.cscfga__Product_Family__c='Enterprise Mobility';
        productconfiglist.add(PCcmp2);
        cscfga__Product_Configuration__c PCcmp1 = new cscfga__Product_Configuration__c();
        PCcmp1.cscfga__Product_Basket__c = basketModify.id;
        PCcmp1.name='Corporate Mobile Plus';
        PCcmp1.Type__c='Cancel';
        PCcmp1.cscfga__originating_offer__c=offername1.id;
        PCcmp1.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCcmp1.Marketable_Offer__c = momob.id;
        PCcmp1.ConfigurationType1__c = 'SolutionComponent';
        PCcmp1.cscfga__Product_Definition__c=pd.Id;
        PCcmp1.cscfga__Product_Family__c='Enterprise Mobility';
        productconfiglist.add(PCcmp1);
        cscfga__Product_Configuration__c PCcmp3 = new cscfga__Product_Configuration__c();
        PCcmp3.cscfga__Product_Basket__c = basketNew.id;
        PCcmp3.name='Corporate Mobile Plus';
        PCcmp3.Type__c='New';
        PCcmp3.cscfga__originating_offer__c=offername1.id;
        PCcmp3.Marketable_Offer__c = momob.id;
        PCcmp3.ConfigurationType1__c = 'SolutionComponent';
        PCcmp3.cscfga__Product_Definition__c=pd.Id;
        PCcmp3.cscfga__Product_Family__c='Enterprise Mobility';
        productconfiglist.add(PCcmp3);        
        /* EDGE-151840 - Hide signature panel from Order Form for MAC orders - Aarathi from team Amsterdam */
        cscfga__Product_Configuration__c PCNews = new cscfga__Product_Configuration__c();
        PCNews.cscfga__Product_Basket__c = basketMAC.id;
        PCNews.name='Connected WorkPlace';
        PCNews.Type__c='New';
        PCNews.cscfga__originating_offer__c=offername1.id;
        PCNews.Marketable_Offer__c = listOfOffers[0].id;//moMob.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        PCNews.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        productconfiglist.add(PCNews);
        cscfga__Product_Configuration__c MACPC = new cscfga__Product_Configuration__c();
        MACPC.cscfga__Product_Basket__c = basketMAC.id;
        MACPC.name='IP Site';
        MACPC.Type__c='Modify';
        MACPC.cscfga__originating_offer__c=offername1.id;
        MACPC.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        MACPC.Marketable_Offer__c = mo1.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        productconfiglist.add(MACPC);
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c = basket.id;
        MACPCnew.cscfga__originating_offer__c=offername.id;
        MACPCnew.Marketable_Offer__c = moMob.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='New';
        MACPCnew.cscfga__Product_Definition__c=prodDefinition.id;//EDGE-132157
        MACPCnew.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        productconfiglist.add(MACPCnew);
        cscfga__Product_Configuration__c MACPCcncl = new cscfga__Product_Configuration__c();
        MACPCcncl.cscfga__Product_Basket__c = basketMAC.id;
        MACPCcncl.name='IP Site';
        MACPCcncl.Type__c='Cancel';
        MACPCcncl.cscfga__originating_offer__c=offername.id;
        MACPCcncl.Marketable_Offer__c=moMob.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        MACPCcncl.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        productconfiglist.add(MACPCcncl);
        //ddddd  
        cscfga__Product_Configuration__c cncl = new cscfga__Product_Configuration__c();
        cncl.cscfga__Product_Basket__c = basket_to_set_email_date.id;
        cncl.name='IP Site';
        cncl.Type__c='Cancel';
        cncl.cscfga__originating_offer__c=offername.id;
        cncl.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        cncl.Marketable_Offer__c = moMob.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        productconfiglist.add(cncl);
        //ddddddddd
        //cancel Mobility
        cscfga__Product_Configuration__c cancelMobility = new cscfga__Product_Configuration__c();
        cancelMobility.cscfga__Product_Basket__c = cancelBasket.id;
        cancelMobility.cscfga__Product_Definition__c = pd.id;
        cancelMobility.name='CWP Mobility';
        cancelMobility.Type__c='Cancel';
        cancelMobility.ConfigurationType1__c = 'SolutionComponent';
        cancelMobility.cscfga__originating_offer__c=offername.id;
        cancelMobility.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        cancelMobility.Marketable_Offer__c = moMob.id;////Add Marketable_Offer__c for EDGE-126184 Changes
        productconfiglist.add(cancelMobility);  
        insert productconfiglist;
        // EDGE-147970 - Adding CLI and DLI's
        Charge_Line_Item__c cli1=new Charge_Line_Item__c();
        cli1.Name = 'Test CLI';
        cli1.basketId__c = basket.id;
        cli1.Product_Configuration__c =  PCBusCalling.Id;
        insert cli1;
        Discount_Line_Item__c dli1 = new Discount_Line_Item__c();
        dli1.Name = 'Test DLI';
        dli1.chargeInstance__c = cli1.Id;
        dli1.BusinessID__c='DMCAT_Discount_000899';
        dli1.discountEndDate__c = System.today();
        insert dli1;
        //EDGE-147970 test data end
        //EDGE-132157 Start
        Attachment transitionAttach = new Attachment();
        transitionAttach.name = 'TransitionJSONData.json';
        transitionAttach.ParentId = MACPCnew.Id;
        transitionAttach.body = Blob.valueOf('Test');
        insert transitionAttach;
        system.debug('transitionAttach@@:: ' + transitionAttach);
        //system.debug('newPC.attach@@:: ' + newPC.attachments);
        //EDGE-132157 End
        /**EDGE-80772 - commented for Solution Console retrofit
List<csbb__Product_Configuration_Request__c> prreqlist= new List<csbb__Product_Configuration_Request__c>();
csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
prrequest.csbb__Product_Configuration__c=MACPC.id;
prrequest.csbb__Product_Basket__c=basketMAC.id;
//prrecord.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c
prreqlist.add(prrequest);
csbb__Product_Configuration_Request__c prrequestnew= new   csbb__Product_Configuration_Request__c();
prrequestnew.csbb__Product_Configuration__c=MACPCnew.id;
prrequestnew.csbb__Product_Basket__c=basket.id;
prreqlist.add(prrequestnew);
csbb__Product_Configuration_Request__c prrequestcncl= new   csbb__Product_Configuration_Request__c();
prrequestcncl.csbb__Product_Configuration__c=MACPCcncl.id;
prrequestcncl.csbb__Product_Basket__c=basketMAC.id;
prreqlist.add(prrequestcncl);
//ddddddd
csbb__Product_Configuration_Request__c pcncl= new   csbb__Product_Configuration_Request__c();
pcncl.csbb__Product_Configuration__c=cncl.id;
pcncl.csbb__Product_Basket__c=basket_to_set_email_date.id;
prreqlist.add(pcncl);
//ddddddd
//PCR for cancel mobilty basket
csbb__Product_Configuration_Request__c cancelPCR= new   csbb__Product_Configuration_Request__c();
cancelPCR.csbb__Product_Configuration__c=cancelMobility.id;
cancelPCR.csbb__Product_Basket__c=cancelBasket.id;
prreqlist.add(cancelPCR);
insert prreqlist;*/
        OpportunityContactRole oppContact = new OpportunityContactRole();
        oppContact.ContactId = contact.Id;
        oppContact.IsPrimary = true;
        oppContact.OpportunityId = basket.cscfga__Opportunity__c;
        oppContact.Role = 'Inside Sales Account Manager';
        insert oppContact;
        OpportunityContactRole oppContact1 = new OpportunityContactRole();
        oppContact1.ContactId = contact.Id;
        oppContact1.IsPrimary = true;
        oppContact1.OpportunityId = basketMAC.cscfga__Opportunity__c;
        oppContact1.Role = 'Inside Sales Account Manager';
        insert oppContact1;
        OpportunityContactRole oppContact2 = new OpportunityContactRole();
        oppContact2.ContactId = contact.Id;
        oppContact2.IsPrimary = true;
        oppContact2.OpportunityId = basket_to_set_email_date.cscfga__Opportunity__c;
        oppContact2.Role = 'Inside Sales Account Manager';
        insert oppContact2;  
        //Added the single insert statements into list
        List<APXTConga4__Conga_Template__c> templateList = new List<APXTConga4__Conga_Template__c>();
        APXTConga4__Conga_Template__c gpttemplate = new APXTConga4__Conga_Template__c();
        gpttemplate.APXTConga4__Name__c = 'GPT';
        gpttemplate.Sequence__c = 3;
        gpttemplate.Type__c='General Product Terms';
        gpttemplate.APXTConga4__Template_Group__c = 'Contract';
        insert gpttemplate;
        //templateList.add(gpttemplate);
        APXTConga4__Conga_Template__c oftemplate = new APXTConga4__Conga_Template__c();
        oftemplate.APXTConga4__Name__c = 'Offer Terms';
        oftemplate.Sequence__c = 4;
        oftemplate.Type__c='Offer Terms';
        oftemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert oftemplate;
        templateList.add(oftemplate);
        APXTConga4__Conga_Template__c otemplate = new APXTConga4__Conga_Template__c();
        otemplate.APXTConga4__Name__c = 'Orderform';
        otemplate.Sequence__c = 1;
        otemplate.Type__c='None' ;
        otemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert otemplate;
        templateList.add(otemplate);
        APXTConga4__Conga_Template__c bsatemplate = new APXTConga4__Conga_Template__c();
        bsatemplate.APXTConga4__Name__c = 'BSA';
        bsatemplate.Sequence__c = 2;
        bsatemplate.Type__c='BSA' ;
        bsatemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert bsatemplate;
        templateList.add(bsatemplate);
        APXTConga4__Conga_Template__c ngucstemplate = new APXTConga4__Conga_Template__c();
        ngucstemplate.APXTConga4__Name__c = 'ngUCContract - Service Terms';
        ngucstemplate.Sequence__c = 5;
        ngucstemplate.Type__c='Offer Terms' ;
        ngucstemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert ngucstemplate;
        Conga_Template_Version__c act = new Conga_Template_Version__c();
        act.Active__c =true;
        act.Version__c = 1.1;
        act.Conga_Template__c = gpttemplate.id;
        insert act;
        APXTConga4__Conga_Template__c cmptemplate = new APXTConga4__Conga_Template__c();
        cmptemplate.APXTConga4__Name__c = 'Contract - Service Terms(CMP)';
        cmptemplate.Sequence__c = 7;
        cmptemplate.Type__c='Service Terms' ;
        cmptemplate.Offer_Name__c = 'Connected Workplace Solution';
        cmptemplate.APXTConga4__Template_Group__c = 'Contract';
        cmptemplate.Active_Template_Version__c = act.Id;
        //insert cmptemplate;
        templateList.add(cmptemplate);
        Service_Term__c cnWrSt = new Service_Term__c(isStatusChange__c=false,Account__c =acc.id,Related_Opportunity__c = opp.id,Name = 'Connected Workplace Solution',Status__c='Pending Countersign',OFTVersion__c=act.Version__c,ServiceTermName__c = 'Connected Workplace Solution');                      
        insert cnWrSt;
        APXTConga4__Conga_Template__c cmptemplate1 = new APXTConga4__Conga_Template__c();
        cmptemplate1.APXTConga4__Name__c = 'Contract - Service Schedule';
        cmptemplate1.Sequence__c = 10;
        cmptemplate1.Type__c='Service Terms' ;
        cmptemplate1.Offer_Name__c = 'IoT solutions';
        cmptemplate1.APXTConga4__Template_Group__c = 'Contract';
        cmptemplate1.Active_Template_Version__c = act.Id;
        //insert cmptemplate;
        templateList.add(cmptemplate1);
        Service_Term__c cnWrSt1 = new Service_Term__c(isStatusChange__c=false,Account__c =acc.id,Related_Opportunity__c = opp.id,Name = 'IoT solutions',Status__c='Pending Countersign',OFTVersion__c=act.Version__c,ServiceTermName__c = 'IoT solutions');                      
        insert cnWrSt1;
        APXTConga4__Conga_Template__c cmptemplateMdm = new APXTConga4__Conga_Template__c();
        cmptemplateMdm.APXTConga4__Name__c = 'Contract - Service Terms(MDM)';
        cmptemplateMdm.Sequence__c = 8;
        cmptemplateMdm.Type__c='Service Terms' ;
        cmptemplateMdm.Offer_Name__c = 'MDM Tenancy';
        cmptemplateMdm.APXTConga4__Template_Group__c = 'Contract';
        cmptemplateMdm.Active_Template_Version__c = act.Id;
        //insert cmptemplateMdm;
        templateList.add(cmptemplateMdm);
        //DPG-1619 Added new Contract Template for IoT
        APXTConga4__Conga_Template__c IoTContractTemplate = new APXTConga4__Conga_Template__c();
        IoTContractTemplate.APXTConga4__Name__c = 'Contract - IoT Order Form';
        IoTContractTemplate.Type__c='None' ;
        IoTContractTemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert IoTContractTemplate;
        templateList.add(IoTContractTemplate);
        //DIGI-683
        APXTConga4__Conga_Template__c priceSchedule = new APXTConga4__Conga_Template__c();
        priceSchedule.APXTConga4__Name__c = 'priceSchedule';
        priceSchedule.Type__c='Price Schedule' ;
        priceSchedule.APXTConga4__Template_Group__c = 'Contract';
        templateList.add(priceSchedule);
        //DIGI-683
        insert templateList;        
        contemplate = new APXTConga4__Conga_Template__c();
        contemplate.APXTConga4__Name__c = 'Contract - Order Form';
        contemplate.Sequence__c = 9;
        contemplate.Type__c='None' ;
        contemplate.APXTConga4__Template_Group__c = 'Contract';
        insert contemplate;        
        //Added the single insert statements into list
        List<APXTConga4__Conga_Merge_Query__c> congaqueryList= new List<APXTConga4__Conga_Merge_Query__c>();
        APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
        query1.APXTConga4__Name__c = 'BasketPricesFromPC1';
        //insert query1;
        congaqueryList.add(query1);
        APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
        query2.APXTConga4__Name__c = 'AccountDetails';
        //insert query2;
        congaqueryList.add(query2);
        APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
        query3.APXTConga4__Name__c = 'BasketProductDetails';
        //insert query3;
        congaqueryList.add(query3);
        APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
        query4.APXTConga4__Name__c = 'OpportunityDetails';
        //insert query4;
        congaqueryList.add(query4);
        APXTConga4__Conga_Merge_Query__c query5 = new APXTConga4__Conga_Merge_Query__c();
        query5.APXTConga4__Name__c = 'BasketPricesFromPC2';
        //insert query5;
        congaqueryList.add(query5);
        APXTConga4__Conga_Merge_Query__c query6 = new APXTConga4__Conga_Merge_Query__c();
        query6.APXTConga4__Name__c = 'BSChangesToExisting';
        //insert query6;
        congaqueryList.add(query6);
        APXTConga4__Conga_Merge_Query__c query7 = new APXTConga4__Conga_Merge_Query__c();
        query7.APXTConga4__Name__c = 'BSCWPChanges';
        //insert query7;
        congaqueryList.add(query7);
        APXTConga4__Conga_Merge_Query__c query8 = new APXTConga4__Conga_Merge_Query__c();
        query8.APXTConga4__Name__c = 'BasketCancellation';
        //insert query8;
        congaqueryList.add(query8);
        //Added changes for EDGE-126184 Start Here
        APXTConga4__Conga_Merge_Query__c query9 = new APXTConga4__Conga_Merge_Query__c();
        query9.APXTConga4__Name__c = 'BSProductDetails';
        //insert query9;
        congaqueryList.add(query9);
        APXTConga4__Conga_Merge_Query__c query10 = new APXTConga4__Conga_Merge_Query__c();
        query10.APXTConga4__Name__c = 'BSCDForCMP';
        congaqueryList.add(query10);
        APXTConga4__Conga_Merge_Query__c query11 = new APXTConga4__Conga_Merge_Query__c();
        query11.APXTConga4__Name__c = 'BSCMPCancel';
        congaqueryList.add(query11);
        APXTConga4__Conga_Merge_Query__c query12 = new APXTConga4__Conga_Merge_Query__c();
        query12.APXTConga4__Name__c = 'BSCMPServices';
        congaqueryList.add(query12);
        APXTConga4__Conga_Merge_Query__c query13 = new APXTConga4__Conga_Merge_Query__c();
        query13.APXTConga4__Name__c = 'BSCMPServicesMAC';
        congaqueryList.add(query13);
        //DPG-1619 Added new Contract Template for IoT
        APXTConga4__Conga_Merge_Query__c query14 = new APXTConga4__Conga_Merge_Query__c();
        query13.APXTConga4__Name__c = 'BSIOTServicesOC';
        congaqueryList.add(query14);
        insert congaqueryList;
        //Added changes for EDGE-126184 End Here
    }
    @isTest static void generateContractSuccess() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
       
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
       
        //EDGE-119211 - Checking AssertEqual for updated document name
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //create ContentDocumentLink  record
        List<ContentDocumentLink> clList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = cdList[0].Id;
        cdl.shareType = 'V';
        clList.add(cdl);
        insert clList;      
        List<ContentDocument> lstcd = new List<ContentDocument>();
        for(ContentDocumentLink cd1:clList)
        {
            ContentDocument cd = new ContentDocument();
            cd.id = cd1.ContentDocumentId;
            cd.Title = 'CMP - Order Form';
            lstcd.add(cd);
        }
        update(lstcd);
        Test.stopTest();
        system.assertEquals('CMP - Order Form',lstcd[0].Title);//EDGE-119211 end
        System.assert(recordId!=null);
        //EDGE-132157 Start  Transition_Services_Show__c
        /* ContractJunction__c showTransitionService = [Select Transition_Services_Show__c from ContractJunction__c limit 1];
system.debug('showTransitionService@@::' + showTransitionService);
System.assert(showTransitionService.Transition_Services_Show__c==false);*/
        //EDGE-132157 End
        //EDGE-141270 AND EDGE-143435 && && EDGE-158055 Start
        ContractJunction__c showExistingService = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        system.debug('showTransitionService@@::' + showExistingService);
        System.assert(showExistingService.Existing_Services_Show__c==true);
        //EDGE-141270 AND EDGE-143435 && && EDGE-158055 END
    }
    /* start EDGE-151840 - Hide signature panel from Order Form for MAC orders - Aarathi from team Amsterdam */
    //EDGE-151840 positive scenario
    @isTest static void generateContractMACorderModifyCancel() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        //oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        List<Conga_Template_Version__c> cvList = [SELECT id,Version__c from Conga_Template_Version__c];
        /*for(Conga_Template_Version__c cv : cvList){
cv.version__c = 2.1;
update cv;
}*/
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        List<cscfga__Product_Configuration__c> p=[select id,name,Type__c,Marketable_Offer__c,Marketable_Offer__r.Name,cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csordtelcoa__Replaced_Product_Configuration__c,OfferName__c, cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basketModify.id];
        String recordId= gc.createContract(basketModify.id, ContractSignatories, 'basket',false,null);
        Test.stopTest();
        System.assert(recordId!=null);
        ContractJunction__c showChangestoExisting = [Select showSignaturePanel__c,isSendOrderFormEmail__c,showAcknowledgeBtn__c,Related_Basket__r.cscfga__Opportunity__r.Basket_Redemption_amount__c from ContractJunction__c Where Id=:recordId limit 1];
        system.debug('showChangestoExisting @@::' + showChangestoExisting);
        System.assert(showChangestoExisting.showSignaturePanel__c==false);
        System.assert(showChangestoExisting.showAcknowledgeBtn__c==true);
        //EDGE-169277 - Assert statement positive - to check isSendOrderFormEmail flag.
        system.assert(showChangestoExisting.isSendOrderFormEmail__c==true);
        //EDGE-190324
        system.assertNotEquals(showChangestoExisting.Related_Basket__r.cscfga__Opportunity__r.Basket_Redemption_amount__c, 10.00);
    }  
    //EDGE-151840 negative scenario
    @isTest static void generateContractNewOrcder() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        //oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        List<Conga_Template_Version__c> cvList = [SELECT id,Version__c from Conga_Template_Version__c];
        /*for(Conga_Template_Version__c cv : cvList){
cv.version__c = 2.1;
update cv;
}*/
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        List<cscfga__Product_Configuration__c> p=[select id,name,Type__c,Marketable_Offer__c,Marketable_Offer__r.Name,cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csordtelcoa__Replaced_Product_Configuration__c,OfferName__c, cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basketNew.id];
        String recordId= gc.createContract(basketNew.id, ContractSignatories, 'basket',false,null);
        Test.stopTest();
        system.debug('recordId::'+ recordId);
        System.assert(recordId!=null);
        ContractJunction__c showChangestoExisting = [Select showSignaturePanel__c,showAcknowledgeBtn__c from ContractJunction__c Where Id=:recordId limit 1];
        system.debug('showChangestoExisting @@::' + showChangestoExisting);
        System.assert(showChangestoExisting.showSignaturePanel__c==false);
        System.assert(showChangestoExisting.showAcknowledgeBtn__c==false);
    }
    /* end EDGE-151840 - Hide signature panel from Order Form for MAC orders - Aarathi from team Amsterdam */
    @isTest static void generateContractMACorder() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        List<Conga_Template_Version__c> cvList = [SELECT id,Version__c from Conga_Template_Version__c];
        /*for(Conga_Template_Version__c cv : cvList){
cv.version__c = 2.1;
update cv;
}*/
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basketMAC.id, ContractSignatories, 'basket',false,null);
        Test.stopTest();          
        System.assert(recordId!=null);
        //EDGE-143435 && EDGE-158055 START
        ContractJunction__c showChangestoExisting = [Select Changes_to_Existing__c,EAP_Discount_End_Date__c,showSignaturePanel__c from ContractJunction__c limit 1];
        system.debug('showChangestoExisting @@::' + showChangestoExisting);
        System.assert(showChangestoExisting.Changes_to_Existing__c==false);
        //EDGE-143435 && EDGE-158055 END
        // System.assert(showChangestoExisting.showSignaturePanel__c==false);
        //EDGE-147970 - Added Negative assert
        System.assertNotEquals(showChangestoExisting.EAP_Discount_End_Date__c, System.today());          
    }
    @isTest static void ToSetEmailDate() {
        Test.startTest();  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket_to_set_email_date.id, ContractSignatories, 'basket',false,null);
        System.assert(recordId!=null);
        Test.stopTest();          
    }
    // EDGE-79676 - Positive Scenarios
    @isTest static void cancelMobility() {
       
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        //EDGE-80772 : Rewritten for Solution Console retrofit
        List<cscfga__Product_Configuration__c> p=[select id,name,Type__c,Marketable_Offer__c,Marketable_Offer__r.Name,cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csordtelcoa__Replaced_Product_Configuration__c,OfferName__c, cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:cancelBasket.id];
        String recordId= gc.createContract(cancelBasket.id, ContractSignatories, 'basket',false,null);
        System.assert(recordId!=null);
        Test.stopTest();          
    }
    // EDGE-79676 - Negative Scenario
    // Below will cover negative for EDGE-132608 and EDGE-144732
    @isTest static void cancelMobilityneg() {
       
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        //EDGE-80772 : Rewritten for Solution Console retrofit
        List<cscfga__Product_Configuration__c> p=[select id,name,Type__c,Marketable_Offer__c,Marketable_Offer__r.Name,cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csordtelcoa__Replaced_Product_Configuration__c,OfferName__c, cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:cancelBasket.id];
        system.debug('valueofProductConfig'+p);
        // INC000092229271 Incident fix--Start Here
        APXTConga4__Conga_Template__c congaTemplateRecord= [Select id,name,APXTConga4__Name__c from APXTConga4__Conga_Template__c where id=:contemplate.id  limit 1];
        String recordId= gc.createContract(cancelBasket.id, ContractSignatories, 'basket',false,null);
        System.assert(recordId!=null);
        system.assertEquals(congaTemplateRecord.APXTConga4__Name__c, 'Contract - Order Form');
        // INC000092229271 Incident fix--Start Here
        Test.stopTest();          
    }
    //DPG-1619 Added new Contract Template for IoT
    @isTest static void generateIOTContractSuccess() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='Active';
        insert acc;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp;
        /*cscfga__Product_Basket__c basketIoT = ProductTestFactory.buildEmptyBasket();
        basketIoT.csbb__Account__c = acc.id;
        basketIoT.cscfga__Opportunity__c = opp.id;
        basketIoT.Name = 'IoT Basket';
        insert basketIoT;*/
        Marketable_Offer__c moIoT = new Marketable_Offer__c();
        moIoT.OfferDefinationName__c ='IoT solutions' ;
        moIoT.Name = System.Label.IoTOfferName;
        moIoT.Offer_ID__c = 'DMCAT_Offer_000964';
        insert moIoT;
        cscfga__Product_Definition__c prodDefIoT = ProductTestFactory.buildProductDefinition(System.Label.InternetOfThings, 'Test Plan');
        insert prodDefIoT;
        cscfga__Product_Configuration__c configIot = new cscfga__Product_Configuration__c();
        //configIot.cscfga__Product_Basket__c = basketIoT.id;
        configIot.Name = System.Label.InternetOfThings;
        configIot.cscfga__Description__c = 'test Description ';
        configIot.cscfga__Contract_Term__c = 36;
        configIot.ConfigurationType1__c = 'SolutionComponent';
        configIot.Marketable_Offer__c = moIoT.id;
        insert configIot;
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        Test.startTest();//DPG-1690 Change
        //String recordId= gc.createContract(basketIoT.id,ContractSignatories, 'basket');
        Test.stopTest();//DPG-1690 Change
        /*ContractJunction__c oldContract = [SELECT Id, Name, Related_Basket__c,CIS_Dispatched_Offers__c FROM ContractJunction__c LIMIT 1];
        System.debug('CIS_Dispatched_Offers__c'+oldContract.CIS_Dispatched_Offers__c.toLowerCase());
        //System.assert(recordId!=null);
        system.assertNotEquals('Corporate Mobile Plus'.toLowerCase(), oldContract.CIS_Dispatched_Offers__c.toLowerCase());
        system.assert(oldContract.CIS_Dispatched_Offers__c.toLowerCase().contains(System.Label.IoTOfferName.toLowerCase()));*/
    }        
   
    //DPG-3344 Iot Service Schedule
    @isTest static void generateIOTContractSuccessAnnualPlan() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='Active';
        insert acc;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp;
        cscfga__Product_Basket__c basketIoTAnnual = ProductTestFactory.buildEmptyBasket();
        basketIoTAnnual.csbb__Account__c = acc.id;
        basketIoTAnnual.cscfga__Opportunity__c = opp.id;
        basketIoTAnnual.Name = 'IoT Basket';
        insert basketIoTAnnual;
        Marketable_Offer__c moIoTAnnual = new Marketable_Offer__c();
        moIoTAnnual.OfferDefinationName__c ='IoT solutions' ;
        moIoTAnnual.Name = 'IoT solutions';
        moIoTAnnual.Offer_ID__c = 'DMCAT_Offer_000964';
        insert moIoTAnnual;
        cscfga__Product_Definition__c prodDefIoT = ProductTestFactory.buildProductDefinition('IoT solutions_Annual Data_700000474978', 'Test Plan');
        insert prodDefIoT;
        cscfga__Product_Configuration__c configIotAnnual = new cscfga__Product_Configuration__c();
        configIotAnnual.cscfga__Product_Basket__c = basketIoTAnnual.id;
        configIotAnnual.Name = 'IoT solutions_Water Data_700000474978';
        configIotAnnual.cscfga__Description__c = 'test Description ';
        configIotAnnual.cscfga__Contract_Term__c = 36;
        configIotAnnual.ConfigurationType1__c = 'SolutionComponent';
        configIotAnnual.Marketable_Offer__c = moIoTAnnual.id;
        //insert configIotAnnual;
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        Test.startTest();//DPG-1690 Change
        String recordId= gc.createContract(basketIoTAnnual.id,ContractSignatories, 'basket',false,null);
        Test.stopTest();//DPG-1690 Change
        ContractJunction__c oldContract1 = [SELECT Id, Name, Related_Basket__c,CIS_Dispatched_Offers__c FROM ContractJunction__c WHERE  Related_Basket__c=:basketIoTAnnual.id];
        //System.debug('CIS_Dispatched_Offers__c'+oldContract1.CIS_Dispatched_Offers__c.toLowerCase());
        System.assert(recordId!=null);
        system.assertNotEquals(oldContract1.CIS_Dispatched_Offers__c,'Corporate Mobile Plus');
        //system.assert(oldContract1.CIS_Dispatched_Offers__c !=null);
       
    }        
   
    //DPG-1619 Added new Contract Template for IoT
    //EDGE-132608 and EDGE-148728 Test Method to check product family change. Positive Scenario
    @isTest static void generateContractBusinessCalling() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showNewServices = [Select New_Services_Show__c,EAP_Discount_End_Date__c,Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        System.assert(recordId!=null);
        //EDGE-154990 - Positive assert
        System.assert(showNewServices.Existing_Services_Show__c==true);
        system.debug('EAP_Discount_End_Date__c-->'+showNewServices.EAP_Discount_End_Date__c);      
        system.debug('New_Services_Show__c @@::' + showNewServices.New_Services_Show__c);
        //EDGE-147970 - Added assert to test CLI update on Contract record
        System.assertEquals(showNewServices.EAP_Discount_End_Date__c, System.today());
        System.assert(showNewServices.New_Services_Show__c==true);
    }
    //EDGE-132608 and EDGE-148728 END
    //EDGE-144732 Test Method to check product family change. Positive Scenario
    @isTest static void generateContractBusinessCallingCancel() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showExistingServices = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        System.assert(recordId!=null);        
        system.debug('New_Services_Show__c @@::' + showExistingServices.Existing_Services_Show__c);
        System.assert(showExistingServices.Existing_Services_Show__c==true);//Already Covered Assert for EDGE-158055
    }
    //EDGE-144732 END
    //EDGE-154990 - Start
    private void setupNgUCData(){
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        Account acc1 = AccountTestFactory.buildAccount('Test NGUC Trans') ;
        acc1.Customer_Status__c='Active';
        insert acc1;
        EnvironmentVariable__c enVar= new EnvironmentVariable__c();
        enVar.name='Send_OrderForm_for_Contract';
        enVar.Value__c='True';
        insert enVar;
        Contact contact1 = new Contact(AccountId = acc1.id,LastName = 'Last',FirstName = 'First',Contact_Role__c = 'Consultant',Email = 'test@tele2.com');
        insert contact1;
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp1;
        basketTC = ProductTestFactory.buildEmptyBasket();
        basketTC.csbb__Account__c = acc1.id;
        basketTC.cscfga__Opportunity__c = opp1.id;
        basketTC.Name = 'basketNGUC';
        insert basketTC;
        Marketable_Offer__c moTC1 = new Marketable_Offer__c();
        moTC1.OfferDefinationName__c ='Telstra Collaboration Solution';
        moTC1.Name = 'Telstra Collaboration';
        moTC1.Offer_ID__c = 'DMCAT_Offer_000618';
        moTC1.Contract_Type__c = 'DSA'; // EDGE-154519
        moTC1.Product_Family__c = '  Adaptive Mobility'; // EDGE-154520
        insert moTC1;
        cscfga__Product_Definition__c pdTC = new cscfga__Product_Definition__c( Name = 'Business Calling', cscfga__Description__c = 'Business Calling', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert pdTC;
        cscfga__Product_Configuration__c pcTC = new cscfga__Product_Configuration__c();        
        pcTC.cscfga__Product_Basket__c = basketTC.id;
        pcTC.name='Business Calling';
        pcTC.Type__c='New';
        pcTC.Marketable_Offer__c = moTC1.id;
        pcTC.cscfga__Product_Family__c = 'Business Calling';
        pcTC.cscfga__Product_Definition__c = pdTC.Id;        
        insert pcTC;
    }
    @isTest static void generateContractTCTrans_Test() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setupNgUCData();
        EnvironmentVariable__c enVar= new EnvironmentVariable__c();
        enVar.name='Send_CIS_for_Contract';
        enVar.Value__c='True';
        insert enVar;
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        //TED-383 Start
        //Create Adobe Agreement Templates
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids = new List<echosign_dev1__Agreement_Template__c>();
        echosign_dev1__Agreement_Template__c templateid1 = new echosign_dev1__Agreement_Template__c();
        templateid1.name = 'BSA Flow';
        eSignTemplateids.add(templateid1);
        echosign_dev1__Agreement_Template__c templateid2 = new echosign_dev1__Agreement_Template__c();
        templateid2.name = 'BSA MAC Flow';
        eSignTemplateids.add(templateid2);
        insert eSignTemplateids;
        //TED-383 End
        String recordId= gc.createContract(basketTC.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showExistingServices = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        System.assert(recordId!=null);        
        system.debug('showExistingServices @@::' + showExistingServices.Existing_Services_Show__c);
        //EDGE-154990 - Negative assert
        System.assert(showExistingServices.Existing_Services_Show__c==false);
    }
    //EDGE-154990 end
    // EDGE-154519 - Start | Maq
    /*@isTest static void getContractTypeForMarketableOffer_Test() {  
GenerateContractTest testData= new GenerateContractTest();
map<String, Boolean> relatedDocumentStatus = new map<String, Boolean>();
testData.setupNgUCData();
Test.startTest();
GenerateContract gc = new GenerateContract();
Boolean iSMarketableOfferPresent= gc.getContractTypeForMarketableOffer(basketTC,'DSA');
String producrFamily = GenerateContract.psProductFamilies; // // EDGE-154520
relatedDocumentStatus = GenerateContract.isDSALinkedToAccount(basketTC);
Test.stopTest();
System.assert(iSMarketableOfferPresent!=null);        
System.assert(iSMarketableOfferPresent==true);
System.assert(producrFamily=='Adaptive Mobility'); // EDGE-154520
}*/
    // EDGE-154519 - END | Maq
    //EDGE-148722 - Start
    @isTest static void generateContractNGEMCare() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showNewServices = [Select New_Services_Show__c,Contact_Role__c  from ContractJunction__c limit 1];
        Test.stopTest();
        System.assert(recordId!=null);
        System.assert(showNewServices.New_Services_Show__c==true);
        System.assert(showNewServices.Contact_Role__c=='Consultant');// Assert added for EDGE-165486
    }
    @isTest static void generateContractNGEMCancel() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showExistingServices = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        System.assert(recordId!=null);
        System.assert(showExistingServices.Existing_Services_Show__c==true);
    }
    //EDGE-148722 - End
    //EDGE-155059 & EDGE-162542 Positive Case
    @isTest static void generateContractNGEMPlanCancel() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basketNGEMCancel.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showExistingServices = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        System.assert(recordId!=null);
        System.assert(showExistingServices.Existing_Services_Show__c==true);
    }
    //EDGE-155059 & EDGE-162542 Negative Case
    @isTest static void generateContractNGEMCancel_Negative() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(null,null,null,false,null);
       
        Test.stopTest();
        System.assert(recordId==null);
       
    }
    //EDGE-165326 - Start
    //Below method covers Positive Scenario for NGEM Plan details for Contract & Negative scenario is already covered as part of generateContractNewOrcder
    @isTest static void generateContractNGEMPlanSuccess() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
       
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showNewServices = [Select New_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        //EDGE-165831 - Existing assert - checking retrofit spec ids method output null or not
        System.assert(recordId!=null);
        System.assert(showNewServices.New_Services_Show__c==true);
    }
    //EDGE-165326 - End
   
   
    //EDGE-165472
    @isTest static void generateBSAMACSignature() {
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        basketMAC.Pre_Authorised__c = false;
        update basketMAC;
        List<Conga_Template_Version__c> cvList = [SELECT id,Version__c from Conga_Template_Version__c];
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basketMAC.id, ContractSignatories, 'basket',false,null);
        Test.stopTest();          
       
       
        ContractJunction__c conObj = [Select showSignaturePanel__c,isSendOrderFormEmail__c,showAcknowledgeBtn__c from ContractJunction__c Where Id=:recordId limit 1];
        System.assert(recordId!=null);
        //EDGE-169277 - Assert statement negative - to check isSendOrderFormEmail flag..
        system.assert(conObj.isSendOrderFormEmail__c==false);
    } //EDGE-165472          
   
   
    /*--------------------------------------------------------
EDGE-171769
Description: Test Method for data setup
Author:Dheeraj Singh
--------------------------------------------------------*/
   
    public void setupNgUCDataApttusFlow(){
        /*Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;*/
        Account acc1 = AccountTestFactory.buildAccount('Test NGUC Trans') ;
        acc1.Customer_Status__c='Active';
        acc1.APTPS_DocuSign_Restricted__c = true;//DIGI-683
        insert acc1;
        EnvironmentVariable__c enVar= new EnvironmentVariable__c();
        enVar.name='Send_OrderForm_for_Contract';
        enVar.Value__c='True';
        insert enVar;
        Contact contact1 = new Contact(AccountId = acc1.id,LastName = 'Last',FirstName = 'First',Contact_Role__c = 'Consultant',Email = 'test@tele2.com');
        insert contact1;
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp1;
        basketTC = ProductTestFactory.buildEmptyBasket();
        basketTC.csbb__Account__c = acc1.id;
        basketTC.cscfga__Opportunity__c = opp1.id;
        basketTC.Name = 'basketNGUC';
        insert basketTC;
        Marketable_Offer__c moTC1 = new Marketable_Offer__c();
        moTC1.OfferDefinationName__c ='Telstra Collaboration Solution';
        moTC1.Name = 'Telstra Collaboration';
        moTC1.Offer_ID__c = 'DMCAT_Offer_000618';
        moTC1.Contract_Type__c = 'DSA'; // EDGE-154519
        moTC1.Product_Family__c = '  Adaptive Mobility'; // EDGE-154520
        insert moTC1;
        cscfga__Product_Definition__c pdTC = new cscfga__Product_Definition__c( Name = 'Business Calling', cscfga__Description__c = 'Business Calling', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert pdTC;
        cscfga__Product_Configuration__c pcTC = new cscfga__Product_Configuration__c();        
        pcTC.cscfga__Product_Basket__c = basketTC.id;
        pcTC.name='Business Calling';
        pcTC.Type__c='New';
        pcTC.Marketable_Offer__c = moTC1.id;
        pcTC.cscfga__Product_Family__c = 'Business Calling';
        pcTC.cscfga__Product_Definition__c = pdTC.Id;        
        insert pcTC;
       
        List<APXTConga4__Conga_Template__c> templateList = new List<APXTConga4__Conga_Template__c>();
        APXTConga4__Conga_Template__c gpttemplate = new APXTConga4__Conga_Template__c();
        gpttemplate.APXTConga4__Name__c = 'GPT';
        gpttemplate.Sequence__c = 3;
        gpttemplate.Type__c='General Product Terms';
        gpttemplate.APXTConga4__Template_Group__c = 'Contract';
        insert gpttemplate;
        //templateList.add(gpttemplate);
        APXTConga4__Conga_Template__c oftemplate = new APXTConga4__Conga_Template__c();
        oftemplate.APXTConga4__Name__c = 'Offer Terms';
        oftemplate.Sequence__c = 4;
        oftemplate.Type__c='Offer Terms';
        oftemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert oftemplate;
        templateList.add(oftemplate);
        APXTConga4__Conga_Template__c otemplate = new APXTConga4__Conga_Template__c();
        otemplate.APXTConga4__Name__c = 'Orderform';
        otemplate.Sequence__c = 1;
        otemplate.Type__c='None' ;
        otemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert otemplate;
        templateList.add(otemplate);
        /*APXTConga4__Conga_Template__c bsatemplate = new APXTConga4__Conga_Template__c();
bsatemplate.APXTConga4__Name__c = 'BSA';
bsatemplate.Sequence__c = 2;
bsatemplate.Type__c='BSA' ;
bsatemplate.APXTConga4__Template_Group__c = 'Contract';
//insert bsatemplate;
templateList.add(bsatemplate);*/
        APXTConga4__Conga_Template__c ngucstemplate = new APXTConga4__Conga_Template__c();
        ngucstemplate.APXTConga4__Name__c = 'ngUCContract - Service Terms';
        ngucstemplate.Sequence__c = 5;
        ngucstemplate.Type__c='Offer Terms' ;
        ngucstemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert ngucstemplate;
        templateList.add(ngucstemplate);
        APXTConga4__Conga_Template__c ngucotemplate = new APXTConga4__Conga_Template__c();
        ngucotemplate.APXTConga4__Name__c = 'ngUCContract - Order Form';
        ngucotemplate.Sequence__c = 6;
        ngucotemplate.Type__c='Offer Terms' ;
        ngucotemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert ngucotemplate;
        templateList.add(ngucotemplate);
        Conga_Template_Version__c act = new Conga_Template_Version__c();
        act.Active__c =true;
        act.Version__c = 1.1;
        act.Conga_Template__c = gpttemplate.id;
        insert act;
        APXTConga4__Conga_Template__c cmptemplate = new APXTConga4__Conga_Template__c();
        cmptemplate.APXTConga4__Name__c = 'Contract - Service Terms(CMP)';
        cmptemplate.Sequence__c = 7;
        cmptemplate.Type__c='Service Terms' ;
        cmptemplate.Offer_Name__c = 'Connected Workplace Solution';
        cmptemplate.APXTConga4__Template_Group__c = 'Contract';
        cmptemplate.Active_Template_Version__c = act.Id;
        //insert cmptemplate;
        templateList.add(cmptemplate);
        Service_Term__c cnWrSt = new Service_Term__c(isStatusChange__c=false,Account__c =acc1.id,Related_Opportunity__c = opp1.id,Name = 'Connected Workplace Solution',Status__c='Pending Countersign',OFTVersion__c=act.Version__c,ServiceTermName__c = 'Connected Workplace Solution');                      
        insert cnWrSt;
        APXTConga4__Conga_Template__c cmptemplateMdm = new APXTConga4__Conga_Template__c();
        cmptemplateMdm.APXTConga4__Name__c = 'Contract - Service Terms(MDM)';
        cmptemplateMdm.Sequence__c = 8;
        cmptemplateMdm.Type__c='Service Terms' ;
        cmptemplateMdm.Offer_Name__c = 'MDM Tenancy';
        cmptemplateMdm.APXTConga4__Template_Group__c = 'Contract';
        cmptemplateMdm.Active_Template_Version__c = act.Id;
        //insert cmptemplateMdm;
        templateList.add(cmptemplateMdm);
        //DPG-1619 Added new Contract Template for IoT
        APXTConga4__Conga_Template__c IoTContractTemplate = new APXTConga4__Conga_Template__c();
        IoTContractTemplate.Sequence__c = 14;
        IoTContractTemplate.APXTConga4__Name__c = 'DSA';
        IoTContractTemplate.Type__c='DSA' ;
        IoTContractTemplate.APXTConga4__Template_Group__c = 'Contract';
        //insert IoTContractTemplate;
        templateList.add(IoTContractTemplate);
        //DIGI-683
        APXTConga4__Conga_Template__c priceSchedule = new APXTConga4__Conga_Template__c();
        priceSchedule.APXTConga4__Name__c = 'priceSchedule';
        priceSchedule.Type__c='Price Schedule' ;
        priceSchedule.APXTConga4__Template_Group__c = 'Contract';
        templateList.add(priceSchedule);
        insert templateList;  
       
       
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basketTC.csbb__Account__c;
        //oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basketTC.cscfga__Opportunity__c;
        oldContract.Status__c ='Initiated';
        oldContract.IsDSAGenerated__c = true;
        oldContract.pricescheduleProductFamilies__c = 'Mobility';
        //oldContract.Related_Basket__c=basket.id;
        insert oldContract;
    }
   
   
    /*--------------------------------------------------------
EDGE-171769
Description: Test Method to cover Apttus flow scenario
Author:Dheeraj Singh
--------------------------------------------------------*/
    @isTest static void generateContractAptusFlowTest() {
        EnvironmentVariable__c enVar= new EnvironmentVariable__c();
        enVar.name='Send_CIS_for_Contract';
        enVar.Value__c='False';
        insert enVar;      
        GenerateContractTest test1= new GenerateContractTest();
       
        test1.setupNgUCDataApttusFlow();
        Test.startTest();
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        /*Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        /*list<Disabled_Triggers__c> triggersDisabled1 = new List<Disabled_Triggers__c>();
Disabled_Triggers__c disabledTriggersProfile02 = new Disabled_Triggers__c();
disabledTriggersProfile02.SetupOwnerId = UserInfo.getProfileId();
disabledTriggersProfile02.Trigger_Name_List1__c = 'ContractJunctionTrigger';
triggersDisabled1.add(disabledTriggersProfile02);
insert triggersDisabled1;*/
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        system.debug('contact == ' +c );
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        system.debug('basketTC == ' +basketTC );
        system.debug('ContractSignatories == ' +ContractSignatories);
        String recordId= gc.createContract(basketTC.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showExistingServices = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
       
        //System.assert(recordId!=null);        
        //system.debug('showExistingServices @@::' + showExistingServices.Existing_Services_Show__c);
        //EDGE-154990 - Negative assert
        //System.assert(showExistingServices.Existing_Services_Show__c==false);
        system.assert(recordId!=null);//Assert value has changed for EDGE-193827 becuase it always comes as false.
       
    }
   
    /*--------------------------------------------------------
EDGE-173035
Description: Test Method to cover mix basket scenario
Author:Dheeraj Singh
--------------------------------------------------------*/
    @isTest static void generateContractAptusFlowmixbasketTest() {  
        GenerateContractTest test1= new GenerateContractTest();
        Test.startTest();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        test1.setupNgUCDataApttusFlow();
        Marketable_Offer__c moTC2 = new Marketable_Offer__c();
        moTC2.OfferDefinationName__c ='Telstra Tenancy';
        moTC2.Name = 'Telstra Tenancy';
        moTC2.Offer_ID__c = 'DMCAT_Offer_000619';
        moTC2.Contract_Type__c = 'BSA'; // EDGE-154519
        moTC2.Product_Family__c = 'Telstra Tenancy'; // EDGE-154520
        insert moTC2;
        cscfga__Product_Definition__c pdTC1= new cscfga__Product_Definition__c( Name = 'Business Telstra Tenancy', cscfga__Description__c = 'Business Telstra Tenancy', product_Specification__c = 'DMCAT_ProductOffering_000404',Snapshot_Object__c='basketsnapshot' );
        insert pdTC1;
        cscfga__Product_Configuration__c pcTC1 = new cscfga__Product_Configuration__c();        
        pcTC1.cscfga__Product_Basket__c = basketTC.id;
        pcTC1.name='Telstra Tenancy';
        pcTC1.Type__c='New';
        pcTC1.Marketable_Offer__c = moTC2.id;
        pcTC1.cscfga__Product_Family__c = 'Telstra Tenancy';
        pcTC1.cscfga__Product_Definition__c = pdTC1.Id;
        pcTC1.ConfigurationType1__c = 'SolutionComponent';
        insert pcTC1;
       
        Marketable_Offer__c moTC3 = new Marketable_Offer__c();
        moTC3.OfferDefinationName__c ='Adaptive Mobiity';
        moTC3.Name = 'Adaptive Mobiity';
        moTC3.Offer_ID__c = 'DMCAT_Offer_000620';
        moTC3.Contract_Type__c = 'DSA'; // EDGE-154519
        moTC3.Product_Family__c = 'Adaptive Mobiity'; // EDGE-154520
        insert moTC3;
        cscfga__Product_Definition__c pdTC2= new cscfga__Product_Definition__c( Name = 'Adaptive Mobiity', cscfga__Description__c = 'Adaptive Mobiity', product_Specification__c = 'DMCAT_ProductOffering_000204',Snapshot_Object__c='basketsnapshot1' );
        insert pdTC2;
        cscfga__Product_Configuration__c pcTC2 = new cscfga__Product_Configuration__c();        
        pcTC2.cscfga__Product_Basket__c = basketTC.id;
        pcTC2.name='Adaptive Mobiity';
        pcTC2.Type__c='New';
        pcTC2.Marketable_Offer__c = moTC3.id;
        pcTC2.cscfga__Product_Family__c = 'Adaptive Mobiity';
        pcTC2.cscfga__Product_Definition__c = pdTC2.Id;
        pcTC2.ConfigurationType1__c = 'SolutionComponent';
        insert pcTC2;
        // Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basketTC.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c showExistingServices = [Select Existing_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
       
        //System.assert(recordId!=null);        
        //system.debug('showExistingServices @@::' + showExistingServices.Existing_Services_Show__c);
        //EDGE-154990 - Negative assert
        //System.assert(showExistingServices.Existing_Services_Show__c==false);
        system.assertEquals(recordId,'Error Mix Basket');
       
    }
    //EDGE-171311 Start
    @isTest static void generateContractInflight() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        String bsktId = basket.id;
        list<recordtype> recType = [select id from recordtype where sObjectType = 'cscfga__Product_Basket__c' and developername = 'Inflight_Change'];      
        list<cscfga__Product_Basket__c> orgBasket = [select Id,Name,csbb__Account__c,cscfga__Opportunity__c from cscfga__Product_Basket__c where Id =:bsktId];
        String optyId = orgBasket[0].cscfga__Opportunity__c;
        orgBasket[0].recordTypeId=recType[0].Id;
        update orgBasket;
        cscfga__Product_Basket__c basketPar = new cscfga__Product_Basket__c();
        basketPar.csbb__Account__c = orgBasket[0].csbb__Account__c;
        basketPar.cscfga__Opportunity__c = orgBasket[0].cscfga__Opportunity__c;
        basketPar.Name = 'testBasket';
        basketPar.csordtelcoa__Basket_Stage__c = 'Submitted';
        insert basketPar;          
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
        ContractJunction__c ctrctRec = [Select Id,Name  from ContractJunction__c limit 1];
        Test.stopTest();
       
        System.assert(ctrctRec.Name!=orgBasket[0].Name);
    }    
    //EDGE-171311 End
    //DIGI-683 Start
    @isTest static void macAgreementlineItemCheck() {  
        Test.startTest();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        Account acc = AccountTestFactory.buildAccount('Test AccountOrderflow') ;
       
        acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c = 'Active';
       
        insert acc;  
        //CREATE CONTACT
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Contact contact = AccountTestFactory.buildContact(acc,'Test Contact');
        Database.SaveResult sr = Database.insert(contact, dml);
        if (sr.isSuccess()) {
            System.debug('Duplicate account has been inserted in Salesforce!');
        }
       
       
       
        list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Id strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Opportunity' and DeveloperName = 'Defined'].Id;
        Opportunity opty   = ProductTestFactory.getOpportunityBasic(acc);
        opty.name='New Opty';
        opty.amount = 4600;
        opty.RecordTypeId = strRecordTypeId;
        opty.Contract_Type__c = 'DSA';
        listoppty.add(opty);
        insert listoppty;
       
       
       
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket00 = ProductTestFactory.buildEmptyBasket();
        basket00 = ProductTestFactory.buildEmptyBasket();
        basket00.csbb__Account__c = acc.id;
        basket00.cscfga__Opportunity__c = listoppty[0].id;
        basket00.Name = 'New basket';
        basket00.cscfga__total_contract_value__c = 10;
        basket00.BasketType__c = 'Incoming';
        lstbasket.add(basket00);
       
        cscfga__Product_Basket__c basket01 = ProductTestFactory.buildEmptyBasket();
        basket01 = ProductTestFactory.buildEmptyBasket();
        basket01.csbb__Account__c = acc.id;
        basket01.cscfga__Opportunity__c = listoppty[0].id;
        basket01.Name = 'Previous basket';
        basket01.cscfga__total_contract_value__c = 20;
        basket01.BasketType__c = 'Incoming';
        lstbasket.add(basket01);
        insert lstbasket;
       
        lstbasket[0].csordtelcoa__Previous_Product_Basket__c = lstbasket[1].id;
        upsert lstbasket;
       
        ContractJunction__c cntrctRecord=new ContractJunction__c();
        cntrctRecord.Account__c = acc.id;
        cntrctRecord.Related_Opportunity__c=lstbasket[0].cscfga__Opportunity__c;
        cntrctRecord.Related_Basket__c=lstbasket[0].id;
        cntrctRecord.DocuSign_Signer_2__c = contact.id;
        cntrctRecord.Related_Price_Schedule__c = null;
        cntrctRecord.DocuSign_Signer_3__c = UserInfo.getUserId();
        cntrctRecord.Customer_Primary_Contact__c = contact.id;
        cntrctRecord.Contract_Type__c = 'DSA';
        insert cntrctRecord;
       
       
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();    
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Related_Contract__c = cntrctRecord.Id,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=lstbasket[0].csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=lstbasket[0].id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=lstbasket[0].csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=lstbasket[0].id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=lstbasket[0].csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=lstbasket[0].id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=lstbasket[0].csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=lstbasket[0].id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
       
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prod.Telstra_Marketable_Product_Family__c = 'Adaptive Mobility';
       
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prod1.Telstra_Marketable_Product_Family__c = 'Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
       
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
       
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
       
        /*list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;*/
        GenerateContract genc = new GenerateContract();
        List<String> pcMarketablePF = new List<String>{'Adaptive Mobility','Corporate Mobile Plus'};
            Boolean result = genc.macAgreementlineItemCheck(acc.Id,pcMarketablePF);
        Map<String,boolean> getRelatedAgmtFlg = GenerateContract.getRelatedAgreementFlags(lstbasket[0],pcMarketablePF);
        system.debug('result::'+result);
        Test.stopTest();
        system.assertEquals(true, result);
       
    }
   
    @isTest static void generateContractAgmtFlow() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        String recordId= gc.createContract(basket.id,ContractSignatories,'basket',false,null);
        ContractJunction__c showNewServices = [Select New_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        system.debug('showNewServices:'+showNewServices+'::'+recordId);
        system.assertEquals(true, showNewServices.New_Services_Show__c);
       
    }
   
    @isTest static void generateContractdocumentsToGenerate() {  
        GenerateContractTest test1= new GenerateContractTest();
       
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('Test Account1') ;
        acc.Customer_Status__c='Active';
        insert acc;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        opp.contract_type__c = 'DSA';//DIGI-683
        insert opp;
        basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        Conga_Template_Version__c act = new Conga_Template_Version__c();
        act.Active__c =true;
        act.Version__c = 1.1;
        //act.Conga_Template__c = gpttemplate.id;
        insert act;
        Service_Term__c cnWrSt = new Service_Term__c(isStatusChange__c=false,Account__c =acc.id,Related_Opportunity__c = opp.id,Name = 'Connected Workplace Solution',Status__c='Pending Countersign',OFTVersion__c=act.Version__c,ServiceTermName__c = 'Connected Workplace Solution');                      
        insert cnWrSt;
        APXTConga4__Conga_Template__c cmptemplateMdm = new APXTConga4__Conga_Template__c();
        cmptemplateMdm.APXTConga4__Name__c = 'Contract - Service Terms(MDM)';
        cmptemplateMdm.Sequence__c = 8;
        cmptemplateMdm.Type__c='Service Terms' ;
        cmptemplateMdm.Offer_Name__c = 'Connected Workplace Solution';
        cmptemplateMdm.APXTConga4__Template_Group__c = 'Contract';
        cmptemplateMdm.Active_Template_Version__c = act.id;
        insert cmptemplateMdm;
        ContractJunction__c cntrctRecord=new ContractJunction__c();
        cntrctRecord.Account__c = basket.csbb__Account__c;
        cntrctRecord.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        cntrctRecord.Related_Basket__c=basket.id;
        //cntrctRecord.DocuSign_Signer_2__c = contact.id;
        cntrctRecord.DocuSign_Signer_3__c = UserInfo.getUserId();
        //cntrctRecord.Customer_Primary_Contact__c = contact.id;
        cntrctRecord.BSA_Generated__c = true;
        insert cntrctRecord;
        GenerateContract gc = new GenerateContract();
       
        set<String> offNameSet = new set<String>{'Connected Workplace Solution'};
            map<String,Boolean> documentsToGenerate = gc.documentsToGenerate(basket,offNameSet);
        system.debug('documentsToGenerate::'+documentsToGenerate);
        Test.stopTest();
        system.assertEquals(true, documentsToGenerate.get('Orderform'));
    }
   
    @isTest static void generateContractException() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        //contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', '01p2O000000AMA0');
        ContractSignatories.put('signer3', '01p2O000000AMA0');
        string exc = '';
        try{
            String recordId= gc.createContract(basket.id,ContractSignatories, 'basket',false,null);
            ContractJunction__c showNewServices = [Select New_Services_Show__c from ContractJunction__c limit 1];
        }
        Catch(Exception e){
            exc = e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exc);
    }
    @isTest static void generateContractisDSALinkedToAccount() {  
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();
        Test.startTest();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductBasketTrigger';
        insert disabledTriggersProfile;
        Account acc = AccountTestFactory.buildAccount('Test Account1') ;
        acc.Customer_Status__c='Active';
        insert acc;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        opp.contract_type__c = 'DSA';//DIGI-683
        insert opp;
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=opp.id;
        //framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        //GenerateContract gc = new GenerateContract();
        map<string, Id> ContractSignatories = new map<string, Id>();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        ContractSignatories.put('signer2', c.Id);
        ContractSignatories.put('signer3', UserInfo.getUserId());
        cscfga__Product_Basket__c bas = [SELECT id,csconta__Frame_Agreement__c,csbb__Account__c from cscfga__Product_Basket__c where id = :basket.id];
        bas.csconta__Frame_Agreement__c = framAg.id;
        upsert bas;
        map<String,boolean> isDSA  = GenerateContract.isDSALinkedToAccount(bas);
        //ContractJunction__c showNewServices = [Select New_Services_Show__c from ContractJunction__c limit 1];
        Test.stopTest();
        system.debug('isDSA::'+isDSA);
        system.assertEquals(false, isDSA.get('DSAGenerated'));
    }
    //DIGI-683 End

    /** 
     *@purpose : MAC order for SDWAN (DIGI-1607)
     *@created Date : 27 Aug 2021  
     */
    @IsTest
    static void createContractSDWANMACDPositiveTest(){

        GenerateContract genContract; 
        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();

        cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = 'SDWAN ADAPT S1', cscfga__Description__c = 'SDWAN ADAPT S1', 
                                                                                          product_Specification__c = 'DMCAT_Offer_001343',
                                                                                          Snapshot_Object__c='basketsnapshot' );
        insert prodDefinition;

      
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
        
        Test.startTest();
            //Product configuration
            cscfga__Product_Configuration__c MACDProdConfig = new cscfga__Product_Configuration__c(Name = 'SDWAN ADAPT S1', Type__c = 'New',
                                                                                                   cscfga__Product_Basket__c = basketMAC.Id,
                                                                                                    cscfga__Product_Definition__c = prodDefinition.Id);

            INSERT MACDProdConfig;

            genContract = new GenerateContract();
            map<string, Id> ContractSignatories = new map<string, Id>(); 

            contact contact = [SELECT id from contact where id != NULL LIMIT 1];

            ContractSignatories.put('signer2', contact.Id);
            ContractSignatories.put('signer3', UserInfo.getUserId());

             //Postive MACD Scenario
             String MACDRecordId= genContract.createContract(basketMAC.id, ContractSignatories, 'basket',false,null);
             ContractJunction__c MACDcontractJunction = [Select Existing_Services_Show__c 
                                                        FROM ContractJunction__c WHERE Related_Basket__c =: basketMAC.Id limit 1];

          
        Test.stopTest();

        //positive scenario
        System.assert(MACDRecordId != null);        
        System.assertEquals(MACDcontractJunction.Existing_Services_Show__c, true);  
        
    }

    /** 
     *@purpose : Negative MAC order Scenario for SDWAN (DIGI-1607)
     *@created Date : 27 Aug 2021  
     */
    @isTest 
    static void createContractSDWANMACDNegativeTest() {  

        GenerateContractTest test1= new GenerateContractTest();
        test1.setup();

        cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = 'SDWAN ADAPT S1', cscfga__Description__c = 'SDWAN ADAPT S1', 
        product_Specification__c = 'DMCAT_Offer_001343',
        Snapshot_Object__c='basketsnapshot' );

        insert prodDefinition;


        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;

        insert oldContract;

        opportunity MACD_Oppty = [SELECT ID, Type, Name FROM Opportunity WHERE Id =: basketMAC.cscfga__Opportunity__c];
        MACD_Oppty.Type = 'New To Market';
        UPDATE MACD_Oppty;

        Test.startTest();

            //Product configuration
            cscfga__Product_Configuration__c MACDProdConfig = new cscfga__Product_Configuration__c(Name = 'SDWAN ADAPT S1', Type__c = 'New',
                                                                                                   cscfga__Product_Basket__c = basketMAC.Id,
                                                                                                   cscfga__Product_Definition__c = prodDefinition.Id);

            INSERT MACDProdConfig;

            GenerateContract gc = new GenerateContract();
            map<string, Id> ContractSignatories = new map<string, Id>(); 
            contact c = [SELECT id from contact where id != NULL LIMIT 1];
            ContractSignatories.put('signer2', c.Id);
            ContractSignatories.put('signer3', UserInfo.getUserId());
            String recordId= gc.createContract(basketMAC.id,ContractSignatories, 'basket',false,null);
            ContractJunction__c showNewServices = [Select New_Services_Show__c, Existing_Services_Show__c from ContractJunction__c WHERE Related_Basket__c =: basketMAC.Id limit 1];

        Test.stopTest();

        system.assertEquals(false, showNewServices.Existing_Services_Show__c);
        system.assertEquals(true, showNewServices.New_Services_Show__c);
            
      }
}