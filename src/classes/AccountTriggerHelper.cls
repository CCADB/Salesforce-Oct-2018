// ========================================================================================================
// AccountTriggerHelper: Trigger for the Account object which handles all the events and based 
// on the event delegates the task to the corresponding trigger handler method in the AccountTriggerHelper class.
// ========================================================================================================
// SetAccountStatusField : Update related Account Status whenever a new Account is created. 
// ========================================================================================================
// updateCAOwnerFields: This method set the ultimate parent to CA Owner and CA Owner Ids fields for all 
// account hiearachy levels. If the user makes account name change or parent id it is reflected in the hiearrchy. 
// 03/30/2018        Added New function checkAuditInfoWhenSameLink to check when Audit URLs are same.
// 04/19/2018        Added try-catch exception while updating accounts to show validation exception.
// ========================================================================================================

public class AccountTriggerHelper {
    
 // define a static boolean variable to avoid recursive trigger update
 public static boolean isAccountTriggerRunning = false;
 
  // this method is invoked whenever a new account is created
  // the requirement is to set the status on account as 'Not Yet Included'
  public static void SetAccountStatusFieldonInsert(List<Account> accountSoLst) {
   
   // loop over all the account which were inserted
   for(Account accountSo : accountSoLst)
    {   
        if(accountSo.status__c==null || accountSo.status__c.length()==0)
        {
         accountSo.status__c = 'Not Yet Included';
        }
    }
  }
   
