echo "Loading Environment Variables"
export $(cat .env | xargs)

echo "Running Terraform Plan"
cd infra
terraform init