/**
 * @description Provider class for User and sales team data access
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_UserProvider {
    
    /**
     * @description Gets sales managers for escalation notifications
     * @return List of sales managers
     */
    public static List<User> getSalesManagers() {
        try {
            return [
                SELECT Id, Name, Email, Phone, UserRole.Name
                FROM User 
                WHERE IsActive = true
                AND UserRole.Name != null
                AND (UserRole.Name LIKE '%Manager%' OR UserRole.Name LIKE '%Director%')
                ORDER BY Name
                LIMIT 20
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving sales managers: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve sales managers: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets active sales representatives
     * @return List of sales reps
     */
    public static List<User> getSalesReps() {
        try {
            return [
                SELECT Id, Name, Email, Phone, UserRole.Name, ManagerId, Manager.Name
                FROM User 
                WHERE IsActive = true
                AND UserRole.Name != null
                AND UserRole.Name NOT IN ('System Administrator')
                ORDER BY Name
                LIMIT 50
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving sales reps: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve sales reps: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets user by ID with role information
     * @param userId The user ID to retrieve
     * @return User record with role details
     */
    public static User getUserWithRole(Id userId) {
        try {
            return [
                SELECT Id, Name, Email, Phone, UserRole.Name, ManagerId, Manager.Name, Manager.Email
                FROM User 
                WHERE Id = :userId
                AND IsActive = true
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving user: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve user: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}