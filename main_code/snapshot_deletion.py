import boto3
import json
from main_functions import *

def lambda_handler(event, context):
    dry_run = event.get("dry_run", False)
    [dateDiff, dateDiffEmail] = date_limit_function(dateToday)
    sns_client = boto3.client("sns")
    [snapshot_log, retrieve_snapshot_logs] = log_of_snapshots_ids_and_dates()
    for snapshot in snapshots["Snapshots"]:
        snapshots_id = snapshot["SnapshotId"]
        snapshots_date = snapshot["StartTime"].date()
        today_delta = dateToday.date() - snapshots_date
        days_for_deletion = dateToday.day - dateDiff.day
        days_for_email = dateToday.day - dateDiffEmail.day

        if today_delta.days > days_for_deletion:
            deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run)

        elif days_for_email < today_delta.days < dateDiff.day:
            snapshot_log(snapshots_id, snapshots_date)

    sns_client.publish(
        TopicArn='arn:aws:sns:eu-north-1:867736086712:snapshot_deletion',
        Subject="Deletion of snapshots.",
        Message=json.dumps(retrieve_snapshot_logs()),
    )
