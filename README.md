# Example Mise-SOPS-AGE Project

This project demonstrates how to configure a Mise environment with an encrypted `.env` file using [SOPS](https://github.com/mozilla/sops) and [AGE](https://github.com/FiloSottile/age).

## Features

- **Encrypted Secrets Management**: Securely manage secrets in `.env.sops.yaml` using SOPS and AGE.
- **Mise Integration**: Automate tasks and environment setup with Mise.

## Project Structure

```plaintext
.env.sops.yaml   # Tracked **secret** environment variables (initially plaintext; encrypted after setup is completed)
.env.tracked     # Tracked **non-sensitive** environment variables
.gitignore       # Git ignore rules for sensitive files
.sops.yaml       # SOPS configuration
keys.age         # Encrypted AGE key file (gitignored)
keys.txt         # Plaintext AGE key file (gitignored)
mise.toml        # Mise configuration
README.md        # Project documentation
scripts/         # Helper scripts
  generate-age-keypair.sh  # Script to generate AGE keypair
```

## Getting Started

### Prerequisites

Ensure that Mise is installed:
- [Mise](https://github.com/mise-sh/mise)

Other dependencies (SOPS and AGE) are installed via Mise. Linked for reference only.
- [SOPS](https://github.com/mozilla/sops)
- [AGE](https://github.com/FiloSottile/age)

### Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd Demo-Mise-SOPS-Age
   ```

2. **Initialise Mise**
  ```bash
  mise trust
  mise install
  ```

3. **Generate AGE Keypair**:
   Run the following Mise task to generate an AGE keypair.  
   The key generation script automatically validates the SOPS configuration by encrypting and decrypting a test file.
   ```bash
   mise run generate-age-keypair
   ```

4. **Add Public Key to SOPS Configuration**:
   Copy the public key output from the key generation step and add it to `.sops.yaml` under the `age` section.

5. **Encrypt Secrets**:
   Encrypt the `.env.sops.yaml` file using the following command. This only needs to occur once.
   ```bash
   mise run encrypt
   ```


### Usage

- **Encrypt Secrets**:
  ```bash
  mise run encrypt
  ```

- **Decrypt Secrets** (for debugging only):
  ```bash
  mise run decrypt
  ```

- **Edit Encrypted Secrets**:
  ```bash
  mise run edit-encrypt
  ```

## Security Notes

- Ensure `keys.txt` is **never** committed to version control. It is explicitly ignored in `.gitignore`.


## License

This project is licensed under the MIT License. See the LICENSE file for details.
