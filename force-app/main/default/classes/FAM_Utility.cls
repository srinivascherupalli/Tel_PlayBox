/*****************************************************************************************
* ModifiedBy     ModifiedDate     Edge          Description
* Shashank Jadhav   11/03/2021    EDGE-203808   Changes related to the FundConsole Tab Functionality

* Manish Berad      26/04/2021   EDGE-211115 & EDGE-211116 Create DPR Rate Card record in backend to store Rate Card Lines (Rate value and Negotiated Rate value) per tier from FA configuration.
* Ankit Goswami     07/05/2021    EDGE-213653 Bulkification of FAM_Utility constructor and load Contaxt

* Ankush Rana       08/06/2021    EDGE-219116    As a Sales/Partner user, When I have offered Fund (Flexi/Advance or No Fund) for a product during NEW FA journey, Then system should update Fund console data as "Allocated" on FA Activation

* Shivaprasad Patil 25/06/2021    EDGE-219475: Added field Fund Expiry (Fund Term)
* Shashank Jadhav:  13/07/2021    EDGE-221893-Insert Exception Log records with Exception Log Frameworks
************************************************************************************************************************************************/

/**
 * Class to hold various FAM related helper methods.
 */
public with sharing class FAM_Utility {
    //map to hold all negotiated rate card line prices for given FA
    private Map<Id, Decimal> rateCardLineIdToValueMap              = new Map<Id, Decimal>();
    private Map<Id,Id> sourceToFrameAggrementIdMap = new Map<Id,Id>();
    private Map<Id,Map<Id, VolumeAndPricing>> productToVolumeAndPricingbulkMap = new Map<Id,Map<Id, VolumeAndPricing>>();
    private Map<Id,Map<String, FAM_Utility.FundData>> fundConsoleRecordsbulkMap = new Map<Id,Map<String, FAM_Utility.FundData>>();//EDGE-203808-Added new variable Map<String, FAM_Utility.FundData> fundConsoleRecordsMap
    /**
     * Constructor, loads working context.
     * Knows how to find FA id from Ids from these objects:
     *  - csconta__Frame_Agreement__c
     *  - csord__Subscription__c
     *  - csord__Solution__c
     */
    public FAM_Utility(Id sourceId) {
    
        this(new list<Id>{sourceId});
    }
    public FAM_Utility(List<Id> sourceIdList) {
        List<Id> frameAgreementIdList=new List<Id>();
        List<Id>subIdList=new List<Id>();
        List<Id>solIdList=new List<Id>();
        try{//EDGE-221893: Added try block
			system.debug('sourceIdList::'+sourceIdList);
			if (sourceIdList.isEmpty()) {
				return; //invalid value so ignoring it
			} 
			
			for(Id sourceId:sourceIdList){
				if (sourceId.getSobjectType() == Schema.csconta__Frame_Agreement__c.SObjectType) {
					frameAgreementIdList.add(sourceId);
					sourceToFrameAggrementIdMap.put(sourceId,sourceId);
				} else if (sourceId.getSobjectType() == Schema.csord__Subscription__c.SObjectType) {
					subIdList.add(sourceId);
				} else if (sourceId.getSobjectType() == Schema.csord__Solution__c.SObjectType) {
					//get FA Id from subscription related basket
					solIdList.add(sourceId);    
				}
			}
			if(!subIdList.isEmpty()){
				//get FA Id from subscription related basket
				for(csord__Subscription__c sub :[SELECT Id,csordtelcoa__Product_Configuration__c ,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csconta__Frame_Agreement__c FROM csord__Subscription__c WHERE Id IN : subIdList]){
					if (sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csconta__Frame_Agreement__c != null) {
						frameAgreementIdList.add(sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csconta__Frame_Agreement__c);
						sourceToFrameAggrementIdMap.put(sub.id,sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csconta__Frame_Agreement__c);
					}
				}
			}else if(!solIdList.isEmpty()){
					for(csord__Solution__c sol :[SELECT Id, cssdm__product_basket__r.csconta__Frame_Agreement__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csconta__Frame_Agreement__c
														  FROM csord__Solution__c
														  WHERE Id IN : solIdList]){
						if (sol.cssdm__product_basket__r.csconta__Frame_Agreement__c != null) {
							frameAgreementIdList.add(sol.cssdm__product_basket__r.csconta__Frame_Agreement__c);
							sourceToFrameAggrementIdMap.put(sol.id,sol.cssdm__product_basket__r.csconta__Frame_Agreement__c);
						}
					}
			}
			loadContext(frameAgreementIdList);
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','FAM Utility', '', string.join(sourceIdList,','), ex.getMessage(), 'Generation of Agreement Document Failed.',false);
        }//EDGE-221893-End
    }
    /**
     * Modifies received cspmb__Rate_Card_Line__c list by applying negotiated prices if any.
     */
    public List<cspmb__Rate_Card_Line__c> applyRateCardNegotiatedPrices(List<cspmb__Rate_Card_Line__c> rateCardLines) {
        if (rateCardLineIdToValueMap.isEmpty()) {
            //if FA doesn't have any rate card data then return original rate card lines
            return rateCardLines;
        } else {
            //adjust each rate card line to hold negotiated value
            for (cspmb__Rate_Card_Line__c rcl :rateCardLines) {
                //us negotiated value if exists
                rcl.cspmb__rate_value__c = rateCardLineIdToValueMap.get(rcl.Id) != null ? rateCardLineIdToValueMap.get(rcl.Id) : rcl.cspmb__rate_value__c;
            }
        }
        return rateCardLines;
    }
    //overloaded methods for convenience
    public Map<Id, List<cspmb__Rate_Card_Line__c> > applyRateCardNegotiatedPrices(Map<Id, List<cspmb__Rate_Card_Line__c> > idToRateCardLineListMap) {
        if (rateCardLineIdToValueMap.isEmpty()) {
            return idToRateCardLineListMap;
        } else {
            for (id key :idToRateCardLineListMap.keySet()) {
                //reuse implementation
                idToRateCardLineListMap.put(key,applyRateCardNegotiatedPrices(idToRateCardLineListMap.get(key)));
            }
        }
        return idToRateCardLineListMap;
    }
    public Map<Id, VolumeAndPricing> getProductToVolumeAndPricingMap() {
       if(productToVolumeAndPricingbulkMap !=null  && !productToVolumeAndPricingbulkMap.isEmpty())
        return productToVolumeAndPricingbulkMap.Values()[0];
       else
       return new Map<Id, VolumeAndPricing>();
    }
    
    //Added by Shashank-Start
    public Map<String, FAM_Utility.FundData> getFundConsoleCustomMap() {
     if(fundConsoleRecordsbulkMap !=null && !fundConsoleRecordsbulkMap.isEmpty())
        return fundConsoleRecordsbulkMap.Values()[0];
       else
       return new Map<String, FAM_Utility.FundData>();
    }
    //Added by Shashank-End
     public Map<Id,Map<Id, VolumeAndPricing>> getProductToVolumeAndPricingBulkMap() {
        return productToVolumeAndPricingbulkMap;
    }
    public Map<Id,Id>getSourceToFrameAggrementIdMap() {
        return sourceToFrameAggrementIdMap;
    }
   
    public Map<Id,Map<String, FAM_Utility.FundData>>getFundConsoleBulkCustomMap() {
        return fundConsoleRecordsbulkMap;
    }
    /**
     * Loads and sets working context: rateCardLineIdToValueMap
     */
    private void loadContext(List<Id> frameAgreementId) {
        if (frameAgreementId == null) {
            return;
        }
        List<Attachment> faAttachments = [SELECT Id, Body,ParentId FROM Attachment WHERE ParentId IN :frameAgreementId AND Name = 'FrameAgreementAttachment'];
        if (faAttachments.isEmpty()) {
            return;
        }
        
        for(Attachment faAttach : faAttachments){
            Map<Id, VolumeAndPricing> productToVolumeAndPricingMap = new Map<Id,VolumeAndPricing>();
            Map<String, Object> parsedFM = (Map<String, Object>) JSON.deserializeUntyped(faAttach.body.toString());
            Map<String, Object> products = (Map<String, Object>)parsedFM.get('products');
        
            for (String productId : products.keySet()) {
                Map<String, Object> product = (Map<String, Object>)products.get(productId);
                //capture rate card data
                if (product.containsKey('_rateCards')) {
                    Map<String, Object> rateCards = (Map<String, Object>)product.get('_rateCards');
                    //loop over all rate cards and build the Rate card line to new value map
                    for (String rateCardId : rateCards.keySet()) {
                        //finaly we have reached rate card line level of details
                        Map<String, Object> rateCardLines = (Map<String, Object>)rateCards.get(rateCardId);
                        for (String rateCardLineId : rateCardLines.keySet()) {
                            rateCardLineIdToValueMap.put(rateCardLineId, (Decimal)rateCardLines.get(rateCardLineId));
                        }
                    }
                }
                //capture _volume and pricing data
                FAM_Utility.VolumeAndPricing volAndPrice = new FAM_Utility.VolumeAndPricing();
                if (product.containsKey('_volume')) {
                    Map<String, Object> volumeObj = (Map<String, Object>)product.get('_volume');
                    volAndPrice.muc  = (Decimal)volumeObj.get('muc');
                    volAndPrice.mucp = (Decimal)volumeObj.get('mucp');
                    volAndPrice.mv   = (Decimal)volumeObj.get('mv');
                    volAndPrice.mvp  = (Decimal)volumeObj.get('mvp');
                }
                if (product.containsKey('_product')) {
                    Map<String, Object> prodObj = (Map<String, Object>)product.get('_product');
                    volAndPrice.recurring = (Decimal)prodObj.get('recurring');
                    volAndPrice.oneOff    = (Decimal)prodObj.get('oneOff');
                }
                
                //added as part of EDGE-177926
                Map<String, FAM_Utility.AddOnPricing> mapOfAddOn = new Map<String,FAM_Utility.AddOnPricing>();
                if (product.containsKey('_addons')){
                    system.debug('in addon mwthod');
                    Map<String, Object> addonsObj = (Map<String, Object>)product.get('_addons');
                    for(String addKey:addonsObj.keySet()){
                        FAM_Utility.AddOnPricing volAndPriceAddon = new FAM_Utility.AddOnPricing();
                        Object addObj=addonsObj.get(addKey);
                        String jsonString = JSON.serialize(addObj);
                        FAM_Utility.AddOnPricing addOnWrapp = (FAM_Utility.AddOnPricing)JSON.deserialize(jsonString, FAM_Utility.AddOnPricing.class);
                        volAndPriceAddon.recurring=addOnWrapp.recurring;
                        volAndPriceAddon.oneOff=addOnWrapp.oneOff;
                        mapOfAddOn.put(addKey,volAndPriceAddon);
                    }
                    //System.debug('mapOfAddOn@@@@'+mapOfAddOn);
                    volAndPrice.addOnAssociationToPricingMap=mapOfAddOn;
                }
                //EDGE-211115 & EDGE-211116 ....Start
                Map<Id, Map<Id, Decimal>> rcToRateCardLinesMap = new Map<Id,Map<Id, Decimal>>();
                if (product.containsKey('_rateCards')){
                    system.debug('in _rateCards mwthod');
                    Map<String, Object> rateCardsObj = (Map<String, Object>)product.get('_rateCards');
                    for(String rcKey:rateCardsObj.keySet()){
                        if(rcKey!=null){
                            Object rcObj=rateCardsObj.get(rcKey);
                            system.debug('in rcObj'+rcObj);
                            String jsonString = JSON.serialize(rcObj);
                            system.debug('in rcObj jsonString'+jsonString);
                            Map<Id, Decimal> rcMap = (Map<Id, Decimal>)JSON.deserialize(jsonString, Map<Id, Decimal>.class);
                            system.debug('in rcObj rcMap'+rcMap);
                            rcToRateCardLinesMap.put(rcKey,rcMap);
                        }
                      }
                    volAndPrice.rateCardToRateCardLinesMap =rcToRateCardLinesMap;
                }            
                //EDGE-211115 & EDGE-211116..end
                
                //always add as we need to have CP in this map
                productToVolumeAndPricingMap.put(productId, volAndPrice);
                if(!productToVolumeAndPricingBulkMap.containskey(faAttach.ParentId))
                    productToVolumeAndPricingBulkMap.put(faAttach.ParentId,productToVolumeAndPricingMap);
                 //System.debug('productToVolumeAndPricingMap@@@@'+productToVolumeAndPricingMap);

            }
        
            
            //EDGE-203808-Added to get the Custom Data from FA JSON attachment-Start
            //System.debug('**@@SS:parsedFM.get(custom)'+parsedFM.get('custom'));
            Map<String, Object> customSectionMap;
            if(parsedFM.get('custom') != null && parsedFM.get('custom') != '' && parsedFM.get('custom') != '{}'){
                customSectionMap=(Map<String, Object>)parsedFM.get('custom');
                String jsonString2=JSON.serialize(customSectionMap);
                FAM_Utility.FundConsoleRecords listOfCustomData;
                if(jsonString2 != null && jsonString2 != '' && jsonString2 != '{}')
                    listOfCustomData = (FAM_Utility.FundConsoleRecords)JSON.deserialize(jsonString2, FAM_Utility.FundConsoleRecords.class);
                //System.debug('**@@SS:listOfCustomData-->'+listOfCustomData);
                if(listOfCustomData != null ){
                    Map<String, FAM_Utility.FundData> fundConsoleRecordsMap = new Map<String,FAM_Utility.FundData>();//EDGE-225306:Moved from for loop
                    for(FAM_Utility.FundData fundDataRecord:listOfCustomData.fundConsoleData){
                        System.debug('fundDataRecord.productFamily='+fundDataRecord.productFamily);
                        if(fundDataRecord.productFamily != null){
                            fundConsoleRecordsMap.put(fundDataRecord.productFamily,fundDataRecord);
                        }
                        if(!fundConsoleRecordsBulkMap.containskey(faAttach.ParentId)){
                            fundConsoleRecordsBulkMap.put(faAttach.ParentId,fundConsoleRecordsMap);
                        }

                    }   
                }
            }
        }   

        system.debug('productToVolumeAndPricingBulkMap:::'+productToVolumeAndPricingBulkMap);

        system.debug('fundConsoleRecordsBulkMap:::'+fundConsoleRecordsBulkMap);
        //EDGE-203808-Added to get the Custom Data from FA JSON attachment-End
    }

        /**
     * Creates "missing" list price override records like this:
     * 1. filter out only CPPRA records where Assocciation Type = Pricing Change, target = Sales and adjustment types are Price Overrides
     * 2. Clone them and change the target price to List
     * 3. Insert cloned records
     */
    public void createAndInsertListPriceOverrides(List<cspmb__Price_Item_Pricing_Rule_Association__c> inputCPPRA) {
        String prObjPrefix =    cspmb__Pricing_Rule__c.sObjecttype.getDescribe().getKeyPrefix();
        //name startes with object prefix
        //code starts with FAM
        String nameFilter                                                  = prObjPrefix + '%';
        String pricingRuleCodeFilter                                       = 'FAM%';
        List<cspmb__Price_Item_Pricing_Rule_Association__c> listPriceCPPRA = new List<cspmb__Price_Item_Pricing_Rule_Association__c>();
        Set<Id> priceRulesIds                                              = new Set<Id>();
        //get all Price rules used
        for (cspmb__Price_Item_Pricing_Rule_Association__c cppra : inputCPPRA) {
            priceRulesIds.add(cppra.cspmb__pricing_rule__c);
        }
        //get all pricing rules for our CPPRA records that are created by FA decomposition (Name starts with pricing rule object prefix and code starts with "FAM")
        Map<Id, cspmb__Pricing_Rule__c> faPrMap = new Map<Id, cspmb__Pricing_Rule__c>(
            [SELECT Id, Name, cspmb__pricing_rule_code__c
            FROM cspmb__Pricing_Rule__c
            WHERE Id IN: priceRulesIds AND Name LIKE: nameFilter AND cspmb__pricing_rule_code__c LIKE: pricingRuleCodeFilter]);
        //now for all matching CPPRA records create clones, add to listPriceCPPRA list and insert them
        for (cspmb__Price_Item_Pricing_Rule_Association__c cppra : inputCPPRA) {
            if (cppra.cspmb__association_type__c == 'Pricing change'
                && cppra.cspmb__target_price__c == 'Sales'
                && cppra.cspmb__recurring_adjustment_type__c == 'Price Override'
                && cppra.cspmb__one_off_adjustment_type__c == 'Price Override'
                && faPrMap.containsKey(cppra.cspmb__pricing_rule__c)) {
                //create clone, change target price
                cspmb__Price_Item_Pricing_Rule_Association__c listPriceClone = cppra.clone(false,true,true,true);
                listPriceClone.cspmb__target_price__c = 'List';
                listPriceCPPRA.add(listPriceClone);
            }
        }
        //insert
        if (!listPriceCPPRA.isEmpty()) {
            insert listPriceCPPRA;
        }
    }

    //inner class
    public class VolumeAndPricing {
        public Decimal muc { get; set; }
        public Decimal mucp { get; set; }
        public Decimal mv { get; set; }
        public Decimal mvp { get; set; }
        public Decimal recurring {get; set;}
        public Decimal oneOff {get; set;}
        //added as part of EDGE-177926
        public Map<String, FAM_Utility.AddOnPricing> addOnAssociationToPricingMap { get; set; }
        public Map<Id, Map<Id, Decimal>> rateCardToRateCardLinesMap{ get; set; }////EDGE-211115 & EDGE-211116
    }
    //inner class added as part of EDGE-177926
    public class AddOnPricing {
        public Decimal recurring {get; set;}
        public Decimal oneOff {get; set;}
    }
    
    //EDGE-203808 inner class added by Shashank
    public class FundConsoleRecords{
        public list<FAM_Utility.FundData> fundConsoleData{get;set;}
    }
    //EDGE-203808 inner class added by Shashank
	//EDGE-219116 ( Added isAllocated, ContractStartDate, ContractEndDate)
  //EDGE-219475 ( Added fundExpiry)
    public class FundData{
        public String productFamily{get;set;}
        public String contractTerm{get;set;}
        public String fundExpiry{get;set;}
        public String fundType{get;set;}
        public String fundIncrementFrequency{get;set;}
        public String fundContribution{get;set;}
        public String advanceFundAmount{get;set;}
        public String minimumSpendPerMonth{get;set;}
        public String totalSpentOverContractTerm{get;set;}
        public Boolean isAllocated{get;set;}
        public DateTime ContractStartDate{get;set;}
        public DateTime ContractEndDate{get;set;}

    }
	
    //EDGE-219116
    public static void setFundConsoleCustomMap(Map<Id,Map<String, FAM_Utility.FundData>> newFundConsoleDataMap){
        
        Set<Id> ids= newFundConsoleDataMap.keySet();
        
        List<Attachment> faAttachments = [SELECT Id, Body,ParentId FROM Attachment WHERE ParentId IN :ids AND Name = 'FrameAgreementAttachment'];
        for(Attachment faAttach : faAttachments){
            
            Map<String, Object> parsedFM = (Map<String, Object>) JSON.deserializeUntyped(faAttach.body.toString());
                    
            Map<String, Object> customSectionMap;
                if(parsedFM.get('custom') != null && parsedFM.get('custom') != '' && parsedFM.get('custom') != '{}'){
                    customSectionMap=(Map<String, Object>)parsedFM.get('custom');
                    String jsonString2=JSON.serialize(customSectionMap);
                    
                    list<FAM_Utility.FundData> newFundDataList =new list<FAM_Utility.FundData>();
                    Map<String, FAM_Utility.FundData> mapFundData = newFundConsoleDataMap.get(faAttach.ParentId);
                    
                    for(FAM_Utility.FundData fdata :  mapFundData.values()){
                        newFundDataList.add(fdata);
                    }
                    Map<String, List<FAM_Utility.FundData>>  fundConsoleData=new Map<String, List<FAM_Utility.FundData>>(); 
                    fundConsoleData.put('fundConsoleData',newFundDataList);
                    
                    jsonString2 = JSON.serialize(fundConsoleData);

                    Map<String,object> customObject= new Map<String,object> ();
                    customObject.put('custom',(Object)fundConsoleData);
                    customObject.put('products',parsedFM.get('products'));
                    customObject.put('addons',parsedFM.get('addons'));
                    faAttach.body=Blob.valueOf(JSON.serialize(customObject));
                    
            
                    
                }
            }   
        upsert faAttachments;
    

    }
}