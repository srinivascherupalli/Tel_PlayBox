public class CollectionUtil {
    
    public static List<String> removeNull(List<String> values) {
        List<String> withoutNull = new List<String>();
        for(String val :  values) {
            if(val != null) {
                withoutNull.add(val);
            }
        }
        return withoutNull;
    }
    
    public static Set<id> removeNull(Set<id> values) {
        Set<id> withoutNull = new Set<id>();
        for(id val :  values) {
            if(val != null) {
                withoutNull.add(val);
            }
        }
        return withoutNull;
    }
    
    public static Set<String> removeNull(Set<String> values) {
        Set<String> withoutNull = new Set<String>();
        for(String val :  values) {
            if(val != null) {
                withoutNull.add(val);
            }
        }
        return withoutNull;
    }

}