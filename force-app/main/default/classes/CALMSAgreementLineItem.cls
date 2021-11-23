public class CALMSAgreementLineItem extends CALMSDataProcessingAbstract{
	//create a schedule record based on SF/Cloudsense data
    
    public Apttus__AgreementLineItem__c createAgreementLineItemRecord(Apttus__APTS_Agreement__c orderFormRecord, Product2 product, Decimal recurring, Decimal oneOff, String site){
        Apttus__AgreementLineItem__c record = new Apttus__AgreementLineItem__c();
        
        record.APTPS_Active__c = true;
        record.Apttus__AgreementId__c = orderFormRecord.Id;
        System.debug('Product:'+product);
        if(product!=null){
            record.Apttus__ProductId__c = String.valueOf(product.Id);
        	record.FF_Attribute__c = product.Name;
        }
       		
        record.Apttus__Description__c = site;
        record.One_Off_Charge__c = oneOff;
        record.Recurring_Charge__c = recurring;
        return record;
    }
     
    public CALMSAgreementLineItem (Opportunity opp, List<sObject> lstObjects){
        super(opp, lstObjects);
    }
    
    public override void test(){
        system.debug('test');
    }
}