/********************************************************************************************************************

  AllCAAIdentifiersReportController is a controller for AllCAAIdentifiersReport VF pages to list CA Owners. 
  Report name used is 'CAA Identifiers'. Report lists Recognized CAA Domains info for all ca owner, 
  root certs and intermediate cert records
  
 *********************************************************************************************************************/

public class AllCAAIdentifiersReportController{

    public List<Account> accSoLst     {get;set;}
    public List<Account> accountSoLst {get;set;}
 
    // constructor method for standard controller
    public AllCAAIdentifiersReportController() {   
                                                                  
        accSoLst =  [select Name, Parent.Name, Recognized_CAA_Domains__c from  Account
                    where (Status__c In ('Included','Change Requested','Provided by CA','Verified') or
                    Microsoft_Status__c In ('Included','Change Requested'))
                    and   RecordType.Name In ('CA Owner','Intermediate Certificate') and Name != '<Fill in Cert Name>'
                    order by Name]; 
        
        // filter records with non blank 'Recognized_CAA_Domains__c', which is long text field   
        accountSoLst = new List<Account>();          
        for(Account a : accSoLst)
        {
            if (a.Recognized_CAA_Domains__c != null && a.Recognized_CAA_Domains__c.length() > 0) {
                accountSoLst.add(a);
            }
        }                                                        
        
        // if we are generating a CSV file then we need to replace the double quotes in all text fields with null
        if((ApexPages.currentPage().getUrl().contains('CSV') && accountSoLst !=null && accountSoLst.size() > 0) || Test.IsRunningTest())
        {
            for(Account accountSo : accountSoLst)
            {
                if(accountSo.Name !=null && accountSo.Name.length() > 0) 
                    accountSo.Name = accountSo.Name.replace('"',''); 
                if(accountSo.Parent.Name !=null && accountSo.Parent.Name.length() > 0) 
                    accountSo.Parent.Name = accountSo.Parent.Name.replace('"','');          
                if(accountSo.Recognized_CAA_Domains__c !=null && accountSo.Recognized_CAA_Domains__c.length() > 0) 
                    accountSo.Recognized_CAA_Domains__c= accountSo.Recognized_CAA_Domains__c.replace('"','');                                                           
            }
        }     
    } 
         
    // Get current Datetime in long date format   
    public String getCurrentDate() {
    
        Datetime cDT = System.now();
        string CurrentDate = cDT.format('MMMM d, yyyy');
        
        return CurrentDate;
    
    }
    
}