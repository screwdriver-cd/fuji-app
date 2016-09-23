# fuji-app

Demo app that shows Flickr images of mount everest in a slideshow. Built by
[Screwdriver](https://screwdriver.cd) and deployed to AWS using CodeDeploy.



## Run Locally
#### Setup
```bash
$ git clone git@github.com:screwdriver-cd/fuji-app.git
$ cd fuji-app/app/
$ npm install
```

#### Start locally
```bash
$ cd fuji-app/app/
$ npm start
```
Navigate to http://localhost:8000.

#### Test
```bash
$ cd fuji-app/app/
$ npm test
```

## Deploy to AWS w/CodeDeploy
We will follow along loosely with the [CodeDeploy Tutorial](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-wordpress.html).

#### Step 0: Set Up Roles and Profiles
##### Screwdriver
First, add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` [Screwdriver secrets](https://github.com/screwdriver-cd/screwdriver/tree/8775adf7107c5a5d6bf0c99cce97e05cc1ffd855/plugins/secrets) for an AWS user. These will be used for aws-cli commands later.

##### AWS
Next, follow steps in [Getting Started with AWS CodeDeploy](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-setup.html). Skip Step 5.

The trust relationship for our `fuji-app.demo` role looks like the example below, where the ARN is the user whose secrets we added.
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": arn:aws:iam::555555555555:user/screwdriver,
        "Service": [
          "config.amazonaws.com",
          "codedeploy.us-west-2.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
It has the following policies attached:
CodeDeploy powers:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObject",
                "ec2:*",
                "codedeploy:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
Access to the S3 Bucket:
```
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":["s3:PutObject"],
      "Resource":"arn:aws:s3:::fuji-app.demo/*"
    }
  ]
}
```

Our `user` has the following policies attached:
Permission to assume the role we created:
```
 {
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::555555555555:role/fuji-app.demo"
  }
}
```
Access to the S3 bucket:
```
{
  "Version":"2012-10-17",  
  "Statement":[
    {
      "Effect":"Allow",
      "Action":["s3:PutObject"],
      "Resource":"arn:aws:s3:::fuji-app.demo/*"
    }
  ]
}
```
CodeDeploy permissions:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codedeploy:Batch*",
        "codedeploy:CreateDeployment",
        "codedeploy:Get*",
        "codedeploy:List*",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

#### Step 1: Set Up an Ubuntu EC2 Instance
Follow [How to set up a new instance](http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-set-up-new-instance.html).
Choose an Ubuntu instance and use `aws-codedeploy-us-west-2` for `bucket-name` and `us-west-2` for `region-name`, like so:
```bash
#!/bin/bash
apt-get -y update
apt-get -y install awscli
apt-get -y install ruby2.0
cd /home/ubuntu
aws s3 cp s3://aws-codedeploy-us-west-2/latest/install . --region us-west-2
chmod +x ./install
./install auto
```

Tag your instance with the `Name` `fuji-app.demo`.

#### Step 2: Configure Your Source Content to Deploy
You will need to a folder with executable scripts to be run in your `appspec.yml` file. The `appspec.yml` file is a YAML-formatted file used by AWS CodeDeploy.
For more information, see the [tutorial](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-configure-repo.html).

#### Step 3: Upload Your Application to Amazon S3
Follow instructions to [Provision an Amazon S3 Bucket](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-push-repo.html). Make sure to create your S3 bucket with the name `fuji-app.demo` with the proper policies.

If it's the first time deploying this application, you will need to register your application by switching to the folder where the files are stored and running a `create-application` command:

```bash
$ cd app/
$ aws deploy create-application --application-name Fuji_App
```

NOTE: The `./bin/code_deploy.sh` file will call the `aws deploy push` command to bundle the files together, upload the revisions to Amazon S3, and register information with AWS CodeDeploy about the uploaded revision, all in one action.

#### Step 4: Deploy Your Application
Follow instructions at [Deploy your Application](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-deploy.html).

If it's the first time deploying this application, you will need to create a deployment group by running a `create-deployment-group` command with your `serviceRoleARN`. Use the same `Value` as you used for the `Name` tag you used when creating your instance (`fuji-app.demo`).

```bash
$ aws deploy create-deployment-group \
    --application-name Fuji_App \
    --deployment-group-name Fuji_DepGroup \
    --deployment-config-name CodeDeployDefault.OneAtATime \
    --ec2-tag-filters Key=Name,Value=fuji-app.demo,Type=KEY_AND_VALUE \
    --service-role-arn {{serviceRoleARN}}
```

NOTE: The `./bin/code_deploy.sh` file will call the `aws deploy create-deployment` command to create a deployment associated with the application.


#### Step 5: Update and Redeploy Your Application
After setting up your app and deploying to AWS for the first time, any new changes you make to the code will be automatically built, pushed, and redeployed when rerunning the Screwdriver job.
