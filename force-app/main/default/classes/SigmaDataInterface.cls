/*
Description: Sigma to CS mapping
ChagneSet No    Name            Date                    Description
CH-1            Abinash         10/15/2018              EDGE-45053 CS adaptor changes to support assurance phase flag and EDM package upgrades
CH-2			Vijaya			04/10/2019 				EDGE-70343 Sigma-CS interface code refactoring - Update logic for Price Item, Attribute LoV and EDM mappings.
*/

@RestResource(urlMapping='/SigmaToCS2/*')
global with sharing class SigmaDataInterface {
    private SigmaDataInterface() {
        //prevents instantiation 
    }
    
    @HttpPost
    global static SigmaDataInterfaceResponse sigmaJsonToCS() {
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','applicatin/json');
        String reqjson = request.requestBody.toString();
        //Change for EDGE-12675
       // Logger.getLogger('SigmaDataInterfaceRequest').logRequest(request.requestBody.toString());
        //Logger.exitLogger();
        Try{
            cs_SigmaToCSJSON obj = cs_SigmaToCSJSON.parse(reqjson);
            /*UpsertSpecificationChangeRequest.parseSigmaJsonData(obj);
            //Added if condition as part of EDGE-70343 to update only the pricing object when price only changes are required.
            if(SigmaDataInterfaceUtility.isPriceChangeOnly())
            {
                System.debug('PriceChangeOnly is true');
                UpsertPricingDatafromSigmaObj.uppsertPricingData();
            }
            else
            {
                System.debug('PriceChangeOnly is false');
                SpecificationAttributesSave.SpecificationAttributes();
                UpsertAttributeLOVfromSigmaObj.uppsertattLov();
                UpsertPricingDatafromSigmaObj.uppsertPricingData();
                UpsertSpecificationObjectRecord.upsertSpecificationRecord();
                UpsertSpecificationObjectRecord.upsertSpecificationChargeRecord();    
                UpsertSpecificationObjectRecord.upsertSpecificationAssuranceRecord(); // CH-1 
                UpsertRequestObjectRecord.upsertAttribute(obj);
                UpsertRequestObjectRecord.upsertAssuranceAttributes(obj);
                UpsertRequestObjectRecord.upsertchargesAttribute(obj);
                UpsertSpecificationChangeRequest.upsertAllowancesChangeRequest(UpsertSpecificationChangeRequest.mapOnlyChargeProduct);
                SpecificationAttributesSave.SpecificationUpdate();
            } */
            string timestamp = string.valueOf(system.now());
            SigmaDataInterfaceResponse resclass = new SigmaDataInterfaceResponse();
            resclass = SigmaDataInterfaceResponse.genresponse('SUCCESS', 'Successfully Executed', timestamp);
            //Change for EDGE-12675
            Logger.getLogger('SigmaDataInterfaceResponse').logResponse(JSON.serialize(resclass));
            Logger.exitLogger();
            return resclass;
      } catch(Exception ex) {
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
}