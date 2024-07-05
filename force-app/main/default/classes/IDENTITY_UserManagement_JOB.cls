global class IDENTITY_UserManagement_JOB implements Schedulable {
    global void execute(SchedulableContext sc) {
          IDENTITY_UserManagement_BATCH job = new IDENTITY_UserManagement_BATCH();
          ID batchprocessid = Database.executeBatch(job, 200);
      }
  }