  public static void validateParentAccountForIntermediateCA(List<Account> accountSoLst) {
  
   // get the record type ID of the intermediate CA records
   Id intermediateCARecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediate Certificate').getRecordTypeId();

   // get the record type ID of the root certificate records 
   Id rootCARecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Root Certificate').getRecordTypeId();

   // get the record type ID of the root certificate records 
   Id ownerCARecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('CA Owner').getRecordTypeId();

   // get the ID of the current user
   Id currentUserId =    UserInfo.getUserId();
   
   //all CA Owners
   set<Id> setParentIds = new set<Id>();
   for(Account accountSo: accountSoLst){
       setParentIds.add(accountSo.ParentId);
   }
   map<Id,string> mapCAOwners = new map<Id,string>();
   for(Account accountSo: [select Id,RecordTypeId,Name from Account Where Id in: setParentIds and RecordTypeId =: ownerCARecTypeId]){
       mapCAOwners.put(accountSo.Id,accountSo.Name);
   }
   //System.debug('mapCAOwners :::: '+mapCAOwners);
   
   //checking intermediate certificate can't create under CA Owner
   for(Account accountSo: accountSoLst){
       if(accountSo.recordTypeId == intermediateCARecTypeId && mapCAOwners.containskey(accountSo.ParentId)) {
           accountSo.addError('You cannot select '+mapCAOwners.get(accountSo.ParentId)+' as Parent CA Owner. Please select a Root Cert or Intermediate Cert.');     
       }  
   }

   // query the user details and check if it is a portal user and get the Owner account ID for that user
   List<User> userSoLst = [select IsPortalEnabled,contact.account.id,contact.account.name from user where id = :currentUserId];
    
   // intermediate cert can have only root/inter certs as their parents. this 
   // validation is done only for portal users
   if(userSoLst!=null && userSoLst.size() > 0 && userSoLst[0].isPortalEnabled)
   //if(userSoLst!=null && userSoLst.size() > 0 )
   {
     
    // set which holds list of all valid parentIDs 
    Set<Id> rootCAIDSet = New Set<Id>();
    
    List<Account> rootAccountSOLst = New List<Account>();
    
    // special case to handle the exceptional scenario for Symantec Accounts
    // When a portal user for any of Symantec Accounts (symantec or sy-geotrust or sy-verisign) 
    // logs in and creates an intermediate CA, they should be able to select the root certificate of any of these owner accounts
     Map<Id,Account> symantecAccountMap;
     List<ID> currentParent      = new List<ID>{};
    // check if the portal user is associated with any of the symantec accounts
    if(userSoLst[0].contact!=null && userSoLst[0].contact.account.name.startsWith('Symantec'))
    {
      // get all the symantec owner accounts
       symantecAccountMap = New Map<Id,Account>([select id from account where name like 'Symantec%' and recordTypeId=:ownerCARecTypeId]);
     
      
      // get all the root CAs for these owner accounts
      rootAccountSOLst  = [select name from Account where parentId in :symantecAccountMap.keySet() and (recordTypeId=:rootCARecTypeId or recordTypeId = :intermediateCARecTypeId)  ];
      for(Id accountId : symantecAccountMap.keySet())
      {
        currentParent.add(accountId );      
      }
      
    }
    else
    {
      
      // non-symantec accounts 
      rootAccountSoLst = [select name from Account where parentId = :userSoLst[0].contact.accountid  and (recordTypeId=:rootCARecTypeId   or recordTypeId = :intermediateCARecTypeId )];
      currentParent.add(userSoLst[0].contact.accountid );
    }
    //system.debug('##currentParent='+currentParent);
    
/*
     //loop over each root certificate and put it in the map
     for(Account accountSo : rootAccountSoLst )
     {
       rootCAIdSet.add(accountSo.id);
     }

     for(Account accountSo: accountSoLst)
    {
      if(accountSo.recordTypeId == intermediateCARecTypeId)
      {
       accountSo.CA_Owner_For_Inter_Cert__c = userSoLst[0].contact.account.name;
      }
    }
          
    List<Account> interCaAccountsLst ;
    
    // get all the intermediate certs where the roots are their parents
    interCaAccountsLst = [select name from Account where parentId in :rootCAIdSet and recordTypeId = :intermediateCARecTypeId];

     for(Account accountSo : interCaAccountsLst )
     {
       rootCAIdSet.add(accountSo.id);
     }
    */ 
     Boolean endOfStructure = false;

      List<Account> al            = new List<Account>{};
           Set<Id> recordIdSet= new Set<Id>(currentParent);
     while ( !endOfStructure ){


       al = [ SELECT id FROM Account a WHERE a.ParentID IN : CurrentParent ORDER BY a.Name ];            

            if( al.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                for ( Integer i = 0 ; i < al.size(); i++ ){
                    //Change below
                    Account a = al[i];
                    currentParent.add( a.id );
                    recordIdSet.add(a.id);
                }
           }
         }  

     
    //system.debug('##recordIdset='+recordIdSet);
     // loop over the existing records which are inserted/updated
      for(Account accountSo: accountSoLst)
      {
          // for each intermediate CA record if the parentId does not exist in the map of valid rootCA then throw an error.
          //if(accountSo.recordTypeId == intermediateCARecTypeId && (!rootCAIdSet.contains(accountSo.ParentId) || (Trigger.isUpdate && accountSo.parentId == accountso.id)))
           if(accountSo.recordTypeId == intermediateCARecTypeId && (!recordIdSet.contains(accountSo.ParentId) || (Trigger.isUpdate && accountSo.parentId == accountso.id))){
               accountSo.addError('Invalid selection made for Parent CA Owner/Certificate. Please select a Root Cert or Intermediate Cert owned by ' + userSoLst[0].contact.account.name);
           }          
      }  
   }
  }
    
    /*
    * recrusive method, will set CA Owner Info to all its children records
    */
    public static List<Account> defaultCA_OwnerOnChildRecords(Set<Id> parentAccId, String ultimateParentAccName, String ultimateParentAccId, List<Account> thisList){
        //System.debug('in recursive call..');
        //List<Account> lstAccountToUpdate = new List<Account>();
        Set<Id> parentRecordIds = new Set<Id>();
        
        List<Account> childrenRecords = [SELECT Id, ParentId FROM Account WHERE ParentId IN :parentAccId];
        
        if(childrenRecords.isEmpty()){
            //System.debug('end of recursive call..');
            return thisList;
        }
        
        for(Account acc : childrenRecords){
            //system.debug('**child record: '+acc.Id);
            thisList.add(new Account(Id = acc.Id, CA_Owner__c = ultimateParentAccName, CA_Owner_ID__c = ultimateParentAccId));
            parentRecordIds.add(acc.Id);
        }
        
        return defaultCA_OwnerOnChildRecords(parentRecordIds, ultimateParentAccName, ultimateParentAccId, thisList);
    }
    
