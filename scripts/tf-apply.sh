echo "Building Purescript Code"
./scripts/build.sh

echo "Loading Environment Variables"
export $(cat .env | xargs)

echo "Running Terraform Plan"
cd infra
terraform apply