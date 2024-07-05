@IsTest
class IC_SchedulerTCLBatch_TEST {

    static testmethod void test() {
    	String jobId = System.schedule('TEST_TCLSCHEDULER','0 0 0 3 9 ? 2024', new IC_SchedulerTCLBatch());
    }
}