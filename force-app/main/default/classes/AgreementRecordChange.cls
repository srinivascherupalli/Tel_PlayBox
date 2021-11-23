/**
* @Author   :   Lokesh, Monali
* @Date     :   March 2021
* @Desc     :   This class is written for Update agreement Records when docusign envelop status changes to voided.
* @US       :   EDGE-205307
* */
public with sharing class AgreementRecordChange {
    
    public static Set<id> pSAggrementIds = new Set<id>();
	public static Set<id> pSDprIds1 = new Set<id>();
	public static Set<id> pBasketId = new Set<id>();
	public static Set<id> cJunctionId = new Set<id>();

    public static Set<id> DSAAgreementIds = new Set<id>();
	public static List<id> frameAggrList = new List<id>();
	public static List<Apttus__APTS_Agreement__c> psAgrUpdate = new List<Apttus__APTS_Agreement__c>();
    public static List<Apttus__APTS_Agreement__c> DsapsAgrUpdate = new List<Apttus__APTS_Agreement__c>();

	public static List<csconta__Frame_Agreement__c> csFrameAgreementUpdate = new List<csconta__Frame_Agreement__c>();
	public static List<Delegated_Pricing_Request__c> dprUpdate2 = new List<Delegated_Pricing_Request__c>();
	public static List<cscfga__Product_Basket__c> updatePBasket = new List<cscfga__Product_Basket__c>();
	public static List<ContractJunction__c> updateCJunction = new List<ContractJunction__c>();    
    public static Map<Id,Apttus__APTS_Agreement__c> idVsUpdateAgg = new Map<Id,Apttus__APTS_Agreement__c>();

    public static Map<Id,Apttus__APTS_Agreement__c> idVsUpdatepsAgg = new Map<Id,Apttus__APTS_Agreement__c>();

	public static Map<Id,csconta__Frame_Agreement__c> idVsUpdateFA = new Map<Id,csconta__Frame_Agreement__c>();
	public static Map<Id,Delegated_Pricing_Request__c> idVsUpdateDPR = new Map<Id,Delegated_Pricing_Request__c>();
	public static Map<Id,cscfga__Product_Basket__c> idVsUpdatePB = new Map<Id,cscfga__Product_Basket__c>();
	public static Map<Id,ContractJunction__c> idVsUpdateCJ = new Map<Id,ContractJunction__c>();
    
	
    @InvocableMethod(label = 'Agreement record Update')
    public static void changeAgreement(list<Apttus__APTS_Agreement__c> aggId){
		for(Apttus__APTS_Agreement__c ag1: aggId) {
                pSAggrementIds.add(ag1.id);
                pSDprIds1.add(ag1.Delegated_Pricing_Request__c);
				pBasketId.add(ag1.Related_Basket__c);
				cJunctionId.add(ag1.Related_Contract__c);
        }
		if(!pSAggrementIds.isEmpty()){
			
			psAgrUpdate=pSAgreementRecordUpdation(pSAggrementIds);
			
			if(!pSDprIds1.isEmpty()){
            frameAggrList = fetchFrameAgreementIDContractRejected(pSAggrementIds, pSDprIds1);
			csFrameAgreementUpdate = frameAgreementRecordUpdationContractRejected(frameAggrList);			
			dprUpdate2 = dprRecordUpdationContractRejected(pSDprIds1);
		    }
			if(!pBasketId.isEmpty() && !cJunctionId.isEmpty() ){
				for(Apttus__APTS_Agreement__c ag: aggId){

                    	DSAAgreementIds.add(ag.id);
						updatePBasket = updateProductBasket(pBasketId);
						updateCJunction = updateContractJunction(cJunctionId);
                    if(!DSAAgreementIds.isEmpty()){
                    	DsapsAgrUpdate=dsaPSAgreementRecordUpdation(DSAAgreementIds);
                    }

				}
			}
			
        }
        
        for(Apttus__APTS_Agreement__c ag : psAgrUpdate){
                idVsUpdateAgg.put(ag.Id, ag);
        }
		for(csconta__Frame_Agreement__c fa : csFrameAgreementUpdate){
                idVsUpdateFA.put(fa.Id, fa);
        }
		for(Delegated_Pricing_Request__c dpr : dprUpdate2){
                idVsUpdateDPR.put(dpr.Id, dpr);
        }
		for(cscfga__Product_Basket__c pb : updatePBasket){
                idVsUpdatePB.put(pb.Id, pb);
        }
		for(ContractJunction__c cj : updateCJunction){
                idVsUpdateCJ.put(cj.Id, cj);
        }	

        for(Apttus__APTS_Agreement__c ag : DsapsAgrUpdate){
                idVsUpdatepsAgg.put(ag.Id, ag);
        }

        try{
				if (!psAgrUpdate.isEmpty()){
                    update idVsUpdateAgg.values();
                }
				if (!psAgrUpdate.isEmpty()){
                    update idVsUpdateFA.values();
                }
				if (!psAgrUpdate.isEmpty()){
                    update idVsUpdateDPR.values();
                }
				if (!psAgrUpdate.isEmpty()){
                    update idVsUpdatePB.values();
                }
				if (!psAgrUpdate.isEmpty()){
                    update idVsUpdateCJ.values();
                }

            	if (!DsapsAgrUpdate.isEmpty()){
                    update idVsUpdatepsAgg.values();
                }

        }catch (DmlException e) { 
            System.debug('Exception while updating : ' + e.getMessage());
        }
    }
	
    public static List<Apttus__APTS_Agreement__c> pSAgreementRecordUpdation(Set<id> pSAggrementIds){
        List<Apttus__APTS_Agreement__c> csAgrUpdate =  new List<Apttus__APTS_Agreement__c>();
        List<Id> aggId = new List<Id>();
        for(Apttus__APTS_Agreement__c psAgreement:[Select id,Apttus__Status__c,Apttus__Status_Category__c From Apttus__APTS_Agreement__c Where ID IN:pSAggrementIds]) {
                
                psAgreement.Apttus__Status__c = 'Cancelled Request';
                psAgreement.Apttus__Status_Category__c='Cancelled';
                csAgrUpdate.add(psAgreement);
            }
       for(Apttus__APTS_Related_Agreement__c aggJun : [SELECT Apttus__APTS_Contract_From__r.Id,Apttus__APTS_Contract_To__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_To__c IN: pSAggrementIds]) {
            aggId.add(aggJun.Apttus__APTS_Contract_From__r.Id); 
        } 
        if(!aggId.isEmpty()){
            for(Apttus__APTS_Agreement__c oldAgreement : [Select id,Apttus__Status_Category__c,Apttus__Status__c   From Apttus__APTS_Agreement__c  Where  Id IN:aggId]){
                oldAgreement.Apttus__Status__c = 'Activated';
                oldAgreement.Apttus__Status_Category__c='In Effect';
                csAgrUpdate.add(oldAgreement);
                
            }
        }
        return csAgrUpdate;
    }
	

    //To update DSA related PS record
    public static List<Apttus__APTS_Agreement__c> dsaPSAgreementRecordUpdation(Set<id> DSAAgreementIds){
        
        List<Apttus__APTS_Agreement__c> AgrRecUpdate =  new List<Apttus__APTS_Agreement__c>();
		for(Apttus__APTS_Agreement__c psAgreement:[Select id,Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c From Apttus__APTS_Agreement__c Where Apttus__Parent_Agreement__c IN:DSAAgreementIds]) {
                
                psAgreement.Apttus__Status__c = 'Cancelled Request';
                psAgreement.Apttus__Status_Category__c='Cancelled';
                AgrRecUpdate.add(psAgreement);
            }
			return AgrRecUpdate;
        
    }
	

 //To fetch related frame agreement Record 
 public static List<id> fetchFrameAgreementIDContractRejected(Set<id> aggrementIds2, Set<id> dprIds2){
        List<id> frameAggrList2 = new List<id>();
        List<FA_Agreement_Association__c> associationList = new List<FA_Agreement_Association__c>([Select id,FA__c From FA_Agreement_Association__c Where FA__r.Delegated_Pricing_Request__c in:dprIds2 LIMIT 1]);
        if (!associationList.isEmpty()){
            for(FA_Agreement_Association__c ac:associationList) {
                frameAggrList2.add(ac.FA__c);
            }
        }
        return frameAggrList2;
    }
	
//To Update Related Frame agreement Record 
  public static List<csconta__Frame_Agreement__c> frameAgreementRecordUpdationContractRejected(List<id> frameAggrList2){ 
        List<csconta__Frame_Agreement__c> csFrameAgrUpdate =  new List<csconta__Frame_Agreement__c>();                   
            for(csconta__Frame_Agreement__c csFrameAgreement:[Select ID,csconta__Status__c From csconta__Frame_Agreement__c Where ID IN:frameAggrList2 LIMIT 1]) {
                csFrameAgreement.csconta__Status__c ='Contract Rejected';  
                csFrameAgrUpdate.add(csFrameAgreement);
            }   
        return csFrameAgrUpdate;
    }
	
//To update DPR Record 
	 public static List<Delegated_Pricing_Request__c> dprRecordUpdationContractRejected(Set<id> dprIds2){
        List<Delegated_Pricing_Request__c> dprRecordUpdate2 =  new List<Delegated_Pricing_Request__c>();
        for(Delegated_Pricing_Request__c dprRecord : [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where ID IN:dprIds2 LIMIT 1]){
                dprRecord.Deal_Status__c = 'Contract Rejected';
                dprRecordUpdate2.add(dprRecord);            
         }  
         return dprRecordUpdate2;
    }
	
//To Update Product Basket 	
	public static List<cscfga__Product_Basket__c> updateProductBasket(Set<Id> pBasketId){ 
	List<cscfga__Product_Basket__c> updateList = new List<cscfga__Product_Basket__c>();
	List<cscfga__Product_Basket__c> pBList = [SELECT Id , csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE Id IN: pBasketId];
	for(cscfga__Product_Basket__c p : pBList){
		p.csordtelcoa__Basket_Stage__c = 'Contract Rejected';
		updateList.add(p);
	}
	return updateList;
	}
// To update Contract Junction 	
	public static List<ContractJunction__c> updateContractJunction(Set<Id> cJunctionId){ 
	List<ContractJunction__c> updateList = new List<ContractJunction__c>();
	List<ContractJunction__c> cNList = [SELECT Id, Status__c FROM ContractJunction__c WHERE Id IN: cJunctionId];
	for(ContractJunction__c p : cNList){
		p.Status__c = 'Void';
		updateList.add(p);
	}
	return updateList;
}

}