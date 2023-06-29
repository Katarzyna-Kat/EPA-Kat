import datetime
from unittest.mock import Mock
from main_code.main_functions import (
    deletion_of_snapshots_function,
    log_of_snapshots_ids_and_dates,
)
from main_code.snapshot_deletion import lambda_handler


####
def test_true_dry_run_deletion_of_snapshots_function():
    snapshots_id = "snap-0ad3582cfacf4acba"
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = True
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id, DryRun=True)


#######
def test_invalid_snapshot_deletion_of_snapshots_function():
    snapshots_id = "snap"
    snapshots_date = datetime.date(2023, 6, 20)
    dry_run = True
    ec2_client = Mock()
    deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run, ec2_client)
    ec2_client.delete_snapshot.assert_called_once()
    ec2_client.delete_snapshot.assert_called_with(SnapshotId=snapshots_id, DryRun=True)


####### happy path for log_of_snapshots_ids_and_dates()
# def test_log_of_snapshots_ids_and_dates():
#     snapshots_id_1 = "snap-0ad3582cfacf4acba"
#     snapshots_id_2 = "snap-0ad3582cfacf4aabc"
#     snapshots_date_1 = datetime.date(2023, 6, 20)
#     snapshots_date_2 = datetime.date(2023, 6, 21)
#     pass
#     # log_of_snapshots_ids_and_dates()
#     # assert log_of_snapshots_ids_and_dates() == [snapshot_log, retrieve_snapshot_logs]


####### happy path for def lambda_handler(event, context)
# def test_lambda_handler():
#     snapshots_id = "snap-0ad3582cfacf4aabc"
#     snapshots_date = datetime.date(2023, 6, 20)
#     lambda_handler(event, context)
#     pass
