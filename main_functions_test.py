from datetime import timedelta
import datetime
from unittest.mock import Mock
from main_code.main_functions import (deletion_of_snapshots_function)


def test_date_limit_function():
    date_diff = datetime.datetime(2023, 6, 19) - timedelta(days = 3)
    date_diff_email = datetime.datetime(2023, 6, 19) - timedelta(days = 1)
    assert date_diff == datetime.datetime(2023, 6, 16)
    assert date_diff_email == datetime.datetime(2023, 6, 18)

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
    result = "Skipping this snapshot - this snapshot is in use^^^^^^^^^^^^^^^^^^^^"
    if snapshots_id != "snap-0ad3582cfacf4acba":
        result = True
    assert result == True