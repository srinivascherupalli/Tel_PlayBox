/**
 * @description represents a Logging Context
 *   This class is meant to store additional data
 *   for each logs at a global level (@see LoggerFactory)
 * 
 * CHANGES TO EXISTING FRAMEWORK:
 *---------------------------------
 * AUTHOR      : Anup Kabra
 * DATE        : 21-May-2020
 * DESCRIPTION : As part of project requirement, correlation ID will be sent from Apex
 * 				 instead of using the one which framework generates in this class. flush()
 * 				 method from LoggerFactory class assigns correlation ID to CONTEXT_ID variable
 * 				 of this class which used while Inserting record to Transaction Log object.
 *
 */

global class LoggingContext {
    
    /**
     * @description CONTEXT_ID is used for Correlation Id.
     * 
     * CHANGE => [ANUP] CONTEXT_ID will be assigned value from 
     *           LoggerFactory.flush(). Therefore, commenting out
     *           existing CONTEXT_ID assignment row.
     */

    //public static final String CONTEXT_ID = DateTime.now().getTime() + '-' + Math.abs(Crypto.getRandomLong());
    public static  String CONTEXT_ID;
    private static final Map<String, String> MAPPING = new Map<String, String>();

    /**
     * @description returns the context mappingd
     *
     * @return the context mappings
     */
    public static Map<String, String> getMapping() {
        return MAPPING;
    }

    /**
     * @description gets a value from the context
     *
     * @param key the key to retrieve
     * @return the value associated with the key
     */
    global static String get(String key) {
        return MAPPING.get(key);
    }
    /**
     * @description sets a value in the context
     *
     * @param key the key
     * @param value a value associated with the key
     */
    global static void put(String key, String value) {
        if (String.isNotBlank(key)) {
            MAPPING.put(key, value);
        }
    }

    /**
     * @description removes a value from the context
     *
     * @param key the key to remove
     */
    global static void remove(String key) {
        MAPPING.remove(key);
    }
}