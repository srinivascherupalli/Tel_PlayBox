/*
* @Author : Shubhi
* @Date : 3 October 2019
* @Desc : Get Address data from East using adbor id and Upsert it in salesforce 
* @Jira : Edge-113351
*@Desc: Test class for NBNEastCallout 
*@TestClass: NBNEastCalloutTest @methods:eastCalloutAndUpsertAddressAndSiteSuccessTest(),eastCalloutAndUpsertAddressAndSiteFailureTest
*/
public class NBNEastCalloutNew implements Queueable , Database.AllowsCallouts{
    public static final String NBN_EAST = 'AddressValidateServiceByAdborId';
    Private AddressRequestDTO addressRequestDTOObj=null; 
    Private String adborID=null;
    Public String compositeKey=null;
    Private ReplicatorGetSiteDataObject replicatorAddress=null;
    Private Service_Qualification__c sqRecordToBeInsertedForReplicator=null;
    Private List<Service_Qualification_Provider_Resource__c> providerresourceList=null;        
    Public NBNEastCalloutNew(AddressRequestDTO addressRequestDTOObj,String adborID,String CIDN,ReplicatorGetSiteDataObject replicatorAddress,Service_Qualification__c sqRecordToBeInsertedForReplicator,List<Service_Qualification_Provider_Resource__c> providerresourceList){       
        this.addressRequestDTOObj=addressRequestDTOObj;
        this.adborID=adborID;
        this.compositeKey=CIDN+adborID;
        this.replicatorAddress=replicatorAddress;
        this.sqRecordToBeInsertedForReplicator=sqRecordToBeInsertedForReplicator;
        this.providerresourceList=new List<Service_Qualification_Provider_Resource__c>();
        this.providerresourceList.addAll(providerresourceList);
    } 
    
    //EDGE-72118 This method is executed when System.enqueue method is called from AddressAndSiteObjectUtility class
    Public void execute(QueueableContext context){
        String urlParam = addressRequestDTOObj.getEncodedURLParam();
        getAndUpsertAddressByAdborId(urlParam,NBN_EAST);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=new AddressAndSiteObjectUtility.AuraProcessingMessage();
        msg=AddressAndSiteObjectUtility.upsertReplicatorAddressAndSite(adborID,replicatorAddress); 
        if(msg.isSuccess==true){
            if(sqRecordToBeInsertedForReplicator!=null){
                system.debug('sqRecordToBeInsertedForReplicator==>'+sqRecordToBeInsertedForReplicator);
           		UpsertSQRecords(sqRecordToBeInsertedForReplicator,providerresourceList,compositeKey);
            }
        }
    }
    
  
   // EDGE-72118 get Address from East and upsert it in salesforce
    public static void getAndUpsertAddressByAdborId(String urlParam, String handlerName){
        AddressResponseDTO addressResponseDTOObj;
        HTTPResponse adResponse = new HTTPResponse();
        try{
            String token = AuthenticationManager.getOauthToken(NBN_EAST);
            
            Map<String,String> headerMap = new Map<String, String>{'Accept' => 'application/json','Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                adResponse = IntegrationRecordHandlerUtil.callout(urlParam, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName,null, null);
            addressResponseDTOObj = AddressResponseDTO.parse(adResponse.getBody());           
            if(addressResponseDTOObj!=null && addressResponseDTOObj.code==200 && addressResponseDTOObj.ErrorCode==null){
                AddressAndSiteObjectUtility.upsertNBNEastAddress(addressResponseDTOObj);
            }
        }catch(Exception e){
                                
            Logger.getLogger(NBNEastCallout .class).debug(e);
            Logger.exitLogger();
        }
    }
	public static void UpsertSQRecords(Service_Qualification__c sq,List<Service_Qualification_Provider_Resource__c> providerresourceList,String compositeKey){
        try{
            if(sq!=null){
                cscrm__Site__c site=[select id from cscrm__Site__c where Composite_Key__c =: compositeKey limit 1];
                if(site!=null){
                    sq.site__c=site.id;
                	upsert sq;
                    if(providerresourceList.size()>0 && providerresourceList !=null){
                        insert providerresourceList;
                   
                    }
                    
                }               
			}            
        }catch(Exception e){
            System.debug('Exception while checking for Service Qualification : ' + e.getMessage());
            Logger2 logger = Logger2.getLogger('SiteSQAddressHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
			
	}
}