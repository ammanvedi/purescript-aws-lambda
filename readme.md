# Purescript Lambda

Deploy a purescript function to AWS Lambda

## Getting Started

### [Install Purescript](https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md#installing-the-compiler)
Purescript is a functional programming language that compiles to Javascript

### [Install Spago](https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md#setting-up-the-development-environment)
Spago is a build tool and package manager for purescript

### [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
Terraform is an infrastructure as code tool, we will use it to deploy our lambda function to AWS

### Update Terraform Variables
in `infra/main.tf` you should change elements marked with `# TODO: Change as needed` so that they reflect your project.

### Create Your Own `.env` File
Create a `.env` file in the root of the project which matches the structure of the `.env.example` provided. See here for help getting [AWS secret keys](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)

### Initialise Terraform
Run `./scripts/tf-init.sh` to install all terraform modules and set up the S3 backend (where terraform will store the state of your project)

### Run a Build
Run `./scripts/build.sh` and with any luck your code will be built to the dist folder. You can have a look and see whet purescript will generate from the purs files.

### Run a Terraform Plan
Run `./scripts/tf-plan.sh` to see what changes will be applied to your infrastructure. On the first run you should see alot of resources being created

### Run a Terraform Apply
Run `./scripts/tf-apply.sh` to see what changes will be applied to your infrastructure and type "yes" to apply these changes. After doing this you should be able to go into the AWS console to see the lambda function exists.

When you make any changes its a case of running the plan and apply scripts again to upload the new code or make any other changes.

## The Codebase

There are two main sides to this codebase;

### Purescript

#### `src/`
The purescript code is located here. The entry point of the lambda is the handler function in Main.purs.

#### `test/`
Here live our purescript tests, implementation is left as an excercise for the reader.

#### `scripts/`
Scripts for the development lifeycle

#### `infra/`
Contains the Terraform code that is used to deploy the lambda function to AWS

#### `lambda.package.json`
A package.json that is uploaded with the lambda function. The most important bit of this is that it sets `type: "module"` 
so that AWS knows this JS code uses native ES Modules syntax

#### `spago.dhall`
This is Purescript's dependency file, it lists all the packages needed to compile the project