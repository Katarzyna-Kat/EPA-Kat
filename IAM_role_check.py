import botocore
import boto3

try:
    iam = boto3.client('iam')
    user = iam.create_user(UserName='snapshot_deletion_lambda')
    print("Created user: %s" % user)
    
except iam.exceptions.EntityAlreadyExistsException:
    print("User already exists")
except botocore.exceptions.ParamValidationError as e:
    print("Parameter validation error: %s" % e)
except botocore.exceptions.ClientError as e:
    print("Unexpected error: %s" % e)