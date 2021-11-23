@isTest
private class ServiceExtentionComparableWrapperTest {
    static testmethod void test1() {        
        List<ServiceExtentionComparableWrapper > serEXtList = new List<ServiceExtentionComparableWrapper > ();
        serEXtList.add(new ServiceExtentionComparableWrapper('0893457399','0893457345'));
        serEXtList.add(new ServiceExtentionComparableWrapper('0893457332','0893457300'));
        serEXtList.add(new ServiceExtentionComparableWrapper('0893457343','0893457334'));
        
        // Sort using the custom compareTo() method
        serEXtList.sort();
        
        // Write list contents to the debug log
        System.debug(serEXtList);
        
        // Verify list sort order.
        System.assertEquals('0893457300', serEXtList[0].Services_From );
        System.assertEquals('0893457334', serEXtList[1].Services_From ); 
    }
}