    /*
    * Recursive method, to get ULTIMATE parent account
    */
    public static Account getUltimateParent(Id parentAccountId, String ultimateParentRecordTypeId){
        
        List<Account> parentRecord = [SELECT Id, Name, RecordTypeId, ParentId FROM Account WHERE Id = :parentAccountId];
        
        if(parentRecord.size() > 0){
            
            if(ultimateParentRecordTypeId == parentRecord[0].RecordTypeId){
                
                return parentRecord[0];
            }
            
            return getUltimateParent(parentRecord[0].ParentId, ultimateParentRecordTypeId);
        }
        
        return null;//should never reach here..
    }
    
    /*
    * method called from Trigger - contains Logic to populate CA Owner Info of current + child records.
    */
    public static void updateCAOwnerFields(Account newAccount, Account oldAccount){
        
        String caOwnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CA Owner').getRecordTypeId();
        String rootCertRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Root Certificate').getRecordTypeId();
        String intermediateCertRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediate Certificate').getRecordTypeId();
        
        //Case-I if there is an update in CA Owner Account's Name, update all it's child records with correcr CA Owner Name
        if(Trigger.isBefore && Trigger.isUpdate && newAccount.Name != oldAccount.Name && newAccount.RecordTypeId == caOwnerRecordTypeId){
            
            //system.debug('CASE-I change in account name of CA Owner Account.');
            
            newAccount.CA_Owner__c = newAccount.Name;
            newAccount.CA_Owner_ID__c = newAccount.Id;
            
            List<Account> lstAccountToUpdate = defaultCA_OwnerOnChildRecords(new Set<Id>{newAccount.Id}, newAccount.Name, newAccount.Id, new List<Account>{});
            //system.debug('list to update: '+lstAccountToUpdate.size());
            if(lstAccountToUpdate.size() > 0){
                try {
                    update lstAccountToUpdate;
                } catch (Exception ex){
                    string ErrorMessage = 'Trigger Error - Cannot proceed to update record due to following errors: ' + ex.getMessage();
                    newAccount.addError(ErrorMessage);
                }
            }
            
            return;
        }
        
        //Case-II if there is a change in ParentId in any "intermediate" or "Root" accounts.
        if(Trigger.isBefore && Trigger.isUpdate && newAccount.RecordTypeId != caOwnerRecordTypeId && newAccount.ParentId != oldAccount.ParentId && newAccount.ParentId != null){
            
            //system.debug('CASE-II update in parent Id');
            //Two sub-cases
            //1. change in parent Id of Root Certificate ->  
                //I. get the Immediate Parent -update in the CA Owner and CA Owner Id field
                //II. get all the child records - update will correct CA Owner & CA Owner Id fields.
            
            if(rootCertRecordTypeId == newAccount.RecordTypeId){
                
                //get Immediate Parent - hope "Root Cert" can we child of "CA Owner" Only if not then ignore - check with Poonamji and confirm
                List<Account> parentAccount = [SELECT Id, Name FROM Account WHERE Id = :newAccount.ParentId AND RecordTypeId = :caOwnerRecordTypeId];
                //system.debug('CASE-II - subcase - I.  update in parent Id of root cert');
                if(parentAccount.size() > 0){
                    //I.
                    newAccount.CA_Owner__c = parentAccount[0].Name;
                    newAccount.CA_Owner_ID__c = parentAccount[0].Id;
                    //II.
                    List<Account> lstAccountToUpdate = defaultCA_OwnerOnChildRecords(new Set<Id>{newAccount.Id}, parentAccount[0].Name, parentAccount[0].Id, new List<Account>{});
                    //system.debug('list to update: '+lstAccountToUpdate.size());
                    if(lstAccountToUpdate.size() > 0){
                        try {
                            update lstAccountToUpdate;
                        } catch (Exception ex){
                            string ErrorMessage = 'Trigger Error - Cannot proceed to update record due to following errors: ' + ex.getMessage();
                            newAccount.addError(ErrorMessage);
                        }
                    }
                    
                    return;
                }
            }
            
            //2. change in the parent Id of Intermediate Certificate -> 
                //I. get the ULTIMATE Parent - update CA Owner and CA Owner Id field
                //II. get all the child records - update will correct CA Owner & CA Owner Id fields.
            
            if(intermediateCertRecordTypeId == newAccount.RecordTypeId){
                
                //I.
                Account ultimanteParent = getUltimateParent(newAccount.ParentId, caOwnerRecordTypeId);
                
                if(ultimanteParent != null){
                    newAccount.CA_Owner__c = ultimanteParent.Name;
                    newAccount.CA_Owner_ID__c = ultimanteParent.Id;
                    
                    //II.
                    List<Account> lstAccountToUpdate = defaultCA_OwnerOnChildRecords(new Set<Id>{newAccount.Id}, ultimanteParent.Name, ultimanteParent.Id, new List<Account>{});
                    if(lstAccountToUpdate.size() > 0){
                        try {
                            update lstAccountToUpdate;
                        }  catch (Exception ex){
                            string ErrorMessage = 'Trigger Error - Cannot proceed to update record due to following errors: ' + ex.getMessage();
                            newAccount.addError(ErrorMessage);
                        }
                    }
                    
                    return;
                }
            }
        }
        
        //Case-III if root record inserted then update its "CA Owner" and "CA Owner Id" field of the same account
        if(Trigger.isAfter && Trigger.isInsert && newAccount.RecordTypeId == caOwnerRecordTypeId){
            
            //system.debug('CASE-III new CA Owner ACcount inserted');
            Account selfUpdate = new Account(Id = newAccount.Id, CA_Owner__c = newAccount.Name, CA_Owner_ID__c = newAccount.Id);
            try {
                update selfUpdate;
            }  catch (Exception ex){
                string ErrorMessage = 'Trigger Error - Cannot proceed to update record due to following errors: ' + ex.getMessage();
                newAccount.addError(ErrorMessage);
            }
        }
        
        //Case-IV
        if(Trigger.isBefore && Trigger.isInsert && newAccount.RecordTypeId != caOwnerRecordTypeId && newAccount.ParentId != null){
            //system.debug('CASE-IV Insert new intermediate or root certificate');
            
            //I. If Root Certificate inserted - get Immediate Parent & update correct CA Owner and CA Owner Id
            if(rootCertRecordTypeId == newAccount.RecordTypeId){
                List<Account> parentAccount = [SELECT Id, Name FROM Account WHERE Id = :newAccount.ParentId AND RecordTypeId = :caOwnerRecordTypeId];
                
                if(parentAccount.size() > 0){
                    //I.
                    newAccount.CA_Owner__c = parentAccount[0].Name;
                    newAccount.CA_Owner_ID__c = parentAccount[0].Id;
                }
                
                return;
            }
            
            //II. If Intermediate Certificate inserted - get ULTIMATE parent and update
            if(intermediateCertRecordTypeId == newAccount.RecordTypeId){
                
                Account ultimanteParent = getUltimateParent(newAccount.ParentId, caOwnerRecordTypeId);
                
                if(ultimanteParent != null){
                    newAccount.CA_Owner__c = ultimanteParent.Name;
                    newAccount.CA_Owner_ID__c = ultimanteParent.Id;
                }
                
                return;
            }
        }
    }
    
