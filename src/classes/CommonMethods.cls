/*
    Description: Class is created for Common Methods
*/
public with sharing class CommonMethods {
    
    public static boolean validatePEMInfo(string strPEMInfo) {
        boolean isPEMInfoCorrect = true;
        // throw an error if the pem info is not provided by the user
        if(strPEMInfo == null || strPEMInfo.length() == 0) {
            ApexPages.Message apexMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide PEM info else click the Cancel button.');
            ApexPages.addMessage(apexMessage);
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        } 
        
        // throw an error if the pem info is exceeding the field length 
        if(strPEMInfo != null && strPEMInfo.length() >= 10000){
            ApexPages.Message apexMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Error: PEM data exceeds field length limit of 10,000 characters, so cannot be used. Please enter the certificate\'s information manually using the Edit button.');
            ApexPages.addMessage(apexMessage);
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        } 
        
        // throw an error if the pem info is missing "BEGIN CERTIFICATE" or "END CERTIFICATE" tags
        if(strPEMInfo.countmatches('BEGIN CERTIFICATE') == 0 || strPEMInfo.countmatches('END CERTIFICATE') == 0) {
            ApexPages.Message apexMessage = new ApexPages.Message(ApexPages.Severity.Error, 'PEM info does not have proper BEGIN CERTIFICATE/END CERTIFICATE format. Please re-enter PEM info.');
            ApexPages.addMessage(apexMessage);
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        } 
        
        // throw an error if the pem info has more than one instance of "BEGIN CERTIFICATE" or "END CERTIFICATE"
        if(strPEMInfo.countmatches('BEGIN CERTIFICATE') > 1 || strPEMInfo.countmatches('END CERTIFICATE') > 1){
            ApexPages.Message apexMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Multiple occurrence of "BEGIN CERTIFICATE" or "END CERTIFICATE" found in PEM info. Please re-enter PEM info.');
            ApexPages.addMessage(apexMessage);
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        } 
        
        // throw an error if the pem info does not have proper format for BEGIN/END tags 
        if(strPEMInfo.countmatches('-----BEGIN CERTIFICATE-----') != 1 || strPEMInfo.countmatches('-----END CERTIFICATE-----') != 1) {
            ApexPages.Message apexMessage = new ApexPages.Message(ApexPages.Severity.Error, 'PEM info does not have proper format for BEGIN/END tags. Please re-enter PEM info.');
            ApexPages.addMessage(apexMessage);
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        }
        
        // throw an error if the pem info has extra characters before '-----BEGIN CERTIFICATE-----' or after '-----END CERTIFICATE-----'
        if(!strPEMInfo.startsWith('-----BEGIN CERTIFICATE-----') || !strPEMInfo.endsWith('-----END CERTIFICATE-----')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'PEM info has extra characters before "-----BEGIN CERTIFICATE-----" or after "-----END CERTIFICATE-----". Please re-enter PEM info.'));
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        } 
        
        // throw an error if the pem info has blank lines
        if(strPEMInfo.countmatches('\r\n\r\n') > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'PEM info has extra blank lines. Please re-enter PEM info.'));
            isPEMInfoCorrect = false;
            return isPEMInfoCorrect;
        } 
        return isPEMInfoCorrect;    
    }
    
}