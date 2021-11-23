/******************************************************************************************************************
Name          : SiteInfoWrapper
Created By    : Mahaboob Basha
Created Date  : July 20 2019
Description   : This class is the wrapper to hold Site and SQ Response Information invoked from SCSQCheckController
-------
History
-------
VERSION     AUTHOR          DATE            DETAIL
-------     ------          -----           ---------
1.1         Mahaboob        20-07-2019      Created
*****************************************************************************************************************/
global class SiteInfoWrapper {
    public String siteId {get; set;}
    public String siteName {get; set;}
    public String siteAddress {get; set;}
    public String siteAdborId {get; set;}
    public String configGUID {get; set;}
    public String sqDisplayStatus {get; set;}
    public SQResponseWrapper sqResponseInfo {get; set;}
    
    public SiteInfoWrapper(cscrm__Site__c site, Service_Qualification__c siteQ, String guid, SQResponseWrapper sqRes) {
        siteId = site != NULL ? site.Id : '';
        siteName = site != NULL ? site.Name : '';
        siteAddress = site != NULL ? site.Display_Name__c : '';
        siteAdborId = site != NULL ? site.AdborID__c : '';
        configGUID = guid;
        sqDisplayStatus = sqRes != NULL ? sqRes.sqStatus : siteQ != NULL ? siteQ.Status__c : '';
        sqResponseInfo = sqRes != NULL ? sqRes : new SQResponseWrapper();
    }
    
    public class SQResponseWrapper {
        public String sqStatus {get; set;}
        public String nbnAvailability {get; set;}
        public String nbnRFSDate {get; set;}
        public String nbnTechnologyType {get; set;}
        public String nbnTechnologyTypeAcrnym {get; set;}
        public String nbnServiceabilityClass {get; set;}
        public String copperPairIndicator {get; set;}
        public String nbnCompatibility {get; set;}
        public String nbnMaxDownloadSpeed {get; set;}
        public String nbnMaxUploadSpeed {get; set;}
        
        public SQResponseWrapper() {
            
        }
    }
}