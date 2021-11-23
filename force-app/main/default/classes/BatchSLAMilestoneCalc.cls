public with sharing class BatchSLAMilestoneCalc implements Database.Batchable<sObject>, schedulable {
	
    public final String query;
    public final Integer batch_size;
    public Decimal slaStage1;
    public Decimal slaStage2;
    public Decimal slaStage3;
    public Decimal avgHandlingTime;
    
    
    public BatchSLAMilestoneCalc() {
        System.debug('=====Inside BatchSLAMilestoneCalc 1=====');
        batch_size = 200;
        query = 'SELECT Id, ' +
                		'Status, ' +
            			'Stage__c, ' +
                		'SLA_Status__c, ' +
                		'SLA_Start_Time__c, ' + 
                		'SLA_Onhold_Time__c, ' +
            			'SLA_Resume_Time__c, ' +
            			'SOC_Handling_Time__c,' +
                		'SLA_Completion_Time__c, ' +
                		'soc_Number_of_Sites__c ' +
                	'FROM Case ' +
                	// EDGE-45687: Removing On Hold Status
                	//'WHERE Status IN (\'In Progress\', \'On Hold\', \'Closed\') ' +
					'WHERE Status IN (\'In Progress\', \'Closed\') ' +
                	'AND RecordType.Name = \'Order request\' ' +
                	'AND soc_Number_of_Sites__c IN (\'1\',\'2-10\',\'11-30\')';
        System.debug('=====query=====' + query);
        new BatchSLAMilestoneCalc(query, batch_size);
    }
    
    public BatchSLAMilestoneCalc(String queryString, Integer batchSize) {
        System.debug('=====Inside BatchSLAMilestoneCalc() 2=====' + queryString);
        query = queryString;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('=====Inside start()=====');
		return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('=====Inside execute()=====' + scope);
        List <Case> caseList = new list<Case>();
        List <Case> caseAHTList = new list<Case>();
		Decimal timeCounter = 0.0000;
        Decimal totalHandlingTime = 0.0000;
        
        getCustomSettings();
        Savepoint sp = Database.setSavepoint();
        
        try {
            for(Case s : scope) {
                Case eachCase = (Case)s;
                System.debug('=====eachCase.SLA_Onhold_Time__c=====' + eachCase.SLA_Onhold_Time__c);
                System.debug('=====eachCase.SLA_Start_Time__c=====' + eachCase.SLA_Start_Time__c);
                System.debug('=====eachCase.SLA_Start_Time__c=====' + eachCase.SLA_Start_Time__c.getTime());
                System.debug('=====System.now().getTime()=====' + System.now().getTime());
                System.debug('=====System.now()=====' + System.now());
                
                if(eachCase.SLA_Onhold_Time__c == null) {
                    timeCounter = (Decimal) (System.now().getTime() - eachCase.SLA_Start_Time__c.getTime())/3600000;
                } else {
                    timeCounter = (Decimal) (System.now().getTime() - eachCase.SLA_Start_Time__c.getTime() + eachCase.SLA_Onhold_Time__c.getTime())/3600000;
                    timeCounter = (Decimal) ((eachCase.SLA_Onhold_Time__c.getTime() - eachCase.SLA_Start_Time__c.getTime()) + (System.now().getTime() - eachCase.SLA_Resume_Time__c.getTime()))/3600000;
                
                }
                System.debug('=====timeCounter=====' + timeCounter);
                System.debug('=====slaStage1=====' + slaStage1);
                System.debug('=====slaStage2=====' + slaStage2);
                System.debug('=====slaStage3=====' + slaStage3);
                System.debug('=====eachCase.Stage__c=====' + eachCase.Stage__c);
                
                if((eachCase.Stage__c).equals('Request Review') ||
                  	(eachCase.Stage__c).equals('Validate Asset And Contract') ||
                  	(eachCase.Stage__c).equals('Assign Order')) {
                    System.debug('=====Inside first loop=====' + eachCase.Stage__c + '===' + timeCounter + '===' + slaStage1);
                        
                    if(timeCounter > slaStage1) {
                    	eachCase.SLA_Status__c = 'Breach at Stage 1';
                    }
            	}
                
                if(eachCase.Stage__c == 'Detail Order') {
                    System.debug('=====Inside second loop=====' + eachCase.Stage__c);
                    if(eachCase.SLA_Status__c == null) {
                        eachCase.SLA_Status__c = 'Complete Stage 1';
                    } else {
                        eachCase.SLA_Status__c += ';Complete Stage 1';
                    }
                    
                    if(timeCounter > slaStage2) {
                        eachCase.SLA_Status__c += ';Breach at Stage 2';
                    }
                }
                
                if(eachCase.Stage__c == 'Capture Order') {
                    eachCase.SLA_Status__c += ';Complete Stage 2';
                    if(timeCounter > slaStage3) {
                        eachCase.SLA_Status__c += ';Breach at Stage 3';
                    }
                }
                System.debug('=====eachCase.SLA_Status__c=====' + eachCase.SLA_Status__c);
                
                if(eachCase.SLA_Onhold_Time__c == null) {
                    eachCase.SOC_Handling_Time__c = (Decimal) (System.now().getTime() - eachCase.SLA_Start_Time__c.getTime())/3600000;
                } else {
                    eachCase.SOC_Handling_Time__c = (Decimal) ((eachCase.SLA_Onhold_Time__c.getTime() - eachCase.SLA_Start_Time__c.getTime()) + (System.now().getTime() - eachCase.SLA_Resume_Time__c.getTime()))/3600000;
                }
                System.debug('=====eachCase.SOC_Handling_Time__c=====' + eachCase.SOC_Handling_Time__c);
                
                totalHandlingTime += eachCase.SOC_Handling_Time__c;
                
                caseList.add(eachCase);
            }
            
            update caseList;
            System.debug('=====totalHandlingTime=====' + totalHandlingTime);
            System.debug('=====scope.size()=====' + scope.size());
            
            avgHandlingTime = totalHandlingTime / scope.size();
          
            for(Case s : scope) {
                Case eachCase = (Case)s;
                eachCase.SOC_Average_Handling_Time__c = avgHandlingTime;
                caseAHTList.add(eachCase);
            }
            update caseAHTList;
            
        } catch(Exception e) {
            Database.rollback(sp);
        }
    }

    public void getCustomSettings() {
        
        List<SLA_Stages__c> slaStagesList = SLA_Stages__c.getall().values();
        System.debug('=====SLA_Stages__c=====' + slaStagesList);
        for(SLA_Stages__c slaStage : slaStagesList) {
			slaStage1 = slaStage.SLA_Stage_1__c;
            slaStage2 = slaStage.SLA_Stage_2__c;
            slaStage3 = slaStage.SLA_Stage_3__c;
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    public void execute (SchedulableContext SC) {
        Database.executeBatch(new BatchSLAMilestoneCalc());
    }
}