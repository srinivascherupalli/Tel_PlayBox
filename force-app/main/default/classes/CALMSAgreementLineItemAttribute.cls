public with sharing class CALMSAgreementLineItemAttribute extends CALMSDataProcessingAbstract {
    
    //create a schedule record based on SF/Cloudsense data
    //TODO: hardcode value at the moment. Need to pass the data to the function
    
    
    public APTPS_Component__c createAgreementLineItemRecord(Apttus__AgreementLineItem__c aliRecord, sObject product){
        APTPS_Component__c record = new APTPS_Component__c();
        record.Agreement_Line_Item__c = aliRecord.Id;
        record.Quantity__c = Decimal.valueOf(String.valueOf(product.get('Quantity')));
        if(Decimal.valueOf(String.valueOf(product.getSObject('cscfga__Attribute__r').get('RecurringCharge__c'))) > 0){            
            String pcId = String.valueOf(product.getSObject('cscfga__Attribute__r').get('cscfga__Product_Configuration__c'));
            system.debug('PC ID :'+pcId);
    		String attrbuteName = 'frequency';
    		cscfga__Attribute__c frequencyAttr = [select Id, Name, cscfga__Value__c, cscfga__Line_Item_Description__c, cscfga__Price__c, cscfga__Is_Line_Item__c, cscfga__is_active__c from cscfga__Attribute__c where cscfga__Product_Configuration__c =:pcId and NAME=:attrbuteName];
            
            record.APTPS_Attribute__c = String.valueOf(product.get('Product_Name__c')) + ' - ' + 'Rerurring Charge' + ' - '+ frequencyAttr.cscfga__Value__c;
            record.APTPS_Original_Value__c = String.valueOf(product.getSObject('cscfga__Attribute__r').get('RecurringCharge__c'));       
            record.Value__c =  String.valueOf(product.getSObject('cscfga__Attribute__r').get('RecurringCharge__c'));    
        }
        
        if(Decimal.valueOf(String.valueOf(product.getSObject('cscfga__Attribute__r').get('OneOffCharge__c'))) > 0){            
            record.APTPS_Attribute__c = String.valueOf(product.get('Product_Name__c')) + ' - ' + 'Once Off Charge';
            record.APTPS_Original_Value__c = String.valueOf(product.getSObject('cscfga__Attribute__r').get('OneOffCharge__c'));
            record.Value__c =  String.valueOf(product.getSObject('cscfga__Attribute__r').get('OneOffCharge__c'));    
        }
        
        return record;
    }
    
    public CALMSAgreementLineItemAttribute (Opportunity opp, List<sObject> lstObjects){
        super(opp, lstObjects);
    }       
    
    public override void test(){
        system.debug('test');
    }
}