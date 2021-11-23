/* ****************************************************************************
Class Name      : SolutionHelperForGuid
* Author        : Ankit Goswami
* Date          : 15 Apr 2021
* Description   : Remote Action Class called from Javascript
* EDGE no       : EDGE-204030
* *****************************************************************************/
global with sharing class SolutionHelperForGuid implements cssmgnt.RemoteActionDataProvider {

/****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
****************************************************************************************************/
        global Map<String,Object> getData(Map<String,Object> inputMap){
            Map<String, Object> returnMap = new Map<String, Object>();      
            System.debug('inputMap'+inputMap);
            String guid = (inputMap.containsKey('getGuid') && (String)inputMap.get('getGuid') != '')? (String)inputMap.get('getGuid'):'';
            string BsCallGuid=getGUID(guid);
            returnMap.put('parentGuid',BsCallGuid);
            return returnMap;
        }
        public static String getGUID(String guid) { 
            String parentGuid = '';
            Map<id,csord__Service__c> serviceMap        =   new Map<id,csord__Service__c>();
            list<csord__Service__c> serviceList          =   [select id from csord__Service__c where csordtelcoa__Product_Configuration__r.configGUID__c =: guid];
            
             for(csord__Service__c seer: serviceList){
                serviceMap.put(seer.id,seer);
            }

            for(Attachment att:[select ID, name, body, parentId from Attachment where parentId in: serviceMap.keyset() and name = 'ServiceSpecifications.json']){
                String newServiceAttachmentStr           =  att.body.toString();
                Map<String, Object> updatedResults       =  (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
                List<Object>lstSpecifications            =  (List<Object>)updatedResults.get('specifications');
                List<Object> newlstSpecifications        =  new List<Object>();
                
                for(Object spec:lstSpecifications){
                    Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                    if(specificationAttributes!=null ) 
                    {
                       if(String.valueOf(specificationAttributes.get('name')).contains(label.Business_Calling_Fulfilment)){
                            parentGuid = String.valueOf(specificationAttributes.get('guid'));
                       }
                    }
                }           
            }
            return parentGuid;
        }
    }