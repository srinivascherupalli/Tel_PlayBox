/*************************************************************************************************************************
 @Class Name: APTPS_Paginate
 @Author: Shishir Bose
 @Created Date: 05/24/2016
 @Descripton: This class is created for implementing paging fucntionality
*************************************************************************************************************************/

public class APTPS_Paginate {
    public Integer index {get;set;} 
    public Integer pageNum {get;set;} 
    public Integer totalPage {get;set;} 
    public Integer totalResults {get;set;} 
    public List<Pager> pageList {get;set;} 
    public Boolean showPrevious {get;set;} 
    public Boolean showNext {get;set;} 
    public Boolean isAll {get;set;} 

    /*************************************************************************************************************************
     @Name: APTPS_Paginate (Constructor)
     @Author: Shishir Bose
     @Created Date: 05/24/2016
     @Descripton: Setting the total count of records, page size, total number of pages
    *************************************************************************************************************************/
    public APTPS_Paginate(Integer listSize, Integer pageSize)
    { 
        this.totalResults = listSize; 
        pageSize = (pageSize > 0)?pageSize:10; 
        this.totalPage = (Integer)Math.ceil((Double)listSize / (Double)pageSize); 
        this.pageNum = 1; 
        this.index = 0; 
        this.isAll = (listSize == pageSize)?true:false; 
        updateNumbers(); 
    } 
    
     /*************************************************************************************************************************
     @Name: updateNumbers
     @Author: Shishir Bose
     @Created Date: 05/24/2016
     @Descripton: Setting the page number active or inactive based on selected page
    *************************************************************************************************************************/
    public void updateNumbers()
    { 
        this.pageList = new List<Pager>(); 
        
        //Set the active page
        for(Integer i = 1; i < (this.totalPage + 1); i++)
        { 
            Boolean b = (i == pageNum)?true:false; 
            this.pageList.add(new Pager(i, b)); 
        } 
        
        //If on first page. Hide the Prev button
        this.showPrevious = (this.pageNum == 1)?false:true; 
        
        //If last page. Hide the Next button
        this.showNext = (this.pageNum == this.totalPage)?false:true; 
        
        //If only one page is there hide the Next button
        if(this.totalPage == 0)
        {
            this.showNext = false;
        }
        this.index = this.pageNum - 1; 
    } 
    
    /*************************************************************************************************************************
     @Name: decrement
     @Author: Shishir Bose
     @Created Date: 05/24/2016
     @Descripton: Decrement page number
    *************************************************************************************************************************/
    
    public void decrement()
    { 
        this.pageNum = this.pageNum - 1; 
        updateNumbers(); 
    } 
    
    /*************************************************************************************************************************
     @Name: increment
     @Author: Shishir Bose
     @Created Date: 05/24/2016
     @Descripton: Increment page number
    *************************************************************************************************************************/
    
    public void increment()
    { 
        this.pageNum++; 
        updateNumbers(); 
    } 
    
    /*************************************************************************************************************************
     @Class Name: Pager
     @Author: Shishir Bose
     @Created Date: 05/24/2016
     @Descripton: This class is used to display style for selected and unselected page numbers
    *************************************************************************************************************************/
    public class Pager
    { 
        public Integer pageNum {get;set;} 
        public Boolean isActive {get;set;} 
        
        public Pager(Integer num, Boolean active)
        { 
            this.pageNum = num; 
            this.isActive = active; 
        } 
    } 

}