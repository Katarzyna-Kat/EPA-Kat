import boto3
import json
from main_functions import *
from datetime_function import *
# from datetime import datetime, timedelta
# import datetime
# import getopt

# ############################################################
# # leifCleanAwsEc2Snapshots
# # Script will delete all snapshots created before dateLimit.
# # ALL SNAPSHOTS OLDER THAN THIS DATE WILL BE DELETED!!!
# dateLimit = datetime.datetime(2023, 6, 16)
# dateEmail = datetime.datetime(2023, 6, 20)
# ############################################################

# # AWS Settings
# ec2_client = boto3.client("ec2", region_name="eu-north-1")
# snapshots = ec2_client.describe_snapshots(OwnerIds=["867736086712"])
# dateToday = datetime.datetime.now()


# def date_limit_function(today_date):
#     dateDiff = today_date - dateLimit
#     dateDiffEmail = today_date - dateEmail
#     # timedelta(days=1)
#     return [dateDiff, dateDiffEmail]


# def deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run):
#     print("SNAPSHOT TO BE DELETED:")
#     print(snapshots_id, snapshots_date)
#     try:
#         if dry_run == False:
#             ec2_client.delete_snapshot(SnapshotId=snapshots_id)
#             print("DELETED^^^^^^^^^^^^^^^^^^")
#         else:
#             ec2_client.delete_snapshot(SnapshotId=snapshots_id, DryRun=True)
#     except Exception as e:
#         if type(e) == getopt.GetoptError and "InvalidSnapshot.InUse" in e.message:
#             print(
#                 "Skipping this snapshot - this snapshot is in use^^^^^^^^^^^^^^^^^^^^"
#             )
#         else:
#             print("Something went wrong.")
#             print(e)
#             print("The snapshot could not be deleted^^^^^^^^^^^^^^^^^^^^")


# def log_of_snapshots_ids_and_dates():
#     list_of_ids = []
#     list_of_dates = []

#     def snapshot_log(snapshots_id, snapshots_date):
#         list_of_ids.append(snapshots_id)
#         list_of_dates.append(snapshots_date)

#     def retrieve_snapshot_logs():
#         dates_changed_format = [str(x) for x in list_of_dates]
#         dictionary_of_ids_and_dates = {
#             list_of_ids[i]: dates_changed_format[i] for i in range(len(list_of_ids))
#         }
#         return dictionary_of_ids_and_dates

#     return [snapshot_log, retrieve_snapshot_logs]


def lambda_handler(event, context):
    dry_run = event.get("dry_run", False)
    [dateDiff, dateDiffEmail] = date_limit_function(dateToday)
    sns_client = boto3.client("sns")
    [snapshot_log, retrieve_snapshot_logs] = log_of_snapshots_ids_and_dates()
    for snapshot in snapshots["Snapshots"]:
        snapshots_id = snapshot["SnapshotId"]
        snapshots_date = snapshot["StartTime"].date()
        today_delta = dateToday.date() - snapshots_date

        if today_delta.days > dateDiff.day:
            deletion_of_snapshots_function(snapshots_id, snapshots_date, dry_run)

        elif dateDiffEmail.day < today_delta.days < dateDiff.day:
            snapshot_log(snapshots_id, snapshots_date)

    sns_client.publish(
        TopicArn='arn:aws:sns:eu-north-1:867736086712:snapshot_deletion',
        Subject="Deletion of snapshots.",
        Message=json.dumps(retrieve_snapshot_logs()),
    )
