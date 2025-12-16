/**
 * @description Test class for the ACME_Security utility, focusing on FLS and CRUD checks.
 * @author ACME Corporation
 * @date 2025-12-15
 */
@IsTest
private class ACME_SecurityTest {

    @TestSetup
    static void setup() {
        ACME_Security.resetMocks();
    }

    @IsTest
    static void testFieldReadAccess_Positive() {
        ACME_Security.setMockFieldReadAccess(Contact.SObjectType, new Set<String>{'Id', 'Email', 'LastName'});

        Test.startTest();
        try {
            ACME_Security.verifyFieldReadAccess(Contact.SObjectType, new Set<String>{'email', 'lastname'});
            System.assert(true, 'Should not have thrown exception for allowed fields.');
        } catch (Exception e) {
            System.assert(false, 'Should not have thrown exception for allowed fields. Got: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testFieldReadAccess_Negative() {
        ACME_Security.setMockFieldReadAccess(Contact.SObjectType, new Set<String>{'Id', 'Email'});

        Test.startTest();
        try {
            ACME_Security.verifyFieldReadAccess(Contact.SObjectType, new Set<String>{'Email', 'Phone'});
            System.assert(false, 'Expected a SecurityException for field Phone.');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('FLS Read permission denied for field: Contact.Phone'), 'Incorrect exception message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testFieldNotFoundException() {
        ACME_Security.resetMocks(); // Test with real FLS checks, not mocks
        Test.startTest();
        try {
            ACME_Security.verifyFieldReadAccess(Contact.SObjectType, new Set<String>{'NonExistentField__c'});
            System.assert(false, 'Expected a SecurityException for a non-existent field.');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('not found on object'), 'Incorrect exception message for non-existent field: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testObjectCreateAccess_Positive() {
        ACME_Security.setMockObjectCreateAccess(Contact.SObjectType, true);

        Test.startTest();
        try {
            ACME_Security.verifyObjectCreateAccess(Contact.SObjectType);
            System.assert(true, 'Should not have thrown exception for create access.');
        } catch (Exception e) {
            System.assert(false, 'Should not have thrown exception for create access.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testObjectCreateAccess_Negative() {
        ACME_Security.setMockObjectCreateAccess(Contact.SObjectType, false);

        Test.startTest();
        try {
            ACME_Security.verifyObjectCreateAccess(Contact.SObjectType);
            System.assert(false, 'Expected a SecurityException for object create.');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('Object Create permission denied for: Contact'), 'Incorrect exception message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testResetMocks() {
        ACME_Security.setMockObjectCreateAccess(Contact.SObjectType, false);
        ACME_Security.resetMocks();

        Test.startTest();
        try {
            // After reset, the real check runs. As an admin, this should pass.
            ACME_Security.verifyObjectCreateAccess(Contact.SObjectType);
            System.assert(true, 'Reset should allow the real (permissive) check to pass.');
        } catch (ACME_Security.SecurityException e) {
            System.assert(false, 'Reset failed, the real check should have passed but threw an exception.');
        }
        Test.stopTest();
    }
}