/**
 * @description Reusable security checks for FLS. Includes test hooks for mocking.
 * @author Copado AI
 * @date 2024
 */
public with sharing class ACME_Security {
    @TestVisible private static Boolean isTest = false;
    @TestVisible private static Boolean mockCanRead = true;
    @TestVisible private static Boolean mockCanCreate = true;
    @TestVisible private static Boolean mockCanUpdate = true;
    @TestVisible private static Boolean mockCanDelete = true;

    /**
     * @description Throws a SecurityException if the user does not have read access to the object.
     * @param sObjType The SObjectType to check.
     */
    public static void checkRead(SObjectType sObjType) {
        if (isTest && !mockCanRead) {
            throw new SecurityException('Read permission denied for object: ' + sObjType);
        }
        if (!isTest && !sObjType.getDescribe().isAccessible()) {
            throw new SecurityException('Read permission denied for object: ' + sObjType);
        }
    }

    /**
     * @description Throws a SecurityException if the user does not have create access to the object.
     * @param sObjType The SObjectType to check.
     */
    public static void checkCreate(SObjectType sObjType) {
        if (isTest && !mockCanCreate) {
            throw new SecurityException('Create permission denied for object: ' + sObjType);
        }
        if (!isTest && !sObjType.getDescribe().isCreateable()) {
            throw new SecurityException('Create permission denied for object: ' + sObjType);
        }
    }

    /**
     * @description Throws a SecurityException if the user does not have update access to the object.
     * @param sObjType The SObjectType to check.
     */
    public static void checkUpdate(SObjectType sObjType) {
        if (isTest && !mockCanUpdate) {
            throw new SecurityException('Update permission denied for object: ' + sObjType);
        }
        if (!isTest && !sObjType.getDescribe().isUpdateable()) {
            throw new SecurityException('Update permission denied for object: ' + sObjType);
        }
    }

    /**
     * @description Throws a SecurityException if the user does not have delete access to the object.
     * @param sObjType The SObjectType to check.
     */
    public static void checkDelete(SObjectType sObjType) {
        if (isTest && !mockCanDelete) {
            throw new SecurityException('Delete permission denied for object: ' + sObjType);
        }
        if (!isTest && !sObjType.getDescribe().isDeletable()) {
            throw new SecurityException('Delete permission denied for object: ' + sObjType);
        }
    }

    /**
     * @description Custom exception for security violations.
     */
    public class SecurityException extends Exception {}
}