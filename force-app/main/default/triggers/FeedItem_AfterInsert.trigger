trigger FeedItem_AfterInsert on FeedItem (after insert) {
	IM_FeedItem_TRG.send(Trigger.new);
}