@IsTest(isParallel=true)
private class CustomMetadataConfigurationProviderTest {
    @IsTest
    private static void testGetAppenders() {
        LoggerFactoryConfigurationProvider conf = new CustomMetadataConfigurationProvider();
        System.assert(conf.getAppenders() != null, 'getAppenders() should return a non null List');
    }

    @IsTest
    private static void testGetDefaultLevel() {
        LoggerFactoryConfigurationProvider conf = new CustomMetadataConfigurationProvider();
        System.assert(conf.getDefaultLevel() != null, 'default level should not be null');
    }

    @IsTest
    private static void testGetLoggerLevels() {
        LoggerFactoryConfigurationProvider conf = new CustomMetadataConfigurationProvider();
        System.assert(conf.getLoggerLevels() != null, 'getLoggerLevels() should return a non null Map');
    }
}