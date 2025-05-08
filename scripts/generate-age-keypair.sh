#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

KEY_FILE="keys.txt"
SECRETS_FILE=".env.sops.yaml"

# --- Prerequisite Checks ---
if ! command -v age &> /dev/null; then echo "ERROR: age command not found. Run 'mise install'." >&2; exit 1; fi
if ! command -v sops &> /dev/null; then echo "ERROR: sops command not found. Run 'mise install'." >&2; exit 1; fi

if [ -z "$SOPS_AGE_KEY_FILE" ]; then
		echo "ERROR: SOPS_AGE_KEY_FILE is not set. Please set it to the path of your SOPS key file; eg './keys.age' or './keys.txt'." >&2
		exit 1
fi

# --- Generate Age Key ---
if [ -f "$KEY_FILE" ]; then
    echo "INFO: Age key file '$KEY_FILE' already exists. Skipping generation."
else
    echo "INFO: Age key file ($KEY_FILE) not found. Generating new key..."
    if age-keygen -o "$KEY_FILE"; then
        chmod 600 "$KEY_FILE"
        echo "INFO: Generated $KEY_FILE."
        echo "IMPORTANT: Secure this file and ensure it is listed in .gitignore!"
    else
        echo "ERROR: Failed to generate age key." >&2
        exit 1
    fi
fi

# --- Extract Public Key ---
PUBLIC_KEY="$(age-keygen -y ${KEY_FILE})"
if [ -z "$PUBLIC_KEY" ]; then
		echo "ERROR: Could not extract public key from $KEY_FILE." >&2
		exit 1
fi
echo "INFO: Public key for AGE key file: $PUBLIC_KEY"
echo "IMPORTANT: Add this public key to .sops.yaml as a recipient for file encryption."

# --- Encrypt Private Key ---
echo "INFO: Converting private key to ASCII-armored AGE encrypted format..."
AGE_KEY_FILE="${KEY_FILE%.txt}.age"
if ! age --armor --passphrase "$KEY_FILE" > "$AGE_KEY_FILE"; then
		echo "ERROR: Failed to convert private key to PEM format." >&2
		exit 1
fi
echo "INFO: Converted private key to PEM format: '${AGE_KEY_FILE}'."

# --- Test SOPS Configuration ---
echo "INFO: Testing SOPS configuration..."
echo "Test Test Test" > test.txt
if ! sops encrypt --in-place --age "$PUBLIC_KEY" test.txt; then
		echo "ERROR: Failed to encrypt test file with SOPS." >&2
		exit 1
fi
if ! sops decrypt --in-place "test.txt"; then
		echo "ERROR: Failed to decrypt test file with SOPS." >&2
		exit 1
fi
rm test.txt
echo "INFO: SOPS configuration is valid."

echo "--- Setup Complete ---"
echo "INFO: Use 'mise run encrypt' to add secrets to $SECRETS_FILE."
echo "IMPORTANT: Remember to secure your '$KEY_FILE' and ensure it's gitignored."
