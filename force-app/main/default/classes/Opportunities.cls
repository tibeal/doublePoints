public class Opportunities {

    public static void onBeforeUpdate(List<Opportunity> records, Map<Id, Opportunity> existingRecords) {
        List<FieloPLT__Event__c> oppEvents = new List<FieloPLT__Event__c>();
        for (Opportunity opp : records) {
            Opportunity oldRecord = existingRecords.get(opp.Id);
            if (opp.StageName == 'Closed Won') {
                oppEvents.add(
                    new FieloPLT__Event__c(
                        FieloPLT__Type__c = 'Opportunity',
                        FieloPLT__Member__c = opp.Member__c
                    )
                );
            }
        }
        insert oppEvents;
    }

    public static void onAfterUpdate(List<Opportunity> records, Map<Id, Opportunity> existingRecords) {
        for (Opportunity opp : records) {
            Opportunity oldRecord = existingRecords.get(opp.Id);
            if (opp.Blocked__c == true && oldRecord.Blocked__c == true) {
                opp.addError('Blocked Opportunities are not allowed to be updated.');
            }
        }
    }
}
