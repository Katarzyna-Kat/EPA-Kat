# EPA-Kat

This repo is a pipeline which can be applied into any AWS account to delete old snapshots.

The AWS credentials need to be updated inside github secrets.

Inside Variables you will find the emails you want to attach for the notifications as well as the region you want to apply the lambda into.

In main.tf you can update dry_run into either 'true' or 'false' in order to test your lambda and what would be deleted.
Also how often you want the lambda to run using triggers and what alarms you would like to include.

Inside main_functions.py you can change the age of snapshots to be deleted.

The pipeline is fully automated and it includes pytests which are run within the workflow.