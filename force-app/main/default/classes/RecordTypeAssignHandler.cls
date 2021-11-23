public class RecordTypeAssignHandler 
{
    
    public static void assignRecordTypeToService( List<Id> serviceIdList )
    {
         System.debug('RRRRR:ServiceList' + serviceIdList);
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<csord__Service__c> serviceListtoUpdate = new List<csord__Service__c>();
        
        Map<String,String> recordTypeMap = new Map<String,string>();
        
        List<RecordType> serviceRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Service__c'];
        for ( RecordType recObj : serviceRecordTypeList )
        {
            recordTypeMap.put(recObj.Name,recObj.id);
        }
             
        serviceList = [SELECT id,Name,RecordTypeId FROM csord__Service__c where id IN :serviceIdList];
        for(csord__Service__c servObj:serviceList )
        {
            String serviceName = servObj.Name;
            List<String> serviceNamelist = new List<String>();
            serviceNamelist =   servObj.Name.split(':');
            serviceName = serviceNamelist[0];
            if(recordTypeMap.keySet().contains(serviceName) )
            {
                servObj.RecordTypeId = recordTypeMap.get(serviceName);
            }
            else if(serviceName.contains(Constants.DEVICE) || serviceName.contains(Constants.ACCESSORIES))
            {
                servObj.RecordTypeId = recordTypeMap.get(Constants.DEVICE);
            }
            else if(serviceName.contains(Constants.ADDITIONAL_STATIC_IP_SUBNET) )
            {
                servObj.RecordTypeId = recordTypeMap.get(Constants.ADDITIONAL_STATIC_IP_SUBNET);
            }
            else if(serviceName.contains(Constants.TRAINING) )
            {
                servObj.RecordTypeId = recordTypeMap.get(Constants.TRAINING);
            }
            serviceListtoUpdate.add(servObj);
        }
        System.debug('PP serviceListtoUpdate: '+serviceListtoUpdate);
        if( !serviceListtoUpdate.isEmpty())
        {
            update serviceListtoUpdate;
        }
        
    }

}