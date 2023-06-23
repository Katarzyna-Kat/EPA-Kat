import datetime
from unittest.mock import Mock
from main_code.main_functions import deletion_of_snapshots_function, log_of_snapshots_ids_and_dates

#### 2 functions for date_limit_function()

#### happy path for deletion_of_snapshots_function()
def test_true_dry_run_deletion_of_snapshots_function():
    snapshots_id = 'snap-0ad3582cfacf4acba'
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = True
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id, DryRun=True)

#######
def test_invalid_snapshot_deletion_of_snapshots_function():
    snapshots_id = 'snap'
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = True
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id, DryRun=True)


####### happy path for log_of_snapshots_ids_and_dates()
def test_log_of_snapshots_ids_and_dates():
    snapshots_id = 'snap-0ad3582cfacf4acba'
    snapshots_date = datetime.date(2023, 6, 20)
    log_of_snapshots_ids_and_dates()
    pass

####### happy path for def lambda_handler(event, context)
def lambda_handler(event, context):
    pass