/**

Test Case for the following Controller Extension:
AuditReminderICWithOutdatedAuditSt Batch Program

**/

@isTest 
public class AuditReminderICWithOutdatedAuditStTest {

    static testMethod void validateTest() {
        Account parentAccount = new Account();
        parentAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CA Owner').getRecordTypeID();
        parentAccount.name = 'ParentAccount';
        parentAccount.Status__c = 'Included';
        parentAccount.CA_Email_Alias_1__c = Userinfo.getUserEmail();
        parentAccount.CA_Email_Alias_2__c = 'test@gmail.com';
        insert parentAccount;
        
        Contact objC = new Contact();
        objC.LastName = 'Test LName';
        objC.Email = 'test1@gmail.com';
        objC.Type__c = 'POC';
        objC.AccountId = parentAccount.Id;
        insert objC;
        
        Account rootAccount = new Account();
        rootAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Root Certificate').getRecordTypeID();
        rootAccount.name = 'rootAccount';
        rootAccount.parentid = parentAccount.id;
        rootAccount.Status__c = 'Included';
        rootAccount.Certificate_Issuer_Organization__c = 'Test IO';
        rootAccount.Certificate_Issuer_Organizational_Unit__c = 'Test IOU';
        rootAccount.Approval_Bug__c = 'Test';
        rootAccount.NSS_Release_When_First_Included__c = 'Test';
        rootAccount.Firefox_Release_When_First_Included__c = 'Test';
        rootAccount.Mozilla_Applied_Constraints__c = 'Test';
        rootAccount.Certificate_Policy_CP__c = 'Test';
        rootAccount.Certification_Practice_Statement_CPS__c = 'Test';
        rootAccount.X_509_Certificate_PEM__c = 'Test';
        insert rootAccount;
        
        Account intercertAccount = new Account();
        intercertAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediate Certificate').getRecordTypeID();
        intercertAccount.name = 'intercertAccount';
        intercertAccount.parentid = rootAccount.id;
        intercertAccount.Root_Cert_ID__c = rootAccount.id;
        intercertAccount.Status__c = 'Included';
        intercertAccount.Valid_From_GMT__c = Date.Today()+1;
        intercertAccount.Valid_To_GMT__c = Date.Today()+1;  // not expired
        intercertAccount.Standard_Audit__c = 'https://stdaudit.com';
        intercertAccount.Standard_Audit_Type__c = 'WebTrust';
        intercertAccount.Standard_Audit_Statement_Date__c = Date.Today() - 365 -1; // older than one year - audits due
        intercertAccount.Standard_Audit_Period_Start_Date__c = Date.Today() - 365 -1;
        intercertAccount.Standard_Audit_Period_End_Date__c = Date.Today() - 365 -1;
        intercertAccount.Certificate_Issuer_Organization__c = 'Test IO';
        intercertAccount.Certificate_Issuer_Organizational_Unit__c = 'Test IOU';
        intercertAccount.Approval_Bug__c = 'Test';
        intercertAccount.NSS_Release_When_First_Included__c = 'Test';
        intercertAccount.Firefox_Release_When_First_Included__c = 'Test';
        intercertAccount.Mozilla_Applied_Constraints__c = 'Test';
        intercertAccount.Certificate_Policy_CP__c = 'Test';
        intercertAccount.Certification_Practice_Statement_CPS__c = 'Test';
        intercertAccount.X_509_Certificate_PEM__c = 'Test';
        insert intercertAccount;        
        
        AuditReminderICWithOutdatedAuditStBatch b1 = new AuditReminderICWithOutdatedAuditStBatch();
        ID batchprocessid = Database.executeBatch(b1,10);
        
        AuditReminderICWithOutdatedAuditStSchd.scheduleMe('Mozilla: Run Audit Reminder For Out Dated Inter Certs Batch on 1st Sunday of Every Month');      
    }

}