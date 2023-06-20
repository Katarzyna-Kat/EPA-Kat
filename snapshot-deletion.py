import boto3
import json
from datetime import datetime, timedelta
import datetime
import getopt

############################################################
# leifCleanAwsEc2Snapshots
# Script will delete all snapshots created before dateLimit.
# ALL SNAPSHOTS OLDER THAN THIS DATE WILL BE DELETED!!!
dateLimit = datetime.datetime(2023, 6, 17)
dateEmail = datetime.datetime(2023, 6, 20)
############################################################

# AWS Settings
client = boto3.client("ec2", region_name="eu-north-1")
snapshots = client.describe_snapshots(OwnerIds=["867736086712"])


def lambda_handler(event, context):

    # Calculate the number of days ago the date limit is.
    dateToday = datetime.datetime.now()
    dateDiff = dateToday - dateLimit
    dateDiffEmail = dateToday - dateEmail
    # timedelta(days=1)
    sns_client = boto3.client('sns')
    list_of_ids = []
    list_of_dates = []

    # Could base this clean-up on the number of snapshots too.
    # snapshotCount=len(snapshots['Snapshots'])
    for snapshot in snapshots["Snapshots"]:
        a = snapshot["StartTime"]
        b = a.date()
        c = datetime.datetime.now().date()
        d = c - b
        try:
            if d.days > dateDiff.days:
                id = snapshot["SnapshotId"]
                started = snapshot["StartTime"]
                print(id + "********************")
                print(started)
                # Uncomment below line for "live run"
                # client.delete_snapshot(SnapshotId=id)
                print("DELETED^^^^^^^^^^^^^^^^^^")
            elif dateDiffEmail.days < d.days < dateDiff.days:
                id_email = snapshot["SnapshotId"]
                started_email = snapshot["StartTime"]
                is_appending = list_of_ids.append(id_email)
                dates_appending = list_of_dates.append(started_email)
        except getopt.GetoptError as e:
            if "InvalidSnapshot.InUse" in e.message:
                print("skipping this snapshot")
                break
    dates_changed = [str(x) for x in list_of_dates]
    email_total = {list_of_ids[i]: dates_changed[i] for i in range(len(list_of_ids))}
    sns_client.publish(
    TopicArn='$(aws_sns_topic.user_updates.arn)',
    Subject='Deletion of snapshots.',
    Message= json.dumps(email_total),
    )
