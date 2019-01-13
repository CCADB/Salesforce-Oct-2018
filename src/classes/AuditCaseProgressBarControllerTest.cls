/*
    Description: Test class for AuditCaseProgressBarController
*/
@isTest
public with sharing class AuditCaseProgressBarControllerTest {
    static testmethod void testAuditCaseProgressBar(){ 
        
        Account caOwnerAcc = new Account();
        caOwnerAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CA Owner').getRecordTypeID();
        caOwnerAcc.name = 'ParentAccount';
        caOwnerAcc.type = 'Owner';
        insert caOwnerAcc;
        
         // create auditor
        Auditor__c auditor = new Auditor__c();
        auditor.Name = 'WebTrust';
        auditor.Auditor_Status__c = 'Confidence - High';
        auditor.Auditor_Website__c = 'http://www.google.com';
        insert auditor;
        
        // create auditor location
        Auditor_Location__c auditorlocation = new Auditor_Location__c();
        auditorlocation.Name = 'US';
        auditorlocation.Auditor__c = auditor.Id;
        auditorlocation.Auditor_Location_Status__c = 'Confidence - High';
        insert auditorlocation;
        
        Case caseSO = CaseTriggerHelperTest.getCase(caOwnerAcc.Id);
        caseSO.Standard_Audit_Authenticity_Confirmed__c = True;
        caseSO.BR_Audit_Authenticity_Confirmed__c = True;
        caseSO.EV_Code_Signing_Audit_Auth_Confirmed__c = True;
        caseSO.EV_SSL_Audit_Authenticity_Confirmed__c = True;
        caseSO.Auditor_New__c = auditor.Id;
        caseSO.Auditor_Location_New__c = auditorlocation.Id; 
        insert caseSO;
        
        Apexpages.currentpage().getParameters().put('id', caseSO.Id);
        AuditCaseProgressBarController objACPBar = new AuditCaseProgressBarController(new Apexpages.standardcontroller(caseSO));
        
        auditorlocation.Auditor_Qualifications__c = 'Test Qualifications';
        update auditorlocation;
        
        // create the child account - record type = Root
        Account childAccount = SyncParentAccountFromCaseControllerTest.getChildAccount(caOwnerAcc.id);
        childAccount.Name = 'child root account 1';
        childAccount.Standard_Audit_Period_End_Date__c = system.today().addDays(-6);
        insert childAccount;
        
        // create the root case and associate it with the case
        Root_Case__c rootCaseA1 = CaseTriggerHelperTest.getRootCase(caseSO.id,caOwnerAcc.Id);
        rootCaseA1.request_status__c   = 'Initial Request Received';       
        rootCaseA1.Apply_Standard_Audit__c = true;
        rootCaseA1.EV_Audit_Type__c = 'WebTrust';
        rootCaseA1.Apply_BR_Audit__c = true;
        rootCaseA1.Apply_EV_Audit__c = true;         
        rootCaseA1.Case_No__c = caseSO.Id;
        rootCaseA1.CA_Owner_Name_Existing__c = caOwnerAcc.Id;
        rootCaseA1.Root_Certificate_Name_Existing__c = childAccount.Id;
        rootCaseA1.RecordTypeId = Schema.SObjectType.Root_Case__c.getRecordTypeInfosByName().get('CA Owner/Root Inclusion Request').getRecordTypeID();
        insert rootCaseA1;
        
        Apexpages.currentpage().getParameters().put('id', caseSO.Id);
        objACPBar = new AuditCaseProgressBarController(new Apexpages.standardcontroller(caseSO));
        
        caseSO.Standard_Audit_Auto_Review_Results__c = 'ALV Result';
        update caseSO;
        
        Apexpages.currentpage().getParameters().put('id', caseSO.Id);
        objACPBar = new AuditCaseProgressBarController(new Apexpages.standardcontroller(caseSO));
        objACPBar.CheckCaseProgress();
    }
}