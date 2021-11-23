/*
*   This need to be removed as part of 1710 NFB-4098
*/
@isTest
public class AppointmentImpl {
/*
    public static final String CORRELATION_ID = '{{CORRELATION_ID}}';
    public static final String REQUEST_SENT_DATE = '{{REQUEST_SENT_DATE}}';
    public static final String USER_ID = '{{USER_ID}}';
    public static final String APPOINMENT_TYPE = '{{APPOINMENT_TYPE}}';
    public static final String SLOT_TYPE = '{{SLOT_TYPE}}';
    public static final String APPOINTMENT_REQUESTED_START_TIME = '{{APPOINTMENT_REQUESTED_START_TIME}}';
    public static final String APPOINTMENT_REQUESTED_END_TIME = '{{APPOINTMENT_REQUESTED_END_TIME}}';
    public static final String APPOINTMENT_RESCHEDULE_REQUEST_REASON = '{{APPOINTMENT_RESCHEDULE_REQUEST_REASON}}';
    public static final String REQUESTED_ADDRESS_ID = '{{REQUESTED_ADDRESS_ID}}';
    public static final String APPOINTMENT_ID = '{{APPOINTMENT_ID}}';
    public static final String QUERY_HANDLER_NAME = 'AppointmentQueryHandler';
    public static final String RESCHEDULE_HANDLER_NAME = 'AppointmentRescheduleHandler';
    public static final String INSTALLATION_TYPE = '{{INSTALLATION_TYPE}}';
    
    public static List<AppointmentDTO> queryForSlot(Date startDate, String slotType, String appointmentType, String siteId,String installationType){

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'QuerySlot' LIMIT 1];
        String reqBody = sr.Body.toString();    
        reqBody = replaceTokens(startDate,slotType,appointmentType,siteId,installationType,null,null,reqBody);
        return sendRequest(reqBody,QUERY_HANDLER_NAME);
    }
    
   

    public static List<AppointmentDTO> reScheduleForSlot(Date startDate, String slotType, String appointmentType, String siteID,String installationType,
                                           String appointmentId, String reason){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ReschduleSlot' LIMIT 1];
        String reqBody = sr.Body.toString();        
        reqBody = replaceTokens(startDate,slotType,appointmentType,siteId,installationType,appointmentId,reason,reqBody);
        return sendRequest(reqBody,RESCHEDULE_HANDLER_NAME);        
    }

    private static String replaceTokens(Date startDate, String slotType, String appointmentType, String siteID,String installationType,
                                           String appointmentId, String reason,String reqBody){

        reqBody = reqBody.replace(CORRELATION_ID, generateUniqueKey());
        reqBody =  reqBody.replace(REQUEST_SENT_DATE, String.valueOf(System.now()));
        reqBody =  reqBody.replace(USER_ID, UserInfo.getUserId());
        reqBody =  reqBody.replace(APPOINMENT_TYPE, appointmentType);
        reqBody =  reqBody.replace(SLOT_TYPE, slotType);
        reqBody =  reqBody.replace(APPOINTMENT_REQUESTED_START_TIME, String.valueOf(startDate));
        reqBody =  reqBody.replace(APPOINTMENT_REQUESTED_END_TIME, String.valueOf(startDate.addDays(60)));  
        reqBody =  reqBody.replace(REQUESTED_ADDRESS_ID, siteID);   
        reqBody =  reqBody.replace(INSTALLATION_TYPE, installationType);

        if(appointmentId!=null){
            reqBody =  reqBody.replace(APPOINTMENT_ID, appointmentId);
            reqBody =  reqBody.replace(APPOINTMENT_RESCHEDULE_REQUEST_REASON, reason);
        }

        return reqBody;
    }

     // Create Requests
    private static List<AppointmentDTO> sendRequest(String payload,String handlerName) {

        List<AppointmentDTO> retVal = new List<AppointmentDTO>();
        
        String token = 'test';//AuthenticationManager.getOauthToken('APPT');
        System.debug('Token: ' + token);
        String soapEnv = 'http://schemas.xmlsoap.org/soap/envelope/';
        String queryRespTag = 'http://www.telstra.com/FieldWorkOrderManagement/ISL-FWOM/v1/FieldWorkOrderManagement.wsdl';
        String workEventRespTag = 'http://www.telstra.com/FieldWorkOrderManagement/ISL-FWOM/v1/FieldWorkOrderManagement.xsd';
        String v1RespTag = 'http://www.telstra.com/OCIM/v1';
       
        //if(token != null) {
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Content-Type', 'application/xml');
            headerMap.put('Authorization', 'Bearer ' + token);
            
            HTTPResponse res = IntegrationRecordHandlerUtil.callout(payload, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, null);
            //System.debug('HTTPResponse is : ' + res.getBody());

            DOM.Document doc = new DOM.Document(); 
            doc.load(res.getBody()); 
            DOM.XMLNode root = doc.getRootElement();

            Dom.XmlNode soapBodyNode = root.getChildElement('Body',soapEnv);

            if(soapBodyNode!=null){         
                Dom.XmlNode queryRespNode = soapBodyNode.getChildElement('queryWorkForceAvailabilityResponse',queryRespTag);
                
                if(queryRespNode!=null){
                    System.debug('Parent queryRespNode is ' + queryRespNode.getName());
                    for (Dom.XMLNode childQuerywork: queryRespNode.getChildElements()) {
                          System.debug('child queryRespNode getName() is ' + childQuerywork.getName());
                          if(childQuerywork.getNodeType() == DOM.XMLNodeType.ELEMENT && childQuerywork.getName()=='queryWorkForceAvailabilityResponse'){
                              Dom.XmlNode workEventRespNode = childQuerywork.getChildElement('WorkForceEvent',workEventRespTag);
                              System.debug('workEventRespNode node : ' + workEventRespNode.getName());
                              if(workEventRespNode!=null){
                                for(Dom.XMLNode calendarNodes: workEventRespNode.getChildElements()){
                                    Dom.XmlNode calendarEntryNodes = calendarNodes.getChildElement('CalendarEntry',v1RespTag);
                                    if(calendarEntryNodes!=null){
                                        Dom.XmlNode simpleExpNode = calendarEntryNodes.getChildElement('SimpleTemporalExpression',v1RespTag);
                                        if(simpleExpNode!=null){
                                            Dom.XmlNode timePeriodNode = simpleExpNode.getChildElement('timePeriod',v1RespTag);
                                            if(timePeriodNode!=null){
                                                Dom.XmlNode startTimeNode = timePeriodNode.getChildElement('startDateTime',v1RespTag);
                                                Dom.XmlNode endTimeNode = timePeriodNode.getChildElement('endDateTime',v1RespTag);
                                                AppointmentDTO appt = new AppointmentDTO();
                                                String startTimeStr = startTimeNode.getText();
                                                String endTimeStr = endTimeNode.getText();
                                                
                                                startTimeStr = startTimeStr.replace('T',' ');
                                                String startDt = String.valueof(DateTime.valueOf(startTimeStr).date());                                                
                                                                                             
                                                endTimeStr = endTimeStr.replace('T',' ');
                                                
                                                appt.slotDate = startDt;
                                                appt.startTime = DateTime.valueOf(startTimeStr).format('HH:mm:ss');
                                                appt.endTime = DateTime.valueOf(endTimeStr).format('HH:mm:ss');
                                                System.debug('New Appt added : ' + appt);
                                                retVal.add(appt);
                                            }
                                        }
                                    }
                                }
                                
                              }
                          }
                    }
                }               
            }
        
        //} 
        System.debug('RetVal New Appt size : ' + retVal.size());
        return retVal;       
    }

    private static String generateUniqueKey() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        System.debug('!@#$% Generated Unique Key : ' + hexDigest);
        return hexDigest;
    }
    */
}