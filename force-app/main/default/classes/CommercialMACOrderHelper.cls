/******************************************************************************************************************************
Class Name : CommercialMACOrderHelper
Test Class : TestCommercialMACOrderHelper 
===============================================================================================================================
Sr.No.  Developer                 Date          Story Description                Sprint
1.      Aman Soni/Shubhi V        08/07/2020    EDGE-224786(New Class)           21.09
******************************************************************************************************************************/
public with sharing class CommercialMACOrderHelper{

    //Create Opportunity Record dynamically
    public static String createDynamicOpportunity(Map<String,String> fieldvaluemap){
        Sobject oppty = new Opportunity();
        Map<String, Schema.SObjectField> oppFieldmap = new Map<String, Schema.SObjectField>();
        oppFieldmap = Schema.SObjectType.Opportunity.fields.getMap();    
        if(fieldvaluemap!=null && !fieldvaluemap.isEmpty()){
            oppty = createDynamicSobject(oppty,fieldvaluemap,oppFieldmap);
        }
        String opportunityId = SobjectFactory.insertSobject((Opportunity)oppty);
        return opportunityId;
    }

    //Create Product Basket Record dynamically
    public static String createDynamicProductBasket(Map<String,String> fieldvaluemap){
        Sobject productBasket = new cscfga__Product_Basket__c();
        Map<String, Schema.SObjectField> pbfieldmap = new Map<String, Schema.SObjectField>();
        pbfieldmap = Schema.SObjectType.cscfga__Product_Basket__c.fields.getMap();       
        if(fieldvaluemap!=null && !fieldvaluemap.isEmpty()){
            productBasket = createDynamicSobject(productBasket,fieldvaluemap,pbfieldmap);
        }
        String basketId = SobjectFactory.insertSobject((cscfga__Product_Basket__c)productBasket);
        return basketId;
    }

    //Create Sobject structure
    public static Sobject createDynamicSobject(Sobject obj,Map<String,String> fieldvaluemap, Map<String, Schema.SObjectField> sObjfieldMap){
        Sobject sObj=obj;       
        if(!sObjfieldMap.isEmpty()){          
            for(String keyField : fieldvaluemap.keyset()){
                Schema.SObjectField field = sObjfieldMap.get(keyField);
                String fieldType= string.valueOf(field.getDescribe().getType());
                if(fieldType.equalsIgnoreCase('Boolean')){
                    Boolean value=Boolean.valueof(fieldvaluemap.get(keyField));
                    sObj.put(keyField,value);
                }else if(fieldType.equalsIgnoreCase('Date')){
                    Date value=Date.valueof(fieldvaluemap.get(keyField));
                    sObj.put(keyField,value);
                }else if(fieldType.equalsIgnoreCase('Currency')){
                    Double value=Double.valueof(fieldvaluemap.get(keyField));
                    sObj.put(keyField,value);
                }else if(fieldType.equalsIgnoreCase('Number')){
                    Integer value=Integer.valueof(fieldvaluemap.get(keyField));
                    sObj.put(keyField,value);
                }
                else if(fieldType.equalsIgnoreCase('Double')){
                    Double value=Double.valueof(fieldvaluemap.get(keyField));
                    sObj.put(keyField,value);
                }else{
                    sObj.put(keyField,fieldvaluemap.get(keyField));
                }              
            }
        }
        return sObj;
    }

    //Create OpportunityContactRole record
    public static void createOpptyContactRole(String opportunityId, String contactId){
        List<OpportunityContactRole> ocrOld = new List<OpportunityContactRole>([Select Id, ContactId from OpportunityContactRole where OpportunityId = :opportunityId]);
        if(!ocrOld.isEmpty()){
            delete ocrOld;
        }
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = contactId, OpportunityId = opportunityId, Role='Decision Maker');
        String ocrId = SobjectFactory.insertSobject(ocr);
    }
}