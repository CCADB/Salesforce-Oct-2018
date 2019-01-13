/**

Test Case for the following Controller Extension:
AllCAAIdentifiersReportController

**/

@isTest 
public class AllCAAIdentifiersReportControllerTest {

    static testMethod void validateTest() {
        
        Account acc = new Account(Name='Test Account Name To Test AllCAAIdentifiersReportController',Problem_Reporting_Mechanism__c = 'test@test.com', Status__c = 'Included',Recognized_CAA_Domains__c = 'test.com');
        insert acc;
        
        PageReference pref = Page.AllCAAIdentifiersReport;
        Test.setCurrentPage(pref);
        AllCAAIdentifiersReportController pacrc = new AllCAAIdentifiersReportController();
        pacrc.getCurrentDate();
    }
}