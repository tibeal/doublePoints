trigger Opportunities on Opportunity (before update, after update){
	if(Trigger.isBefore && Trigger.isUpdate) {
		Opportunities.onBeforeUpdate(Trigger.new, Trigger.oldMap);
	} else if(Trigger.isAfter && Trigger.isUpdate){
		Opportunities.onAfterUpdate(Trigger.new, Trigger.oldMap);
	}
}