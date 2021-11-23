/**
* Created by tihomir.baljak on 5/23/2019.
Version No  Author                  Date
1           Monali                Aug  2020       Enable POR - DPG-2228
2           Aditya                Oct  2020       Edge: EDGE-176833
3       lavish                  Nov 2020        EDGE-173035 validation to avoid mix basket
4.      shubhi                  12.02.2021      EDGE-170016 restrict solutions in case f inflight
5.      Dheeraj Bhatt           15 Jan 2021     EDGE-187684-Enhancement to Migration User Profile to add the ability to configure Adaptive Care Solution
6.      Prince Malik            12.02.2021      P2OB-11861 Only one solution of type "Standard Product Solution" is allowed per product basket 
7.      Shishir Pareek          12.02.2021      P2OB-Only "Standard Product Solution" must be available for opportunities having "Standard" product type in Solution console
8.      Shishir Pareek          12.02.2021      P2OB-"Standard Product Solution" must not be available for opportunities having "Digitized" product type in Solution console
9.      Shishir Pareek          02.03.2021      P2OB-13104 "<CloudSense> Standard Solution | QA2 org | Change in solution names allows creation of another standard product solution"
10.     Vamsi Krishna Vaddipalli 18FEB2021      Added CHOWN condition for EDGE-152457
11.     Shubhi V                22.03.2021      EDGE-210587
12. 	Srujana D				12.05.2021		P2OB-12924 <Cloudsense><Solution Console> Allow multiple Standard Product Solutions to be added to the console
13.	  Payel Ganguly		22.09.2021   DIGI-18412 Hiding the Velocloud Interconnect Solution if one is already present in the Basket
14.	  Radhika Uppal		23.09.2021   DIGI-931 Hiding the SecureEdge and VeloCloud Solution if one is already present in the Basket
15. 	Monali M				22.09.2021		DIGI-5561 Only one solution for the AMMS lifecycle managemnet
16.    Rozi Firdaus             13.10.2021      DIGI-21829 Hide IoT Connectivity offer from partner channel 
*/

