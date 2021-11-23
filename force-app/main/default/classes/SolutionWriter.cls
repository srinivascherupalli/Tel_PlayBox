public with sharing class SolutionWriter {
  private static Map<Id, List<Object>> m_pdToAttributesJSONmap = new Map<Id, List<Object>>();
  private static Map<Id, String> m_pdToRPName = new Map<Id, String>();
  private static Map<Id, List<cscfga__Product_Configuration__c>> m_config2RelatedConfigsMap = new Map<Id, List<cscfga__Product_Configuration__c>>();
  private static Map<Id, List<cscfga__Attribute__c>> m_config2AttributeMap = new Map<Id, List<cscfga__Attribute__c>>();
  private static Map<Id, Id> m_pd2SDMap = new Map<Id, Id>();
  public static Map<Id, String> m_configID2GUIDMap = new Map<Id, String>();
  public static SolutionWrapper CreateSolutionJSON(cssdm__Solution_Definition__c solutionDefinition, Id accountId, Map<Id, String> pc2GUIDMap) {
    return CreateSolutionJSON(solutionDefinition, accountId, null, pc2GUIDMap);
  }
  public static void LoadSolutionDefinitionSchemas(List<cscfga__Product_Configuration__c> configIdsToMigrate, List<Id> solutionDefinitionIds)
  {
    for (cssdm__Solution_Definition__c sd : [SELECT Id, Name, cssdm__Schema__r.csutil__value__c, cssdm__related_product_name__c, cssdm__Product_Definition__c, cssdm__Type__c FROM cssdm__Solution_Definition__c where Id in :solutionDefinitionIds])
    {
      m_pdToAttributesJSONmap.put(sd.cssdm__Product_Definition__c, GetAttributesDefinedForThisSolution(sd));
      if (sd.cssdm__Type__c == 'Related Component') {
        m_pdToRPName.put(sd.cssdm__Product_Definition__c, sd.cssdm__related_product_name__c);
                System.debug('m_pdToRPName ::'+m_pdToRPName);
      }
      if (m_pd2SDMap.containsKey(sd.cssdm__Product_Definition__c)) {
        throw new CS_Exception('Two solution definitions are defined for product definition: ' + sd.cssdm__Product_Definition__c);
      }
      m_pd2SDMap.put(sd.cssdm__Product_Definition__c, sd.Id);
    }
    for (cscfga__Product_Configuration__c rpConfig : [
        SELECT
        Id, 
        csordtelcoa__Replaced_Product_Configuration__c,
        Name,
        cscfga__Product_Definition__c,
        cscfga__Product_Definition__r.Name,
        cscfga__Parent_Configuration__c,
        cscfga__Configuration_Status__c,
        cscfga__Contract_Term__c,
        cscfga__One_Off_Charge__c,
        cscfga__Recurring_Charge__c,
        cscfga__total_contract_value__c,
        cssdm__Solution_Association__c,
              cscfga__Product_Basket__c
        FROM
        cscfga__Product_Configuration__c
        WHERE
        cscfga__Parent_Configuration__c in :configIdsToMigrate
    ]
    )
    {
      if (m_config2RelatedConfigsMap.containsKey(rpConfig.cscfga__Parent_Configuration__c)) {
        m_config2RelatedConfigsMap.get(rpConfig.cscfga__Parent_Configuration__c).add(rpConfig);
      }
      else
      {
        m_config2RelatedConfigsMap.put(rpConfig.cscfga__Parent_Configuration__c, new List<cscfga__Product_Configuration__c>{rpConfig});
                System.debug('m_config2RelatedConfigsMap:::'+m_config2RelatedConfigsMap);
      }
    }
    for (cscfga__Attribute__c attr : [SELECT Id, Name, cscfga__Value__c, cscfga__Display_Value__c, cscfga__Product_Configuration__c FROM cscfga__Attribute__c WHERE cscfga__Product_Configuration__c in :configIdsToMigrate])
    {
      if (m_config2AttributeMap.containsKey(attr.cscfga__Product_Configuration__c)) {
        m_config2AttributeMap.get(attr.cscfga__Product_Configuration__c).add(attr);
      }
      else {
        m_config2AttributeMap.put(attr.cscfga__Product_Configuration__c, new List<cscfga__Attribute__c> {attr});
      }
    }

  }
  public static SolutionWrapper CreateSolutionJSON(cssdm__Solution_Definition__c solutionDefinition, Id accountId, cscfga__Product_Configuration__c mainConfig, Map<Id, String> pc2GUIDMap) {
    /*
    Create the main JSON component for the solution.
    solutionData.json is ultimately made of a list of these components; one for each solution definition linked
    to a main solution definition.
    Uses configurations previously saved in the basket (expects ID and GUID attributes to be present) unless
    mainConfig is supplied.
    */
    SolutionWriter.m_configID2GUIDMap = pc2GUIDMap;
    String guid = '';
    List<cscfga__Product_Configuration__c> configurations;
    if (mainConfig != null)
    {
      guid = 'myGUID';
      configurations = new List<cscfga__Product_Configuration__c> {mainConfig};
    } else {
      configurations = GetSavedProductConfigurationsFromBasket(
        solutionDefinition, 
        accountId, 
        pc2GUIDMap.keySet()
      );
    }
    //LoadSolutionDefinitionSchemas(configurations);
    List<Object> attributesJSON = GetAttributesDefinedForThisSolution(solutionDefinition);


    SolutionWrapper solnWrapper = new SolutionWrapper();
    solnWrapper.name = solutionDefinition.Name;
    System.Debug('SolutionWriter: Setting guid of solution ' + solutionDefinition + ' to ' + solutionDefinition.Id);
    solnWrapper.guid = solutionDefinition.Id;
    solnWrapper.description = solutionDefinition.Name;
    for (cscfga__Product_Configuration__c configInstance : configurations) {
      solnWrapper.configurations.add(CreateConfigJSON(configInstance, attributesJSON)); 
    }

    return solnWrapper;
  }

  private static List<cscfga__Product_Configuration__c> GetSavedProductConfigurationsFromBasket(cssdm__Solution_Definition__c solutionDefinition, Id accountId, Set<Id> configIdsToMigrate) {
    /*Get Product configurations in the basket for this specified solution definition
    Return list of cscfga__Product_Configuration__c
    */
    System.Debug('GetSavedProductConfigurationsFromBasket, pd = ' + solutionDefinition.cssdm__Product_Definition__c + ', account = ' + accountId);
    return   [
          SELECT 
            Id, 
            Name,
            cscfga__Configuration_Status__c,
            cscfga__Contract_Term__c,
            cscfga__Product_Definition__c,
            cscfga__One_Off_Charge__c,
            cscfga__Recurring_Charge__c,
            cscfga__total_contract_value__c,
            csordtelcoa__Replaced_Product_Configuration__c,
            cssdm__Solution_Association__c,
                  cscfga__Product_Basket__c
          FROM 
            cscfga__Product_Configuration__c
          WHERE
            cscfga__Product_Definition__c = :solutionDefinition.cssdm__Product_Definition__c
          AND
            cscfga__Product_Basket__r.csbb__Account__c = :accountId
          AND
            Id in :configIdsToMigrate];
  }

  private static List<Object> GetAttributesDefinedForThisSolution(cssdm__Solution_Definition__c solutionDefinition){
    /*
    Pull Solution Attributes out of the JSON schema. Returned as list of Apex Objects
    */
    String sdSchemaJSON = solutionDefinition.cssdm__Schema__r.csutil__value__c;
    if (sdSchemaJSON == '' || sdSchemaJSON == null)
    {
      return null; // handling for invalid solution definitions (no schema)
    }
    //System.Debug(String.Format('Getting schema for solution definition {0} ({1} = {2}',
    //  new List<String> {solutionDefinition.Name, solutionDefinition.Id, sdSchemaJSON}));
    
    Map<String, Object> schema = (Map<String, Object>)JSON.deserializeUntyped(sdSchemaJSON);
    return (List<Object>)schema.get('attributes');
  }

  private static string getGUID(cscfga__Product_Configuration__c config){
//      cscfga__Attribute__c guidAttr = [SELECT cscfga__Value__c FROM cscfga__Attribute__c WHERE cscfga__Product_Configuration__c = :configId AND Name = 'GUID' Limit 1];
//      String guid = guidAttr.cscfga__Value__c;
      if (m_configID2GUIDMap.containsKey(config.Id))
      {
        return m_configID2GUIDMap.get(config.Id);
      }
      else if (m_configID2GUIDMap.containsKey(config.cscfga__Product_Basket__c)){
        return m_configID2GUIDMap.get(config.cscfga__Product_Basket__c);
      }
      else{
        throw new CS_Exception('Unable to find GUID for Configuration ' + config);
      }

  }
  private static migrate_configuration_wrapper CreateConfigJSON(cscfga__Product_Configuration__c configInstance, List<Object> attributesJSON) {
    /*x
    Create a JSON serialisable version of the specified product configuration record
    */
    String guid = getGUID(configInstance);
    //System.assert(configInstance.Id != null);
    //CONFIGURATION DATA
    migrate_configuration_wrapper config = new migrate_configuration_wrapper();
    Map<String, cscfga__Attribute__c> attributeInstances = new Map<String, cscfga__Attribute__c>();
    List<cscfga__Product_Configuration__c> relatedProductConfigs = new List<cscfga__Product_Configuration__c>();
        System.debug('configInstance.Id ::'+configInstance.Id);
    if (configInstance.Id!= null && m_config2RelatedConfigsMap.containsKey(configInstance.Id)) {
      relatedProductConfigs = m_config2RelatedConfigsMap.get(configInstance.Id);
    }
      
    if (m_config2AttributeMap.containsKey(configInstance.Id)) {
      for (cscfga__Attribute__c attr : m_config2AttributeMap.get(configInstance.Id))
      {
        attributeInstances.put(attr.Name, attr);
      }
    }
    config.configurationName = configInstance.Name; //TODO looks ok
    config.configurationStatus = configInstance.cscfga__Configuration_Status__c;
    config.contractTerm = configInstance.cscfga__Contract_Term__c; //TODO looks ok
    System.Debug('SolutionWriter: setting configuration guid to ' + guid + ' for configuration ' + configInstance);
    config.guid = guid; //TODO fetch value from GUID attribute (bulkify pls)
    config.id = configInstance.Id; //TODO looks ok
    config.name = ''; //TODO
    config.oneOffPrice = configInstance.cscfga__One_Off_Charge__c; //TODO looks ok
    config.recurringPrice = configInstance.cscfga__Recurring_Charge__c; //TODO looks ok
    config.totalContractValue = configInstance.cscfga__total_contract_value__c; //TODO looks ok
    config.solutionId = configInstance.cssdm__Solution_Association__c;//TODO set after solution insert
    config.siteProductList = new List<String>(); //TODO looks ok
    config.orderEnrichmentList = new List<String>(); //TODO list
    config.replacedConfigId = null;
    config.oeErrorMessages = new List<String>(); //TODO
    config.statusMessage = ''; //TODO
    config.parent = ''; //TODO
    config.other = ''; //TODO

    //ATTRIBUTES
    config.attributes = new List<migrate_attribute_wrapper>();
    for (Object attributeobj : attributesJSON)
    {
      System.Debug('Getting config attributes ' + attributeobj);
      String attributeName = (String)((Map<String, Object>)attributeobj).get('name');
      System.Debug('MakeAttribute from name = '+ attributeName + ' = ' + attributeInstances.get(attributeName));
      migrate_attribute_wrapper attribute = MakeAttribute(attributeInstances.get(attributeName),(Map<String, Object>)attributeobj);
      config.attributes.add(attribute);
    }
    //RELATED PRODUCTS
    config.relatedProductList = new List<migrate_relatedproduct_wrapper>(); //TODO list
    for (cscfga__Product_Configuration__c rp : relatedProductConfigs)
    {
            System.debug('rp.Id ::'+rp.Id);
      config.relatedProductList.add(MakeRelatedProduct(m_pdToRPName.get(rp.cscfga__Product_Definition__c), rp));
    }

    return config;
  }

  private static migrate_attribute_wrapper MakeAttribute(cscfga__Attribute__c attributeInstance, Map<String, Object> attributeMap) {

    System.Debug('MakeAttribute. Got instance = '+attributeInstance);
    migrate_attribute_wrapper attribute = new migrate_attribute_wrapper();

    attribute.name = (String)attributeMap.get('name');
//    attribute.label = (String)attributeMap.get('label');
//    attribute.readOnly = (Boolean)attributeMap.get('readOnly');
    attribute.showInUI = (Boolean)attributeMap.get('showInUI');
//    attribute.required = (Boolean)attributeMap.get('required');
//    attribute.type = (String)attributeMap.get('type');
    if (attributeInstance == null)
    {
      attribute.value = attributeMap.get('value');
      attribute.displayValue = '';
    } else {
      attribute.value = attributeInstance.cscfga__Value__c;
      attribute.displayValue = attributeInstance.cscfga__Display_Value__c; //CS116
    }
    
//    attribute.displayColumn = ''; //TODO
//    attribute.other = '';// TODO
//    attribute.error = '';//TODO from config
//    attribute.status = ''; //TODO
//    attribute.errorMessage = ''; //TODO
//    attribute.helpText = ''; //TODO
//    attribute.validationErrorMessage = '';//TODO
    
    System.Debug('attribute = ' + attribute);
    return attribute;
  }

    @testVisible
  private static migrate_relatedproduct_wrapper MakeRelatedProduct(String rpName, cscfga__Product_Configuration__c rp)
  {
    Id prodDefId = rp.cscfga__Product_Definition__c;
    
    if (!m_pd2SDMap.containsKey(prodDefId))
    {
      throw new CS_Exception(String.Format('No solution definition found for relatedProduct {0} ({1})',
        new List<String> {rp.Name, rp.Id}));
    }
    Id solutionDefinitionId = m_pd2SDMap.get(prodDefId);
    migrate_relatedproduct_wrapper relatedProduct = new migrate_relatedproduct_wrapper();
    relatedProduct.replacedConfigId = rp.csordtelcoa__Replaced_Product_Configuration__c;
    relatedProduct.relatedProductName = rpName;//.cscfga__Product_Definition__r.Name; //TODO check??
    relatedProduct.recurringCharge = rp.cscfga__Recurring_Charge__c;
    relatedProduct.productDefinitionId = rp.cscfga__Product_Definition__c;
    relatedProduct.oneOffCharge = rp.cscfga__One_Off_Charge__c;
    relatedProduct.name = rp.cscfga__Product_Definition__r.Name;
    System.Debug('SolutionWriter: setting RP guid to "" for rp ' + rp);
    relatedProduct.guid = getGUID(rp); //TODO
    relatedProduct.groupName = rpName;//.cscfga__Product_Definition__r.Name;//TODO
    relatedProduct.configurationId = rp.Id;
    relatedProduct.configData = ''; //TODO huh?
    relatedProduct.componentId = solutionDefinitionId;//TODO
    relatedProduct.configuration = CreateConfigJSON(rp, m_pdToAttributesJSONmap.get(rp.cscfga__Product_Definition__c)); //do not pass in relatedproduct name map -- assumes no second-level related products in config
    return relatedProduct;
  }
  
}