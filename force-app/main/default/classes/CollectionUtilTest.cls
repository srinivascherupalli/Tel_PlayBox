@IsTest
public class CollectionUtilTest {
    
    @IsTest
    static void removeNull_WillReturnListWithoutNull_WhenPassList() {
        List<String> values = new List<String>{'Test', null, 'anotherTest'};
        System.assertEquals(3, values.size());
        System.assertEquals(2, CollectionUtil.removeNull(values).size());
    }
    
    @IsTest
    static void removeNull_WillReturnListWithoutNull_WhenPassStringSet() {
        Set<String> values = new Set<String>{'Test', null, 'anotherTest'};
        System.assertEquals(3, values.size());
        System.assertEquals(2, CollectionUtil.removeNull(values).size());
    }
    
    @IsTest
    static void removeNull_WillReturnListWithoutNull_WhenPassIdSet() {
        Set<Id> values = new Set<Id>{'01I28000000R1zo', null, '01I28000000R1zk'};
        System.assertEquals(3, values.size());
        System.assertEquals(2, CollectionUtil.removeNull(values).size());
    }

}