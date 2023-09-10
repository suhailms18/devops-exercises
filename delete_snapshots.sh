# Set the AWS region and your AWS CLI profile if needed
AWS_REGION="us-east-1"
AWS_PROFILE="your-profile-name"

# Specify the file path to your snapshot IDs text file
SNAPSHOT_FILE="snapshot_ids.txt"

# Specify the file path to the output text file for removed snapshots
REMOVED_SNAPSHOTS_FILE="removed_snapshots.txt"

# Read each line in the snapshot IDs file
while IFS= read -r SNAPSHOT_ID; do
    # Check if there are any AMIs associated with the snapshot
    AMI_COUNT=$(aws ec2 describe-images --filters "Name=block-device-mapping.snapshot-id,Values=$SNAPSHOT_ID" --region $AWS_REGION --profile $AWS_PROFILE --query 'length(Images)' --output text)

    if [ "$AMI_COUNT" -eq 0 ]; then
        # No associated AMIs found, delete the snapshot
        echo "Deleting snapshot $SNAPSHOT_ID..."
        aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID --region $AWS_REGION --profile $AWS_PROFILE
        echo "Snapshot $SNAPSHOT_ID deleted."

        # Append the removed snapshot to the output file
        echo "$SNAPSHOT_ID" >> "$REMOVED_SNAPSHOTS_FILE"
    else
        # Associated AMIs found, skip deletion
        echo "Snapshot $SNAPSHOT_ID has associated AMIs. Skipping deletion."
    fi
done < "$SNAPSHOT_FILE"
