/*
    Description: Batch program to parse PEM info using PEMParserController
    
    If PEM info (x509 field) is not null then add to the batch processing
*/

global class RootCasePEMParserBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    global final String Query;
    
    global RootCasePEMParserBatch(String q){
        Query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Root_Case__c> lstRootCases){
        
        List<Root_Case__c> lstRootCasesToUpdate = new List<Root_Case__c>();
        
        for(Root_Case__c rootCase : lstRootCases){
            
            if(rootCase.X_509_Certificate_PEM__c != null) {
                
                Root_Case__c rootCaseToUpdate = new Root_Case__c();
                Account tempAccount = PEMParserController.parsePEM(rootCase.X_509_Certificate_PEM__c);
                rootCaseToUpdate.Extraction_Results__c = tempAccount.Extraction_Results__c;
                rootCaseToUpdate.Certificate_Issuer_Common_Name__c = tempAccount.Certificate_Issuer_Common_Name__c;
                rootCaseToUpdate.O_From_Issuer_Field__c = tempAccount.Certificate_Issuer_Organization__c;
                rootCaseToUpdate.OU_From_Issuer_Field__c = tempAccount.Certificate_Issuer_Organizational_Unit__c;
                rootCaseToUpdate.Valid_From__c = tempAccount.Valid_From_GMT__c;
                rootCaseToUpdate.Valid_To__c = tempAccount.Valid_To_GMT__c;
                rootCaseToUpdate.Certificate_Serial_Number__c = tempAccount.Certificate_Serial_Number__c;
                rootCaseToUpdate.Subject__c = tempAccount.Subject__c;
                rootCaseToUpdate.Signature_Hash_Algorithm__c = tempAccount.Signature_Hash_Algorithm__c;
                rootCaseToUpdate.Public_Key_Algorithm__c = tempAccount.Public_Key_Algorithm__c;
                rootCaseToUpdate.SHA_1_Fingerprint__c = tempAccount.SHA_1_Fingerprint__c;
                rootCaseToUpdate.SHA_256_Fingerprint__c = tempAccount.SHA_256_Fingerprint__c;
                //rootCaseToUpdate.Certificate_Fingerprint__c = tempAccount.Certificate_ID__c;
                rootCaseToUpdate.Certificate_Version__c = tempAccount.Certificate_Version__c;
                rootCaseToUpdate.Technically_Constrained__c = tempAccount.Technically_Constrained__c;
                rootCaseToUpdate.SPKI_SHA256__c = tempAccount.SPKI_SHA256__c;
                rootCaseToUpdate.Subject_SPKI_SHA256__c = tempAccount.Subject_SPKI_SHA256__c;
                 
                rootCaseToUpdate.Id = rootCase.Id;
                lstRootCasesToUpdate.add(rootCaseToUpdate);
            }
        }
        if(lstRootCasesToUpdate.size() > 0){
            update lstRootCasesToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}