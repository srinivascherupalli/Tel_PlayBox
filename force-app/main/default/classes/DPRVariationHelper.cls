/*****************************************************************************************
* ModifiedBy         ModifiedDate     Edge          Description
* Parmanand Shete    22/02/2021       EDGE-194566   Created new method for updateDPRVariation

************************************************************************************************************************************************/

public class DPRVariationHelper{
    public static Delegated_Pricing_Request__c updateDPRVariation( csconta__Frame_Agreement__c fa){
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(
                                            Opportunity__c = fa.Opportunity__c,
                                            Deal_Status__c = 'Draft');
        Delegated_Pricing_Request__c prevDpr = new Delegated_Pricing_Request__c();
        if (fa.csconta__replaced_frame_agreement__c != null){
            dpr.Replaced_DPR__c = fa.csconta__replaced_frame_agreement__r.Delegated_Pricing_Request__c;
            dpr.Mark_as_Variation__c = true;
            prevDpr.Id = fa.csconta__replaced_frame_agreement__r.Delegated_Pricing_Request__c;
        }
        insert dpr;
        if(prevDpr.Id!=null){
            prevDpr.ReplacedBy_DPR__c = dpr.Id;
            Update prevDpr;
        }
        
        fa.Delegated_Pricing_Request__c = dpr.Id;
        update fa;
        return dpr;
    }
}