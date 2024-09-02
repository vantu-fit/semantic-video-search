### Getting Started
1. Create ECR repository
- Initialize the repository
```bash
cd terraform
terraform init
```

- Create private ECR repository
```bash
make create-ecr-repo
```

2. Build and push the image to ECR
- Build the image
```bash
make build-ecs-video
make push-ecs-video
```
Output:
```bash
ecr_repo_url = "<aws account id>.dkr.ecr.ap-southeast-1.amazonaws.com/semantic-repo"
```
