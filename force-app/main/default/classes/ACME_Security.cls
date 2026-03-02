/**
 * @description Centralized, reusable security checks for CRUD and FLS.
 * @author ACME Corporation
 * @date 2025-12-15
 */
public with sharing class ACME_Security {

    @TestVisible private static Boolean isTestMode = false;
    @TestVisible private static Map<String, Set<String>> mockFieldReadAccess = new Map<String, Set<String>>();
    @TestVisible private static Set<String> mockObjectCreateAccess = new Set<String>();

    /**
     * @description Verifies the current user has FLS read access to a set of fields on an SObject.
     * @param sObjType The SObjectType to check.
     * @param fieldsToCheck A set of field API names to verify.
     */
    public static void verifyFieldReadAccess(SObjectType sObjType, Set<String> fieldsToCheck) {
        if (isTestMode) {
            Set<String> allowedFields = mockFieldReadAccess.get(String.valueOf(sObjType));
            if (allowedFields != null) {
                for (String field : fieldsToCheck) {
                    if (!allowedFields.contains(field.toLowerCase())) {
                        throw new SecurityException('FLS Read permission denied for field: ' + sObjType + '.' + field);
                    }
                }
                return; // Mock access granted
            }
        }

        Map<String, SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
        for (String fieldName : fieldsToCheck) {
            if (fieldMap.containsKey(fieldName.toLowerCase())) {
                if (!fieldMap.get(fieldName.toLowerCase()).getDescribe().isAccessible()) {
                    throw new SecurityException('FLS Read permission denied for field: ' + sObjType + '.' + fieldName);
                }
            } else {
                throw new SecurityException('Field ' + fieldName + ' not found on object ' + sObjType);
            }
        }
    }

    /**
     * @description Verifies the current user has object-level create permission.
     * @param sObjType The SObjectType to check.
     */
    public static void verifyObjectCreateAccess(SObjectType sObjType) {
        if (isTestMode) {
            if (!mockObjectCreateAccess.contains(String.valueOf(sObjType))) {
                throw new SecurityException('Object Create permission denied for: ' + sObjType);
            }
            return; // Mock access granted
        }

        if (!sObjType.getDescribe().isCreateable()) {
            throw new SecurityException('Object Create permission denied for: ' + sObjType);
        }
    }

    /**
     * @description Enables test mode and sets mock FLS read permissions.
     * @param sObjType The SObjectType to mock.
     * @param readableFields A set of fields the user can read.
     */
    @TestVisible
    private static void setMockFieldReadAccess(SObjectType sObjType, Set<String> readableFields) {
        isTestMode = true;
        Set<String> lowerCaseFields = new Set<String>();
        for(String field : readableFields) {
            lowerCaseFields.add(field.toLowerCase());
        }
        mockFieldReadAccess.put(String.valueOf(sObjType), lowerCaseFields);
    }

    /**
     * @description Enables test mode and sets mock object create permissions.
     * @param sObjType The SObjectType to mock.
     * @param canCreate Boolean indicating if create is allowed.
     */
    @TestVisible
    private static void setMockObjectCreateAccess(SObjectType sObjType, Boolean canCreate) {
        isTestMode = true;
        if (canCreate) {
            mockObjectCreateAccess.add(String.valueOf(sObjType));
        } else {
            mockObjectCreateAccess.remove(String.valueOf(sObjType));
        }
    }

    /**
     * @description Resets all mocks and disables test mode.
     */
    @TestVisible
    private static void resetMocks() {
        isTestMode = false;
        mockFieldReadAccess.clear();
        mockObjectCreateAccess.clear();
    }

    /**
     * @description Custom exception for security violations.
     */
    public class SecurityException extends Exception {}
}