global with sharing class SCProductCatalogueFilter implements  cssmgnt.ProductCatalogueFilter {
    public static String accountId = '';
    public Boolean isNonComBasket = false ; //Edge: EDGE-176833: Able to view only non commercial solutions in non commercial basket solution catalogue list
    
    global List<cssmgnt.SolutionComponent> filter(List<cssmgnt.SolutionComponent> definitions, String params) {        
        
        try {
            //EDGE-128933 Start
            map<String, String> mpPSOfferId = new map<String, String>();
            map<String, Boolean> mpPSOffers = new map<String, Boolean>();
            //Edge: EDGE-176833: Able to view only non commercial solutions in non commercial basket solution catalogue list
            List<string>  listofNonComSDName = new List<string>();
            
            system.debug('the pramas BasketId ==>'+params);
            // Custom Setting to Store  products are to be added for the filter condition.
            list<PS_Solution_Filter__c> psSolList = PS_Solution_Filter__c.getall().values();
            list <csord__Solution__c> countBasket = new list<csord__Solution__c>(); //DIGI-18412/DIGI-931
            list <String> sdwanList  =new list <String>(); //DIGI-18412
            list <String> secureEdge  =new list <String>();  //DIGI-931
            list <String> veloCloud  =new list <String>();   //DIGI-931
			list <csord__Subscription__c> countAcc = new list<csord__Subscription__c>(); //DIGI-18412/DIGI-931
            for(PS_Solution_Filter__c ps :psSolList ){
                mpPSOfferId.put(ps.Product_Definition_Name__c, ps.Offer_Id__c);
                if(ps.Hide_Default__c == true){
                    mpPSOffers.put(ps.Offer_Id__c,false);
                }
                else{
                    mpPSOffers.put(ps.Offer_Id__c,true);
                }
                
            }//EDGE-128933 End
            system.debug('the mpPSOffers==>'+mpPSOffers);
            if (params == null)
                return definitions;
            
            
            Map< String, Object > paramMap = (Map< String, Object >)JSON.deserializeUntyped(params);
            if (paramMap == null) {
                return definitions;
            }
            
            String basketId = (String)paramMap.get('basketId');
            //P2OB-12189 - "Standard Product Solution" must not be available for opportunities having "Digitized" product type in Solution console
            //P2OB-12188 - <Cloudsense><Solution Console> Only "Standard Product Solution" must be available for opportunities having "Standard" product type in Solution console
            String opportunityProdType = '';
            System.debug('basketId: ' + basketId);
            
            if (basketId == null || basketId.length() == 0)
            {
                return definitions;
            }else
            {
                cscfga__Product_Basket__c basket = Model_ProductBasket.getProductBasket(basketId); //EDGE-170016
                if(basket!= null ){
                    accountId =basket.Account_Id__c;
                    //P2OB-12189 - "Standard Product Solution" must not be available for opportunities having "Digitized" product type in Solution console
                //P2OB-12188 - <Cloudsense><Solution Console> Only "Standard Product Solution" must be available for opportunities having "Standard" product type in Solution console
                    opportunityProdType = basket.cscfga__Opportunity__r.Product_Type__c;
            //Edge: EDGE-176833: Able to view only non commercial solutions in non commercial basket solution catalogue list
                    if(basket.cscfga__Opportunity__c == null){
                        isNonComBasket = true;
                    }
                    //EDGE-170016,Added OR condition for EDGE-152456 start-- //EDGE-210587

                     if(basket.RecordType.name=='Inflight Change'|| (String.isNotBlank(basket.Opportunity_Type__c) && basket.Opportunity_Type__c.containsIgnoreCase('CHOWN'))){//Added CHOWN condition for EDGE-152457 on 18feb2021 by Vamsi
                        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
                        return filteredDefinitions;


                }
                    //EDGE-170016,Added OR condition for EDGE-152456 ends---
            }

            
            }
            //EDGE-173035 start

            List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();

            List<Marketable_Offer__c>  marOfferList = SCProductCatalogueFilterUtility.getMarketableOffer(basketId);

            



            for(Marketable_Offer__c mOffers :marOfferList ){
                mpPSOfferId.put(mOffers.Solution_Template__c,mOffers.Offer_ID__c);
                mpPSOffers.put(mOffers.Offer_ID__c,false);
            }
            //EDGE-173035 end
            system.debug('mpPSOffers==>'+mpPSOffers);
            
            // EDGE-119578 Raviteja As system, I must be able to restrict visibility of off
            mpPSOffers = arePSOffersEligible(basketId, mpPSOffers);     
            system.debug('PK mpPSOffers==>'+mpPSOffers);
            System.debug('accountId: ' + accountId);
            
            if (accountId == null || accountId.length() == 0)
                return definitions;
            
            /* added search text for ngUC */
            String searchCWPText = '%'+System.Label.Connected_Workplace+'%';
            String searchNGUCText = '%'+System.Label.NextGenUC+'%';
            String searchIoTText = '%'+System.Label.InternetOfThings+'%';  //Manish Added for DPG-902:added search text for IoT
            String searchBAU_SPC = '%'+System.Label.StandardProductCatalog+'%'; //Prince Added for P2OB-11861 : Added search text for Standard Product Catalog
            String searchIterConText = '%'+System.Label.SDWANInterConnection_SD+'%'; //DIGI-18412
            String searchSecureEdgeConText = '%'+System.Label.SecureEdgeSolution+'%'; //DIGI-931
            String searchVeloCloudConText = '%'+System.Label.VeloCloudSolution+'%'; //DIGI-931
            //P2OB-12189 - "Standard Product Solution" must not be available for opportunities having "Digitized" product type in Solution console
            //P2OB-12188 -  "Standard Product Solution" must be available for opportunities having "Standard" product type in Solution console
            String searchAMMSLCText = '%'+System.Label.AMMSLC+'%';  //Added for DIGI-5561:added search text for AMMS LC 
            Integer countBAU_SC;
            if (opportunityProdType != null && opportunityProdType != '' && opportunityProdType.equals('Non Modular')) {
              //Prince added for P2OB-11861 query to count Standard Product Catalog solutions in basket Start
                countBAU_SC = [
                  SELECT count()
                  FROM csord__Solution__c
                  WHERE cssdm__product_basket__c=:basketId AND 
          cssdm__product_basket__r.cscfga__Opportunity__r.Product_Type__c = 'Non Modular'
              ];

            
            //Prince added for P2OB-11861 query to count Standard Product Catalog solutions in basket End    
            }
            //Changes Start for Adaptive Care (DPG-1878)
            Boolean isPartnerOfRecord = getPORs.isPORADC(accountId,'Active');
            //Changes End for Adaptive Care (DPG-1878)
            
            /* updated SOQL query for ngUC */
            Integer countProducts = [
                SELECT count()
                FROM csord__Solution__c
                WHERE ((csord__Account__c =:accountId) OR (cssdm__product_basket__c=:basketId)) and (Name LIKE :searchCWPText or Name =:System.Label.NextGenUC)
            ];
            system.debug('countProducts'+countProducts);
            // Bhargava Updated the like condition for searchNGUCText           
            //Manish Added for DPG-902:SOQL query to count IoT in basket
            Integer countIoT = [
                SELECT count()
                FROM csord__Solution__c
                WHERE cssdm__product_basket__c=:basketId and Name Like: searchIoTText
            ];
            
            //Added for DIGI-5561:SOQL query to count AMMS LC in basket
            Integer countAMMSLC = [SELECT count() FROM csord__Solution__c WHERE cssdm__product_basket__c=:basketId and Name Like: searchAMMSLCText];

            System.debug('CW count: ' + countProducts);

            //DIGI-18412:SOQL query to count SDWAN VPN Interconnect in basket at basket level
            countBasket = [
                SELECT cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c
                FROM csord__Solution__c
                WHERE cssdm__product_basket__c=:basketId and cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c in (:System.Label.SDWAN_Interconnect_Offer,:System.Label.VELOCLOUD_OFFER,:System.Label.SECUREEDGE_OFFER)
            ];
			System.debug('accountId: ' + countBasket);
			//DIGI-18412/931:SOQL query to count SDWAN VPN/VeloCloud/SecureEdge Interconnect in basket at basket level
            countAcc = [
                SELECT ConfigSpecID__c
                FROM csord__Subscription__c
                WHERE csord__Account__c=:accountId and ConfigSpecID__c in (:System.Label.SDWAN_Interconnect_Offer,:System.Label.VELOCLOUD_OFFER,:System.Label.SECUREEDGE_OFFER) and csord__Status__c = : System.label.active
            ];

            for(csord__Solution__c sol: countBasket){
                if(sol.cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c == System.Label.SDWAN_Interconnect_Offer){
                    sdwanList.add(sol.cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c);
                }
                if(sol.cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c == System.Label.VELOCLOUD_OFFER){
                    veloCloud.add(sol.cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c);
                }
                if(sol.cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c == System.Label.SECUREEDGE_OFFER){
                        secureEdge.add(sol.cssdm__solution_definition__r.cssdm__product_definition__r.product_Specification__c);
                }
            }

            for(csord__Subscription__c subs: countAcc){
                if(subs.ConfigSpecID__c == System.Label.SDWAN_Interconnect_Offer){
                    sdwanList.add(subs.ConfigSpecID__c);
                }
                if(subs.ConfigSpecID__c == System.Label.VELOCLOUD_OFFER){
                    veloCloud.add(subs.ConfigSpecID__c);
                }
                if(subs.ConfigSpecID__c == System.Label.SECUREEDGE_OFFER){
                        secureEdge.add(subs.ConfigSpecID__c);
                }
            }//End --- DIGI-18412/DIGI-931
            
            if (countProducts == 0 && /*isPSEligibleflag==true && isMSEligibleflag==true && */ FeatureManagement.checkPermission('Partner_User') && !(mpPSOffers.Values().Contains(false)) && isPartnerOfRecord == true )
                return definitions;
            
            Map<string,string> porMap = new Map<String,String>();
           
            for(POR_Solution_Filter__mdt porInst:[select DeveloperName,MasterLabel,POR_Solution_Name__c FROM POR_Solution_Filter__mdt])
            {
                porMap.put(porInst.POR_Solution_Name__c,porInst.POR_Solution_Name__c);
            }
            //Edge: EDGE-176833: Able to view only non commercial solutions in non commercial basket solution catalogue list
            listofNonComSDName = getNonComSolDefinition(basketId);
             ///EDGE-176833 end 
            //List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
            System.debug('definitions++++' + definitions.size());
            System.debug('SCProductCatalogueFilter params' + params);
            
            //EDGE-185052 changes by Abhishek From Osaka Team-----------START----------
            //Description: To display only AM solution for Migration BOH User and opportunity type as Migration
            String profileName = getProfileName();
            String opptyType = getOpptyType(basketId);
            //getSolutionData method to fetch data from Custom Setting based as a part of EDGE-185052
            Solution_Console_Filter__c solutionConsoleFilter = getSolutionData('Adaptive_Mobility');
            //EDGE-185052 changes by Abhishek From Osaka Team-----------END----------
            
            for (cssmgnt.SolutionComponent sc : definitions) 
            {
                //-----START------Added as a part of EDGE-187319 by Abhishek from Osaka Team
                //Description: To display only AM solution for Migration BOH User and opportunity type as Migration

                //EDGE-187684-Dheeraj Bhatt-Enhancement to Migration User Profile to add the ability to configure Adaptive Care Solution

                system.debug('TestSolutionConsoleFilters'+solutionConsoleFilter);
                SYstem.debug('SC Name' + sc.name);
                //P2OB-12189 - "Standard Product Solution" must not be available for opportunities having "Digitized" product type in Solution console
              //P2OB-12188 - <Cloudsense><Solution Console> Only "Standard Product Solution" must be available for opportunities having "Standard" product type in Solution console
                //Only for Product Type Standard
                if(opportunityProdType != null && opportunityProdType != '' && opportunityProdType.equals('Non Modular')) {
          if(countBAU_SC == 0) {
                        if (sc.name.contains(System.Label.StandardProductCatalog)) {
                          filteredDefinitions.add(sc);    
                        }
          }else if( countBAU_SC != 0) {
            if (sc.name.contains(System.Label.StandardProductCatalog))
            {
              /*System.debug('Coming in Prince class: ');
              System.debug('Removing: ' + sc.name);
              continue;*/
			  filteredDefinitions.add(sc);//P2OB-12924:Allow multiple Standard Product Solutions
            }
          }
        }
                //P2OB-12188,P2OB-12189 changes end
                //This block is get all the soltuion other than standard
                else {

                   if(profileName == solutionConsoleFilter.Profile__c && opptyType == solutionConsoleFilter.Opportunity_Type__c){
                    for(String solutionFilter:solutionConsoleFilter.Solution_Name__c.split(';')){
                        if(sc.name == solutionFilter){
                            filteredDefinitions.add(sc);


                        }

                        }
                         system.debug('filteredDefinitions??'+filteredDefinitions);
                    }
                    
                //-----END------Added as a part of EDGE-187319 by Abhishek from Osaka Team
                else{
                System.debug('sc.name---->: ' + sc.name);
                //Changes Start for Adaptive Care (DPG-1878)
                if(porMap.containsKey(sc.name) && mpPSOffers.ContainsKey(mpPSOfferId.get(sc.name)) && mpPSOffers.get(mpPSOfferId.get(sc.name)) == true && isPartnerOfRecord == false)
                {
                    continue;
                }
                //Changes End for Adaptive Care (DPG-1878)
                
                // Rozi Added for DIGI-21819: Hide IoT Connectivity offer from partner channel
                if(sc.name == 'IoT connectivity' && FeatureManagement.checkPermission('Partner_User')){
                    continue;
                } 
                if(sc.name == 'IoT solutions' && FeatureManagement.checkPermission('Partner_User')){
                    continue;
                }
                if(sc.name == 'IoT Account Support' && FeatureManagement.checkPermission('Partner_User')){
                    continue;
                }// End DIGI-21819
                if( countProducts != 0)
                {
                    if (sc.name.contains(System.Label.Connected_Workplace) || sc.name.contains(System.Label.NextGenUC)) 
                    {
                        System.debug('Removing: ' + sc.name);
                        continue;
                    }
                }
                
                //Manish Added for DPG-902:Condition to break loop if IoT count is more than one
                if( countIoT != 0)
                {
                    if (sc.name.contains(System.Label.InternetOfThings))
                    {
                        System.debug('Removing: ' + sc.name);
                        continue;
                    }
                }

                 //Added for DIGI-5561:Condition to break loop if AMMS LC count is more than one
                 if( countAMMSLC != 0){
                    if (sc.name.contains(System.Label.AMMSLC)){
                        System.debug('Removing: ' + sc.name);
                        continue;
                    }
                }

                //DIGI-18412
                if(!sdwanList.isEmpty())
              {
                  //System.debug('sc.productDefinitionId: ' + sc.productDefinitionId);
                  //System.debug('sc.schemaName: ' + sc.schemaName);
                  //System.debug('Inside LOL');
                  //System.debug('Inside LOL'+ sc.cssdm__product_definition__r.id);
                  if (sc.schemaName.contains(System.Label.SDWANInterConnection_SD))/* && opptyType.equals('New To Market'))*/
                  {
                      System.debug('RemovingSDWAN: ' + sc.name);
                      continue;
                  }
              }
              //DIGI-931
              if(!secureEdge.isEmpty())
              {
                  //System.debug('Removing_LOL: ' + sc.name);
                  if (sc.schemaName.contains(System.Label.SecureEdgeSolution))/* && opptyType.equals('New To Market'))*/
                  {
                      System.debug('RemovingSecureEdge: ' + sc.name);
                      continue;
                  }
              }
              //DIGI-931
              if (!veloCloud.isEmpty())
              {
                  //System.debug('Removing_LOL: ' + sc.name);
                  if (sc.schemaName.contains(System.Label.VeloCloudSolution))/* && opptyType.equals('New To Market'))*/
                  {
                      System.debug('RemovingVeloCloud: ' + sc.name);
                      continue;
                  }
              }
                
                //Prince added for P2OB-11861 : Condition to break loop if Standard Product Catalog count>1 in basket Start
                System.debug('countBAU_SC: '+ countBAU_SC);

                
                if( countBAU_SC != 0)

                {
                    if (sc.name.contains(System.Label.StandardProductCatalog))
                    {
                        System.debug('Coming in Prince class: ');
                        System.debug('Removing: ' + sc.name);
                        continue;
                    }
                }
                
                //Prince added for P2OB-11861 : Condition to break loop if Standard Product Catalog count>1 in basket End
                
                //Filtering Partner Offers based on Custom Settings data: PS Solution Filter
                if(mpPSOffers.Values().Contains(false))//EDGE-128933 
                {
                    system.debug('mpPSOfferId.get(sc.name)'+mpPSOfferId.get(sc.name));
                    if(mpPSOffers.ContainsKey(mpPSOfferId.get(sc.name)) && mpPSOffers.get(mpPSOfferId.get(sc.name)) == false)
                    {
                        System.debug('Removing in else: ' + sc.name);
                        continue;
                    }
                }  
                //Edge: EDGE-176833: Able to view only non commercial solutions in non commercial basket solution catalogue list--
                if(isNonComBasket && listofNonComSDName!=null && !listofNonComSDName.contains(sc.name)){ 
                    System.debug('SCName++++' + sc.name); 
                    continue;
                }
                if(!isNonComBasket && listofNonComSDName!=null && listofNonComSDName.contains(sc.name))
                {
                    System.debug('InsideComBasket++++' + sc.name);
                    continue;
                }
        ///EDGE-176833 end 
                filteredDefinitions.add(sc);
                
            }
            }
            System.debug('FiltereDefinitions++++' + filteredDefinitions);
           
            }
            return filteredDefinitions;
        } catch (Exception e) {
            System.debug('Exception occurred while filtering product catalogue : ' + e.getMessage());
            return definitions;
        }
    }
    
    //EDGE-119578- Remove Professional Service and Managed Service offers if the User doesn't have "Partner User" custom permission 
    public static map<String, Boolean> arePSOffersEligible(String basketId, map<String, Boolean> mpPSOffers){
        map<String, Boolean> ConfigMap = new map<String, Boolean>(); //Map for product added to the basket
        map<String, Boolean> ActiveSubscriptionMap = new map<String, Boolean>();// Map for product added to the Subscription
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        try{
            prodConfigList = [SELECT id,Name,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Basket__r.Name,Type__c,
                              cscfga__Product_Basket__r.csbb__Account__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,
                              Marketable_Offer__r.Offer_ID__c,Marketable_Offer__r.Name, cscfga__Product_Basket__c,Marketable_Offer__r.OfferDefinationName__c,
                              cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Record_Type__c,OfferName__c
                              from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=: basketId and Marketable_Offer__r.Offer_ID__c IN :mpPSOffers.keySet()];        
            System.debug('prodConfigList'+prodConfigList);        
            
            
            for(cscfga__Product_Configuration__c pc :prodConfigList){
                // if(pc.Marketable_Offer__r.Name != System.Label.Adaptive_Care)
                ConfigMap.put(pc.Marketable_Offer__r.Offer_ID__c, false);
            }

            List<csord__Subscription__c>  SubrList=[SELECT id,csord__Order__c,MarketableOffer__r.Offer_ID__c FROM csord__Subscription__c WHERE csord__Account__c=:accountId AND (Sub_Status__c='Active' OR csord__status__c = 'Active') AND MarketableOffer__r.Offer_ID__c IN:mpPSOffers.keySet()];
            
            for(csord__Subscription__c sc :SubrList){
                ActiveSubscriptionMap.put(sc.MarketableOffer__r.Offer_ID__c, false);  
            }
            
            list<PS_Solution_Filter__c> psSolList = PS_Solution_Filter__c.getall().values();
            
            //Check for handling parent product added to basket or have active subscription to enable the offer   eg: PSMDM has to be part of basket or have active subscription to account to enable MDM PS          
            for(PS_Solution_Filter__c ps :psSolList ){
                if(ps.Offer_to_Check__c != null && FeatureManagement.checkPermission('Partner_User') && (ActiveSubscriptionMap.get(ps.Offer_ID__c) == false || ConfigMap.get(ps.Offer_ID__c) == false ) )                
                {  
                    mpPSOffers.put(ps.Offer_to_Check__c,true);          
                }
            }
            //Check for handling offer display based on Custom setting configuration "PS Solution Filter" based on Product COnfiguraions added to basket and Active subscriptions to Account.
            for(PS_Solution_Filter__c ps :psSolList ){
                if((( ActiveSubscriptionMap.get(ps.Offer_ID__c) == false && ps.Check_Active_Subscriptions__c ==true) 
                    || ( ConfigMap.get(ps.Offer_ID__c) == false && ps.Check_Product_Config__c==true) 
                    || ( ps.Enable_for_Partner_Only__c ==true && !FeatureManagement.checkPermission('Partner_User')))
                   && ps.Offer_to_Check__c == null)  
                {    
                    mpPSOffers.put(ps.Offer_Id__c, false);
                    System.debug('arePSOffersEligible --- inside block'+ ps.Offer_ID__c); 
                }
            }
        }
        catch (Exception e) {
            System.debug('Exception occurred while filtering product catalogue : ' + e.getMessage());
        }
        system.debug('mpPSOffers'+mpPSOffers);
        return mpPSOffers;
    }
    

     




    //Edge: EDGE-176833: Able to view only non commercial solutions in non commercial basket solution catalogue list
     public static list<string> getNonComSolDefinition(String basketId){
    List<String> listofSolutionDefinition = new List<String>();
    try{
      List<Marketable_Offer__c>  marOfferList= [SELECT isNonChargeable__c, Solution_Template__c from Marketable_Offer__c where isNonChargeable__c = true];
      for(Marketable_Offer__c mo :marOfferList){
              listofSolutionDefinition.add(mo.Solution_Template__c);
            }
                }catch(Exception e){
      system.debug('exception in catalogue filter non com'+e);
    }
    return listofSolutionDefinition;
    }
            /*-------------------------------------------------------- 
EDGE-185052
Description: Method to fetch profile of logged in User to filter AM solution
Developer: Abhishek
Team: Osaka
--------------------------------------------------------*/
    public static String getProfileName(){
        
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName'+profileName);
        
        return profileName;   


    }

/*-------------------------------------------------------- 
EDGE-185052
Description: Method to fetch Opporunity Type association to Basket to filter AM solution.
Developer: Abhishek
Team: Osaka
--------------------------------------------------------*/
    
    public static String getOpptyType(String basketId){
        String opptyType;
        if(basketId!= null){
            cscfga__Product_Basket__c basketRec = [select  cscfga__Opportunity__r.Type from cscfga__Product_Basket__c where id =:basketId LIMIT 1];
            opptyType = basketRec.cscfga__Opportunity__r.Type;
            System.debug('Opportunity Type = '+opptyType);
        }
        return opptyType;
    }
    
    /*-------------------------------------------------------- 
EDGE-185052
Description: Method to fetch profile,opportunity type and solution Name from Solution_Console_Filter__c custom setting
Developer: Abhishek
Team: Osaka
--------------------------------------------------------*/
    public static Solution_Console_Filter__c getSolutionData(String keyValue){
        Solution_Console_Filter__c solutionConsoleRec = Solution_Console_Filter__c.getValues(keyValue);
        System.debug('Custom Setting Rec:' +solutionConsoleRec);
        
        return solutionConsoleRec;
    }
}