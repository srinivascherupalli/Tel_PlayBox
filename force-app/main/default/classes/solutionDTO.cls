/*
* @Author : Shubhi
* @Date : 26 Nov 2019
* @Desc : solution DTO
* @Jira : Edge-120132
*@TestClass: solutionDTOTest 
*/

public with sharing class solutionDTO {

    public Boolean visible {get;set;} 
    public String name {get;set;} 
    public String id {get;set;} 
    public String guid {get;set;} 
    public String disabled {get;set;} 
    public String description {get;set;} 
    public Map<String,Configurations> configurations {get;set;} 
    public String changeType {get;set;} 

    public solutionDTO(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'visible') {
                        visible = parser.getBooleanValue();
                    } else if (text == 'name') {
                        name = parser.getText();
                    } else if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'guid') {
                        guid = parser.getText();
                    } else if (text == 'disabled') {
                        disabled = parser.getText();
                    } else if (text == 'description') {
                        description = parser.getText();
                    } else if (text == 'configurations') {
                        configurations = mapOfConfigurations(parser);
                        system.debug('@@@@configurationsmapparser---->'+configurations);
                    } else if (text == 'changeType') {
                        changeType = parser.getText();
                    } else {
                        //System.debug(LoggingLevel.WARN, 'solutionDTO consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    public class Attributes {
        public String value {get;set;} 
        public Boolean showInUI {get;set;} 
        public String name {get;set;} 
        public String displayValue {get;set;} 

        public Attributes(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'value') {
                            value = parser.getText();
                        } else if (text == 'showInUI') {
                            showInUI = parser.getBooleanValue();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'displayValue') {
                            displayValue = parser.getText();
                        } else {
                            //System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class SiteProductList {

        public SiteProductList(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            //LoggingLevel.WARN, 'SiteProductList consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Configurations {
        public Double totalContractValue {get;set;} 
        //public Object siteProducts {get;set;} 
        public List<SiteProductList> siteProductList {get;set;} 
        public String replacedConfigId {get;set;} 
        public Object relatedProducts {get;set;} 
        public List<RelatedProductList> relatedProductList {get;set;} 
        public Double recurringPrice {get;set;} 
        public String other {get;set;} 
      //  public Object orderEnrichments {get;set;} 
       // public List<SiteProductList> orderEnrichmentList {get;set;} 
        public Integer oneOffPrice {get;set;} 
        public Object oeTabsToLoad {get;set;} 
        public String id {get;set;} 
        public String guid {get;set;} 
        public String disabled {get;set;} 
        public Boolean dirty {get;set;} 
        public Integer contractTerm {get;set;} 
        public String configurationStatus {get;set;} 
        public String configurationName {get;set;} 
        public String configurationMessage {get;set;} 
        public String configCurrency {get;set;} 
        public Map<String,Attributes> attributes {get;set;} 
        
        public Configurations(){
            
        }
        public Configurations(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'totalContractValue') {
                            totalContractValue = parser.getDoubleValue();
                        } /*else if (text == 'siteProducts') {
                            siteProducts = parser.readValueAs(Object.class);
                        }*/ else if (text == 'siteProductList') {
                            siteProductList = arrayOfSiteProductList(parser);
                        } else if (text == 'replacedConfigId') {
                            replacedConfigId =  parser.getText();
                        } else if (text == 'relatedProducts') {
                            relatedProducts = parser.readValueAs(Object.class);
                        } else if (text == 'relatedProductList') {
                            relatedProductList = arrayOfRelatedProductList(parser);
                        } else if (text == 'recurringPrice') {
                            recurringPrice = parser.getDoubleValue();
                        } else if (text == 'other') {
                            other = parser.getText();
                        } /*else if (text == 'orderEnrichments') {
                            orderEnrichments = parser.readValueAs(Object.class);
                        } else if (text == 'orderEnrichmentList') {
                            orderEnrichmentList = arrayOfSiteProductList(parser);
                        } */else if (text == 'oneOffPrice') {
                            oneOffPrice = parser.getIntegerValue();
                        } else if (text == 'oeTabsToLoad') {
                            oeTabsToLoad = parser.readValueAs(Object.class);
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'guid') {
                            guid = parser.getText();
                        } else if (text == 'disabled') {
                            disabled = parser.getText();
                        } else if (text == 'dirty') {
                            dirty = parser.getBooleanValue();
                        } else if (text == 'contractTerm') {
                            contractTerm = parser.getIntegerValue();
                        } else if (text == 'configurationStatus') {
                            configurationStatus = parser.getText();
                        } else if (text == 'configurationName') {
                            configurationName = parser.getText();
                        } else if (text == 'configurationMessage') {
                            configurationMessage = parser.getText();
                        } else if (text == 'configCurrency') {
                            configCurrency = parser.getText();
                        } else if (text == 'attributes') {
                            attributes = mapOfAttributes(parser);
                        } else {
                            //(LoggingLevel.WARN, 'Configurations consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class RelatedProductList {
        /*public String replacedConfigId {get;set;} 
        public String relatedProductName {get;set;} 
        public Object recurringCharge {get;set;} 
        public String productDefinitionId {get;set;} 
        public Object oneOffCharge {get;set;}*/ 
        public String name {get;set;} 
        public String guid {get;set;} 
        /*public String groupName {get;set;} 
        public String configurationId {get;set;} */
        public Configurations configuration {get;set;} 
        /*public Object configData {get;set;} 
        public String componentId {get;set;} */

        public RelatedProductList(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        /*if (text == 'replacedConfigId') {
                            replacedConfigId =  parser.getText();
                        } else if (text == 'relatedProductName') {
                            relatedProductName = parser.getText();
                        } else if (text == 'recurringCharge') {
                            recurringCharge = parser.readValueAs(Object.class);
                        } else if (text == 'productDefinitionId') {
                            productDefinitionId = parser.getText();
                        } else if (text == 'oneOffCharge') {
                            oneOffCharge = parser.readValueAs(Object.class);
                        } else*/
                        if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'guid') {
                            guid = parser.getText();
                        } /*else if (text == 'groupName') {
                            groupName = parser.getText();
                        } else if (text == 'configurationId') {
                            configurationId = parser.getText();
                        } */else if (text == 'configuration') {
                            configuration = new Configurations(parser);
                        } /*else if (text == 'configData') {
                            configData = parser.readValueAs(Object.class);
                        } else if (text == 'componentId') {
                            componentId = parser.getText();
                        } */else {
                            //System.debug(LoggingLevel.WARN, 'RelatedProductList consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static List<solutionDTO> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfsolutionDTO(parser);
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
    

    private static List<RelatedProductList> arrayOfRelatedProductList(System.JSONParser p) {
        List<RelatedProductList> res = new List<RelatedProductList>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new RelatedProductList(p));
        }
        return res;
    }


    private static Map<String,Configurations> mapOfConfigurations(System.JSONParser p) {
        Map<String,Configurations> res = new Map<String,Configurations>();        
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
			Configurations config=new Configurations(p);
            system.debug('config-- --->'+ config);
            res.put(config.guid,config);
        }
        system.debug('res map --->'+ res);
        return res;
    }


    private static Map<String, Attributes> mapOfAttributes(System.JSONParser p) {
        Map<String,Attributes> res = new Map<String, Attributes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
			Attributes att=new Attributes(p);
            res.put(att.name,att);
        }
        return res;
    }


    private static List<SiteProductList> arrayOfSiteProductList(System.JSONParser p) {
        List<SiteProductList> res = new List<SiteProductList>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new SiteProductList(p));
        }
        return res;
    }
    private static List<solutionDTO> arrayOfsolutionDTO(System.JSONParser p) {
        List<solutionDTO> res = new List<solutionDTO>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new solutionDTO(p));
        }
        return res;
    }



}