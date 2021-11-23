Public class ServiceExtentionComparableWrapper implements Comparable {
    public String Services_To  {get;set;}
    public String Services_From  {get;set;}
  
    Public ServiceExtentionComparableWrapper (String Services_To ,String Services_From ){
        This.Services_To = Services_To ;
        This.Services_From  = Services_From  ;
   }
   Public Integer compareTo (Object compareTo) {
        ServiceExtentionComparableWrapper ServExt= (ServiceExtentionComparableWrapper )compareTo;
        Integer returnValue = 0;
        If (Services_From  > ServExt.Services_From) {
            returnValue = 1;
        } else if (Services_From < ServExt.Services_From) {
            returnValue = -1;
        }
            Return returnValue; 
    }
}