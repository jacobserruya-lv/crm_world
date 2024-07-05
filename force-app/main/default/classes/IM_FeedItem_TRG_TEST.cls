@isTest(SeeAllData = true)
private class IM_FeedItem_TRG_TEST {

  @isTest static void FeedItemAfterInsert() {

    IM_NotificationsMaps__c nmp9 = new IM_NotificationsMaps__c(Name = 'CareService', Aliases__c = 'CareServiceId,ClientId,Name', Fields__c = 'Id,Client__c,Client__r.Name', ObjectName__c = 'CollaborationGroup');
    List < IM_NotificationsMaps__c > npms = new List < IM_NotificationsMaps__c > { nmp9 };
    try {
      insert npms;
    } catch (Exception e) {}
    CollaborationGroup grp = new CollaborationGroup();
    grp.Name = 'Israel Customers1';
    grp.CollaborationType = 'public';
    insert grp;
    List < CollaborationGroup > clist = [SELECT Id, Name FROM CollaborationGroup where name = 'Israel Customers1'
      limit 1
    ];
    List < FeedItem > items = new List < FeedItem > ();
    FeedItem post1 = new FeedItem();
    if (clist.size() > 0)
      post1.ParentId = clist[0].id;
    else
      post1.ParentId = userInfo.getUserId();
    post1.Body = '[#Sale] If this works im gonna be angry'; // And i was... super simple :D
    items.add(post1);
    FeedItem post2 = new FeedItem();
    if (clist.size() > 0)
      post2.ParentId = clist[0].id;
    else
      post2.ParentId = userInfo.getUserId();
    post2.Body = 'If this works im gonna be angry'; // And i was... super simple :D
    items.add(post2);
    FeedItem post3 = new FeedItem();
    if (clist.size() > 0)
      post3.ParentId = clist[0].id;
    else
      post3.ParentId = userInfo.getUserId();
    post3.Body = '[#Support] If this works im gonna be angry'; // And i was... super simple :D
    items.add(post3);
    insert items;

  }

  @isTest static void FeedItemAfterInsert2() {

    try {
      CollaborationGroup grp = new CollaborationGroup();
      grp.Name = 'User';
      grp.CollaborationType = 'User';
      insert grp;
      List < CollaborationGroup > clist = [SELECT Id, Name FROM CollaborationGroup where name = 'User'
        limit 1
      ];
      List < FeedItem > items = new List < FeedItem > ();

      FeedItem post1 = new FeedItem();
      post1.body = 'Mention';
      items.add(post1);
      if (clist.size() > 0)
        post1.ParentId = clist[0].id;
      else
        post1.ParentId = userInfo.getUserId();
      post1.Body = '[#Sale] If this works im gonna be angry'; // And i was... super simple :D
      items.add(post1);
      FeedItem post2 = new FeedItem();
      if (clist.size() > 0)
        post2.ParentId = clist[0].id;
      else
        post2.ParentId = userInfo.getUserId();
      post2.Body = 'If this works im gonna be angry'; // And i was... super simple :D
      items.add(post2);
      FeedItem post3 = new FeedItem();
      if (clist.size() > 0)
        post3.ParentId = clist[0].id;
      else
        post3.ParentId = userInfo.getUserId();
      post3.Body = '[#Support] If this works im gonna be angry'; // And i was... super simple :D
      items.add(post3);
      insert items;
    } catch (Exception e) {}

  }
}