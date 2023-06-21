import datetime
from unittest.mock import Mock
from functions_folder.main_code.main_functions import deletion_of_snapshots_function

#### happy path
def test_true_dry_run_deletion_of_snapshots_function():
    snapshots_id = 'snap-0ad3582cfacf4acba'
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = True
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id, DryRun=True)

def test_false_dry_run_deletion_of_snapshots_function():
    snapshots_id = 'snap-0ad3582cfacf4acba'
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = False
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id)


#######
def test_invalid_snapshot_deletion_of_snapshots_function():
    snapshots_id = 'snap-0ad3582cfacf4acba'
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = False
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id)