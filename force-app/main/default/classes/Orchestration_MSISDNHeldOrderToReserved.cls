/**================================================================
 * Appirio, Inc
 * Name: Orchestration_MSISDNHeldOrderToReserved
 * Description: Class will create payload and invokes searchReserveMSISDN callout for IP Site with Mobile Access and updates corresponding specifications
 * Created Date: July 4, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
global with sharing class Orchestration_MSISDNHeldOrderToReserved extends Orchestration_AbstractStepHandler {
	//StepList will be fetched in performCallout
	private List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
	//Order --> Service
	private Map<Id, List<csord__Service__c>> orderServiceMap = new Map<Id, List<csord__Service__c>>();
	//ProductConfig --> Attribute Value
	private Map<Id, String> prodConfigToAttValMap = new Map<Id, String>();
	//Store order --> step relationship
	private Map<Id, Id> stepRelationshipMap = new Map<Id, Id>();
	//Keep track of order updation
	private List<csord__Order__c> updateOrderList = new List<csord__Order__c>();
	//Track if exception happens for all steps in callout
	private Boolean exceptionInCallOut = false;
	//Store the active step Id
	private String currentStep = '';
	//Store the Id of the step where limit got hit
	private String pendingStep = '';
	//Store Handler Metadata
	private Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
	//Storing the success
	private Set<String> correctStatusCode = new Set<String>{ '200', '201', '202' };
	//Flag to check reset callout
	private Boolean resetCallout;
	//Local constants
	private static String handler = 'HeldToReserveMSISDNHandler';

	/**************************************************************
        Name: performCallouts
        Parameters: List<SObject> steps
        Return Type: Boolean
        Description: Overriding the performCallouts method of Calloutable interface
      *******************************************************************/
	public override Boolean performCallouts(List<sObject> steps) {
		if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
			//Cannot process the records
			return false;
		}

		//Exception Handling
		try {
			stepList = getStepListData(steps);

			Set<Id> prodConfigSet = new Set<Id>();
			//Product Configuration is must for callouts
			for (csord__service__c ser : [SELECT Id, csordtelcoa__Product_Configuration__c, csord__Order__c FROM csord__service__c WHERE csord__order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND NAME LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null]) {
				if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
					//Cannot create collections
					return false;
				}
				//Create Order to Service Map
				if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
					orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
				} else {
					orderServiceMap.get(ser.csord__Order__c).add(ser);
				}

				//Capture the product configuration
				if (ser.csordtelcoa__Product_Configuration__c != null) {
					prodConfigSet.add(ser.csordtelcoa__Product_Configuration__c);
				}
			}

			for (cscfga__attribute__c att : [SELECT Id, Name, cscfga__value__c, cscfga__Product_Configuration__c FROM cscfga__attribute__c WHERE cscfga__Product_Configuration__c IN :prodConfigSet AND Name LIKE '%MSISDN%']) {
				if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
					//Cannot create collections
					return false;
				}
				//Value cannot be filtered in SOQL
				if (att.cscfga__value__c != null) {
					//1:1 mapping for payload
					prodConfigToAttValMap.put(att.cscfga__Product_Configuration__c, att.cscfga__value__c);
				}
			}

            //Fetching the Metadata
            handlerMetaData = getIntegrationHandlerSettings(handler);

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
					if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
						//terminate the loop
						break;
					}

					if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
						//Updating steps as Error since no proper data linked to step
						stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
						//move to next step
						continue;
					}

					if (!orderServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
						//Updating steps as Error since no proper data linked to step
						stepResults.put(step.Id, new stepResult('Success: MSISDN reservation not required for the order', OrchestratorConstants.OrchestratorStep.Complete));
						//move to next step
						continue;
					}

					//Check MSI reservation is required
					if (!step.CSPOFA__Orchestration_Process__r.Order__r.isMSISDNHeld__c) {
						//Updating steps as Complete since isMSISDNHeld__c is false
						stepResults.put(step.Id, new stepResult('Error: MSISDN are not held so cannot make reservation calls', OrchestratorConstants.OrchestratorStep.Error));
						//move to next step
						continue;
					}

					//Check MSI is already reserved
					if (step.CSPOFA__Orchestration_Process__r.Order__r.isMSISDNReserved__c) {
						//Updating steps as Complete since order already reserved
						stepResults.put(step.Id, new stepResult('Success: Number already reserved', OrchestratorConstants.OrchestratorStep.Complete));
						//move to next step
						continue;
					}

					//Setting the current variable
					currentStep = step.Id;

					//generating the token - OAuth Callout
					Datetime startTime = System.now();
					String token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
					Datetime endTime = System.now();
					Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);

					//OAuth Failure
					if (String.isBlank(token)) {
						stepResults.put(step.Id, new stepResult('Error: OAuth Failure', OrchestratorConstants.OrchestratorStep.Error, new List<Orchestration_CallOutResponse>{ new Orchestration_CallOutResponse(null, null, null, null, 'OAuthLogin', 'Exception', null, null, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_GET) }));
						//move to next step
						continue;
					}
					if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
						//Cannot create collections
						return false;
					}

					//Check if reset callouts
					if (step.cspofa__message__c == null || (step.cspofa__message__c != null && step.cspofa__message__c.contains(OrchestratorConstants.SystemConstant.stepResetMsg))) {
						resetCallout = true;
					} else {
						resetCallout = false;
					}

					//Main method called
					generateNumberReq(step.CSPOFA__Orchestration_Process__r.Order__r, token);
				} catch (Exception ex) {
					stepResult cr = this.stepResults.get(step.Id);
					if (cr != null) {
						cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
						cr.status = OrchestratorConstants.OrchestratorStep.Error;
					} else {
						stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
					}
				}
			}
		} catch (Exception ex) {
			exceptionInCallOut = true;
			for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
				stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
			}
		}

		return !this.stepResults.isEmpty();
	}

	/**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
	public override List<SObject> process(List<SObject> steps) {
		if (Orchestration_LimitsUtility.areLimitsViolated() || exceptionInCallOut) {
			//Cannot process the records
			return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
		}

		for (CSPOFA__Orchestration_Step__c step : stepList) {
			try {
				//Limit check
				if (Orchestration_LimitsUtility.areLimitsViolated()) {
					//terminate the loop
					break;
				}

				//Store count of success callouts
				Integer successCnt = 0;

				//Store count of success callouts
				Integer failCnt = 0;

				//If result is not present, perform callout is not done for the step therefore skip the processing of that step
				stepResult cr = this.stepResults.get(step.Id);
				if (cr == null) {
					//Check for next step
					continue;
				}

				//Setting the current variable
				currentStep = step.Id;

				//Message is already given on perform CallOut
				if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
					//move to next step
					continue;
				}

				if (!orderServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
					//move to next step
					continue;
				}

				//Check MSI reservation is required
				if (!step.CSPOFA__Orchestration_Process__r.Order__r.isMSISDNHeld__c) {
					//move to next step
					continue;
				}

				//Check MSI is already reserved
				if (step.CSPOFA__Orchestration_Process__r.Order__r.isMSISDNReserved__c) {
					//move to next step
					continue;
				}

				//Step result will be present only if response was not captured earlier
				if (cr.callOutResponse != null) {
					//Iterating over each response
					for (Orchestration_CallOutResponse resp : cr.callOutResponse) {
						if (Orchestration_LimitsUtility.areLimitsViolated()) {
							//terminate the loop
							break;
						}
						String resCode = resp.statusCode;
						String relRecId = resp.recordId;

						if (resCode != null && relRecId != null && correctStatusCode.contains(resCode)) {
							successCnt++;
						} else {
							failCnt++;
						}
					}
				}

				//Response exists therefore no step result created in performcallout, pending step means limits got hit
				if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(step.Id)) {
					Map<Id, ApplicationLog__c> recToResponse = mapStepIdToRecordApplicationLog.get(currentStep);
					for (ApplicationLog__c applg : recToResponse.values()) {
						if (Orchestration_LimitsUtility.areLimitsViolated()) {
							//terminate the loop
							break;
						}

						String resCode = applg.Status_Code__c;
						String relRecId = applg.Related_Record_Id__c;
						if (resCode != null && relRecId != null && correctStatusCode.contains(resCode)) {
							successCnt++;
						} else {
							failCnt++;
						}
					}
				}

				//Capturing the order
				csord__Order__c ord = step.CSPOFA__Orchestration_Process__r.Order__r;
				Integer serviceCnt = orderServiceMap.get(ord.Id).size();
				if (successCnt == serviceCnt) {
					//DML check to avoid iteration in process method
					if (!hasDMLRowsLimitExceeded()) {
						updateOrderReservation(ord);
					} else {
						//Capturing the step where limit got
						pendingStep = step.Id;
						//Terminate the loop
						break;
					}
				} else if (successCnt + failCnt == serviceCnt) {
					cr.message = 'Error: Please check application logs for Number reservation failure';
					cr.status = OrchestratorConstants.OrchestratorStep.Error;
				}
			} catch (Exception ex) {
				stepResult cr = this.stepResults.get(step.Id);
				if (cr != null) {
					cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
					cr.status = OrchestratorConstants.OrchestratorStep.Error;
				} else {
					stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
				}
			}
		}

		if (updateOrderList.size() > 0) {
			//Call update
			updateObjects();
		}

		return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
	}

	//generate the request Data to make the request and reserve the number
	private void generateNumberReq(csord__Order__c ord, String token) {
		List<Orchestration_CallOutResponse> stepToCallOutResponse = new List<Orchestration_CallOutResponse>();
		Map<Id, ApplicationLog__c> recToResponse = new Map<Id, ApplicationLog__c>();
		Integer callOutCnt = 0;

		//Fetching the response from the application logs
		if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(currentStep)) {
			recToResponse = mapStepIdToRecordApplicationLog.get(currentStep);
		}
		//Order will always have a service, so null check not required
		for (csord__Service__c ser : orderServiceMap.get(ord.Id)) {
			if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
				//Terminate the Method
				break;
			}

			if (!recToResponse.isEmpty() && recToResponse.containsKey(ser.Id)) {
				String resCode = recToResponse.get(ser.Id).Status_Code__c;
				//Check if the response is of success
				if (resCode != null && correctStatusCode.contains(resCode) || !resetCallout) {
					//Callout response exists
					callOutCnt++;
					//No call required
					continue;
				}
			}

			String correlationId = Orchestration_Utility.getUID();
			FNNDTO dto = new FNNDTO();
			FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
			fdo.activityName = 'RESERVE';
			dto.data = fdo;
			String reqBody = JSON.serialize(dto, true);
			Map<String, String> headerMap = new Map<String, String>();
			headerMap.put('Accept', 'application/json');
			headerMap.put('Content-type', 'application/json');
			headerMap.put('Authorization', 'Bearer ' + token);
			headerMap.put('X-HTTP-Method-Override', 'PATCH');
			Map<String, String> pathMap = new Map<String, String>{ 'msisdn' => prodConfigToAttValMap.get(ser.csordtelcoa__Product_Configuration__c) };
			Datetime startTime = System.now();
			HttpResponse resp = reserveNumber(reqBody, headerMap, pathMap);
			Datetime endTime = System.now();
			Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
			String responseBody = resp.getBody();
			String statusCode = String.valueOf(resp.getStatusCode());

			//Callout Done
			callOutCnt++;

			//Capture multiple Response for success
			if (correctStatusCode.contains(statusCode)) {
				stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(ser.Id), reqBody, responseBody, statusCode, handler, 'Integration', null, correlationId, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
			} else {
				stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(ser.Id), reqBody, responseBody, statusCode, handler, 'Exception', null, correlationId, statusCode, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
			}
		}
		//Capture All response, as processing will be done on the process method
		if (callOutCnt == orderServiceMap.get(ord.Id).size()) {
			stepResults.put(currentStep, new stepResult('Success: All Callout Performed', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
		} else {
			stepResults.put(currentStep, new stepResult('Partial Success: Number has been queued for reservation', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
		}
	}

	//To make the actual callout to reserve the number
	private HttpResponse reserveNumber(String reqBody, Map<String, String> headerMap, Map<String, String> pathMap) {
		HttpResponse resp = new HttpResponse();
		resp = Orchestration_CalloutUtility.sendRequestGeneric(reqBody, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, pathMap);

		/*  For testing
        resp.setHeader('Content-Type', 'application/json');
        resp.setStatusCode(200);
        resp.setBody(
            '{"data":{"result":[{"fnn":"0282345560","status":"SUCCESS"}],"resources":[{"resourceId":"0732722177","resourceType":"FNN","resourceState":"HELD PRESENTATION","poolId":25,"characteristics":[{"name":"ESA","value":"APPX"},{"name":"Potential Line Type","value":"SS"}],"category":[{"type":"FNN_Type","value":"Regular"}]}]},"status":200,"responseCode":"LRM-SUCCESS","time":"2018-07-26T05:03:20.299+0000","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","path":"/networks/v2/logical-resources/locks?attributes=all","request":{"data":{"geoParam":"ESA","geoParamValues":"BULA","type":"REGULAR","quantity":1,"pattern":"*2","searchType":"RANDOM","systemId":"MSPA","serviceIds":["9922145874","9822154789"],"fnns":["9922145874","9822154789"]}}}'
        );
*/
		return resp;
	}

	private void updateOrderReservation(csord__Order__c ord) {
		ord.isMSISDNReserved__c = true;
		stepRelationshipMap.put(ord.Id, currentStep);
		updateOrderList.add(ord);
	}

	public override void updateObjects() {
		//Updating all the order records
		List<Database.SaveResult> updateResult = Database.update(updateOrderList, false);

		//Storing the order success Ids
		for (Database.SaveResult rslt : updateResult) {
			String stepId = stepRelationshipMap.get(rslt.getId());
			//Step Result will never be null
			stepResult cr = this.stepResults.get(stepId);
			if (rslt.isSuccess()) {
				cr.message = 'Success: Number Reservation successful';
				cr.status = OrchestratorConstants.OrchestratorStep.Complete;
			} else {
				cr.message = 'Error: DML failed on updating Order record';
				cr.status = OrchestratorConstants.OrchestratorStep.Error;
			}
		}
	}

	private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
		Set<String> stepIds = new Set<String>();
		//Fetching more fields from the query
		List<CSPOFA__Orchestration_Step__c> stepList = [
			SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.isMSISDNHeld__c, CSPOFA__Orchestration_Process__r.Order__r.isMSISDNReserved__c, JSON__c
			FROM CSPOFA__Orchestration_Step__c
			WHERE Id IN :steps
		];

		for (CSPOFA__Orchestration_Step__c step : stepList) {
			//Fetching the order Request
			if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
				orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
				stepIds.add(step.Id);
			}
		}

		//Get the logs related to the steps
		getResponseAndProcessIdAttachments(stepIds, handler);

		//Returning the step list
		return stepList;
	}

	public override boolean hasDMLRowsLimitExceeded() {
		if (updateOrderList.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
			return false;
		}
		//Limit Hit
		return true;
	}
}