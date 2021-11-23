@isTest
public class SpecificationAttributesSaveTest {

    static testMethod void Test(){
        
        List<ID> specIds = New List<ID> ();
        
        cscfga__Product_Definition__c ProdDef = new cscfga__Product_Definition__c();
        ProdDef.Name = 'OfferName';
        ProdDef.cscfga__Description__c ='Description';
        insert ProdDef;
        
        csedm__Specification__c specRec = new csedm__Specification__c();
        specRec.Name='Specification Record';
        specRec.External_Id__c = '6d9bb456-e204-3895-7140-a0693d575f42';
        specRec.csedm__Value__c  = '{"code":"DMCAT_ProductSpecification_000077_Fulfilment","name":"Device "}';
        specRec.csedm__Active__c = true;
       // specRec.csedm__Product_Definition__c = ProdDef.Id;    // Spring 20 Commented
        specRec.csedm__Source__c = ProdDef.Id;  // Spring 20 
        insert specRec;
        specIds.add(specRec.Id);
        
        Test.startTest();
        SpecificationAttributesSave SpecAttri = new SpecificationAttributesSave(); 
        csedm__Specification__c SpecRec1 = [Select id, Name from csedm__Specification__c where name = 'Specification Record' LIMIT 1];  
        SpecificationAttributesSave.SpecificationAttributes();
        SpecificationAttributesSave.SpecificationUpdate();
        SpecificationAttributesSave.getSpecificationAttributes();
        System.assert(SpecRec1 != null);
        Test.stopTest();
       
    }  
}