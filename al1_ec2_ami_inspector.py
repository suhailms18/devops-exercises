import boto3
from tabulate import tabulate

# Fetch AMIs with the name within the specified region
def fetch_amis_with_name(ec2_client, ami_name, region='your-region'):
    response = ec2_client.describe_images(
        Filters=[
            {'Name': 'name', 'Values': [ami_name]},
            {'Name': 'state', 'Values': ['available']}
        ]
    )
    return response['Images']

# Fetch all EC2 instance IDs and respective AMI IDs
def fetch_instance_amis(ec2_client, region='your-region'):
    response = ec2_client.describe_instances()
    instances = response['Reservations']

    instance_amis = []
    for reservation in instances:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            ami_id = instance['ImageId']
            instance_amis.append({'instance_id': instance_id, 'ami_id': ami_id})

    return instance_amis

def main():
    aws_region = 'your-region'        # 'us-east-1'
    ami_name_to_search = 'amzn-ami*'  # Amazon Linux 1 AMI name

    # Initialize AWS clients
    ec2_client = boto3.client('ec2', region_name=aws_region)

    # Fetch all AMIs in us-east-1 with the specified name in the Array
    array_1 = fetch_amis_with_name(ec2_client, ami_name_to_search)

    # Store all EC2 instance IDs and respective AMI IDs in the Array
    array_2 = fetch_instance_amis(ec2_client)

    # Loop through array_1 and find matching instances in array_2
    array_3 = []
    for ami in array_1:
        ami_id = ami['ImageId']
        ami_name = ami['Name']
        matching_instances = [instance for instance in array_2 if instance['ami_id'] == ami_id]
        instance_ids = ', '.join(instance['instance_id'] for instance in matching_instances)
        if instance_ids:
            array_3.append({'ami_id': ami_id, 'ami_name': ami_name, 'instance_ids': instance_ids})

    # Print the final output in a tabular column
    print(tabulate(array_3, headers="keys"))

if __name__ == "__main__":
    main()
