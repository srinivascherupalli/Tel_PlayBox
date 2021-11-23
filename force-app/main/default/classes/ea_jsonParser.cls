/**
* Author : Shreyansh Sharma(Jaipur)
* Date : 5/24/2021
* Description: P2OB-14430, helper class for parsing json ontained from Einstein query
**/
public with sharing class ea_jsonParser {
   public class Field {
		public String id {get;set;} 
		public String type_Z {get;set;} // in json: type

		public Field(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Field consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Results {
		public List<Metadata> metadata {get;set;} 
		public List<Records> records {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'metadata') {
							metadata = arrayOfMetadata(parser);
						} else if (text == 'records') {
							records = arrayOfRecords(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property1: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Lineage {
		public String type_Z {get;set;} // in json: type
		public List<Projections> projections {get;set;} 

		public Lineage(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'projections') {
							projections = arrayOfProjections(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Lineage consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Metadata {
		public Lineage lineage {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'lineage') {
							lineage = new Lineage(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String action {get;set;} 
	public String responseId {get;set;} 
	public Results results {get;set;} 
	public String query {get;set;} 
	public Integer responseTime {get;set;} 

	public ea_jsonParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'action') {
						action = parser.getText();
					} else if (text == 'responseId') {
						responseId = parser.getText();
					} else if (text == 'results') {
						results = new Results(parser);
					} else if (text == 'query') {
						query = parser.getText();
					} else if (text == 'responseTime') {
						responseTime = parser.getIntegerValue();
					} else {
						System.debug(LoggingLevel.WARN, 'EAProdServ2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Projections {
		public Field field {get;set;} 
		public List<Inputs> inputs {get;set;} 

		public Projections(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'field') {
							field = new Field(parser);
						} else if (text == 'inputs') {
							inputs = arrayOfInputs(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Projections consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Inputs {
		public String id {get;set;} 

		public Inputs(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Inputs consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Records {
       
		public String CIDN {get;set;} // in json: Account.CIDN__c
		public String Billing_Account_Info {get;set;} 
		public String ComputedUltimateCIDN {get;set;} 
		public String Svc_Type {get;set;} 
		public String VisibleSvcDescription {get;set;} 
        public String Count {get;set;}

		public Records(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Account.CIDN__c') {
							CIDN = parser.getText();
						} else if (text == 'Billing_Account_Info') {
							Billing_Account_Info = parser.getText();
						} else if (text == 'ComputedUltimateCIDN') {
							ComputedUltimateCIDN = parser.getText();
						} else if (text == 'Svc_Type') {
							Svc_Type = parser.getText();
						} else if (text == 'VisibleSvcDescription') {
							VisibleSvcDescription = parser.getText();
						} else if (text == 'Count') {
							Count = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Records consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static ea_jsonParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ea_jsonParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


    private static List<Inputs> arrayOfInputs(System.JSONParser p) {
        List<Inputs> res = new List<Inputs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Inputs(p));
        }
        return res;
    }







    private static List<Projections> arrayOfProjections(System.JSONParser p) {
        List<Projections> res = new List<Projections>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Projections(p));
        }
        return res;
    }


    private static List<Metadata> arrayOfMetadata(System.JSONParser p) {
        List<Metadata> res = new List<Metadata>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Metadata(p));
        }
        return res;
    }
    
    private static List<Records> arrayOfRecords(System.JSONParser p) {
        List<Records> res = new List<Records>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Records(p));
        }
        return res;
    }
}