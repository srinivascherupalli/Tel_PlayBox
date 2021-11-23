/*
 * Developer Name: Kunal Dixit
 * Description: Generic Method to compare sObjects basis on the field with Integer type
 */
global class CustomSortDateTime implements Comparable {
    
    public SObject obj;
    public static String fieldName;
    public CustomSortDateTime(SObject obj){
        this.obj=obj;
        
    }
    
    global Integer compareTo(Object obj2){
        CustomSortDateTime compObject=(CustomSortDateTime)obj2;
        Integer output;
        
        if(DateTime.valueOf(obj.get(fieldName))>DateTime.valueOf(compObject.obj.get(fieldName)))
            output=1;
        else if(DateTime.valueOf(obj.get(fieldName))<DateTime.valueOf(compObject.obj.get(fieldName)))
            output=-1;
        else
            output=0;
        return output;
        
    }
    
}