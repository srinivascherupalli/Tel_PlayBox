/**
 *  Purpose          :   This class is used to update Order's Status and Record Type if it matches below criteria of it's related services:
 *                       Order.isAppointmentCompleted__c = false and serviceInstance.Appointment_Required__c = 'true' and serviceInstance.modelChange__c = false
 *                              Status = Appointment Required
 *                              recTypeId = 'Appointment Required'
 *                       Order.isAppointmentCompleted__c = true and serviceInstance.Appointment_Required__c = 'true' and serviceInstance.modelChange__c = false
 *                              Status = 'Ready for Submit'
 *                              recTypeId = 'Ready for Submit With Appointment'
 *                       If doesn't matches any of above
 *                              Status = 'Ready for Submit'
 *                              recTypeId = 'Ready for Submit'
 *  
 *  Author          :   Gaurang Maheshwari
 * 
 *  Created Date    :   15 June 2020
 * 
 *  Current Version :   V_1.0
 * 
 *  Revision Log    :   V_1.0 - Gaurang Maheshwari (15 June 2020) - Created/Optimised
 */
global with sharing class Orchestration_OrderNextAvailableStatus Extends Orchestration_AbstractStepHandler {
    
    private static List<RecordType> orderRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
    private List<CSPOFA__Orchestration_Step__c> stepList;
    private Map<Id, List<csord__Service__c>> mapOrderToServices = new Map<Id, List<csord__Service__c>>();
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    
    public override List<sObject> process(List<sObject> data){
        try {
            if(Orchestration_LimitsUtility.areLimitsViolated()){        
                system.debug('stopping execution as limit breached.....');
                return null;
            }  
            stepList= (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
			Map<String, Id> orderRecordTypeNameToIdMap = new Map<String, Id>();
			for(RecordType recTypeInstance : orderRecordTypeList){
                orderRecordTypeNameToIdMap.put(recTypeInstance.Name, recTypeInstance.Id);      
            }
            for(CSPOFA__Orchestration_Step__c step : stepList) {
				stepRelationship.put(step.CSPOFA__Orchestration_Process__r.Order__c, step.id);
            }
            if(stepRelationship.size() > 0) {                
                for(csord__Service__c service : [SELECT Id, Appointment_Required__c, modelChange__c, Name, csord__Service__c, SiteId__c, csord__Subscription__c,
                                                                                            Serviceability_Location__c,Contract_Term__c, 
                                                                                            TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c, 
                                                                                            csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.isMSISDNRequired__c, 
                                                                                            csord__Order__r.isMSISDNReserved__c, csord__Order__r.isAppointmentCompleted__c  
                                                                                            FROM csord__Service__c WHERE csord__service__c = null 
                                                                                            AND csord__Order__c IN:stepRelationship.keyset()]) {
                    if(!mapOrderToServices.containsKey(service.csord__Order__c)) {
                        mapOrderToServices.put(service.csord__Order__c, new List<csord__Service__c>{service});
                    }else{
						mapOrderToServices.get(service.csord__Order__c).add(service);
					}
                 System.debug('mapOrderToServices '+mapOrderToServices);                                                                               
                }
            }
            for(CSPOFA__Orchestration_Step__c step : stepList) {
                try {	
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have a related order', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    if(step.CSPOFA__Orchestration_Process__r.Order__c != null && !hasDMLRowsLimitExceeded()) {
                        //String opportunityId = String.isNotBlank(step.CSPOFA__Orchestration_Process__r.Order__c) && String.isNotBlank(step.CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c) ? step.CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c : null;
                        //Boolean isRequired = false;
                        Boolean isSubmitWithAppointment = false;
                        Boolean isAppointmentRequired = false;
                     for(csord__Service__c service : mapOrderToServices.get(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                            if(step.CSPOFA__Orchestration_Process__r.Order__r.isAppointmentCompleted__c == false && service.Appointment_Required__c == 'true' && !service.modelChange__c) {
                                isAppointmentRequired = true;
								break;
                            } else if(step.CSPOFA__Orchestration_Process__r.Order__r.isAppointmentCompleted__c == true && service.Appointment_Required__c == 'true' && !service.modelChange__c) {
                                isSubmitWithAppointment = true;
                            }/* else if(opportunityId != null) {
            
                                isAppointmentRequired = true;
                            }*/
                        }
                        csord__Order__c order = new csord__Order__c(Id = step.CSPOFA__Orchestration_Process__r.Order__c);
                        if(isAppointmentRequired) {
                            order.csord__Status2__c = OrchestratorConstants.OrderStatus.AppointmentRequired;
                            order.RecordTypeId = orderRecordTypeNameToIdMap.get('Appointment Required');
                            sObjectsToUpdate.put(order.Id, order);
                        } else if(isSubmitWithAppointment) {                            
                            order.csord__Status2__c = OrchestratorConstants.OrderStatus.ReadyForSubmit;
                            order.RecordTypeId = orderRecordTypeNameToIdMap.get('Ready for Submit With Appointment');
                            sObjectsToUpdate.put(order.Id, order);
                        } else {
							order.csord__Status2__c = OrchestratorConstants.OrderStatus.ReadyForSubmit;
                            order.RecordTypeId = orderRecordTypeNameToIdMap.get('Ready for Submit');
                            sObjectsToUpdate.put(order.Id, order);
                        }
                    } 
                } catch(Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch(Exception ex) {
            //System.debug('stepList :::'+ stepList);
            for(CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        if(!sObjectsToUpdate.isEmpty() && !Orchestration_LimitsUtility.areLimitsViolated()){
            updateObjects();
        }
        return processStepResults(stepList, stepResults);
    }

    public override void updateObjects() {
        //Updating all the records including orders and subscription
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        
		//Storing the records
		for (Database.SaveResult rslt : updateResult) {
			//stepRelationship will contain only subscription therefore avoiding updated order records
			//if(stepRelationship.containsKey(rslt.getId())){
			if (rslt.isSuccess()) {
				stepResults.put(stepRelationship.get(rslt.getId()),	new stepResult('Success: Order Updated to next status', OrchestratorConstants.OrchestratorStep.Complete));
			} else {
				//record updation failed there related step updated
				stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to process records as DML failed', OrchestratorConstants.OrchestratorStep.Error));
			}
		}
    }

    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description called to perform SOQL to fetch step data for the data in context for the running batch transaction
     * @param List<sObject> a list of steps being passed in to the process method during batch execution
     */
    public override List<sObject> getStepList(List<sObject> steps) {

        List<sObject> stepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c,
                                    CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c,
                                    CSPOFA__Orchestration_Process__r.Order__r.isAppointmentCompleted__c
                                    FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        return stepList;
    }
}