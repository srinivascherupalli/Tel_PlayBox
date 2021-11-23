/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 08/04/2018 
@ModifiedByandDate: 
@Description: This class will start/stop SLAMilestone on case     
*******************************************************************************/ 
public class soc_SLABusinessHourService {
    
    public static final String CASE_STAGE_VALIDATE_ASSIGN = 'Validate And Assign Order'; 
    public static final String CASE_STAGE_DETAIL_ORDER = 'Detail Order';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_WITHDRAWN = 'Withdrawn';
    public static final String STATUS_REJECTED = 'Rejected';
    public static final String STATUS_ONHOLD = 'On Hold';
    public static final String CASE_STAGE_REQUEST_REVIEW = 'Request Review';
    public static String CASE_RECORDTYPE_SFD_PRODUCT = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    public static String CASE_RECORDTYPE_ORDER_REQUEST = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    
    
    /*
* Method Name: manageSLAMilestone
* Input Parameter:  Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap
* Output Parameter: Void
* Description: For updating stopping/starting milestone on all child case
* Created By:   Sandeep Soni
* Create Date:  08 April 2019
*/
    public static void manageSLAMilestone(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        Map<Id, Case> caseMap = new Map<Id, Case>(); 
        try{
            for(Case cs : newCaseMap.values()){ 
                System.debug('cs.DeveloperName::'+cs.RecordType.DeveloperName);
                System.debug('cs.Stage__c::'+cs.Stage__c);
                if(cs.RecordTypeId == CASE_RECORDTYPE_SFD_PRODUCT && (cs.Stage__c == CASE_STAGE_VALIDATE_ASSIGN 
                                                                     || cs.Stage__c == CASE_STAGE_DETAIL_ORDER)
                  && (cs.Status != STATUS_ONHOLD && cs.Status != STATUS_CLOSED && cs.Status!= STATUS_WITHDRAWN && cs.Status!= STATUS_REJECTED)){
                    caseMap.put(cs.id, cs);  
                }
                
            }
            System.debug('caseMap::'+caseMap);
            soc_SLABusinessHoursHoliday.processHoliday(caseMap);
            
        }
        catch(Exception ex){
            System.debug('Exception on Line Number::'+ex.getLineNumber()+' :: '+ex.getMessage());
        }
        
        
    }
}