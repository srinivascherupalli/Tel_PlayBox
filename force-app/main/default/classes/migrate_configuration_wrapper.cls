public with sharing class migrate_configuration_wrapper {
	public String configurationName {get;set;}
	public String configCurrency {get {return 'AUD';}set;}
	public String configurationStatus {get;set;}
	public Decimal contractTerm {get;set;}
	public String orderEnrichmentSave {get{return '';}set;}
	public Boolean dirty {get{return false;}set;}
	public Boolean disabled {get{return false;}set;}
	public Boolean error {get{return false;}set;}
	public String errorMessage {get{return '';}set;}
	public String guid {get;set;}
	public String id {get;set;}
	public String name {get;set;}
	public Decimal oneOffPrice {get;set;}
	public Decimal recurringPrice {get;set;}
	public Decimal totalContractValue {get;set;}
	public Boolean status {get{return true;}set;}
	public String solutionId {get;set;}
	public List<String> siteProductList {get;set;} //TODO: List
	public List<String> orderEnrichmentList {get;set;}
	public List<migrate_relatedproduct_wrapper> relatedProductList {get;set;}
	public String replacedConfigId {get;set;} //always null
	public List<String> oeErrorMessages {get;set;}
	public String statusMessage {get;set;}
	public String parent {get;set;}
	public String other {get;set;}
	public List<migrate_attribute_wrapper> attributes {get;set;}
}