#!/bin/bash

# Set the AWS region and your AWS CLI profile if needed
AWS_REGION="us-east-1"
AWS_PROFILE="your-profile-name"

# Specify the file path to your volume IDs text file
VOLUME_FILE="volume_ids.txt"

# Specify the file path to the output text file for removed volumes
REMOVED_VOLUMES_FILE="removed_volumes.txt"

# Read each line in the volume IDs file
while IFS= read -r VOLUME_ID; do
    # Check if the volume is available and not in use
    VOLUME_STATUS=$(aws ec2 describe-volumes --volume-ids "$VOLUME_ID" --region $AWS_REGION --profile $AWS_PROFILE --query 'Volumes[0].State' --output text)

    if [ "$VOLUME_STATUS" == "available" ]; then
        # Check if there are any snapshots or AMIs associated with the volume
        SNAPSHOT_COUNT=$(aws ec2 describe-snapshots --filters "Name=volume-id,Values=$VOLUME_ID" --region $AWS_REGION --profile $AWS_PROFILE --query 'length(Snapshots)' --output text)
        AMI_COUNT=$(aws ec2 describe-images --filters "Name=block-device-mapping.ebs.volume-id,Values=$VOLUME_ID" --region $AWS_REGION --profile $AWS_PROFILE --query 'length(Images)' --output text)

        if [ "$SNAPSHOT_COUNT" -eq 0 ] && [ "$AMI_COUNT" -eq 0 ]; then
            # No associated snapshots or AMIs found, delete the volume
            echo "Deleting volume $VOLUME_ID..."
            aws ec2 delete-volume --volume-id "$VOLUME_ID" --region $AWS_REGION --profile $AWS_PROFILE
            echo "Volume $VOLUME_ID deleted."

            # Append the removed volume to the output file
            echo "$VOLUME_ID" >> "$REMOVED_VOLUMES_FILE"
        else
            # Snapshots or AMIs associated with the volume, skip deletion
            echo "Volume $VOLUME_ID has associated snapshots or AMIs. Skipping deletion."
        fi
    else
        # Volume is not available, skip deletion
        echo "Volume $VOLUME_ID is not available. Skipping deletion."
    fi
done < "$VOLUME_FILE"
