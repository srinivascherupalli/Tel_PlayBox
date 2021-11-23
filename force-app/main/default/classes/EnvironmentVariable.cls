/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to get/set environment variables from custom settings.
*/

global class EnvironmentVariable {
    
    // Get the value of environment variable
    global static String get(String name) {
    	EnvironmentVariable__c record = EnvironmentVariable__c.getInstance(name);
    	
    	if(record != null) {
    		return record.Value__c;
        } else {
        	return null;
        }
    }

    // Set an environment variable, if the environment variable doesn't exists, then create a new one, otherwise update.
    global static String put(String name, String value) {
    	EnvironmentVariable__c record = EnvironmentVariable__c.getInstance(name);
    	if(record == null) {
    		record = new EnvironmentVariable__c(name = name ,Value__c = value);
    	}
    	
    	record.Value__c = value;
    	upsert record;
    	return value;
    }
    
    // Remove an environment variable.
    global static void remove(String name) {
    	EnvironmentVariable__c record = EnvironmentVariable__c.getInstance(name);
    	if(record != null) {
    		delete record;
    	}
    }
}