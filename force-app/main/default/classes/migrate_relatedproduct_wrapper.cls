public with sharing class migrate_relatedproduct_wrapper {
	public String replacedConfigId {get; set;}
	public String relatedProductName {get;set;}
	public Decimal recurringCharge {get; set;}
	public String productDefinitionId {get;set;}
	public Decimal oneOffCharge {get; set;}
	public String name {get;set;}
	public String guid {get;set;}
	public String groupName {get;set;}
	public String configurationId {get;set;}
	public migrate_configuration_wrapper configuration {get;set;}
	public String configData {get;set;}
	public String componentId {get;set;}

}