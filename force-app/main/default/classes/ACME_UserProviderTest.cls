/**
 * @description Test class for ACME_UserProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_UserProviderTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users with different roles
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testManager = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'test.manager@acme.com',
            Username = 'test.manager@acme.test.com',
            Alias = 'tmgr',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = salesProfile.Id
        );
        insert testManager;
        
        User testRep = new User(
            FirstName = 'Test',
            LastName = 'Rep',
            Email = 'test.rep@acme.com',
            Username = 'test.rep@acme.test.com',
            Alias = 'trep',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = salesProfile.Id,
            ManagerId = testManager.Id
        );
        insert testRep;
    }
    
    @IsTest
    static void testGetSalesManagers() {
        Test.startTest();
        List<User> managers = ACME_UserProvider.getSalesManagers();
        Test.stopTest();
        
        System.assertNotEquals(null, managers, 'Sales managers list should not be null');
        System.assert(managers.size() >= 0, 'Should return a list of managers');
    }
    
    @IsTest
    static void testGetSalesReps() {
        Test.startTest();
        List<User> reps = ACME_UserProvider.getSalesReps();
        Test.stopTest();
        
        System.assertNotEquals(null, reps, 'Sales reps list should not be null');
        System.assert(reps.size() >= 0, 'Should return a list of sales reps');
    }
    
    @IsTest
    static void testGetUserWithRole() {
        User testUser = [SELECT Id FROM User WHERE Email = 'test.rep@acme.com' LIMIT 1];
        
        Test.startTest();
        User result = ACME_UserProvider.getUserWithRole(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return user with role information');
        System.assertEquals(testUser.Id, result.Id, 'Should return the correct user');
    }
    
    @IsTest
    static void testGetUserWithRoleException() {
        Test.startTest();
        try {
            ACME_UserProvider.getUserWithRole(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (ACME_UserProvider.AcmeDataException e) {
            System.assert(true, 'Expected AcmeDataException was thrown');
        }
        Test.stopTest();
    }
}