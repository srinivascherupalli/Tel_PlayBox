/**
* Version        Date               Author                      Modification
* ----------------------------------------------------------------------------
* 1.0            05/04/2021         Arunkumar V                 Created
*
* @description Helper class for managing the Platform Cache.  Supports both Platform and Session cache,
* and can be used with implementations of Cache.CacheBuilder to populate the cache entry when it is empty.
*/
public class CacheManager {
    // Default time-to-live for the cache entry is 15 minutes
    private static final Integer DEFAULT_TTL = 900;

    /*******************************************************************************************************
    * @description Returns the cached value corresponding to the specified key from the cache.
    * @param type Specifies whether to use the org cache or session cache.
    * @param key A case-sensitive string value that uniquely identifies a cached value. For information about the format of the key name, see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_cache_Org.htm#apex_class_cache_Org
    * @return The cached value as a generic object type. Cast the returned value to the appropriate type.
    * @example
    * CacheManager.get(CacheType.ORG, 'local.ACPartition.activePBId');
    */
    public static Object get(CacheType type, String key) {
        Object value = null;
        if (type == CacheType.ORG) {
            value = Cache.Org.get(key);
            system.debug(value);
        }
        else if (type == CacheType.SESSION) {
            value = Cache.Session.get(key);
        }
        if (value != null) {
            System.debug(LoggingLevel.DEBUG, 'Hit for key ' + key);
        }

        return value;
    }

    /*******************************************************************************************************
    * @description Returns the cached value corresponding to the specified key from the cache. Use this method if your cached value is a class that implements the CacheBuilder interface.
    * @param type Specifies whether to use the org cache or session cache.
    * @param cacheBuilder The Apex class that implements the CacheBuilder interface.
    * @param key A case-sensitive string value that, combined with the class name corresponding to the cacheBuilder parameter, uniquely identifies a cached value.
    * @return The cached value as a generic object type. Cast the returned value to the appropriate type.
    * @example
    * CacheManager.get(CacheType.ORG, TestCacheBuilder.class, 'newkey');
    */
    public static Object get(CacheType type, System.Type cacheBuilder, String key) {
        Object value = null;
        if (type == CacheType.ORG) {
            value = Cache.Org.get(cacheBuilder, key);
        }
        else if (type == CacheType.SESSION) {
            value = Cache.Session.get(cacheBuilder, key);
        }
        if (value != null) {
            System.debug(LoggingLevel.DEBUG, 'Hit for key ' + key);
        }
        return value;
    }

    /*******************************************************************************************************
    * @description Stores the specified key/value pair as a cached entry in the cache. The put method can write only to the cache in your org’s namespace.
    * @param type Specifies whether to use the org cache or session cache.
    * @param key A string that uniquely identifies the value to be cached. For information about the format of the key name, see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_cache_Org.htm#apex_class_cache_Org
    * @example
    * CacheManager.put(CacheType.SESSION, 'correlationId', GuidUtil.NewGuid());
    */
    public static void put(CacheType type, String key, Object value) {
        put(type, key, value, DEFAULT_TTL);
    }

    /*******************************************************************************************************
    * @description Stores the specified key/value pair as a cached entry in the session cache and sets the cached value’s lifetime.
    * @param type Specifies whether to use the org cache or session cache.
    * @param key A string that uniquely identifies the value to be cached. For information about the format of the key name, see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_cache_Org.htm#apex_class_cache_Org
    * @param ttlSecs The amount of time, in seconds, to keep the cached value in the session cache. The cached values remain in the cache as long as the Salesforce session hasn’t expired. The maximum value is 28,800 seconds or eight hours. The minimum value is 300 seconds or five minutes.
    * @example
    * CacheManager.put(CacheType.SESSION, 'correlationId', GuidUtil.NewGuid(), 20000);
    */
    public static void put(CacheType type, String key, Object value, Integer ttlSecs) {
        if (type == CacheType.ORG) {
            Cache.Org.put(key, value, ttlSecs, Cache.Visibility.NAMESPACE, false);
            System.debug(LoggingLevel.DEBUG, 'put() in Org cache for key ' + key);
        }
        else if (type == CacheType.SESSION) {
            Cache.Session.put(key, value, ttlSecs, Cache.Visibility.NAMESPACE, false);
            System.debug(LoggingLevel.DEBUG, 'put() in Session cache for key ' + key);
        }
    }

    /*******************************************************************************************************
    * @description Deletes the cached value corresponding to the specified key from the cache.
    * @param type Specifies whether to use the org cache or session cache.
    * @param key A case-sensitive string value that uniquely identifies a cached value. For information about the format of the key name, see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_cache_Org.htm#apex_class_cache_Org
    * @example
    * @return true if the cache value was successfully removed. Otherwise, false.
    * CacheManager.remove(CacheType.SESSION, 'correlationId');
    */
    public static Boolean remove(CacheType type, String key) {
        Boolean removed = false;
        if (type == CacheType.ORG) {
            removed = Cache.Org.remove(key);
        }
        if (type == CacheType.SESSION) {
            removed = Cache.Session.remove(key);
        }
        if (removed) { 
            System.debug(LoggingLevel.DEBUG, 'Removed key ' + key);
            return true;
        } else {
            return false;
        }
    }

    /*******************************************************************************************************
    * @description Deletes the cached value corresponding to the specified key from the org cache. Use this method if your cached value is a class that implements the CacheBuilder interface.
    * @param type Specifies whether to use the org cache or session cache.
    * @param cacheBuilder The Apex class that implements the CacheBuilder interface.
    * @param key A case-sensitive string value that, combined with the class name corresponding to the cacheBuilder parameter, uniquely identifies a cached value. 
    * @return true if the cache value was successfully removed. Otherwise, false.
    * @example
    * CacheManager.remove(CacheType.SESSION, 'correlationId');
    */
    public static Boolean remove(CacheType type, System.Type cacheBuilder, String key) {
        Boolean removed = false;
        if (type == CacheType.ORG) {
            removed = Cache.Org.remove(cacheBuilder, key);
        }
        if (type == CacheType.SESSION) {
            removed = Cache.Session.remove(cacheBuilder, key);
        }
        if (removed) { 
            System.debug(LoggingLevel.DEBUG, 'Removed key ' + key);
            return true;
        } else {
            return false;
        }
    }
}