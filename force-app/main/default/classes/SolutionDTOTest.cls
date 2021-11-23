/*
* @Author : Shubhi
* @Date : 26 Nov 2019
* @Desc : solution DTO
* @Jira : Edge-120132
*@TestClass: solutionDTOTest 
*/
@IsTest
public class SolutionDTOTest {
    			        
        @istest
        public static void testParse() {
        String json = SolutionAttachmentTestDataFactory.json;
        List<SolutionDTO> r = SolutionDTO.parse(json);
        System.assert(r != null);
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SolutionDTO objSolutionDTO = new SolutionDTO(System.JSON.createParser(json));
        System.assert(objSolutionDTO != null);
        System.assert(objSolutionDTO.visible == null);
        System.assert(objSolutionDTO.name == null);
        System.assert(objSolutionDTO.id == null);
        System.assert(objSolutionDTO.guid == null);
        System.assert(objSolutionDTO.disabled == null);
        System.assert(objSolutionDTO.description == null);
        System.assert(objSolutionDTO.configurations == null);
        System.assert(objSolutionDTO.changeType == null);
                  
        json=SolutionAttachmentTestDataFactory.JsonWithRelatedProd;
        SolutionDTO objSolutionDTO1 = new SolutionDTO(System.JSON.createParser(json));
        System.assert(objSolutionDTO1 != null);
        //System.assert(objSolutionDTO1.visible == null);
        //System.assert(objSolutionDTO1.name == null);
        //System.assert(objSolutionDTO1.id == null);
        //System.assert(objSolutionDTO1.guid == null);
        //System.assert(objSolutionDTO.configurations == null);
        //System.assert(objSolutionDTO.changeType == null);
        SolutionDTO.RelatedProductList objRelatedProductList = new SolutionDTO.RelatedProductList(System.JSON.createParser(json));
        System.assert(objRelatedProductList != null);

        /*json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SolutionDTO.Configuration objConfiguration = new SolutionDTO.Configuration(System.JSON.createParser(json));
        System.assert(objConfiguration != null);
        System.assert(objConfiguration.totalContractValue == null);
        System.assert(objConfiguration.siteProducts == null);
        System.assert(objConfiguration.siteProductList == null);
        System.assert(objConfiguration.replacedConfigId == null);
        System.assert(objConfiguration.relatedProducts == null);
        System.assert(objConfiguration.relatedProductList == null);
        System.assert(objConfiguration.recurringPrice == null);
        System.assert(objConfiguration.other == null);
        System.assert(objConfiguration.orderEnrichments == null);
        System.assert(objConfiguration.orderEnrichmentList == null);
        System.assert(objConfiguration.oneOffPrice == null);
        System.assert(objConfiguration.oeTabsToLoad == null);
        System.assert(objConfiguration.id == null);
        System.assert(objConfiguration.guid == null);
        //System.assert(objConfiguration.disabled == false);
        System.assert(objConfiguration.dirty == null);
        System.assert(objConfiguration.contractTerm == null);
        System.assert(objConfiguration.configurationStatus == null);
        System.assert(objConfiguration.configurationName == null);
        System.assert(objConfiguration.configurationMessage == null);
        System.assert(objConfiguration.configCurrency == null);
        System.assert(objConfiguration.attributes == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SolutionDTO.Configurations_Z objConfigurations_Z = new SolutionDTO.Configurations_Z(System.JSON.createParser(json));
        System.assert(objConfigurations_Z != null);
        System.assert(objConfigurations_Z.totalContractValue == null);
        System.assert(objConfigurations_Z.siteProducts == null);
        System.assert(objConfigurations_Z.siteProductList == null);
        System.assert(objConfigurations_Z.replacedConfigId == null);
        System.assert(objConfigurations_Z.relatedProducts == null);
        System.assert(objConfigurations_Z.relatedProductList == null);
        System.assert(objConfigurations_Z.recurringPrice == null);
        System.assert(objConfigurations_Z.other == null);
        System.assert(objConfigurations_Z.orderEnrichments == null);
        System.assert(objConfigurations_Z.orderEnrichmentList == null);
        System.assert(objConfigurations_Z.oneOffPrice == null);
            System.assert(objConfigurations_Z.oeTabsToLoad == null);
            System.assert(objConfigurations_Z.id == null);
            System.assert(objConfigurations_Z.guid == null);
            //System.assert(objConfigurations_Z.disabled == false);
            System.assert(objConfigurations_Z.dirty == null);
            System.assert(objConfigurations_Z.contractTerm == null);
            System.assert(objConfigurations_Z.configurationStatus == null);
            System.assert(objConfigurations_Z.configurationName == null);
            System.assert(objConfigurations_Z.configurationMessage == null);
            System.assert(objConfigurations_Z.configCurrency == null);
            System.assert(objConfigurations_Z.attributes == null);
    
            json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
            SolutionDTO.Attributes objAttributes = new SolutionDTO.Attributes(System.JSON.createParser(json));
            System.assert(objAttributes != null);
            System.assert(objAttributes.value == null);
            System.assert(objAttributes.showInUI == null);
            System.assert(objAttributes.name == null);
            System.assert(objAttributes.displayValue == null);
    
            json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
            SolutionDTO.SiteProductList objSiteProductList = new SolutionDTO.SiteProductList(System.JSON.createParser(json));
            System.assert(objSiteProductList != null);
    
            json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
            SolutionDTO.Configurations objConfigurations = new SolutionDTO.Configurations(System.JSON.createParser(json));
            System.assert(objConfigurations != null);
            System.assert(objConfigurations.totalContractValue == null);
            System.assert(objConfigurations.siteProducts == null);
            System.assert(objConfigurations.siteProductList == null);
            System.assert(objConfigurations.replacedConfigId == null);
            System.assert(objConfigurations.relatedProducts == null);
            System.assert(objConfigurations.relatedProductList == null);
            System.assert(objConfigurations.recurringPrice == null);
            System.assert(objConfigurations.other == null);
            System.assert(objConfigurations.orderEnrichments == null);
            System.assert(objConfigurations.orderEnrichmentList == null);
            System.assert(objConfigurations.oneOffPrice == null);
            System.assert(objConfigurations.oeTabsToLoad == null);
            System.assert(objConfigurations.id == null);
            System.assert(objConfigurations.guid == null);
            //System.assert(objConfigurations.disabled == false);
            System.assert(objConfigurations.dirty == null);
            System.assert(objConfigurations.contractTerm == null);
            System.assert(objConfigurations.configurationStatus == null);
            System.assert(objConfigurations.configurationName == null);
            System.assert(objConfigurations.configurationMessage == null);
            System.assert(objConfigurations.configCurrency == null);
            System.assert(objConfigurations.attributes == null);
    
            json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
            SolutionDTO.RelatedProductList objRelatedProductList = new SolutionDTO.RelatedProductList(System.JSON.createParser(json));
            System.assert(objRelatedProductList != null);
            System.assert(objRelatedProductList.replacedConfigId == null);
            System.assert(objRelatedProductList.relatedProductName == null);
            System.assert(objRelatedProductList.recurringCharge == null);
            System.assert(objRelatedProductList.productDefinitionId == null);
            System.assert(objRelatedProductList.oneOffCharge == null);
            System.assert(objRelatedProductList.name == null);
            System.assert(objRelatedProductList.guid == null);
            System.assert(objRelatedProductList.groupName == null);
            System.assert(objRelatedProductList.configurationId == null);
            System.assert(objRelatedProductList.configuration == null);
            System.assert(objRelatedProductList.configData == null);
            System.assert(objRelatedProductList.componentId == null);*/
    }
}