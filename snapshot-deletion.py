import boto3
from datetime import datetime, timedelta
import datetime
import getopt

############################################################
# leifCleanAwsEc2Snapshots
# Script will delete all snapshots created before dateLimit.
# ALL SNAPSHOTS OLDER THAN THIS DATE WILL BE DELETED!!!
dateLimit = datetime.datetime(2023, 6, 17)
############################################################

# AWS Settings
client = boto3.client("ec2", region_name="eu-north-1")
snapshots = client.describe_snapshots(OwnerIds=["867736086712"])


def lambda_handler(event, context):

    # Calculate the number of days ago the date limit is.
    dateToday = datetime.datetime.now()
    dateDiff = dateToday - dateLimit
    #timedelta(days=1)
    sns_client = boto3.client('sns')

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
                # sns_client.publish(
                # TopicArn='arn:aws:sns:eu-north-1:867736086712:snapshot-deletion',
                # Subject='Deletion of snapshots.',
                # Message= 'hello',
                # )
        except getopt.GetoptError as e:
            if "InvalidSnapshot.InUse" in e.message:
                print("skipping this snapshot")
                continue
