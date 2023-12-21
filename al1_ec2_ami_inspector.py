import boto3
from tabulate import tabulate

def fetch_instance_amis(ec2_client, region='us-east-1'):
    response = ec2_client.describe_instances()
    instances = response['Reservations']

    instance_amis = []
    for reservation in instances:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            ami_id = instance['ImageId']
            instance_amis.append({'instance_id': instance_id, 'ami_id': ami_id})

    return instance_amis

def fetch_ami_name(ec2_client, ami_id, region='us-east-1'):
    response = ec2_client.describe_images(ImageIds=[ami_id])
    ami_name = response['Images'][0]['Name'] if response['Images'] else None
    return ami_name

def main():
    aws_region = 'us-east-1'

    # Initialize AWS clients
    ec2_client = boto3.client('ec2', region_name=aws_region)

    # Fetch all EC2 instance IDs and respective AMI IDs
    array_1 = fetch_instance_amis(ec2_client)

    # Fetch AMI names for each AMI ID in array_2
    array_2 = []
    for instance in array_1:
        ami_id = instance['ami_id']
        ami_name = fetch_ami_name(ec2_client, ami_id)
        if ami_name and ami_name.startswith('amzn-ami'):
            array_3.append({'instance_id': instance['instance_id'], 'ami_id': ami_id, 'ami_name': ami_name})

    # Print the final output
    print(tabulate(array_2, headers="keys"))

if __name__ == "__main__":
    main()
