curl -fsSL https://opencode.ai/install | bash     # installs to ~/.opencode/bin
source ~/.bashrc

export AWS_REGION=us-east-1
eval "$(aws configure export-credentials --format env)"   # makes credentials explicit for the Node SDK