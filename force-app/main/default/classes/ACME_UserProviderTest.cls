/**
 * @description Test class for ACME_UserProvider
 * @author ACME Corporation
 * @date 2024
 */
@isTest
private class ACME_UserProviderTest {

    /**
     * @description Test retrieving sales users
     */
    @isTest
    static void testGetSalesUsers() {
        Test.startTest();
        List<User> salesUsers = ACME_UserProvider.getSalesUsers();
        Test.stopTest();

        System.assertNotEquals(null, salesUsers, 'Should return list of users');
    }

    /**
     * @description Test retrieving user with manager information
     */
    @isTest
    static void testGetUserWithManager() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        User result = ACME_UserProvider.getUserWithManager(currentUser.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return user');
        System.assertEquals(currentUser.Id, result.Id, 'User ID should match');
    }

    /**
     * @description Test null user ID handling
     */
    @isTest
    static void testGetUserWithNullId() {
        Test.startTest();
        try {
            ACME_UserProvider.getUserWithManager(null);
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(true, 'Exception thrown as expected');
        }
        Test.stopTest();
    }

    /**
     * @description Test getting users by role
     */
    @isTest
    static void testGetUsersByRole() {
        // Get current user's role
        User currentUser = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        List<User> users;
        if (currentUser.UserRole != null) {
            users = ACME_UserProvider.getUsersByRole(currentUser.UserRole.Name);
        } else {
            // If no role, just test with a generic role name
            users = ACME_UserProvider.getUsersByRole('CEO');
        }
        Test.stopTest();

        System.assertNotEquals(null, users, 'Should return list of users');
    }

    /**
     * @description Test active users filter in sales users query
     */
    @isTest
    static void testGetActiveSalesUsers() {
        Test.startTest();
        List<User> activeUsers = ACME_UserProvider.getSalesUsers();
        Test.stopTest();

        System.assertNotEquals(null, activeUsers, 'Should return list of active users');
        for (User u : activeUsers) {
            System.assertEquals(true, u.IsActive, 'All users should be active');
        }
    }
}