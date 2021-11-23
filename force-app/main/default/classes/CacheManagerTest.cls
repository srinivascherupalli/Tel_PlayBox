@isTest
private class CacheManagerTest {
    Static User contactCenterUser;
    Static User sysAdminUser;
    private static final String CC_PROFILE = 'System Administrator',CC_EMAIL = 'testUserAddP@testEmail.com';
    
    /** Session Cache tests */
    @TestSetup
    static void initData(){
        contactCenterUser = TestDataFactory.createTestUser(CC_PROFILE);
        contactCenterUser.Email =CC_Email;
        contactCenterUser.Username = CC_EMAIL;
        Database.update(contactCenterUser);
    }
    
    @isTest
    static void testSessionGetMiss() {
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            System.assertEquals(null, CacheManager.get(CacheType.SESSION, 'nonexistent'));
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSessionGetHit() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Cache.Session.put(key, 'test');
            Test.startTest();
            System.assertEquals(null , CacheManager.get(CacheType.SESSION, key),'Check session key from cache');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSessionGetCacheBuilder() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            System.assertEquals(null, CacheManager.get(CacheType.SESSION, key),'Null session key check from cache');
            System.assertEquals('cache entry for newkey', CacheManager.get(CacheType.SESSION, TestCacheBuilder.class, key),'cache entry for new key in session cache');
            Test.stopTest();
        }
        
        // Salesforce seems to internally store CacheBuilder keys using key such as 'TestCacheBuilder_B_newkey'
        // Therefore entries added using CacheBuilder cannot be retrieved through the Cache methods.  Attempting to do so gives
        // error such as:
        // cache.Org.OrgCacheException: Failed Cache.Session.put() for key 'TestCacheBuilder_B_newkey': Invalid key: key must be alphanumeric.
    }
    
    @isTest
    static void testSessionPut() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            CacheManager.put(CacheType.SESSION, key, 'test');
            Test.stopTest();
        }
        System.assertEquals(null, Cache.Org.get(key),'Get key from org cache');
    }
    
    @isTest
    static void testSessionRemove() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Cache.Session.put(key, 'test');
            Test.startTest();
            System.assertEquals(null, Cache.Session.get(key),'get key from session cache after removal of key');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSessionRemoveCacheBuilder() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            CacheManager.get(CacheType.SESSION, TestCacheBuilder.class, key);
            Test.stopTest();
        }
        System.assertEquals(false, CacheManager.remove(CacheType.SESSION, TestCacheBuilder.class, key),'remove class variable from session cache');
        System.assertEquals(0, Cache.Session.getKeys().size(),'Class variable check in session cache after removal');
    }
    
    /** Org Cache tests */
    static void testOrgGetMiss() {
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            System.assertEquals(null, CacheManager.get(CacheType.ORG, 'nonexistent'));
            Test.stopTest();
        }
    }
    
    @isTest
    static void testOrgGetHit() {
        final String key = 'newkey';
        Cache.Org.put(key, 'test');
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            System.assertEquals('test', CacheManager.get(CacheType.ORG, key),'Org cache check');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testOrgGetCacheBuilder() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            System.assertEquals(null, CacheManager.get(CacheType.ORG, key));
            System.assertEquals('cache entry for newkey', CacheManager.get(CacheType.ORG, TestCacheBuilder.class, key),'cache entry for newkey in org cache');
            Test.stopTest();
        }
        
        // Salesforce seems to internally store CacheBuilder keys using key such as 'TestCacheBuilder_B_newkey'
        // Therefore entries added using CacheBuilder cannot be retrieved through the Cache methods.  Attempting to do so gives
        // error such as:
        // cache.Org.OrgCacheException: Failed Cache.Session.put() for key 'TestCacheBuilder_B_newkey': Invalid key: key must be alphanumeric.
        System.debug(Cache.Org.getKeys());
    }
    
    @isTest
    static void testOrgPut() {
        final String key = 'newkey';
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            CacheManager.put(CacheType.ORG, key, 'test');
            Test.stopTest();
        }
        
        System.assertEquals('test', Cache.Org.get(key),'Org cache check');
        System.assertEquals(null, Cache.Session.get(key),'check for key in session cache');
    }
    
    @isTest
    static void testOrgRemove() {
        final String key = 'newkey';
        
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Cache.Org.put(key, 'test');
            Test.startTest();
            System.assertEquals('test', Cache.Org.get(key),'Org cache check');
            System.assertEquals(true, CacheManager.remove(CacheType.ORG, key),'Remove key from org cache');
            System.assertEquals(null, Cache.Org.get(key),'Org cache check after removal');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testOrgRemoveCacheBuilder() {
        final String key = 'newkey';
        
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            CacheManager.get(CacheType.ORG, TestCacheBuilder.class, key);
            Test.stopTest();
        }
        Integer count =  Cache.Org.getKeys().size();
        System.assertEquals(count, Cache.Org.getKeys().size(),'check org cache size');
        System.assertEquals(true, CacheManager.remove(CacheType.ORG, TestCacheBuilder.class, key),'remove class variable from org cache');
        count =  Cache.Org.getKeys().size();
        System.assertEquals(count, Cache.Org.getKeys().size(),'check org cache size after removal');
    }
    
    /** Invalid Cache type tests */
    static void testInvalidGet() {
        
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            System.assertEquals(null, CacheManager.get(null, 'nonexistent'));
            Test.stopTest();
        }
    }
    
    @isTest
    static void testInvalidPut() {
        final String key = 'newkey';
        
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            CacheManager.put(null, key, 'test');
            Test.stopTest();
        }
        
        System.assertEquals(null, Cache.Org.get(key),'Org cache check');
        System.assertEquals(null, Cache.Session.get(key),'Session cache check');
    }
    
    @isTest
    static void testInvalidRemove() {
        final String key = 'newkey';
        
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Cache.Org.put(key, 'org');
            Cache.Session.put(key, 'session');
            Test.startTest();
            System.assertEquals('org', Cache.Org.get(key),'Org cache check');
            System.assertEquals(false, CacheManager.remove(null, key),'remove invalid key from cache');
            System.assertEquals('org', Cache.Org.get(key),'get newkey value from Orgcache');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testInvalidRemoveCacheBuilder() {
        final String key = 'newkey';
        
        contactCenterUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: CC_PROFILE LIMIT 1];
        System.runAs(contactCenterUser){
            Test.startTest();
            CacheManager.get(CacheType.SESSION, TestCacheBuilder.class, key);
            CacheManager.get(CacheType.ORG, TestCacheBuilder.class, key);
            Test.stopTest();
        }
        Integer count =  Cache.Org.getKeys().size();
        System.assertEquals(count, Cache.Org.getKeys().size(),'check orgcache keys size');
        System.assertEquals(false, CacheManager.remove(null, TestCacheBuilder.class, key),'remove invalid key from org cache');
        count =  Cache.Org.getKeys().size();
        System.assertEquals(count, Cache.Org.getKeys().size(),'check orgcache keys size');
    }
    
    private class TestCacheBuilder implements Cache.CacheBuilder {
        public Object doLoad(String key) {
            String value = 'cache entry for ' + key;
            return value;
        }
    }
}