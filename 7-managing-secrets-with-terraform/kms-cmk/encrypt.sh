#!/bin/bash

set -e

if [[ "$#" -ne 4 ]]; then
  echo "Usage: encrypt.sh <CMK_ID> <AWS_REGION> <INPUT_FILE> <OUTPUT_FILE>"
  exit
fi

CKM_ID="$1"
AWS_REGION="$2"
INPUT_FILE="$3"
OUTPUT_FILE="$4"

echo "Encrypting contents of $INPUT_FILE using CMK $CMK_ID..."
ciphertext=$(aws kms encrypt \
    --key-id "$CKM_ID" \
    --region "$AWS_REGION" \
    --plaintext "fileb://$INPUT_FILE" \
    --output text \
    --query CiphertextBlob)

echo "Writing result to $OUTPUT_FILE..."
echo "$ciphertext" > "$OUTPUT_FILE"

echo "Done!"

# Instead of this long command we can use side tools like sops
# It can cypher and decypher files automatically, using AWS KMS, Azure Key Vault, GCP KMS or PGP