/**

Test Case for the following Controller Extension:
ProblemReportingMechanismsReportCtlr

**/

@isTest 
public class ProblemReportingMechanismsReportCtlrTest{

  static testMethod void validateTest() {
  
  PageReference pref = Page.ProblemReportingMechanismsReport;
  Test.setCurrentPage(pref);
  
  ProblemReportingMechanismsReportCtlr pacrc = new ProblemReportingMechanismsReportCtlr();
  
  }

}