/**
 * @description Test class for the ACME_Security utility.
 * @author Copado AI
 * @date 2024
 */
@IsTest
private class ACME_SecurityTest {

    @IsTest
    static void testCheckRead_Exception() {
        ACME_Security.isTest = true;
        ACME_Security.mockCanRead = false;
        try {
            ACME_Security.checkRead(Contact.SObjectType);
            System.assert(false, 'Expected SecurityException for read');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('Read permission denied'));
        }
        ACME_Security.isTest = false;
    }

    @IsTest
    static void testCheckCreate_Exception() {
        ACME_Security.isTest = true;
        ACME_Security.mockCanCreate = false;
        try {
            ACME_Security.checkCreate(Contact.SObjectType);
            System.assert(false, 'Expected SecurityException for create');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('Create permission denied'));
        }
        ACME_Security.isTest = false;
    }

    @IsTest
    static void testCheckUpdate_Exception() {
        ACME_Security.isTest = true;
        ACME_Security.mockCanUpdate = false;
        try {
            ACME_Security.checkUpdate(Contact.SObjectType);
            System.assert(false, 'Expected SecurityException for update');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('Update permission denied'));
        }
        ACME_Security.isTest = false;
    }

    @IsTest
    static void testCheckDelete_Exception() {
        ACME_Security.isTest = true;
        ACME_Security.mockCanDelete = false;
        try {
            ACME_Security.checkDelete(Contact.SObjectType);
            System.assert(false, 'Expected SecurityException for delete');
        } catch (ACME_Security.SecurityException e) {
            System.assert(e.getMessage().contains('Delete permission denied'));
        }
        ACME_Security.isTest = false;
    }

    @IsTest
    static void testPositiveAccess() {
        // This test runs without mocking and relies on the default (permissive)
        // access of the user running the test. It ensures the checks do not
        // throw exceptions when access is granted.
        ACME_Security.isTest = false; // Ensure we are not in test mode
        try {
            ACME_Security.checkRead(Contact.SObjectType);
            ACME_Security.checkCreate(Contact.SObjectType);
            ACME_Security.checkUpdate(Contact.SObjectType);
            ACME_Security.checkDelete(Contact.SObjectType);
            // If we reach here, no exception was thrown, which is the correct behavior.
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'No security exception should be thrown when access is granted. Exception: ' + e.getMessage());
        }
    }
}