from XrdTest.TestUtils import TestSuite, TestCase

def getTestSuite():
    ts = TestSuite()

    # Unique name for this test suite. Currently, it must match the filename
    # exactly, minus the extension. (mandatory)
    ts.name = "ts_008_eos"
    # Names of all clusters which this test suite requires. (mandatory)
    ts.clusters = ['cluster_007_eos']
    # Names of all machines required by this test suite (optional)
    # ts.machines = ['metamanager1', 'manager1', 'manager2', 'ds1', 'ds2', 'ds3', 'ds4', 'client1']
    # Names of test cases to be run in this suite. These are actually the names
    # of the subfolders in the tc/ directory. Each test case subdirectory must
    # contain at least an initialization script called init.sh and a run script
    # called run.sh. Also an optional finalization script called finalize.sh can
    # be included. (mandatory)
    ts.tests = ['run_eos_tests']
    # Cron-style scheduler expression for this suite. (mandatory)
    ts.schedule = dict(second='00', minute='00', hour='00', day='*', month='*')
    # Path to the test suite initialization script. Usually in the same directory
    # as this definition, and usually called suite_init.sh. Can also optionally
    # be an HTTP URL, an absolute file path, or an inline script. (mandatory)
    ts.initialize = "file://suite_init.sh"
    # Path to the test suite finalization script. (optional)
    ts.finalize = "file://suite_finalize.sh"
    # List containing paths to any log files that should be pulled at each stage.
    # These will show up as a tab on the web interface. If necessary, the
    # @slavename@ tag can be used in the path.
    ts.logs = ['/var/log/eos/fst/xrdlog.fst',
               '/var/log/eos/mgm/xrdlog.mgm',
               '/var/log/eos/mq/xrdlog.mq',
               '/etc/sysconfig/eos',
               '/etc/xrd.cf.mgm',
               '/var/log/XrdTest/XrdTestSlave.log']
    # List of email addresses which will be alerted for this test suite, based
    # on the alert policies below.
    ts.alert_emails = ['jsalmon@cern.ch', 'apeters@cern.ch']
    # Email alert policy for test suite successes.
    # CASE = on each test CASE success;
    # SUITE = on each test SUITE success;
    # NONE = no success alerts
    ts.alert_success = 'SUITE'
    # Email alert policy for test suite failures.
    # CASE = on each test CASE failure;
    # SUITE = on each test SUITE failure;
    # NONE = no failure alerts
    ts.alert_failure = 'CASE'
    
    return ts
