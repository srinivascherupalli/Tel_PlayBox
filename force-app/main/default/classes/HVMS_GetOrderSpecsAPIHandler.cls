/*************************************************************************************************************
 * @name			HVMS_GetOrderSpecsAPIHandler
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			01 / 10 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-01		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
public with sharing class HVMS_GetOrderSpecsAPIHandler {
    public class My2Exception extends Exception {} //added as part of EDGE-144219
    public String reqBody;
    public static Map<String,List<CS_SpecificationDTO.ServiceSpecification>> getAllServSpecsFromService(set<id> setServiceId, String targetSystem , id orderId){
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> finalServiceSpecification;
        List<CS_SpecificationDTO.ServiceSpecification> listServiceSpecification;
        Map<string, List<csord__Service__c>> mapName = new Map<string, List<csord__Service__c>>();
        List<csord__Service__c> listCSordService = new List<csord__Service__c>();
        if(orderId != null && setServiceId.isEmpty()){
            Map<Id,csord__Service__c> orderRelatedServiceMap = Coms_CorrelationIdGeneration.getCSordServices(new set<id>{orderId});
            setServiceId.addAll(orderRelatedServiceMap.keyset());
        }
        if(targetSystem == 'FULFILMENT' && !setServiceId.isEmpty()){
            //fulServSpecList.addAll(HVMS_EDMConversionUtil.ConvertOrchestrationTechnicalToSpecDTO(listAttachment, 'FULFILMENT'));
            finalServiceSpecification = new Map<String,List<CS_SpecificationDTO.ServiceSpecification>>();
            listServiceSpecification = new List<CS_SpecificationDTO.ServiceSpecification>();
            listServiceSpecification = CS_SpecificationDTO.parseServiceSpec(setServiceId , orderId);
            finalServiceSpecification.put('FULFILMENT' , listServiceSpecification);
        }
        return finalServiceSpecification;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-06-2021 
    * @param orderId 
    * @param targetSystem 
    * @param Order_Number 
    * @return String 
    **/
    public static String getOrderSpecs(String orderId,String targetSystem, String Order_Number , Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap){
        String retVal = '';
        Boolean isNGUCConnected = false;
        system.debug('HVMS_GetOrderSpecsAPIHandler :: getOrderSpecs :: found ---->  srvSpecMap '+srvSpecMap);
        if(srvSpecMap == null){
            return isNGUCConnected ? 'Manage Fixed Numbers' : retVal;
        }
        if(srvSpecMap.values() != null){
            if(targetSystem == 'FULFILMENT'){
                return '{"data":'+ JSON.serialize(srvSpecMap.get('FULFILMENT'))+'}';
            }else if(targetSystem == 'BILLING'){
                System.debug('JSON.serializ BILLING ===>'+JSON.serialize(srvSpecMap.get('BILLING')));
                return '{"data":'+JSON.serialize(srvSpecMap.get('BILLING'))+'}';
            }else if(targetSystem == 'ASSURANCE'){
                System.debug('JSON.serializ BILLING ===>'+JSON.serialize(srvSpecMap.get('BILLING')));           
                return '{"data":'+JSON.serialize(srvSpecMap.get('ASSURANCE'))+'}';
            }else                 
                return '{"data":'+JSON.serialize(srvSpecMap.get(''))+'}';
        } else {
            return retVal; 
        }
    }
}