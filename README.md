# Fielo Double Points Issue

## Pre Conditions:
- Activate FieloPLT Library
- Activate Local Library

### Metadata
- Two custom fields in Opportunity:
    - Blocked (checkbox, default: false)
    - Member (Lookup(FieloPLT__Member__c))

- Classes
    - [Opportunity.cls](https://github.com/tibeal/doublePoints/blob/master/force-app/main/default/classes/Opportunities.cls)
```apex
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
```
- Triggers
    - [Opportunity.trigger](https://github.com/tibeal/doublePoints/blob/master/force-app/main/default/triggers/Opportunities.trigger)
```apex
trigger Opportunities on Opportunity (before update, after update){
	if(Trigger.isBefore && Trigger.isUpdate) {
		Opportunities.onBeforeUpdate(Trigger.new, Trigger.oldMap);
	} else if(Trigger.isAfter && Trigger.isUpdate){
		Opportunities.onAfterUpdate(Trigger.new, Trigger.oldMap);
	}
}
```

### Business Rules
- Whenever an opportunity is updated to Stage = Closed Won a Fielo Event with Type = Opportunity is created and incentivized
- There is a validation in the after trigger of opportunity:
    - Opportunities with the field Blocked = true when updated throw an error "Blocked Opportunities are not allowed to be modified."

### Program Configuration
- 1 promotion
- 1 Rule on Generate event and win
    - 1 point per event

