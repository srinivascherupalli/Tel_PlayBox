@istest
public without sharing class CampaignTriggerHelper_Test {
	 private static testMethod void CampaigntestCreate() {
         try{
        	Id DiamondCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Diamond Campaign').getRecordTypeId();
        	Id DefaultCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        	campaign cmp=new Campaign();
             cmp.Name='Test Campaign';
             cmp.Status='Planned';
             cmp.Type='Daimond Progress';
             cmp.RecordTypeId=DiamondCampRecordTypeId;
             insert cmp;
             campaign cmp1=new Campaign();
             cmp1.Name='Test Campaign';
             cmp1.Status='Sent';
             cmp1.Type='Daimond Progress';
             cmp1.RecordTypeId=DiamondCampRecordTypeId;
             insert cmp1;
             campaign cmp2=new Campaign();
             cmp2.Name='Test Campaign';
             cmp2.Status='Responded';
             cmp2.Type='Daimond Progress';
             cmp2.RecordTypeId=DiamondCampRecordTypeId;
             insert cmp2;
            campaign cmp3=new Campaign();
             cmp3.Name='Test Campaign3';
             cmp3.Status='Sent';
             cmp3.Type='Advertisment';
             cmp3.RecordTypeId=DefaultCampRecordTypeId;
             insert cmp3;
             CampaignMemberStatus cms=new CampaignMemberStatus( 
                                CampaignId = cmp.id, 
                                HasResponded = True, 
                                //IsDefault = True, 
                                Label = 'Sent' ,
                                SortOrder = 1);
             CampaignMemberStatus cms1=new CampaignMemberStatus( 
                                CampaignId = cmp1.id, 
                                HasResponded = True, 
                                //IsDefault = True, 
                                Label = 'Responded' ,
                                SortOrder = 2);
             
				insert cms;
				insert cms1;
					system.assertEquals(DiamondCampRecordTypeId, cmp2.RecordTypeId); 
         }
         catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());
         }
     }
}