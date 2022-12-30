echo "Building Purescript Code"
./scripts/build.sh

echo "Loading Environment Variables"
export $(cat .env | xargs)

echo "Validating"
sam validate -t sam.yaml --region $AWS_REGION

export DOCKER_HOST="unix://$HOME/.colima/docker.sock"

echo "Invoking"
sam local invoke PurescriptLambda -t sam.yaml --region $AWS_REGION


