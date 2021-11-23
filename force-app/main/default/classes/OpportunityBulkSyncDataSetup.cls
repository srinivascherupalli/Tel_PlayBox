@IsTest
public class OpportunityBulkSyncDataSetup{
    
    public static void testDataSetup(){

        //Create accounts
        List<Account> accountList = new List<Account>();

        for(Integer i= 0; i < 1; i++){
            Account acc1 = AccountTestFactory.buildAccount('Test Basket Sync Account '+i);
            accountList.add(acc1);
        }

        insert accountList;


        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;


        //CREATE OPPORTUNITY
        List<Opportunity> opptyList = new List<Opportunity>();
        for(Integer j = 0; j < 1; j++){
            //(Integer)(math.rint(j/20))
            Opportunity opp0  = ProductTestFactory.getOpportunity(accountList[0],pb);
            opp0.Name = 'Test Basket BulkSync '+j;
            opp0.StageName = 'Enriched';
            //Opp0.Won_Lost_Reason__c = 'Pricing';
            opp0.Pricebook2Id = '01s28000006ePHb';
            opptyList.add(opp0);
        }

        insert opptyList;
        
        cscfga__Product_Category__c  prodCat = ProductTestFactory.buildProductCategory();
        insert prodCat;
        
        //CREATE BASKETS
        List<cscfga__Product_Basket__c> baskets = new List<cscfga__Product_Basket__c>();
        for(Integer b = 0; b < 1; b++){
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = accountList[0].id; //(Integer)(math.rint(b/20))
            basket.Name = 'Test Class Basket '+b;
            basket.cscfga__Basket_Status__c = 'Valid';
            
            basket.cscfga__Opportunity__c = opptyList[b].id;
            basket.csordtelcoa__Basket_Stage__c = 'Enriched';
            baskets.add(basket);
        }
        
        insert baskets;

        cscfga__Product_Definition__c PD = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        PD.csordtelcoa__Product_Type__c = 'Subscription';
        PD.cscfga__Active__c = true;
        PD.cscfga__Product_Category__c = prodCat.Id;
        PD.cscfga__Default_Contract_Term__c = 12;
        PD.cscfga__Default_Contract_Term_Period__c = 'Month';
        insert PD;

        List<cscfga__Attribute_Definition__c> lstAttrDefs = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ATTDEF1 = ProductTestFactory.buildAttributeDefinition('Quantity', PD.Id);
        ATTDEF1.cscfga__Is_Line_Item__c = true;
        ATTDEF1.cscfga__Base_Price__c = 10;
        lstAttrDefs.add(ATTDEF1);
        
        cscfga__Attribute_Definition__c ATTDEF2 = ProductTestFactory.buildAttributeDefinition('PartnerName', PD.Id);
        //insert ATTDEF2;
        ATTDEF2.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF2);

        /*cscfga__Attribute_Definition__c ATTDEF3 = ProductTestFactory.buildAttributeDefinition('MaxDownSpeed', PD.Id);
        //insert ATTDEF3;
        ATTDEF3.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF3);

        cscfga__Attribute_Definition__c ATTDEF4 = ProductTestFactory.buildAttributeDefinition('MaxUpSpeed', PD.Id);
        //insert ATTDEF4;
        ATTDEF4.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF4);

        cscfga__Attribute_Definition__c ATTDEF5 = ProductTestFactory.buildAttributeDefinition('TechType', PD.Id);
        //insert ATTDEF5;
        ATTDEF5.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF5);       */
        insert lstAttrDefs;

        
        //CREATE CONFIGS
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
        List<csbb__Product_Configuration_Request__c> pcrList = new List<csbb__Product_Configuration_Request__c>();

        for(Integer c = 0; c < 2; c++){

            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

            cscfga__Product_Configuration__c PC = ProductTestFactory.buildProductConfig(PD.Id);
            PC.cscfga__Product_Basket__c = baskets[0].id;//(Integer)(math.rint(c/2))
            PC.cscfga__Product_Definition__c = PD.Id;
            PC.cscfga__Index__c = 0;
            PC.csexpimp1__guid__c = guid;
            PC.cscfga__Configuration_Status__c = 'Valid';
            PC.cscfga__Key__c = h; 
            PC.cscfga__Description__c = PD.Name;
            PC.Name = PD.Name;
            configList.add(PC);
        }

        insert configList;
        

        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        
        for(cscfga__Product_Configuration__c config:configList){
            
            Blob r = Crypto.GenerateAESKey(128);
            String s = EncodingUtil.ConvertTohex(r);
            String t = s.SubString(0,8)+ '-' + s.SubString(8,12) + '-' + s.SubString(12,16) + '-' + s.SubString(16,20) + '-' + s.substring(20);


            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('ProductName', '100.00', config.id);
            attr0.cscfga__Attribute_Definition__c = ATTDEF1.Id;
            attr0.Name = 'ProductName';
            attr0.cscfga__Display_Value__c = 'BPOND ADSL NON PRESELECT PRO INSTAL 1 PORT';
            attr0.csexpimp1__guid__c = t;
            attr0.cscfga__Is_Line_Item__c = false;
            attr0.cscfga__Key__c = s;
            attr0.cscfga__Product_Configuration__c = config.id;
            attr0.cscfga__Recurring__c = false;
            attr0.cscfga__Value__c = 'BPOND ADSL NON PRESELECT PRO INSTAL 1 PORT';
            attr0.cscfga__Cascade_value__c = false;
            attList.add(attr0);

            /*cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config.id);
            attr1.cscfga__Attribute_Definition__c = ATTDEF2.Id;
            attr1.cscfga__Line_Item_Description__c = 'PartnerName';
            attr1.cscfga__Value__c = '20';
            attList.add(attr1);*/

            /*cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('MaxDownSpeed', '400.00', config.id);
            attr2.cscfga__Attribute_Definition__c = ATTDEF3.Id;
            attr2.cscfga__Line_Item_Description__c = 'MaxDownSpeed';
            attr2.cscfga__Value__c = '30';
            attList.add(attr2);

            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('MaxUpSpeed', '300.00', config.id);
            attr3.cscfga__Attribute_Definition__c = ATTDEF4.Id;
            attr3.cscfga__Line_Item_Description__c = 'MaxUpSpeed';
            attr3.cscfga__Value__c = '10';
            attList.add(attr3);

            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('TechType', 'NBN', config.id);
            attr4.cscfga__Attribute_Definition__c = ATTDEF5.Id;
            attr4.cscfga__Line_Item_Description__c = 'TechType';
            attr4.cscfga__Value__c = '10';
            attr4.cscfga__Price__c = 10;
            attList.add(attr4);*/
            
         }

         insert attList;
        
        for(Integer d = 0; d < 2; d++){

            csbb__Product_Configuration_Request__c PCR2 = ProductTestFactory.buildConfigRequest(baskets[0].Id, configList[d].Id);//(Integer)(math.rint(d/2))
            pcrList.add(PCR2);
        }

        insert pcrList;
        System.debug('<><> pcrList == ' + pcrList);

    }
}