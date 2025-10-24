/**
 * @description Provider class for User data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_UserProvider {
    
    /**
     * @description Gets user by ID with manager information
     * @param userId User ID to retrieve
     * @return User record with manager details
     */
    public static User getUserWithManager(Id userId) {
        try {
            // Query with CRUD/FLS check
            List<User> users = [
                SELECT Id, Name, Email, Phone, Title, Department,
                       Manager.Name, Manager.Email, Manager.Phone
                FROM User 
                WHERE Id = :userId
                LIMIT 1
            ];
            
            // Strip inaccessible fields
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                users
            );
            
            List<User> accessibleUsers = securityDecision.getRecords();
            
            if (accessibleUsers.isEmpty()) {
                throw new AcmeDataException('User not found or not accessible: ' + userId);
            }
            
            return accessibleUsers[0];
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving user: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve user: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets active sales users
     * @return List of active sales team members
     */
    public static List<User> getSalesUsers() {
        try {
            // Query with CRUD/FLS check
            List<User> users = [
                SELECT Id, Name, Email, Phone, Title, Department,
                       Manager.Name, Manager.Email
                FROM User 
                WHERE IsActive = true
                AND (Profile.Name LIKE '%Sales%' OR Department = 'Sales')
                ORDER BY Name
                LIMIT 200
            ];
            
            // Strip inaccessible fields
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                users
            );
            
            return securityDecision.getRecords();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving sales users: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve sales users: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets users by role
     * @param roleName Role name to filter by
     * @return List of users with specified role
     */
    public static List<User> getUsersByRole(String roleName) {
        try {
            // Query with CRUD/FLS check
            List<User> users = [
                SELECT Id, Name, Email, Phone, Title, Department,
                       UserRole.Name, Manager.Name, Manager.Email
                FROM User 
                WHERE UserRole.Name = :roleName
                AND IsActive = true
                ORDER BY Name
                LIMIT 200
            ];
            
            // Strip inaccessible fields
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                users
            );
            
            return securityDecision.getRecords();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving users by role: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve users by role: ' + e.getMessage());
        }
    }
    
    /**
     * @description Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}