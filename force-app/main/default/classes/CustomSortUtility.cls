/*
 * Developer: Kunal Dixit
 * Description: Generic custom Sort utility to Sort list of Sobjects according to a specific field of SObject
 * EDGE-81250
 */ 

public class CustomSortUtility {
    
    public static List<SObject> customSort(List<SObject> inputList,String fieldName,String dataType){
        List<SObject> outputList=new List<SObject>();
        switch on dataType{
            when 'Integer'{
                List<CustomSortInteger> listToSort=new List<CustomSortInteger>();
                for(SObject o:inputList){
                    listToSort.add(new CustomSortInteger(o));
                }
                CustomSortInteger.fieldName=fieldName;
                listToSort.sort();
                for(CustomSortInteger myObject:listToSort){
                    outputList.add(myObject.obj);
                }
            }
            
            when 'DateTime'{
                List<CustomSortDateTime> listToSort=new List<CustomSortDateTime>();
                for(SObject o:inputList){
                    listToSort.add(new CustomSortDateTime(o));
                }
                CustomSortDateTime.fieldName=fieldName;
                listToSort.sort();
                for(CustomSortDateTime myObject:listToSort){
                    outputList.add(myObject.obj);
                }
            }
        }
        return outputList;
    }
    
    
    

}