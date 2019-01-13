/*
    Description: Test class for CommonMethods
*/
@isTest
public with sharing class CommonMethodsTest {

    static testmethod void TestValidatePEMInfo() {
        //cover for blank PEM Info
        CommonMethods.validatePEMInfo('');
        
        //when PEM info is greater than 10000 chars
        string strPEM10000Info = '';
        for(Integer I = 0; I < 11000; I++) {
            strPEM10000Info += 'A'+I;
        }
        CommonMethods.validatePEMInfo(strPEM10000Info);
        
        //when pem info doesn't value begin certificates
        CommonMethods.validatePEMInfo('Test');
        
        //when pem info have more than 1 BEGIN CERTIFICATE
        CommonMethods.validatePEMInfo('BEGIN CERTIFICATE BEGIN CERTIFICATE END CERTIFICATE');
        
        //when pem info have more than 1 -----BEGIN CERTIFICATE-----
        CommonMethods.validatePEMInfo('-----BEGIN CERTIFICATE----- -----END CERTIFICATE-----');
        
        //when pem info have more than 1 -----BEGIN CERTIFICATE-----
        CommonMethods.validatePEMInfo('----BEGIN CERTIFICATE-----  ---123--END CERTIFICATE-----');
    }

}