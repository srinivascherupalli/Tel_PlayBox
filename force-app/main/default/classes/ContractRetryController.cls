public with sharing class ContractRetryController {
    @auraenabled
        public static String displayError(string recordId){
            ContractJunction__c objConj;
            String retVal = 'InProgress';
            system.debug('recordId '+recordId);
            try{
                objConj = [select CreatedDate,account__r.APTPS_DocuSign_Restricted__c,CongaStatus__c,Related_Basket__c,Name from ContractJunction__c where id=:recordId];
                list<ContentDocumentLink> lstConjDocs = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :objConj.id AND (ShareType = 'V' OR ShareType = 'I')];
                System.debug('lstConjDocs:'+lstConjDocs);
                System.debug('APTPS_DocuSign_Restricted flag :' + objConj.account__r.APTPS_DocuSign_Restricted__c);
                if(!lstConjDocs.isEmpty() && objConj.account__r.APTPS_DocuSign_Restricted__c){
                    retVal = 'Docusign Restricted';
                }else if(!lstConjDocs.isEmpty()){
                    retVal = 'Success'; 
                }else if(objConj.CreatedDate !=null){
                    if(objConj.CreatedDate.Date()<=system.today() && objConj.CongaStatus__c !='Success'){
                        DateTime myDateTime = objConj.CreatedDate.addMinutes(15); 
                        System.debug(objConj.createddate);
                        System.debug('myDateTime'+myDateTime);
                        System.debug('system.now()'+system.now());
                        System.debug(myDateTime>system.now());            
                        if(myDateTime>system.now())
                            return 'InProgress'; 
                        else{
                            markContractJunctionErr(objConj);
                            return 'Failure';
                        }
                    }
                    
                }
              }catch(QueryException e){
                System.debug(e.getMessage());
                Logger.getLogger(ContractRetryController.class).debug(e);
                Logger.exitLogger();
                markContractJunctionErr(objConj);
                retVal = 'Failure';
                  
            }catch(Exception e){
                System.debug(e.getMessage());
                Logger.getLogger(ContractRetryController.class).debug(e);
                Logger.exitLogger();
                markContractJunctionErr(objConj);
                retVal = 'Failure';
            }
            system.debug('Retval --> '+retVal);
            return retVal;
            }
        
        public static void markContractJunctionErr(ContractJunction__c objConj)
            {
                if(objConj!=null){
                    objConj.CongaStatus__c = 'Error';
                    upsert objConj;
                }
            }
        @auraenabled
        public static String getcontractName(string recordId){
           ContractJunction__c objConj;
            objConj = [select Name from ContractJunction__c where id=:recordId];
            system.debug('contract name :' + objConj.Name);
           return objConj.Name; 
        }
        
        @auraenabled
        public static String getcontractStatus(string recordId){
           ContractJunction__c objConj;
            objConj = [select Status__c from ContractJunction__c where id=:recordId];
            system.debug('contract status :' + objConj.Status__c);
           return objConj.Status__c; 
        }
        
        @auraenabled
        public static String updateContractStatus(string recordId , String changeaction ){
           system.debug('inside contract status update controller');
            String status = null;
            string basketId = null;
            list<ContractJunction__c> contractStatus;
            list<cscfga__Product_Basket__c> basket; 
            try{
                contractStatus = Database.query('select Related_Basket__r.csordtelcoa__Basket_Stage__c,Status__c  from ContractJunction__c  where Id = : recordId');
                basketId = contractStatus[0].Related_Basket__r.id;
                basket = Database.query('select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where Id = : basketId');
                if(changeaction == 'UpdateStatusButton'){
                    contractStatus[0].Status__c = 'Contract Accepted';
                    basket[0].csordtelcoa__Basket_Stage__c = 'Contract Accepted';
                }
                else if(changeaction == 'DeclineStatusButton'){
                    contractStatus[0].Status__c = 'Signature Declined';
                    basket[0].csordtelcoa__Basket_Stage__c = 'Contract Rejected';
                }
                update contractStatus;
                update basket;
                status = contractStatus[0].Status__c;
                system.debug('****status:'+status);
                }catch(Exception e){
                system.debug('Exception message ' + e.getMessage());
            }
            return status;
            
        }
        
        @auraenabled
        public static String retryContractGeneration(string recordId)
            {
                String response='';
                system.debug('Retry ----'+recordId);
                ContractJunction__c objConj = [select createddate,CongaStatus__c,Related_Basket__c from ContractJunction__c where id=:recordId];
                String BasketId = objConj.Related_Basket__c;
                System.debug('BasketId = '+BasketId);
                if(BasketId!=null)
                {
                    GenerateContract genContract = New GenerateContract();
                    map<string, Id> ContractSignatories = new map<string, Id>();
                    response = genContract.createContract(BasketId, ContractSignatories, 'ContractRetry',false,null); 
                }
                return 'InProgress';
            }
        
        @auraenabled
        public static String checkContractDocumentGeneration(String recordId)
            {
                return displayError(recordId);
            }
       /*-------------------------------------------------------- 
    EDGE-187048
    Description: Method to fetch the contract junction record is conga restricted or not
    Author:Dheeraj Singh
    --------------------------------------------------------*/
        
        @auraenabled
        public static Map<String,Boolean> getcontractDocusignEnabledStatus(string recordId){
           ContractJunction__c objConj;
            objConj = [select id,isDSAGenerated__c,BSA_Generated__c,Restrict_Conga_Flow__c,Related_Price_Schedule__r.Apttus__Source__c from ContractJunction__c where id=:recordId];//Added fields as per DIGI-14389
            system.debug('contract status :' + objConj.Restrict_Conga_Flow__c);
            Map<String,Boolean> contractValueMap =  new Map<String,Boolean>();
            //DIGI-14389 added below if condition
            if(objConj.Related_Price_Schedule__r.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL){
                if(objConj.BSA_Generated__c!=null ||objConj.isDSAGenerated__c!=null)
                //if(objConj.isDSAGenerated__c==true)
                    contractValueMap.put('isDSAFlag',true);
                else 
                    contractValueMap.put('isDSAFlag',false);
            }
            contractValueMap.put('restrictCongaFlag',objConj.Restrict_Conga_Flow__c);
            
           return contractValueMap; 
        }
        
       /*-------------------------------------------------------- 
    EDGE-187048
    Description: Method to check if the document is generated or not for contract junction record 
    Author:Dheeraj Singh
    --------------------------------------------------------*/
        @auraenabled
        public static String checkDocumentGenerated(String recordId)
            {
                ContractJunction__c objConj;
                try{
                     objConj = [select id,Related_Price_Schedule__r.Apttus__Parent_Agreement__r.Id,Related_Price_Schedule__r.Apttus__Parent_Agreement__r.APTPS_Send_for_eSignature__c,CreatedDate,account__r.APTPS_DocuSign_Restricted__c,CongaStatus__c,Related_Basket__c,Name from ContractJunction__c where id=:recordId];
                    list<ContentDocumentLink> lstConjDocs = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :objConj.id AND (ShareType = 'V' OR ShareType = 'I')];
                    system.debug('lstConjDocs=='+lstConjDocs);
                    if(lstConjDocs.size()>0){
                       return objConj.Related_Price_Schedule__r.Apttus__Parent_Agreement__r.Id;
                       // return null; 
                    }
                    return null; 
                        }
                catch(exception e){
                    return null;
                }
                
            }
        //EDGE-187048 end
        }