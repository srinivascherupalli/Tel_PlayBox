/*
Created BY: Abinash Barik
Created Date: 
Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring - 
            Modular class structure and generic json parsing logic,
            Sigma-CS interface code refactoring - Update logic for Price Item, 
            Attribute LoV and EDM mappings.
            Sigma to CS Adaptor Class and process the JSON
Class Name: SigmaDataInterfacev2
============================================================================
ChagneSet No    Name            Date                    Description

*/ 
@RestResource(urlMapping='/SigmaToCS/*')
global with sharing class SigmaDataInterfacev2 {
    public static map<String,String> mapSpecdetails;
    //EDGE-70345 
    //public static map<string,List<SigmaJSONParseInterface.Attributes>> mapOfInterfaceNames = new map<string,List<SigmaJSONParseInterface.Attributes>>();
   
    @HttpPost
    global static SigmaDataInterfaceResponse sigmaJsonToCS() {
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','applicatin/json');
        String reqjson = request.requestBody.toString();
         Try{
            //mapSpecdetails = SpecificationAttributesSave.getSpecificationAttributes();
            /*
             *  Below code will replace predefine keywords
             * */
            reqjson = reqjson.replace('"default"', '"default_x"');
            reqjson = reqjson.replace('"currency"', '"currency_x"');
            reqjson = reqjson.replace('"type"', '"type_x"');
            reqjson = reqjson.replace('"frequency"', '"frequency_x"');
            
            // Below map will stores all qualified records to be inserted/updated after the JSON parse
            Map<String, List<sobject>> mapOfFinalObjects = new Map<String, List<sobject>>();
            SigmaJSONParseInterface obj = (SigmaJSONParseInterface) JSON.deserialize(reqjson, Type.forName('SigmaJSONParseInterface'));
            //system.debug(Logginglevel.ERROR ,'obj>>>>>>>>>>>>>>>>>>>'+obj);
            //Map<string,List<SigmaJSONParseInterface.Attributes>> mapOfInterfaceNames = new map<string,List<SigmaJSONParseInterface.Attributes>>();
            obj.productOffering.AssignObjectValues(mapOfFinalObjects);
            //system.debug(Logginglevel.ERROR ,'mapOfFinalObjects>>>>'+mapOfFinalObjects.values().size());
            //system.debug(Logginglevel.ERROR ,'ChangeRequest>>>>'+mapOfFinalObjects.get('ChangeRequest'));
            
            /*
            * Create all qulaified records(Specification, Price Item, Addon Price Item,
            * Add on Price Item Association and Attachments) records
            */
            SigmaUtility.commitAllrecords(mapOfFinalObjects);
            //SigmaAutomation sigmaInstance = new SigmaAutomation();
            //System.debug ('mapOfInterfaceNames.size() :: '+mapOfInterfaceNames.size()+'---->'+mapOfInterfaceNames);
            //sigmaInstance.automateAttributes(mapOfInterfaceNames);
           
            //SpecificationAttributesSave.SpecificationUpdate();
            
            string timestamp = string.valueOf(system.now());
            SigmaDataInterfaceResponse resclass = new SigmaDataInterfaceResponse();
            resclass = SigmaDataInterfaceResponse.genresponse('SUCCESS', 'Successfully Executed', timestamp);
             
            //Change for EDGE-12675
            Logger.getLogger('SigmaDataInterfaceResponse').logResponse(JSON.serialize(resclass));
            Logger.exitLogger();
             saveAttachment(reqjson);
            return resclass;
       }
        catch(Exception ex) {
            saveAttachment(reqjson);
            string timestamp = string.valueOf(system.now());
            SigmaDataInterfaceResponse resclass = new SigmaDataInterfaceResponse();
            resclass = SigmaDataInterfaceResponse.genresponse('ERROR', ex.getmessage(), timestamp);
            //Change for EDGE-12675
            Logger logr = Logger.getLogger(SigmaDataInterfaceResponse.class);
            logr.logResponse(JSON.serialize(resclass));
            logr.debug(ex);
            Logger.exitLogger();
            return resclass;         
        }
    }
    
    Public Static void saveAttachment(String reqjson){
        ApplicationLog__c appLog=new ApplicationLog__c();
        
        appLog.Debug_Level__c = 'SigmaDataInterfacev2';
        appLog.Message__c = 'Creating Attachment';
        appLog.Reference_Info__c = 'SigmaDataInterfacev2';
        appLog.Timer__c = System.now();
        appLog.User__c=UserInfo.getUserId();
        appLog.Type__c='Sigma Integration';
        
        insert appLog;
        
        Attachment att = new Attachment();
        att.body= blob.valueOf(reqjson);
        att.ParentId = appLog.id;
        att.Name = 'SigmaFile_'+System.now()+'.json';
        insert att;
        
    }
}