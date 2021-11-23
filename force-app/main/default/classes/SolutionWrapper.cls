public with sharing class SolutionWrapper {
		public String name {get;set;}
		public String guid {get;set;} //id of the solution definition
//		public String id {get;set;} //id of this solution instance
		public Boolean disabled {get{return false;}set;}
		public String description {get;set;}
//		public String componentType {get;set;}
//		public Boolean dirty {get {return false;}set;}
//		public Boolean error {get{return false;}set;}
//		public Boolean active {get{return true;}set;}
		public Boolean visible {get{return true;}set;}
//		public String errorMessage {get{return '';}set;}
//TODO: SD attributes? seems to be empty always
		public final List<migrate_configuration_wrapper> configurations = new List<migrate_configuration_wrapper>();
}