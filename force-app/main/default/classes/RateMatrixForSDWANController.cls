/*************************************************************************************************************************
* @Author       : Lalit Motiray
* @Created Date : 28 Oct 2020
* @Description  : RateMatrixForSDWAN lightning component controller 
* @Jira         : DPG-3110
***************************************************************************************************************************/
public class RateMatrixForSDWANController {
    
    
    /*
     *@purpose : Get the material groups for commercial Product (Plan Name)
     *@param   : commercial Product Id
     *@return  : Response (isSuccess, Data or message)
     */
    @AuraEnabled
    public static Response getMaterialGroups(Id commercialProdId){
        
		if(commercialProdId == null){
			return new Response(false, 'Commercial Product Id is blank');
		}
		
        try{
            
			cspmb__Commercial_Product_Material_Group_Assoc__c commProMaterialGrp = [SELECT Id, cspmb__material_group__c 
																					FROM cspmb__Commercial_Product_Material_Group_Assoc__c 
																					WHERE cspmb__commercial_product__c =: commercialProdId];
			 
			 
            List<cspmb__Material_Group_Material_Association__c> materialGrpAssociationList;
            
            System.debug('label==>'+ System.Label.Material_Group_Association_Fields);
            
            String queryString = 'SELECT ' +  System.Label.Material_Group_Association_Fields + 
								 ' FROM cspmb__Material_Group_Material_Association__c '+
                                 'WHERE cspmb__material__r.Non_Commercial_Schema__c != null	 AND cspmb__material_group__c = \''+ 
								        commProMaterialGrp.cspmb__material_group__c +'\'';   

			materialGrpAssociationList = Database.Query(queryString);	

			Map<String, String> columnHeaderToValueMap = new RateMatrixForSDWANController().createRateMatrixData(materialGrpAssociationList);
									  
            return new Response(true, columnHeaderToValueMap);
            
        }catch(Exception exp){
            return new Response(false, 'Error while trying to access the material ' + exp.getMessage());
        }        
    }
	
	
	/**
     *@purpose : create rate matrix data to display in SDWAN solution  
     *@param   : materialGrpAssociationList (Material group and material association)
     *@return  : columnHeaderToValueMap (Plan detail table header and its values)
     */
	private Map<String, String> createRateMatrixData (List<cspmb__Material_Group_Material_Association__c> materialGrpAssociationList){
		
		Map<String, String> columnHeaderToValueMap = new Map<String, String>();
		
		if(materialGrpAssociationList == null){
			return columnHeaderToValueMap;
		}
		
		for(String ratematrixColHeader : System.Label.SDWAN_Rate_Matrix_Column_Headers.split(',')){
			
			for(cspmb__Material_Group_Material_Association__c materialGrpMaterialAssociationRec : materialGrpAssociationList){
																				
				if(materialGrpMaterialAssociationRec.cspmb__material__c != null && 
				  ratematrixColHeader.containsIgnoreCase(materialGrpMaterialAssociationRec.cspmb__material__r.Non_Commercial_Schema__r.Name)){
					   
					columnHeaderToValueMap.put(ratematrixColHeader, materialGrpMaterialAssociationRec.cspmb__material__r.Name);
					break;
					
				}else if(ratematrixColHeader == 'Plan Name'){
					
					columnHeaderToValueMap.put(ratematrixColHeader, materialGrpMaterialAssociationRec.cspmb__material_group__r.Name);
					break;
					
                 // need to check the condition a schema name and header is different  
				}else if(ratematrixColHeader == 'SecureEdge Cloud Bandwidth[Mbps]' && 
                         materialGrpMaterialAssociationRec.cspmb__material__r.Non_Commercial_Schema__r.Name == 'prisma'){
                    
                    columnHeaderToValueMap.put(ratematrixColHeader, materialGrpMaterialAssociationRec.cspmb__material__r.Name);
                }
			}
		}
        
		return columnHeaderToValueMap;
	}
	
    
    /*
     *@purpose : To return the response for the SDWAN material groups
     */
    public class Response {
        
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public Object data {get;set;}
        
        public Response(Boolean isSuccess, Object data){
            this.isSuccess = isSuccess;
            this.data = data;
        }
        
        public Response(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}