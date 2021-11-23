public with sharing class UpdatePIExtIdAndPSCode{
	public static void UpdatePIAndPSCode(){
		List<cspmb__Price_Item__c> priceIteams = new List<cspmb__Price_Item__c>() ;
		Final String  newExternalID= 'test';
        Integer count = 0;
		for(cspmb__Price_Item__c priceitem : [Select Id, External_Id__c  from cspmb__Price_Item__c]){
			priceitem.External_Id__c = newExternalID+String.valueof(count);
			priceIteams.add(priceitem);
            count ++;
		}
		List<cscfga__Product_Definition__c	> productSpecifications = new List<cscfga__Product_Definition__c	>() ;
		
		for(cscfga__Product_Definition__c ps : [Select Id, product_Specification__c  from cscfga__Product_Definition__c]){
            string oldCode = ps.product_Specification__c;
            if(oldCode != null){
            if(oldCode.contains('PS_')){
                string newcode = ps.product_Specification__c.replace('PS_', 'DMCAT_ProductSpecification_');
                ps.product_Specification__c = newcode;
                productSpecifications.add(ps);
            }
            }
		}
		system.debug('priceIteams=='+priceIteams);
        system.debug('productSpecifications=='+productSpecifications);
		update priceIteams; //Update PriceIteam
		update productSpecifications; // Update product Sepecifications
		
		//List<Id> serviceIds = [Select Id from csord__Service__c order by csord__Order__r.CreatedDate desc Limit 5];
		//updatesServiceSpecsAttributes(serviceIds);
	}
	
	public static void updatesServiceSpecsAttributes(List<Id> serviceIds){
		List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE parentId IN :serviceIds AND name = 'ServiceSpecifications.json'];
	}
}