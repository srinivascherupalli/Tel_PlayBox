/*
 * CALMSDataProcessingAbstract class impplement the common functions to push CALMS data 
 */

public abstract with sharing class CALMSDataProcessingAbstract {
	public Opportunity opp {get; set;}
	public List<sObject> lstObjects {get; set;}
    
	public CALMSDataProcessingAbstract (Opportunity opp, List<sObject> lstObjects){
		this.opp = opp;
		this.lstObjects = lstObjects;
	}
    
    public abstract void test();
}