## k8s-cluster

### Overview
Help to create all the AWS infrastructure to have a k8s cluster.

### Requirements
- [pre-commit](https://pre-commit.com)
- [jq](https://stedolan.github.io/jq)
- [yq](https://github.com/mikefarah/yq)
- [hclq](https://github.com/mattolenik/hclq)
- [shellcheck](https://github.com/koalaman/shellcheck)
- [shfmt](https://github.com/mvdan/sh)
- [terraform](https://www.terraform.io/downloads)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- aws s3 bucket
- [kubectl](https://kubernetes.io/docs/tasks/tools)

> Please use the latest version for all the requirements.<br/>
> The `upgrade-dependencies.sh` local pre-commit repo should upgrade<br/>
> to the latest all the dependencies used by pre-commit itself and by terraform.

### AWS infrastructure

### AWS VPC
The project create an AWS VCP using the ipV4 CIDR block specified under
`project_aws_vpc_cidr_block` terraform variable.<br/>
Consider that:
- the project creates 6 subnets using a `/27`

### AWS Subnets
The project creates mainly the following AWS services:
- RDS mysql, requires at less two subnets in different availability zones
- EKS, use four subnets; two public and two private in different availability zones

##### AWS Database Subnets
Database will create two subnets using a `/27` CIDR:

| NETWORK     | RANGES                          |
|-------------|---------------------------------|
| x.x.x.0/27  | from x.x.x.1/27 to x.x.x.30/27  |
| x.x.x.32/27 | from x.x.x.33/27 to x.x.x.62/27 |

##### AWS EKS Public Subnets
AWS EKS will use two public subnets `/27` CIDR:

| NETWORK     | RANGES                           |
|-------------|----------------------------------|
| x.x.x.64/27 | from x.x.x.65/27 to x.x.x.94/27  |
| x.x.x.96/27 | from x.x.x.97/27 to x.x.x.126/27 |

##### AWS EKS Private Subnets
AWS EKS will use two private subnets `/27` CIDR:

| NETWORK      | RANGES                            |
|--------------|-----------------------------------|
| x.x.x.128/27 | from x.x.x.129/27 to x.x.x.158/27 |
| x.x.x.160/27 | from x.x.x.161/27 to x.x.x.190/27 |

### Running the whole project
The project has an order in which it needs to be executed:
1. Create the initial infrastructure, basically create an eks service
2. Provisioning the initial infrastructure, basically deploy whatever application you want
3. Add infrastructure to expose the application
4. Have fun!

##### Initial infrastructure
1. Init `terraform init`
2. Plan `terraform plan -var-file=k8s-cluster-1.tfvars` (optional)
3. Apply `terraform apply -var-file=k8s-cluster-1.tfvars`
4. Destroy `terraform destroy -var-file=k8s-cluster-1.tfvars`

>Note that we are passing the k8s-cluster-1.tfvars variables file,
>review if you need different file or values in there

##### Provisioning
Use the following command to download the kubeconfig file on your local `~/.kube/` directory:
`aws eks --region us-west-2 --profile dev update-kubeconfig --name k8s-cluster-1-eks --alias k8s-cluster-1 --kubeconfig ~/.kube/k8s-cluster-1`

##### Exposing the application
1. Init `terraform init`
2. Plan `terraform plan -var-file=k8s-cluster-1.tfvars` (optional)
3. Apply `terraform apply -var-file=k8s-cluster-1.tfvars`
4. Destroy `terraform destroy -var-file=k8s-cluster-1.tfvars`

>Note that we are passing the k8s-cluster-1.tfvars variables file,
>review if you need different file or values in there

##### Have fun!

Now you have an up and running application on AWS EKS, that could be use to do whatever you want!
