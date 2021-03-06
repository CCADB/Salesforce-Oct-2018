/**

Test Case for the following Controller Extension:
RemovedCACertificateReportController

**/

@isTest 
public class RemovedCACertificateReportControlerTest{

    static testMethod void validateTest() {
        
        Account parentAccount = new Account();
        parentAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CA Owner').getRecordTypeID();
        parentAccount.name = 'ParentAccount';
        insert parentAccount;
        
        Account childAccount = new Account();
        childAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Root Certificate').getRecordTypeID();
        childAccount.name = 'ChildAccount';
        childAccount.Status__c = 'Included';
        childAccount.Certificate_Issuer_Organization__c = 'Test IO';
        childAccount.Certificate_Issuer_Organizational_Unit__c = 'Test IOU';
        childAccount.Approval_Bug__c = 'Test';
        childAccount.NSS_Release_When_First_Included__c = 'Test';
        childAccount.Firefox_Release_When_First_Included__c = 'Test';
        childAccount.Mozilla_Applied_Constraints__c = 'Test';
        childAccount.Certificate_Policy_CP__c = 'Test';
        childAccount.Certification_Practice_Statement_CPS__c = 'Test';
        childAccount.X_509_Certificate_PEM__c = 'Test';
        childAccount.Status__c = 'Removed';
        childAccount.Firefox_Release_When_Removed__c = 'Removed';
        childAccount.NSS_Release_When_Removed__c = 'Removed';
        insert childAccount;
    
        PageReference pref = Page.RemovedCACertificateReportCSVFormat;
        Test.setCurrentPage(pref);
        
        RemovedCACertificateReportController pacrc = new RemovedCACertificateReportController();
        pacrc.getCurrentDate();
    }

}