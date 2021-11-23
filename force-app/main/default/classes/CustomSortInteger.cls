global class CustomSortInteger implements Comparable {
    
    public SObject obj;
    public static String fieldName;
    public CustomSortInteger(SObject obj){
        this.obj=obj;
        
    }
    
    global Integer compareTo(Object obj2){
        CustomSortInteger compObject=(CustomSortInteger)obj2;
        Integer output;
        
        if(Integer.valueOf(obj.get(fieldName))>Integer.valueOf(compObject.obj.get(fieldName)))
            output=1;
        else if(Integer.valueOf(obj.get(fieldName))<Integer.valueOf(compObject.obj.get(fieldName)))
            output=-1;
        else
            output=0;
        return output;
        
    }
    
}