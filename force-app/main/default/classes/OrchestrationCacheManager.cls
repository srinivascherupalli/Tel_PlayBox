public class OrchestrationCacheManager {

    public static Object get(String key) {
        Object value = Cache.Org.get(key);
        return value;     
    }

    public static void put(String key, Object value) {
        System.debug(' OrchestrationCacheManager put ==> '  );
        Cache.Org.put(key, value);
        System.debug(' Cache.Org.get(key) ==> ' + key +':::'+  Cache.Org.get(key) );
    }

    public static Boolean remove(String key) {
        Boolean removed = Cache.Org.remove(key);
        return removed;
    }

    public static Boolean isStoredInCache(String key){
        Boolean contains = Cache.Org.contains(key);
        return contains;
    }
}