    public static String checkDeleteValidation(Account deletedAccount){
        
        Integer hasChildRecords = [SELECT COUNT() FROM Account WHERE ParentId = :deletedAccount.Id];
        
        if(hasChildRecords > 0){
            //deletedAccount.addError('You can\'t delete this record, please delete child records first.');
            return 'You can\'t delete this record, please delete child records first.';
        }
        
        return null;
    }
    
    /*
        This function is used to check if Audit URLs are same then other audit information should be same.
    */
    public static void checkAuditInfoWhenSameLink(List<Account> lstAccounts){
        String rootCertRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Root Certificate').getRecordTypeId();
        String intermediateCertRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediate Certificate').getRecordTypeId();
        
        for(Account objAcc: lstAccounts){
            
            if((objAcc.RecordTypeId == rootCertRecordTypeId || objAcc.RecordTypeId == intermediateCertRecordTypeId) && 
                objAcc.Standard_Audit__c != null){
                
                //compare standard audit with Code signing audit 
                if(objAcc.Code_Signing_Audit__c != null && objAcc.Standard_Audit__c == objAcc.Code_Signing_Audit__c) {
                    if(objAcc.Standard_Audit_Statement_Date__c != objAcc.Code_Signing_Audit_Statement_Date__c) {
                        objAcc.addError('Standard Audit & Code Signing Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_Start_Date__c != objAcc.Code_Signing_Audit_Period_Start_Date__c) {
                        objAcc.addError('Standard Audit & Code Signing Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_End_Date__c != objAcc.Code_Signing_Audit_Period_End_Date__c) {
                        objAcc.addError('Standard Audit & Code Signing Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare standard audit with BR Audit
                if(objAcc.BR_Audit__c != null && objAcc.Standard_Audit__c == objAcc.BR_Audit__c) {
                    if(objAcc.Standard_Audit_Statement_Date__c != objAcc.BR_Audit_Statement_Date__c) {
                        objAcc.addError('Standard Audit & BR Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_Start_Date__c != objAcc.BR_Audit_Period_Start_Date__c) {
                        objAcc.addError('Standard Audit & BR Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_End_Date__c != objAcc.BR_Audit_Period_End_Date__c) {
                        objAcc.addError('Standard Audit & BR Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                //compare standard audit with EV SSL Audit
                if(objAcc.EV_Audit__c != null && objAcc.Standard_Audit__c == objAcc.EV_Audit__c) {
                    if(objAcc.Standard_Audit_Statement_Date__c != objAcc.EV_Audit_Statement_Date__c) {
                        objAcc.addError('Standard Audit & EV SSL Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_Start_Date__c != objAcc.EV_Audit_Period_Start_Date__c) {
                        objAcc.addError('Standard Audit & EV SSL Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_End_Date__c != objAcc.EV_Audit_Period_End_Date__c) {
                        objAcc.addError('Standard Audit & EV SSL Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare standard audit with EV Code Signing Audit
                if(objAcc.EV_Code_Signing_Audit__c != null && objAcc.Standard_Audit__c == objAcc.EV_Code_Signing_Audit__c) {
                    if(objAcc.Standard_Audit_Statement_Date__c != objAcc.EV_Code_Signing_Audit_Statement_Date__c) {
                        objAcc.addError('Standard Audit & EV Code Signing Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_Start_Date__c != objAcc.EV_Code_Signing_Audit_Period_Start_Date__c) {
                        objAcc.addError('Standard Audit & EV Code Signing Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Standard_Audit_Period_End_Date__c != objAcc.EV_Code_Signing_Audit_Period_End_Date__c) {
                        objAcc.addError('Standard Audit & EV Code Signing Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare code signing audit with BR audit
                if(objAcc.Code_Signing_Audit__c != null && objAcc.BR_Audit__c != null && objAcc.Code_Signing_Audit__c == objAcc.BR_Audit__c) {
                    if(objAcc.Code_Signing_Audit_Statement_Date__c != objAcc.BR_Audit_Statement_Date__c) {
                        objAcc.addError('Code Signing Audit & BR Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Code_Signing_Audit_Period_Start_Date__c != objAcc.BR_Audit_Period_Start_Date__c) {
                        objAcc.addError('Code Signing Audit & BR Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Code_Signing_Audit_Period_End_Date__c != objAcc.BR_Audit_Period_End_Date__c) {
                        objAcc.addError('Code Signing Audit & BR Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare code signing audit with EV SSL audit
                if(objAcc.Code_Signing_Audit__c != null && objAcc.EV_Audit__c != null && objAcc.Code_Signing_Audit__c == objAcc.EV_Audit__c) {
                    if(objAcc.Code_Signing_Audit_Statement_Date__c != objAcc.EV_Audit_Statement_Date__c) {
                        objAcc.addError('Code Signing Audit & EV SSL Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Code_Signing_Audit_Period_Start_Date__c != objAcc.EV_Audit_Period_Start_Date__c) {
                        objAcc.addError('Code Signing Audit & EV SSL Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Code_Signing_Audit_Period_End_Date__c != objAcc.EV_Audit_Period_End_Date__c) {
                        objAcc.addError('Code Signing Audit & EV SSL Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare code signing audit with EV Code Signing audit
                if(objAcc.Code_Signing_Audit__c != null && objAcc.EV_Code_Signing_Audit__c != null && objAcc.Code_Signing_Audit__c == objAcc.EV_Code_Signing_Audit__c) {
                    if(objAcc.Code_Signing_Audit_Statement_Date__c != objAcc.EV_Code_Signing_Audit_Statement_Date__c) {
                        objAcc.addError('Code Signing Audit & EV Code Signing Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.Code_Signing_Audit_Period_Start_Date__c != objAcc.EV_Code_Signing_Audit_Period_Start_Date__c) {
                        objAcc.addError('Code Signing Audit & EV Code Signing Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.Code_Signing_Audit_Period_End_Date__c != objAcc.EV_Code_Signing_Audit_Period_End_Date__c) {
                        objAcc.addError('Code Signing Audit & EV Code Signing Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare BR audit with EV SSL Audit
                if(objAcc.BR_Audit__c != null && objAcc.EV_Audit__c != null && objAcc.BR_Audit__c == objAcc.EV_Audit__c) {
                    if(objAcc.BR_Audit_Statement_Date__c != objAcc.EV_Audit_Statement_Date__c) {
                        objAcc.addError('BR Audit & EV SSL Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.BR_Audit_Period_Start_Date__c != objAcc.EV_Audit_Period_Start_Date__c) {
                        objAcc.addError('BR Audit & EV SSL Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.BR_Audit_Period_End_Date__c != objAcc.EV_Audit_Period_End_Date__c) {
                        objAcc.addError('BR Audit & EV SSL Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare BR audit with EV Code Signing Audit
                if(objAcc.BR_Audit__c != null && objAcc.EV_Code_Signing_Audit__c != null && objAcc.BR_Audit__c == objAcc.EV_Code_Signing_Audit__c) {
                    if(objAcc.BR_Audit_Statement_Date__c != objAcc.EV_Code_Signing_Audit_Statement_Date__c) {
                        objAcc.addError('BR Audit & EV Code Signing Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.BR_Audit_Period_Start_Date__c != objAcc.EV_Code_Signing_Audit_Period_Start_Date__c) {
                        objAcc.addError('BR Audit & EV Code Signing Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.BR_Audit_Period_End_Date__c != objAcc.EV_Code_Signing_Audit_Period_End_Date__c) {
                        objAcc.addError('BR Audit & EV Code Signing Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
                
                //compare EV SSL audit with EV Code Signing Audit
                if(objAcc.EV_Audit__c != null && objAcc.EV_Code_Signing_Audit__c != null && objAcc.EV_Audit__c == objAcc.EV_Code_Signing_Audit__c) {
                    if(objAcc.EV_Audit_Statement_Date__c != objAcc.EV_Code_Signing_Audit_Statement_Date__c) {
                        objAcc.addError('EV SSL Audit & EV Code Signing Audit are same but Audit Statement Date does not match');
                        return;
                    }
                    if(objAcc.EV_Audit_Period_Start_Date__c != objAcc.EV_Code_Signing_Audit_Period_Start_Date__c) {
                        objAcc.addError('EV SSL Audit & EV Code Signing Audit are same but Audit Period Start Date does not match');
                        return;
                    }
                    if(objAcc.EV_Audit_Period_End_Date__c != objAcc.EV_Code_Signing_Audit_Period_End_Date__c) {
                        objAcc.addError('EV SSL Audit & EV Code Signing Audit are same but Audit Period End Date does not match');
                        return;
                    }
                }
            }
        }
    }
}