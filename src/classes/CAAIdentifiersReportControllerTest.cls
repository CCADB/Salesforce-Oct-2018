/**

Test Case for the following Controller Extension:
CAAIdentifiersReportController

**/

@isTest 
public class CAAIdentifiersReportControllerTest{

  static testMethod void validateTest() {
  
  PageReference pref = Page.CAAIdentifiersReport;
  Test.setCurrentPage(pref);
  
  CAAIdentifiersReportController pacrc = new CAAIdentifiersReportController();
  
  }

}