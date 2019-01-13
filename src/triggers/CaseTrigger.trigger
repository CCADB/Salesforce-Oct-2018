// Trigger for the case object which handles all the events and based on the event delegates the task 
// to the corresponding trigger handler method in the CaseTriggerHelper class
//
// 08/31/2018 Added DefaultCaseAssignedTo method
//

trigger CaseTrigger on Case (before insert, before update, after insert, after update) {

    if(trigger.isBefore){
    
       if(trigger.isInsert) {
           //CaseTriggerHelper.PortalUserValidation(Trigger.New);
           //CaseTriggerHelper.SetAccountStatusField(Trigger.New);
           CaseTriggerHelper.EnforceCAOwnerRule(Trigger.New);
           CaseTriggerHelper.SetAllFieldsVerifiedField(Trigger.New); 
           CaseTriggerHelper.EnforceCommunityUser(Trigger.New);
           CaseTriggerHelper.EnforceRequestStatusRulesForInserts(Trigger.New);
           CaseTriggerHelper.DefaultCAOwnerFields(Trigger.New);
           CaseTriggerHelper.DefaultCaseAssignedTo (Trigger.New);
           //CaseTriggerHelper.EnforceRequestStatusRulesForAuditUpdates(Trigger.New, Trigger.oldMap);
       }
        
       if(trigger.isUpdate) {
           //CaseTriggerHelper.PortalUserValidation(Trigger.New);
           CaseTriggerHelper.EnforceCAOwnerRule(Trigger.New);
           CaseTriggerHelper.EnforceAccountRules(Trigger.New, Trigger.OldMap);       
           CaseTriggerHelper.SetAllFieldsVerifiedField(Trigger.New);
           CaseTriggerHelper.EnforceCommunityUser(Trigger.New);
           CaseTriggerHelper.EnforceRequestStatusRulesForUpdates(Trigger.New, Trigger.OldMap);
           CaseTriggerHelper.EnforceRequestStatusRulesForAuditUpdates(Trigger.New, Trigger.oldMap);
           CaseTriggerHelper.DefaultCAOwnerFieldsOnChange(Trigger.New, Trigger.oldMap);
           // CaseTriggerHelper.populateAuditDeviationForCAAuditUpdateCases(Trigger.New, Trigger.oldMap);
           //CaseTriggerHelper.setAuditFileArchive(Trigger.New, Trigger.oldMap);
       }        
    }
    //added by Sunil
    if(trigger.Isafter) {
        CaseTriggerHelper.ManualCaseSharing(trigger.new);
    }
    
    //added on 2nd May 18 - Audit Gap updates
    if(trigger.isAfter && trigger.isUpdate){
        CaseTriggerHelper.UpdateAuditGaps(Trigger.New, Trigger.OldMap);
    }
}